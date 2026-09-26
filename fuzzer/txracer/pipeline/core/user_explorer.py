"""Standalone corpus loop."""

from collections import deque
from dataclasses import dataclass
from fractions import Fraction
import random

from fuzzer.txracer.pipeline.core.corpus import CoverageCorpus, EconomicCorpus, CorpusScheduler
from fuzzer.txracer.pipeline.core.economic_feedback import EconomicFeedback
from fuzzer.txracer.pipeline.core.mutation import InputMutator, SequenceMutator
from fuzzer.txracer.pipeline.core.parameter_solver import ParameterSolver
from fuzzer.txracer.pipeline.core.diagnostics import exception_summary, execution_summary
from fuzzer.txracer.pipeline.core.diagnostics import is_memory_error
from fuzzer.txracer.pipeline.core.memory import MemoryConfig, release_computations
from fuzzer.txracer.retention import History, EventHistory


@dataclass(frozen=True)
class ExplorerConfig:
    seed: int = 1
    max_length: int = 20
    pm: float = 0.1
    sequence_probability: float = 0.5
    economic_probability: str = "1/2"
    max_value: int = 10 ** 18
    solve: bool = True
    mutate_sender: bool = False
    mutate_environment: bool = False

    def __post_init__(self):
        if not 1 <= self.max_length <= 20 or not 0 <= self.sequence_probability <= 1:
            raise ValueError("Invalid User exploration bounds")


class UserExplorer:
    def __init__(self, backend, baseline, catalog, user, accounts, config=None, memory_config=None):
        self.backend, self.baseline, self.catalog = backend, baseline, catalog
        self.user, self.accounts = user, tuple(accounts)
        self.config = config or ExplorerConfig()
        self.memory_config = memory_config or MemoryConfig()
        self.rng = random.Random(self.config.seed)
        self.coverage, self.economic = CoverageCorpus(), EconomicCorpus()
        self.feedback = EconomicFeedback(self.memory_config)
        self.scheduler = CorpusScheduler(self.coverage, self.economic, self.rng,
                                         Fraction(self.config.economic_probability))
        self.input_mutator = InputMutator(catalog, accounts, self.rng, self.config.pm,
                                         self.config.mutate_sender, self.config.mutate_environment, self.config.max_value)
        self.sequence_mutator = SequenceMutator(self.rng, self._new_transaction, self.config.max_length)
        self.solver = ParameterSolver(accounts, self.config.max_value,
                                      mutate_sender=self.config.mutate_sender,
                                      value_candidates=catalog.input_templates.values if catalog.input_templates else None) if self.config.solve else None
        if self.solver:
            self.solver.diagnostics = History(self.memory_config.events)
        self.scheduler.choices = History(self.memory_config.events)
        self.pending, self.queued, self.executed = deque(), set(), set()
        self.observations = History(self.memory_config.observations)
        self.events = EventHistory(self.memory_config.events)
        self.observation_count = 0
        self.on_observation = None
        self.failure = None

    def _new_transaction(self):
        function = self.rng.choice(self.catalog.initial_functions)
        return self.catalog.transaction(function, self.user, self.accounts, self.rng)

    def enqueue(self, sequence, source, baseline=None):
        baseline = baseline or self.baseline
        if not 1 <= len(sequence) <= self.config.max_length:
            self.events.append({"event": "rejected_length", "source": source})
            return False
        key = (baseline, sequence.identity)
        if key in self.queued or key in self.executed:
            if self.catalog.input_templates:
                self.catalog.input_templates.note_generated(sequence, False)
            self.events.append({"event": "duplicate", "sequence": sequence.identity, "source": source})
            return False
        self.pending.append((sequence, baseline, source))
        self.queued.add(key)
        if self.catalog.input_templates:
            self.catalog.input_templates.note_generated(sequence, True)
        return True

    def initialize(self, preparation=()):
        for sequence in self.catalog.initial_sequences(self.user, self.accounts, preparation, self.config.max_length):
            self.enqueue(sequence, "initial")

        initial_count = len(self.pending)
        for _ in range(initial_count):
            self.execute_next()

    def execute_next(self):
        if not self.pending:
            return None
        sequence, baseline, source = self.pending.popleft()
        key = (baseline, sequence.identity)
        self.queued.remove(key)
        result, stage = None, "backend"
        try:
            result = self.backend.execute_sequence(sequence, baseline)
            self.executed.add(key)
            stage = "economic_feedback"
            observation = self.feedback.observe(result)
            stage = "coverage_admission"
            admitted = self.coverage.admit(result, source, initial=source == "initial")
            stage = "economic_admission"
            economic = self.economic.admit(result, observation.economic_states, source)
            self.observation_count += 1
            self.observations.append(observation)
            if self.catalog.input_templates:
                for record in result.records:
                    if record.status == "SUCCESS":
                        self.catalog.input_templates.add(record.transaction, "successful_user_seed", True)
            self.events.append({"event": "executed", "source": source, "sequence": sequence.identity,
                                "coverage_admission": admitted is not None, "economic_admissions": len(economic),
                                "statuses": [r.status for r in result.records]})
            stage = "smt"
            if self.solver:
                for assignment in self.solver.candidates(result):
                    self.enqueue(assignment.sequence, "smt", baseline)
            stage = "observation_callback"
            if self.on_observation is not None:
                self.on_observation(observation)
            return observation
        except Exception as error:
            if is_memory_error(error):
                self.failure = {"stage": stage, "resource_error": True,
                                "exception": {"type": "MemoryError", "message": "allocation failed"}}
                raise
            self.failure = {"sequence": sequence.to_dict(), "sequence_id": sequence.identity,
                            "baseline": vars(baseline), "source": source, "stage": stage,
                            "exception": exception_summary(error), "execution": execution_summary(result)}
            raise
        finally:
            release_computations(result)

    def summary(self):
        return {"events": self.events, "pending": len(self.pending),
                "backend_completed": len(self.executed), "observations_completed": self.observation_count,
                "history_retention": self.observations.retention(),
                "event_retention": self.events.retention(), "event_counts": dict(self.events.counts),
                "failure": self.failure,
                "pending_user_queue": [{"sequence": sequence.to_dict(), "baseline": vars(baseline), "source": source}
                                       for sequence, baseline, source in self.pending],
                "coverage_seeds": len(self.coverage.seeds),
                "economic_representatives": len(self.economic.representatives()),
                "asset_observation_failures": [
                    {"sequence_id": seen.result.sequence.identity,
                     "failures": [vars(item) for item in seen.result.asset_observation_failures]}
                    for seen in self.observations if seen.result.asset_observation_failures],
                "solver_diagnostics": self.solver.diagnostics if self.solver else []}

    def step(self):
        if self.pending:
            return self.execute_next()
        seed = self.scheduler.select()
        if seed is None:
            return None
        mutation = self.input_mutator.mutate(seed.sequence)
        candidate = mutation.sequence
        operator = "input"
        if self.rng.random() < self.config.sequence_probability:
            mutation = self.sequence_mutator.mutate(candidate)
            candidate, operator = mutation.sequence, "input+" + mutation.operator
        if candidate.identity == seed.sequence.identity:
            self.events.append({"event": "mutation_noop", "operator": operator})
            return None
        if self.enqueue(candidate, operator, seed.baseline):
            return self.execute_next()
        return None

    def run(self, iterations):
        for _ in range(iterations):
            self.step()
        return self.observations
