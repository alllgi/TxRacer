"""Canonical execution integration with the unchanged final-spec scheduler."""

from collections.abc import Mapping
from dataclasses import dataclass
from eth_utils import to_normalized_address

from fuzzer.txracer.interleaving.scheduler import (
    SchedulerConfig, generate_schedules,
)
from fuzzer.txracer.interleaving.rw_sets import _union_anchor_records
from fuzzer.txracer.interleaving.preemption import find_all_preemption_points
from fuzzer.txracer.oracles.front_running import FrontRunningOracle, OracleConfig
from fuzzer.txracer.pipeline.core.model import Sequence
from fuzzer.txracer.pipeline.core.memory import release_computations
from fuzzer.txracer.retention import EventHistory


class TransactionView(Mapping):

    def __init__(self, transaction):
        self.canonical = transaction

    def __iter__(self):
        return iter(("transaction",))

    def __len__(self):
        return 1

    def __getitem__(self, key):
        if key != "transaction":
            raise KeyError(key)
        tx = self.canonical
        return {"from": tx.sender, "to": tx.contract, "value": tx.value,
                "data": tx.calldata.hex(), "gaslimit": tx.gas}


@dataclass(frozen=True)
class OracleInput:
    execution: object
    user_addr: str
    attacker_addr: str

    @property
    def tx_results(self):
        return self.execution.records

    @property
    def assets(self):
        return {role: {asset: value for address, asset, value in self.execution.asset_balances if address == account}
                for role, account in (("user", self.user_addr), ("attacker", self.attacker_addr))}


def complete_asset_comparison(baseline, candidate, user, attacker):

    return baseline.assets_complete and candidate.assets_complete


def flipped_points(baseline, candidate, points, user_ids, attacker_ids):

    first = [r.tx_id for r in baseline.records]
    second = [r.tx_id for r in candidate.records]
    if len(first) != len(set(first)) or len(second) != len(set(second)) or set(first) != set(second):
        raise ValueError("Baseline/candidate execution identities differ")
    expected = set(user_ids) | set(attacker_ids)
    if set(first) != expected or set(user_ids) & set(attacker_ids):
        raise ValueError("Invalid role-qualified execution identities")
    first_index, second_index = {v: i for i, v in enumerate(first)}, {v: i for i, v in enumerate(second)}
    flipped = []
    for point in points:
        user, attacker = point.user_tx_id, point.attacker_tx_id
        if user not in user_ids or attacker not in attacker_ids or first_index[user] >= first_index[attacker]:
            raise ValueError("Invalid PP or UR baseline order")
        if second_index[attacker] < second_index[user]:
            flipped.append({"user_tx_id": user, "attacker_tx_id": attacker,
                            "baseline_user_position": first_index[user], "baseline_attacker_position": first_index[attacker],
                            "candidate_user_position": second_index[user], "candidate_attacker_position": second_index[attacker]})
    return flipped


class InteractionPipeline:
    def __init__(self, backend, user, attacker, scheduler_config=None, oracle_config=None):
        self.backend = backend
        self.user, self.attacker = to_normalized_address(user), to_normalized_address(attacker)
        self.scheduler_config = scheduler_config or SchedulerConfig()
        self.oracle = FrontRunningOracle(oracle_config or OracleConfig())
        self.events = EventHistory()

    def analyze(self, observation, candidate):
        user_sequence, attacker_sequence = observation.result.sequence, candidate.sequence
        baseline = observation.result.baseline
        if not 1 <= len(user_sequence) <= 20 or not 1 <= len(attacker_sequence) <= 25:
            self.events.append({"event": "pair_length_rejected", "candidate": candidate.candidate_id})
            return None
        senders = {"user": sorted({tx.sender for tx in user_sequence}),
                   "attacker": sorted({tx.sender for tx in attacker_sequence})}
        reason = None
        if self.user == self.attacker:
            reason = "role_addresses_overlap"
        elif any(len(addresses) > 1 for addresses in senders.values()):
            reason = "mixed_role_senders_unsupported"
        elif set(senders["user"]) & set(senders["attacker"]):
            reason = "role_addresses_overlap"
        elif senders["user"] != [self.user] or senders["attacker"] != [self.attacker]:
            reason = "role_sender_binding_mismatch"
        if reason:
            self.events.append({"event": reason, "candidate": candidate.candidate_id,
                                "expected_senders": {"user": self.user, "attacker": self.attacker},
                                "actual_senders": senders})
            return None
        user_ids = tuple("user-tx-%d" % i for i in range(len(user_sequence)))
        attacker_ids = candidate.transaction_ids
        ur_sequence = Sequence(tuple(user_sequence) + tuple(attacker_sequence))
        ru_sequence = Sequence(tuple(attacker_sequence) + tuple(user_sequence))
        ur = self.backend.execute_sequence(ur_sequence, baseline, user_ids + attacker_ids)
        release_computations(ur)
        ru = self.backend.execute_sequence(ru_sequence, baseline, attacker_ids + user_ids)
        release_computations(ru)
        if not ur.trustworthy or not ru.trustworthy:
            self.events.append({"event": "untrustworthy_anchor", "candidate": candidate.candidate_id})
            return None
        split_user, split_attacker = len(user_sequence), len(attacker_sequence)
        predicate = lambda key: key in observation.economic_states
        user_rw = _union_anchor_records(ur.records[:split_user], ru.records[split_attacker:], predicate)
        attacker_rw = _union_anchor_records(ur.records[split_user:], ru.records[:split_attacker], predicate)
        points = find_all_preemption_points(user_rw, attacker_rw)
        schedules = generate_schedules([TransactionView(t) for t in user_sequence],
                                      [TransactionView(t) for t in attacker_sequence], points,
                                      config=self.scheduler_config, user_ids=user_ids, attacker_ids=attacker_ids,
                                      economic_state_snapshot=observation.economic_states,
                                      anchor_results={"UR": ur, "RU": ru})
        by_id = dict(zip(user_ids + attacker_ids, tuple(user_sequence) + tuple(attacker_sequence)))
        outcomes, unsupported = [], []
        for schedule in schedules.schedules:
            if schedule.cached_result is not None:
                result = schedule.cached_result
            else:
                ids = tuple(item[1] for item in schedule.order_key)


                sequence = Sequence(tuple(by_id[tx_id] for tx_id in ids))
                if tuple(view.canonical for view in schedule.tx_inputs) != sequence.transactions:
                    raise ValueError("Schedule view differs from canonical transaction identities")
                result = self.backend.execute_sequence(sequence, baseline, ids)
                release_computations(result)
            if not result.trustworthy:
                self.events.append({"event": "untrustworthy_schedule", "candidate": candidate.candidate_id})
                continue
            flipped = flipped_points(ur, result, points, user_ids, attacker_ids)
            if not complete_asset_comparison(ur, result, self.user, self.attacker):
                diagnostic = {"event": "oracle_unsupported", "status": "unsupported",
                              "reason": "incomplete_asset_observation", "candidate": candidate.candidate_id,
                              "schedule_order": schedule.order_key,
                              "baseline_failures": [vars(item) for item in ur.asset_observation_failures],
                              "candidate_failures": [vars(item) for item in result.asset_observation_failures]}
                self.events.append(diagnostic)
                unsupported.append((schedule, result, diagnostic))
                continue
            oracle = self.oracle.evaluate(OracleInput(ur, self.user, self.attacker),
                                          OracleInput(result, self.user, self.attacker),
                                          reversed_preemption_pairs=flipped, interaction_gate=True,
                                          paper_design_version="v2")
            outcomes.append((schedule, result, oracle))
            self.events.append({"event": "oracle_evaluated", "candidate": candidate.candidate_id,
                                "anchor_reused": schedule.cached_result is not None,
                                "depth": schedule.interaction_depth, "flipped_points": len(flipped),
                                "confirmed": bool(oracle.confirmed_assets)})
        summary = {"candidate": candidate, "anchors": (ur, ru), "points": points,
                   "schedules": schedules, "outcomes": outcomes, "unsupported_comparisons": unsupported}
        self.events.append({"event": "pair_analyzed", "candidate": candidate.candidate_id,
                            "preemption_points": len(points), "schedules": len(schedules.schedules),
                            "oracle_evaluations": len(outcomes)})
        return summary
