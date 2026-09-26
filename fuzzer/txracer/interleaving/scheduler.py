import random
from dataclasses import dataclass

from eth_hash.auto import keccak

from fuzzer.txracer.compat import legacy_keyword_aliases
from fuzzer.txracer.interleaving.modes import (
    SUPPORTED_WEIGHT_MODES,
    WEIGHT_MODE_EXTENDED,
)


USER_MAX_TRANSACTIONS = 20
ATTACKER_MAX_TRANSACTIONS = 25
B_DEEP = 100
MAX_DEEP_PROPOSALS = 1000

USER_ROLE = "U"
ATTACKER_ROLE = "R"
USER_WIRE_ROLE = "v"
ATTACKER_WIRE_ROLE = "a"


USER_ROLE_BYTE = b"v"
ATTACKER_ROLE_BYTE = b"a"

PAIR_DOMAIN = b"TxRacerPairV1"
PROPOSAL_DOMAIN = b"TxRacerProposalV1"
RNG_DOMAIN = b"TxRacerRngV1"


@dataclass(frozen=True)
class SchedulerConfig:
    """Scheduler configuration with legacy constructor compatibility."""

    max_preemption_points: int = 2
    preemption_candidate_cap: int = 8
    max_schedules_per_seed: int = 128
    max_interaction_depth: int = None
    global_seed: int = 1

    def __post_init__(self):
        for name, value in (
            ("max_preemption_points", self.max_preemption_points),
            ("preemption_candidate_cap", self.preemption_candidate_cap),
            ("max_schedules_per_seed", self.max_schedules_per_seed),
        ):
            if isinstance(value, bool) or not isinstance(value, int) or value <= 0:
                raise ValueError(
                    "%s must be a positive integer, got %r" % (name, value))
        if self.max_interaction_depth is not None and (
                isinstance(self.max_interaction_depth, bool)
                or not isinstance(self.max_interaction_depth, int)
                or self.max_interaction_depth <= 0):
            raise ValueError(
                "max_interaction_depth must be a positive integer, got %r"
                % (self.max_interaction_depth,))
        if (isinstance(self.global_seed, bool)
                or not isinstance(self.global_seed, int)
                or self.global_seed < 0
                or self.global_seed >= 2 ** 256):
            raise ValueError(
                "global_seed must be a uint256 integer, got %r"
                % (self.global_seed,))

    @property
    def interaction_depth_bound(self):
        if self.max_interaction_depth is not None:
            return self.max_interaction_depth
        return self.max_preemption_points


class Segment(object):


    def __init__(self, role, segment_index, items, start, end,
                 conflict_keys, economic_state_snapshot):
        self.role = role
        self.segment_index = int(segment_index)
        self.items = tuple(items)
        self.start = int(start)
        self.end = int(end)
        self.conflict_keys = frozenset(conflict_keys)
        self.economic_keys = frozenset(
            self.conflict_keys & economic_state_snapshot)
        self.weight = 1 + len(self.economic_keys)

    @property
    def segment_id(self):
        return (self.role, self.segment_index)

    def __repr__(self):
        return "%s%d" % self.segment_id


class Schedule(object):


    def __init__(self, order_key, tx_inputs, source_combo,
                 weight_mode=WEIGHT_MODE_EXTENDED, extra=False,
                 canonical_id=None, segments=None, interaction_depth=None,
                 anchor=None, cached_result=None):
        self.order_key = tuple(order_key)
        self.tx_inputs = list(tx_inputs)
        self.weight_mode = weight_mode
        self.extra = bool(extra)
        self.source_combo = [
            point.to_dict(weight_mode=weight_mode) for point in source_combo
        ]
        self.source_combo_key = tuple(
            (point.user_idx, point.attacker_idx) for point in source_combo
        )
        self.segments = tuple(segments or ())
        self.canonical_id = tuple(
            canonical_id if canonical_id is not None else self.order_key)
        self.interaction_depth = (
            schedule_interaction_depth(self.segments)
            if interaction_depth is None and self.segments
            else interaction_depth
        )
        self.anchor = anchor
        self.cached_result = cached_result

    def to_dict(self):

        return {
            "order_key": [list(entry) for entry in self.order_key],
            "tx_inputs": self.tx_inputs,
            "source_combo": self.source_combo,
            "source_combo_key": [list(entry) for entry in self.source_combo_key],
            "weight_mode": self.weight_mode,
        }


class ScheduleSet(object):


    def __init__(self, schedules, truncated, pp_detected, pp_capped,
                 theoretical_combos, processed_combos, duplicate,
                 skip_reasons, user_segments=None, attacker_segments=None,
                 pair_id=None, economic_state_snapshot=None,
                 explored_schedules=None, deep_proposals=0,
                 deep_proposal_identities=None, shallow_count=0,
                 deep_count=0, feasible_depths=None, anchor_reuse_count=0):
        self.schedules = list(schedules)
        self.truncated = bool(truncated)
        self.pp_detected = pp_detected
        self.pp_capped = pp_capped
        self.theoretical_combos = theoretical_combos
        self.processed_combos = processed_combos
        self.duplicate = duplicate
        self.skip_reasons = list(skip_reasons)
        self.user_segments = tuple(user_segments or ())
        self.attacker_segments = tuple(attacker_segments or ())
        self.pair_id = pair_id
        self.economic_state_snapshot = frozenset(
            economic_state_snapshot or ())
        self.explored_schedules = frozenset(explored_schedules or ())
        self.deep_proposals = int(deep_proposals)
        self.deep_proposal_identities = tuple(
            deep_proposal_identities or ())
        self.shallow_count = int(shallow_count)
        self.deep_count = int(deep_count)
        self.feasible_depths = tuple(feasible_depths or ())
        self.anchor_reuse_count = int(anchor_reuse_count)

    @property
    def unique(self):
        return len(self.schedules)

    def to_dict(self):

        return {
            "unique": self.unique,
            "duplicate": self.duplicate,
            "truncated": self.truncated,
            "pp_detected": self.pp_detected,
            "pp_capped": self.pp_capped,
            "theoretical_combos": self.theoretical_combos,
            "processed_combos": self.processed_combos,
            "skip_reasons": self.skip_reasons,
        }


def sequence_pair_skip_reason(user_txs, attacker_txs):

    if not user_txs:
        return "user sequence empty"
    if not attacker_txs:
        return "attacker sequence empty"
    if len(user_txs) > USER_MAX_TRANSACTIONS:
        return "user sequence exceeds 20 transactions"
    if len(attacker_txs) > ATTACKER_MAX_TRANSACTIONS:
        return "attacker sequence exceeds 25 transactions"
    return None


def _uint32_be(value):
    if isinstance(value, bool) or not isinstance(value, int) \
            or value < 0 or value >= 2 ** 32:
        raise ValueError("value is not uint32: %r" % (value,))
    return value.to_bytes(4, "big")


def _uint256_be(value):
    if isinstance(value, bool) or not isinstance(value, int) \
            or value < 0 or value >= 2 ** 256:
        raise ValueError("value is not uint256: %r" % (value,))
    return value.to_bytes(32, "big")


def _address_bytes(value, field_name):
    if isinstance(value, bytes):
        raw = value
    elif isinstance(value, bytearray):
        raw = bytes(value)
    elif isinstance(value, str):
        encoded = value[2:] if value.startswith(("0x", "0X")) else value
        try:
            raw = bytes.fromhex(encoded)
        except ValueError:
            raise ValueError("%s is not a hex address" % field_name)
    else:
        raise ValueError("%s must be bytes or a hex string" % field_name)
    if len(raw) != 20:
        raise ValueError("%s must contain exactly 20 bytes" % field_name)
    return raw


def _calldata_bytes(value):
    if value is None:
        return b""
    if isinstance(value, bytes):
        return value
    if isinstance(value, bytearray):
        return bytes(value)
    if isinstance(value, str):
        encoded = value[2:] if value.startswith(("0x", "0X")) else value
        try:
            return bytes.fromhex(encoded)
        except ValueError:
            raise ValueError("calldata is not an even-length hex string")
    raise ValueError("calldata must be bytes or a hex string")


def canonical_transaction_bytes(tx_input):

    tx = tx_input.get("transaction", tx_input)
    sender = _address_bytes(tx.get("sender", tx.get("from")), "sender")
    target = _address_bytes(tx.get("target", tx.get("to")), "target")
    value = tx.get("value")
    if isinstance(value, str):
        try:
            value = int(value, 0)
        except ValueError:
            raise ValueError("value is not an integer")
    calldata = _calldata_bytes(tx.get("calldata", tx.get("data", b"")))
    return (
        sender
        + target
        + _uint256_be(value)
        + _uint32_be(len(calldata))
        + calldata
    )


def canonical_sequence_bytes(sequence):
    serialized = [_uint32_be(len(sequence))]
    serialized.extend(canonical_transaction_bytes(tx) for tx in sequence)
    return b"".join(serialized)


def canonical_pair_id(user_txs, attacker_txs):

    return keccak(
        PAIR_DOMAIN
        + canonical_sequence_bytes(user_txs)
        + canonical_sequence_bytes(attacker_txs)
    )


def proposal_seed(global_seed, pair_id, sample_idx):
    if not isinstance(pair_id, bytes) or len(pair_id) != 32:
        raise ValueError("pair_id must be exactly 32 bytes")
    return keccak(
        PROPOSAL_DOMAIN
        + _uint256_be(global_seed)
        + pair_id
        + _uint32_be(sample_idx)
    )


def partition_seed(global_seed, pair_id, depth, sample_idx, role):
    if not isinstance(pair_id, bytes) or len(pair_id) != 32:
        raise ValueError("pair_id must be exactly 32 bytes")
    if role == USER_ROLE:
        role_byte = USER_ROLE_BYTE
    elif role == ATTACKER_ROLE:
        role_byte = ATTACKER_ROLE_BYTE
    else:
        raise ValueError("unknown role: %r" % (role,))
    return keccak(
        RNG_DOMAIN
        + _uint256_be(global_seed)
        + pair_id
        + _uint32_be(depth)
        + _uint32_be(sample_idx)
        + role_byte
    )


def _rng(seed):
    return random.Random(int.from_bytes(seed, "big"))


def _tagged(sequence, wire_role, ids=None):
    if ids is None:
        ids = range(len(sequence))
    if len(ids) != len(sequence):
        raise ValueError(
            "stable id count %d does not match sequence length %d"
            % (len(ids), len(sequence)))
    return [
        (wire_role, tx_id, tx)
        for tx_id, tx in zip(ids, sequence)
    ]


def _segment_side(tagged, role, split_indices, preemption_points,
                  economic_state_snapshot):
    length = len(tagged)
    boundaries = sorted({index for index in split_indices
                         if 0 <= index < length})
    ranges = []
    start = 0
    for boundary in boundaries:
        if boundary > start:
            ranges.append((start, boundary))
        start = boundary
    if start < length:
        ranges.append((start, length))

    segments = []
    for segment_index, (start, end) in enumerate(ranges, 1):
        conflict_keys = set()
        for point in preemption_points:
            point_index = (
                point.user_idx if role == USER_ROLE else point.attacker_idx)
            if start <= point_index < end:
                conflict_keys |= set(point.conflict_keys)
        segments.append(Segment(
            role=role,
            segment_index=segment_index,
            items=tagged[start:end],
            start=start,
            end=end,
            conflict_keys=conflict_keys,
            economic_state_snapshot=economic_state_snapshot,
        ))
    return segments


def build_segments(user_txs, attacker_txs, preemption_points,
                   economic_state_snapshot=None, user_ids=None,
                   attacker_ids=None):

    snapshot = frozenset(economic_state_snapshot or ())
    user_tagged = _tagged(user_txs, USER_WIRE_ROLE, user_ids)
    attacker_tagged = _tagged(attacker_txs, ATTACKER_WIRE_ROLE, attacker_ids)
    for point in preemption_points:
        if not 0 <= point.user_idx < len(user_txs):
            raise ValueError(
                "preemption point user index out of range: %r"
                % (point.user_idx,))
        if not 0 <= point.attacker_idx < len(attacker_txs):
            raise ValueError(
                "preemption point attacker index out of range: %r"
                % (point.attacker_idx,))
    user_indices = {point.user_idx for point in preemption_points}
    attacker_indices = {point.attacker_idx for point in preemption_points}
    return (
        _segment_side(user_tagged, USER_ROLE, user_indices,
                      preemption_points, snapshot),
        _segment_side(attacker_tagged, ATTACKER_ROLE, attacker_indices,
                      preemption_points, snapshot),
    )


def schedule_interaction_depth(segment_schedule):

    depth = 0
    previous_role = None
    for X in segment_schedule:
        role = X.role if hasattr(X, "role") else X[0]
        if previous_role is not None and role != previous_role:
            depth += 1
        previous_role = role
    return depth


def feasible_starting_roles(depth, user_segment_count, attacker_segment_count):

    run_count = depth + 1
    user_runs_if_user_first = (run_count + 1) // 2
    attacker_runs_if_user_first = run_count // 2
    roles = []
    if (user_segment_count >= user_runs_if_user_first
            and attacker_segment_count >= attacker_runs_if_user_first):
        roles.append(USER_ROLE)
    if (user_segment_count >= attacker_runs_if_user_first
            and attacker_segment_count >= user_runs_if_user_first):
        roles.append(ATTACKER_ROLE)
    return tuple(roles)


def sample_weighted_boundaries(segments, run_count, rng):

    segment_count = len(segments)
    if run_count < 1 or run_count > segment_count:
        raise ValueError("run count is infeasible for the segment sequence")
    if run_count == 1:
        return ()
    boundaries = []
    previous = 0
    for selected_count in range(run_count - 1):
        minimum = previous + 1
        maximum = segment_count - (run_count - selected_count - 1)
        candidates = list(range(minimum, maximum + 1))
        weights = [segments[position].weight for position in candidates]
        total = sum(weights)
        draw = rng.randrange(total)
        cumulative = 0
        chosen = None
        for position, weight in zip(candidates, weights):
            cumulative += weight
            if draw < cumulative:
                chosen = position
                break
        boundaries.append(chosen)
        previous = chosen
    return tuple(boundaries)


def partition_segments(segments, run_count, rng):
    boundaries = sample_weighted_boundaries(segments, run_count, rng)
    runs = []
    start = 0
    for boundary in boundaries:
        runs.append(tuple(segments[start:boundary]))
        start = boundary
    runs.append(tuple(segments[start:]))
    return tuple(runs)


def _alternate_runs(user_runs, attacker_runs, starting_role):
    result = []
    user_index = 0
    attacker_index = 0
    role = starting_role
    while user_index < len(user_runs) or attacker_index < len(attacker_runs):
        if role == USER_ROLE:
            if user_index >= len(user_runs):
                return None
            result.extend(user_runs[user_index])
            user_index += 1
            role = ATTACKER_ROLE
        else:
            if attacker_index >= len(attacker_runs):
                return None
            result.extend(attacker_runs[attacker_index])
            attacker_index += 1
            role = USER_ROLE
    return tuple(result)


def _anchor_cached_result(anchor_results, anchor, canonical_id):
    if not anchor_results:
        return None
    if anchor in anchor_results:
        return anchor_results[anchor]
    return anchor_results.get(canonical_id)


def _schedule_from_segments(segment_schedule, preemption_points,
                            weight_mode, anchor=None, cached_result=None):
    items = [item for X in segment_schedule for item in X.items]
    canonical_id = tuple(X.segment_id for X in segment_schedule)
    return Schedule(
        order_key=[(wire_role, tx_id)
                   for wire_role, tx_id, _tx in items],
        tx_inputs=[tx for _wire_role, _tx_id, tx in items],
        source_combo=preemption_points,
        weight_mode=weight_mode,
        canonical_id=canonical_id,
        segments=segment_schedule,
        interaction_depth=schedule_interaction_depth(segment_schedule),
        anchor=anchor,
        cached_result=cached_result,
    )


@legacy_keyword_aliases(victim_txs='user_txs', victim_ids='user_ids')
def generate_extra_schedules(user_txs, attacker_txs, seed=1,
                             count=4, user_ids=None,
                             attacker_ids=None, weight_mode=None):

    rng = random.Random(seed)
    user_tagged = _tagged(user_txs, USER_WIRE_ROLE, user_ids)
    attacker_tagged = _tagged(attacker_txs, ATTACKER_WIRE_ROLE, attacker_ids)
    weight_mode = weight_mode or WEIGHT_MODE_EXTENDED
    schedules = []
    seen = set()
    attempts = 0
    while len(schedules) < max(1, int(count)) and attempts < count * 20:
        attempts += 1
        merged = []
        user_index = 0
        attacker_index = 0
        while user_index < len(user_tagged) or attacker_index < len(attacker_tagged):
            user_remaining = len(user_tagged) - user_index
            attacker_remaining = len(attacker_tagged) - attacker_index
            if user_remaining and attacker_remaining:
                take_user = rng.random() < (
                    user_remaining / (user_remaining + attacker_remaining))
            else:
                take_user = bool(user_remaining)
            if take_user:
                merged.append(user_tagged[user_index])
                user_index += 1
            else:
                merged.append(attacker_tagged[attacker_index])
                attacker_index += 1
        key = tuple((role, tx_id) for role, tx_id, _tx in merged)
        if key in seen:
            continue
        seen.add(key)
        schedules.append(Schedule(
            key, [tx for _role, _tx_id, tx in merged], [],
            weight_mode=weight_mode, extra=True))
    return schedules


@legacy_keyword_aliases(victim_txs='user_txs', victim_ids='user_ids')
def generate_schedules(user_txs, attacker_txs, preemption_points,
                       config=None, weight_mode=WEIGHT_MODE_EXTENDED,
                       user_ids=None, attacker_ids=None,
                       economic_state_snapshot=None, anchor_results=None,
                       statistics=None):

    if weight_mode not in SUPPORTED_WEIGHT_MODES:
        raise ValueError("unsupported weight mode: %r" % (weight_mode,))
    config = config if config is not None else SchedulerConfig()
    skip_reason = sequence_pair_skip_reason(user_txs, attacker_txs)
    if skip_reason is not None:
        return ScheduleSet(
            schedules=[], truncated=False, pp_detected=len(preemption_points),
            pp_capped=len(preemption_points), theoretical_combos=0,
            processed_combos=0, duplicate=0,
            skip_reasons=[skip_reason])
    if not preemption_points:
        return ScheduleSet(
            schedules=[], truncated=False, pp_detected=0, pp_capped=0,
            theoretical_combos=0, processed_combos=0, duplicate=0,
            skip_reasons=["no preemption points"])

    pair_id = canonical_pair_id(user_txs, attacker_txs)
    snapshot = frozenset(economic_state_snapshot or ())
    if statistics is not None:
        statistics.phase("segmentation")
    user_segments, attacker_segments = build_segments(
        user_txs, attacker_txs, preemption_points,
        economic_state_snapshot=snapshot,
        user_ids=user_ids, attacker_ids=attacker_ids)
    if statistics is not None:
        statistics.phase("pp_provenance")


    points = tuple(sorted(
        preemption_points,
        key=lambda point: (
            point.user_idx, point.attacker_idx, point.user_tx_id or "",
            point.attacker_tx_id or "", sorted(point.conflict_keys))))
    schedules = []
    explored_schedules = set()
    duplicate = 0
    anchor_reuse_count = 0

    def register(segment_schedule, anchor=None):
        nonlocal duplicate, anchor_reuse_count
        canonical_id = tuple(X.segment_id for X in segment_schedule)
        if canonical_id in explored_schedules:
            duplicate += 1
            return False
        explored_schedules.add(canonical_id)
        cached_result = _anchor_cached_result(
            anchor_results, anchor, canonical_id) if anchor else None
        if cached_result is not None:
            anchor_reuse_count += 1
        schedules.append(_schedule_from_segments(
            segment_schedule, points, weight_mode,
            anchor=anchor, cached_result=cached_result))
        return True


    if statistics is not None:
        statistics.phase("shallow_exhaustive")
    register(tuple(user_segments + attacker_segments), anchor="UR")
    register(tuple(attacker_segments + user_segments), anchor="RU")


    for boundary in range(1, len(user_segments)):
        register(tuple(
            user_segments[:boundary]
            + attacker_segments
            + user_segments[boundary:]))
    for boundary in range(1, len(attacker_segments)):
        register(tuple(
            attacker_segments[:boundary]
            + user_segments
            + attacker_segments[boundary:]))
    shallow_count = len(schedules)
    if statistics is not None:
        statistics.phase("deep_setup")

    feasible_by_depth = {
        depth: feasible_starting_roles(
            depth, len(user_segments), len(attacker_segments))
        for depth in range(3, config.interaction_depth_bound + 1)
    }
    feasible_by_depth = {
        depth: roles for depth, roles in feasible_by_depth.items() if roles
    }
    feasible_depths = tuple(sorted(feasible_by_depth))
    deep_proposal_identities = []
    deep_count = 0
    proposal_count = 0

    if statistics is not None:
        statistics.phase("deep_sampling")
    while (deep_count < B_DEEP
           and proposal_count < MAX_DEEP_PROPOSALS
           and feasible_depths):
        sample_idx = proposal_count
        proposal_count += 1
        proposal_rng = _rng(proposal_seed(
            config.global_seed, pair_id, sample_idx))
        depth = feasible_depths[proposal_rng.randrange(len(feasible_depths))]
        starting_roles = feasible_by_depth[depth]
        if len(starting_roles) == 1:
            starting_role = starting_roles[0]
        else:
            starting_role = starting_roles[proposal_rng.randrange(2)]

        run_count = depth + 1
        if starting_role == USER_ROLE:
            user_run_count = (run_count + 1) // 2
            attacker_run_count = run_count // 2
        else:
            user_run_count = run_count // 2
            attacker_run_count = (run_count + 1) // 2


        user_runs = partition_segments(
            user_segments, user_run_count,
            _rng(partition_seed(config.global_seed, pair_id, depth,
                                sample_idx, USER_ROLE)))
        attacker_runs = partition_segments(
            attacker_segments, attacker_run_count,
            _rng(partition_seed(config.global_seed, pair_id, depth,
                                sample_idx, ATTACKER_ROLE)))
        proposal = _alternate_runs(user_runs, attacker_runs, starting_role)
        if proposal is None or schedule_interaction_depth(proposal) != depth:
            deep_proposal_identities.append(())
            continue
        canonical_id = tuple(X.segment_id for X in proposal)
        deep_proposal_identities.append(canonical_id)
        before = len(schedules)
        register(proposal)
        if len(schedules) > before:
            deep_count += 1

    if statistics is not None:
        statistics.phase("finalize")
    truncated = bool(
        feasible_depths
        and deep_count < B_DEEP
        and proposal_count >= MAX_DEEP_PROPOSALS)
    return ScheduleSet(
        schedules=schedules,
        truncated=truncated,
        pp_detected=len(points),
        pp_capped=len(points),
        theoretical_combos=1,
        processed_combos=1,
        duplicate=duplicate,
        skip_reasons=[],
        user_segments=user_segments,
        attacker_segments=attacker_segments,
        pair_id=pair_id,
        economic_state_snapshot=snapshot,
        explored_schedules=explored_schedules,
        deep_proposals=proposal_count,
        deep_proposal_identities=deep_proposal_identities,
        shallow_count=shallow_count,
        deep_count=deep_count,
        feasible_depths=feasible_depths,
        anchor_reuse_count=anchor_reuse_count,
    )


__all__ = [
    "B_DEEP",
    "MAX_DEEP_PROPOSALS",
    "ATTACKER_MAX_TRANSACTIONS",
    "ATTACKER_ROLE",
    "ATTACKER_ROLE_BYTE",
    "Schedule",
    "ScheduleSet",
    "SchedulerConfig",
    "Segment",
    "USER_MAX_TRANSACTIONS",
    "USER_ROLE",
    "USER_ROLE_BYTE",
    "build_segments",
    "canonical_pair_id",
    "canonical_sequence_bytes",
    "canonical_transaction_bytes",
    "feasible_starting_roles",
    "generate_extra_schedules",
    "generate_schedules",
    "partition_seed",
    "partition_segments",
    "proposal_seed",
    "sample_weighted_boundaries",
    "schedule_interaction_depth",
    "sequence_pair_skip_reason",
]
