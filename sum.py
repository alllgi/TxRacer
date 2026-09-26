import json
from collections import Counter
import sys

def summarize_missed_contracts(results_filepath):

    try:
        with open(results_filepath, 'r') as f:
            data = json.load(f)
    except FileNotFoundError:
        print(f"[!] Error: Results file not found at '{results_filepath}'", file=sys.stderr)
        return
    except json.JSONDecodeError:
        print(f"[!] Error: Could not decode JSON from '{results_filepath}'. Is the file valid?", file=sys.stderr)
        return

    missed_cases = data.get("missed_cases_details")
    if not isinstance(missed_cases, list):
        print("[!] 'missed_cases_details' key not found or is not a list in the JSON file.")
        return

    if not missed_cases:
        print("[+] Congratulations! No missed cases found.")
        return


    contract_counts = Counter()


    for case in missed_cases:
        involved_contracts = case.get("involved_contracts", [])


        base_contract_names = set()
        for contract_name_with_address in involved_contracts:
            base_name = contract_name_with_address.split('-')[0]
            base_contract_names.add(base_name)


        for name in base_contract_names:
            contract_counts[name] += 1


    print("=" * 60)
    print("      Frequency Analysis of Missed Contracts")
    print("=" * 60)

    total_missed_contracts = len(contract_counts)
    print(f"\n[*] Found {total_missed_contracts} unique contracts involved in missed cases.")

    print("\n--- Missed Contract Frequency (Most frequent first) ---")


    for contract, count in contract_counts.most_common():
        print(f"{contract:<40} | Appears in {count} missed cases")

    print("\n" + "=" * 60)


if __name__ == "__main__":

    DEFAULT_RESULTS_FILE = "benchmark_analysis_results.json"


    filepath = sys.argv[1] if len(sys.argv) > 1 else DEFAULT_RESULTS_FILE

    summarize_missed_contracts(filepath)
