# TxRacer

TxRacer is a smart-contract security testing tool that builds candidate attack
transaction sequences and simulates their interleaving with user transactions in
a local EVM. It models an `attacker` and a `user`, then checks asset changes for
economic security risks.

## Responsible use

**TxRacer can help construct attacks that threaten real on-chain assets.** Use it
only for authorized audits in isolated environments with synthetic assets. Keep
actionable attack evidence private and follow [SECURITY.md](SECURITY.md).
No findings does not prove a contract is safe.

## Quick start

Use **Linux and Python 3.8**. The included example uses Solidity **0.4.26**.

```bash
git clone https://github.com/alllgi/TxRacer.git
cd TxRacer
python3.8 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt
python -c "import solcx; solcx.install_solc('0.4.26')"
export TXRACER_SOLC="$HOME/.solcx/solc-v0.4.26"
```

Run the example:

```bash
python -m fuzzer.txracer.pipeline.runner examples/smoke.json \
  --solc "$TXRACER_SOLC" \
  --iterations 6 \
  --output txracer-results.json
```

Results are written to `txracer-results.json`; findings and attack replay evidence
are written to `txracer-results.evidence.jsonl`.

To test your own contracts, adapt [examples/smoke.json](examples/smoke.json) using
the [usage guide](docs/usage.md).

## Benchmarks

- [FRBench and FRVul26](benchmarks/README.md)

## Documentation

- [Configuration, input generators, and tests](docs/usage.md)
- [Security and responsible disclosure](SECURITY.md)

## License

[MIT](LICENSE). Benchmark sources retain their original licenses.
