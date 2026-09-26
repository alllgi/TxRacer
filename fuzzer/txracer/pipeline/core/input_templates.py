"""Offline, contract-qualified input examples; never an execution verdict."""
from collections import Counter, defaultdict
from dataclasses import dataclass

from fuzzer.txracer.pipeline.core.model import json_value


def structured(types):
    return any("[" in t or "(" in t or t in ("bytes", "string") for t in types)


def normalize_arguments(inputs, values):
    """Accept positional ABI values or explicitly named tuple components."""
    from fuzzer.txracer.pipeline.core.model import from_json_value
    values = from_json_value(values)
    if isinstance(values, dict):
        names = [item.get("name", "") for item in inputs]
        if not all(names) or len(set(names)) != len(names) or set(values) != set(names):
            raise ValueError("Named ABI arguments require all and only unique component names")
        values = tuple(values[name] for name in names)
    if not isinstance(values, (list, tuple)) or len(values) != len(inputs):
        raise ValueError("ABI argument count mismatch")

    def convert(schema, value):
        text = schema["type"]
        if text.endswith("]"):
            element, _, size = text.rpartition("[")
            if not isinstance(value, (list, tuple)):
                raise ValueError("ABI array requires a list")
            if size[:-1] and len(value) != int(size[:-1]):
                raise ValueError("Fixed ABI array length mismatch")
            return tuple(convert(dict(schema, type=element), v) for v in value)
        if text == "tuple":
            return normalize_arguments(schema["components"], value)
        if text.startswith("bytes"):
            value = from_json_value(value)
            if isinstance(value, str) and value.startswith("0x"):
                value = bytes.fromhex(value[2:])
            if not isinstance(value, (bytes, bytearray)):
                raise ValueError("ABI bytes require explicit hex bytes")
            return bytes(value)
        return value
    return tuple(convert(schema, value) for schema, value in zip(inputs, values))


@dataclass(frozen=True)
class CallTemplate:
    transaction: object
    source: str
    successful: bool
    related_arguments: tuple = ()
    related_value: bool = False


class InputTemplates:
    """Keep complete argument/value combinations and their provenance together."""
    def __init__(self, balance, limit_per_function=64):
        self.balance = balance
        self.limit = limit_per_function
        self.templates = defaultdict(list)
        self.payments = defaultdict(dict)
        self.usage = Counter()
        self.generated = Counter()
        self.queries = []

    def add(self, transaction, source, successful=False, *, related_arguments=(), related_value=False):


        if any(type(i) is not int or not 0 <= i < len(transaction.arguments) for i in related_arguments):
            raise ValueError("Related argument index is outside the transaction ABI")
        related_arguments = tuple(sorted(set(related_arguments)))
        key = (transaction.contract, transaction.selector)
        entries = self.templates[key]
        identity = (transaction.arguments, transaction.value)
        for index, entry in enumerate(entries):
            if (entry.transaction.arguments, entry.transaction.value) == identity:
                entries[index] = CallTemplate(
                    transaction if successful and not entry.successful else entry.transaction,
                    source if successful and not entry.successful else entry.source,
                    successful or entry.successful,
                    tuple(sorted(set(entry.related_arguments) | set(related_arguments))),
                    entry.related_value or related_value)
                break
        else:
            if len(entries) < self.limit:
                entries.append(CallTemplate(transaction, source, successful, related_arguments, related_value))
        self.add_value(key, transaction.value, source)

    def related_fields(self, function):

        entries = self.templates.get(function.key, ())
        return (frozenset(i for entry in entries for i in entry.related_arguments),
                any(entry.related_value for entry in entries))

    def add_value(self, key, value, source):
        if type(value) is not int or not 0 <= value < 2 ** 256:
            raise ValueError("Payment sample must be a raw uint256 integer")
        values = self.payments[key]
        if value in values or len(values) < self.limit:
            values[value] = source

    def values(self, transaction):
        available = self.balance(transaction.sender)
        values = set(self.payments.get((transaction.contract, transaction.selector), {}))
        values.update((0, transaction.value))
        return tuple(sorted(v for v in values if v <= available))

    def choices(self, function, sender):
        entries = [t for t in self.templates.get(function.key, ())
                   if t.transaction.value <= self.balance(sender)]

        successful = [t for t in entries if t.successful]
        return successful or entries

    def construct(self, function, sender, accounts, rng=None, arguments=None):
        from fuzzer.txracer.pipeline.core.abi import build_value
        from fuzzer.txracer.pipeline.core.model import Transaction
        choices = self.choices(function, sender)
        if arguments is not None:
            choices = [t for t in choices if t.transaction.arguments == tuple(arguments)]
        if choices:
            chosen = rng.choice(choices) if rng else choices[0]
            self.usage["whole_call_template_used"] += 1
            self.usage["structured_argument_template_used"] += int(structured(function.types))
            self.usage["payable_value_candidate_used"] += int(function.payable)


            return Transaction(function.contract, function.selector, function.types,
                               chosen.transaction.arguments, sender, value=chosen.transaction.value)
        values = tuple(build_value(t, accounts, rng) for t in function.types) if arguments is None else arguments
        tx = Transaction(function.contract, function.selector, function.types, values, sender)
        if function.payable:
            payments = self.values(tx)
            nonzero = [v for v in payments if v > 0]
            selected = rng.choice(payments) if rng else (nonzero[0] if nonzero else 0)
            tx = tx.changed(value=selected)
            self.usage["payable_value_candidate_used"] += 1
        return tx

    def mutate(self, transaction, function, rng):
        from fuzzer.txracer.pipeline.core.model import Sequence
        seen = {Sequence([transaction]).identity}
        candidates = []
        for entry in self.choices(function, transaction.sender):
            candidate = transaction.changed(arguments=entry.transaction.arguments,
                                            value=entry.transaction.value)
            identity = Sequence([candidate]).identity
            if identity in seen:
                continue
            seen.add(identity)
            candidates.append(candidate)
        if not candidates:
            return None
        selected = rng.choice(candidates)
        self.usage["whole_call_template_used"] += 1
        self.usage["structured_argument_template_used"] += int(structured(function.types))
        self.usage["payable_value_candidate_used"] += int(function.payable)
        return selected

    def note_generated(self, sequence, accepted):
        self.generated["generated_call_count"] += len(sequence)
        self.generated["queued_call_count"] += len(sequence) if accepted else 0

    def summary(self):
        return dict(self.usage, **self.generated,
                    templates=[dict(contract=k[0], selector=k[1], source=t.source,
                                    successful=t.successful,
                                    related_arguments=t.related_arguments,
                                    related_value=t.related_value,
                                    arguments=json_value(t.transaction.arguments),
                                    value=t.transaction.value)
                               for k, entries in sorted(self.templates.items()) for t in entries],
                    payable_samples=[dict(contract=k[0], selector=k[1], value=value, source=source)
                                     for k, values in sorted(self.payments.items())
                                     for value, source in sorted(values.items())],
                    initialization_value_queries=self.queries)
