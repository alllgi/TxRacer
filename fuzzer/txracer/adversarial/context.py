from eth_utils import function_signature_to_4byte_selector

import os

from fuzzer.txracer.compat import legacy_keyword_aliases
from fuzzer.txracer.interleaving.interaction import (
    InteractionValidationError,
)
from fuzzer.txracer.adversarial.inference import InferenceContext

SIDE_EFFECT_FREE_CONTRACTS = ("0x00000000000000000000000000000000000000",)


def canonical_address(address):
    return str(address).lower()


@legacy_keyword_aliases(victim_addr='user_addr', expected_victim_ids='expected_user_ids')
def executed_order(records, user_addr, attacker_addr,
                   expected_user_ids, expected_attacker_ids):

    user = canonical_address(user_addr)
    attacker = canonical_address(attacker_addr)
    expected_user = [str(tx_id) for tx_id in expected_user_ids]
    expected_attacker = [str(tx_id) for tx_id in expected_attacker_ids]
    if not isinstance(records, (list, tuple)):
        raise InteractionValidationError(
            "executed records must be a list of TxExecutionRecord")
    actual_user_ids = []
    actual_attacker_ids = []
    order = []
    for index, record in enumerate(records):
        sender = getattr(record, "sender", None)
        tx_id = getattr(record, "tx_id", None)
        if sender is None:
            raise InteractionValidationError(
                "executed record %d has no sender" % index)
        if tx_id is None:
            raise InteractionValidationError(
                "executed record %d has no stable tx id" % index)
        sender_key = canonical_address(sender)
        if sender_key == user:
            label = "v"
            actual_user_ids.append(str(tx_id))
        elif sender_key == attacker:
            label = "a"
            actual_attacker_ids.append(str(tx_id))
        else:
            raise InteractionValidationError(
                "executed record %d has unknown sender %r (expected "
                "user %s or attacker %s)"
                % (index, sender, user, attacker))
        order.append((label, str(tx_id)))
    if sorted(actual_user_ids) != sorted(expected_user):
        raise InteractionValidationError(
            "executed user ids %r do not match the expected ids %r"
            % (sorted(actual_user_ids), sorted(expected_user)))
    if sorted(actual_attacker_ids) != sorted(expected_attacker):
        raise InteractionValidationError(
            "executed attacker ids %r do not match the expected ids %r"
            % (sorted(actual_attacker_ids), sorted(expected_attacker)))
    if len(set(actual_user_ids)) != len(actual_user_ids):
        raise InteractionValidationError(
            "duplicate user stable tx id in the executed order")
    if len(set(actual_attacker_ids)) != len(actual_attacker_ids):
        raise InteractionValidationError(
            "duplicate attacker stable tx id in the executed order")
    return order


def build_selector_map(abi):

    selector_map = {}
    for entry in abi or []:
        if entry.get("type") != "function":
            continue
        name = entry.get("name", "")
        inputs = entry.get("inputs") or []
        arg_types = [i.get("type") for i in inputs]
        names = [i.get("name", "") for i in inputs]
        signature = name + "(" + ",".join(arg_types) + ")"
        selector = function_signature_to_4byte_selector(signature).hex()
        mutability = entry.get("stateMutability")
        payable = (mutability == "payable"
                   or bool(entry.get("payable")))
        selector_map[selector] = {
            "signature": signature,
            "arg_types": arg_types,
            "names": names,
            "payable": payable,
        }
    return selector_map


def function_rw_from_observations(observations, selector_map=None):

    function_rw = {}
    for observation in observations or []:
        for record in getattr(observation, "records", None) or []:
            func_hash = getattr(record, "func_hash", None)
            if not func_hash:
                continue
            signature = None
            if selector_map is not None:
                entry = selector_map.get(str(func_hash).lower())
                if entry:
                    signature = entry["signature"]
            if signature is None:
                signature = str(func_hash)
            rw = function_rw.setdefault(
                signature, {"reads": set(), "writes": set()})
            rw["reads"] |= set(getattr(record, "reads", None) or [])
            rw["writes"] |= set(getattr(record, "writes", None) or [])
    return function_rw


def confirmed_flows_from(flows):

    confirmed = []
    for flow in flows or []:
        explicit = getattr(flow, "confirmed", None)
        if explicit is not None:
            if not explicit:
                continue
        elif getattr(flow, "attempted", False):

            continue
        if getattr(flow, "ambiguous", False):
            continue
        confirmed.append({
            "sender": getattr(flow, "sender", None),
            "recipient": getattr(flow, "recipient", None),
            "asset_id": getattr(flow, "asset_id", None),
            "amount": getattr(flow, "amount", 0),
            "tx_id": getattr(flow, "tx_id", None),
        })
    return confirmed


def _signature_for_tx(observations, tx_id, selector_map):
    for observation in observations or []:
        for record in getattr(observation, "records", None) or []:
            if getattr(record, "tx_id", None) != tx_id:
                continue
            func_hash = getattr(record, "func_hash", None)
            if not func_hash:
                return None
            if selector_map is not None:
                entry = selector_map.get(str(func_hash).lower())
                if entry:
                    return entry["signature"]
            return str(func_hash)
    return None


def known_flow_reversals_from(flows, observations=None, selector_map=None):

    reversals = {}
    by_tx = {}
    for flow in flows or []:
        tx_id = flow.get("tx_id")
        if not tx_id:
            continue
        by_tx.setdefault(tx_id, []).append(flow)
    for tx_id, tx_flows in by_tx.items():
        signature, tx_sender, _entry = _signature_and_sender_for_tx(
            observations, tx_id, selector_map)
        if not signature:
            continue


        caller = tx_sender
        if caller is None:
            continue
        for out_flow in tx_flows:
            if out_flow.get("sender") != caller:
                continue
            if out_flow.get("recipient") == caller:
                continue
            for in_flow in tx_flows:
                if in_flow is out_flow:
                    continue
                if not out_flow.get("asset_id") or not in_flow.get(
                        "asset_id"):
                    continue
                asset_a = tuple(out_flow["asset_id"])
                asset_b = tuple(in_flow["asset_id"])
                if asset_a == asset_b:
                    continue
                if in_flow.get("recipient") != caller:
                    continue
                if in_flow.get("sender") == caller:
                    continue
                reversals[(asset_a, asset_b)] = {
                    "signature": signature,
                    "swap_params": None,
                    "kind": "corpus_confirmed",
                }
    return reversals


def _signature_and_sender_for_tx(observations, tx_id, selector_map):
    for observation in observations or []:
        for record in getattr(observation, "records", None) or []:
            if getattr(record, "tx_id", None) != tx_id:
                continue
            func_hash = getattr(record, "func_hash", None)
            sender = getattr(record, "sender", None)
            if not func_hash:
                return None, sender, None
            if selector_map is not None:
                entry = selector_map.get(str(func_hash).lower())
                if entry:
                    return entry["signature"], sender, entry
            return str(func_hash), sender, None
    return None, None, None


def new_sidecar_id(prefix, existing_ids, counter):

    candidate = "%s-%d" % (prefix, counter)
    while candidate in existing_ids:
        counter += 1
        candidate = "%s-%d" % (prefix, counter)
    return candidate, counter


__all__ = [
    "build_selector_map",
    "canonical_address",
    "confirmed_flows_from",
    "executed_order",
    "function_rw_from_observations",
    "known_flow_reversals_from",
    "new_sidecar_id",
]


@legacy_keyword_aliases(victim_addr='user_addr', victim_txs='user_txs')
def build_inference_context(env, pipeline, user_addr, attacker_addr,
                            user_txs):

    from fuzzer.utils import settings as _settings

    generator = getattr(env, "generator", None)
    abi = getattr(generator, "abi", None) or []
    selector_map = build_selector_map(abi)
    observations = []
    if pipeline is not None:
        observations = list(getattr(pipeline, "_seed_observations", []))
    function_rw = function_rw_from_observations(observations,
                                                selector_map)
    amount_param_evidence = {}
    for selector, entry in selector_map.items():
        for index, name in enumerate(entry["names"]):
            lowered = name.lower()
            if any(token in lowered for token in
                   ("amount", "quantity", "value")) or                     lowered in ("amountin", "amountout"):
                amount_param_evidence.setdefault(
                    entry["signature"], []).append(index)
    flows = []
    for observation in observations:
        flows.extend(getattr(observation, "flows", None) or [])
    confirmed_flows = _annotate_flow_callers(
        confirmed_flows_from(flows), observations)
    recipient_param_evidence = _recipient_evidence(
        confirmed_flows, observations, selector_map,
        user_addr, attacker_addr)
    known_flow_reversals = known_flow_reversals_from(
        confirmed_flows, observations, selector_map)
    attacker_balance = 0
    try:
        from eth_utils import to_canonical_address
        attacker_balance = env.instrumented_evm.vm.state.get_balance(
            to_canonical_address(attacker_addr))
    except Exception:  # noqa: BLE001
        attacker_balance = 0
    deployed_contracts = dict(getattr(_settings,
                                      "DEPLOYED_CONTRACT_ADDRESS", {}))
    selector_abi = {
        selector: {
            "signature": entry["signature"],
            "arg_types": list(entry["arg_types"]),
            "names": list(entry["names"]),
            "payable": entry["payable"],
        }
        for selector, entry in selector_map.items()
    }
    ctx = InferenceContext(
        planner_candidates=_planner_candidates(env, selector_map),
        function_rw=function_rw,
        amount_param_evidence=amount_param_evidence,
        recipient_param_evidence=recipient_param_evidence,
        confirmed_flows=confirmed_flows,
        known_flow_reversals=known_flow_reversals,
        attacker_balance=attacker_balance,
        selector_abi=selector_abi,
        deployed_contracts=deployed_contracts,
        argument_builder=_argument_builder(env),
    )
    return ctx, selector_map


def _recipient_evidence(confirmed_flows, observations, selector_map,
                        user_addr, attacker_addr):

    return {}


def _planner_candidates(env, selector_map):
    candidates = []
    template_path = getattr(
        getattr(env, "args", None), "sequence_template", None)
    if template_path and os.path.exists(template_path):
        import json as _json
        try:
            with open(template_path, "r", encoding="utf-8") as fh:
                template = _json.load(fh)
            entries = []
            if isinstance(template, dict):
                entries = template.get("candidate_functions", [])
            elif isinstance(template, list):
                entries = template
            for entry in entries:
                if not isinstance(entry, dict):
                    continue
                signature = entry.get("signature")
                if not signature:
                    continue
                selector = entry.get("selector")
                if not selector and signature in {
                        e["signature"]: s for s, e in selector_map.items()}:
                    selector = next(
                        (s for s, e in selector_map.items()
                         if e["signature"] == signature), None)
                if selector:
                    candidates.append({
                        "contract": entry.get("contract"),
                        "signature": signature,
                        "selector": selector,
                    })
        except (OSError, ValueError):
            candidates = []
    return candidates


def _argument_builder(env):
    generator = getattr(env, "generator", None)

    def build(signature, arg_types):
        if generator is None:
            return None
        interface_mapper = getattr(generator, "interface_mapper", None)             or {}
        selector = interface_mapper.get(signature)
        if selector is None:
            return None
        try:
            args = []
            for index, arg_type in enumerate(arg_types):
                args.append(generator.get_random_argument(
                    arg_type, selector, index))
            return args
        except Exception:  # noqa: BLE001
            return None
    return build


def _annotate_flow_callers(flows, observations):

    sender_by_tx = {}
    for observation in observations or []:
        for record in getattr(observation, "records", None) or []:
            tx_id = getattr(record, "tx_id", None)
            if tx_id is None:
                continue
            sender_by_tx.setdefault(
                tx_id, getattr(record, "sender", None))
    annotated = []
    for flow in flows or []:
        entry = dict(flow)
        entry["caller"] = sender_by_tx.get(entry.get("tx_id"))
        annotated.append(entry)
    return annotated
