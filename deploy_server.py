import os
import json
import random
import sys
import shutil
import argparse
from copy import deepcopy

PROJECT_ROOT = os.path.dirname(os.path.realpath(__file__))


if PROJECT_ROOT not in sys.path:
    sys.path.append(PROJECT_ROOT)
    print(f"[*] Project root '{PROJECT_ROOT}' added to sys.path.")


from fuzzer.utils import settings
from fuzzer.evm import InstrumentedEVM
from fuzzer.engine.environment import FuzzingEnvironment
from fuzzer.engine.components import Generator, Individual
from fuzzer.utils.utils import initialize_logger, compile, get_function_signature_mapping
from comp import analysis_depend_contract, analysis_main_contract_constructor
from eth_utils import encode_hex, to_canonical_address
from eth_abi import encode_abi
from z3 import Solver


import binascii
from pprint import pprint, pformat
from datetime import datetime


def _get_user_state(env, user_address_str):
    try:
        canonical_addr = to_canonical_address(user_address_str)
        eth_balance = env.instrumented_evm.get_balance(canonical_addr)
        return {'eth': eth_balance}
    except Exception as e:
        print(f"!! ERROR in _get_user_state for '{user_address_str}': {e}"); return {'eth': 0}

def _compare_scenarios(initial_state_alice, initial_state_bob, state_A_alice, state_A_bob, state_B_alice, state_B_bob):
    profit_A_alice = state_A_alice['eth'] - initial_state_alice['eth']
    profit_B_alice = state_B_alice['eth'] - initial_state_alice['eth']
    profit_B_bob = state_B_bob['eth'] - initial_state_bob['eth']

    if profit_B_alice < profit_A_alice and profit_B_bob > 0:
        score = (profit_A_alice - profit_B_alice) + profit_B_bob
        return score
    if profit_A_alice > 0 and profit_B_alice < 0:
        return profit_A_alice - profit_B_alice
    if profit_B_bob > 0 and profit_B_alice > 0 and profit_B_bob > profit_B_alice :
        return profit_B_bob - profit_B_alice

    return 0

def fitness_function(indv, env, sequence_template=None):
    print("\n" + "="*80)
    print(f"DEBUG: Analyzing Individual with hash: {indv.hash}")

    final_sequence = indv.decode()
    if not final_sequence: return 0.0

    try:
        alice_addr_str = env.instrumented_evm.accounts[0]
        if len(env.instrumented_evm.accounts) > 3: bob_addr_str = env.instrumented_evm.accounts[3]
        else:
            random_bytes = os.urandom(20); bob_addr_str = '0x' + binascii.hexlify(random_bytes).decode('ascii')
            env.instrumented_evm.create_fake_account(bob_addr_str); env.instrumented_evm.accounts.append(bob_addr_str)
        initial_state_alice = _get_user_state(env, alice_addr_str)
        initial_state_bob = _get_user_state(env, bob_addr_str)
    except Exception as e:
        print(f"!! ERROR: Failed to set up accounts: {e}"); return 0.0


    template_filepath = "./current_fuzz_sequence.json"
    final_sequence = []

    if sequence_template is not None:
        print(f"!!! DEBUG: Engaging template-based Fuzzing with provided sequence (length {len(sequence_template)}). !!!")
        try:


            template_indv = type(indv)(generator=indv.generator)
            new_chromosome = []
            for item in sequence_template:
                func_sig = item['signature']
                print(f"DEBUG:   -> Generating gene for template: {func_sig}")


                try:


                    func_hash, arg_types = indv.generator.get_specific_function_with_argument_types(func_sig)


                    gene_list = indv.generator.generate_individual(func_hash, arg_types)
                    if gene_list:
                        new_chromosome.append(gene_list[0])
                    else:
                        print(f"!! WARNING: Generator returned empty list for '{func_sig}'.")

                except KeyError:
                    print(f"!! WARNING: Signature '{func_sig}' not found in generator's interface. Skipping.")
                except Exception as e:
                    print(f"!! ERROR generating gene for '{func_sig}': {e}")


            if new_chromosome:
                template_indv.init(chromosome=new_chromosome)
                final_sequence = template_indv.decode()

        except Exception as e:
            print(f"!! FATAL ERROR while processing sequence template: {e}"); return 0.0
    else:

        print("DEBUG: No sequence template found. Running in standard Fuzzing mode.")
        final_sequence = indv.decode()

    if not final_sequence:
        print("DEBUG: No valid sequence to test. Skipping."); return 0.0

    env.instrumented_evm.restore_from_snapshot()
    for i, execution_input in enumerate(final_sequence):
        current_input = deepcopy(execution_input)
        current_input['transaction']['from'] = alice_addr_str
        tx_data = current_input['transaction']['data']
        selector = tx_data[:10] if tx_data.startswith("0x") else "0x" + tx_data[:8]
        func_name = env.function_map.get(selector, f"Unknown/Fallback({selector})")
        result = env.instrumented_evm.deploy_transaction(current_input, gas_price=0)
        status = "SUCCESS" if not result.is_error else f"FAILED ({result._error})"
        print(f"DEBUG: [A-{i}] Tx from Alice, func: {func_name}, Status: {status}")
    state_A_alice = _get_user_state(env, alice_addr_str); state_A_bob = _get_user_state(env, bob_addr_str)


    env.instrumented_evm.restore_from_snapshot()
    alice_tasks = [deepcopy(x) for x in final_sequence]; [t['transaction'].update({'from': alice_addr_str}) for t in alice_tasks]
    bob_tasks = [deepcopy(x) for x in final_sequence]; [t['transaction'].update({'from': bob_addr_str}) for t in bob_tasks]
    merged_sequence = []
    while alice_tasks or bob_tasks:
        chosen_list = random.choice([l for l in [alice_tasks, bob_tasks] if l])
        merged_sequence.append(chosen_list.pop(0))
    for i, execution_input in enumerate(merged_sequence):
        user_name = "Alice" if execution_input['transaction']['from'] == alice_addr_str else "Bob"
        tx_data = execution_input['transaction']['data']
        selector = tx_data[:10] if tx_data.startswith("0x") else "0x" + tx_data[:8]
        func_name = env.function_map.get(selector, f"Unknown/Fallback({selector})")
        result = env.instrumented_evm.deploy_transaction(execution_input, gas_price=0)
        status = "SUCCESS" if not result.is_error else f"FAILED ({result._error})"
        print(f"DEBUG: [B-{i}] Tx from {user_name}, func: {func_name}, Status: {status}")
    state_B_alice = _get_user_state(env, alice_addr_str); state_B_bob = _get_user_state(env, bob_addr_str)
    print(f"DEBUG: Scenario B Final States -> Alice: {state_B_alice}, Bob: {state_B_bob}")

    vulnerability_score = _compare_scenarios(initial_state_alice, initial_state_bob, state_A_alice, state_A_bob, state_B_alice, state_B_bob)
    print(f"DEBUG: Vulnerability Score = {vulnerability_score}")

    if vulnerability_score > 0:
        print("\n" + "="*80)
        print(f"DEBUG: Analyzing Individual with hash: {indv.hash}")
        print(f"DEBUG: Scenario A Final States -> Alice: {state_A_alice}, Bob: {state_A_bob}")
        print(f"DEBUG: Scenario B Final States -> Alice: {state_B_alice}, Bob: {state_B_bob}")
        print(f"DEBUG: Vulnerability Score = {vulnerability_score}")

    if vulnerability_score > 0:
        with open("vulnerabilities.log", "a") as f:
            f.write("="*50 + "\n")
            f.write(f"Timestamp: {datetime.now()}\n")
            f.write(f"Individual Hash: {indv.hash}\n")
            f.write(f"Vulnerability Score: {vulnerability_score}\n")


            f.write("Decoded Function Sequence:\n")
            readable_sequence = []
            for execution_input in final_sequence:
                tx_data = execution_input['transaction']['data']
                selector = tx_data[:10] if tx_data.startswith("0x") else "0x" + tx_data[:8]

                func_name = env.function_map.get(selector, f"Unknown/Fallback({selector})")
                readable_sequence.append(func_name)
            f.write(pformat(readable_sequence) + "\n")


            f.write("Underlying Chromosome (Gene):\n")
            f.write(pformat(indv.chromosome) + "\n")


            f.write(f"Initial States: Alice={initial_state_alice}, Bob={initial_state_bob}\n")
            f.write(f"Scenario A States: Alice={state_A_alice}, Bob={state_A_bob}\n")
            f.write(f"Scenario B States: Alice={state_B_alice}, Bob={state_B_bob}\n\n")

            print("\n" + "!"*20 + " VULNERABILITY DETECTED! Logged to vulnerabilities.log " + "!"*20)

    return float(vulnerability_score)


def crossover(parent1, parent2):

    if len(parent1) < 2 or len(parent2) < 2:
        return parent1, parent2
    point = random.randint(1, min(len(parent1), len(parent2)) - 1)
    child1 = parent1[:point] + parent2[point:]
    child2 = parent2[:point] + parent1[point:]
    return child1, child2

def mutate(sequence, master_sequence):

    if not sequence or random.random() > MUTATION_RATE:
        return sequence


    mutation_type = random.choices(['add', 'delete', 'swap'], weights=[0.5, 0.25, 0.25], k=1)[0]


    if mutation_type == 'add':

        current_signatures = {item['signature'] for item in sequence}
        candidates_to_add = [item for item in master_sequence if item['signature'] not in current_signatures]

        if candidates_to_add:
            new_gene = random.choice(candidates_to_add)
            insert_pos = random.randint(0, len(sequence))
            sequence.insert(insert_pos, new_gene)

            return sequence


    if len(sequence) > 1:
        if mutation_type == 'delete':
            del_index = random.randint(0, len(sequence) - 1)
            removed = sequence.pop(del_index)

        elif mutation_type == 'swap':
            idx1, idx2 = random.sample(range(len(sequence)), 2)
            sequence[idx1], sequence[idx2] = sequence[idx2], sequence[idx1]


    return sequence


class UltimateFuzzer:
    def __init__(self, args):
        self.args = args
        self.logger = initialize_logger("UltimateFuzzer")
        self.full_constructor_config = {}
        if args.constructor_config and os.path.exists(args.constructor_config):
            with open(args.constructor_config, 'r') as f:
                self.full_constructor_config = json.load(f)

    def deploy(self):

        self.logger.title("--- Initializing EVM and Deploying Contracts (ONCE) ---")


        instrumented_evm = InstrumentedEVM(settings.RPC_HOST, settings.RPC_PORT)
        instrumented_evm.set_vm_by_name("byzantium")
        solver = Solver()
        solver.set("timeout", settings.SOLVER_TIMEOUT)


        self.logger.info(f"Compiling {self.args.sol_file}...")
        compiler_output = compile(f"v{self.args.solc_version}", "byzantium", self.args.sol_file)
        if not compiler_output:
            raise RuntimeError(f"Compilation failed for {self.args.sol_file}")

        self.whole_compile_info = compiler_output['contracts'][self.args.sol_file]
        main_contract_info = self.whole_compile_info[self.args.contract_name]

        main_abi = main_contract_info["abi"]
        main_deployment_bytecode = main_contract_info['evm']['bytecode']['object']
        main_runtime_bytecode = main_contract_info['evm']['deployedBytecode']['object']


        self.logger.info("Analyzing contract dependencies...")
        depend_contracts, slither_instance = analysis_depend_contract(
            file_path=self.args.sol_file, _contract_name=self.args.contract_name,
            _solc_version=self.args.solc_version, _solc_path=self.args.solc_path
        )
        if depend_contracts is None: depend_contracts = []

        self._deploy_depend_contracts(instrumented_evm, depend_contracts)


        self.logger.info(f"Deploying main contract '{self.args.contract_name}'...")

        _constructor_args = []


        result = instrumented_evm.deploy_contract(
            instrumented_evm.accounts[0], main_deployment_bytecode, deploy_args=_constructor_args
        )
        if result.is_error:
            raise RuntimeError(f"Failed to deploy main contract: {result._error}")

        main_contract_address = encode_hex(result.msg.storage_address)
        self.logger.info(f"Main contract deployed at {main_contract_address}")


        instrumented_evm.create_snapshot()
        self.logger.info("Initial state snapshot created.")


        self.logger.info("Creating Fuzzing Environment...")
        env = FuzzingEnvironment(
            instrumented_evm=instrumented_evm,
            contract_name=self.args.contract_name,
            contract_address=main_contract_address,
            solver=solver,
            results={},
            symbolic_taint_analyzer=None,
            detector_executor=None,
            interface=get_interface_from_abi(main_abi)[0],
            overall_pcs=None,
            overall_jumpis=None,
            len_overall_pcs_with_children=0,
            other_contracts=[],
            args=self.args,
            seed=random.random(),
            cfg=None,
            abi=main_abi,
            function_map=get_function_signature_mapping(main_abi)
        )

        return env

    def _deploy_depend_contracts(self, instrumented_evm, depend_contracts):

        for depend_contract in depend_contracts:
            abi = self.whole_compile_info[depend_contract]['abi']
            bytecode_base = self.whole_compile_info[depend_contract]['evm']['bytecode']['object']
            final_bytecode = bytecode_base

            if depend_contract in self.full_constructor_config and 'args' in self.full_constructor_config[depend_contract]:
                config_args = self.full_constructor_config[depend_contract]['args']
                if config_args:
                    self.logger.info(f"Encoding constructor args for dependency '{depend_contract}'...")
                    arg_types = [arg['type'] for arg in config_args]
                    arg_values = [int(arg['value']) if 'int' in arg['type'] else arg['value'] for arg in config_args]
                    encoded_args = encode_abi(arg_types, arg_values).hex()
                    final_bytecode += encoded_args

            result = instrumented_evm.deploy_contract(instrumented_evm.accounts[0], final_bytecode)
            if result.is_error:
                raise RuntimeError(f"Failed to deploy dependency {depend_contract}: {result._error}")

            contract_address = encode_hex(result.msg.storage_address)
            instrumented_evm.accounts.append(contract_address)
            self.logger.info(f"Dependency '{depend_contract}' deployed at {contract_address}")
            settings.DEPLOYED_CONTRACT_ADDRESS[depend_contract] = contract_address

    def evolve(self, env):

        self.logger.title("--- Starting Evolutionary Fuzzing ---")


        self.logger.info("Generating initial master sequence (gene pool)...")
        master_sequence_file = "master_sequence.json"


        if not os.path.exists("sequence_generator.py"):
            raise FileNotFoundError("sequence_generator.py not found. Please ensure it's in the root directory.")

        subprocess.run([
            "python", "sequence_generator.py",
            self.args.sol_file,
            "--solc", self.args.solc_path,
            "-o", master_sequence_file
        ])

        with open(master_sequence_file, "r") as f:
            master_sequence = json.load(f)
            master_sequence.sort(key=lambda x: x['score'], reverse=True)


        self.logger.title("--- STAGE 1: BINARY SEARCH FOR CORE SEQUENCE ---")
        best_runnable_sequence = []
        best_runnable_fitness = -1.0


        if not hasattr(env, 'main_generator'):
             env.main_generator = Generator(
                 interface=get_function_signature_mapping(env.abi),
                 accounts=env.instrumented_evm.accounts,
                 contract=env.contract_address,
                 interface_mapper=get_function_signature_mapping(env.abi),
                 contract_name=env.contract_name
             )

        temp_indv = Individual(generator=env.main_generator)

        low, high = 0, len(master_sequence)
        for i in range(6):
            if low >= high: break
            mid = (low + high) // 2
            if mid == low and mid < high: mid += 1

            current_sequence = master_sequence[:mid]
            print(f"\n--- Binary Search Iteration {i+1}: Testing sequence of length {len(current_sequence)} ---")


            fitness = fitness_function(temp_indv, env, sequence_template=current_sequence)

            if fitness >= 0:
                print(f"--- SUCCESS: Sequence of length {mid} is runnable with fitness {fitness}. Trying longer...")
                if fitness > best_runnable_fitness:
                    best_runnable_fitness = fitness
                    best_runnable_sequence = current_sequence
                low = mid
            else:
                print(f"--- TIMEOUT: Sequence of length {mid} is too long. Trying shorter...")
                high = mid

        if not best_runnable_sequence:
            self.logger.error("Could not find any runnable sequence. Exiting.")
            sys.exit(1)


        self.logger.title(f"--- STAGE 2: EVOLUTION FROM CORE SEQUENCE (length {len(best_runnable_sequence)}) ---")

        population = [best_runnable_sequence]
        while len(population) < settings.POPULATION_SIZE:
            mutated_seed = mutate(deepcopy(best_runnable_sequence), master_sequence)
            population.append(mutated_seed)

        for generation in range(settings.GENERATIONS):
            self.logger.info(f"--- GENERATION {generation} ---")


            fitness_scores = []
            for i, seq in enumerate(population):
                print(f"  - Evaluating individual {i+1}/{len(population)}...")
                fitness = fitness_function(temp_indv, env, sequence_template=seq)
                fitness_scores.append((seq, fitness))

            fitness_scores.sort(key=lambda x: x[1], reverse=True)

            best_seq_info = fitness_scores[0]
            best_fitness = best_seq_info[1]
            best_sequence_signatures = [item['signature'] for item in best_seq_info[0]]
            self.logger.info(f"Generation {generation} Best Fitness: {best_fitness}")
            self.logger.info(f"Best sequence (len {len(best_sequence_signatures)}): {best_sequence_signatures[:5]}...")

            if best_fitness >= 1000:
                self.logger.info("VULNERABILITY LIKELY FOUND! Optimal sequence logged. Halting evolution.")
                break


            next_generation = [best_seq_info[0]]
            while len(next_generation) < settings.POPULATION_SIZE:

                parent1 = random.choices(fitness_scores, weights=[max(0.01, f[1]) for f in fitness_scores], k=1)[0][0]
                parent2 = random.choices(fitness_scores, weights=[max(0.01, f[1]) for f in fitness_scores], k=1)[0][0]
                if random.random() < 0.7: child1, child2 = crossover(deepcopy(parent1), deepcopy(parent2))
                else: child1, child2 = deepcopy(parent1), deepcopy(parent2)
                next_generation.append(mutate(child1, master_sequence))
                if len(next_generation) < settings.POPULATION_SIZE:
                    next_generation.append(mutate(child2, master_sequence))

            population = next_generation

    def run(self):
        env = self.deploy()
        self.evolve(env)


def main():
    parser = argparse.ArgumentParser(description="Evolutionary Sequencer for CrossFuzz.")
    parser.add_argument("sol_file", help="Path to the Solidity source file.")
    parser.add_argument("contract_name", help="Name of the main contract to fuzz.")
    parser.add_argument("solc_version", help="Solidity compiler version.")
    parser.add_argument("max_seq_len", type=int, help="Maximum length of a transaction sequence.")
    parser.add_argument("result_path", help="Path to save the temporary results JSON file.")
    parser.add_argument("solc_path", help="Absolute path to the solc binary.")
    parser.add_argument("duplication", choices=['0', '1'], help="Duplication mode.")
    parser.add_argument("--constructor_config", help="Path to the constructor config JSON file. (optional)")
    parser.add_argument(
        "-o", "--output",
        default="master_sequence.json",
        help="Path to the output master sequence JSON file (default: master_sequence.json)."
    )
    args = parser.parse_args()

    fuzzer = UltimateFuzzer(args)
    fuzzer.run()

if __name__ == "__main__":
    main()
