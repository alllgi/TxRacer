"""Contract-qualified ABI metadata and simple, pool-free input construction."""

from dataclasses import dataclass
import re

from eth_abi import decode_abi
from eth_utils import function_signature_to_4byte_selector, to_normalized_address

from fuzzer.txracer.pipeline.core.model import Transaction, Sequence


def abi_type(item):
    text = item["type"]
    if text.startswith("tuple"):
        return "(" + ",".join(abi_type(c) for c in item["components"]) + ")" + text[5:]
    return text


def split_tuple(text):
    result, depth, start = [], 0, 0
    for index, char in enumerate(text):
        if char in "([":
            depth += 1
        elif char in ")]":
            depth -= 1
        elif char == "," and depth == 0:
            result.append(text[start:index])
            start = index + 1
    return result + [text[start:]] if text else []


def build_value(text, accounts, rng=None):
    array = re.match(r"^(.*)\[([0-9]*)\]$", text)
    if array:
        length = int(array[2]) if array[2] else (rng.randrange(4) if rng else 0)
        return tuple(build_value(array[1], accounts, rng) for _ in range(length))
    if text.startswith("("):
        return tuple(build_value(t, accounts, rng) for t in split_tuple(text[1:-1]))
    if text.startswith("uint") or text.startswith("int"):
        signed = text.startswith("int")
        bits = int(text[3 if signed else 4:] or "256")
        return rng.randint(-(2 ** (bits - 1)) if signed else 0,
                           2 ** (bits - int(signed)) - 1) if rng else 0
    if text == "address":
        return rng.choice(accounts) if rng else accounts[0]
    if text == "bool":
        return bool(rng.randrange(2)) if rng else False
    if text == "string":
        return "" if rng is None else chr(97 + rng.randrange(26))
    if text.startswith("bytes"):
        size = int(text[5:]) if text != "bytes" else (rng.randrange(4) if rng else 0)
        return bytes(rng.randrange(256) if rng else 0 for _ in range(size))
    raise ValueError("Unsupported ABI type: %s" % text)


@dataclass(frozen=True)
class Function:
    contract: str
    contract_name: str
    signature: str
    selector: str
    types: tuple
    names: tuple
    payable: bool
    read_only: bool
    kind: str = "function"

    @property
    def key(self):
        return (self.contract, self.selector)

    @property
    def qualified_signature(self):
        return self.contract + ":" + self.signature


class AbiCatalog:
    def __init__(self, deployed_contracts, include_fallback=False, include_receive=False):
        self.functions = {}
        self.initial_functions = []
        self.contracts = {}
        self.diagnostics = []
        self.argument_schemas = {}
        self.input_templates = None
        for contract in deployed_contracts:
            if not contract.get("in_scope", True) or contract.get("kind", "contract") != "contract":
                continue
            if not contract.get("address"):
                continue
            address = to_normalized_address(contract["address"])
            self.contracts[contract["name"]] = address
            for entry in contract["abi"]:
                kind = entry.get("type", "function")
                if kind == "constructor":
                    continue
                if kind not in ("function", "fallback", "receive"):
                    continue
                inputs = entry.get("inputs", [])
                types = tuple(abi_type(item) for item in inputs)
                signature = entry.get("name", kind) + "(" + ",".join(types) + ")"
                selector = function_signature_to_4byte_selector(signature).hex() if kind == "function" else (
                    "00000000" if kind == "fallback" else "")
                function = Function(address, contract["name"], signature, selector, types,
                                    tuple(item.get("name", "") for item in inputs),
                                    entry.get("stateMutability") == "payable" or entry.get("payable", False),
                                    entry.get("stateMutability") in ("view", "pure") or entry.get("constant", False), kind)
                self.argument_schemas[function.key] = inputs


                if kind == "receive" or function.key not in self.functions:
                    self.functions[function.key] = function
                elif kind == "function" and self.functions[function.key].signature != signature:
                    raise ValueError("ABI selector collision within deployed contract")
                if not function.read_only and (kind == "function" or
                        kind == "fallback" and include_fallback or kind == "receive" and include_receive):
                    self.initial_functions.append(function)
        self.initial_functions.sort(key=lambda f: (f.contract, f.signature))

    def function_for(self, transaction):
        return self.functions.get((transaction.contract, transaction.selector))

    def transaction(self, function, sender, accounts, rng=None, arguments=None):
        if arguments is not None:
            from fuzzer.txracer.pipeline.core.input_templates import normalize_arguments
            arguments = normalize_arguments(self.argument_schemas[function.key], arguments)
        if self.input_templates is not None:
            return self.input_templates.construct(function, sender, accounts, rng, arguments)
        values = tuple(build_value(t, accounts, rng) for t in function.types) if arguments is None else arguments
        return Transaction(function.contract, function.selector, function.types, values, sender)

    def decode_transaction(self, payload, environment=None):

        data = payload["data"]
        if data.startswith("0x"):
            data = data[2:]
        selector = data[:8] if data else ""
        key = (to_normalized_address(payload["to"]), selector)
        function = self.functions.get(key)
        if function is None:
            raise ValueError("Unknown contract-qualified function: %r" % (key,))
        arguments = decode_abi(function.types, bytes.fromhex(data[8:]))
        fields = dict(contract=key[0], selector=selector, argument_types=function.types,
                      arguments=arguments, sender=payload["from"], value=payload["value"], gas=payload["gaslimit"])
        if environment is not None:
            fields["environment"] = environment
        return Transaction(**fields)

    def initial_sequences(self, sender, accounts, preparation=(), max_length=20):
        sequences = [Sequence([self.transaction(f, sender, accounts)]) for f in self.initial_functions]
        if self.input_templates is not None:
            for function in self.initial_functions:
                for example in self.input_templates.choices(function, sender):
                    sequences.append(Sequence([self.transaction(function, sender, accounts,
                                                               arguments=example.transaction.arguments).changed(value=example.transaction.value)]))


        by_name = {(f.contract_name, f.signature): f for f in self.initial_functions}
        for chain in preparation:
            txs = []
            for item in chain:
                key = (item["contract"], item["function"])
                if key not in by_name:
                    raise ValueError("Preparation references unavailable ABI entry: %r" % (key,))
                if item.get("sender", sender).lower() != sender.lower():
                    raise ValueError("Preparation sender must match the fixed User")
                transaction = self.transaction(by_name[key], sender, accounts, arguments=item.get("arguments"))
                fields = {k: item[k] for k in ("value", "gas") if k in item}
                if "environment" in item:
                    from fuzzer.txracer.pipeline.core.model import Environment
                    fields["environment"] = Environment(**item["environment"])
                txs.append(transaction.changed(**fields))
            sequences.append(Sequence(txs))
        unique = {}
        for sequence in sequences:
            if not 1 <= len(sequence) <= max_length:
                raise ValueError("Initial sequence violates the User length bound")
            unique.setdefault(sequence.identity, sequence)
        return tuple(unique.values())

    def preparation_from_template(self, template):

        from fuzzer.txracer.planner.sequence_planner import normalize_sequence_template
        entries = normalize_sequence_template(template)
        if isinstance(template, dict) and template.get("planner_failure"):
            raise ValueError("Cannot use failed preparation plan")
        chain = []
        for entry in entries:
            signature = entry["signature"]
            all_matches = [f for f in self.functions.values() if f.signature == signature and
                           (not entry.get("contract") or f.contract_name == entry["contract"])]
            if not all_matches and entry.get("contract") not in self.contracts:
                self.diagnostics.append(("preparation_out_of_deployed_scope", entry["contract"], signature))
                continue
            if all_matches and all(f.read_only for f in all_matches):
                self.diagnostics.append(("preparation_query_excluded_from_user_corpus", entry["contract"], signature))
                continue
            matches = [f for f in self.initial_functions if f.signature == signature and
                       (not entry.get("contract") or f.contract_name == entry["contract"])]
            if len(matches) != 1:
                raise ValueError("Preparation entry is unavailable or ambiguous: %r" % entry)
            chain.append(dict({"contract": matches[0].contract_name, "function": signature},
                              **{k: entry[k] for k in ("arguments", "value", "gas", "environment", "sender") if k in entry}))
        return [chain] if chain else []
