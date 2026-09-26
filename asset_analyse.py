import sys
import json
import argparse
import shutil
from slither import Slither
from slither.core.declarations import Contract, Function
from slither.core.variables.state_variable import StateVariable

from slither.core.cfg.node import Node

from slither.exceptions import SlitherError

ASSET_FUNCTION_NAMES = {"transfer", "send", "transferFrom", "approve", "balanceOf", "allowance", "safeTransferFrom", "ownerOf", "deposit", "withdraw", "claimReward", "liquidate"}
ASSET_VARIABLE_NAMES = {"_balances", "balances", "balance", "_allowances", "allowances", "allowance", "_owners", "owners", "totalSupply", "_totalSupply"}

class AssetAnalyzer:
    def __init__(self, slither_instance):
        self.slither = slither_instance
        self.asset_related_variables = {}

    def _is_concrete_contract(self, contract):


        if not contract.functions:
            return False


        is_interface = all(len(func.nodes) == 0 for func in contract.functions if not func.is_constructor)

        return not is_interface

    def run(self):
        print("[*] Step 1: Statically identifying direct asset sources...")
        direct_sources = set()
        all_concrete_contracts = [c for c in self.slither.contracts if self._is_concrete_contract(c)]


        for contract in all_concrete_contracts:
            for var in contract.state_variables:
                if var.name in ASSET_VARIABLE_NAMES:
                    if var not in direct_sources:
                        direct_sources.add(var)
                        self.asset_related_variables[var.canonical_name] = {"reason": "Direct name match"}
            for func in contract.functions:
                if func.name in ASSET_FUNCTION_NAMES:
                    for var in func.state_variables_written:
                        if var not in direct_sources:
                            direct_sources.add(var)
                            self.asset_related_variables[var.canonical_name] = {"reason": f"Written by asset func '{func.name}'"}

        if not direct_sources:
            print("[!] Warning: No direct asset sources found."); return {}

        print("\n[*] Step 2: Tracing data dependencies using high-level API...")
        worklist = list(direct_sources)
        processed_vars = set(direct_sources)

        while worklist:
            current_var = worklist.pop(0)

            for contract in all_concrete_contracts:
                for func in contract.functions:

                    if current_var in func.state_variables_read:
                        all_written_vars = func.all_state_variables_written()

                        for tainted_var in all_written_vars:
                            if tainted_var not in processed_vars:
                                print(f"  - Found tainted var '{tainted_var.canonical_name}' (transitively written by '{func.name}')")
                                self.asset_related_variables[tainted_var.canonical_name] = {"reason": f"Tainted by {func.name}"}
                                processed_vars.add(tainted_var)
                                worklist.append(tainted_var)

        print("\n[*] Step 3: Resolving storage slots for asset-related variables...")
        final_output = {}

        for contract in all_concrete_contracts:

            for slot_index, var_in_order in enumerate(contract.state_variables):
                if var_in_order.canonical_name in self.asset_related_variables:
                    canonical_name = var_in_order.canonical_name
                    info = self.asset_related_variables[canonical_name]
                    is_mapping = str(var_in_order.type).startswith("mapping")

                    print(f"  - Resolved: {canonical_name} -> Slot: {slot_index}")

                    final_output[canonical_name] = {
                        "reason": info["reason"],
                        "slot": slot_index,
                        "is_mapping": is_mapping
                    }

        return final_output


def main():
    parser = argparse.ArgumentParser(
        description="Analyze a smart contract to identify asset-related state variables."
    )
    parser.add_argument("solidity_file", help="Path to the Solidity source file (.sol).")
    parser.add_argument("-o", "--output", default="asset_variable_list.json", help="Path to the output JSON file.")
    parser.add_argument("--solc", dest="solc_path", help="Path to the solc binary.")

    args = parser.parse_args()

    solc_path = args.solc_path

    try:
        slither = Slither(args.solidity_file, solc=solc_path)

        analyzer = AssetAnalyzer(slither)
        asset_vars = analyzer.run()

        with open(args.output, 'w') as f:
            json.dump(asset_vars, f, indent=2)

        print(f"\n[*] Successfully generated asset-related state variable list at: {args.output}")

    except Exception as e:
        print(f"\n[!] An unexpected error occurred: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()
