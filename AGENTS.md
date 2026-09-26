# Repository guidelines

This is the public TxRacer repository. Benchmark data belongs in `benchmarks/`.
Preserve original contracts, evidence, annotations, and third-party notices. Keep
dataset-specific adapters, deployment presets, tool mappings, and historical
detector outputs outside this repository.
Keep public tests focused on core behavior; full development regressions belong
outside this repository. Examples must not depend on the test directory.

Use Python 3.8, four-space indentation, and the surrounding style. Preserve
detector, oracle, search, and interleaving semantics unless the task requests a
behavioral change. Keep comments brief and focused on non-obvious logic.

Use TxRacer as the public project name. Keep internal release labels and project
version numbers out of repository documentation, names, and runtime output.
Keep commit messages brief, without validation reports or other metadata.

Use `attacker` for the adversarial actor and attack-related API fields. Keep the
TxRacer project name. Explain real on-chain asset risks in security documentation
and brief comments at attack construction and evidence export boundaries. Follow
the authorized-use and disclosure guidance in `SECURITY.md`.

The standalone entry point is `python -m fuzzer.txracer.pipeline.runner`. Generic setup
and isolation live in `fuzzer/txracer/pipeline/runtime/`; tests use synthetic fixtures.

Compile sources and run related tests after changes. For execution or detector
changes, also run the standalone example. For generator changes, run both generators
against `examples/T.sol` and validate their JSON output. Report failures and missing
dependencies accurately. Do not commit generated output or local environments.
