#!/usr/bin/env python3


import logging
from datetime import datetime


EVM_VERSION = "petersburg"

POPULATION_SIZE = 10


GENERATIONS = 10


GLOBAL_TIMEOUT = None

PROBABILITY_CROSSOVER = 0.9

PROBABILITY_MUTATION = 0.1

MAX_SYMBOLIC_EXECUTION = 2


SOLVER_TIMEOUT = 100

ATTACKER_ACCOUNTS = ["0xdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef"]



GAS_LIMIT = 2000000000

GAS_PRICE = 1

ACCOUNT_BALANCE = 100000000 * (10 ** 18)

MAX_INDIVIDUAL_LENGTH = 5

LOGGING_LEVEL = logging.INFO

BLOCK_HEIGHT = 'latest'

RPC_HOST = 'localhost'

RPC_PORT = 8545

REMOTE_FUZZING = False

ENVIRONMENTAL_INSTRUMENTATION = True

TRANS_INFO_JSON_PATH = "/tmp/ConFuzzius_trans.json"

TRANS_INFO = {"start_time": str(datetime.now())}
DEPLOYED_CONTRACT_ADDRESS = {}

MAIN_CONTRACT_NAME = ""

OUTPUT_TRANS_INFO = False

SOLC_PATH_CROSS = ""

CROSS_TRANS_EXEC_COUNT = 0

TRANS_MODE = "origin"

TRANS_COMP_OPEN = True
TRANS_SUPPORT_MODE = 1
TRANS_CROSS_BAD_INDVS = []
TRANS_CROSS_BAD_INDVS_HASH = set()
GLOBAL_DATA_INFO = dict()
P_OPEN_CROSS = 5
CROSS_INIT_MODE = 1
DUPLICATION = 0


ASSET_MAP_INFO = None
FINDINGS_LOG_PATH = None
RESULTS_PATH = None
SOURCE_SHA256 = None


PAPER_DESIGN_VERSION = "v1"
MAX_ATTACKER_SEQUENCES_PER_USER = 8
MAX_ATTACKER_MUTATION_DEPTH = 2
USER_PREFILTER_POLICY = "hard"


MAX_ATTACKER_SEQUENCES_PER_VICTIM = MAX_ATTACKER_SEQUENCES_PER_USER
VICTIM_PREFILTER_POLICY = USER_PREFILTER_POLICY


def resolve_actor_role_setting(canonical_name, legacy_name, default):

    canonical_value = globals().get(canonical_name, default)
    legacy_value = globals().get(legacy_name, default)
    if canonical_value == legacy_value:
        return canonical_value
    if canonical_value == default:
        return legacy_value
    if legacy_value == default:
        return canonical_value
    raise ValueError(
        "conflicting values for %s=%r and legacy alias %s=%r"
        % (canonical_name, canonical_value, legacy_name, legacy_value)
    )


ECONOMIC_STATE_POLICY = "validated"
ORACLE_INTERACTION_GATE = False
STOP_ON_FIRST_FINDING = False
LEGACY_FINDING_LOG = False
REPRODUCTION_COMMAND = ""


LEGACY_FIXED_VALUATION = False


SHADOW_ECONOMIC_ORACLE = False
SHADOW_LOG_PATH = "shadow_oracle.jsonl"
ORACLE_THRESHOLD_RATIO = "0"
ORACLE_MIN_ABSOLUTE = 0
CHAIN_ID = 1


PREEMPTION_SCHEDULER = False
MAX_PREEMPTION_POINTS = 2
PREEMPTION_CANDIDATE_CAP = 8
MAX_SCHEDULES_PER_SEED = 128
PREEMPTION_WEIGHT_MODE = "extended"


ASSET_STATE_FEEDBACK = False
STATE_CORPUS_PROBABILITY = "1/2"
COVERAGE_STAGNATION_GENERATIONS = 10


INTENT_ORACLE = False
INTENT_LOG_PATH = None
INTENT_ADAPTERS_PATH = None


OUTER_SEQUENCE_EVOLUTION = False


READONLY_CACHE = False
CACHE_DIR = None


EXTRA_SEED_SCHEDULING = False
PRICE_REPORTING = False
MAX_EXTRA_SCHEDULES = 4
PAPER_FINDINGS_PATH = None


SYMBOLIC_EXECUTION_PATIENCE = 2


SYMBOLIC_EXECUTION_TARGETS = [
    "claim(uint256)",

    "claimForLoot(uint256)",
    "setApprovalForAll(address,bool)",

    "approve(address, uint256)" ,
    "ownerClaim(uint256)",
    "transferOwnership(address)",
    "swap(IERC20, IERC20, uint256, uint256, Utils.Route[] calldata)",
    "burnToken(address,uint256[],string)",
    "burnToken(address,uint256[],string,address)",
    "setRateEngine(address)",
    "increaseAllowance(address,uint256)",
    "burn(uint256)",
    "allowance(address,address)",
    "setTreasury(address,uint128)",
    "renounceOwnership()",
    "burnFrom(address,uint256)",

    "burnToken(address,uint256[],string)",
    "burnToken(address,uint256[],string,address)",


    "setRateEngine(address)",

    "setTransferFunction(string,bytes4)",
    "approveAdmin(address)",
    "revokeAdmin(address)",
    "transferOwnership(address)",


    "transferFrom(address,address,uint256)",
    "approve(address,uint256)",

    "mint(address,uint256)",
    "mintFREE(address , uint256)",


    "withdraw()",


    "setCost(uint256)",
    "pause(bool)",
    "whitelistUser(address)",

     "setSale()",
    "setWhitelistState()",


    "whitelistClaim(uint256,uint256,bytes32[])",

    "short(uint256,uint256,uint256,address[],uint256)",
    "close(uint256,uint256,uint256,address[],uint256)",


    "breedWith(uint256,uint256)",
    "mintGen0Egg()",
    "bid(uint256)",


    "createSale(uint256,uint256,address)",
    "hatchFish(uint256,uint256,uint256)",

    "mintPresale(uint256)",
    "mint(uint256)",
    "upgrade(uint256)",


    "addToPresaleList1(address[])",
    "addToPresaleList2(address[])",
    "setKATz(address)",
    "togglePresaleStatus()",
    "togglePublicSaleStatus()",
    "toggleUpgradeStatus()"

]
