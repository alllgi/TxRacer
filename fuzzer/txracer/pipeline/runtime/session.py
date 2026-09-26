"""Initialize manifest contracts and isolate setup from search."""
from collections import Counter, defaultdict

from fuzzer.txracer.pipeline.core.abi import AbiCatalog
from fuzzer.txracer.pipeline.core.input_templates import InputTemplates
from fuzzer.txracer.pipeline.core.memory import release_computations
from fuzzer.txracer.pipeline.core.model import Sequence
from .state_isolation import isolated_state, verify_state


class ExecutionSession:
    def __init__(self, manifest, directory, solc=None, diagnostics=None):
        from fuzzer.txracer.pipeline.runner import setup_backend, canonical_sequence
        self.manifest = manifest
        self.diagnostics = diagnostics if diagnostics is not None else {}
        self.diagnostics.update(setup_success=False, state_restore_success=None,
                                evaluation_start_state_matches_setup=False,
                                generated_call_count=0, successfully_executed_call_count=0,
                                revert_count=0, structured_argument_template_used=0,
                                payable_value_candidate_used=0, evaluation_completed=False)
        self.phase = "deployment"
        self.phase_counts = defaultdict(Counter)
        self.apis = defaultdict(Counter)
        self.backend, self.deployed, self.metadata = setup_backend(manifest, directory, solc)
        self.catalog = AbiCatalog(self.metadata, **manifest.get("initial_abi_options", {}))

        # Setup may call dependencies excluded from the search catalog.
        self.setup_catalog = AbiCatalog([dict(c, in_scope=True) for c in self.metadata])
        options = manifest.get("input_construction", {})
        self.available_balances = {}
        self.templates = InputTemplates(lambda sender: self.available_balances[sender.lower()]) if options.get("mode") == "templates" else None
        if options.get("mode") not in (None, "templates"):
            raise ValueError("Unknown input construction mode")
        self.backend.transaction_observer = self.observe
        if "required_setup" in manifest and manifest.get("setup"):
            raise ValueError("Declare required_setup or legacy setup, never both")
        self.phase = "setup"
        self.setup = canonical_sequence(manifest.get("required_setup", manifest.get("setup", [])),
                                        self.setup_catalog, self.deployed)
        for index, tx in enumerate(self.setup):
            record = self.backend.execute_transaction(tx, "setup-%d" % index)
            object.__setattr__(record, "computation", None)
            if record.status != "SUCCESS":
                self.refresh()
                raise RuntimeError("Required setup failed: %s" % record.reason)
        self.diagnostics["setup_success"] = True
        self.baseline = self.backend.snapshot("post-setup")
        self.available_balances = {a["address"].lower(): self.backend.balance(a["address"]) for a in manifest["accounts"]}
        self.diagnostics["post_setup_fingerprint"] = self.baseline.fingerprint
        self.diagnostics["post_setup_native_balances"] = self.available_balances


        self.catalog.input_templates = self.templates
        if self.templates:
            self._collect_declared_examples(options)
        self.refresh()

    def observe(self, record):
        phase = self.phase
        if phase == "evaluation":
            phase = "user_search" if record.tx_id.startswith("tx-") else "comparison"
        counts = self.phase_counts[phase]
        counts["executed_call_count"] += 1
        counts["successfully_executed_call_count"] += int(record.status == "SUCCESS")
        counts["revert_count"] += int(record.status == "REVERT")
        counts["other_failure_count"] += int(record.status not in ("SUCCESS", "REVERT"))
        function = self.catalog.function_for(record.transaction)
        if function and phase in ("user_search", "comparison"):
            stats = self.apis[function.qualified_signature]
            stats["executed_call_count"] += 1
            stats["evm_trace_seen"] += int(bool(record.coverage))
            stats["successfully_executed_call_count"] += int(record.status == "SUCCESS")
            stats["revert_count"] += int(record.status == "REVERT")
        if self.templates and record.status == "SUCCESS" and phase in ("setup", "probe", "compatibility_validation"):
            self.templates.add(record.transaction, "%s:%s" % (phase, record.tx_id), True)

    def _collect_declared_examples(self, options):
        from fuzzer.txracer.pipeline.runner import canonical_sequence
        for index, entry in enumerate(options.get("templates", [])):
            tx = canonical_sequence([entry], self.setup_catalog, self.deployed)[0]
            self.templates.add(tx, "fixture_template:%d" % index)
        for index, chain in enumerate(self.manifest.get("sequences", [])):
            for tx in canonical_sequence(chain, self.setup_catalog, self.deployed):
                self.templates.add(tx, "existing_seed:%d" % index)
        for index, chain in enumerate(self.manifest.get("preparation", [])):
            entries = [dict(item, sender=item.get("sender", self.manifest["user"])) for item in chain]
            for tx in canonical_sequence(entries, self.setup_catalog, self.deployed):
                if tx.sender != self.manifest["user"].lower():
                    raise ValueError("Preparation must retain the fixed User sender")
                self.templates.add(tx, "existing_preparation_seed:%d" % index)


        for item in options.get("value_bindings", []):
            function = self.function(item["contract"], item["function"])
            if not function.payable:
                raise ValueError("Payment binding target must be payable")
            origin = item["source"]
            if origin["kind"] == "setup_argument":
                tx = self.setup[origin["call_index"]]
                value = tx.arguments[origin["argument_index"]]
            elif origin["kind"] == "constructor_argument":
                contract = next(c for c in self.metadata if c["name"] == origin["contract"])
                value = contract["constructor_arguments"][origin["argument_index"]]
            else:
                raise ValueError("Unknown payment configuration provenance")
            self.templates.add_value(function.key, value, "initialization_config:%r" % origin)

    def function(self, name, signature):
        matches = [f for f in self.setup_catalog.functions.values()
                   if f.contract_name == name and f.signature == signature]
        if len(matches) != 1:
            raise ValueError("Fixture function is unavailable or ambiguous: %s %s" % (name, signature))
        return matches[0]

    def run_auxiliary(self):
        from fuzzer.txracer.pipeline.runner import canonical_sequence
        for phase, field in (("probe", "probes"), ("compatibility_validation", "compatibility_validation")):
            self.phase = phase
            for index, chain in enumerate(self.manifest.get(field, [])):
                with isolated_state(self.backend, self.baseline, self.diagnostics, "%s:%d" % (phase, index)):
                    sequence = canonical_sequence(chain, self.setup_catalog, self.deployed)
                    result = self.backend.execute_sequence(sequence, self.baseline)
                    try:
                        if any(r.status != "SUCCESS" for r in result.records):
                            raise RuntimeError("%s call failed: %s" % (phase, [r.reason for r in result.records]))
                    finally:
                        release_computations(result)
        if self.templates:
            self.phase = "value_query"
            for item in self.manifest.get("input_construction", {}).get("value_queries", []):
                target = self.function(item["contract"], item["for_function"])
                query = self.function(item["contract"], item["function"])
                if not target.payable or not query.read_only or query.types:
                    raise ValueError("Value query must be a zero-argument view mapped to a payable API")
                abi = next(a for c in self.metadata if c["name"] == item["contract"] for a in c["abi"]
                           if a.get("name") == query.signature[:-2] and not a.get("inputs"))
                if len(abi.get("outputs", [])) != 1 or not abi["outputs"][0]["type"].startswith("uint"):
                    raise ValueError("Value query must return one raw unsigned integer")
                with isolated_state(self.backend, self.baseline, self.diagnostics, "value_query"):
                    tx = self.setup_catalog.transaction(query, self.manifest["user"], [a["address"] for a in self.manifest["accounts"]])
                    result = self.backend.execute_sequence(Sequence([tx]), self.baseline)
                    try:
                        record = result.records[0]
                        if record.status != "SUCCESS" or len(record.return_value) != 32:
                            raise RuntimeError("Payment query failed; cannot substitute zero")
                        value = int.from_bytes(record.return_value, "big")
                        self.templates.add_value(target.key, value, "post_setup_query:" + query.qualified_signature)
                        self.templates.queries.append(dict(query=query.qualified_signature, target=target.qualified_signature, value=value))
                    finally:
                        release_computations(result)
        self.restore("auxiliary_finished")

    def restore(self, phase):
        with isolated_state(self.backend, self.baseline, self.diagnostics, phase):
            pass

    def begin_evaluation(self):
        # Verify before restoring so unexpected writes remain visible.


        self.diagnostics["evaluation_start_fingerprint"] = verify_state(self.backend, self.baseline)
        self.diagnostics["evaluation_start_state_matches_setup"] = True
        self.phase = "evaluation"

    def refresh(self):
        total = Counter()
        for phase in ("user_search", "comparison"):
            total.update(self.phase_counts[phase])
        self.diagnostics.update(total)
        self.diagnostics["phase_counts"] = {k: dict(v) for k, v in self.phase_counts.items()}
        self.diagnostics["target_api_reached"] = [dict(api=f.qualified_signature, **dict(self.apis[f.qualified_signature]))
                                                   for f in self.catalog.initial_functions]
        self.diagnostics["target_api_reached_definition"] = "Per API: selected top-level calls, EVM trace observed, and successful calls; no claim of branch or vulnerability coverage. Setup/probes excluded."
        if self.templates:
            self.diagnostics["input_construction"] = self.templates.summary()
            for key in ("generated_call_count", "structured_argument_template_used", "payable_value_candidate_used"):
                self.diagnostics[key] = self.diagnostics["input_construction"].get(key, 0)
        return self.diagnostics
