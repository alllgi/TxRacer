import json
import shutil
import sys
import os
import argparse
from web3 import Web3

import config
from comp import analysis_depend_contract, analysis_main_contract_constructor
from fuzzer.txracer.config import (
    TxRacerConfig,
    add_txracer_arguments,
    append_txracer_arguments,
)

SOLC_TO_EVM_VERSION = {
    '0.8': 'london',
    '0.7': 'istanbul',
    '0.6': 'istanbul',

     '0.5':'petersburg',
    '0.4': 'byzantium',
}

SUPPORTED_EVM_VERSIONS = {'homestead', 'byzantium', 'petersburg'}

def get_evm_version_for_solc(solc_version_str):

    if not solc_version_str: return 'byzantium'

    major_minor = ".".join(solc_version_str.split('.')[:2])
    ideal_evm = SOLC_TO_EVM_VERSION.get(major_minor, 'byzantium')


    if ideal_evm in SUPPORTED_EVM_VERSIONS:
        return ideal_evm
    else:

        print(f"[*] Warning: Ideal EVM version '{ideal_evm}' is not supported by the underlying py-evm.")
        print(f"[*] Gracefully degrading to the latest supported version: 'petersburg'.")
        return 'petersburg'

def run(_file_path: str, _main_contract: str, solc_version: str, timeout: int, _depend_contracts: list,
        max_individual_length: int, _constructor_args: list, _solc_path: str,
        _full_config_path: str = "",_sequence_template_path: str = "",
        _duplication: str = '0', _txracer_config: TxRacerConfig = None):

    evm_version = get_evm_version_for_solc(solc_version)
    template_arg = f"--sequence-template {_sequence_template_path}" if _sequence_template_path and os.path.exists(_sequence_template_path) else ""


    command = [
        PYTHON, FUZZER,
        '-s', _file_path,
        '-c', _main_contract,
        '--solc', f'v{solc_version}',
        '--evm', evm_version,
        '-t', str(timeout),
        '--result', 'fuzzer/result/res.json',
        '--cross-contract', '1',
        '--open-trans-comp', '1',
        '--constraint-solving', '1',
        '--max-individual-length', str(max_individual_length),
        '--solc-path-cross', _solc_path,
        '--p-open-cross', '80',
        '--cross-init-mode', '1',
        '--trans-mode', '1',
        '--duplication', _duplication
    ]
    append_txracer_arguments(command, _txracer_config or TxRacerConfig())


    if _depend_contracts:
        command.append('--depend-contracts')
        command.extend(_depend_contracts)

    if _constructor_args:
        command.append('--constructor-args')
        command.extend(_constructor_args)

    if _full_config_path and os.path.exists(_full_config_path):
        command.extend(['--full-constructor-config', _full_config_path])

    if _sequence_template_path and os.path.exists(_sequence_template_path):
        command.extend(['--sequence-template', _sequence_template_path])

    cmd_str = ' '.join(command)
    print("="*50); print("Executing Fuzzer Command:"); print(cmd_str); print("="*50)
    os.system(cmd_str)

    return "fuzzer/result/res.json"


def cli():

    parser = argparse.ArgumentParser(description="CrossFuzz - A cross-contract fuzzer for smart contracts.")
    parser.add_argument("sol_file", help="Path to the Solidity source file.")
    parser.add_argument("contract_name", help="Name of the main contract to fuzz.")
    parser.add_argument("solc_version", help="Solidity compiler version (e.g., 0.8.4).")
    parser.add_argument("max_seq_len", type=int, help="Maximum length of a transaction sequence.")
    parser.add_argument("fuzz_time", type=int, help="Fuzzing duration in seconds.")
    parser.add_argument("result_path", help="Path to save the final results JSON file.")
    parser.add_argument("solc_path", help="Absolute path to the solc binary.")
    parser.add_argument("duplication", choices=['0', '1'], help="Duplication mode (0 for off, 1 for on).")
    parser.add_argument("--constructor_config", default="auto",
                        help="Path to the constructor config JSON file. (default: 'auto')")
    parser.add_argument("--depend-contracts", nargs='+', default=[],
                        help="A space-separated list of dependent contracts in deployment order.")
    parser.add_argument("--sequence-template",
                        help="Path to the JSON file with the function sequence template.")
    add_txracer_arguments(parser)
    args = parser.parse_args()
    txracer_config = TxRacerConfig.from_namespace(args)
    inactive_warning = txracer_config.inactive_feature_warning()
    if inactive_warning:
        print(f"[!] {inactive_warning}")


    final_fitness = 0.0
    res_path = "fuzzer/result/res.json"

    try:
        print("[*] Bypassing internal dependency analysis. Relying on external context from fuzz_context.json.")
        _depend_contracts = []
        try:
            with open("fuzz_context.json", "r") as f:
                fuzz_context = json.load(f)
            fuzz_universe = fuzz_context.get("fuzz_universe", [])
            _depend_contracts = [c for c in fuzz_universe if c != args.contract_name]
            print(f"[*] Successfully loaded fuzz universe. Dependent contracts: {_depend_contracts}")
        except FileNotFoundError:
            print("[!] Warning: fuzz_context.json not found. Falling back to old internal analysis.")

            _depend_contracts, _ = analysis_depend_contract(
                file_path=args.sol_file, _contract_name=args.contract_name,
                _solc_version=args.solc_version, _solc_path=args.solc_path
            )
        except Exception as e:
             print(f"[!] Error loading fuzz_context.json: {e}. Falling back to old internal analysis.")
             _depend_contracts, _ = analysis_depend_contract(
                file_path=args.sol_file, _contract_name=args.contract_name,
                _solc_version=args.solc_version, _solc_path=args.solc_path
            )

        if _depend_contracts is None:
            _depend_contracts = []


        print("\n[*] Step 2: Analyzing main contract constructor...")

        _depend_contracts = args.depend_contracts
        print(f"[*] Received dependent contracts from command line: {_depend_contracts}")


        _constructor_args = []
        if args.constructor_config.lower() != "auto":
            full_config_path = args.constructor_config
            try:
                with open(full_config_path, "r", encoding="utf-8") as f:
                    config = json.load(f)
                if args.contract_name in config and 'args' in config[args.contract_name]:


                    main_contract_config = config[args.contract_name]['args']
                    for arg in main_contract_config:
                        arg_name = arg.get('name', '_')
                        arg_type_from_json = arg['type']
                        arg_value = arg['value']

                        value_str = ""
                        if isinstance(arg_value, list):


                            value_str = ",".join(map(str, arg_value))
                        else:
                            value_str = str(arg_value)


                        if arg_type_from_json == 'contract':


                            _constructor_args.append(f"{arg_name} address {value_str}")
                        else:

                            _constructor_args.append(f"{arg_name} {arg_type_from_json} {value_str}")
            except Exception as e:
                print(f"Warning: Could not parse constructor config file: {e}")

        print(f"[*] Using constructor arguments for main contract: {_constructor_args}")


        res_path = run(
            args.sol_file, args.contract_name, args.solc_version,
            args.fuzz_time,
            _depend_contracts,
            args.max_seq_len,
            _constructor_args = _constructor_args,
            _solc_path=args.solc_path,
            _full_config_path=full_config_path,
             _sequence_template_path=args.sequence_template,
            _duplication=args.duplication,
            _txracer_config=txracer_config
        )

        if os.path.exists(res_path):
            with open(res_path, 'r') as f:
                results = json.load(f)
            main_contract_results = results.get(args.contract_name, {})
            coverage = main_contract_results.get('code_coverage', {}).get('percentage', 0.0)
            vulnerability_score = main_contract_results.get('vulnerability_score', 0.0)


            state_distance = main_contract_results.get('state_distance', 0.0)
            import math
            state_distance_score = math.log1p(state_distance)
            final_fitness = coverage + (vulnerability_score * 1000) + (state_distance_score * 0.1)


            shutil.copyfile(res_path, args.result_path)
            print(f"[*] Results saved. Final Fitness (Coverage+Vuln+Distance) = {final_fitness}")
            print(f"[*] Results successfully saved to {args.result_path}")
        else:
            print(f"[!] Warning: Fuzzer did not produce a result file at {res_path}")

    except Exception as e:
        print(f"[!!!] CrossFuzz.py encountered a fatal error: {e}", file=sys.stderr)

    finally:

        print(f"FINAL_FITNESS: {final_fitness}")

if __name__ == "__main__":

    PYTHON = "python3 -u"

    FUZZER = "fuzzer/main.py"
    cli()
