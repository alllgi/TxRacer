import hashlib
import json
import os
import random
import subprocess
import sys
from copy import deepcopy

from fuzzer.txracer.planner.sequence_planner import (
    normalize_sequence_template,
)

DEFAULT_STAGNATION_GENERATIONS = 3
DEFAULT_MAX_ROUNDS = 4
DEFAULT_CANDIDATES_PER_TRIGGER = 4

COVERAGE_STAGNATION = "coverage_stagnation"
ASSET_STAGNATION = "asset_stagnation"
DEPENDENCY_FAILURE = "dependency_failure"


class EvolutionMetrics(object):


    def __init__(self, coverage_count=0, boundary_count=0,
                 dependency_failed=False, run_ok=False):
        self.coverage_count = int(coverage_count)
        self.boundary_count = int(boundary_count)
        self.dependency_failed = bool(dependency_failed)
        self.run_ok = bool(run_ok)

    def to_dict(self):
        return {
            "coverage_count": self.coverage_count,
            "boundary_count": self.boundary_count,
            "dependency_failed": self.dependency_failed,
            "run_ok": self.run_ok,
        }


class StagnationTracker(object):


    def __init__(self, coverage_threshold=DEFAULT_STAGNATION_GENERATIONS,
                 asset_threshold=DEFAULT_STAGNATION_GENERATIONS):
        self.coverage_threshold = int(coverage_threshold)
        self.asset_threshold = int(asset_threshold)
        self._coverage_streak = 0
        self._asset_streak = 0
        self._prev_coverage = None
        self._prev_boundary = None
        self.history = []

    def update(self, metrics):

        triggers = []
        if metrics.dependency_failed:
            triggers.append({
                "kind": DEPENDENCY_FAILURE,
                "metric": "dependency",
                "value": True,
                "threshold": "any",
            })
            self._coverage_streak = 0
            self._asset_streak = 0
        if self._prev_coverage is None or metrics.coverage_count > self._prev_coverage:
            self._coverage_streak = 0
        else:
            self._coverage_streak += 1
        if self._prev_boundary is None or metrics.boundary_count > self._prev_boundary:
            self._asset_streak = 0
        else:
            self._asset_streak += 1
        if (self._coverage_streak >= self.coverage_threshold
                and not any(t["kind"] == COVERAGE_STAGNATION
                            for t in triggers)):
            triggers.append({
                "kind": COVERAGE_STAGNATION,
                "metric": "coverage_count",
                "value": metrics.coverage_count,
                "threshold": self.coverage_threshold,
            })
            self._coverage_streak = 0
        if (self._asset_streak >= self.asset_threshold
                and not any(t["kind"] == ASSET_STAGNATION
                            for t in triggers)):
            triggers.append({
                "kind": ASSET_STAGNATION,
                "metric": "boundary_count",
                "value": metrics.boundary_count,
                "threshold": self.asset_threshold,
            })
            self._asset_streak = 0
        self._prev_coverage = metrics.coverage_count
        self._prev_boundary = metrics.boundary_count
        record = {
            "metrics": metrics.to_dict(),
            "triggers": triggers,
        }
        self.history.append(record)
        return triggers


def _task_key(task):
    return (task.get("contract", ""), task.get("signature", ""))


def _task_pool(gene_pool, current):

    present = {_task_key(task) for task in current}
    pool = []
    for task in gene_pool or []:
        if _task_key(task) not in present:
            pool.append(task)
    return pool


def _dependency_insert(current, gene_pool, dependency_map):

    result = list(current)
    keys = {_task_key(task) for task in result}
    by_key = {_task_key(task): task for task in gene_pool or []}
    inserted = []
    for index, task in enumerate(list(result)):
        for dep_key in dependency_map.get(_task_key(task), []) or []:
            if dep_key in keys or dep_key in inserted:
                continue
            dependency = by_key.get(dep_key)
            if dependency is None:
                continue
            result.insert(index, deepcopy(dependency))
            inserted.append(dep_key)
            keys.add(dep_key)
    return result


def generate_outer_candidates(gene_pool, base_sequence, rng_seed,
                              count=DEFAULT_CANDIDATES_PER_TRIGGER,
                              dependency_map=None, max_length=12):

    rng = random.Random(rng_seed)
    candidates = []
    seen = set()
    base_keys = set((task.get("contract"), task.get("signature"))
                    for task in base_sequence)
    attempts = 0
    while len(candidates) < count and attempts < count * 8:
        attempts += 1
        candidate = deepcopy(base_sequence)
        operation = rng.choice(
            ["add", "delete", "swap", "repeat", "dependency"])
        if operation == "add":
            pool = _task_pool(gene_pool, candidate)
            if pool:
                task = rng.choice(pool)
                position = rng.randint(0, len(candidate))
                candidate.insert(position, deepcopy(task))
        elif operation == "delete" and len(candidate) > 1:
            candidate.pop(rng.randrange(len(candidate)))
        elif operation == "swap" and len(candidate) > 1:
            first, second = rng.sample(range(len(candidate)), 2)
            candidate[first], candidate[second] = (
                candidate[second], candidate[first])
        elif operation == "repeat" and candidate:
            ranked = sorted(
                candidate,
                key=lambda task: -float(task.get("score", 0.0)))
            top = ranked[:max(1, len(ranked) // 5)]
            task = deepcopy(rng.choice(top))
            candidate.insert(rng.randint(0, len(candidate)), task)
        elif operation == "dependency" and dependency_map:
            repaired = _dependency_insert(
                candidate, gene_pool, dependency_map)
            if len(repaired) != len(candidate):
                candidate = repaired
        if len(candidate) > max_length:

            continue
        if not candidate:
            continue
        candidate_keys = set(
            (task.get("contract"), task.get("signature"))
            for task in candidate)
        if not base_keys.issubset(candidate_keys):

            continue
        key = json.dumps(candidate, sort_keys=True)
        if key in seen:
            continue
        seen.add(key)
        candidates.append(candidate)
    return candidates


def select_best_candidate(candidates_and_metrics):

    def _key(entry):
        candidate, metrics = entry
        digest = hashlib.sha256(
            json.dumps(candidate, sort_keys=True).encode("utf-8")).hexdigest()
        return (
            -int(metrics.run_ok),
            -int(metrics.coverage_count),
            -int(metrics.boundary_count),
            digest,
        )

    ranked = sorted(candidates_and_metrics, key=_key)
    return ranked[0] if ranked else None


def parse_campaign_metrics(results_path, feedback_path, log_text,
                            run_ok=True, contract_name=None):

    coverage = 0.0
    try:
        if results_path and os.path.exists(results_path):
            with open(results_path, "r", encoding="utf-8") as handle:
                payload = json.load(handle)
            subtree = payload
            if contract_name and isinstance(payload, dict):
                subtree = payload.get(contract_name, payload)
            generations = subtree.get("generations") or []
            if generations:
                coverage = float(generations[-1].get("code_coverage", 0.0))
    except (OSError, ValueError, TypeError):
        coverage = 0.0
    boundaries = 0
    try:
        if feedback_path and os.path.exists(feedback_path):
            with open(feedback_path, "r", encoding="utf-8") as handle:
                payload = json.load(handle)
            corpus = payload.get("corpus") or {}
            boundaries = int(corpus.get("validated_slots")
                             or len(payload.get("validated_asset_slots", {})))
    except (OSError, ValueError, TypeError):
        boundaries = 0
    dependency_failed = False
    for marker in ("Could not find generator for",
                   "Could not find DEPLOYED address",
                   "deployment_dependency_unresolved",
                   "deployment_dependency_cycle"):
        if marker in (log_text or ""):
            dependency_failed = True
            break
    return EvolutionMetrics(
        coverage_count=coverage, boundary_count=boundaries,
        dependency_failed=dependency_failed, run_ok=run_ok)


class SubprocessCrossFuzzRunner(object):


    def __init__(self, sol_file, contract_name, solc_version, solc_path,
                 evm_version="byzantium", generations=2, population=4,
                 seed=1, workdir=None, fuzz_time_per_sequence=2,
                 txracer_flags=None, sequence_template_path=None):
        self.sol_file = sol_file
        self.contract_name = contract_name
        self.solc_version = solc_version
        self.solc_path = solc_path
        self.evm_version = evm_version
        self.generations = generations
        self.population = population
        self.seed = seed
        self.workdir = workdir
        self.fuzz_time_per_sequence = int(fuzz_time_per_sequence)

        self.campaign_timeout = self.fuzz_time_per_sequence
        self.txracer_flags = list(txracer_flags or [])
        self.sequence_template_path = sequence_template_path

        self.base_dir = os.path.dirname(os.path.dirname(
            os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

    def run_sequence(self, tasks, results_name, feedback_name):

        template_path = self.sequence_template_path
        temp_template = None
        if template_path is None:
            import tempfile
            handle = tempfile.NamedTemporaryFile(
                mode="w", suffix=".json", dir=self.workdir,
                delete=False, encoding="utf-8")
            json.dump(tasks, handle)
            handle.close()
            temp_template = handle.name
            template_path = temp_template
        results_path = os.path.join(self.workdir, results_name)
        feedback_path = os.path.join(self.workdir, feedback_name)
        findings_path = os.path.join(self.workdir, "findings.jsonl")
        for stale in (results_path, feedback_path, findings_path):
            try:
                if os.path.exists(stale):
                    os.remove(stale)
            except OSError:
                pass
        command = [
            sys.executable,
            os.path.join(self.base_dir, "fuzzer", "main.py"),
            "-s", self.sol_file,
            "-c", self.contract_name,
            "--solc", self.solc_version,
            "--evm", self.evm_version,
            "--solc-path-cross", self.solc_path,
            "--sequence-template", template_path,
            "-r", results_name,
            "--findings-log", findings_path,
        ]
        if self.campaign_timeout:
            command.extend(["-t", str(self.campaign_timeout)])
        else:
            command.extend(["-g", str(self.generations),
                            "-n", str(self.population)])
        command.extend(["--seed", str(self.seed)])
        command.extend(self.txracer_flags)
        try:
            process = subprocess.run(
                command, capture_output=True, text=True,
                cwd=self.workdir, timeout=600)
        except subprocess.TimeoutExpired:
            return EvolutionMetrics(run_ok=False)
        except OSError as spawn_error:
            return EvolutionMetrics(run_ok=False)
        finally:
            if temp_template is not None:
                try:
                    os.remove(temp_template)
                except OSError:
                    pass
        if process.returncode != 0:

            return EvolutionMetrics(run_ok=False)
        return parse_campaign_metrics(
            results_path, feedback_path,
            process.stdout + process.stderr,
            run_ok=True,
            contract_name=self.contract_name)


class OuterEvolutionController(object):


    def __init__(self, runner, gene_pool, base_sequence, seed=1,
                 coverage_threshold=DEFAULT_STAGNATION_GENERATIONS,
                 asset_threshold=DEFAULT_STAGNATION_GENERATIONS,
                 candidates_per_trigger=DEFAULT_CANDIDATES_PER_TRIGGER,
                 max_rounds=DEFAULT_MAX_ROUNDS,
                 dependency_map=None, max_length=12):
        self.runner = runner
        self.gene_pool = list(gene_pool or [])
        self.base_sequence = list(base_sequence)
        self.seed = int(seed)
        self.tracker = StagnationTracker(
            coverage_threshold=coverage_threshold,
            asset_threshold=asset_threshold)
        self.candidates_per_trigger = candidates_per_trigger
        self.max_rounds = max_rounds
        self.dependency_map = dict(dependency_map or {})
        self.max_length = max_length
        self.records = []
        self.current_sequence = list(base_sequence)
        self._round = 0

    def run(self):

        while self._round < self.max_rounds:
            self._round += 1
            results_name = "outer_results_%d.json" % self._round
            feedback_name = "asset_feedback_campaign.json"
            metrics = self.runner.run_sequence(
                self.current_sequence, results_name, feedback_name)
            record = {
                "round": self._round,
                "sequence": list(self.current_sequence),
                "metrics": metrics.to_dict(),
                "triggers": [],
                "candidates": [],
                "selected": None,
            }
            if not metrics.run_ok:
                record["run_failed"] = True
                record["note"] = ("campaign failed; no stagnation "
                                  "accumulated, no triggers, no stale "
                                  "artifacts read")
                self.records.append(record)
                continue
            triggers = self.tracker.update(metrics)
            record["triggers"] = list(triggers)
            if triggers:
                rng_seed = int(hashlib.sha256(
                    ("%d:%d:%s" % (self.seed, self._round,
                                   triggers[0]["kind"])).encode(
                        "utf-8")).hexdigest()[:12], 16)
                candidates = generate_outer_candidates(
                    self.gene_pool, self.current_sequence, rng_seed,
                    count=self.candidates_per_trigger,
                    dependency_map=self.dependency_map,
                    max_length=self.max_length)
                evaluated = []
                for index, candidate in enumerate(candidates):
                    candidate_metrics = self.runner.run_sequence(
                        candidate,
                        "outer_results_%d_%d.json" % (self._round, index),
                        feedback_name)
                    evaluated.append((candidate, candidate_metrics))
                    record["candidates"].append({
                        "index": index,
                        "sequence": list(candidate),
                        "metrics": candidate_metrics.to_dict(),
                    })
                selection = select_best_candidate(evaluated)
                if selection is not None:
                    best_candidate, best_metrics = selection
                    record["selected"] = {
                        "sequence": list(best_candidate),
                        "metrics": best_metrics.to_dict(),
                    }
                    if best_metrics.run_ok and (
                            best_metrics.coverage_count
                            > metrics.coverage_count
                            or best_metrics.boundary_count
                            > metrics.boundary_count):
                        self.current_sequence = list(best_candidate)
            self.records.append(record)
        return self.records

    def to_dict(self):
        return {
            "schema_version": 1,
            "enabled": True,
            "seed": self.seed,
            "coverage_threshold": self.tracker.coverage_threshold,
            "asset_threshold": self.tracker.asset_threshold,
            "candidates_per_trigger": self.candidates_per_trigger,
            "max_rounds": self.max_rounds,
            "rounds": self.records,
        }


def build_dependency_map(template):

    dependency_map = {}
    contracts = template.get("contracts") or {}
    candidates = template.get("candidate_functions") or []
    first_of = {}
    for candidate in candidates:
        first_of.setdefault(candidate["contract"], candidate["signature"])
    for candidate in candidates:
        key = (candidate["contract"], candidate["signature"])
        deps = []
        contract_info = contracts.get(candidate["contract"]) or {}
        for dep_contract in contract_info.get("dependencies") or []:
            dep_signature = first_of.get(dep_contract)
            if dep_signature:
                deps.append((dep_contract, dep_signature))
        dependency_map[key] = deps
    return dependency_map


def load_template_tasks(template_path):

    with open(template_path, "r", encoding="utf-8") as handle:
        payload = json.load(handle)
    if isinstance(payload, dict) and "sequence" in payload:
        sequence = normalize_sequence_template(payload)
        gene_pool = payload.get("candidate_functions") or []
        dependency_map = build_dependency_map(payload)
        limitations = list(payload.get("limitations") or [])
        return sequence, gene_pool, dependency_map, limitations
    return normalize_sequence_template(payload), list(payload), {}, []


__all__ = [
    "ASSET_STAGNATION",
    "COVERAGE_STAGNATION",
    "DEPENDENCY_FAILURE",
    "DEFAULT_CANDIDATES_PER_TRIGGER",
    "DEFAULT_MAX_ROUNDS",
    "DEFAULT_STAGNATION_GENERATIONS",
    "EvolutionMetrics",
    "OuterEvolutionController",
    "StagnationTracker",
    "SubprocessCrossFuzzRunner",
    "build_dependency_map",
    "generate_outer_candidates",
    "load_template_tasks",
    "parse_campaign_metrics",
    "select_best_candidate",
]
