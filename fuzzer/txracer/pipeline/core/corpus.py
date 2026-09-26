"""Coverage seeds and at most two economic boundary representatives per slot."""

from dataclasses import dataclass
from fractions import Fraction

from fuzzer.txracer.pipeline.core.model import Baseline, Sequence


@dataclass(frozen=True)
class Seed:
    sequence: Sequence
    baseline: Baseline
    reasons: tuple
    source: str

    @property
    def identity(self):
        return (self.baseline.name, self.baseline.fingerprint, self.sequence.identity)


class CoverageCorpus:
    def __init__(self):
        self.seeds, self.coverage, self.branches = {}, set(), set()

    def admit(self, result, source, initial=False):
        reasons = []
        if result.coverage - self.coverage:
            reasons.append("new_coverage")
        if result.branches - self.branches:
            reasons.append("new_branch_behavior")
        if initial:
            reasons.append("initial_callable_or_preparation")
        if not reasons or any(r.status in ("VALIDATION_ERROR", "FAILED") for r in result.records):
            return None
        self.coverage.update(result.coverage)
        self.branches.update(result.branches)
        seed = Seed(result.sequence, result.baseline, tuple(reasons), source)
        self.seeds.setdefault(seed.identity, seed)
        return self.seeds[seed.identity]


class EconomicCorpus:
    def __init__(self):
        self.boundaries = {}

    def admit(self, result, economic_states, source):
        changes, admissions = {}, []
        if any(r.status in ("VALIDATION_ERROR", "FAILED") for r in result.records):
            return admissions
        for record in result.records:
            for address, slot, value in record.storage_changes:
                if (address, slot) in economic_states:
                    changes.setdefault((address, slot), []).append(value)
        for key, values in sorted(changes.items()):
            bounds = self.boundaries.setdefault((result.baseline, key), {})
            for side, value in (("lower", min(values)), ("upper", max(values))):
                old = bounds.get(side)
                if old is None or side == "lower" and value < old[0] or side == "upper" and value > old[0]:
                    seed = Seed(result.sequence, result.baseline, ("economic_" + side, key, value), source)
                    bounds[side] = (value, seed)
                    admissions.append(seed)
        return admissions

    def representatives(self):
        return [bounds[side][1] for (_, key), bounds in sorted(
            self.boundaries.items(), key=lambda item: (item[0][0].name, item[0][1]))
                for side in sorted(bounds)]


class CorpusScheduler:
    def __init__(self, coverage, economic, rng, economic_probability=Fraction(1, 2)):
        self.coverage, self.economic, self.rng = coverage, economic, rng
        self.probability = Fraction(economic_probability)
        if not 0 <= self.probability <= 1:
            raise ValueError("Invalid economic corpus probability")
        self.cursors = {"coverage": 0, "economic": 0}
        self.choices = []

    def select(self):
        pools = {"coverage": sorted(self.coverage.seeds.values(), key=lambda seed: seed.identity),
                 "economic": self.economic.representatives()}
        if not any(pools.values()):
            return None
        if not pools["coverage"]:
            side = "economic"
        elif not pools["economic"]:
            side = "coverage"
        else:
            side = "economic" if self.rng.randrange(self.probability.denominator) < self.probability.numerator else "coverage"
        seed = pools[side][self.cursors[side] % len(pools[side])]
        self.cursors[side] += 1
        self.choices.append((side, seed.identity))
        return seed
