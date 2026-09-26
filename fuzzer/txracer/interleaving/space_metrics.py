from collections import Counter
from math import comb
from time import perf_counter


def choose(n, k):
    return comb(n, k) if 0 <= k <= n else 0


def depth_counts(user_segments, attacker_segments):

    counts = {}
    for depth in range(1, user_segments + attacker_segments):
        runs = depth + 1
        first, second = (runs + 1) // 2, runs // 2
        count = (choose(user_segments - 1, first - 1) * choose(attacker_segments - 1, second - 1)
                 + choose(user_segments - 1, second - 1) * choose(attacker_segments - 1, first - 1))
        if count:
            counts[str(depth)] = count
    return counts


class PhaseTimer:

    def __init__(self):
        self.seconds = {}
        self.name, self.started = None, None

    def phase(self, name):
        now = perf_counter()
        if self.name is not None:
            self.seconds[self.name] = self.seconds.get(self.name, 0.0) + now - self.started
        self.name, self.started = name, now

    def stop(self):
        self.phase(None)


def schedule_space(user_length, attacker_length, result, depth_bound):

    raw = comb(user_length + attacker_length, user_length)
    if result.skip_reasons and result.skip_reasons != ["no preemption points"]:
        return {"accounted": False, "raw": raw, "reason": result.skip_reasons}
    no_pp = not result.pp_detected
    u, r = len(result.user_segments), len(result.attacker_segments)
    distribution = depth_counts(u, r) if not no_pp else {}
    pp = comb(u + r, u) if not no_pp else 0
    effective_depth = max(2, depth_bound)
    bounded_distribution = {d: n for d, n in distribution.items() if int(d) <= effective_depth}
    bounded = sum(bounded_distribution.values())
    selected = result.unique
    shallow = sum(n for d, n in distribution.items() if int(d) <= 2)
    deep_before = bounded - shallow
    invalid = sum(not identity for identity in result.deep_proposal_identities)
    duplicate = result.deep_proposals - invalid - result.deep_count
    from fuzzer.txracer.interleaving.scheduler import B_DEEP, MAX_DEEP_PROPOSALS
    stops = []
    if result.deep_count >= B_DEEP:
        stops.append("unique_budget")
    if result.deep_proposals >= MAX_DEEP_PROPOSALS:
        stops.append("proposal_limit")
    if not result.feasible_depths:
        stops.append("no_feasible_deep_depth")
    metrics = {
        "accounted": True, "raw": raw, "pp_guided": pp, "depth_bounded": bounded,
        "selected": selected, "pp_gate_removed": raw if no_pp else 0,
        "segmentation_removed": 0 if no_pp else raw - pp,
        "depth_removed": pp - bounded, "sampling_budget_unselected": bounded - selected,
        "user_segments": u, "attacker_segments": r, "preemption_points": result.pp_detected,
        "configured_depth": depth_bound, "effective_depth": effective_depth,
        "pp_depth_distribution": distribution, "bounded_depth_distribution": bounded_distribution,
        "selected_depth_distribution": dict(sorted(Counter(str(s.interaction_depth) for s in result.schedules).items())),
        "cached_depth_distribution": dict(Counter(str(s.interaction_depth) for s in result.schedules if s.cached_result is not None)),
        "shallow_exhaustive": result.shallow_count, "deep_before": deep_before, "deep_after": result.deep_count,
        "deep_proposals": result.deep_proposals, "duplicate_proposals": duplicate, "invalid_proposals": invalid,
        "generated_unique_budget_rejected": 0,
        "exclusive_budget_removed": None,
        "scheduler_truncated_flag": result.truncated, "stop_reasons": stops,
        "cached_available": result.anchor_reuse_count,
        "fresh_executions_required": selected - result.anchor_reuse_count,
    }
    assert sum(distribution.values()) == pp
    assert result.shallow_count == shallow
    assert result.duplicate == duplicate
    assert result.deep_proposals == result.deep_count + duplicate + invalid
    assert 0 <= selected <= bounded <= pp <= raw
    assert selected == result.shallow_count + result.deep_count
    assert raw == metrics["pp_gate_removed"] + metrics["segmentation_removed"] + metrics["depth_removed"] + metrics["sampling_budget_unselected"] + selected
    return metrics
