"""Observe amount-dependency semantics without another EVM run."""

from dataclasses import dataclass
from fuzzer.txracer.pipeline.core.memory import MemoryConfig

from fuzzer.txracer.assets.state_discovery import (
    BackwardDependencyAnalyzer, ValidationLedger, link_flow_evidence,
    computation_storage_accesses,
)


@dataclass(frozen=True)
class EconomicObservation:
    result: object
    economic_states: frozenset
    evidence_count: int
    diagnostics: tuple


class EconomicFeedback:
    def __init__(self, memory_config=None):
        memory_config = memory_config or MemoryConfig()
        self.ledger = ValidationLedger(validation_log_limit=memory_config.validation_log,
                                       evidence_log_limit=memory_config.evidence_log,
                                       incremental=True)

    def observe(self, result):
        count, diagnostics = 0, []
        for record in result.records:
            if record.computation is None:
                continue
            analyzer = BackwardDependencyAnalyzer()
            evidence = link_flow_evidence(analyzer, record.computation, record.asset_flows, record.tx_id)
            reads, writes = computation_storage_accesses(record.computation)
            self.ledger.observe(record.tx_id, result.sequence.identity,
                                result.baseline.name + ":" + result.baseline.fingerprint,
                                reads, writes, evidence, taint_clean=not analyzer.limitations)
            count += len(evidence)
            diagnostics.extend(analyzer.limitations)


        return EconomicObservation(result, frozenset(self.ledger.discovered_economic_states), count, tuple(diagnostics))
