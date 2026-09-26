"""Search attacker interleavings for smart-contract asset-security risks."""

from eth_utils import to_normalized_address

from fuzzer.txracer.interleaving.scheduler import SchedulerConfig
from fuzzer.txracer.oracles.front_running import OracleConfig
from fuzzer.txracer.pipeline.core.abi import build_value
from fuzzer.txracer.pipeline.core.attacker_inference import AttackerInference, InferenceConfig, InferenceContext
from fuzzer.txracer.pipeline.core.interaction import InteractionPipeline
from fuzzer.txracer.pipeline.core.user_explorer import UserExplorer
from fuzzer.txracer.pipeline.core.memory import MemoryConfig
from fuzzer.txracer.retention import History, EventHistory


def execution_evidence(execution):
    return {"baseline": vars(execution.baseline), "sequence": execution.sequence.to_dict(),
            "trustworthy": execution.trustworthy, "assets_complete": execution.assets_complete,
            "asset_balances": [{"address": address, "asset": asset, "raw_balance": value}
                               for address, asset, value in execution.asset_balances],
            "records": [{"tx_id": r.tx_id, "sender": r.sender, "status": r.status,
                         "reason": r.reason} for r in execution.records]}


class TxRacer:
    def __init__(self, backend, baseline, catalog, user, attacker, accounts,
                 planner_entries, explorer_config=None, inference_config=None,
                 scheduler_config=None, oracle_config=None, memory_config=None, evidence_sink=None):
        user, attacker = to_normalized_address(user), to_normalized_address(attacker)
        accounts = tuple(to_normalized_address(account) for account in accounts)
        if user == attacker:
            raise ValueError("role_addresses_overlap: User and Attacker must be distinct funded accounts")
        if explorer_config is not None and explorer_config.mutate_sender:
            raise ValueError("Fixed User/Attacker campaigns require mutate_sender=False")
        self.backend, self.baseline, self.catalog = backend, baseline, catalog
        self.user, self.attacker, self.accounts = user, attacker, tuple(accounts)
        self.memory_config = memory_config or MemoryConfig()
        self.evidence_sink = evidence_sink
        self.on_pair = None
        self.planner_functions = []
        self.diagnostics = History(self.memory_config.events)
        for entry in planner_entries:
            matches = [f for f in catalog.functions.values()
                       if f.contract_name == entry["contract"] and f.signature == entry["signature"]]
            if len(matches) != 1:
                self.diagnostics.append(("planner_entry_not_deployed_or_supported", entry["contract"], entry["signature"]))
                continue
            self.planner_functions.append(matches[0])
        self.planner_functions.sort(key=lambda f: f.qualified_signature)
        token_addresses = [f.contract for f in catalog.functions.values() if f.signature == "balanceOf(address)"]
        backend.configure_asset_queries((user, attacker), token_addresses)
        self.explorer = UserExplorer(backend, baseline, catalog, user, accounts, explorer_config, self.memory_config)
        self.inference = AttackerInference(inference_config or InferenceConfig())
        self.interaction = InteractionPipeline(backend, user, attacker,
                                               scheduler_config or SchedulerConfig(global_seed=self.explorer.config.seed),
                                               oracle_config or OracleConfig())
        self.inference.events = EventHistory(self.memory_config.events)
        self.interaction.events = EventHistory(self.memory_config.events)
        self.pairs = History(self.memory_config.pairs)
        self.findings = History(self.memory_config.findings)
        self.contexts = History(1)
        self.known_arguments = {}
        self.context = InferenceContext(self.catalog, self.user, self.attacker,
                                        0, self.planner_functions, self._arguments)
        self.context.diagnostics = History(self.memory_config.events)
        self.explorer.on_observation = self._after_user_execution

    def _arguments(self, function):
        return self.known_arguments.get(function.key, tuple(build_value(t, self.accounts) for t in function.types))

    def _after_user_execution(self, observation):


        for record in observation.result.records:
            if record.status == "SUCCESS":
                self.known_arguments[(record.transaction.contract, record.transaction.selector)] = record.transaction.arguments
        context = self.context
        context.attacker_balance = self.backend.balance(self.attacker)
        context.diagnostics.clear()
        context.observe(observation.result)
        candidates, truncated = self.inference.derive(observation, context)
        self.contexts.append(context)
        for candidate in candidates:
            result = self.interaction.analyze(observation, candidate)
            if result is not None:
                if self.on_pair is not None:
                    self.on_pair(observation, result)
                for schedule, execution, oracle in result["outcomes"]:
                    if oracle.confirmed_assets:
                        # Keep attack evidence within the authorized disclosure scope.
                        finding = {"tool": "TxRacer", "baseline": vars(observation.result.baseline),
                                   "kind": "finding", "review_status": "unreviewed",
                                   "addresses": {"user": self.user, "attacker": self.attacker},
                                   "effective_config": self.effective_config(),
                                   "user_sequence": observation.result.sequence.to_dict(),
                                   "attacker_sequence": candidate.sequence.to_dict(),
                                   "attacker_transaction_ids": candidate.transaction_ids,
                                   "candidate_id": candidate.candidate_id,
                                   "schedule_order": schedule.order_key,
                                   "executed_sequence": execution.sequence.to_dict(),
                                   "executed_transaction_ids": [record.tx_id for record in execution.records],
                                   "oracle": oracle.to_dict(),
                                   "replay": {"baseline_UR": execution_evidence(result["anchors"][0]),
                                              "candidate": execution_evidence(execution),
                                              "same_initial_state": execution.baseline == result["anchors"][0].baseline},
                                   "cost_basis": "raw asset units; existing gas exclusion; net real-world profit unverified"}
                        if self.evidence_sink is not None:
                            self.evidence_sink(finding)
                        self.findings.append(finding)
                self.pairs.append(result)
        self.diagnostics.extend(context.diagnostics)
        if truncated:
            self.diagnostics.append(("attacker_inference_budget", observation.result.sequence.identity))

    def run(self, iterations, preparation=()):
        self.explorer.initialize(preparation)
        self.explorer.run(iterations)
        return self

    def summary(self):
        def seed_record(seed):
            return {"sequence": seed.sequence.to_dict(), "sequence_id": seed.sequence.identity,
                    "baseline": vars(seed.baseline), "reasons": seed.reasons, "source": seed.source}

        return {"tool": "TxRacer", "user_events": self.explorer.events,
                "inference_events": self.inference.events, "interaction_events": self.interaction.events,
                "coverage_seeds": len(self.explorer.coverage.seeds),
                "economic_representatives": len(self.explorer.economic.representatives()),
                "coverage_corpus": [seed_record(seed) for seed in self.explorer.coverage.seeds.values()],
                "economic_corpus": [seed_record(seed) for seed in self.explorer.economic.representatives()],
                "pending_user_seeds": len(self.explorer.pending), "pairs": self.pairs.total,
                "findings": self.findings, "finding_count": self.findings.total,
                "memory": self.memory_summary(),
                "pending_user_queue": [{"sequence": sequence.to_dict(), "baseline": vars(baseline), "source": source}
                                       for sequence, baseline, source in self.explorer.pending],
                "diagnostics": self.diagnostics,
                "user_execution": self.explorer.summary(),
                "solver_diagnostics": self.explorer.solver.diagnostics if self.explorer.solver else [],
                "configuration": self.effective_config()}

    def effective_config(self):
        return {"explorer": vars(self.explorer.config), "inference": vars(self.inference.config),
                "scheduler": vars(self.interaction.scheduler_config),
                "oracle_threshold": self.interaction.oracle.config.ratio_str,
                "oracle": self.interaction.oracle.config.to_dict()}

    def memory_summary(self):
        ledger = self.explorer.feedback.ledger
        return {"configuration": vars(self.memory_config),
                "observations": self.explorer.observations.retention(), "pairs": self.pairs.retention(),
                "contexts": self.contexts.retention(), "findings": self.findings.retention(),
                "user_events": self.explorer.events.retention(),
                "inference_events": self.inference.events.retention(),
                "interaction_events": self.interaction.events.retention(),
                "validation_log": ledger.validation_log.retention(),
                "evidence_log": ledger._evidence_log.retention(),
                "ledger_contexts": len(ledger._ctx_txs),
                "deduplicated_user_executions": len(self.explorer.executed),
                "confirmed_directions": len(self.context.confirmed_directions),
                "evidence_stream_enabled": self.evidence_sink is not None}
