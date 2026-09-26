import sys
import json
import argparse
import shutil
from crytic_compile import CryticCompile
from crytic_compile.platform.exceptions import InvalidCompilation


def generate_constructor_config(solidity_file, solc_path=None):
    print(f"[*] Analyzing {solidity_file}...")

    config_data = {}

    try:
        compile_manager = CryticCompile(solidity_file, solc=solc_path)

        if not compile_manager.compilation_units:
            print("[!] No compilation units found.", file=sys.stderr)
            return None

        for unit in compile_manager.compilation_units.values():

            all_contract_names_in_unit = [c.split(':')[-1] for c in unit.contracts_names]

            for contract_name_with_path in unit.contracts_names:

                clean_contract_name = contract_name_with_path.split(':')[-1]
                print(f"  -> Found contract: {clean_contract_name}")

                config_data[clean_contract_name] = {"args": []}

                abi = unit.abis.get(contract_name_with_path)
                if not abi:
                    print(f"    - Could not find ABI for {clean_contract_name}. Skipping.")
                    continue

                constructor_abi = next((item for item in abi if item.get('type') == 'constructor'), None)

                if constructor_abi and 'inputs' in constructor_abi and constructor_abi['inputs']:
                    print(f"    - Constructor found with {len(constructor_abi['inputs'])} arguments.")

                    for param in constructor_abi['inputs']:
                        param_name = param.get('name', '_unnamed')
                        param_type = param.get('type')

                        final_type = param_type
                        default_value = "YA_DO_NOT_KNOW"

                        if param_type == 'address':
                            potential_contract_name = param_name.lstrip('_').replace('Address', '').lower()

                            matching_contract = None
                            if potential_contract_name:
                                for c_name in all_contract_names_in_unit:
                                    if potential_contract_name in c_name.lower():
                                        matching_contract = c_name
                                        break

                            if matching_contract:
                                final_type = "address"
                                default_value = matching_contract
                                print(f"      - Detected contract dependency: '{param_name}' -> '{matching_contract}'")

                        arg_entry = {
                            "name": param_name,
                            "type": final_type,
                            "value": default_value
                        }
                        config_data[clean_contract_name]["args"].append(arg_entry)
                        print(f"      - Param: '{param_name}', Type: '{final_type}', Value: '{default_value}'")
                else:
                    print(f"    - No constructor with arguments found.")

    except InvalidCompilation as e:
        print(f"\n[!] Compilation Error: {e}", file=sys.stderr)
        return None
    except Exception as e:
        print(f"\n[!] An unexpected error occurred: {e}", file=sys.stderr)
        return None

    return config_data

def main():
    parser = argparse.ArgumentParser(description="Generate a constructor configuration JSON for CrossFuzz.")
    parser.add_argument("solidity_file", help="Path to the Solidity source file (.sol).")
    parser.add_argument("-o", "--output", default="constructor_config.json", help="Path to the output JSON file.")
    parser.add_argument("--solc", dest="solc_path", help="Path to the solc binary.")
    args = parser.parse_args()
    solc_path = args.solc_path
    if not solc_path:
        solc_path_found = shutil.which("solc")
        if solc_path_found:
            print(f"[*] --solc path not provided. Using found solc at: {solc_path_found}")
            solc_path = solc_path_found
        else:
            print("[!] --solc path not provided and could not be found automatically.", file=sys.stderr); sys.exit(1)
    config = generate_constructor_config(args.solidity_file, solc_path)
    if config:
        with open(args.output, 'w') as f:
            json.dump(config, f, indent=4)
        print(f"\n[*] Successfully generated configuration file at: {args.output}")
        print("[*] IMPORTANT: Please review this file and fill in any 'TODO' values.")

if __name__ == "__main__":
    main()
