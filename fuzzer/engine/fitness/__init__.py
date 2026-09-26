import os
import binascii
from pprint import pprint, pformat
from datetime import datetime
from copy import deepcopy
import random
import json
import traceback
from eth_utils import to_canonical_address, to_bytes, function_signature_to_4byte_selector, decode_hex, ValidationError
from fuzzer.utils import settings
from eth_abi import encode_abi, decode_abi
from web3 import Web3
from eth.vm.spoof import SpoofTransaction
import sys
from fuzzer.utils.utils import convert_stack_value_to_int
from collections import defaultdict
from fuzzer.txracer.execution import rw_trace
from fuzzer.txracer.execution.rw_trace import (
    TxExecutionInternalError,
    build_tx_calldata,
    get_revert_reason,
)
from fuzzer.txracer.reporting import (
    StopOnFirstFinding,
    build_finding_record,
    maybe_stop_on_finding,
)
ASSET_VALUES = {
    "ETH": {"_DEFAULT_": 1},
    "ERC165": {
         "_DEFAULT_": 55,
    },
    "ERC20": {
        "_DEFAULT_": 666,

    },
    "ERC721": {
        "_DEFAULT_": 7777,

    }
}

def get_revert_reason(result):

    return rw_trace.get_revert_reason(result)

def get_storage_value(evm, address, slot):
    return evm.vm.state.get_storage(to_canonical_address(address), slot)

def _get_user_state(env, user_address_str, contracts_to_check):

    state = {'assets': {}, '_diagnostics': []}
    try:
        state['assets']['ETH'] = env.instrumented_evm.get_balance(to_canonical_address(user_address_str))
    except Exception as read_error:
        state['assets']['ETH'] = 0
        diagnostic = "ETH balance read failed for %s: %s" % (user_address_str, read_error)
        state['_diagnostics'].append(diagnostic)
        print("[!] %s" % diagnostic)

    for contract_address, contract_type in contracts_to_check.items():
        try:
            balance_of_data = "0x70a08231" + encode_abi(['address'], [user_address_str]).hex()

            output = env.instrumented_evm.safe_read_call(user_address_str, contract_address, balance_of_data)

            if output and int.from_bytes(output, 'big') > 0:
                balance = int.from_bytes(output, 'big')
                state['assets'][f"{contract_type}@{contract_address}"] = balance
        except Exception as read_error:
            diagnostic = "balanceOf read failed for %s@%s of %s: %s" % (
                contract_type, contract_address, user_address_str, read_error)
            state['_diagnostics'].append(diagnostic)
            print("[!] %s" % diagnostic)
    return state

def calculate_total_value(state):
    total_value = 0
    for asset_key, balance in state['assets'].items():
        try:
            value_per_unit_eth = 0

            if asset_key == 'ETH':
                value_per_unit_eth = ASSET_VALUES['ETH']['_DEFAULT_']
            else:
                asset_type, asset_address = asset_key.split('@')


                if asset_type in ASSET_VALUES:


                    value_per_unit_eth = ASSET_VALUES[asset_type].get(
                        asset_address,
                        ASSET_VALUES[asset_type]['_DEFAULT_']
                    )


            total_value += balance * Web3.toWei(value_per_unit_eth, 'ether')
        except (KeyError, ValueError) as e:
            print(f"!! WARNING: Could not calculate value for asset '{asset_key}': {e}")
            continue

    return total_value
def _legacy_valuation_score(initial_state_alice, initial_state_bob, state_A_alice, state_A_bob, state_B_alice, state_B_bob):

    initial_value_alice = calculate_total_value(initial_state_alice)
    initial_value_bob = calculate_total_value(initial_state_bob)
    final_value_A_alice = calculate_total_value(state_A_alice)
    final_value_A_bob = calculate_total_value(state_A_bob)
    final_value_B_alice = calculate_total_value(state_B_alice)
    final_value_B_bob = calculate_total_value(state_B_bob)

    profit_A_alice = final_value_A_alice - initial_value_alice
    profit_A_bob = final_value_A_bob - initial_value_bob
    profit_B_alice = final_value_B_alice - initial_value_alice
    profit_B_bob = final_value_B_bob - initial_value_bob


    return (profit_A_alice - profit_B_alice) * (profit_B_bob > 0)


def _compare_scenarios(initial_state_alice, initial_state_bob, state_A_alice, state_A_bob, state_B_alice, state_B_bob, use_fixed_valuation=False):

    value_based_score = 0
    if use_fixed_valuation:
        value_based_score = _legacy_valuation_score(
            initial_state_alice, initial_state_bob,
            state_A_alice, state_A_bob, state_B_alice, state_B_bob,
        )


    intent_based_score = 0

    initial_assets_alice = set(k for k in initial_state_alice['assets'].keys())
    final_assets_A_alice = set(k for k in state_A_alice['assets'].keys())
    target_assets = final_assets_A_alice - initial_assets_alice

    if target_assets:
        print(f"DEBUG: Alice's target assets identified from Scenario A: {target_assets}")
        print(f"DEBUG: Bob's target assets identified from Scenario B: {set(state_B_bob['assets']) - set(initial_state_bob['assets'])}")

    if target_assets:
        final_assets_B_alice = set(k for k in state_B_alice['assets'].keys() if k != 'ETH')
        final_assets_B_bob = set(k for k in state_B_bob['assets'].keys() if k != 'ETH')
        initial_assets_bob = set(k for k in initial_state_bob['assets'].keys() if k != 'ETH')

        assets_bob = final_assets_B_alice - initial_assets_bob


        for asset in state_A_alice['assets'].keys():

            if asset == 'ETH':
                 continue


            if state_B_alice['assets'].get(asset) != state_B_bob['assets'].get(asset):
                intent_based_score = 2**21
                print(f"!!! INTENT VIOLATION DETECTED1: Alice lost target asset '{asset}' which was gained by Bob. !!!")
                print(f"Alice:{initial_state_alice['assets']} Bob:{initial_state_bob['assets']}\nALice:{state_B_alice['assets']} Bob:{state_B_bob['assets']}")

            asset_lost_by_alice_in_B = asset not in final_assets_B_alice
            asset_gained_by_bob_in_B = asset in final_assets_B_bob and asset not in initial_assets_bob

            if asset_lost_by_alice_in_B and asset_gained_by_bob_in_B or target_assets != final_assets_B_alice:
                print(f"!!! INTENT VIOLATION DETECTED2: Alice lost target asset '{asset}' which was gained by Bob. !!!")
                intent_based_score = 9**21
                break


    return max(value_based_score, intent_based_score)

def _gene_argument(gene, index, default=None):

    if gene is None or not isinstance(gene, dict):
        return default
    arguments = gene.get("arguments")
    if not isinstance(arguments, (list, tuple)) or len(arguments) <= index:
        return default
    return arguments[index]


def _tx_func_hash(gene, tx_data):

    func_hash = _gene_argument(gene, 0)
    if func_hash is not None:
        return func_hash
    if isinstance(tx_data, dict):
        data = tx_data.get("data")
        if isinstance(data, str):
            return data[:10] if data.startswith("0x") else data[:8]
    return None


def _run_and_record_rw_sets(env, solution, user_addr_str):

    print(f"[*] Scout Run: Recording R/W sets for {user_addr_str}...")
    rw_sets = []


    user_solution = deepcopy(solution)
    for tx_input in user_solution:
        tx_input['transaction']['from'] = user_addr_str


    env.instrumented_evm.restore_from_snapshot()


    for i, tx_input in enumerate(user_solution):
        try:
            record = rw_trace.execute_transaction_with_rw_trace(
                env.instrumented_evm,
                tx_input,
                tx_id=f"scout-{i}",
                func_hash=None,
            )
        except TxExecutionInternalError as internal_error:
            print(f"!! FATAL (internal) error during scout run tx #{i}: {internal_error}")
            return None, None
        rw_sets.append({
            "reads": record.reads,
            "writes": record.writes,
            "func_hash": record.func_hash,
            "tx_id": record.tx_id,
            "status": record.status,
            "reason": record.reason,
            "notes": sorted(record.notes),
        })

    print(f"[*] Finished recording. Found R/W sets: {rw_sets}")
    return rw_sets, user_solution

def _find_preemption_pairs(alice_rw_sets, bob_rw_sets):

    return rw_trace.find_preemption_pairs(alice_rw_sets, bob_rw_sets)

def _scout_rw_sets(env, final_paired_sequence, sender_addr_str, user_label):

    env.instrumented_evm.restore_from_snapshot()
    env.data_dependencies.clear()
    rw_sets = []
    for i, (gene, execution_input) in enumerate(final_paired_sequence):
        tx_input = deepcopy(execution_input)
        tx_input['transaction']['from'] = sender_addr_str


        func_hash = _gene_argument(gene, 0)

        try:
            record = rw_trace.execute_transaction_with_rw_trace(
                env.instrumented_evm,
                tx_input,
                tx_id="%s-%d" % (user_label, i),
                func_hash=func_hash,
            )
        except TxExecutionInternalError as internal_error:
            print(f"!! FATAL (internal) error during {user_label} scout tx #{i}: {internal_error}")
            return None
        rw_sets.append({
            "reads": record.reads,
            "writes": record.writes,
            "func_hash": record.func_hash,
            "tx_id": record.tx_id,
            "status": record.status,
            "reason": record.reason,
            "notes": sorted(record.notes),
        })
    return rw_sets


def _run_scenario_b(env, alice_addr_str, bob_addr_str, merged_sequence,
                    generator_function_maps, ideal_trajectory_map,
                    initial_state_alice, initial_state_bob,
                    state_A_alice, state_A_bob, contracts_to_check):

    alice_event_counter = defaultdict(int)
    flag = 0
    vulnerability_score = 0
    state_B_alice = None
    state_B_bob = None
    executed_prefix = None

    for i, execution_input in enumerate(merged_sequence):
        tx_data = execution_input['transaction']
        user_addr_str = tx_data['from']
        user_name = "Alice" if user_addr_str == alice_addr_str else "Bob"

        try:
            record = rw_trace.execute_transaction_with_rw_trace(
                env.instrumented_evm,
                execution_input,
                tx_id="scenario-b-%d" % i,
                func_hash=_tx_func_hash(None, tx_data),
            )
        except TxExecutionInternalError as internal_error:
            print(f"!! FATAL (internal) error during scenario B tx #{i}: {internal_error}")
            return {
                "flag": flag,
                "vulnerability_score": vulnerability_score,
                "state_B_alice": state_B_alice,
                "state_B_bob": state_B_bob,
                "candidate_schedule": merged_sequence,
                "error": str(internal_error),
            }

        target_address = tx_data['to']
        target_contract_name = "UnknownContract"
        for name, address in settings.DEPLOYED_CONTRACT_ADDRESS.items():
            if address.lower() == target_address.lower():
                target_contract_name = name
                break

        func_name = "UnknownFunction"
        if target_contract_name in generator_function_maps:
            contract_map = generator_function_maps.get(target_contract_name, {})
            selector = tx_data['data'][:10]
            func_name = contract_map.get(selector, f"UnknownFuncIn_{target_contract_name}({selector})")

        print(f"DEBUG: [B-{i}] Tx from {user_name}. Status: {record.status} ({record.reason}), function: {func_name}")

        if user_name == "Alice":

            func_hash = _tx_func_hash(None, tx_data)


            event_stamp = (func_hash, alice_event_counter[func_hash])
            alice_event_counter[func_hash] += 1

            ideal_state_alice = ideal_trajectory_map.get(event_stamp)
            actual_state_alice = _get_user_state(env, alice_addr_str, contracts_to_check)
            actual_state_bob = _get_user_state(env, bob_addr_str, contracts_to_check)
            if ideal_state_alice:

                step_score = _compare_scenarios(
                    initial_state_alice, initial_state_bob,
                    ideal_state_alice, initial_state_bob,
                    actual_state_alice, actual_state_bob)
                if step_score > 0:
                    flag = 1
                    vulnerability_score = step_score
                    state_B_alice = actual_state_alice
                    state_B_bob = actual_state_bob
                    executed_prefix = merged_sequence[:i + 1]
                    print("[*] Vulnerability found, terminating scenario B early.")
                    break

    if flag == 0:
        state_B_alice = _get_user_state(env, alice_addr_str, contracts_to_check)
        state_B_bob = _get_user_state(env, bob_addr_str, contracts_to_check)
        vulnerability_score = _compare_scenarios(
            initial_state_alice, initial_state_bob,
            state_A_alice, state_A_bob, state_B_alice, state_B_bob)

    return {
        "flag": flag,
        "vulnerability_score": vulnerability_score,
        "state_B_alice": state_B_alice,
        "state_B_bob": state_B_bob,
        "candidate_schedule": executed_prefix if executed_prefix is not None else merged_sequence,
        "error": None,
    }


def _calculate_state_deltas(initial_state, final_state):

    deltas = {}
    all_asset_keys = set(initial_state['assets'].keys()) | set(final_state['assets'].keys())
    for key in all_asset_keys:
        deltas[key] = final_state['assets'].get(key, 0) - initial_state['assets'].get(key, 0)
    return deltas


def _calculate_state_distance(initial_state, final_state):

    return sum(
        1 for delta in _calculate_state_deltas(initial_state, final_state).values() if delta != 0
    )

def _record_finding(env, indv, vulnerability_score,
                    alice_addr_str, bob_addr_str,
                    initial_state_alice, initial_state_bob,
                    state_A_alice, state_A_bob, state_B_alice, state_B_bob,
                    final_sequence, candidate_schedule,
                    alice_rw_sets, bob_rw_sets, threshold=0.0,
                    legacy_valuation_score=None):

    mode = "legacy"
    execution_backend = "legacy"
    if hasattr(env, "args") and hasattr(env.args, "txracer_config"):
        mode = getattr(env.args.txracer_config, "mode", "legacy")
        execution_backend = getattr(env.args.txracer_config, "execution_backend", "legacy")

    asset_map_info = getattr(settings, "ASSET_MAP_INFO", None)
    reproduction_command = getattr(settings, "REPRODUCTION_COMMAND", "")

    def _rw_entries(rw_sets):
        entries = []
        for entry in rw_sets or []:
            entries.append({
                "tx_id": entry.get("tx_id"),
                "func_hash": entry.get("func_hash"),
                "status": entry.get("status"),
                "reason": entry.get("reason"),
                "reads": sorted(entry.get("reads") or []),
                "writes": sorted(entry.get("writes") or []),
                "notes": sorted(entry.get("notes") or []),
            })
        return entries

    record = build_finding_record(
        mode=mode,
        execution_backend=execution_backend,
        seed=getattr(env, "seed", None),
        user=alice_addr_str,
        attacker=bob_addr_str,
        baseline_schedule=final_sequence,
        candidate_schedule=candidate_schedule,
        states={
            "initial": {"victim": initial_state_alice, "attacker": initial_state_bob},
            "scenario_a": {"victim": state_A_alice, "attacker": state_A_bob},
            "scenario_b": {"victim": state_B_alice, "attacker": state_B_bob},
        },
        rw_sets={
            "victim": _rw_entries(alice_rw_sets),
            "attacker": _rw_entries(bob_rw_sets),
        },
        vulnerability_score=vulnerability_score,
        threshold=threshold,
        asset_map_info=asset_map_info,
        reproduction_command=reproduction_command,
        legacy_valuation_score=legacy_valuation_score,
    )

    print("\n" + "!" * 20 + " VULNERABILITY DETECTED! Recording finding... " + "!" * 20)
    print(f"Finding ID: {record['finding_id']}  Vulnerability Score: {vulnerability_score}")


    findings_log = getattr(env, "findings_log", None)
    written = False
    if findings_log is not None:
        written = findings_log.write_record(record)

    if getattr(settings, "LEGACY_FINDING_LOG", False):
        _write_legacy_finding_log(
            indv, vulnerability_score, final_sequence,
            initial_state_alice, initial_state_bob,
            state_A_alice, state_A_bob, state_B_alice, state_B_bob,
        )

    stop_enabled = getattr(settings, "STOP_ON_FIRST_FINDING", False)
    if written and stop_enabled:
        maybe_stop_on_finding(record["finding_id"], True)


def _write_legacy_finding_log(indv, vulnerability_score, final_sequence,
                              initial_state_alice, initial_state_bob,
                              state_A_alice, state_A_bob, state_B_alice, state_B_bob):

    with open("vulnerabilities.log", "a") as f:
        f.write("=" * 50 + "\n")
        f.write(f"Timestamp: {datetime.now()}\n")
        f.write(f"Individual Hash: {indv.hash}\n")
        f.write(f"Vulnerability Score: {vulnerability_score}\n")
        f.write("Decoded Function Sequence (executed in Scenario A):\n")
        f.write(pformat([tx.get('transaction', {}).get('data') for tx in final_sequence]) + "\n")
        f.write(f"Initial States:\n  Alice: {initial_state_alice}\n  Bob:   {initial_state_bob}\n")
        f.write(f"Scenario A Final States:\n  Alice: {state_A_alice}\n  Bob:   {state_A_bob}\n")
        f.write(f"Scenario B Final States:\n  Alice: {state_B_alice}\n  Bob:   {state_B_bob}\n\n")


def _shadow_economic_evaluation(env, indv, user_addr_str, attacker_addr_str,
                                user_sequence, planned_schedule,
                                legacy_executed_prefix, legacy_score):

    try:
        from fuzzer.txracer.execution.scenario_runner import ScenarioRunner
        from fuzzer.txracer.oracles.front_running import (
            FrontRunningOracle,
            OracleConfig,
            build_shadow_record,
        )
        runner = ScenarioRunner(
            env.instrumented_evm,
            chain_id=getattr(settings, "CHAIN_ID", 1),
        )

        user_txs = [deepcopy(tx) for tx in user_sequence]
        for tx in user_txs:
            tx['transaction']['from'] = user_addr_str
        attacker_sequence = [deepcopy(tx) for tx in user_sequence]
        for tx in attacker_sequence:
            tx['transaction']['from'] = attacker_addr_str
        baseline = runner.run_baseline(
            user_txs, attacker_sequence, user_addr_str, attacker_addr_str)

        candidate = runner.run_candidate(
            planned_schedule, user_addr_str, attacker_addr_str)
        oracle = FrontRunningOracle(OracleConfig(
            threshold_ratio=getattr(settings, "ORACLE_THRESHOLD_RATIO", "0"),
            min_absolute=getattr(settings, "ORACLE_MIN_ABSOLUTE", 0)))
        result = oracle.evaluate(baseline, candidate)
        record = build_shadow_record(
            env, indv, legacy_score, baseline, candidate, result,
            planned_schedule=planned_schedule,
            legacy_executed_prefix=legacy_executed_prefix,
            mode=getattr(getattr(env, "args", None), "txracer_mode", "legacy"),
            chain_id=getattr(settings, "CHAIN_ID", 1))
        shadow_log = getattr(env, "shadow_log", None)
        if shadow_log is not None:
            shadow_log.write_record(record)
    except Exception as shadow_error:
        _write_shadow_diagnostic(
            env, indv, legacy_score,
            "shadow economic oracle failed: %s: %s"
            % (type(shadow_error).__name__, shadow_error))


def _write_shadow_diagnostic(env, indv, legacy_score, message):

    diagnostic = {
        "schema_version": 2,
        "type": "shadow_diagnostic",
        "individual_hash": getattr(indv, "hash", None),
        "legacy_vulnerability_score": legacy_score,
        "error": message,
    }
    shadow_log = getattr(env, "shadow_log", None)
    if shadow_log is not None:
        shadow_log.write_record(diagnostic)
    else:
        print("[!] %s (individual %s)"
              % (message, getattr(indv, "hash", "?")))


def _fitness_preemption_path(env, indv, alice_addr_str, bob_addr_str, final_sequence):

    from fuzzer.txracer.execution.scenario_runner import ScenarioRunner
    from fuzzer.txracer.interleaving.attacker import (
        ASSET_PREFILTER_STATUS,
        prune_attacker_sequence,
    )
    from fuzzer.txracer.interleaving.rw_sets import (
        collect_anchor_rw_sets,
    )
    from fuzzer.txracer.interleaving.preemption import (
        find_all_preemption_points,
        sort_preemption_points,
    )
    from fuzzer.txracer.interleaving.scheduler import (
        SchedulerConfig,
        generate_schedules,
    )
    from fuzzer.txracer.oracles.front_running import (
        FRONT_RUNNING_PROFIT,
        FrontRunningOracle,
        OracleConfig,
    )
    from fuzzer.txracer.reporting import (
        attach_finding_status,
        build_schedule_finding,
        build_scheduler_outcome,
    )

    chain_id = getattr(settings, "CHAIN_ID", 1)
    runner = ScenarioRunner(env.instrumented_evm, chain_id=chain_id)

    user_txs = [deepcopy(tx) for tx in final_sequence]
    for tx in user_txs:
        tx['transaction']['from'] = alice_addr_str


    user_ids = ["trace-%d" % i for i in range(len(user_txs))]

    def _write_diagnostic(message):
        diagnostic = {
            "schema_version": 2,
            "type": "scheduler_diagnostic",
            "individual_hash": getattr(indv, "hash", None),
            "error": message,
        }
        findings_log = getattr(env, "findings_log", None)
        if findings_log is not None:
            findings_log.write_record(diagnostic)
        else:
            print("[!] %s" % message)

    def _write_scheduler_outcome(outcome, reason=None, removed_call_count=None,
                                 pp_detected=None):

        record = build_scheduler_outcome(
            outcome=outcome,
            seed=getattr(env, "seed", None),
            mode=getattr(getattr(env, "args", None), "txracer_mode", "legacy"),
            chain_id=chain_id,
            individual_hash=getattr(indv, "hash", None),
            weight_mode=getattr(settings, "PREEMPTION_WEIGHT_MODE", "extended"),
            reason=reason,
            removed_call_count=removed_call_count,
            pp_detected=pp_detected,
        )
        findings_log = getattr(env, "findings_log", None)
        persisted = False
        persistence_error = None
        if findings_log is not None:
            if findings_log.write_record(record):
                persisted = True
            else:
                persistence_error = "finding log write failed"
        else:
            persistence_error = "finding log absent"
        record["persisted"] = persisted
        if persistence_error:
            record["persistence_error"] = persistence_error
        if isinstance(env.results, dict):
            env.results["scheduler_outcome"] = record
        print("[*] Preemption scheduler: %s (outcome %s, persisted=%s)"
              % (outcome, record["outcome_id"], persisted))
        return record

    try:

        prune_result = prune_attacker_sequence(
            runner, user_txs, bob_addr_str)


        if prune_result.non_prunable_failures:
            failure = prune_result.non_prunable_failures[0]
            _write_scheduler_outcome(
                outcome="attacker_validation_error",
                reason=failure.get("reason"),
                removed_call_count=len(prune_result.removed_calls),
            )
            return 0.0
        attacker_txs = prune_result.pruned
        if not attacker_txs:
            _write_scheduler_outcome(
                outcome="attacker_empty_after_pruning",
                removed_call_count=len(prune_result.removed_calls),
            )
            return 0.0


        pipeline = getattr(env, "state_feedback_pipeline", None)
        asset_prefilter_status = ASSET_PREFILTER_STATUS
        economic_state_snapshot = frozenset()
        predicate = None
        if pipeline is not None and getattr(settings, "ASSET_STATE_FEEDBACK", False):


            user_obs, attacker_obs = pipeline.observe_seed(
                user_txs, attacker_txs,
                user_ids=user_ids,
                attacker_ids=prune_result.pruned_ids,
                user_chromosome=getattr(indv, "chromosome", None),
                attacker_chromosome=getattr(indv, "chromosome", None))


            if getattr(settings, "INTENT_ORACLE", False):
                _evaluate_seed_intent(
                    env, pipeline, runner, user_txs, attacker_txs,
                    user_ids=user_ids,
                    attacker_ids=prune_result.pruned_ids)
            decision = pipeline.prefilter(user_txs, user_obs.records)
            if not decision.allowed:
                outcome = "paper_fail_closed" if any(
                    reason.startswith(("ambiguous", "taint",
                                       "unsupported", "asset_read_failed"))
                    for reason in decision.reasons
                ) else "prefilter_rejected"
                _write_scheduler_outcome(
                    outcome=outcome,
                    reason=";".join(decision.reasons),
                    removed_call_count=len(prune_result.removed_calls),
                )
                return 0.0
            predicate = pipeline.asset_key_predicate()
            economic_state_snapshot = user_obs.economic_state_snapshot
            asset_prefilter_status = "active"
        anchor_pair = collect_anchor_rw_sets(
            runner, user_txs, attacker_txs,
            user_addr=alice_addr_str, attacker_addr=bob_addr_str,
            asset_key_predicate=predicate,
            user_ids=user_ids, attacker_ids=prune_result.pruned_ids)
        if anchor_pair.skip_reason is not None:
            _write_scheduler_outcome(
                outcome="sequence_pair_out_of_bounds",
                reason=anchor_pair.skip_reason,
                removed_call_count=len(prune_result.removed_calls))
            return 0.0
        user_rw, attacker_rw = anchor_pair.user_rw, anchor_pair.attacker_rw
        points = find_all_preemption_points(user_rw, attacker_rw)
        if not points:
            _write_scheduler_outcome(
                outcome="no_preemption_points",
                removed_call_count=len(prune_result.removed_calls),
                pp_detected=0,
            )
            return 0.0

        weight_mode = getattr(settings, "PREEMPTION_WEIGHT_MODE", "extended")
        config = SchedulerConfig(
            max_preemption_points=getattr(settings, "MAX_PREEMPTION_POINTS", 2),
            preemption_candidate_cap=getattr(settings, "PREEMPTION_CANDIDATE_CAP", 8),
            max_schedules_per_seed=getattr(settings, "MAX_SCHEDULES_PER_SEED", 128),
            global_seed=int(getattr(env, "seed", 1) or 0),
        )
        schedule_set = generate_schedules(
            user_txs, attacker_txs, points, config, weight_mode=weight_mode,
            user_ids=user_ids, attacker_ids=prune_result.pruned_ids,
            economic_state_snapshot=economic_state_snapshot,
            anchor_results=anchor_pair.anchor_results)
        print("[*] Preemption scheduler: %d PPs (%s mode), %d unique schedules%s"
              % (len(points), weight_mode, len(schedule_set.schedules),
                 " (truncated)" if schedule_set.truncated else ""))


        baseline = anchor_pair.ur_result
        oracle = FrontRunningOracle(OracleConfig(
            threshold_ratio=getattr(settings, "ORACLE_THRESHOLD_RATIO", "0"),
            min_absolute=getattr(settings, "ORACLE_MIN_ABSOLUTE", 0)))


        intent_oracle = None
        intent_baseline = None
        intent_log = getattr(env, "intent_log", None)
        if getattr(settings, "INTENT_ORACLE", False):
            from fuzzer.txracer.oracles.intent import (
                IntentOracle,
                evm_intent_reader,
                identity_resolver,
            )


            intent_adapters = getattr(settings, "INTENT_ADAPTERS", None)
            intent_oracle = IntentOracle(
                adapters=intent_adapters,
                chain_id=chain_id,
                block_profile={"evm_version": getattr(
                    settings, "EVM_VERSION", None)})
            intent_reader = evm_intent_reader(env.instrumented_evm)
            intent_resolver = identity_resolver(
                dict(getattr(settings, "DEPLOYED_CONTRACT_ADDRESS", {})))
            token_ids = _collect_intent_token_ids(pipeline)
            intent_baseline = intent_oracle.capture_baseline(
                intent_reader, intent_resolver, alice_addr_str,
                bob_addr_str, token_ids)

        sorted_points = sort_preemption_points(points, weight_mode=weight_mode)
        for schedule in schedule_set.schedules:
            candidate = schedule.cached_result
            if candidate is None:
                candidate = runner.run_candidate(
                    schedule.tx_inputs, alice_addr_str, bob_addr_str,
                    tx_ids=[tx_id for _label, tx_id in schedule.order_key])
            result = oracle.evaluate(baseline, candidate)
            if intent_oracle is not None and intent_baseline is not None:
                intent_result = intent_oracle.evaluate_candidate(
                    intent_baseline, intent_reader, intent_resolver,
                    alice_addr_str, bob_addr_str, token_ids,
                    schedule_identity=[
                        [label, tx_id]
                        for label, tx_id in schedule.order_key
                    ])
                if intent_log is not None:
                    intent_record = {
                        "schema_version": 1,
                        "finding_type": "INTENT_ORACLE",
                        "seed": getattr(env, "seed", None),
                        "individual_hash": getattr(indv, "hash", None),
                        "candidate_order_key": [
                            [label, tx_id]
                            for label, tx_id in schedule.order_key
                        ],
                        "note": "intent evidence only; never "
                                "FRONT_RUNNING_PROFIT",
                    }
                    intent_record.update(intent_result.to_dict())
                    intent_log.write_record(intent_record)
            if result.classification == FRONT_RUNNING_PROFIT:
                mode = getattr(getattr(env, "args", None), "txracer_mode", "legacy")
                execution_backend = getattr(
                    getattr(env, "args", None), "execution_backend", "legacy")
                target_source_hash = getattr(
                    settings, "SOURCE_SHA256", None)
                target_contract = getattr(
                    env, "contract_name", None)
                target_contract_address = dict(getattr(
                    settings, "DEPLOYED_CONTRACT_ADDRESS", {})).get(
                        target_contract) if target_contract else None
                record = build_schedule_finding(
                    mode=mode,
                    chain_id=chain_id,
                    seed=getattr(env, "seed", None),
                    execution_backend=execution_backend,
                    profile={"evm_version": getattr(settings, "EVM_VERSION", None)},
                    user=alice_addr_str,
                    attacker=bob_addr_str,
                    extra_schedule=getattr(schedule, "extra", False),
                    target_source_hash=target_source_hash,
                    target_contract=target_contract,
                    target_contract_address=target_contract_address,
                    user_sequence=user_txs,
                    attacker_sequence_original=prune_result.original,
                    attacker_removed_calls=prune_result.removed_calls,
                    attacker_sequence_pruned=attacker_txs,
                    preemption_pairs=[
                        point.to_dict(weight_mode=weight_mode)
                        for point in sorted_points
                    ],
                    selected_preemption_points=schedule.source_combo,
                    weight_mode=weight_mode,
                    candidate_cap=config.preemption_candidate_cap,
                    baseline=baseline,
                    candidate=candidate,
                    planned_candidate=schedule.tx_inputs,
                    oracle_result=result,
                    schedule_order_key=schedule.order_key,
                    schedule_stats=schedule_set.to_dict(),
                    reproduction_command=getattr(settings, "REPRODUCTION_COMMAND", ""),
                    diagnostic_refs=[],
                    asset_prefilter_status=asset_prefilter_status,
                )


                if pipeline is not None:
                    record["asset_feedback"] = pipeline.summary_dict()


                attach_finding_status(
                    record,
                    persisted=False,
                    stop_reason="high_confidence_confirmed",
                )
                findings_log = getattr(env, "findings_log", None)
                if findings_log is not None:
                    payload = dict(record)
                    payload["persisted"] = True
                    if findings_log.write_record(payload):
                        record["persisted"] = True
                    else:
                        record["persisted"] = False
                        record["persistence_error"] = "finding log write failed"
                else:
                    record["persisted"] = False
                    record["persistence_error"] = "finding log absent"
                if isinstance(env.results, dict):
                    env.results['vulnerability_score'] = float(len(result.confirmed_assets))
                    env.results['scheduler_finding'] = record
                print("[*] Preemption scheduler: FRONT_RUNNING_PROFIT confirmed "
                      "(finding %s, persisted=%s); stopping remaining schedules "
                      "for this seed."
                      % (record["finding_id"], record["persisted"]))
                return float(len(result.confirmed_assets))
        return 0.0
    except Exception as preemption_error:
        _write_diagnostic(
            "preemption scheduling failed for %s: %s: %s"
            % (getattr(indv, "hash", "?"), type(preemption_error).__name__,
               preemption_error))
        return 0.0


def _fitness_preemption_path_v2(env, indv, alice_addr_str,
                                    bob_addr_str, final_sequence):

    from fuzzer.txracer.execution.scenario_runner import ScenarioRunner
    from fuzzer.txracer.interleaving.rw_sets import (
        collect_anchor_rw_sets,
    )
    from fuzzer.txracer.interleaving.preemption import (
        find_all_preemption_points,
        sort_preemption_points,
    )
    from fuzzer.txracer.interleaving.scheduler import (
        SchedulerConfig,
        generate_schedules,
    )
    from fuzzer.txracer.interleaving.interaction import (
        InteractionValidationError,
        reversed_preemption_pairs,
    )
    from fuzzer.txracer.oracles.front_running import (
        FRONT_RUNNING_PROFIT,
        FrontRunningOracle,
        OracleConfig,
    )
    from fuzzer.txracer.adversarial.inference import (
        AttackerInferenceConfig,
        derive_attacker_candidates,
    )
    from fuzzer.txracer.adversarial.context import (
        build_inference_context,
        executed_order,
    )
    from fuzzer.txracer.reporting import (
        attach_finding_status,
        build_schedule_finding,
        build_scheduler_outcome,
    )

    chain_id = getattr(settings, "CHAIN_ID", 1)
    runner = ScenarioRunner(env.instrumented_evm, chain_id=chain_id)
    user_txs = [deepcopy(tx) for tx in final_sequence]
    for tx in user_txs:
        tx['transaction']['from'] = alice_addr_str
    user_ids = ["trace-%d" % i for i in range(len(user_txs))]

    def _write_scheduler_outcome(outcome, reason=None,
                                 removed_call_count=None,
                                 pp_detected=None):
        record = build_scheduler_outcome(
            outcome=outcome,
            seed=getattr(env, "seed", None),
            mode=getattr(getattr(env, "args", None), "txracer_mode",
                         "legacy"),
            chain_id=chain_id,
            individual_hash=getattr(indv, "hash", None),
            weight_mode=getattr(settings, "PREEMPTION_WEIGHT_MODE",
                                "extended"),
            reason=reason,
            removed_call_count=removed_call_count,
            pp_detected=pp_detected,
        )
        findings_log = getattr(env, "findings_log", None)
        persisted = False
        if findings_log is not None and findings_log.write_record(record):
            persisted = True
        record["persisted"] = persisted
        return record

    pipeline = getattr(env, "state_feedback_pipeline", None)
    try:
        user_obs = None
        if pipeline is not None and getattr(
                settings, "ASSET_STATE_FEEDBACK", False):
            user_obs = pipeline.observe_sequence(
                user_txs, user_ids, role="victim",
                chromosome=getattr(indv, "chromosome", None))
        inference_context, selector_map = build_inference_context(
            env, pipeline, alice_addr_str, bob_addr_str, user_txs)
        ka = settings.resolve_actor_role_setting(
            "MAX_ATTACKER_SEQUENCES_PER_USER",
            "MAX_ATTACKER_SEQUENCES_PER_VICTIM",
            8,
        )
        max_depth = getattr(settings, "MAX_ATTACKER_MUTATION_DEPTH", 2)
        seed = int(getattr(env, "seed", 1) or 1)
        config = AttackerInferenceConfig(ka=ka, max_depth=max_depth,
                                         seed=seed)
        economic_state_snapshot = (
            user_obs.economic_state_snapshot
            if user_obs is not None else frozenset())
        economic_states = sorted(economic_state_snapshot)
        candidates, budget_truncated = derive_attacker_candidates(
            user_txs, bob_addr_str, "victim-%s" % getattr(
                indv, "hash", "?"), config, inference_context,
            economic_states=economic_states)
        if not candidates:
            _write_scheduler_outcome(
                outcome="attacker_inference_empty",
                reason="no attacker candidate derivable",
                removed_call_count=0)
            return 0.0
        print("[*] Paper v2 attacker inference: %d candidates "
              "(ka=%d, max_depth=%d, seed=%d%s)"
              % (len(candidates), ka, max_depth, seed,
                 ", TRUNCATED" if budget_truncated else ""))
        stop_on_first = bool(getattr(settings, "STOP_ON_FIRST_FINDING",
                                     False))
        findings_count = 0


        priority_state = None
        priority_fail_closed = False
        if pipeline is not None and getattr(
                settings, "ASSET_STATE_FEEDBACK", False):
            try:
                priority_state, priority_reasons, priority_fail_closed = (
                    pipeline.user_priority(
                        user_txs,
                        user_obs.records if user_obs is not None
                        else None))
                if priority_fail_closed:
                    _write_scheduler_outcome(
                        outcome="v2_priority_fail_closed",
                        reason=";".join(priority_reasons),
                        removed_call_count=0)
            except Exception as priority_error:  # noqa: BLE001
                priority_fail_closed = True
                _write_scheduler_outcome(
                    outcome="v2_priority_fail_closed",
                    reason="%s: %s" % (type(priority_error).__name__,
                                       priority_error),
                    removed_call_count=0)
        for candidate in candidates:
            candidate_txs = candidate.transactions
            candidate_ids = list(candidate.transaction_ids)
            try:
                anchor_pair = collect_anchor_rw_sets(
                    runner, user_txs, candidate_txs,
                    user_addr=alice_addr_str, attacker_addr=bob_addr_str,
                    asset_key_predicate=(
                        pipeline.asset_key_predicate()
                        if pipeline is not None else None),
                    user_ids=user_ids,
                    attacker_ids=candidate_ids)
            except Exception as rw_error:  # noqa: BLE001
                _write_scheduler_outcome(
                    outcome="candidate_rw_failed",
                    reason="%s: %s" % (candidate.candidate_id,
                                       rw_error),
                    removed_call_count=0)
                continue
            if anchor_pair.skip_reason is not None:
                _write_scheduler_outcome(
                    outcome="sequence_pair_out_of_bounds",
                    reason="%s: %s" % (
                        candidate.candidate_id, anchor_pair.skip_reason),
                    removed_call_count=0)
                continue
            user_rw, attacker_rw = anchor_pair.user_rw, anchor_pair.attacker_rw
            points = find_all_preemption_points(user_rw, attacker_rw)
            if not points:
                continue
            weight_mode = getattr(settings,
                                  "PREEMPTION_WEIGHT_MODE", "extended")
            scheduler_config = SchedulerConfig(
                max_preemption_points=getattr(
                    settings, "MAX_PREEMPTION_POINTS", 2),
                preemption_candidate_cap=getattr(
                    settings, "PREEMPTION_CANDIDATE_CAP", 8),
                max_schedules_per_seed=getattr(
                    settings, "MAX_SCHEDULES_PER_SEED", 128),
                global_seed=seed,
            )
            schedule_set = generate_schedules(
                user_txs, candidate_txs, points, scheduler_config,
                weight_mode=weight_mode,
                user_ids=user_ids,
                attacker_ids=candidate_ids,
                economic_state_snapshot=economic_state_snapshot,
                anchor_results=anchor_pair.anchor_results)
            if not schedule_set.schedules:
                continue
            baseline = anchor_pair.ur_result
            oracle = FrontRunningOracle(OracleConfig(
                threshold_ratio=getattr(
                    settings, "ORACLE_THRESHOLD_RATIO", "0"),
                min_absolute=getattr(settings, "ORACLE_MIN_ABSOLUTE", 0)))
            sorted_points = sort_preemption_points(
                points, weight_mode=weight_mode)
            for schedule in schedule_set.schedules:
                candidate_result = schedule.cached_result
                if candidate_result is None:
                    candidate_result = runner.run_candidate(
                        schedule.tx_inputs, alice_addr_str, bob_addr_str,
                        tx_ids=[tx_id for _label, tx_id in schedule.order_key])
                try:
                    baseline_order = executed_order(
                        baseline.tx_results, alice_addr_str, bob_addr_str,
                        user_ids, candidate_ids)
                    candidate_order = executed_order(
                        candidate_result.tx_results, alice_addr_str,
                        bob_addr_str, user_ids, candidate_ids)
                    reversed_pairs = reversed_preemption_pairs(
                        baseline_order, candidate_order, points)
                except InteractionValidationError as interaction_error:
                    _write_scheduler_outcome(
                        outcome="interaction_validation_error",
                        reason="%s: %s" % (candidate.candidate_id,
                                           interaction_error),
                        removed_call_count=0)
                    continue
                result = oracle.evaluate(
                    baseline, candidate_result,
                    reversed_preemption_pairs=reversed_pairs,
                    interaction_gate=bool(getattr(
                        settings, "ORACLE_INTERACTION_GATE", False)),
                    paper_design_version="v2")
                if (priority_fail_closed
                        and result.classification == FRONT_RUNNING_PROFIT):
                    _write_scheduler_outcome(
                        outcome="v2_priority_fail_closed",
                        reason="economic conditions met but victim "
                               "priority evidence is untrustworthy; "
                               "finding blocked",
                        removed_call_count=0)
                    continue
                if result.classification == FRONT_RUNNING_PROFIT:
                    mode = getattr(getattr(env, "args", None),
                                   "txracer_mode", "legacy")
                    execution_backend = getattr(
                        getattr(env, "args", None),
                        "execution_backend", "legacy")
                    target_source_hash = getattr(
                        settings, "SOURCE_SHA256", None)
                    target_contract = getattr(env, "contract_name", None)
                    target_contract_address = (
                        dict(getattr(settings,
                                     "DEPLOYED_CONTRACT_ADDRESS", {}))
                        .get(target_contract)
                        if target_contract else None)
                    record = build_schedule_finding(
                        mode=mode,
                        chain_id=chain_id,
                        seed=getattr(env, "seed", None),
                        execution_backend=execution_backend,
                        profile={"evm_version": getattr(
                            settings, "EVM_VERSION", None)},
                        user=alice_addr_str,
                        attacker=bob_addr_str,
                        user_sequence=user_txs,
                        attacker_sequence_original=candidate_txs,
                        attacker_removed_calls=[],
                        attacker_sequence_pruned=candidate_txs,
                        preemption_pairs=[
                            point.to_dict(weight_mode=weight_mode)
                            for point in sorted_points
                        ],
                        selected_preemption_points=schedule.source_combo,
                        weight_mode=weight_mode,
                        candidate_cap=scheduler_config.preemption_candidate_cap,
                        baseline=baseline,
                        candidate=candidate_result,
                        planned_candidate=schedule.tx_inputs,
                        oracle_result=result,
                        schedule_order_key=schedule.order_key,
                        schedule_stats=schedule_set.to_dict(),
                        reproduction_command=getattr(
                            settings, "REPRODUCTION_COMMAND", ""),
                        diagnostic_refs=[],
                        asset_prefilter_status=(
                            "v2_priority_only"
                            if priority_state is not None
                            else "v2_no_priority_computed"),
                        extra_schedule=getattr(schedule, "extra", False),
                        target_source_hash=target_source_hash,
                        target_contract=target_contract,
                        target_contract_address=target_contract_address,
                        paper_design_version="v2",
                        attacker_candidate_id=candidate.candidate_id,
                        attacker_operator_chain=candidate.operator_chain,
                        reversed_preemption_pairs=reversed_pairs,
                        economic_state_keys=economic_states,
                        eta=str(result.threshold_ratio),
                    )
                    if pipeline is not None:
                        record["asset_feedback"] = pipeline.summary_dict()
                    record["attacker_inference_budget"] = {
                        "ka": ka, "max_depth": max_depth,
                        "generated": len(candidates),
                        "truncated": budget_truncated,
                    }
                    record["attacker_candidate_provenance"] = (
                        candidate.to_dict())
                    if priority_state is not None:
                        record["v2_priority"] = {
                            "has_economic_write": priority_state[0],
                            "victim_has_equity": priority_state[1],
                            "has_economic_change": priority_state[2],
                        }
                    record["baseline_order"] = [
                        [label, tx_id] for label, tx_id in baseline_order
                    ]
                    record["candidate_order"] = [
                        [label, tx_id] for label, tx_id in candidate_order
                    ]
                    attach_finding_status(
                        record, persisted=False,
                        stop_reason="high_confidence_confirmed")
                    findings_log = getattr(env, "findings_log", None)
                    if findings_log is not None:
                        payload = dict(record)
                        payload["persisted"] = True
                        if findings_log.write_record(payload):
                            record["persisted"] = True
                        else:
                            record["persisted"] = False
                            record["persistence_error"] = (
                                "finding log write failed")
                    print("[*] Paper v2: FRONT_RUNNING_PROFIT confirmed "
                          "(finding %s, candidate %s, %d reversed PP)"
                          % (record["finding_id"],
                             candidate.candidate_id, len(reversed_pairs)))
                    findings_count += 1
                    if stop_on_first:
                        return float(len(result.confirmed_assets))

        _write_scheduler_outcome(
            outcome="paper_v2_completed",
            reason="candidates=%d truncated=%s stop_on_first=%s" % (
                len(candidates), budget_truncated, stop_on_first),
            removed_call_count=0)
        return float(findings_count)
    except Exception as v2_error:  # noqa: BLE001
        _write_scheduler_outcome(
            outcome="paper_v2_internal_error",
            reason="%s: %s" % (type(v2_error).__name__, v2_error),
            removed_call_count=0)
        return 0.0


def fitness_function(indv, env):


    solution_sequence = indv.decode()
    chromosome = indv.chromosome

    if not solution_sequence or len(chromosome) != len(solution_sequence):
        print("!! WARNING: Chromosome and Solution mismatch or empty. Running with raw fuzzer sequence.")

        final_paired_sequence = [(None, sol) for sol in solution_sequence] if solution_sequence else []
    else:
        paired_sequence = list(zip(chromosome, solution_sequence))


        generator_function_maps = {gen.contract_name: {h: sig for sig, h in gen.interface_mapper.items()}
                                   for gen in [indv.generator] + indv.other_generators if gen.interface_mapper}


        parts_warehouse = {}
        for gene, solution in paired_sequence:
            try:

                func_hash = gene['arguments'][0]
                target_address = solution['transaction']['to']
                target_contract_name = next((name for name, addr in settings.DEPLOYED_CONTRACT_ADDRESS.items() if addr.lower() == target_address.lower()), None)
                if not target_contract_name: continue

                func_sig = generator_function_maps.get(target_contract_name, {}).get(func_hash)
                if not func_sig: continue


                parts_warehouse[func_sig] = (gene, solution)
            except (KeyError, TypeError, IndexError) as warehouse_error:

                print(f"!! WARNING: skipping malformed gene for parts warehouse: {warehouse_error}")
                continue


        template_filepath = "./current_fuzz_sequence.json"
        final_paired_sequence = []

        if os.path.exists(template_filepath):

            try:
                with open(template_filepath, 'r') as f:
                    sequence_template = json.load(f)

                for task in sequence_template:
                    func_sig = task.get('signature')
                    required_part = parts_warehouse.get(func_sig)

                    if required_part:

                        final_paired_sequence.append(required_part)
                    else:
                        print(f"!! WARNING: Could not find part for '{func_sig}' in this individual's sequence. Skipping step.")
            except Exception as e:
                print(f"!! FATAL ERROR while processing sequence template: {e}"); return 0.0
        else:
            final_paired_sequence = paired_sequence

    if not final_paired_sequence:
        print("DEBUG: No valid sequence to test. Skipping."); return 0.0

    try:
        if len(env.instrumented_evm.accounts) < 2:
            raise RuntimeError("Not enough pre-set accounts for simulation. Need at least 2.")

        alice_addr_str = env.instrumented_evm.accounts[0]
        bob_addr_str = env.instrumented_evm.accounts[1]


        all_generators = [indv.generator] + indv.other_generators
        for gen in all_generators:

            extended_accounts = set(gen.accounts)
            extended_accounts.add(alice_addr_str)
            extended_accounts.add(bob_addr_str)
            gen.accounts = list(extended_accounts)


        env.instrumented_evm.restore_from_snapshot()


        genesis_transfer_amount = Web3.toWei(1, 'ether')
        try:
             genesis_tx_input = {
                 'transaction': {
                     'from': alice_addr_str, 'to': bob_addr_str,
                     'value': genesis_transfer_amount, 'data': '0x',
                     'gaslimit': settings.GAS_LIMIT
                 }, 'block': {}, 'global_state': {}, 'environment': {}
             }
             result = env.instrumented_evm.deploy_transaction(genesis_tx_input, gas_price=0)
             if result.is_error:
                 raise RuntimeError(f"Genesis transaction failed: {result._error}")

        except Exception as e:
            print(f"!! FATAL ERROR during genesis transaction: {e}"); return 0.0


        env.instrumented_evm.create_snapshot()
        contracts_to_check = {}

        env.instrumented_evm.restore_from_snapshot()


        if hasattr(settings, 'DEPLOYED_CONTRACT_ADDRESS'):
            for name, address in settings.DEPLOYED_CONTRACT_ADDRESS.items():
                contracts_to_check[address] = "ERC20"

    except Exception as e:
        print(f"!! ERROR: Failed to set up: {e}"); return 0.0

    generator_map = {indv.generator.contract_name: indv.generator}
    for g in indv.other_generators:
        generator_map[g.contract_name] = g

    final_sequence = []

    for i, gene in enumerate(indv.chromosome):

        try:

            target_address = gene['contract']


            target_generator = None
            target_contract_name = None
            for name, address in settings.DEPLOYED_CONTRACT_ADDRESS.items():
                if address.lower() == target_address.lower():
                    target_contract_name = name
                    target_generator = generator_map.get(name)
                    break


            if not target_generator:
                print(f"!! WARNING: Could not find generator for address {target_address} in gene {i}. Skipping.")
                continue


            func_hash = gene['arguments'][0]
            arg_values = gene['arguments'][1:]

            if func_hash == "constructor":


                print(f"!! WARNING: skipping constructor gene {i}; contract is already deployed.")
                continue

            arg_types = target_generator.interface.get(func_hash)

            if arg_types is None:
                print(f"!! WARNING: Could not find arg_types for hash {func_hash} in {target_contract_name}'s interface. Skipping.")
                continue
            if len(arg_values) != len(arg_types):
                print(f"!! WARNING: Arg count mismatch for {func_hash}. Skipping gene {i}.")
                continue


            tx_data = build_tx_calldata(func_hash, arg_types, arg_values)
            if tx_data is None:
                print(f"!! WARNING: skipping gene {i}: could not build valid calldata for '{func_hash}'.")
                continue


            execution_input = {
                'transaction': {
                    'from': '0xPLACEHOLDER',
                    'to': target_address,
                    'value': gene['amount'],
                    'data': tx_data,
                    'gaslimit': gene['gaslimit']
                }, 'block': {}, 'global_state': {}, 'environment': {}
            }
            final_sequence.append(execution_input)

        except Exception as decode_error:


            print(f"!! FATAL (internal) error while decoding gene {i}: {decode_error}")
            pprint(gene)
            return 0.0

    if not final_sequence:
        print("DEBUG: No valid sequence was decoded. Skipping."); return 0.0


    if getattr(settings, "PREEMPTION_SCHEDULER", False):
        if getattr(settings, "PAPER_DESIGN_VERSION", "v1") == "v2":
            return _fitness_preemption_path_v2(
                env, indv, alice_addr_str, bob_addr_str, final_sequence)
        return _fitness_preemption_path(env, indv, alice_addr_str,
                                        bob_addr_str, final_sequence)


    if getattr(settings, "ASSET_STATE_FEEDBACK", False):
        feedback_pipeline = getattr(env, "state_feedback_pipeline", None)
        if feedback_pipeline is not None:
            try:
                shadow_user = [deepcopy(tx) for tx in final_sequence]
                for tx in shadow_user:
                    tx['transaction']['from'] = alice_addr_str
                feedback_pipeline.observe_sequence(
                    shadow_user,
                    ["trace-%d" % i for i in range(len(shadow_user))],
                    role="victim",
                    chromosome=getattr(indv, "chromosome", None))
            except Exception as feedback_error:
                _write_diagnostic(
                    "asset state feedback shadow observation failed: %s: %s"
                    % (type(feedback_error).__name__, feedback_error))


    generator_function_maps = {}
    all_generators = [indv.generator] + indv.other_generators
    for gen in all_generators:
        if gen.interface_mapper:
            gen_map = {h: sig for sig, h in gen.interface_mapper.items()}
            generator_function_maps[gen.contract_name] = gen_map
        else:
            generator_function_maps[gen.contract_name] = {}
    def execute_and_log(tx_input, user_name, tx_index_str):
        tx = tx_input['transaction']
        target_address = tx['to']

        target_contract_name = next((name for name, addr in settings.DEPLOYED_CONTRACT_ADDRESS.items() if addr.lower() == target_address.lower()), "UnknownContract")

        func_name = "UnknownFunc"
        params_str = "N/A"

        if target_contract_name in generator_function_maps:
            contract_map = generator_function_maps.get(target_contract_name, {})
            selector = tx['data'][:10]
            func_sig = contract_map.get(selector)

            if func_sig:
                func_name = func_sig
                try:
                    _, _, arg_types_str = func_sig.partition('(')
                    arg_types_str = arg_types_str.rpartition(')')[0]
                    arg_types = arg_types_str.split(',') if arg_types_str and arg_types_str.strip() else []

                    encoded_args_hex = tx['data'][10:]
                    decoded_args = decode_abi(arg_types, bytes.fromhex(encoded_args_hex))
                    params_str = str(decoded_args)
                except Exception as e:
                    params_str = f"DECODING_ERROR: {e}"

        result = env.instrumented_evm.deploy_transaction(tx_input, gas_price=0)
        status = "SUCCESS" if not result.is_error else f"FAILED ({result._error})"
        print(f"DEBUG: [{tx_index_str}] Tx from {user_name} to {target_contract_name}, func: {func_name}, params: {params_str}, Status: {status}")


        current_alice_state = _get_user_state(env, alice_addr_str, contracts_to_check)
        current_bob_state = _get_user_state(env, bob_addr_str, contracts_to_check)


    alice_solution = deepcopy(final_sequence)
    for tx in alice_solution: tx['transaction']['from'] = alice_addr_str
    bob_solution = deepcopy(final_sequence)
    for tx in bob_solution: tx['transaction']['from'] = bob_addr_str

    alice_rw_sets = _scout_rw_sets(env, final_paired_sequence, alice_addr_str, "alice")
    if alice_rw_sets is None:
        return 0.0
    bob_rw_sets = _scout_rw_sets(env, final_paired_sequence, bob_addr_str, "bob")
    if bob_rw_sets is None:
        return 0.0


    preemption_pairs = _find_preemption_pairs(alice_rw_sets, bob_rw_sets)


    env.instrumented_evm.restore_from_snapshot()
    env.data_dependencies.clear()
    initial_state_alice = _get_user_state(env, alice_addr_str, contracts_to_check)
    initial_state_bob = _get_user_state(env, bob_addr_str, contracts_to_check)
    ideal_trajectory_map = {}
    for i, (gene, execution_input) in enumerate(final_paired_sequence):
        tx_data = execution_input['transaction']
        try:

            sender_addr_canon = to_canonical_address(alice_addr_str)
            nonce = env.instrumented_evm.vm.state.get_nonce(sender_addr_canon)
            tx = env.instrumented_evm.vm.create_unsigned_transaction(
                nonce=nonce, gas_price=0, gas=tx_data['gaslimit'],
                to=to_canonical_address(tx_data['to']), value=tx_data['value'],
                data=decode_hex(tx_data['data'])
            )
            spoofed_tx = SpoofTransaction(tx, from_=sender_addr_canon)
            result_computation = env.instrumented_evm.vm.state.apply_transaction(spoofed_tx)
            status = get_revert_reason(result_computation)


            func_hash = _tx_func_hash(gene, tx_data)
            if gene is not None and isinstance(gene, dict) and isinstance(gene.get("arguments"), list):
                readable_args = gene["arguments"][1:]
            else:
                readable_args = "N/A (raw fuzzer sequence)"


            target_address = tx_data['to']
            target_contract_name = next((name for name, addr in settings.DEPLOYED_CONTRACT_ADDRESS.items() if addr.lower() == target_address.lower()), "UnknownContract")
            func_name = generator_function_maps.get(target_contract_name, {}).get(func_hash, f"UnknownFunc({func_hash})")

            if hasattr(settings, 'DEPLOYED_CONTRACT_ADDRESS'):
                for name, address in settings.DEPLOYED_CONTRACT_ADDRESS.items():
                    if address.lower() == target_address.lower():
                        target_contract_name = name
                        break
            event_stamp = (func_hash, len([h for h,s in ideal_trajectory_map.keys() if h == func_hash]))
            current_state_A_alice = _get_user_state(env, alice_addr_str, contracts_to_check)
            ideal_trajectory_map[event_stamp] = current_state_A_alice
        except ValidationError as validation_error:


            print(f"DEBUG: [A-{i}] Tx from Alice. ValidationError: {validation_error}")
        except Exception as internal_error:

            print(f"!! FATAL (internal) error during scenario A tx #{i}: {internal_error}")
            return 0.0

    state_A_alice = _get_user_state(env, alice_addr_str, contracts_to_check)


    state_A_bob = _get_user_state(env, bob_addr_str, contracts_to_check)


    env.instrumented_evm.restore_from_snapshot()

    merged_sequence = []
    alice_event_counter = defaultdict(int)
    flag = 0

    if preemption_pairs and random.random() < 0.8:


        k = min(len(preemption_pairs), 2)
        selected_pps = sorted(preemption_pairs, key=lambda p: (p['A_idx'], p['B_idx']))[:k]

        alice_conflict_indices = [pp['A_idx'] for pp in selected_pps]
        bob_conflict_indices = [pp['B_idx'] for pp in selected_pps]

        def segment_sequence(solution, indices):
            segments = []
            last_idx = -1
            for idx in indices:
                segments.append(solution[last_idx+1 : idx+1])
                last_idx = idx
            segments.append(solution[last_idx+1:])
            return segments

        alice_segments = segment_sequence(alice_solution, alice_conflict_indices)
        bob_segments = segment_sequence(bob_solution, bob_conflict_indices)

        num_segments = k + 1
        for i in range(num_segments):
            if i < len(bob_segments) and bob_segments[i]:
                merged_sequence.extend(bob_segments[i])
            if i < len(alice_segments) and alice_segments[i]:
                merged_sequence.extend(alice_segments[i])

    else:


        alice_tasks = [deepcopy(x) for x in final_sequence]
        for task in alice_tasks: task['transaction']['from'] = alice_addr_str
        bob_tasks = [deepcopy(x) for x in final_sequence]
        for task in bob_tasks: task['transaction']['from'] = bob_addr_str

        while alice_tasks or bob_tasks:
            available_lists = [l for l in [alice_tasks, bob_tasks] if l]
            if not available_lists: break
            chosen_list = random.choice(available_lists)
            merged_sequence.append(chosen_list.pop(0))


    scenario_b_result = _run_scenario_b(
        env, alice_addr_str, bob_addr_str, merged_sequence,
        generator_function_maps, ideal_trajectory_map,
        initial_state_alice, initial_state_bob,
        state_A_alice, state_A_bob, contracts_to_check)
    if scenario_b_result["error"]:
        return 0.0
    flag = scenario_b_result["flag"]
    vulnerability_score = scenario_b_result["vulnerability_score"]
    state_B_alice = scenario_b_result["state_B_alice"]
    state_B_bob = scenario_b_result["state_B_bob"]
    candidate_schedule = scenario_b_result["candidate_schedule"]


    state_distance = _calculate_state_distance(initial_state_alice, state_A_alice)

    env.results['state_distance'] = state_distance
    env.results['state_deltas'] = _calculate_state_deltas(initial_state_alice, state_A_alice)


    if getattr(settings, "SHADOW_ECONOMIC_ORACLE", False):
        _shadow_economic_evaluation(
            env, indv, alice_addr_str, bob_addr_str,
            final_sequence, merged_sequence, candidate_schedule, vulnerability_score)

    if vulnerability_score > 0:
        print("\n" + "="*80)
        print(f"DEBUG: Analyzing Individual with hash: {indv.hash}")
        print(f"DEBUG: Initial States -> Alice: {initial_state_alice}, Bob: {initial_state_bob}")
        print(f"DEBUG: Scenario A Final States -> Alice: {state_A_alice}, Bob: {state_A_bob}")
        print(f"DEBUG: Scenario B Final States -> Alice: {state_B_alice}, Bob: {state_B_bob}")
        print(f"DEBUG: Vulnerability Score = {vulnerability_score}")

    if vulnerability_score > 0:
        env.results['vulnerability_score'] = vulnerability_score

        legacy_valuation_score = None
        if getattr(settings, "LEGACY_FIXED_VALUATION", False):
            legacy_valuation_score = _legacy_valuation_score(
                initial_state_alice, initial_state_bob,
                state_A_alice, state_A_bob, state_B_alice, state_B_bob,
            )

        _record_finding(
            env, indv, vulnerability_score,
            alice_addr_str, bob_addr_str,
            initial_state_alice, initial_state_bob,
            state_A_alice, state_A_bob, state_B_alice, state_B_bob,
            final_sequence, candidate_schedule,
            alice_rw_sets, bob_rw_sets,
            legacy_valuation_score=legacy_valuation_score,
        )

    return float(vulnerability_score)


def _collect_intent_token_ids(pipeline):

    token_ids = set()
    if pipeline is None:
        return []
    for observation in getattr(pipeline, "_seed_observations", []):
        for flow in getattr(observation, "flows", None) or []:
            asset_id = getattr(flow, "asset_id", None)
            if asset_id is None or asset_id[0] not in ("ERC721", "ERC1155"):
                continue
            if asset_id[2] is None:
                continue
            token_ids.add((asset_id[0], asset_id[1], int(asset_id[2])))
    return sorted(token_ids)


def _evaluate_seed_intent(env, pipeline, runner, user_txs, attacker_txs,
                          user_ids=None, attacker_ids=None):

    from fuzzer.txracer.oracles.intent import (
        IntentOracle,
        evm_intent_reader,
        identity_resolver,
    )
    chain_id = getattr(settings, "CHAIN_ID", 1)
    intent_adapters = getattr(settings, "INTENT_ADAPTERS", None)
    intent_oracle = IntentOracle(
        adapters=intent_adapters, chain_id=chain_id,
        block_profile={"evm_version": getattr(settings, "EVM_VERSION",
                                              None)})
    reader = evm_intent_reader(env.instrumented_evm)
    resolver = identity_resolver(
        dict(getattr(settings, "DEPLOYED_CONTRACT_ADDRESS", {})))
    token_ids = _collect_intent_token_ids(pipeline)
    intent_log = getattr(env, "intent_log", None)
    try:
        env.instrumented_evm.restore_from_snapshot()
        runner.execute_sequence(
            user_txs, tx_ids=user_ids
            or ["victim-%d" % i for i in range(len(user_txs))])
        baseline = intent_oracle.capture_baseline(
            reader, resolver,
            user_txs[0]["transaction"]["from"] if user_txs else None,
            attacker_txs[0]["transaction"]["from"] if attacker_txs else None,
            token_ids)
        env.instrumented_evm.restore_from_snapshot()
        runner.execute_sequence(
            attacker_txs, tx_ids=attacker_ids
            or ["attacker-%d" % i for i in range(len(attacker_txs))])
        user_addr = (user_txs[0]["transaction"]["from"]
                       if user_txs else None)
        attacker_addr = (attacker_txs[0]["transaction"]["from"]
                         if attacker_txs else None)
        result = intent_oracle.evaluate_candidate(
            baseline, reader, resolver, user_addr, attacker_addr,
            token_ids, schedule_identity=["seed", "victim-vs-attacker"])
        if intent_log is not None:
            record = {
                "schema_version": 1,
                "finding_type": "INTENT_ORACLE",
                "seed": getattr(env, "seed", None),
                "individual_hash": None,
                "scope": "seed_victim_vs_attacker",
                "note": "intent evidence only; never FRONT_RUNNING_PROFIT",
            }
            record.update(result.to_dict())
            intent_log.write_record(record)
    except Exception as intent_error:  # noqa: BLE001
        if intent_log is not None:
            intent_log.write_record({
                "schema_version": 1,
                "finding_type": "INTENT_ORACLE",
                "scope": "seed_victim_vs_attacker",
                "classification": "GENERIC_ORDER_DEPENDENCY",
                "failure": "internal_error",
                "detail": str(intent_error),
            })
