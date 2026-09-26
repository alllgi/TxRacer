from fractions import Fraction

from fuzzer.txracer.config import parse_exact_ratio
from fuzzer.txracer.oracles.assets import sorted_asset_ids
from fuzzer.utils import settings
from fuzzer.txracer.reporting import stable_finding_id
from fuzzer.txracer.compat import legacy_keyword_aliases


def exact_ratio(value, name="threshold_ratio"):

    return parse_exact_ratio(value, name)


def exact_min_absolute(value):

    if isinstance(value, bool) or not isinstance(value, int) or value < 0:
        raise ValueError("min_absolute must be a non-negative integer, got %r" % (value,))
    return value


class OracleConfig(object):
    @legacy_keyword_aliases(
        suppress_on_victim_revert="suppress_on_user_revert",
    )
    def __init__(self, threshold_ratio="0", min_absolute=0,
                 suppress_on_user_revert=False):
        self.threshold_ratio = exact_ratio(threshold_ratio)
        self.min_absolute = exact_min_absolute(min_absolute)
        self.suppress_on_user_revert = suppress_on_user_revert

    @property
    def suppress_on_victim_revert(self):

        return self.suppress_on_user_revert

    @suppress_on_victim_revert.setter
    def suppress_on_victim_revert(self, value):
        self.suppress_on_user_revert = value

    @property
    def ratio_str(self):

        return str(self.threshold_ratio)

    @property
    def no_threshold(self):
        return self.threshold_ratio == 0 and self.min_absolute == 0

    def to_dict(self):
        return {"economic_policy": "strict_delta" if self.no_threshold else "explicit_threshold",
                "threshold_ratio": self.ratio_str, "min_absolute": self.min_absolute,
                "suppress_on_user_revert": self.suppress_on_user_revert}


class AssetOutcome(object):


    @legacy_keyword_aliases(victim_loss='user_loss', victim_cutoff='user_cutoff')
    def __init__(self, asset_id, attacker_gain, user_loss,
                 attacker_cutoff, user_cutoff, confirmed, no_threshold=False):
        self.asset_id = asset_id
        self.attacker_gain = attacker_gain
        self.user_loss = user_loss
        self.attacker_cutoff = attacker_cutoff
        self.user_cutoff = user_cutoff
        self.attacker_above = attacker_gain > 0 if no_threshold else attacker_gain >= attacker_cutoff
        self.user_above = user_loss > 0 if no_threshold else user_loss >= user_cutoff
        self.confirmed = confirmed
        self.raw_balances = {}



    @property
    def victim_loss(self):

        return self.user_loss

    @victim_loss.setter
    def victim_loss(self, value):
        self.user_loss = value



    @property
    def victim_cutoff(self):

        return self.user_cutoff

    @victim_cutoff.setter
    def victim_cutoff(self, value):
        self.user_cutoff = value



    @property
    def victim_above(self):

        return self.user_above

    @victim_above.setter
    def victim_above(self, value):
        self.user_above = value

    def to_dict(self):
        standard, contract, token_id = self.asset_id
        return {
            "asset": [standard, contract, token_id],
            "raw_balances": self.raw_balances,
            "attacker_delta": self.attacker_gain,
            "user_delta": -self.user_loss,
            "attacker_gain": self.attacker_gain,
            "victim_loss": self.user_loss,
            "attacker_cutoff": self.attacker_cutoff,
            "victim_cutoff": self.user_cutoff,
            "attacker_above": self.attacker_above,
            "victim_above": self.user_above,
            "confirmed": self.confirmed,
        }


class OracleResult(object):
    """Outcome of one economic oracle evaluation."""

    def __init__(self, asset_outcomes, confirmed_assets, reasons,
                 threshold_ratio="0", min_absolute=0):
        self.asset_outcomes = dict(asset_outcomes)
        self.confirmed_assets = list(confirmed_assets)
        self.reasons = list(reasons)
        self.classification = None
        self.threshold_ratio = threshold_ratio
        self.min_absolute = min_absolute
        self.attacker_non_decreasing = False
        self.user_non_increasing = False
        self.significant_attacker_gain_assets = []
        self.significant_user_loss_assets = []
        self.effective_config = {}
        self.user_reverted = False
        self.reversed_preemption_pairs = []

    def to_dict(self):
        return {
            "classification": self.classification,
            "effective_config": self.effective_config,
            "user_reverted": self.user_reverted,
            "actual_flip_points": self.reversed_preemption_pairs,
            "threshold_ratio": self.threshold_ratio,
            "min_absolute": self.min_absolute,
            "comparison": "component_wise_dominance",
            "attacker_non_decreasing": self.attacker_non_decreasing,
            "user_non_increasing": self.user_non_increasing,
            "significant_attacker_gain_assets": [list(asset) for asset in self.significant_attacker_gain_assets],
            "significant_user_loss_assets": [list(asset) for asset in self.significant_user_loss_assets],
            "confirmed_assets": [
                list(asset_id) for asset_id in self.confirmed_assets
            ],
            "asset_outcomes": [
                self.asset_outcomes[asset_id].to_dict()
                for asset_id in sorted_asset_ids(self.asset_outcomes)
            ],
            "reasons": self.reasons,
        }


FRONT_RUNNING_PROFIT = "FRONT_RUNNING_PROFIT"
VICTIM_DOS = "VICTIM_DOS"
GENERIC_ORDER_DEPENDENCY = "GENERIC_ORDER_DEPENDENCY"
NONE = "NONE"


class FrontRunningOracle(object):
    def __init__(self, config=None):
        self.config = config if config is not None else OracleConfig()

    @staticmethod
    def _assets(result, role):

        if role in result.assets:
            return result.assets[role]
        return result.assets[{"user": "victim", "attacker": "attacker"}[role]]

    def evaluate(self, baseline, candidate,
                 reversed_preemption_pairs=None, interaction_gate=False,
                 paper_design_version="v1"):

        outcomes = {}
        nft_reasons = []
        all_ids = (
            set(self._assets(baseline, "user"))
            | set(self._assets(baseline, "attacker"))
            | set(self._assets(candidate, "user"))
            | set(self._assets(candidate, "attacker"))
        )


        min_absolute = self.config.min_absolute
        for asset_id in sorted_asset_ids({key: 0 for key in all_ids}):
            raw = {stage + "_" + role: self._assets(snapshot, role).get(asset_id, 0)
                   for stage, snapshot in (("baseline", baseline), ("candidate", candidate))
                   for role in ("user", "attacker")}
            if any(type(value) is not int or value < 0 for value in raw.values()):
                raise ValueError("Asset balances must be nonnegative raw integers: %r" % (asset_id,))
            attacker_gain = raw["candidate_attacker"] - raw["baseline_attacker"]
            user_loss = raw["baseline_user"] - raw["candidate_user"]
            if self.config.no_threshold:


                attacker_cutoff = user_cutoff = 1
            else:
                p, q = self.config.threshold_ratio.numerator, self.config.threshold_ratio.denominator
                attacker_cutoff = max((raw["baseline_attacker"] * p) // q + 1, min_absolute + 1)
                user_cutoff = max((raw["baseline_user"] * p) // q + 1, min_absolute + 1)


            if asset_id[0] in ("ERC721", "ERC1155"):
                if attacker_gain != 0 or user_loss != 0:
                    nft_reasons.append(
                        "NFT/claim asset change on %s deferred to IntentOracle; "
                        "not an economic finding" % (list(asset_id),)
                    )
            outcomes[asset_id] = AssetOutcome(
                asset_id, attacker_gain, user_loss,
                attacker_cutoff, user_cutoff, False, no_threshold=self.config.no_threshold,
            )
            outcomes[asset_id].raw_balances = raw

        reasons = list(nft_reasons)


        supported = [asset for asset in sorted_asset_ids(outcomes) if asset[0] in ("ETH", "ERC20")]
        attacker_non_decreasing = all(outcomes[asset].attacker_gain >= 0 for asset in supported)
        user_non_increasing = all(outcomes[asset].user_loss >= 0 for asset in supported)
        gain_assets = [asset for asset in supported if outcomes[asset].attacker_above]
        loss_assets = [asset for asset in supported if outcomes[asset].user_above]
        if attacker_non_decreasing and user_non_increasing and gain_assets and loss_assets:
            for asset in set(gain_assets) | set(loss_assets):
                outcomes[asset].confirmed = True
        if not attacker_non_decreasing:
            reasons.append("attacker_asset_decrease_prevents_dominance")
        if not user_non_increasing:
            reasons.append("user_asset_increase_prevents_dominance")
        user_reverted = self._user_reverted(baseline, candidate)
        if user_reverted:
            if self.config.suppress_on_user_revert:
                for outcome in outcomes.values():
                    outcome.confirmed = False
                reasons.append(
                    "victim candidate tx reverted (succeeded in baseline); "
                    "executed victim loss suppressed (holdings preserved)"
                )
            else:
                reasons.append(
                    "user candidate tx reverted (succeeded in baseline); "
                    "baseline post-state acquisition loss retained"
                )

        confirmed_assets = [
            asset_id for asset_id in sorted_asset_ids(outcomes)
            if outcomes[asset_id].confirmed
        ]
        if interaction_gate and confirmed_assets:

            reversed_pairs = list(reversed_preemption_pairs or [])
            if not reversed_pairs:
                for asset_id in confirmed_assets:
                    outcomes[asset_id].confirmed = False
                reasons.append(
                    "no_reversed_preemption_pair: economic conditions "
                    "met but no PP is flipped in the candidate order; "
                    "not confirmed (paper-design-version v2 gate)")
                confirmed_assets = []
        result = OracleResult(
            outcomes, confirmed_assets, reasons,
            threshold_ratio=self.config.ratio_str,
            min_absolute=min_absolute,
        )
        result.attacker_non_decreasing = attacker_non_decreasing
        result.effective_config = self.config.to_dict()
        result.user_reverted = user_reverted
        result.user_non_increasing = user_non_increasing
        result.significant_attacker_gain_assets = gain_assets
        result.significant_user_loss_assets = loss_assets
        result.reversed_preemption_pairs = list(
            reversed_preemption_pairs or [])
        result.interaction_gate = bool(interaction_gate)
        result.paper_design_version = paper_design_version
        result.classification = self.classify(baseline, candidate, result)
        return result

    def classify(self, baseline, candidate, result):

        reasons = result.reasons
        if result.confirmed_assets:
            return FRONT_RUNNING_PROFIT

        for asset_id in sorted_asset_ids(result.asset_outcomes):
            outcome = result.asset_outcomes[asset_id]
            if outcome.attacker_above and not result.significant_user_loss_assets:
                reasons.append(
                    "attacker-only gain on %s without executed victim loss (suppressed)"
                    % (list(asset_id),)
                )
            elif outcome.user_above and not result.significant_attacker_gain_assets:
                reasons.append(
                    "victim-only change on %s without attacker gain (suppressed)"
                    % (list(asset_id),)
                )

        user_reverted = self._user_reverted(baseline, candidate)
        if user_reverted:
            if self._any_attacker_gain_above_threshold(result):
                reasons.append(
                    "attacker gained and user reverted, but the configured "
                    "gain/loss and ordering conditions did not confirm a finding"
                )
                return NONE
            return VICTIM_DOS

        if self._any_state_change(result):
            reasons.append(
                "state changed between baseline and candidate but no economic "
                "confirmation; generic order dependency (hint only)"
            )
            return GENERIC_ORDER_DEPENDENCY

        reasons.append("no state change between baseline and candidate")
        return NONE

    @staticmethod
    def _any_attacker_gain_above_threshold(result):
        return any(
            outcome.attacker_above
            for outcome in result.asset_outcomes.values()
        )

    @staticmethod
    def _any_state_change(result):
        return any(
            outcome.attacker_gain != 0 or outcome.user_loss != 0
            for outcome in result.asset_outcomes.values()
        )

    @staticmethod
    def _user_reverted(baseline, candidate):

        baseline_user = [
            record for record in baseline.tx_results
            if record.sender == baseline.user_addr
        ]
        candidate_user = [
            record for record in candidate.tx_results
            if record.sender == candidate.user_addr
        ]
        for index, record in enumerate(candidate_user):
            if record.status != "SUCCESS":
                if index < len(baseline_user) and baseline_user[index].status == "SUCCESS":
                    return True
        return False


def resolve_oracle_min_absolute(mode, min_absolute):

    if mode == "paper":
        return 0
    return min_absolute


def build_shadow_record(env, indv, legacy_score, baseline, candidate,
                        oracle_result, planned_schedule=None,
                        legacy_executed_prefix=None, mode="legacy", chain_id=1):

    core = {
        "schema_version": 2,
        "mode": mode,
        "chain_id": chain_id,
        "seed": getattr(env, "seed", None),
        "individual_hash": getattr(indv, "hash", None),
        "legacy_vulnerability_score": legacy_score,
        "planned_schedule": list(planned_schedule or []),
        "legacy_executed_prefix": list(legacy_executed_prefix or []),
        "baseline": baseline.to_dict(),
        "shadow_executed_schedule": candidate.to_dict(),
        "oracle": oracle_result.to_dict(),
        "reproduction_command": getattr(settings, "REPRODUCTION_COMMAND", ""),
    }
    core["shadow_id"] = stable_finding_id(core)
    return core


__all__ = [
    "AssetOutcome",
    "FRONT_RUNNING_PROFIT",
    "FrontRunningOracle",
    "GENERIC_ORDER_DEPENDENCY",
    "NONE",
    "OracleConfig",
    "OracleResult",
    "VICTIM_DOS",
    "build_shadow_record",
    "exact_min_absolute",
    "exact_ratio",
    "resolve_oracle_min_absolute",
]
