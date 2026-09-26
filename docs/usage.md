# Usage

Follow the [quick start](../README.md#quick-start) to install TxRacer.
Run the commands below from the repository root.

## Configuration

Start from [examples/smoke.json](../examples/smoke.json) and adjust:

- Fund `accounts` and set distinct `user` and `attacker` addresses.
- `contracts`: list contracts in deployment order, with a unique `name`, `sender`,
  `source`/`artifact` or `abi`/`bytecode`, and any required `constructor_arguments`.
  Use `@Name` to reference an already deployed contract.
- `setup` or `required_setup`: calls with `contract`, full `function` signature,
  `arguments`, and `sender`; `value` and `gas` are optional.
- `preparation`: initial user transaction sequences. `planner_candidates` lists
  functions available for constructing attacker sequences.

Source and sequence-template paths are relative to the manifest directory.
Set `TXRACER_SOLC` to an absolute compiler path matching the contract's pragma and pass it
with `--solc`. Each isolated execution starts from the saved setup state.
Follow the [security guidance](../SECURITY.md) for authorized attack simulations.

## Input generators

```bash
python generate_sequence.py examples/T.sol --solc "$TXRACER_SOLC"
python generate_config.py examples/T.sol --solc "$TXRACER_SOLC"
```

These write `sequence_template.json` and `constructor_config.json`.
Review the generated inputs and replace unresolved constructor values before use.

## Tests

Run the core checks with the same compiler used by the example:

```bash
export TXRACER_SOLC="$HOME/.solcx/solc-v0.4.26"
PYTHONPATH=.:tests python -m unittest discover -s tests -p 'test_*.py'
```
