#!/usr/bin/env python3


import os
import sys
import time
import json
from datetime import datetime

import solcx
import random
import argparse
from eth.vm.spoof import SpoofTransaction
from z3 import Solver
from eth_utils import to_canonical_address, decode_hex, encode_hex, to_bytes

from detectors import DetectorExecutor
from engine import EvolutionaryFuzzingEngine
from engine.components import Generator, Individual, Population
from engine.analysis import SymbolicTaintAnalyzer
from engine.analysis import ExecutionTraceAnalyzer
from engine.environment import FuzzingEnvironment
from engine.operators import LinearRankingSelection
from engine.operators import DataDependencyLinearRankingSelection
from engine.operators import Crossover
from engine.operators import DataDependencyCrossover
from engine.operators import Mutation
from engine.fitness import fitness_function
from fuzzer.utils.transaction_seq_utils import check_cross_init, gen_trans, init_func
from fuzzer.txracer.config import TxRacerConfig, add_txracer_arguments
from fuzzer.txracer.execution import create_execution_backend
from web3 import Web3


BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

sys.path.append(BASE_DIR)
from fuzzer.utils import settings
from utils.source_map import SourceMap
from utils.utils import initialize_logger, compile, get_interface_from_abi, get_pcs_and_jumpis, \
    get_function_signature_mapping
from utils.control_flow_graph import ControlFlowGraph
from eth_abi import encode_abi
from crytic_compile import CryticCompile
from utils.source_map import SourceMap

def create_population_from_template(template_path, main_generator, other_generators, population_size, logger):

    logger.info(f"Creating population from template: {template_path}")

    with open(template_path, 'r') as f:
        sequence_template = json.load(f)


    generator_map = {main_generator.contract_name: main_generator}
    for g in other_generators:
        generator_map[g.contract_name] = g
    logger.debug(f"Generator map created with keys: {list(generator_map.keys())}")

    individuals_list = []

    for _ in range(population_size):
        new_indv = Individual(generator=main_generator, other_generators=other_generators)
        new_chromosome = []


        for task in sequence_template:
            target_contract_name = task.get('contract')
            func_sig = task.get('signature')

            if not target_contract_name or not func_sig: continue

            target_generator = generator_map.get(target_contract_name)
            if not target_generator:
                logger.warning(f"Could not find generator for '{target_contract_name}'. Skipping.")
                continue

            try:
                func_hash, arg_types = target_generator.get_specific_function_with_argument_types(func_sig)
                gene_list = target_generator.generate_individual(func_hash, arg_types)
                if gene_list: new_chromosome.extend(gene_list)
            except KeyError:
                logger.warning(f"Sig '{func_sig}' not found in '{target_contract_name}' generator. Skipping.")
            except Exception as e:
                logger.error(f"Error generating gene for task '{task}': {e}")

        new_indv.init(chromosome=new_chromosome)
        individuals_list.append(new_indv)

    return individuals_list

class Fuzzer:
    def __init__(self, contract_name, abi, deployment_bytecode, runtime_bytecode, test_instrumented_evm,
                 blockchain_state, solver, args, seed, source_map=None, whole_compile_info=None):
        global logger

        logger = initialize_logger("Fuzzer  ")
        logger.title("Fuzzing contract %s", contract_name)

        cfg = ControlFlowGraph()
        cfg.build(runtime_bytecode, settings.EVM_VERSION)

        function_map = get_function_signature_mapping(abi)
        function_map_reversed = {h: sig for sig, h in function_map.items()}
        self.contract_name = contract_name
        self.interface, self.interface_mapper = get_interface_from_abi(abi)
        self.deployement_bytecode = deployment_bytecode
        self.blockchain_state = blockchain_state
        self.instrumented_evm = test_instrumented_evm
        self.solver = solver
        self.args = args

        self.depend_contracts = args.depend_contracts if args.depend_contracts is not None else []
        print(f"Received depend_contracts in order: {self.depend_contracts}")

        self.full_constructor_config = {}
        if args.full_constructor_config and os.path.exists(args.full_constructor_config):
            with open(args.full_constructor_config, 'r') as f: self.full_constructor_config = json.load(f)


        self.whole_compile_info = whole_compile_info


        self.overall_pcs, self.overall_jumpis = get_pcs_and_jumpis(runtime_bytecode)


        self.results = {"errors": {}}


        self.env = FuzzingEnvironment(instrumented_evm=self.instrumented_evm,
                                      contract_name=self.contract_name,
                                      solver=self.solver,
                                      results=self.results,
                                      symbolic_taint_analyzer=SymbolicTaintAnalyzer(),
                                      detector_executor=DetectorExecutor(source_map,
                                                                         get_function_signature_mapping(abi)),
                                      interface=self.interface,
                                      overall_pcs=self.overall_pcs,
                                      overall_jumpis=self.overall_jumpis,
                                      len_overall_pcs_with_children=0,
                                      other_contracts=list(),
                                      args=args,
                                      seed=seed,
                                      cfg=cfg,
                                      abi=abi,
                                      function_map=function_map,
                                      function_map_reversed=function_map_reversed)
        init_func(args.source)
        assert check_cross_init(), "跨合约初始化失败"
        print("跨合约初始化成功......")


        from fuzzer.txracer.reporting import AppendingFindingLog
        self.env.findings_log = AppendingFindingLog(settings.FINDINGS_LOG_PATH)


        if settings.SHADOW_ECONOMIC_ORACLE:
            self.env.shadow_log = AppendingFindingLog(settings.SHADOW_LOG_PATH)
        else:
            self.env.shadow_log = None


        if settings.INTENT_ORACLE:
            self.env.intent_log = AppendingFindingLog(
                settings.INTENT_LOG_PATH or "intent_records.jsonl")
        else:
            self.env.intent_log = None


    def deploy_depend_contracts(self):
        generators = []
        if self.whole_compile_info is None:
            logger.error("没有找到编译信息, 退出程序!")
            sys.exit(-1)


        for depend_contract in self.depend_contracts:
            abi = self.whole_compile_info[depend_contract]['abi']
            interface, interface_mapper = get_interface_from_abi(abi)
            bytecode_base = self.whole_compile_info[depend_contract]['evm']['bytecode']['object']
            final_bytecode = bytecode_base

            def _build_deployment_plan(contract_name=depend_contract,
                                       bytecode=bytecode_base):


                import hashlib as _hashlib
                plan_bytecode = bytecode
                constructor_config = self.full_constructor_config.get(
                    contract_name, {}) if self.full_constructor_config else {}
                plan = {
                    "bytecode": plan_bytecode,
                    "constructor_config": constructor_config,
                    "link_config": {},
                    "deploy_order": list(self.depend_contracts),
                }
                return plan

            if (getattr(settings, "READONLY_CACHE", False)
                    and getattr(settings, "CACHE_MANAGER", None) is not None):
                import hashlib as _hashlib
                from fuzzer.txracer.cache.compile_cache import (
                    deployment_plan_key,
                    deployment_plan_with_cache,
                )
                constructor_config = self.full_constructor_config.get(
                    depend_contract, {}) if self.full_constructor_config else {}
                plan_key = deployment_plan_key(
                    depend_contract,
                    _hashlib.sha256(bytecode_base.encode(
                        "utf-8")).hexdigest(),
                    _hashlib.sha256(str(constructor_config).encode(
                        "utf-8")).hexdigest(),
                    {},
                    list(self.depend_contracts),
                    config_fields={
                        "mode": getattr(getattr(self, "args", None),
                                        "txracer_mode", "legacy"),
                        "seed": getattr(self.args, "seed", None),
                        "execution_backend": getattr(
                            getattr(self, "args", None),
                            "execution_backend", "legacy"),
                    })
                plan, _status = deployment_plan_with_cache(
                    settings.CACHE_MANAGER.deployment_cache,
                    plan_key, _build_deployment_plan)
                final_bytecode = plan["bytecode"]

            if depend_contract in self.full_constructor_config and 'args' in self.full_constructor_config[depend_contract]:
                constructor_config = self.full_constructor_config[depend_contract]['args']
                if constructor_config:
                    logger.info(f"为依赖合约 {depend_contract} 从配置文件加载、转换并编码参数...")
                    try:
                        arg_types = [arg['type'] for arg in constructor_config]
                        arg_values = []


                        for arg in constructor_config:
                            arg_type = arg['type']
                            arg_value_from_json = arg['value']

                            if arg_type == 'contract':

                                arg_types.append('address')


                                deployed_address = settings.DEPLOYED_CONTRACT_ADDRESS.get(str(arg_value_from_json))
                                if not deployed_address:
                                    raise ValueError(f"Could not find deployed address for contract '{arg_value_from_json}' needed by '{depend_contract}'")
                                print(f"  -> Resolved dependency '{arg_value_from_json}' to address {deployed_address}")
                                arg_values.append(deployed_address)


                            if 'bytes' in arg_type:

                                arg_values.append(to_bytes(hexstr=arg_value_from_json))
                            elif 'uint' in arg_type or 'int' in arg_type:

                                arg_values.append(int(arg_value_from_json))
                            elif 'bool' in arg_type:

                                arg_values.append(str(arg_value_from_json).lower() in ['true', '1'])
                            elif 'address' in arg_type:

                                arg_values.append(arg_value_from_json)
                            else:

                                arg_values.append(arg_value_from_json)

                        logger.debug(f"  -> Types for encoding: {arg_types}")
                        logger.debug(f"  -> Values for encoding (with correct Python types): {arg_values}")

                        encoded_arguments = encode_abi(arg_types, arg_values)
                        final_bytecode += encoded_arguments.hex()
                        logger.debug(f"  -> Successfully encoded arguments.")

                    except Exception as e:
                        logger.error(f"为 {depend_contract} 编码构造函数参数时出错: {e}")
                        sys.exit(f"无法为 {depend_contract} 编码构造函数参数。")


            result = self.instrumented_evm.deploy_contract(
                self.instrumented_evm.accounts[0],
                final_bytecode,
                deploy_args=[]
            )

            if result.is_error:
                logger.error("部署依赖合约 %s 失败。错误信息: %s", depend_contract, result._error)
                sys.exit(f"无法部署依赖合约 {depend_contract}，Fuzzing 终止。")
            else:
                if "constructor" in interface: del interface['constructor']
                contract_address = encode_hex(result.msg.storage_address)
                self.instrumented_evm.accounts.append(contract_address)
                logger.info(f"依赖合约 {depend_contract} 部署成功于: %s", contract_address)
                settings.TRANS_INFO[depend_contract] = contract_address
                settings.DEPLOYED_CONTRACT_ADDRESS[depend_contract] = contract_address
                generator = Generator(interface=interface, bytecode=bytecode_base,
                                      accounts=self.instrumented_evm.accounts, contract=contract_address,
                                      interface_mapper=interface_mapper, contract_name=depend_contract,
                                      sol_path=self.args.source,abi=abi)
                generators.append(generator)

        return generators


    def run(self):
        print("Starting Fuzzer")
        contract_address = None
        self.instrumented_evm.create_fake_accounts()
        if self.args.cross_contract == 1:
            generators = self.deploy_depend_contracts()
        else:
            generators = []
        if self.args.source:
            for transaction in self.blockchain_state:
                if transaction['from'].lower() not in self.instrumented_evm.accounts:
                    self.instrumented_evm.accounts.append(
                        self.instrumented_evm.create_fake_account(transaction['from']))

                if not transaction['to']:
                    result = self.instrumented_evm.deploy_contract(transaction['from'], transaction['input'],
                                                                   int(transaction['value']), int(transaction['gas']),
                                                                   int(transaction['gasPrice']))
                    if result.is_error:
                        logger.error("Problem while deploying contract %s using account %s. Error message: %s",
                                     self.contract_name, transaction['from'], result._error)
                        sys.exit(-2)
                    else:
                        contract_address = encode_hex(result.msg.storage_address)
                        self.instrumented_evm.accounts.append(contract_address)
                        self.env.nr_of_transactions += 1
                        logger.debug("Contract deployed at %s", contract_address)
                        self.env.other_contracts.append(to_canonical_address(contract_address))
                        cc, _ = get_pcs_and_jumpis(
                            self.instrumented_evm.get_code(to_canonical_address(contract_address)).hex())
                        self.env.len_overall_pcs_with_children += len(cc)
                else:
                    input = {}
                    input["block"] = {}
                    input["transaction"] = {
                        "from": transaction["from"],
                        "to": transaction["to"],
                        "gaslimit": int(transaction["gas"]),
                        "value": int(transaction["value"]),
                        "data": transaction["input"]
                    }
                    input["global_state"] = {}
                    out = self.instrumented_evm.deploy_transaction(input, int(transaction["gasPrice"]))

            if "constructor" in self.interface:
                del self.interface["constructor"]

            if not contract_address:
                if "constructor" not in self.interface:
                    result = self.instrumented_evm.deploy_contract(self.instrumented_evm.accounts[0],
                                                                   self.deployement_bytecode,
                                                                   deploy_args=self.args.constructor_args,
                                                                   deploy_mode=settings.CROSS_INIT_MODE)
                    if result.is_error:
                        logger.error("Problem while deploying contract %s using account %s. Error message: %s",
                                     self.contract_name, self.instrumented_evm.accounts[0], result._error)
                        sys.exit(-2)
                    else:
                        contract_address = encode_hex(result.msg.storage_address)
                        self.instrumented_evm.accounts.append(contract_address)
                        self.env.nr_of_transactions += 1
                        logger.info("主Contract deployed at %s", contract_address)

                        settings.TRANS_INFO[self.contract_name] = contract_address
                        settings.DEPLOYED_CONTRACT_ADDRESS[self.contract_name] = contract_address

            if contract_address in self.instrumented_evm.accounts:
                self.instrumented_evm.accounts.remove(contract_address)

            self.env.overall_pcs, self.env.overall_jumpis = get_pcs_and_jumpis(
                self.instrumented_evm.get_code(to_canonical_address(contract_address)).hex())

        if self.args.abi:
            contract_address = self.args.contract

        sequence_template = None

        if self.args.sequence_template and os.path.exists(self.args.sequence_template):
            logger.info(f"Loading sequence template from {self.args.sequence_template}")
            with open(self.args.sequence_template, 'r') as f:
                from fuzzer.txracer.planner.sequence_planner import (
                    PlannerError,
                    normalize_sequence_template,
                )
                try:
                    sequence_template = normalize_sequence_template(
                        json.load(f))
                except (PlannerError, ValueError) as template_error:
                    logger.error(
                        "Invalid sequence template %s: %s",
                        self.args.sequence_template, template_error)
                    sys.exit(-1)


        logger.info("--- Performing Automated Initial Airdrop ---")


        owner_account = self.instrumented_evm.accounts[0]


        for contract_name, contract_address in settings.DEPLOYED_CONTRACT_ADDRESS.items():

            abi = self.whole_compile_info.get(contract_name, {}).get('abi')
            if not abi: continue


            mint_function = next((f for f in abi if f.get('name', '').lower() == 'mint' and f.get('type') == 'function'), None)

            if mint_function:
                logger.info(f"Found mint function in {contract_name}. Attempting airdrop...")

                owner_account = self.instrumented_evm.accounts[0]
                if len(self.instrumented_evm.accounts) > 2:
                    targets = self.instrumented_evm.accounts[0:3]
                else:
                    targets = self.instrumented_evm.accounts


                for target_account in targets:

                    try:
                        print(f"[*] Attempting to airdrop {contract_name} tokens to {target_account}...")


                        mint_amount = 1000 * (10**18)


                        mint_selector = "0x40c10f19"
                        encoded_args = encode_abi(['address', 'uint256'], [target_account, mint_amount]).hex()
                        tx_data = mint_selector + encoded_args


                        sender_addr_canon = to_canonical_address(owner_account)
                        nonce = self.instrumented_evm.vm.state.get_nonce(sender_addr_canon)
                        tx = self.instrumented_evm.vm.create_unsigned_transaction(
                            nonce=nonce, gas_price=0, gas=settings.GAS_LIMIT,
                            to=to_canonical_address(contract_address), value=0,
                            data=decode_hex(tx_data)
                        )
                        spoofed_tx = SpoofTransaction(tx, from_=sender_addr_canon)
                        result, _ = self.instrumented_evm.vm.state.apply_transaction(spoofed_tx)

                        if not result.is_error:
                            logger.info(f"  -> SUCCESS: Airdropped {mint_amount} {contract_name} tokens to {target_account}")
                        else:

                            logger.warning(f"  -> FAILED: Airdrop tx for {target_account} reverted with: {result._error}")

                    except Exception as e:


                        logger.error(f"  -> CRITICAL FAILURE during airdrop for {target_account}: {e}")

                        continue

        self.instrumented_evm.create_snapshot()

        generator = Generator(interface=self.interface,
                              bytecode=self.deployement_bytecode,
                              accounts=self.instrumented_evm.accounts,
                              contract=contract_address,
                              abi = self.env.abi,
                              other_generators=generators,
                              interface_mapper=self.interface_mapper,
                              contract_name=self.contract_name,
                              sol_path=self.args.source,
                              sequence_template=sequence_template)


        all_generators = [generator] + generators
        for gen in generators:
            gen.update_other_generators(all_generators, generator.total_interface_mapper)


        size = settings.POPULATION_SIZE if settings.POPULATION_SIZE else 2 * len(self.interface)
        population = Population(
            indv_template=Individual(generator=generator, other_generators=generators),
            indv_generator=generator,
            size=settings.POPULATION_SIZE if settings.POPULATION_SIZE else 2 * len(self.interface),
            other_generators=generators
        )


        template_filepath = self.args.sequence_template
        if template_filepath and os.path.exists(template_filepath):
            with open(template_filepath, 'r') as f:
                from fuzzer.txracer.planner.sequence_planner import (
                    PlannerError,
                    normalize_sequence_template,
                )
                try:
                    sequence_template = normalize_sequence_template(
                        json.load(f))
                except (PlannerError, ValueError) as template_error:
                    logger.error(
                        "Invalid sequence template %s: %s",
                        template_filepath, template_error)
                    sys.exit(-1)

            population.init_from_template(sequence_template)
        else:

            logger.info("No sequence template found. Using default random initialization.")
            population.init(init_seed=False)


        if self.args.data_dependency:
            selection = DataDependencyLinearRankingSelection(env=self.env)
            crossover = DataDependencyCrossover(pc=settings.PROBABILITY_CROSSOVER, env=self.env)
            mutation = Mutation(pm=settings.PROBABILITY_MUTATION)
        else:
            selection = LinearRankingSelection()
            crossover = Crossover(pc=settings.PROBABILITY_CROSSOVER)
            mutation = Mutation(pm=settings.PROBABILITY_MUTATION)


        engine = EvolutionaryFuzzingEngine(population=population, selection=selection, crossover=crossover,
                                           mutation=mutation,
                                           mapping=get_function_signature_mapping(self.env.abi))
        engine.fitness_register(lambda x: fitness_function(x, self.env))
        engine.analysis.append(ExecutionTraceAnalyzer(self.env))


        self.env.execution_begin = time.time()
        self.env.population = population
        settings.GLOBAL_ENV = self.env


        if settings.ASSET_STATE_FEEDBACK:
            from fractions import Fraction
            from fuzzer.txracer.assets.pipeline import StateFeedbackPipeline
            self.env.state_feedback_pipeline = StateFeedbackPipeline(
                self.instrumented_evm,
                chain_id=settings.CHAIN_ID,
                mode=self.args.txracer_mode,
                seed=getattr(self.args, "seed", None),
                state_corpus_probability=Fraction(
                    settings.STATE_CORPUS_PROBABILITY),
                coverage_stagnation_generations=(
                    settings.COVERAGE_STAGNATION_GENERATIONS),
            )

        engine.run(ng=settings.GENERATIONS)


        if settings.ASSET_STATE_FEEDBACK:
            feedback_pipeline = getattr(
                self.env, "state_feedback_pipeline", None)
            if feedback_pipeline is not None:
                import json as _json
                try:
                    with open("asset_feedback_campaign.json", "w",
                              encoding="utf-8") as handle:
                        _json.dump(feedback_pipeline.to_dict(), handle,
                                   indent=2, default=str, sort_keys=True)
                except OSError as dump_error:
                    self.logger.warning(
                        "Phase 4 asset feedback dump failed: %s",
                        dump_error)


        if self.env.args.cfg:
            if self.env.args.source:
                self.env.cfg.save_control_flow_graph(
                    os.path.splitext(self.env.args.source)[0] + '-' + self.contract_name, 'pdf')
            elif self.env.args.abi:
                self.env.cfg.save_control_flow_graph(
                    os.path.join(os.path.dirname(self.env.args.abi), self.contract_name), 'pdf')

        self.instrumented_evm.reset()
        settings.TRANS_INFO["end_time"] = str(datetime.now())


        if getattr(self.env, "findings_log", None) is not None:
            self.env.findings_log.close()
        if getattr(self.env, "shadow_log", None) is not None:
            self.env.shadow_log.close()
        if getattr(self.env, "intent_log", None) is not None:
            self.env.intent_log.close()


def apply_preemption_runtime_settings(settings_module, args):

    settings_module.PREEMPTION_SCHEDULER = args.txracer_config.features.preemption_scheduler
    settings_module.MAX_PREEMPTION_POINTS = args.max_preemption_points
    settings_module.PREEMPTION_CANDIDATE_CAP = args.preemption_candidate_cap
    settings_module.MAX_SCHEDULES_PER_SEED = args.max_schedules_per_seed
    settings_module.PREEMPTION_WEIGHT_MODE = args.txracer_config.preemption_weight_mode
    return settings_module


def main():
    args = launch_argument_parser()

    logger = initialize_logger("Main    ")


    from fuzzer.txracer.asset_map import AssetMapError, load_asset_map
    try:
        settings.ASSET_MAP_INFO = load_asset_map(args.asset_map)
    except AssetMapError as asset_map_error:
        print(f"[!] {asset_map_error}", file=sys.stderr)
        sys.exit(1)
    from fuzzer.txracer.config import resolve_findings_log_path
    settings.FINDINGS_LOG_PATH = resolve_findings_log_path(args.findings_log)
    settings.STOP_ON_FIRST_FINDING = args.stop_on_first_finding
    settings.LEGACY_FIXED_VALUATION = args.legacy_fixed_valuation
    settings.LEGACY_FINDING_LOG = args.legacy_finding_log
    settings.REPRODUCTION_COMMAND = " ".join(sys.argv)
    settings.RESULTS_PATH = args.results


    settings.SOURCE_SHA256 = None
    if args.source:
        import hashlib as _hashlib
        try:
            with open(args.source, "rb") as _handle:
                settings.SOURCE_SHA256 = _hashlib.sha256(
                    _handle.read()).hexdigest()
        except OSError:
            settings.SOURCE_SHA256 = None


    from fuzzer.txracer.oracles.front_running import resolve_oracle_min_absolute
    settings.SHADOW_ECONOMIC_ORACLE = args.txracer_config.features.shadow_economic_oracle
    settings.ORACLE_THRESHOLD_RATIO = args.oracle_threshold_ratio
    settings.ORACLE_MIN_ABSOLUTE = resolve_oracle_min_absolute(
        args.txracer_mode, args.oracle_min_absolute)
    settings.CHAIN_ID = args.chain_id


    apply_preemption_runtime_settings(settings, args)


    settings.INTENT_ORACLE = args.txracer_config.features.intent_oracle
    settings.OUTER_SEQUENCE_EVOLUTION = (
        args.txracer_config.features.outer_sequence_evolution)
    settings.EXTRA_SEED_SCHEDULING = (
        args.txracer_config.features.extra_seed_scheduling)
    settings.PRICE_REPORTING = args.txracer_config.features.price_reporting
    settings.READONLY_CACHE = args.txracer_config.features.readonly_cache
    settings.CACHE_DIR = args.txracer_config.cache_dir
    settings.INTENT_ADAPTERS_PATH = args.txracer_config.intent_adapters
    settings.MAX_EXTRA_SCHEDULES = args.txracer_config.max_extra_schedules
    settings.PAPER_FINDINGS_PATH = args.txracer_config.paper_findings

    settings.PAPER_DESIGN_VERSION = (
        args.txracer_config.paper_design_version)
    settings.MAX_ATTACKER_SEQUENCES_PER_USER = (
        args.txracer_config.max_attacker_sequences_per_user)
    settings.MAX_ATTACKER_MUTATION_DEPTH = (
        args.txracer_config.max_attacker_mutation_depth)
    settings.USER_PREFILTER_POLICY = (
        args.txracer_config.user_prefilter_policy)

    settings.MAX_ATTACKER_SEQUENCES_PER_VICTIM = (
        settings.MAX_ATTACKER_SEQUENCES_PER_USER)
    settings.VICTIM_PREFILTER_POLICY = settings.USER_PREFILTER_POLICY
    settings.ECONOMIC_STATE_POLICY = (
        args.txracer_config.economic_state_policy)
    settings.ORACLE_INTERACTION_GATE = (
        args.txracer_config.oracle_interaction_gate)


    settings.CACHE_MANAGER = None
    if settings.READONLY_CACHE:
        from fuzzer.txracer.cache import CacheManager
        cache_dir = settings.CACHE_DIR or ".txracer_cache"
        settings.CACHE_MANAGER = CacheManager(cache_dir, enabled=True)


    settings.ASSET_STATE_FEEDBACK = args.txracer_config.features.asset_state_feedback
    settings.STATE_CORPUS_PROBABILITY = str(
        args.txracer_config.state_corpus_probability)
    settings.COVERAGE_STAGNATION_GENERATIONS = (
        args.txracer_config.coverage_stagnation_generations)
    if args.txracer_mode == "paper" and args.oracle_min_absolute > 0:
        print("[!] paper mode forces --oracle-min-absolute to 0 (ratio-only thresholds).")
    if settings.ASSET_MAP_INFO.provided:
        logger.info("Loaded asset map %s (SHA-256 %s)",
                    settings.ASSET_MAP_INFO.path, settings.ASSET_MAP_INFO.sha256)
    else:
        logger.info("No explicit asset map provided; asset discovery path remains open.")


    settings.INTENT_ADAPTERS = None
    if args.intent_adapters:
        from fuzzer.txracer.oracles.intent import (
            build_adapters,
            validate_adapter_config,
        )
        import json as _json
        adapter_error = None
        try:
            with open(args.intent_adapters, "r",
                      encoding="utf-8") as handle:
                payload = _json.load(handle)
            errors = validate_adapter_config(payload)
            if errors:
                adapter_error = "invalid intent adapter config: %s" % (
                    "; ".join(errors))
            else:
                settings.INTENT_ADAPTERS = build_adapters(payload)
        except OSError as missing:
            adapter_error = "intent adapter config %r not readable: %s" % (
                args.intent_adapters, missing)
        except ValueError as bad_json:
            adapter_error = "intent adapter config %r invalid JSON: %s" % (
                args.intent_adapters, bad_json)
        if adapter_error:
            print("[!] %s" % adapter_error, file=sys.stderr)
            sys.exit(1)
    if args.paper_findings:
        if not os.path.exists(args.paper_findings):
            print("[!] --paper-findings %r does not exist"
                  % args.paper_findings, file=sys.stderr)
            sys.exit(1)
        corrupt = 0
        try:
            with open(args.paper_findings, "r",
                      encoding="utf-8") as handle:
                for line_number, line in enumerate(handle, 1):
                    if not line.strip():
                        continue
                    try:
                        json.loads(line)
                    except ValueError as line_error:
                        corrupt += 1
                        if corrupt == 1:
                            print(
                                "[!] --paper-findings %r corrupt at line "
                                "%d: %s" % (args.paper_findings,
                                            line_number, line_error),
                                file=sys.stderr)
        except OSError as read_error:
            print("[!] --paper-findings %r unreadable: %s"
                  % (args.paper_findings, read_error), file=sys.stderr)
            sys.exit(1)
        if corrupt:
            sys.exit(1)


    if args.results and os.path.exists(args.results):
        os.remove(args.results)
        logger.info("Contract " + str(args.source) + " has already been analyzed: " + str(args.results))
        logger.info(f"原始的测试输出文件{args.results}已被删除")


    if args.seed:
        seed = args.seed
        if not "PYTHONHASHSEED" in os.environ:
            logger.debug("Please set PYTHONHASHSEED to '1' for Python's hash function to behave deterministically.")
    else:
        seed = random.random()
    random.seed(seed)
    logger.title("Initializing seed to %s", seed)


    settings.EXTENDED_REPORT = None
    if (args.txracer_mode == "extended"
            or any((args.intent_oracle, args.outer_sequence_evolution,
                    args.extra_seed_scheduling, args.price_reporting,
                    args.readonly_cache))):
        from fuzzer.txracer.extended.report import ExtendedReport
        settings.EXTENDED_REPORT = ExtendedReport(
            mode=args.txracer_mode, seed=seed, chain_id=args.chain_id,
            extension_flags={
                "intent_oracle": args.txracer_config.features.intent_oracle,
                "outer_sequence_evolution": (
                    args.txracer_config.features.outer_sequence_evolution),
                "extra_seed_scheduling": (
                    args.txracer_config.features.extra_seed_scheduling),
                "price_reporting": args.txracer_config.features.price_reporting,
                "readonly_cache": args.txracer_config.features.readonly_cache,
            },
            cache_manager=settings.CACHE_MANAGER,
            price_reporting=args.txracer_config.features.price_reporting,
        )


    instrumented_evm = create_execution_backend(
        args.txracer_config.execution_backend,
        settings.RPC_HOST,
        settings.RPC_PORT,
    )
    instrumented_evm.set_vm_by_name(settings.EVM_VERSION)


    solver = Solver()
    solver.set("timeout", settings.SOLVER_TIMEOUT)


    blockchain_state = []
    if args.blockchain_state:
        if args.blockchain_state.endswith(".json"):
            with open(args.blockchain_state) as json_file:
                for line in json_file.readlines():
                    blockchain_state.append(json.loads(line))
        elif args.blockchain_state.isnumeric():
            settings.BLOCK_HEIGHT = int(args.blockchain_state)
            instrumented_evm.set_vm(settings.BLOCK_HEIGHT)
        else:
            logger.error("Unsupported input file: " + args.blockchain_state)
            sys.exit(-1)


    if args.source:
        if args.source.endswith(".sol"):

            compile_fn = compile
            if settings.READONLY_CACHE:
                from fuzzer.txracer.cache.compile_cache import (
                    compile_with_cache,
                )
                cache_manager = settings.CACHE_MANAGER
                compiler_output, _cache_result = compile_with_cache(
                    cache_manager.compile_cache if cache_manager else None,
                    args.source, args.solc_version, settings.EVM_VERSION,
                    compile_fn,
                    config_fields={
                        "mode": args.txracer_mode,
                        "execution_backend": args.execution_backend,
                        "seed": args.seed,
                        "chain_id": args.chain_id,
                        "feature_flags": sorted(
                            args.txracer_config.features.enabled_names()),
                    })
            else:
                compiler_output = compile(
                    args.solc_version, settings.EVM_VERSION, args.source)
            if not compiler_output:
                logger.error("No compiler output for: " + args.source)
                sys.exit(-1)
            for contract_name, contract in compiler_output['contracts'][args.source].items():
                if args.contract and contract_name != args.contract:
                    continue
                if contract['abi'] and contract['evm']['bytecode']['object'] and contract['evm']['deployedBytecode'][
                    'object']:
                    source_map = SourceMap(':'.join([args.source, contract_name]), compiler_output)
                    Fuzzer(contract_name, contract["abi"], contract['evm']['bytecode']['object'],
                           contract['evm']['deployedBytecode']['object'], instrumented_evm, blockchain_state, solver,
                           args, seed, source_map, compiler_output['contracts'][args.source]).run()
        else:
            logger.error("Unsupported input file: " + args.source)
            sys.exit(-1)


    if args.abi:
        with open(args.abi) as json_file:
            abi = json.load(json_file)
            runtime_bytecode = instrumented_evm.get_code(to_canonical_address(args.contract)).hex()
            Fuzzer(args.contract, abi, None, runtime_bytecode, instrumented_evm, blockchain_state, solver, args,
                   seed).run()


    report = getattr(settings, "EXTENDED_REPORT", None)
    if report is not None:
        try:
            paper_records = None
            extended_records = []
            findings_path = settings.FINDINGS_LOG_PATH or "findings.jsonl"
            if os.path.exists(findings_path):
                with open(findings_path, "r", encoding="utf-8") as handle:
                    for line in handle:
                        line = line.strip()
                        if not line:
                            continue
                        try:
                            record = json.loads(line)
                        except ValueError:
                            continue
                        if record.get("finding_type") == "FRONT_RUNNING_PROFIT":
                            extended_records.append(record)
            paper_path = settings.PAPER_FINDINGS_PATH
            if paper_path and os.path.exists(paper_path):
                paper_records = []
                with open(paper_path, "r", encoding="utf-8") as handle:
                    for line in handle:
                        line = line.strip()
                        if not line:
                            continue
                        try:
                            record = json.loads(line)
                        except ValueError:
                            continue
                        if record.get("finding_type") == "FRONT_RUNNING_PROFIT":
                            paper_records.append(record)
            intent_log_path = getattr(
                settings, "INTENT_LOG_PATH", None) or "intent_records.jsonl"
            if os.path.exists(intent_log_path):
                with open(intent_log_path, "r",
                          encoding="utf-8") as handle:
                    for line in handle:
                        line = line.strip()
                        if not line:
                            continue
                        try:
                            intent_record = json.loads(line)
                        except ValueError:
                            continue
                        report.note_intent_record(
                            intent_record.get("classification"))
            extra_count = 0
            try:
                for contract_name, contract_results in (
                        env_results_entries()):
                    extra_count += int(
                        (contract_results or {}).get(
                            "extra_seed_schedules", 0) or 0)
            except Exception:  # noqa: BLE001
                extra_count = 0
            report.extra_seed_schedules = extra_count
            report.set_campaign_assets(
                _extended_campaign_assets(instrumented_evm))
            payload = report.to_dict(
                paper_findings=paper_records,
                extended_findings=extended_records)
            with open("extended_report.json", "w",
                      encoding="utf-8") as handle:
                json.dump(payload, handle, indent=2, sort_keys=True,
                          default=str)
                handle.write("\n")
        except Exception as report_error:  # noqa: BLE001
            print("[!] Extended report write failed: %s" % report_error,
                  file=sys.stderr)
            try:
                with open(settings.FINDINGS_LOG_PATH
                          or "findings.jsonl", "a",
                          encoding="utf-8") as handle:
                    handle.write(json.dumps({
                        "schema_version": 1,
                        "type": "extended_report_diagnostic",
                        "error": str(report_error),
                    }, sort_keys=True) + "\n")
            except OSError:
                pass


def launch_argument_parser():
    parser = argparse.ArgumentParser()


    group1 = parser.add_mutually_exclusive_group(required=True)
    group1.add_argument("-s", "--source", type=str,
                        help="Solidity smart contract source code file (.sol).")
    group1.add_argument("-a", "--abi", type=str,
                        help="Smart contract ABI file (.json).")


    parser.add_argument("-c", "--contract", type=str,
                        help="Contract name to be fuzzed (if Solidity source code file provided) or blockchain contract address (if ABI file provided).")

    parser.add_argument("-b", "--blockchain-state", type=str,
                        help="Initialize fuzzer with a blockchain state by providing a JSON file (if Solidity source code file provided) or a block number (if ABI file provided).")


    parser.add_argument("--solc", help="Solidity compiler version (default '" + str(
        solcx.get_solc_version()) + "'). Installed compiler versions: " + str(
        solcx.get_installed_solc_versions()) + ".",
                        action="store", dest="solc_version", type=str)
    parser.add_argument("--evm", help="Ethereum VM (default '" + str(
        settings.EVM_VERSION) + "'). Available VM's: 'homestead', 'byzantium' or 'petersburg'.", action="store",
                        dest="evm_version", type=str)


    group3 = parser.add_mutually_exclusive_group(required=False)
    group3.add_argument("-g", "--generations",
                        help="Number of generations (default " + str(settings.GENERATIONS) + ").", action="store",
                        dest="generations", type=int)
    group3.add_argument("-t", "--timeout",
                        help="Number of seconds for fuzzer to stop.", action="store",
                        dest="global_timeout", type=int)
    parser.add_argument("-n", "--population-size",
                        help="Size of the population.", action="store",
                        dest="population_size", type=int)
    parser.add_argument("-pc", "--probability-crossover",
                        help="Size of the population.", action="store",
                        dest="probability_crossover", type=float)
    parser.add_argument("-pm", "--probability-mutation",
                        help="Size of the population.", action="store",
                        dest="probability_mutation", type=float)


    parser.add_argument("-r", "--results", type=str, help="Folder or JSON file where results should be stored.")
    parser.add_argument("--seed", type=float, help="Initialize the random number generator with a given seed.")
    parser.add_argument("--cfg", help="Build control-flow graph and highlight code coverage.", action="store_true")
    parser.add_argument("--rpc-host", help="Ethereum client RPC hostname.", action="store", dest="rpc_host", type=str)
    parser.add_argument("--rpc-port", help="Ethereum client RPC port.", action="store", dest="rpc_port", type=int)

    parser.add_argument("--data-dependency",
                        help="Disable/Enable data dependency analysis: 0 - Disable, 1 - Enable (default: 1)",
                        action="store",
                        dest="data_dependency", type=int)
    parser.add_argument("--constraint-solving",
                        help="Disable/Enable constraint solving: 0 - Disable, 1 - Enable (default: 1)", action="store",
                        dest="constraint_solving", type=int)
    parser.add_argument("--environmental-instrumentation",
                        help="Disable/Enable environmental instrumentation: 0 - Disable, 1 - Enable (default: 1)",
                        action="store",
                        dest="environmental_instrumentation", type=int)
    parser.add_argument("--max-individual-length",
                        help="Maximal length of an individual (default: " + str(settings.MAX_INDIVIDUAL_LENGTH) + ")",
                        action="store",
                        dest="max_individual_length", type=int)
    parser.add_argument("--max-symbolic-execution",
                        help="Maximum number of symbolic execution calls before restting population (default: " + str(
                            settings.MAX_SYMBOLIC_EXECUTION) + ")", action="store",
                        dest="max_symbolic_execution", type=int)


    parser.add_argument("--cross-contract", type=int, help="open cross contract mode, open -- 1, close -- 2 (default)",
                        action="store", dest="cross_contract", default=2)
    parser.add_argument("--depend-contracts", type=str, nargs="*",
                        help="main fuzzed contract depend those contracts, you should give some names.",
                        dest="depend_contracts")
    parser.add_argument("--trans-json-path", type=str, help="location to save trans info to json",
                        dest="trans_json_path")
    parser.add_argument("--solc-path-cross", type=str, help="solc path, used by cross-slither", dest="solc_path_cross")
    parser.add_argument("--constructor-args", type=str, nargs="*",
                        help="constructor args, like: [address, uint, .....]", dest="constructor_args")
    parser.add_argument("--open-trans-comp", type=int, help="open cross trans mode, open -- 1 (default), close -- 2",
                        action="store", dest="trans_comp", default=1)
    parser.add_argument("--trans-mode", type=int, help="trans support mode, open other -- 1, no exec other -- 2",
                        default=1, dest="trans_mode")
    parser.add_argument("--p-open-cross", type=int, help="use cross trans probability: (1~8)", default=5,
                        dest="p_open_cross")
    parser.add_argument("--cross-init-mode", type=int, help="cross init mode: 1 -- specify, 2 -- random, 3 -- close",
                        default=1, dest="cross_init_mode")

    parser.add_argument("--full-constructor-config", type=str,
                        help="Path to the JSON file with constructor args for all contracts.",
                        dest="full_constructor_config")

    parser.add_argument("--duplication", type=str, help="duplication mode: 0 -- close, 1 -- open", default='0',
                        dest="duplication")

    parser.add_argument("--sequence-template", type=str,
                        help="Path to the JSON file with the function sequence template.",
                        dest="sequence_template")

    add_txracer_arguments(parser)


    parser.add_argument("-v", "--version", action="version", version="TxRacer")

    args = parser.parse_args()
    try:
        args.txracer_config = TxRacerConfig.from_namespace(args)
    except ValueError as config_error:
        parser.error(str(config_error))
    inactive_warning = args.txracer_config.inactive_feature_warning()
    if inactive_warning:
        print(f"[!] {inactive_warning}")

    if not args.contract:
        args.contract = ""

    if args.source and args.contract.startswith("0x"):
        parser.error("--source requires --contract to be a name, not an address.")
    if args.source and args.blockchain_state and args.blockchain_state.isnumeric():
        parser.error("--source requires --blockchain-state to be a file, not a number.")

    if args.abi and not args.contract.startswith("0x"):
        parser.error("--abi requires --contract to be an address, not a name.")
    if args.abi and args.blockchain_state and not args.blockchain_state.isnumeric():
        parser.error("--abi requires --blockchain-state to be a number, not a file.")

    if args.evm_version:
        settings.EVM_VERSION = args.evm_version
    if not args.solc_version:
        args.solc_version = solcx.get_solc_version()
    if args.generations:
        settings.GENERATIONS = args.generations
    if args.global_timeout:
        settings.GLOBAL_TIMEOUT = args.global_timeout
    if args.population_size:
        settings.POPULATION_SIZE = args.population_size
    if args.probability_crossover:
        settings.PROBABILITY_CROSSOVER = args.probability_crossover
    if args.probability_mutation:
        settings.PROBABILITY_MUTATION = args.probability_mutation

    if args.data_dependency is None:
        args.data_dependency = 1
    if args.constraint_solving is None:
        args.constraint_solving = 1
    if args.environmental_instrumentation is None:
        args.environmental_instrumentation = 1

    if args.environmental_instrumentation == 1:
        settings.ENVIRONMENTAL_INSTRUMENTATION = True
    elif args.environmental_instrumentation == 0:
        settings.ENVIRONMENTAL_INSTRUMENTATION = False

    if args.max_individual_length:
        settings.MAX_INDIVIDUAL_LENGTH = args.max_individual_length
    if args.max_symbolic_execution:
        settings.MAX_SYMBOLIC_EXECUTION = args.max_symbolic_execution

    if args.abi:
        settings.REMOTE_FUZZING = True

    if args.rpc_host:
        settings.RPC_HOST = args.rpc_host
    if args.rpc_port:
        settings.RPC_PORT = args.rpc_port


    if args.contract is None or args.contract == "" or args.cross_contract == 2:
        args.cross_contract = 2
        args.depend_contracts = []
        args.trans_json_path = None
    else:
        if args.contract is None or args.contract == "":
            print(
                '\033[42;31m!!!!!!if open cross contract mode, you need specify a main contract which will be fuzzed!!!!!!\033[0m')
            print('\033[42;31m!!!!!!use --contract [Example]!!!!!!\033[0m')
            sys.exit(-1)


    if args.trans_json_path is not None:
        settings.TRANS_INFO_JSON_PATH = args.trans_json_path
        print(f'\033[42;31m!!!!!!设置用于存储事务序列信息的json地址{settings.TRANS_INFO_JSON_PATH}!!!!!!\033[0m')
        if os.path.exists(settings.TRANS_INFO_JSON_PATH):
            print(
                f'\033[42;31m!!!!!!用于存储事务序列信息的json地址{settings.TRANS_INFO_JSON_PATH}已经存在了, 现已覆盖!!!!!!\033[0m')
    if args.trans_comp == 1:
        settings.TRANS_COMP_OPEN = True
    elif args.trans_comp == 2:
        settings.TRANS_COMP_OPEN = False
    settings.MAIN_CONTRACT_NAME = args.contract
    settings.SOLC_PATH_CROSS = args.solc_path_cross
    settings.P_OPEN_CROSS = args.p_open_cross
    settings.CROSS_INIT_MODE = args.cross_init_mode
    settings.TRANS_SUPPORT_MODE = args.trans_mode
    if args.duplication == '0':
        settings.DUPLICATION = True
    else:
        settings.DUPLICATION = False
    if settings.SOLC_PATH_CROSS is None:
        print('\033[42;31m!!!!!!you need specify a solc path!!!!!!\033[0m')
        sys.exit(-1)

    return args


def env_results_entries():

    from fuzzer.utils import settings as _settings
    path = _settings.RESULTS_PATH
    if not path or not os.path.exists(path):
        return []
    try:
        with open(path, "r", encoding="utf-8") as handle:
            payload = json.load(handle)
    except (OSError, ValueError):
        return []
    if not isinstance(payload, dict):
        return []
    return [(name, value) for name, value in payload.items()
            if isinstance(value, dict)]


def _extended_campaign_assets(evm):

    from fuzzer.txracer.extended.report import (
        price_display_row,
        read_token_decimals,
    )
    rows = []
    seen_contracts = set()
    findings_path = settings.FINDINGS_LOG_PATH or "findings.jsonl"
    if os.path.exists(findings_path):
        try:
            with open(findings_path, "r", encoding="utf-8") as handle:
                for line in handle:
                    line = line.strip()
                    if not line:
                        continue
                    try:
                        record = json.loads(line)
                    except ValueError:
                        continue
                    if record.get("finding_type") != "FRONT_RUNNING_PROFIT":
                        continue
                    for outcome in ((record.get("oracle") or {}).get(
                            "asset_outcomes") or []):
                        asset_entry = (outcome or {}).get("asset")
                        if not isinstance(asset_entry, (list, tuple)) \
                                or len(asset_entry) < 2:
                            continue
                        standard, contract = (
                            asset_entry[0], asset_entry[1])
                        if standard != "ERC20":
                            continue
                        if contract in seen_contracts:
                            continue
                        seen_contracts.add(contract)
                        decimals, decimals_diag = read_token_decimals(
                            evm, contract)
                        raw_amount = 0
                        try:
                            balance_of = "0x70a08231" + encode_abi(
                                ["address"],
                                [settings.ATTACKER_ACCOUNTS[0]]).hex()
                            output = evm.safe_read_call(
                                settings.ATTACKER_ACCOUNTS[0],
                                contract, balance_of)
                            if output:
                                raw_amount = int.from_bytes(
                                    output, "big")
                        except Exception:  # noqa: BLE001
                            raw_amount = 0
                        rows.append(price_display_row(
                            ("ERC20", contract, None), raw_amount,
                            decimals=decimals,
                            decimals_diagnostic=decimals_diag,
                            price_source=None,
                            asset_source="campaign_finding"))
        except OSError as findings_error:
            rows.append(price_display_row(
                ("ETH", settings.CHAIN_ID, None), 0,
                decimals_diagnostic="findings_read_failed:%s"
                % (findings_error,),
                price_source=None))
    if not rows:
        rows.append(price_display_row(
            ("ETH", settings.CHAIN_ID, None), 0,
            price_source=None))
    return rows


if '__main__' == __name__:
    main()
