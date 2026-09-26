"""Run authorized attacker simulations against an isolated local EVM."""

import argparse
import json
from pathlib import Path
import subprocess

from eth_abi import encode_abi

from fuzzer.txracer.pipeline.backend.legacy_evm import LegacyExecutionBackend
from fuzzer.txracer.pipeline.core.model import Sequence, Transaction, Environment, from_json_value
from fuzzer.txracer.pipeline.core.abi import AbiCatalog, abi_type
from fuzzer.txracer.pipeline.core.user_explorer import UserExplorer, ExplorerConfig
from fuzzer.txracer.pipeline.core.campaign import TxRacer
from fuzzer.txracer.pipeline.core.attacker_inference import InferenceConfig
from fuzzer.txracer.interleaving.scheduler import SchedulerConfig
from fuzzer.txracer.oracles.front_running import OracleConfig
from fuzzer.txracer.pipeline.core.diagnostics import CampaignAborted, exception_summary
from fuzzer.txracer.pipeline.core.diagnostics import is_memory_error
from fuzzer.txracer.pipeline.core.memory import MemoryConfig, release_computations


def compile_source(source, solc):
    """Use the existing Solidity compiler toolchain; no downloads or RPC."""
    result = subprocess.run([solc, "--combined-json", "abi,bin", str(source)],
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                            universal_newlines=True, check=True)
    return json.loads(result.stdout)["contracts"]


def setup_backend(manifest, directory=Path("."), solc=None, computation_observer=None):
    backend = LegacyExecutionBackend(vm_name=manifest.get("vm", "byzantium"))
    if computation_observer is not None:
        state = backend._runtime.vm.state
        apply_transaction = state.apply_transaction
        def observed_apply(transaction):
            computation = apply_transaction(transaction)
            computation_observer(computation, state)
            return computation
        state.apply_transaction = observed_apply
    for account in manifest["accounts"]:
        backend.fund(account["address"], account["balance"])
    deployed, metadata, compiled = {}, [], {}
    for contract in manifest.get("contracts", []):
        abi, bytecode = contract.get("abi", []), contract.get("bytecode")
        if contract.get("created_by"):
            raise ValueError("Factory deployment recipes are not supported; provide directly deployable contracts")
        if bytecode is None:
            if not solc:
                raise ValueError("Source deployment requires explicit --solc")
            source = str((directory / contract["source"]).resolve())
            if source not in compiled:
                compiled[source] = compile_source(source, solc)
            matches = [v for k, v in compiled[source].items() if k.endswith(":" + contract.get("artifact", contract["name"]))]
            if len(matches) != 1 or not matches[0]["bin"]:
                raise ValueError("Expected one deployable contract artifact")
            bytecode = matches[0]["bin"]
            abi = json.loads(matches[0]["abi"]) if isinstance(matches[0]["abi"], str) else matches[0]["abi"]
        if contract.get("link_references"):
            from fuzzer.txracer.pipeline.runtime.linking import link_template
            bytecode = link_template(bytecode, contract["link_references"], contract.get("library_bindings", {}), deployed)
        constructor = next((item for item in abi if item.get("type") == "constructor"), {})
        arguments = from_json_value(contract.get("constructor_arguments", []))

        def resolve(value):
            if isinstance(value, dict):
                raise ValueError("Constructor arguments require literal ABI values or @contract references")
            if isinstance(value, tuple):
                return tuple(resolve(item) for item in value)
            return deployed[value[1:]] if isinstance(value, str) and value.startswith("@") else value

        bytecode += encode_abi([abi_type(item) for item in constructor.get("inputs", [])], resolve(arguments)).hex()
        address = backend.deploy(contract["sender"], bytecode, contract.get("value", 0),
                                 gas=contract.get("deployment_gas", 8000000))
        deployed[contract["name"]] = address
        metadata.append(dict(contract, abi=abi, address=address))
    return backend, deployed, metadata


def canonical_sequence(data, catalog, deployed):
    def resolve(value):
        if isinstance(value, (list, tuple)):
            return tuple(resolve(item) for item in value)
        if isinstance(value, dict):
            return {key: resolve(item) for key, item in value.items()}
        return deployed[value[1:]] if isinstance(value, str) and value.startswith("@") else value

    txs = []
    for entry in data:
        target = deployed.get(entry["contract"], entry["contract"])
        fields = dict(entry, contract=target, arguments=resolve(from_json_value(entry.get("arguments", []))))
        if "function" in fields:
            signature = fields.pop("function")
            matches = [f for f in catalog.functions.values() if f.contract == target and f.signature == signature]
            if len(matches) != 1:
                raise ValueError("Unknown function on deployed instance: %s %s" % (target, signature))
            fields["selector"] = matches[0].selector
            fields["argument_types"] = matches[0].types
            from fuzzer.txracer.pipeline.core.input_templates import normalize_arguments
            fields["arguments"] = normalize_arguments(catalog.argument_schemas[matches[0].key], fields["arguments"])
        fields["environment"] = Environment(**fields.get("environment", {}))
        txs.append(Transaction(**fields))
    return Sequence(txs)


def run_manifest(manifest, directory=Path("."), solc=None, iterations=0, evidence_sink=None):
    if iterations < 0:
        raise ValueError("iterations must be nonnegative")
    progress = {"stage": "setup", "results": []}
    try:
        return _run_manifest(manifest, directory, solc, iterations, progress, evidence_sink)
    except Exception as error:
        if is_memory_error(error):
            raise CampaignAborted({"tool": "TxRacer", "status": "resource_error", "stage": progress["stage"],
                                   "exception": exception_summary(error)}) from error
        summary = {"tool": "TxRacer", "status": "aborted", "stage": progress["stage"],
                   "exception": exception_summary(error), "results": progress["results"],
                   "deployed": progress.get("deployed", {}), "baseline": progress.get("baseline"),
                   "setup_diagnostics": progress.get("setup_diagnostics", {})}
        if "campaign" in progress:
            summary["exploration"] = progress["campaign"].summary()
        elif "explorer" in progress:
            summary["exploration"] = progress["explorer"].summary()
        raise CampaignAborted(summary) from error


def _run_manifest(manifest, directory, solc, iterations, progress, evidence_sink=None):
    from fuzzer.txracer.pipeline.runtime.session import ExecutionSession
    diagnostics = progress.setdefault("setup_diagnostics", {})
    session = ExecutionSession(manifest, directory, solc, diagnostics)
    try:
        session.run_auxiliary()
        result = _run_session(manifest, directory, iterations, progress, session, evidence_sink)
        diagnostics["evaluation_completed"] = True
        return result
    finally:
        try:
            session.restore("evaluation_exit")
        except BaseException:
            diagnostics["evaluation_completed"] = False
            raise
        finally:
            session.refresh()


def _run_session(manifest, directory, iterations, progress, session, evidence_sink):
    from fuzzer.txracer.pipeline.runtime.state_isolation import isolated_state
    backend, deployed, catalog, baseline = session.backend, session.deployed, session.catalog, session.baseline
    progress["deployed"] = deployed
    progress.update(baseline=vars(baseline), stage="explicit_sequences")
    results = progress["results"]
    session.phase = "compatibility_validation"
    for data in manifest.get("sequences", []):
        with isolated_state(backend, baseline, session.diagnostics, "existing_seed_validation"):
            sequence = canonical_sequence(data, session.setup_catalog, deployed)
            result = backend.execute_sequence(sequence, baseline)
            release_computations(result)
        results.append({"sequence_id": sequence.identity, "status": result.status,
                        "statuses": [r.status for r in result.records],
                        "coverage": sorted(result.coverage), "branches": sorted(result.branches)})
    exploration = {}
    session.begin_evaluation()
    if "user" in manifest:
        accounts = [a["address"] for a in manifest["accounts"]]
        explorer_options = dict(manifest.get("explorer", {}))
        if session.templates is not None:
            session.diagnostics["replaced_transaction_value_cap"] = explorer_options.get("max_value")
            explorer_options["max_value"] = None
        config = ExplorerConfig(**explorer_options)
        memory_config = MemoryConfig(**manifest.get("memory", {}))
        preparation = list(manifest.get("preparation", []))
        planner_entries = list(manifest.get("planner_candidates", []))
        if manifest.get("sequence_template"):
            with open(directory / manifest["sequence_template"], encoding="utf8") as stream:
                template = json.load(stream)
            preparation.extend(catalog.preparation_from_template(template))
            planner_entries.extend(template.get("candidate_functions", []) if isinstance(template, dict) else template)
        if "attacker" in manifest:
            if not planner_entries:
                raise ValueError("Attacker interaction requires explicit planner_candidates or an existing sequence_template")
            campaign = TxRacer(backend, baseline, catalog, manifest["user"], manifest["attacker"], accounts,
                                 planner_entries, config, InferenceConfig(**manifest.get("inference", {})),
                                 SchedulerConfig(**dict({"global_seed": config.seed}, **manifest.get("scheduler", {}))),
                                 OracleConfig(**manifest.get("oracle", {})), memory_config, evidence_sink)
            progress.update(campaign=campaign, stage="campaign")
            campaign.run(iterations, preparation)
            exploration = campaign.summary()
        else:
            explorer = UserExplorer(backend, baseline, catalog, manifest["user"], accounts, config, memory_config)
            progress.update(explorer=explorer, stage="user_exploration")
            explorer.initialize(preparation)
            explorer.run(iterations)
            exploration = explorer.summary()
    return {"tool": "TxRacer", "status": "completed", "deployed": deployed, "baseline": vars(baseline),
            "results": results, "exploration": exploration, "abi_diagnostics": catalog.diagnostics,
            "setup_diagnostics": session.diagnostics}


def main(argv=None):
    parser = argparse.ArgumentParser(
        description="TxRacer standalone runner for authorized attack simulation",
        epilog="Attack sequences and replay evidence concern real on-chain asset security. "
               "Use only with authorization in isolated environments; see SECURITY.md.")
    parser.add_argument("manifest", help="JSON with funded accounts, deployment bytecode and canonical sequences")
    parser.add_argument("--output", required=True)
    parser.add_argument("--solc", help="Local Solidity compiler for source-based deployments")
    parser.add_argument("--iterations", type=int, default=0, help="Bounded User search iterations after initialization")
    args = parser.parse_args(argv)
    with open(args.manifest, encoding="utf8") as stream:
        manifest = json.load(stream)
    failure = None
    reserve = bytearray(1024 * 1024)
    evidence_path = str(Path(args.output).with_suffix(".evidence.jsonl"))
    with open(evidence_path, "w", buffering=1) as evidence:
        def emit(finding):
            # Attack replay evidence may expose exploitable paths to real on-chain assets.
            evidence.write(json.dumps(finding, sort_keys=True) + "\n")
            evidence.flush()
        try:
            result = run_manifest(manifest, Path(args.manifest).resolve().parent, args.solc, args.iterations, emit)
        except CampaignAborted as error:
            reserve = None
            result, failure = error.summary, error
    result["evidence_path"] = evidence_path
    with open(args.output, "w", encoding="utf8") as stream:
        json.dump(result, stream, indent=2)
    if failure is not None:
        raise failure


if __name__ == "__main__":
    main()
