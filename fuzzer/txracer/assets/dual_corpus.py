from fractions import Fraction
from typing import Dict, List, Optional


class DualCorpusController(object):
    def __init__(self, state_corpus_probability=Fraction(1, 2),
                 coverage_stagnation_generations=10, rng=None):
        if isinstance(state_corpus_probability, str):
            state_corpus_probability = Fraction(state_corpus_probability)
        if not (0 <= state_corpus_probability <= 1):
            raise ValueError(
                "state corpus probability must be within [0, 1], got %r"
                % state_corpus_probability)
        if isinstance(coverage_stagnation_generations, bool) or \
                not isinstance(coverage_stagnation_generations, int) or \
                coverage_stagnation_generations <= 0:
            raise ValueError(
                "coverage stagnation generations must be a positive "
                "integer, got %r" % coverage_stagnation_generations)
        self.state_corpus_probability = state_corpus_probability
        self.coverage_stagnation_generations = coverage_stagnation_generations
        self.rng = rng
        self._side_round_robin = 0
        self._coverage_stagnation = 0
        self._asset_stagnation = 0
        self._rebuild_requested = False
        self.generation_stats = []
        self.seed_choices = []

    def _draw(self):
        if self.rng is None:
            import random
            return random.randrange(self.state_corpus_probability.denominator)
        return self.rng.randrange(self.state_corpus_probability.denominator)

    def choose_seed(self, state_seeds, coverage_pool=None, generation=None):

        state_seeds = list(state_seeds or [])
        coverage_pool = list(coverage_pool or [])
        side, seed = self._choose(state_seeds, coverage_pool)
        record = {
            "generation": generation,
            "side": side,
            "seed_hash": seed.get("seed_hash") if isinstance(seed, dict)
            else None,
            "state_size": len(state_seeds),
            "coverage_size": len(coverage_pool),
        }
        self.seed_choices.append(record)
        return side, seed

    def _choose(self, state_seeds, coverage_pool):
        if not state_seeds and not coverage_pool:
            return "empty", None
        if state_seeds and not coverage_pool:
            return "state", self._pick_state_seed(state_seeds)
        if coverage_pool and not state_seeds:
            return "coverage", self._pick_coverage_seed(coverage_pool)
        if self._draw() < self.state_corpus_probability.numerator:
            return "state", self._pick_state_seed(state_seeds)
        return "coverage", self._pick_coverage_seed(coverage_pool)

    def _pick_state_seed(self, state_seeds):

        ordered = sorted(state_seeds, key=lambda seed: (
            seed.get("slot", ["", 0])[0], seed.get("slot", ["", 0])[1],
            seed.get("side", ""), seed.get("seed_hash", "")))
        if not ordered:
            return None
        index = self._side_round_robin % len(ordered)
        self._side_round_robin += 1
        return ordered[index]

    def _pick_coverage_seed(self, coverage_pool):
        ordered = sorted(coverage_pool, key=str)
        return ordered[self._side_round_robin % len(ordered)] \
            if ordered else None


    def record_generation(self, generation, coverage_grew, asset_grew,
                          state_corpus_size=0, coverage_corpus_size=0,
                          state_selected=0, coverage_selected=0,
                          state_fallback=0, coverage_fallback=0,
                          new_slots=0, new_min=0, new_max=0,
                          replacements=0, rebuild=False, **extra):

        if coverage_grew:
            self._coverage_stagnation = 0
        else:
            self._coverage_stagnation += 1
        if asset_grew:
            self._asset_stagnation = 0
        else:
            self._asset_stagnation += 1
        if self._coverage_stagnation >= self.coverage_stagnation_generations:
            rebuild = True
            self._rebuild_requested = True
        stats = {
            "generation": generation,
            "coverage_grew": bool(coverage_grew),
            "asset_grew": bool(asset_grew),
            "coverage_stagnation": self._coverage_stagnation,
            "asset_stagnation": self._asset_stagnation,
            "rebuild": bool(rebuild),
            "state_corpus_size": int(state_corpus_size),
            "coverage_corpus_size": int(coverage_corpus_size),
            "state_selected": int(state_selected),
            "coverage_selected": int(coverage_selected),
            "state_fallback": int(state_fallback),
            "coverage_fallback": int(coverage_fallback),
            "new_slots": int(new_slots),
            "new_min": int(new_min),
            "new_max": int(new_max),
            "replacements": int(replacements),
        }
        stats.update(extra)
        self.generation_stats.append(stats)
        return stats

    @property
    def rebuild_requested(self):
        return self._rebuild_requested

    def drain_choices(self):

        choices = list(self.seed_choices)
        self.seed_choices = []
        return choices

    def mark_rebuild_done(self):

        self._rebuild_requested = False
        self._coverage_stagnation = 0

    def summarize(self):
        if not self.generation_stats:
            return {}
        latest = self.generation_stats[-1]
        return {
            "latest_generation": latest["generation"],
            "latest_rebuild": latest["rebuild"],
            "coverage_stagnation": latest["coverage_stagnation"],
            "asset_stagnation": latest["asset_stagnation"],
            "state_corpus_size": latest["state_corpus_size"],
            "coverage_corpus_size": latest["coverage_corpus_size"],
            "state_selected": latest["state_selected"],
            "coverage_selected": latest["coverage_selected"],
        }

    def to_dict(self):
        return {
            "state_corpus_probability": str(self.state_corpus_probability),
            "coverage_stagnation_generations":
                self.coverage_stagnation_generations,
            "generation_stats": self.generation_stats,
            "seed_choices": self.seed_choices,
        }

    @classmethod
    def from_dict(cls, payload):
        controller = cls(
            state_corpus_probability=Fraction(
                payload["state_corpus_probability"]),
            coverage_stagnation_generations=payload[
                "coverage_stagnation_generations"])
        controller.generation_stats = list(
            payload.get("generation_stats") or [])
        controller.seed_choices = list(payload.get("seed_choices") or [])
        return controller


__all__ = ["DualCorpusController"]
