import json
import os
from pathlib import Path
import unittest

from eth_abi import encode_abi
from test_pipeline_foundation import USER, ATTACKER, tx
from fuzzer.txracer.oracles.front_running import FrontRunningOracle, OracleConfig
from fuzzer.txracer.pipeline.runner import compile_source
from fuzzer.txracer.pipeline.backend.legacy_evm import LegacyExecutionBackend
from fuzzer.txracer.pipeline.core.abi import AbiCatalog
from fuzzer.txracer.pipeline.core.campaign import TxRacer, execution_evidence
from fuzzer.txracer.pipeline.core.model import Sequence
from fuzzer.txracer.pipeline.core.interaction import OracleInput
from fuzzer.txracer.pipeline.core.user_explorer import ExplorerConfig
from fuzzer.txracer.pipeline.core.attacker_inference import InferenceConfig


def tiny_case(initial=10 ** 60, failed_observation=False):
    solc = os.environ.get('TXRACER_SOLC')
    if not solc:
        raise unittest.SkipTest('TXRACER_SOLC required for real EVM tests')
    artifacts = compile_source(Path(__file__).parent / 'fixtures/tiny_delta.sol', solc)
    artifact = next(v for k, v in artifacts.items() if k.endswith(':TinyDelta'))
    backend = LegacyExecutionBackend()
    backend.fund(USER, 10 ** 60)
    backend.fund(ATTACKER, initial)
    bytecode = artifact['bin'] + encode_abi(['address', 'address', 'uint256'], [USER, ATTACKER, initial]).hex()
    address = backend.deploy(USER, bytecode, value=1)
    baseline = backend.snapshot('tiny-delta')
    catalog = AbiCatalog([{'name': 'Tiny', 'address': address, 'abi': json.loads(artifact['abi'])}])
    campaign = TxRacer(backend, baseline, catalog, USER, ATTACKER, [USER, ATTACKER],
                        [{'contract': 'Tiny', 'signature': 'claim()'}],
                        ExplorerConfig(seed=17), InferenceConfig(candidate_budget=1, max_depth=0))
    pairs = []
    campaign.on_pair = lambda observation, pair: pairs.append(pair)
    sequence = [tx(address, 'claim()')]
    if failed_observation:
        sequence.append(tx(address, 'invalidateObservation()'))
    campaign.explorer.enqueue(Sequence(sequence), 'deterministic-regression')
    observation = campaign.explorer.execute_next()
    assert all(t.sender == USER for t in observation.result.sequence)
    return backend, campaign, pairs[0]


def shared_comparison(pair):
    ur = pair['anchors'][0]
    schedule, execution, new = next(o for o in pair['outcomes'] if o[2].reversed_preemption_pairs)

    old = FrontRunningOracle(OracleConfig(threshold_ratio='3/100', suppress_on_user_revert=False)).evaluate(
        OracleInput(ur, USER, ATTACKER), OracleInput(execution, USER, ATTACKER),
        reversed_preemption_pairs=new.reversed_preemption_pairs, interaction_gate=True, paper_design_version='v2')
    return ur, execution, new, old


class DeltaTests(unittest.TestCase):
    def test_real_evm_same_snapshot_one_wei_and_one_token_unit(self):
        backend, campaign, pair = tiny_case()
        ur, execution, new, old = shared_comparison(pair)
        self.assertEqual(ur.baseline, execution.baseline)
        self.assertTrue(ur.trustworthy and execution.trustworthy)
        self.assertTrue(ur.assets_complete and execution.assets_complete)
        self.assertTrue(all(r.status == 'SUCCESS' for r in ur.records + execution.records))
        self.assertEqual(len(new.confirmed_assets), 2)
        self.assertFalse(old.confirmed_assets)
        self.assertEqual(new.reversed_preemption_pairs, old.reversed_preemption_pairs)
        self.assertEqual(new.effective_config['suppress_on_user_revert'], old.effective_config['suppress_on_user_revert'])
        for outcome in new.asset_outcomes.values():
            self.assertEqual((outcome.attacker_gain, outcome.user_loss), (1, 1))
            self.assertEqual(outcome.raw_balances['baseline_attacker'], 10 ** 60)
        for original in [ur, execution]:
            replayed = backend.execute_sequence(original.sequence, original.baseline, [r.tx_id for r in original.records])
            self.assertEqual(execution_evidence(original), execution_evidence(replayed))
        finding = campaign.findings[0]
        self.assertEqual(finding['kind'], 'finding')
        self.assertEqual(finding['review_status'], 'unreviewed')
        self.assertTrue(finding['replay']['same_initial_state'])
        self.assertEqual(finding['effective_config']['oracle']['economic_policy'], 'strict_delta')
        self.assertEqual(finding['addresses'], {'user': USER, 'attacker': ATTACKER})
        self.assertTrue(finding['attacker_sequence'])
        self.assertEqual(len(finding['attacker_sequence']), len(finding['attacker_transaction_ids']))
        self.assertTrue(all(tx['sender'] == ATTACKER for tx in finding['attacker_sequence']))
        self.assertTrue(finding['oracle']['actual_flip_points'])
        no_flip = FrontRunningOracle().evaluate(OracleInput(ur, USER, ATTACKER), OracleInput(execution, USER, ATTACKER), [], True)
        self.assertFalse(no_flip.confirmed_assets)

    def test_real_evm_zero_baseline(self):
        _, campaign, pair = tiny_case(initial=0)
        _, _, new, _ = shared_comparison(pair)
        self.assertTrue(new.confirmed_assets)
        for outcome in new.asset_outcomes.values():
            self.assertEqual(outcome.raw_balances['baseline_attacker'], 0)
            self.assertEqual(outcome.attacker_gain, 1)

    def test_real_evm_failed_observations_are_not_zero_balances(self):
        _, campaign, pair = tiny_case(failed_observation=True)
        self.assertFalse(campaign.findings)
        self.assertFalse(pair['outcomes'])
        self.assertTrue(pair['unsupported_comparisons'])
        for anchor in pair['anchors']:
            self.assertFalse(anchor.assets_complete)
            self.assertTrue(anchor.asset_observation_failures)
            self.assertFalse(any(asset[0] == 'ERC20' for _, asset, _ in anchor.asset_balances))
