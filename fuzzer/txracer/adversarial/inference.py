import hashlib
import random

from fuzzer.txracer.compat import legacy_keyword_aliases
from fuzzer.txracer.adversarial.model import (
    OPERATOR_FLOW_REVERSAL,
    OPERATOR_PARAMETER_MUTATION,
    OPERATOR_STATE_AWARE_INSERTION,
    AttackerCandidate,
    transaction_content_hash,
)

DEFAULT_KA = 8
DEFAULT_MAX_DEPTH = 2

AMOUNT_PARAM_NAMES = ("amount", "amountin", "amountout", "amounts",
                      "amountmin", "amountmax", "quantity", "value")

UNSUPPORTED_FLOW_REVERSAL = "UNSUPPORTED_FLOW_REVERSAL"


class AttackerInferenceError(Exception):
    pass


class InferenceContext(object):


    def __init__(self, planner_candidates=None, function_rw=None,
                 amount_param_evidence=None,
                 recipient_param_evidence=None, confirmed_flows=None,
                 known_flow_reversals=None, attacker_balance=0,
                 selector_abi=None, rng=None, deployed_contracts=None,
                 argument_builder=None, gas_limit=2000000000):
        self.planner_candidates = list(planner_candidates or [])

        self.function_rw = dict(function_rw or {})

        self.amount_param_evidence = dict(amount_param_evidence or {})

        self.recipient_param_evidence = dict(
            recipient_param_evidence or {})


        self.confirmed_flows = list(confirmed_flows or [])

        self.known_flow_reversals = dict(known_flow_reversals or {})
        self.attacker_balance = int(attacker_balance)

        self.selector_abi = dict(selector_abi or {})
        self.rng = rng if rng is not None else random.Random(1)

        self.deployed_contracts = dict(deployed_contracts or {})

        self.argument_builder = argument_builder
        self.gas_limit = int(gas_limit)




class AttackerInferenceConfig(object):
    def __init__(self, ka=DEFAULT_KA, max_depth=DEFAULT_MAX_DEPTH,
                 seed=1):
        self.ka = int(ka)
        self.max_depth = int(max_depth)
        self.seed = int(seed)

    def to_dict(self):
        return {
            "ka": self.ka,
            "max_depth": self.max_depth,
            "seed": self.seed,
        }


def _tx_data(transactions, index):
    return (transactions[index].get("transaction") or {}).get("data", "")


def _selector_of(data):
    hex_data = data
    if hex_data.startswith("0x"):
        hex_data = hex_data[2:]
    return hex_data[:8].lower()


def _decode_arguments(arg_types, data):
    from eth_abi import decode_abi
    hex_data = data
    if hex_data.startswith("0x"):
        hex_data = hex_data[2:]
    raw = bytes.fromhex(hex_data[8:])
    return list(decode_abi(arg_types, raw))


def _encode_arguments(selector, arg_types, args):
    from eth_abi import encode_abi
    return selector + encode_abi(arg_types, args).hex()


def _amount_bounds(arg_type):

    text = arg_type.lower()
    if text.startswith("uint"):
        bits = int(text[4:]) if len(text) > 4 else 256
        return (0, (1 << bits) - 1)
    if text.startswith("int"):
        bits = int(text[3:]) if len(text) > 3 else 256
        return (-(1 << (bits - 1)), (1 << (bits - 1)) - 1)
    return None


def _arg_type(selector, index, ctx):
    entry = ctx.selector_abi.get(selector)
    if not entry or len(entry) < 2 or index >= len(entry[1]):
        return None
    return entry[1][index]


def _argument_value(transactions, index, arg_index):
    data = _tx_data(transactions, index)
    selector = _selector_of(data)
    return None, None, selector, data


def _resolve_args(transactions, index, ctx):

    data = _tx_data(transactions, index)
    selector = _selector_of(data)
    entry = _entry(selector, ctx)
    if not entry:
        return None, None, None
    arg_types = list(entry["arg_types"])
    try:
        args = _decode_arguments(arg_types, data)
    except Exception:  # noqa: BLE001 - undecodable, skip mutation
        return None, None, None
    return selector, arg_types, args


def parameter_mutation(parent, ctx):

    children = []
    for tx_index, tx in enumerate(parent.transactions):
        selector, arg_types, args = _resolve_args(
            parent.transactions, tx_index, ctx)
        if selector is None:
            continue
        mutations = []
        amount_indices = ctx.amount_param_evidence.get(
            _signature_for(selector, ctx), [])
        for arg_index in amount_indices:
            if arg_index >= len(args):
                continue
            arg_type = _arg_type(selector, arg_index, ctx)
            bounds = _amount_bounds(arg_type)
            if bounds is None:
                continue
            original = args[arg_index]
            if isinstance(original, bool):
                continue
            candidates = [0, 1, original - 1, original + 1,
                          original // 2, original * 2]
            lower, upper = bounds
            for candidate in candidates:
                if candidate < lower or candidate > upper:
                    continue
                if candidate == original:
                    continue
                mutations.append(
                    ("amount", arg_index, candidate, arg_type))
        recipient_index = ctx.recipient_param_evidence.get(
            _signature_for(selector, ctx))
        if recipient_index is not None and recipient_index < len(args):
            arg_type = _arg_type(selector, recipient_index, ctx)
            if arg_type == "address":
                original_recipient = args[recipient_index]
                for candidate in (_attacker_address(parent, ctx),
                                  _user_address(parent, ctx),
                                  original_recipient):
                    if candidate == original_recipient:
                        continue
                    if not isinstance(candidate, str):
                        continue
                    mutations.append(
                        ("recipient", recipient_index, candidate,
                         arg_type))
        value = int(tx.get("transaction", {}).get("value", 0) or 0)


        if _is_payable_selector(selector, ctx):
            value_candidates = [0, value, value // 2, value * 2]
            for candidate in value_candidates:
                if candidate > ctx.attacker_balance:
                    continue
                if candidate == value:
                    continue
                mutations.append(("value", None, candidate, None))
        for mutation in mutations:
            kind, arg_index, new_value, arg_type = mutation
            new_txs = _deep_copy(parent.transactions)
            new_tx = new_txs[tx_index]
            if kind == "value":
                new_tx["transaction"]["value"] = int(new_value)
            else:
                new_args = list(args)
                new_args[arg_index] = new_value
                try:
                    new_data = _encode_arguments(selector, arg_types,
                                                 new_args)
                except Exception:  # noqa: BLE001
                    continue
                new_tx["transaction"]["data"] = new_data
            children.append(AttackerCandidate(
                candidate_id="",
                parent_candidate_id=parent.candidate_id,
                user_sequence_id=parent.user_sequence_id,
                operator_chain=(parent.operator_chain
                                + [OPERATOR_PARAMETER_MUTATION]),
                transactions=new_txs,
                transaction_ids=list(parent.transaction_ids),
                depth=parent.depth + 1,
                diagnostics=["parameter_mutation:%s:%s" % (kind,
                                                           arg_index)
                             if arg_index is not None
                             else "parameter_mutation:value"],
            ))
    return children


def _entry(selector, ctx):

    raw = ctx.selector_abi.get(selector)
    if raw is None:
        return None
    if isinstance(raw, dict):
        return raw
    if isinstance(raw, (list, tuple)) and len(raw) >= 2:
        payable = bool(raw[2]) if len(raw) > 2 else False
        return {
            "signature": raw[0],
            "arg_types": list(raw[1]),
            "names": [],
            "payable": payable,
        }
    return None


def _signature_for(selector, ctx):
    entry = _entry(selector, ctx)
    if entry:
        return entry["signature"]
    return selector


def _is_payable_selector(selector, ctx):
    entry = _entry(selector, ctx)
    return bool(entry and entry.get("payable"))


def _arg_type(selector, index, ctx):
    entry = _entry(selector, ctx)
    if not entry or index >= len(entry["arg_types"]):
        return None
    return entry["arg_types"][index]


def _attacker_address(parent, ctx):
    for tx in parent.transactions:
        sender = (tx.get("transaction") or {}).get("from")
        if sender:
            return sender
    return None


def _user_address(parent, ctx):
    return getattr(parent, "_user_address",
                   getattr(parent, "_victim_address", None))


def state_aware_insertion(parent, ctx, economic_states):

    children = []
    for tx_index, tx in enumerate(parent.transactions):
        data = _tx_data(parent.transactions, tx_index)
        selector = _selector_of(data)
        for candidate in ctx.planner_candidates:
            signature = candidate.get("signature")
            rw = ctx.function_rw.get(signature)
            if not rw:
                continue
            writes = {tuple(k) for k in rw.get("writes", [])}
            reads = {tuple(k) for k in rw.get("reads", [])}
            user_writes = {tuple(k) for k in
                              _user_tx_writes(parent, tx_index, ctx)}
            user_reads = {tuple(k) for k in
                            _user_tx_reads(parent, tx_index, ctx)}
            sigma_e = {tuple(k) for k in economic_states or []}
            before_intersection = sorted(
                writes & user_reads & sigma_e)
            after_intersection = sorted(
                reads & user_writes & sigma_e)
            if not before_intersection and not after_intersection:
                continue
            if before_intersection:
                new_txs = _deep_copy(parent.transactions)
                inserted = _build_inserted_tx(candidate, ctx, parent)
                if inserted is None:
                    parent.diagnostics.append(
                        "insertion_arg_construction_failed:%s"
                        % signature)
                    continue
                new_txs.insert(tx_index, inserted)
                new_ids = _ids_with_insertion(parent, tx_index, "ins")
                children.append(AttackerCandidate(
                    candidate_id="",
                    parent_candidate_id=parent.candidate_id,
                    user_sequence_id=parent.user_sequence_id,
                    operator_chain=(parent.operator_chain
                                    + [OPERATOR_STATE_AWARE_INSERTION]),
                    transactions=new_txs,
                    transaction_ids=new_ids,
                    depth=parent.depth + 1,
                    diagnostics=["insertion_before:%s@%d" % (
                        signature, tx_index)],
                    economic_state_intersections=[
                        list(k) for k in before_intersection],
                ))
            if after_intersection:
                new_txs = _deep_copy(parent.transactions)
                inserted = _build_inserted_tx(candidate, ctx, parent)
                if inserted is None:
                    parent.diagnostics.append(
                        "insertion_arg_construction_failed:%s"
                        % signature)
                    continue
                new_txs.insert(tx_index + 1, inserted)
                new_ids = _ids_with_insertion(parent, tx_index + 1,
                                              "ins")
                children.append(AttackerCandidate(
                    candidate_id="",
                    parent_candidate_id=parent.candidate_id,
                    user_sequence_id=parent.user_sequence_id,
                    operator_chain=(parent.operator_chain
                                    + [OPERATOR_STATE_AWARE_INSERTION]),
                    transactions=new_txs,
                    transaction_ids=new_ids,
                    depth=parent.depth + 1,
                    diagnostics=["insertion_after:%s@%d" % (
                        signature, tx_index)],
                    economic_state_intersections=[
                        list(k) for k in after_intersection],
                ))
    return children


def _ids_with_insertion(parent, insert_index, prefix):

    from fuzzer.txracer.adversarial.context import new_sidecar_id
    existing = set(parent.transaction_ids)
    counter = max(
        [int(part) for part in (tx_id.split("-")[-1]
                                for tx_id in parent.transaction_ids)
         if part.isdigit()] or [0]) + 1
    new_id, _ = new_sidecar_id(prefix, existing, counter)
    new_ids = list(parent.transaction_ids)
    new_ids.insert(insert_index, new_id)
    return new_ids


def _build_inserted_tx(candidate, ctx, parent):

    signature = candidate.get("signature")
    selector = candidate.get("selector")
    entry = _entry(selector, ctx)
    if not entry:
        return None
    arg_types = list(entry["arg_types"])
    builder = getattr(ctx, "argument_builder", None)
    if builder is None:

        return None
    try:
        args = builder(signature, arg_types)
    except Exception:  # noqa: BLE001
        return None
    if args is None:
        return None
    try:
        data = _encode_arguments(selector, arg_types, args)
    except Exception:  # noqa: BLE001
        return None
    sender = _attacker_address(parent, ctx)
    contract = candidate.get("contract")
    deployed = getattr(ctx, "deployed_contracts", None) or {}
    to_address = deployed.get(contract) if contract else None
    if to_address is None and contract:
        return None
    if to_address is None:
        to_address = candidate.get("target")
    return {
        "transaction": {
            "from": sender,
            "to": to_address,
            "value": 0,
            "data": data,
            "gaslimit": getattr(ctx, "gas_limit", 2000000000),
        },
        "block": {}, "global_state": {}, "environment": {},
    }


def _user_tx_writes(parent, tx_index, ctx):
    signature = _signature_for(_selector_of(
        _tx_data(parent.transactions, tx_index)), ctx)
    rw = ctx.function_rw.get(signature)
    return [tuple(k) for k in (rw.get("writes", []) if rw else [])]


def _user_tx_reads(parent, tx_index, ctx):
    signature = _signature_for(_selector_of(
        _tx_data(parent.transactions, tx_index)), ctx)
    rw = ctx.function_rw.get(signature)
    return [tuple(k) for k in (rw.get("reads", []) if rw else [])]


def flow_reversal(parent, ctx):

    children = []
    for flow_a in ctx.confirmed_flows:
        for flow_b in ctx.confirmed_flows:
            if flow_b is flow_a:
                continue
            if flow_a.get("tx_id") != flow_b.get("tx_id"):
                continue
            asset_a = tuple(flow_a.get("asset_id") or ())
            asset_b = tuple(flow_b.get("asset_id") or ())
            if not asset_a or not asset_b or asset_a == asset_b:
                continue


            caller = flow_a.get("caller")
            if caller is None:
                caller = flow_a.get("sender")
            if caller is None:
                continue


            if flow_a.get("recipient") == caller:
                continue
            if flow_b.get("recipient") != caller:
                continue
            if flow_b.get("sender") == caller:
                continue


            source = ctx.known_flow_reversals.get(
                (asset_b, asset_a))
            if source is None:
                parent.diagnostics.append(
                    "%s:%s->%s" % (UNSUPPORTED_FLOW_REVERSAL,
                                   _asset_label(asset_a),
                                   _asset_label(asset_b)))
                continue


            if source.get("swap_params") is not None:
                parent.diagnostics.append(
                    "%s:%s->%s" % (UNSUPPORTED_FLOW_REVERSAL,
                                   _asset_label(asset_a),
                                   _asset_label(asset_b)))
                continue
            signature = source.get("signature")
            if not signature:
                continue
            candidate = next(
                (c for c in ctx.planner_candidates
                 if c.get("signature") == signature), None)
            if candidate is None:
                continue
            new_txs = _deep_copy(parent.transactions)
            inserted = _build_inserted_tx(candidate, ctx, parent)
            if inserted is None:
                parent.diagnostics.append(
                    "flow_reversal_arg_construction_failed:%s"
                    % signature)
                continue
            new_txs.append(inserted)
            from fuzzer.txracer.adversarial.context import new_sidecar_id
            existing = set(parent.transaction_ids)
            counter = max(
                [int(part) for part in (tx_id.split("-")[-1]
                                        for tx_id in parent.transaction_ids)
                 if part.isdigit()] or [0]) + 1
            new_id, _ = new_sidecar_id("rev", existing, counter)
            children.append(AttackerCandidate(
                candidate_id="",
                parent_candidate_id=parent.candidate_id,
                user_sequence_id=parent.user_sequence_id,
                operator_chain=(parent.operator_chain
                                + [OPERATOR_FLOW_REVERSAL]),
                transactions=new_txs,
                transaction_ids=list(parent.transaction_ids) + [new_id],
                depth=parent.depth + 1,
                diagnostics=["flow_reversal:%s->%s:%s" % (
                    _asset_label(asset_a), _asset_label(asset_b),
                    source.get("kind", "unknown"))],
            ))
    return children


def _asset_label(asset_id):
    return "-".join(str(part) for part in asset_id)


@legacy_keyword_aliases(victim_txs='user_txs', victim_sequence_id='user_sequence_id')
def derive_attacker_candidates(user_txs, attacker_address,
                               user_sequence_id, config, ctx,
                               economic_states=None):

    base_transactions = _deep_copy(user_txs)
    for tx in base_transactions:
        tx["transaction"]["from"] = attacker_address
    base = AttackerCandidate(
        candidate_id="attacker-0000",
        parent_candidate_id="",
        user_sequence_id=user_sequence_id,
        operator_chain=[],
        transactions=base_transactions,
        depth=0,
    )
    base._user_address = _first_sender(user_txs)
    base._victim_address = base._user_address
    results = [base]
    queue = [base]
    seen = {base.content_hash}
    operators = [
        lambda parent: parameter_mutation(parent, ctx),
        lambda parent: state_aware_insertion(
            parent, ctx, economic_states or []),
        lambda parent: flow_reversal(parent, ctx),
    ]
    truncated = False
    while queue and len(results) < config.ka:
        parent = queue.pop(0)
        if parent.depth >= config.max_depth:
            continue
        for operator in operators:
            children = operator(parent)
            children = sorted(children, key=lambda c: c.content_hash)
            for child in children:
                child.candidate_id = "attacker-%04d" % len(results)
                child._user_address = parent._user_address
                child._victim_address = child._user_address
                if child.content_hash in seen:
                    continue
                if len(results) >= config.ka:

                    truncated = True
                    break
                seen.add(child.content_hash)
                results.append(child)
                queue.append(child)
            if truncated:
                break
        if truncated:
            break
    if queue:

        truncated = True
    return results, truncated


def _first_sender(transactions):
    for tx in transactions:
        sender = (tx.get("transaction") or {}).get("from")
        if sender:
            return sender
    return None


def _deep_copy(transactions):
    from copy import deepcopy
    return deepcopy(transactions)


def candidate_chain(candidate):

    return list(candidate.operator_chain)




__all__ = [
    'DEFAULT_KA',
    'DEFAULT_MAX_DEPTH',
    'UNSUPPORTED_FLOW_REVERSAL',
    'AttackerInferenceConfig',
    'AttackerInferenceError',
    'InferenceContext',
    'candidate_chain',
    'derive_attacker_candidates',
    'flow_reversal',
    'parameter_mutation',
    'state_aware_insertion',
]
