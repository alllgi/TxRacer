import os
from copy import deepcopy
from fractions import Fraction

from fuzzer.txracer.assets.dual_corpus import DualCorpusController
from fuzzer.txracer.assets.flow_tracker import FlowCollector
from fuzzer.txracer.assets.state_corpus import StateCorpus
from fuzzer.txracer.assets.state_discovery import (
    BackwardDependencyAnalyzer,
    ValidationLedger,
    computation_storage_accesses,
    computation_storage_writes,
    link_flow_evidence,
)
from fuzzer.txracer.compat import legacy_keyword_aliases


class PrefilterDecision(object):
    def __init__(self, allowed, reasons):
        self.allowed = bool(allowed)
        self.reasons = list(reasons)

    def to_dict(self):
        return {"allowed": self.allowed, "reasons": self.reasons}


class SeedObservation(object):


    def __init__(self, role, sequence, tx_ids, records, flows,
                 evidence_count, fail_closed_reasons, diagnostics,
                 economic_state_snapshot=None):
        self.role = role
        self.sequence = list(sequence)
        self.tx_ids = list(tx_ids)
        self.records = list(records)
        self.flows = list(flows)
        self.evidence_count = evidence_count
        self.fail_closed_reasons = list(fail_closed_reasons)
        self.diagnostics = list(diagnostics)


        self.economic_state_snapshot = frozenset(
            economic_state_snapshot or ())

    def to_dict(self):
        return {
            "role": self.role,
            "tx_count": len(self.records),
            "flows": len(self.flows),
            "evidence_count": self.evidence_count,
            "fail_closed_reasons": self.fail_closed_reasons,
            "diagnostics": self.diagnostics,
        }


class StateFeedbackPipeline(object):
    def __init__(self, evm, chain_id=1, mode="legacy", seed=None,
                 static_index=None, standard_resolver=None,
                 asset_reader=None,
                 state_corpus_probability=Fraction(1, 2),
                 coverage_stagnation_generations=10, rng=None):
        self.evm = evm
        self.chain_id = int(chain_id)
        self.mode = mode
        self.seed = seed
        self.collector = FlowCollector(
            evm, chain_id=chain_id, standard_resolver=standard_resolver,
            mode=mode)
        self.analyzer = BackwardDependencyAnalyzer()
        self.ledger = ValidationLedger(static_index=static_index)
        self.corpus = StateCorpus()
        self.dual = DualCorpusController(
            state_corpus_probability=state_corpus_probability,
            coverage_stagnation_generations=coverage_stagnation_generations,
            rng=rng)
        self.asset_reader = asset_reader
        self.state_ref = None
        self.snapshot_ref = None
        self.diagnostic_log = []
        self._current_diagnostics = []
        self._current_fail_closed = []
        self._user_equity_snapshot = None
        self._user_equity_error = None
        self._post_values = {}
        self._writes_since_clean = []
        self._seed_observations = []
        self._generation = 0
        self._prev_coverage_count = None
        self._prev_boundary_count = 0
        self._boundary_updates = {"new_slots": 0, "replacements": 0}


    def observe_sequence(self, sequence, tx_ids, role, chromosome=None,
                         state_ref=None, snapshot_ref=None,
                         reset_diagnostics=True):

        if state_ref is not None:
            self.state_ref = state_ref
        if snapshot_ref is not None:
            self.snapshot_ref = snapshot_ref
        if reset_diagnostics:
            self._begin_seed_diagnostics()
        if tx_ids is None:
            tx_ids = ["trace-%d" % i for i in range(len(sequence))]
        self._capture_clean_values()
        records, computations, flows = self.collector.execute_sequence(
            list(sequence), tx_ids=list(tx_ids))
        sequence_hash = self._sequence_hash(sequence)
        evidence_count = 0
        for i, (record, computation) in enumerate(
                zip(records, computations)):
            if computation is None:
                continue
            evidences = link_flow_evidence(
                self.analyzer, computation, flows, record.tx_id)
            evidence_count += len(evidences)


            taint_clean = not bool(self.analyzer.limitations)
            reads, writes = computation_storage_accesses(computation)
            self.ledger.observe(
                tx_id=record.tx_id, sequence_hash=sequence_hash,
                state_ref=self.state_ref, reads=reads, writes=writes,
                evidences=evidences, taint_clean=taint_clean)


            writes, write_notes = computation_storage_writes(computation)
            for note in write_notes:
                self._current_diagnostics.append({
                    "kind": "sstore_extraction_limitation",
                    "detail": note,
                })
            if self._writes_since_clean is None:
                self._writes_since_clean = []
            for (address, slot, value) in writes:
                self._writes_since_clean.append(
                    (address, slot, value, record.tx_id))
        if role == "victim":


            self._user_equity_snapshot, self._user_equity_error = \
                self._capture_equity_snapshot(sequence)
        self._update_boundaries_for(sequence, tx_ids, role, chromosome)
        self._update_economic_ranges(sequence, tx_ids, role, chromosome)
        self._writes_since_clean = []
        self._clean_values = {}
        self._collect_fail_closed(flows)
        self._flush_diagnostics()
        observation = SeedObservation(
            role=role, sequence=sequence, tx_ids=tx_ids,
            records=records, flows=flows,
            evidence_count=evidence_count,
            fail_closed_reasons=list(self._current_fail_closed),
            diagnostics=list(self._current_diagnostics),
            economic_state_snapshot=(
                frozenset(self.discovered_economic_states)
                if role in ("user", "victim") else frozenset()),
        )
        self._seed_observations.append(observation)


        return observation

    @legacy_keyword_aliases(victim_txs='user_txs', victim_ids='user_ids', victim_chromosome='user_chromosome')
    def observe_seed(self, user_txs, attacker_txs, user_ids=None,
                     attacker_ids=None, user_chromosome=None,
                     attacker_chromosome=None, state_ref=None,
                     snapshot_ref=None):

        self._begin_seed_diagnostics()
        user_observation = self.observe_sequence(
            user_txs, user_ids, role="victim",
            chromosome=user_chromosome, state_ref=state_ref,
            snapshot_ref=snapshot_ref, reset_diagnostics=False)
        attacker_observation = self.observe_sequence(
            attacker_txs, attacker_ids, role="attacker",
            chromosome=attacker_chromosome, state_ref=state_ref,
            snapshot_ref=snapshot_ref, reset_diagnostics=False)
        return user_observation, attacker_observation

    def _begin_seed_diagnostics(self):
        self._current_diagnostics = []
        self._current_fail_closed = []

    def _flush_diagnostics(self):
        for diagnostic in self._current_diagnostics:
            self.diagnostic_log.append(diagnostic)

    def _collect_fail_closed(self, flows):
        for diagnostic in self.collector.diagnostics:
            self._current_diagnostics.append(diagnostic)
        for note in self.analyzer.limitations:
            self._current_diagnostics.append(
                {"kind": "taint_limitation", "detail": note})
        ambiguous = sum(1 for flow in flows if flow.ambiguous)
        if ambiguous:
            self._current_fail_closed.append(
                "ambiguous_flow:%d" % ambiguous)
        if self.analyzer.limitations:
            self._current_fail_closed.append(
                "taint_limitation:%d" % len(self.analyzer.limitations))
        for diagnostic in self.collector.diagnostics:
            if diagnostic.get("kind") in ("ambiguous_transfer",
                                          "malformed_transfer",
                                          "malformed_transfer_single",
                                          "malformed_transfer_batch"):
                self._current_fail_closed.append(diagnostic["kind"])
        self.collector.diagnostics = []
        self.analyzer.limitations = []

    def _sequence_hash(self, txs):
        import hashlib
        import json
        canonical = json.dumps(txs, sort_keys=True, default=str)
        return hashlib.sha256(canonical.encode("utf-8")).hexdigest()[:16]

    def _capture_clean_values(self):

        try:
            self.evm.restore_from_snapshot()
            self._clean_values = {}
            for key in list(self.validated_asset_slots):
                try:
                    self._clean_values[key] = self.evm.vm.state.get_storage(
                        self._to_canonical(key[0]), key[1])
                except Exception:
                    self._clean_values[key] = None
        except Exception:
            self._clean_values = {}

    def _update_boundaries_for(self, sequence, tx_ids, role, chromosome):

        post_values = {}
        for key in list(self.validated_asset_slots):
            try:
                post_values[key] = self.evm.vm.state.get_storage(
                    self._to_canonical(key[0]), key[1])
            except Exception as read_error:
                self._current_diagnostics.append({
                    "kind": "boundary_read_failed",
                    "slot": [key[0], key[1]],
                    "detail": str(read_error),
                })
        missing = [key for key in post_values
                   if key not in self._clean_values]
        if missing:
            try:
                self.evm.restore_from_snapshot()
                for key in missing:
                    try:
                        self._clean_values[key] = \
                            self.evm.vm.state.get_storage(
                                self._to_canonical(key[0]), key[1])
                    except Exception as read_error:
                        self._current_diagnostics.append({
                            "kind": "boundary_clean_read_failed",
                            "slot": [key[0], key[1]],
                            "detail": str(read_error),
                        })
            except Exception as restore_error:
                self._current_diagnostics.append({
                    "kind": "boundary_clean_restore_failed",
                    "detail": str(restore_error),
                })
        for key, value in post_values.items():
            self._post_values[key] = value
            outcome = self.corpus.observe(
                key, value, sequence=sequence,
                state_ref=self.state_ref or "unknown",
                snapshot_ref=self.snapshot_ref,
                role=role, chromosome=chromosome,
                evidence_ref="seed:%s" % role,
                initial_value=self._clean_values.get(key))
            if outcome == "first_observation":
                self._boundary_updates["new_slots"] += 1
            elif outcome.startswith("replaced"):
                self._boundary_updates["replacements"] += 1
        self.corpus.sync_validated(self.validated_asset_slots)

    def _update_economic_ranges(self, sequence, tx_ids, role,
                                 chromosome):

        from collections import defaultdict
        state_writes = defaultdict(list)
        for (address, slot, value, tx_id) in self._writes_since_clean or []:
            state_writes[(address, slot)].append((value, tx_id))
        for key in self.discovered_economic_states:
            written = state_writes.get(key, [])
            if not written:
                self._current_diagnostics.append({
                    "kind": "economic_range_empty",
                    "slot": [key[0], key[1]],
                })
                continue
            values = [value for value, _tx_id in written]
            self.corpus.observe_range(
                key, values, sequence=sequence,
                state_ref=self.state_ref or "unknown",
                snapshot_ref=self.snapshot_ref,
                role=role, chromosome=chromosome,
                evidence_ref="range:%s" % role,
                initial_value=None)

    def _to_canonical(self, address):
        from eth_utils import to_canonical_address
        return to_canonical_address(address)

    @property
    def validated_asset_slots(self):
        return self.ledger.validated_asset_slots

    @property
    def discovered_economic_states(self):

        return self.ledger.discovered_economic_states

    def economic_state_confidence(self, key):
        return self.ledger.economic_state_confidence(key)

    @property
    def fail_closed_reasons(self):
        return list(self._current_fail_closed)

    def asset_key_predicate(self):

        validated = set(self.validated_asset_slots)
        return lambda key: key in validated


    @legacy_keyword_aliases(
        victim_txs="user_txs",
        victim_records="user_records",
    )
    def prefilter(self, user_txs, user_records=None):

        reasons = []
        if self._current_fail_closed:
            reasons.extend(self._current_fail_closed)
            return PrefilterDecision(False, reasons)
        if not self.validated_asset_slots:
            reasons.append("no_validated_asset_slots")
            return PrefilterDecision(False, reasons)

        user_writes = set()
        if user_records is not None:
            for record in user_records:
                user_writes |= set(record.writes)
        user_validated_writes = [
            key for key in self.validated_asset_slots
            if key in user_writes
        ]
        if not user_validated_writes:
            reasons.append("no_validated_asset_writes")

        equity_ok, equity_reasons = self._user_has_asset_equity(user_txs)
        if not equity_ok:
            reasons.extend(equity_reasons)

        if not self._effective_change():
            reasons.append("no_effective_asset_change")

        return PrefilterDecision(not reasons, reasons)

    def _capture_equity_snapshot(self, sequence):

        from fuzzer.txracer.execution.scenario_runner import (
            default_asset_reader,
        )
        reader = self.asset_reader or default_asset_reader
        try:
            user_addr = None
            if sequence:
                user_addr = sequence[0]["transaction"].get("from")
            if user_addr is None:
                return None, None
            return reader(self.evm, self.chain_id, user_addr), None
        except Exception as read_error:
            return None, "asset_read_failed:%s" % read_error

    def _user_has_asset_equity(self, user_txs):

        reasons = []
        snapshot = self._user_equity_snapshot
        error = self._user_equity_error
        if snapshot is None and error is None:

            snapshot, error = self._capture_equity_snapshot(user_txs)
        if error:
            reasons.append(error)
            return False, reasons
        if snapshot is None:
            return False, ["victim_no_asset_equity"]
        found = False
        for key in self.validated_asset_slots:
            for asset_id in self.validated_asset_slots[key]:
                if asset_id[0] in ("ERC721", "ERC1155"):


                    reasons.append(
                        "unsupported_asset_equity:%s" % (asset_id[0],))
                    continue
                if asset_id in snapshot and snapshot[asset_id] > 0:
                    found = True
        if found:
            return True, []
        if not reasons:
            reasons.append("victim_no_asset_equity")
        return False, reasons

    def _effective_change(self):

        try:
            self.evm.restore_from_snapshot()
            for key in self.validated_asset_slots:
                clean = self.evm.vm.state.get_storage(
                    self._to_canonical(key[0]), key[1])
                post = self._post_values.get(key)
                if post is None:
                    self._current_diagnostics.append({
                        "kind": "effective_change_unverifiable",
                        "slot": [key[0], key[1]],
                    })
                    continue
                if post != clean:
                    return True
        except Exception as read_error:
            self._current_diagnostics.append({
                "kind": "effective_change_read_failed",
                "detail": str(read_error),
            })
            return False
        return False


    @legacy_keyword_aliases(
        victim_txs="user_txs",
        victim_records="user_records",
    )
    def user_priority(self, user_txs, user_records=None):

        reasons = []
        if self._current_fail_closed:
            return ((False, False, False, None), reasons, True)
        has_economic_write = False
        if user_records is not None:
            user_writes = set()
            for record in user_records:
                user_writes |= set(record.writes)
            has_economic_write = bool(
                self.discovered_economic_states & user_writes)
        equity_ok, equity_reasons = self._user_has_asset_equity(
            user_txs)
        if not equity_ok:
            reasons.extend(equity_reasons)
            if any(reason.startswith(("asset_read_failed", "unsupported"))
                   for reason in equity_reasons):

                return ((False, False, False, None), reasons, True)
        has_economic_change = self._effective_change()
        stable_sequence_id = self._sequence_hash(user_txs)
        priority = (has_economic_write, equity_ok,
                    has_economic_change, stable_sequence_id)
        return (priority, reasons, False)


    def finalize_generation(self, generation, new_coverage=None,
                            state_corpus_pool=None, coverage_pool=None,
                            state_selected=0, coverage_selected=0,
                            state_fallback=0, coverage_fallback=0,
                            choices=None):
        self._generation = generation
        grew = False
        if new_coverage is not None:
            grew = self._prev_coverage_count is not None and \
                new_coverage > self._prev_coverage_count
            self._prev_coverage_count = new_coverage
        boundary_count = len(self.corpus.boundaries)
        asset_grew = boundary_count > self._prev_boundary_count
        self._prev_boundary_count = boundary_count
        stats = self.dual.record_generation(
            generation=generation,
            coverage_grew=grew,
            asset_grew=asset_grew,
            state_corpus_size=len(self.corpus.state_corpus),
            coverage_corpus_size=len(coverage_pool or []),
            state_selected=state_selected,
            coverage_selected=coverage_selected,
            state_fallback=state_fallback,
            coverage_fallback=coverage_fallback,
            new_slots=self._boundary_updates["new_slots"],
            replacements=self._boundary_updates["replacements"],
            choices=list(choices or []),
        )
        self._boundary_updates = {"new_slots": 0, "replacements": 0}
        return stats

    def state_corpus_seeds(self):

        seen = set()
        seeds = []
        for seed in self.corpus.state_corpus.values():
            key = seed["seed_hash"]
            if key in seen:
                continue
            seen.add(key)
            seeds.append(seed)
        return seeds


    def summary_dict(self):
        return {
            "mode": self.mode,
            "chain_id": self.chain_id,
            "seed": self.seed,
            "state_ref": self.state_ref,
            "snapshot_ref": self.snapshot_ref,
            "validated_asset_slots": {
                "%s:%d" % (key[0], key[1]):
                    sorted(assets)
                for key, assets in sorted(
                    self.validated_asset_slots.items())
            },
            "corpus": self.corpus.stats(),
            "dual_corpus": self.dual.summarize(),
            "diagnostics": self.diagnostic_log[-20:],
        }

    def to_dict(self):
        return {
            "mode": self.mode,
            "chain_id": self.chain_id,
            "seed": self.seed,
            "state_ref": self.state_ref,
            "snapshot_ref": self.snapshot_ref,
            "ledger": self.ledger.to_dict(),
            "corpus": self.corpus.to_dict(),
            "dual_corpus": self.dual.to_dict(),
            "diagnostics": self.diagnostic_log,
        }


StateFeedbackPipeline.victim_priority = StateFeedbackPipeline.user_priority


__all__ = ["PrefilterDecision", "SeedObservation", "StateFeedbackPipeline"]
