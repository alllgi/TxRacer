import hashlib
import json
import sys

from fuzzer.txracer.compat import legacy_keyword_aliases


class StopOnFirstFinding(Exception):
    pass


def maybe_stop_on_finding(finding_id, enabled):

    if enabled:
        raise StopOnFirstFinding(finding_id)
    return None


def stable_finding_id(record_core):

    canonical = json.dumps(record_core, sort_keys=True, default=_json_default)
    return hashlib.sha256(canonical.encode("utf-8")).hexdigest()[:16]


def _json_default(value):
    if isinstance(value, (set, frozenset)):
        return sorted(value)
    if isinstance(value, bytes):
        return value.hex()
    raise TypeError("not JSON serializable: %r" % (value,))


class AppendingFindingLog(object):


    def __init__(self, path):
        self.path = path
        self._handle = None

    def _open(self):
        if self._handle is None:
            self._handle = open(self.path, "a", encoding="utf-8")
        return self._handle

    def write_record(self, record):
        try:
            payload = json.dumps(record, sort_keys=True, default=_json_default)
        except (TypeError, ValueError) as serialization_error:
            print(
                "[!] Finding log serialization failed for %s: %s"
                % (self.path, serialization_error),
                file=sys.stderr,
            )
            return False
        try:
            handle = self._open()
        except (OSError, ValueError) as io_error:
            print(
                "[!] Finding log open failed for %s: %s" % (self.path, io_error),
                file=sys.stderr,
            )
            return False
        try:
            handle.write(payload + "\n")
            handle.flush()
            return True
        except OSError as io_error:
            print(
                "[!] Finding log write failed for %s: %s" % (self.path, io_error),
                file=sys.stderr,
            )
            return False

    def close(self):
        if self._handle is not None:
            try:
                self._handle.close()
            except OSError as io_error:
                print(
                    "[!] Finding log close failed for %s: %s" % (self.path, io_error),
                    file=sys.stderr,
                )
            self._handle = None


def compute_asset_deltas(baseline_state, candidate_state):

    baseline_assets = baseline_state.get("assets", {}) if isinstance(baseline_state, dict) else {}
    candidate_assets = candidate_state.get("assets", {}) if isinstance(candidate_state, dict) else {}
    keys = sorted(set(baseline_assets) | set(candidate_assets))
    return {
        key: candidate_assets.get(key, 0) - baseline_assets.get(key, 0)
        for key in keys
    }


@legacy_keyword_aliases(victim='user')
def build_finding_record(*, mode, execution_backend, seed, user, attacker,
                         baseline_schedule, candidate_schedule, states,
                         rw_sets, vulnerability_score, threshold,
                         asset_map_info, reproduction_command,
                         legacy_valuation_score=None,
                         schema_version=1):

    asset_map = asset_map_info.to_dict() if asset_map_info is not None else {
        "path": None,
        "provided": False,
        "loaded": False,
        "sha256": None,
        "slot_count": 0,
        "diagnostics": [],
    }
    core = {
        "schema_version": schema_version,
        "mode": mode,
        "execution_backend": execution_backend,
        "seed": seed,
        "accounts": {"victim": user, "attacker": attacker},
        "baseline_schedule": baseline_schedule,
        "candidate_schedule": candidate_schedule,
        "states": states,
        "rw_sets": rw_sets,
        "vulnerability_score": vulnerability_score,
        "threshold": threshold,
        "asset_map": asset_map,
        "reproduction_command": reproduction_command,
    }
    asset_deltas = {}
    if isinstance(states, dict):
        scenario_a = states.get("scenario_a") or {}
        scenario_b = states.get("scenario_b") or {}
        asset_deltas = {
            "victim": compute_asset_deltas(
                scenario_a.get("victim"), scenario_b.get("victim")),
            "attacker": compute_asset_deltas(
                scenario_a.get("attacker"), scenario_b.get("attacker")),
        }
    core["asset_deltas"] = asset_deltas
    if legacy_valuation_score is not None:


        core["legacy_valuation"] = {
            "enabled": True,
            "value_score": legacy_valuation_score,
            "marked_legacy": True,
            "note": "fixed-weight valuation display only; never used for default finding confirmation",
        }
    core["finding_id"] = stable_finding_id(core)
    return core


@legacy_keyword_aliases(victim='user', victim_sequence='user_sequence')
def build_schedule_finding(*, mode, chain_id, seed, execution_backend, profile,
                           user, attacker,
                           user_sequence, attacker_sequence_original,
                           attacker_removed_calls, attacker_sequence_pruned,
                           preemption_pairs, selected_preemption_points,
                           weight_mode, candidate_cap,
                           baseline, candidate, planned_candidate,
                           oracle_result, schedule_order_key, schedule_stats,
                           reproduction_command, diagnostic_refs,
                           asset_prefilter_status, schema_version=2,
                           extra_schedule=False,
                           target_source_hash=None, target_contract=None,
                           target_contract_address=None,
                           paper_design_version="v1",
                           attacker_candidate_id=None,
                           attacker_operator_chain=None,
                           reversed_preemption_pairs=None,
                           economic_state_keys=None,
                           eta=None):

    core = {
        "schema_version": schema_version,
        "finding_type": "FRONT_RUNNING_PROFIT",
        "mode": mode,
        "chain_id": chain_id,
        "seed": seed,
        "execution_backend": execution_backend,
        "profile": dict(profile or {}),
        "accounts": {"victim": user, "attacker": attacker},
        "victim_sequence": list(user_sequence),
        "attacker_sequence_original": list(attacker_sequence_original),
        "attacker_removed_calls": list(attacker_removed_calls),
        "attacker_sequence_pruned": list(attacker_sequence_pruned),
        "preemption_pairs": list(preemption_pairs),
        "selected_preemption_points": list(selected_preemption_points),
        "preemption_weight_mode": weight_mode,
        "preemption_candidate_cap": candidate_cap,
        "baseline_schedule": baseline.to_dict(),
        "planned_candidate": list(planned_candidate),
        "executed_candidate": candidate.to_dict(),
        "oracle": oracle_result.to_dict(),
        "schedule_order_key": [list(entry) for entry in schedule_order_key],
        "schedule_stats": dict(schedule_stats or {}),
        "reproduction_command": reproduction_command,
        "diagnostic_refs": list(diagnostic_refs or []),
        "asset_prefilter_status": asset_prefilter_status,
        "extra_schedule": bool(extra_schedule),
    }
    core["finding_id"] = stable_finding_id(core)


    if target_source_hash or target_contract:
        core["target"] = {
            "source_hash": target_source_hash,
            "contract": target_contract,
            "contract_addresses": (
                {target_contract: target_contract_address}
                if target_contract and target_contract_address else {}),
        }


    core["paper_design_version"] = paper_design_version
    if attacker_candidate_id is not None:
        core["attacker_candidate_id"] = attacker_candidate_id
    if attacker_operator_chain is not None:
        core["attacker_operator_chain"] = list(attacker_operator_chain)
    core["baseline_order"] = _order_key_list(baseline)
    core["candidate_order"] = _order_key_list(candidate)

    core["preemption_pairs"] = list(preemption_pairs)
    id_pairs = []
    for point in preemption_pairs:
        if isinstance(point, dict):
            a_id = point.get("a_tx_id")
            b_id = point.get("b_tx_id")
        else:
            a_id = getattr(point, "a_tx_id", None)
            b_id = getattr(point, "b_tx_id", None)
        if a_id is not None and b_id is not None:
            id_pairs.append({"victim_tx_id": a_id,
                             "attacker_tx_id": b_id})
    if id_pairs:
        core["preemption_pair_ids"] = id_pairs
    core["reversed_preemption_pairs"] = list(
        reversed_preemption_pairs or [])
    core["economic_state_keys"] = [
        [key[0], key[1]] for key in sorted(economic_state_keys or [])
    ]
    core["eta"] = oracle_result.threshold_ratio if eta is None else str(eta)
    return core


def _order_key_list(result):

    records = getattr(result, "tx_results", None) or []
    return [
        [getattr(record, "sender", None),
         getattr(record, "tx_id", "tx-%d" % index)]
        for index, record in enumerate(records)
    ]


def attach_finding_status(record, persisted=False, persistence_error=None,
                          stop_reason=None):

    record["persisted"] = bool(persisted)
    if persistence_error:
        record["persistence_error"] = persistence_error
    if stop_reason:
        record["stop_reason"] = stop_reason
    return record


def build_scheduler_outcome(*, outcome, seed, mode, chain_id,
                            individual_hash=None, weight_mode=None,
                            reason=None, removed_call_count=None,
                            pp_detected=None, schema_version=2):

    core = {
        "schema_version": schema_version,
        "type": "scheduler_outcome",
        "outcome": outcome,
        "seed": seed,
        "mode": mode,
        "chain_id": chain_id,
        "individual_hash": individual_hash,
        "weight_mode": weight_mode,
        "reason": reason,
        "removed_call_count": removed_call_count,
        "pp_detected": pp_detected,
    }
    core["outcome_id"] = stable_finding_id(core)
    return core


__all__ = [
    "AppendingFindingLog",
    "StopOnFirstFinding",
    "attach_finding_status",
    "build_finding_record",
    "build_schedule_finding",
    "build_scheduler_outcome",
    "compute_asset_deltas",
    "maybe_stop_on_finding",
    "stable_finding_id",
]
