"""Construct candidate attack sequences for authorized security testing."""

from collections import deque
from dataclasses import dataclass, replace

from fuzzer.txracer.pipeline.core.model import Sequence

PARAMETER = "parameter_mutation"
INSERTION = "state_aware_insertion"
REVERSAL = "flow_reversal"


@dataclass(frozen=True)
class AttackerCandidate:
    sequence: Sequence
    candidate_id: str
    parent_id: str
    user_sequence_id: str
    operators: tuple = ()
    depth: int = 0
    transaction_ids: tuple = ()
    evidence: tuple = ()


@dataclass(frozen=True)
class InferenceConfig:
    candidate_budget: int = 8
    max_depth: int = 2
    max_length: int = 25

    def __post_init__(self):
        if self.candidate_budget < 1 or self.max_depth < 0 or not 1 <= self.max_length <= 25:
            raise ValueError("Invalid Attacker inference bounds")


class InferenceContext:
    def __init__(self, catalog, user, attacker, attacker_balance, planner_functions, argument_builder):
        self.catalog, self.user, self.attacker = catalog, user, attacker
        self.attacker_balance = int(attacker_balance)
        self.planner_functions = tuple(planner_functions)
        self.argument_builder = argument_builder
        self.function_rw, self.amount_indices, self.recipient_indices = {}, {}, {}
        self.confirmed_directions, self.reverse_sources = [], {}
        self.diagnostics = []
        for function in catalog.functions.values():
            self.amount_indices[function.key] = tuple(
                index for index, name in enumerate(function.names)
                if any(token in name.lower() for token in ("amount", "quantity", "value")))

    def observe(self, result):

        for record in result.records:
            function = self.catalog.function_for(record.transaction)
            if function is None:
                continue
            rw = self.function_rw.setdefault(function.key, {"reads": set(), "writes": set()})
            rw["reads"].update(record.reads)
            rw["writes"].update(record.writes)
            if record.status != "SUCCESS":
                continue
            flows = [f for f in record.asset_flows if not f.attempted and not f.ambiguous]
            for index, (name, arg_type, value) in enumerate(zip(function.names, function.types, record.transaction.arguments)):
                if arg_type == "address" and name.lower() in ("recipient", "receiver", "to"):
                    if value in (self.user, self.attacker) and any(f.recipient == value for f in flows):
                        self.recipient_indices[function.key] = index
            for outgoing in flows:
                if outgoing.sender != record.sender or outgoing.recipient == record.sender:
                    continue
                for incoming in flows:
                    if incoming.recipient != record.sender or incoming.sender == record.sender:
                        continue
                    if outgoing.asset_id == incoming.asset_id:
                        continue
                    direction = (tuple(outgoing.asset_id), tuple(incoming.asset_id))
                    self.confirmed_directions.append((direction, result.sequence.identity, record.tx_id))


                    self.reverse_sources[direction] = function


def _child(parent, sequence, operator, evidence, ids=None):
    # Attack candidates can reveal ways to cause loss of real on-chain assets.
    return AttackerCandidate(sequence, "", parent.candidate_id, parent.user_sequence_id,
                          parent.operators + (operator,), parent.depth + 1,
                          tuple(ids) if ids is not None else parent.transaction_ids, tuple(evidence))


def _insert_id(ids, index, prefix):
    counter = max([int(i.rsplit("-", 1)[-1]) for i in ids if i.rsplit("-", 1)[-1].isdigit()] or [0]) + 1
    new_id = "%s-%d" % (prefix, counter)
    while new_id in ids:
        counter += 1
        new_id = "%s-%d" % (prefix, counter)
    result = list(ids)
    result.insert(index, new_id)
    return tuple(result)


def parameter_mutation(parent, context):
    children = []
    for index, tx in enumerate(parent.sequence):
        function = context.catalog.function_for(tx)
        if function is None:
            continue
        changes = []
        templates = context.catalog.input_templates
        if templates is not None and templates.choices(function, tx.sender):


            for example in templates.choices(function, tx.sender):
                changed = tx.changed(arguments=example.transaction.arguments, value=example.transaction.value)
                if changed != tx:
                    changes.append((changed, ("whole_call_template", index, example.source)))
            children.extend(_child(parent, parent.sequence.replace_transaction(index, changed), PARAMETER, evidence)
                            for changed, evidence in changes)
            continue
        for parameter in context.amount_indices.get(function.key, ()):
            text, value = tx.argument_types[parameter], tx.arguments[parameter]
            if "[" in text or not (text.startswith("uint") or text.startswith("int")) or isinstance(value, bool):
                continue
            signed = text.startswith("int")
            bits = int(text[3 if signed else 4:] or "256")
            lower, upper = (-(2 ** (bits - 1)), 2 ** (bits - 1) - 1) if signed else (0, 2 ** bits - 1)
            for new in (0, 1, value - 1, value + 1, value // 2, value * 2):
                if lower <= new <= upper and new != value:
                    args = list(tx.arguments)
                    args[parameter] = new
                    changes.append((tx.changed(arguments=tuple(args)), ("amount", index, parameter, new)))
        recipient = context.recipient_indices.get(function.key)
        if recipient is not None and tx.argument_types[recipient] == "address":
            for address in (context.attacker, context.user, tx.arguments[recipient]):
                if address != tx.arguments[recipient]:
                    args = list(tx.arguments)
                    args[recipient] = address
                    changes.append((tx.changed(arguments=tuple(args)), ("recipient", index, recipient, address)))
        if function.payable:
            values = templates.values(tx) if templates is not None else (0, tx.value, tx.value // 2, tx.value * 2)
            for new in values:
                if new != tx.value and new <= context.attacker_balance:
                    changes.append((tx.changed(value=new), ("value", index, new)))
        children.extend(_child(parent, parent.sequence.replace_transaction(index, changed), PARAMETER, evidence)
                        for changed, evidence in changes)
    return children


def _build(function, context):
    try:
        arguments = context.argument_builder(function)
        if arguments is None:
            raise ValueError("argument builder returned no arguments")
        return context.catalog.transaction(function, context.attacker, (context.user, context.attacker), arguments=arguments)
    except (ValueError, TypeError) as error:
        context.diagnostics.append(("argument_construction_failed", function.qualified_signature, str(error)))
        return None


def state_aware_insertion(parent, context, economic_states):
    children, sigma = [], set(economic_states)
    for index, tx in enumerate(parent.sequence):
        current = context.function_rw.get((tx.contract, tx.selector), {})
        for function in context.planner_functions:
            rw = context.function_rw.get(function.key, {})
            before = set(rw.get("writes", ())) & set(current.get("reads", ())) & sigma
            after = set(rw.get("reads", ())) & set(current.get("writes", ())) & sigma
            for position, intersection, side in ((index, before, "before"), (index + 1, after, "after")):
                if not intersection:
                    continue
                inserted = _build(function, context)
                if inserted is None:
                    continue
                txs = list(parent.sequence)
                txs.insert(position, inserted)
                children.append(_child(parent, Sequence(txs), INSERTION,
                                       (side, function.qualified_signature, tuple(sorted(intersection))),
                                       _insert_id(parent.transaction_ids, position, "ins")))
    return children


def flow_reversal(parent, context):

    children = []
    for (asset_a, asset_b), sequence_id, tx_id in context.confirmed_directions:
        source = context.reverse_sources.get((asset_b, asset_a))
        if source is None or source not in context.planner_functions:
            context.diagnostics.append(("UNSUPPORTED_FLOW_REVERSAL", sequence_id, tx_id))
            continue
        inserted = _build(source, context)
        if inserted is None:
            continue
        children.append(_child(parent, Sequence(tuple(parent.sequence) + (inserted,)), REVERSAL,
                               ("confirmed_reverse_source", source.qualified_signature, asset_b, asset_a),
                               _insert_id(parent.transaction_ids, len(parent.sequence), "rev")))
    return children


class AttackerInference:
    def __init__(self, config=None):
        self.config = config or InferenceConfig()
        self.events = []

    def derive(self, observation, context):
        user = observation.result.sequence
        base_sequence = Sequence(tuple(tx.changed(sender=context.attacker) for tx in user))
        if not 1 <= len(base_sequence) <= self.config.max_length:
            return (), False
        base = AttackerCandidate(base_sequence, "attacker-0000", "", user.identity,
                              transaction_ids=tuple("attacker-tx-%d" % i for i in range(len(user))))
        results, queue, seen, truncated = [base], deque([base]), {base_sequence.identity}, False
        while queue and len(results) < self.config.candidate_budget:
            parent = queue.popleft()
            if parent.depth >= self.config.max_depth:
                continue
            for name, operation in ((PARAMETER, lambda: parameter_mutation(parent, context)),
                                    (INSERTION, lambda: state_aware_insertion(parent, context, observation.economic_states)),
                                    (REVERSAL, lambda: flow_reversal(parent, context))):
                children = operation()
                event = {"operator": name, "parent": parent.candidate_id, "generated": len(children), "admitted": 0}
                self.events.append(event)
                for child in sorted(children, key=lambda c: c.sequence.identity):
                    if len(child.sequence) > self.config.max_length or child.sequence.identity in seen:
                        continue
                    if len(results) >= self.config.candidate_budget:
                        truncated = True
                        break
                    child = replace(child, candidate_id="attacker-%04d" % len(results))
                    results.append(child)
                    queue.append(child)
                    seen.add(child.sequence.identity)
                    event["admitted"] += 1
                if truncated:
                    break
            if truncated:
                break
        return tuple(results), truncated or bool(queue)
