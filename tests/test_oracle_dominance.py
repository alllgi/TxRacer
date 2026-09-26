from copy import deepcopy
from dataclasses import replace
import json
from types import SimpleNamespace
import unittest

from fuzzer.txracer.oracles.front_running import FrontRunningOracle, OracleConfig, FRONT_RUNNING_PROFIT, NONE
from fuzzer.txracer.pipeline.core.interaction import OracleInput, complete_asset_comparison
from fuzzer.txracer.pipeline.core.model import AssetObservationFailure, Baseline, ExecutionResult, Sequence


USER = "0x" + "11" * 20
ATTACKER = "0x" + "22" * 20
A = ("ERC20", "0x" + "aa" * 20, None)
B = ("ERC20", "0x" + "bb" * 20, None)
ETH = ("ETH", "1", None)


def snapshot(user, attacker, records=()):
    return SimpleNamespace(assets={"user": dict(user), "attacker": dict(attacker)},
                           tx_results=records, user_addr=USER, attacker_addr=ATTACKER)


def evaluate(baseline, candidate, ratio="3/100", min_absolute=0, flipped=True, **options):
    return FrontRunningOracle(OracleConfig(threshold_ratio=ratio, min_absolute=min_absolute, **options)).evaluate(
        baseline, candidate, interaction_gate=True, paper_design_version="v2",
        reversed_preemption_pairs=[{"user_tx_id": "user-0", "attacker_tx_id": "attacker-0"}] if flipped else [])


def old_same_asset(baseline, candidate, ratio="3/100"):

    from fractions import Fraction
    eta = Fraction(ratio)
    keys = set().union(*(set(s.assets[role]) for s in (baseline, candidate) for role in ("user", "attacker")))
    return any(
        candidate.assets["attacker"].get(asset, 0) - baseline.assets["attacker"].get(asset, 0)
        > baseline.assets["attacker"].get(asset, 0) * eta
        and baseline.assets["user"].get(asset, 0) - candidate.assets["user"].get(asset, 0)
        > baseline.assets["user"].get(asset, 0) * eta for asset in keys)


class DominanceTests(unittest.TestCase):
    def test_A_same_asset_and_B_separate_assets(self):
        baseline = snapshot({A: 100, B: 100}, {A: 100, B: 100})
        for name, candidate, old_positive in (
                ("A", snapshot({A: 90, B: 100}, {A: 110, B: 100}), True),
                ("B", snapshot({A: 100, B: 95}, {A: 110, B: 100}), False)):
            with self.subTest(case=name):
                result = evaluate(baseline, candidate)
                self.assertEqual(result.classification, FRONT_RUNNING_PROFIT)
                self.assertEqual(old_same_asset(baseline, candidate), old_positive)
                self.assertTrue(result.attacker_non_decreasing and result.user_non_increasing)
                self.assertEqual(result.significant_attacker_gain_assets, [A])
                self.assertEqual(result.significant_user_loss_assets, [A] if name == "A" else [B])
                self.assertEqual(set(result.confirmed_assets), {A} if name == "A" else {A, B})

    def test_C_attacker_mixed_outcome_and_D_user_mixed_outcome(self):
        baseline = snapshot({A: 100, B: 100}, {A: 100, B: 100})
        cases = (("C", snapshot({A: 90, B: 100}, {A: 110, B: 80}), False, True),
                 ("D", snapshot({A: 90, B: 120}, {A: 110, B: 100}), True, False))
        for name, candidate, attacker_ok, user_ok in cases:
            with self.subTest(case=name):
                result = evaluate(baseline, candidate)
                self.assertNotEqual(result.classification, FRONT_RUNNING_PROFIT)
                self.assertFalse(result.confirmed_assets)
                self.assertEqual(result.attacker_non_decreasing, attacker_ok)
                self.assertEqual(result.user_non_increasing, user_ok)
                self.assertTrue(old_same_asset(baseline, candidate))

    def test_E_unchanged_and_F_no_ordering_interaction(self):
        baseline = snapshot({A: 100, B: 100}, {A: 100, B: 100})
        unchanged = evaluate(baseline, deepcopy(baseline))
        self.assertEqual(unchanged.classification, NONE)
        self.assertFalse(unchanged.confirmed_assets)
        candidate = snapshot({A: 100, B: 95}, {A: 110, B: 100})
        no_flip = evaluate(baseline, candidate, flipped=False)
        self.assertFalse(no_flip.confirmed_assets)
        self.assertFalse(any(outcome.confirmed for outcome in no_flip.asset_outcomes.values()))
        self.assertIn("no_reversed_preemption_pair", " ".join(no_flip.reasons))

    def test_tiny_adverse_changes_still_veto_dominance(self):
        baseline = snapshot({A: 1000, B: 1000}, {A: 1000, B: 1000})
        for candidate in (snapshot({A: 900, B: 1000}, {A: 1100, B: 999}),
                          snapshot({A: 900, B: 1001}, {A: 1100, B: 1000})):
            self.assertFalse(evaluate(baseline, candidate).confirmed_assets)

    def test_eta_is_strict_and_independent_for_each_role_dimension(self):
        baseline = snapshot({A: 1000, B: 100}, {A: 1000, B: 100})
        for gain, loss, positive in ((30, 4, False), (31, 3, False), (31, 4, True)):
            with self.subTest(gain=gain, loss=loss):
                result = evaluate(baseline, snapshot({A: 1000, B: 100 - loss}, {A: 1000 + gain, B: 100}))
                self.assertEqual(bool(result.confirmed_assets), positive)
                self.assertEqual(result.asset_outcomes[A].attacker_cutoff, 31)
                self.assertEqual(result.asset_outcomes[B].user_cutoff, 4)

    def test_min_absolute_zero_baseline_and_large_exact_integers(self):
        baseline = snapshot({B: 100}, {})
        for gain, loss, positive in ((2, 3, False), (3, 2, False), (3, 3, True)):
            result = evaluate(baseline, snapshot({B: 100 - loss}, {A: gain}), ratio="0", min_absolute=2)
            self.assertEqual(bool(result.confirmed_assets), positive)
        big = 10 ** 30
        baseline = snapshot({B: big}, {A: big})
        cutoff = 3 * 10 ** 28
        self.assertFalse(evaluate(baseline, snapshot({B: big - cutoff}, {A: big + cutoff})).confirmed_assets)
        result = evaluate(baseline, snapshot({B: big - cutoff - 1}, {A: big + cutoff + 1}))
        self.assertTrue(result.confirmed_assets)
        self.assertEqual(result.asset_outcomes[A].attacker_cutoff, cutoff + 1)
        self.assertEqual(result.threshold_ratio, "3/100")

    def test_union_zero_fills_new_and_disappearing_assets(self):
        baseline = snapshot({B: 5}, {})
        candidate = snapshot({}, {A: 10})
        result = evaluate(baseline, candidate)
        self.assertEqual(set(result.asset_outcomes), {A, B})
        self.assertEqual(result.asset_outcomes[A].attacker_gain, 10)
        self.assertEqual(result.asset_outcomes[B].user_loss, 5)
        self.assertTrue(result.confirmed_assets)


        self.assertFalse(evaluate(snapshot({A: 100}, {B: 20}), snapshot({A: 90}, {A: 10})).confirmed_assets)
        self.assertFalse(evaluate(snapshot({A: 100}, {}), snapshot({A: 90, B: 20}, {A: 10})).confirmed_assets)
        self.assertFalse(evaluate(snapshot({}, {}), snapshot({}, {})).confirmed_assets)

    def test_native_balance_is_a_dominance_dimension(self):
        baseline = snapshot({A: 100, ETH: 100}, {A: 100, ETH: 100})
        candidate = snapshot({A: 90, ETH: 100}, {A: 110, ETH: 99})
        self.assertFalse(evaluate(baseline, candidate).confirmed_assets)

    def test_user_revert_retains_baseline_loss_by_default(self):
        baseline = snapshot({B: 100}, {A: 100}, [SimpleNamespace(sender=USER, status="SUCCESS")])
        candidate = snapshot({B: 95}, {A: 110}, [SimpleNamespace(sender=USER, status="REVERT")])
        self.assertTrue(evaluate(baseline, candidate).confirmed_assets)
        self.assertFalse(evaluate(baseline, candidate, suppress_on_user_revert=True).confirmed_assets)

    def test_first_come_claim_displacement_survives_user_revert(self):


        baseline = snapshot({A: 1}, {A: 0}, [SimpleNamespace(sender=USER, status="SUCCESS")])
        candidate = snapshot({A: 0}, {A: 1}, [SimpleNamespace(sender=USER, status="REVERT")])
        result = evaluate(baseline, candidate)
        self.assertEqual(result.classification, FRONT_RUNNING_PROFIT)
        self.assertEqual(result.asset_outcomes[A].user_loss, 1)
        self.assertEqual(result.asset_outcomes[A].attacker_gain, 1)
        self.assertFalse(evaluate(baseline, candidate, flipped=False).confirmed_assets)

    def test_revert_without_acquisition_loss_is_not_a_positive(self):
        baseline = snapshot({A: 0}, {A: 0}, [SimpleNamespace(sender=USER, status="SUCCESS")])
        candidate = snapshot({A: 0}, {A: 1}, [SimpleNamespace(sender=USER, status="REVERT")])
        self.assertFalse(evaluate(baseline, candidate).confirmed_assets)

    def test_nft_changes_do_not_supply_economic_gain_or_loss(self):
        for standard in ("ERC721", "ERC1155"):
            nft = (standard, "0x" + "cc" * 20, 1)
            result = evaluate(snapshot({nft: 1, B: 100}, {}), snapshot({B: 95}, {nft: 1}))
            self.assertFalse(result.confirmed_assets)
            self.assertFalse(result.significant_attacker_gain_assets)
            self.assertIn("IntentOracle", " ".join(result.reasons))

    def test_serialization_identifies_global_evidence_and_does_not_mutate_inputs(self):
        baseline, candidate = snapshot({B: 100}, {A: 100}), snapshot({B: 95}, {A: 110})
        before = deepcopy((baseline.assets, candidate.assets))
        result = evaluate(baseline, candidate)
        payload = json.loads(json.dumps(result.to_dict()))
        self.assertEqual(payload["comparison"], "component_wise_dominance")
        self.assertEqual(payload["significant_attacker_gain_assets"], [list(A)])
        self.assertEqual(payload["significant_user_loss_assets"], [list(B)])
        self.assertEqual((baseline.assets, candidate.assets), before)
        self.assertEqual(result.to_dict(), evaluate(baseline, candidate).to_dict())


class PipelineComparisonAdapterTests(unittest.TestCase):
    def test_sparse_complete_results_reach_union_comparison(self):
        baseline = Baseline("post-setup", "synthetic")
        first = ExecutionResult(Sequence(()), baseline, (), ((USER, B, 5),))
        second = replace(first, asset_balances=((ATTACKER, A, 10),))
        self.assertTrue(complete_asset_comparison(first, second, USER, ATTACKER))
        result = evaluate(OracleInput(first, USER, ATTACKER), OracleInput(second, USER, ATTACKER))
        self.assertEqual(result.classification, FRONT_RUNNING_PROFIT)

    def test_explicit_failure_or_missing_required_query_remains_unsupported(self):
        baseline = Baseline("post-setup", "synthetic")
        first = ExecutionResult(Sequence(()), baseline, (), ((USER, B, 5),))
        sparse = replace(first, asset_balances=((ATTACKER, A, 10),))
        failed = replace(sparse, asset_observation_failures=(
            AssetObservationFailure(USER, B, "unavailable", "query reverted", "REVERT"),))
        missing_required = replace(sparse, asset_queries=((USER, B), (ATTACKER, A)))
        for incomplete in (failed, missing_required):
            self.assertFalse(complete_asset_comparison(first, incomplete, USER, ATTACKER))
            self.assertFalse(complete_asset_comparison(incomplete, first, USER, ATTACKER))


if __name__ == "__main__":
    unittest.main()
