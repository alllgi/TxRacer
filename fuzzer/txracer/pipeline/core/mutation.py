"""Explicit input and sequence mutation; every decision has one call site."""

from dataclasses import dataclass

from fuzzer.txracer.pipeline.core.abi import build_value
from fuzzer.txracer.pipeline.core.model import Sequence


@dataclass(frozen=True)
class MutationResult:
    sequence: Sequence
    changed: bool
    operator: str
    decisions: tuple = ()


class InputMutator:
    def __init__(self, catalog, accounts, rng, pm=0.1, mutate_sender=False,
                 mutate_environment=False, max_value=10 ** 18):
        if not 0 <= pm <= 1:
            raise ValueError("pm must be a probability")
        self.catalog, self.accounts, self.rng, self.pm = catalog, tuple(accounts), rng, pm
        self.mutate_sender, self.mutate_environment = mutate_sender, mutate_environment
        self.max_value = None if max_value is None else int(max_value)
        if self.max_value is None and catalog.input_templates is None:
            raise ValueError("No-cap input construction requires explicit payment samples")

    def mutate(self, sequence):
        txs, template_txs, decisions = [], [], []
        for index, tx in enumerate(sequence):
            templates = self.catalog.input_templates
            function = self.catalog.function_for(tx)
            template = None
            related_arguments, related_value = (), False
            if templates is not None and function is not None:
                related_arguments, related_value = templates.related_fields(function)
            if templates is not None and function is not None and templates.choices(function, tx.sender):
                selected = self.rng.random() < self.pm
                decisions.append((index, "whole_call_template", None, selected))
                if selected:
                    template = templates.mutate(tx, function, self.rng)
            args = list(tx.arguments)
            for parameter, arg_type in enumerate(tx.argument_types):
                selected = self.rng.random() < self.pm and parameter not in related_arguments
                decisions.append((index, "argument", parameter, selected))
                if selected:
                    args[parameter] = build_value(arg_type, self.accounts, self.rng)
            changes = {"arguments": tuple(args)}
            function = self.catalog.function_for(tx)
            if function is not None and function.payable:
                selected = self.rng.random() < self.pm and not related_value
                decisions.append((index, "value", None, selected))
                if selected:
                    if templates is not None:
                        changes["value"] = self.rng.choice(templates.values(tx))
                        templates.usage["payable_value_candidate_used"] += 1
                    else:
                        changes["value"] = self.rng.randint(0, self.max_value)
            if self.mutate_sender:
                selected = self.rng.random() < self.pm
                decisions.append((index, "sender", None, selected))
                if selected:
                    changes["sender"] = self.rng.choice(self.accounts)
            if self.mutate_environment:
                from dataclasses import replace
                environment = tx.environment
                for field in ("blocknumber", "timestamp"):
                    selected = self.rng.random() < self.pm
                    decisions.append((index, field, None, selected))
                    if selected:
                        environment = replace(environment, **{field: self.rng.randrange(2 ** 32)})
                changes["environment"] = environment
            mutated = tx.changed(**changes)
            txs.append(mutated)
            template_txs.append(template if template is not None else mutated)


        seen, candidates = {sequence.identity}, []
        for transactions in (txs, template_txs):
            candidate = Sequence(transactions)
            if candidate.identity in seen:
                continue
            seen.add(candidate.identity)
            candidates.append(candidate)
        candidate = self.rng.choice(candidates) if len(candidates) > 1 else candidates[0] if candidates else sequence
        return MutationResult(candidate, candidate.identity != sequence.identity, "input", tuple(decisions))


class SequenceMutator:
    OPERATORS = ("insert", "repeat", "delete", "swap")

    def __init__(self, rng, transaction_builder, max_length=20, operators=OPERATORS):
        if not 1 <= max_length <= 20 or not operators or any(op not in self.OPERATORS for op in operators):
            raise ValueError("Invalid sequence mutation configuration")
        self.rng, self.transaction_builder, self.max_length = rng, transaction_builder, max_length
        self.operators = tuple(operators)

    def mutate(self, sequence, operator=None):
        if not 1 <= len(sequence) <= self.max_length:
            raise ValueError("Parent violates User length bound")
        operator = operator or self.rng.choice(self.operators)
        if operator not in self.operators:
            raise ValueError("Disabled sequence operator")
        txs = list(sequence)
        if operator == "insert" and len(txs) < self.max_length:
            txs.insert(self.rng.randrange(len(txs) + 1), self.transaction_builder())
        elif operator == "repeat" and len(txs) < self.max_length:
            index = self.rng.randrange(len(txs))
            txs.insert(index + 1, txs[index])
        elif operator == "delete" and len(txs) > 1:
            del txs[self.rng.randrange(len(txs))]
        elif operator == "swap" and len(txs) > 1:
            first, second = self.rng.sample(range(len(txs)), 2)
            txs[first], txs[second] = txs[second], txs[first]
        candidate = Sequence(txs)
        return MutationResult(candidate, candidate.identity != sequence.identity, operator)
