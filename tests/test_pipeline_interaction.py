import json
import os
from pathlib import Path
import unittest

from eth_abi import encode_abi

from test_pipeline_foundation import USER, ATTACKER, tx
from fuzzer.txracer.pipeline.runner import compile_source
from fuzzer.txracer.pipeline.backend.legacy_evm import LegacyExecutionBackend
from fuzzer.txracer.pipeline.core.abi import AbiCatalog
from fuzzer.txracer.pipeline.core.model import Sequence
from fuzzer.txracer.pipeline.core.campaign import TxRacer
from fuzzer.txracer.pipeline.core.user_explorer import ExplorerConfig
from fuzzer.txracer.pipeline.core.attacker_inference import InferenceConfig, PARAMETER, INSERTION, REVERSAL
from fuzzer.txracer.interleaving.scheduler import SchedulerConfig


def asset_fixture():
    solc = os.environ.get("TXRACER_SOLC")
    if not solc:
        raise unittest.SkipTest("Set TXRACER_SOLC for local synthetic EVM tests")
    source = Path(__file__).resolve().parents[1] / "examples/contracts/token_exchange.sol"
    artifacts = compile_source(source, solc)
    token = next(v for k, v in artifacts.items() if k.endswith(":SyntheticToken"))
    exchange = next(v for k, v in artifacts.items() if k.endswith(":SyntheticExchange"))
    backend = LegacyExecutionBackend()
    for account in (USER, ATTACKER):
        backend.fund(account, 10 ** 21)
    token_a, token_b = backend.deploy(USER, token["bin"]), backend.deploy(USER, token["bin"])
    venue = backend.deploy(USER, exchange["bin"] + encode_abi(["address", "address"], [token_a, token_b]).hex(), value=1000)
    for address in (token_a, token_b):
        for account in (USER, ATTACKER, venue):
            backend.execute_transaction(tx(address, "mint(address,uint256)", (account, 100)), "fund-token")
    baseline = backend.snapshot("funded-local-group")
    metadata = [{"name": "TokenA", "address": token_a, "abi": json.loads(token["abi"])},
                {"name": "TokenB", "address": token_b, "abi": json.loads(token["abi"])},
                {"name": "Exchange", "address": venue, "abi": json.loads(exchange["abi"])}]
    return backend, baseline, AbiCatalog(metadata), venue


class InteractionTests(unittest.TestCase):
    def test_three_operators_through_real_campaign_callback(self):
        backend, baseline, catalog, venue = asset_fixture()
        planner = [{"contract": "Exchange", "signature": signature} for signature in
                   ("prepare(uint256)", "forward(uint256)", "reverse(uint256)")]
        campaign = TxRacer(backend, baseline, catalog, USER, ATTACKER, [USER, ATTACKER], planner,
                            ExplorerConfig(solve=False), InferenceConfig(candidate_budget=32, max_depth=1),
                            SchedulerConfig(max_interaction_depth=3, global_seed=11))

        pairs = []
        campaign.on_pair = lambda observation, pair: pairs.append(pair)


        sequence = Sequence([tx(venue, "prepare(uint256)", (3,)),
                             tx(venue, "forward(uint256)", (1,)),
                             tx(venue, "reverse(uint256)", (1,))])
        campaign.explorer.enqueue(sequence, "synthetic_preparation")
        observation = campaign.explorer.execute_next()
        self.assertEqual(observation.result.status, "SUCCESS")
        self.assertIn((venue, 2), observation.economic_states, observation.diagnostics)
        events = campaign.inference.events
        for operator in (PARAMETER, INSERTION, REVERSAL):
            self.assertTrue(any(e["operator"] == operator and e["generated"] > 0 and e["admitted"] > 0 for e in events), events)
            self.assertTrue(any(operator in p["candidate"].operators for p in pairs))
        self.assertEqual(len(pairs), campaign.pairs.total)
        self.assertLessEqual(len(campaign.pairs), campaign.memory_config.pairs)
        self.assertTrue(any(p["points"] for p in pairs))
        self.assertTrue(any(p["outcomes"] for p in pairs))
        self.assertTrue(any(e.get("depth") == 2 for e in campaign.interaction.events))
        for pair in pairs:
            self.assertEqual(pair["schedules"].anchor_reuse_count, 2)
            for schedule, execution, oracle in pair["outcomes"]:
                self.assertEqual(execution.baseline, baseline)
                self.assertTrue(oracle.interaction_gate)
                self.assertEqual({r.tx_id for r in execution.records}, {r.tx_id for r in pair["anchors"][0].records})
        self.assertEqual(sequence[0].sender, USER)

    def test_state_insertion_evidence_uses_contract_qualified_function_keys(self):
        backend, baseline, catalog, venue = asset_fixture()
        campaign = TxRacer(backend, baseline, catalog, USER, ATTACKER, [USER, ATTACKER],
                            [{"contract": "Exchange", "signature": "prepare(uint256)"}],
                            ExplorerConfig(solve=False), InferenceConfig(candidate_budget=8, max_depth=1))
        sequence = Sequence([tx(venue, "forward(uint256)", (1,))])
        campaign.explorer.enqueue(sequence, "synthetic")
        campaign.explorer.execute_next()
        context = campaign.contexts[-1]
        self.assertTrue(all(len(key) == 2 and key[0].startswith("0x") for key in context.function_rw))
        self.assertFalse(any(REVERSAL in p["candidate"].operators for p in campaign.pairs))
        self.assertTrue(any(d[0] == "UNSUPPORTED_FLOW_REVERSAL" for d in context.diagnostics))


if __name__ == "__main__":
    unittest.main()
