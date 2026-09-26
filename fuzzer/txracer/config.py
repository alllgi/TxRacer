from argparse import ArgumentParser, Namespace
from dataclasses import dataclass
from fractions import Fraction
from typing import List, Optional, Sequence

from fuzzer.txracer.compat import legacy_keyword_aliases


WEIGHT_MODE_PAPER = "paper"
WEIGHT_MODE_EXTENDED = "extended"
SUPPORTED_WEIGHT_MODES = (WEIGHT_MODE_PAPER, WEIGHT_MODE_EXTENDED)


SUPPORTED_MODES = ("legacy", "paper", "extended")
SUPPORTED_EXECUTION_BACKENDS = ("legacy",)


DEFAULT_FINDINGS_LOG = "findings.jsonl"


def resolve_findings_log_path(findings_log):

    return findings_log if findings_log else DEFAULT_FINDINGS_LOG


def parse_exact_ratio(value, name="threshold_ratio"):

    if isinstance(value, Fraction):
        ratio = value
    elif isinstance(value, int) and not isinstance(value, bool):
        ratio = Fraction(value)
    elif isinstance(value, str):
        text = value.strip()
        if not text:
            raise ValueError("invalid %s: empty value" % name)
        try:
            ratio = Fraction(text)
        except (ValueError, ZeroDivisionError) as parse_error:
            raise ValueError("invalid %s: %r (%s)" % (name, value, parse_error))
    else:
        raise ValueError(
            "invalid %s type: %r (float is not allowed; use a decimal or "
            "a/b string)" % (name, type(value).__name__)
        )
    if ratio.denominator <= 0 or ratio.numerator < 0:
        raise ValueError("%s must be a non-negative rational, got %r" % (name, value))
    return ratio


def parse_probability_ratio(value, name="probability_ratio"):

    ratio = parse_exact_ratio(value, name=name)
    if ratio > 1:
        raise ValueError(
            "%s must be within [0, 1], got %r" % (name, value))
    return ratio


def positive_int(value, name="value"):

    try:
        parsed = int(value)
    except (TypeError, ValueError) as parse_error:
        raise ValueError("%s must be a positive integer, got %r" % (name, value))
    if parsed <= 0:
        raise ValueError("%s must be a positive integer, got %r" % (name, value))
    return parsed


def positive_chain_id(value):

    return positive_int(value, name="chain id")


@dataclass(frozen=True)
class FeatureFlags:
    shadow_economic_oracle: bool = False
    asset_state_feedback: bool = False
    preemption_scheduler: bool = False
    intent_oracle: bool = False
    outer_sequence_evolution: bool = False
    extra_seed_scheduling: bool = False
    price_reporting: bool = False
    readonly_cache: bool = False

    def enabled_names(self) -> List[str]:

        return [
            name
            for name, enabled in (
                ("shadow-economic-oracle", self.shadow_economic_oracle),
                ("asset-state-feedback", self.asset_state_feedback),
                ("preemption-scheduler", self.preemption_scheduler),
                ("intent-oracle", self.intent_oracle),
                ("outer-sequence-evolution", self.outer_sequence_evolution),
                ("extra-seed-scheduling", self.extra_seed_scheduling),
                ("price-reporting", self.price_reporting),
                ("readonly-cache", self.readonly_cache),
            )
            if enabled
        ]

    def reserved_inactive_names(self) -> List[str]:

        return []


@dataclass(frozen=True)
class TxRacerConfig:
    mode: str = "legacy"
    execution_backend: str = "legacy"
    features: FeatureFlags = FeatureFlags()
    asset_map: Optional[str] = None
    findings_log: Optional[str] = None
    stop_on_first_finding: bool = False
    legacy_fixed_valuation: bool = False
    legacy_finding_log: bool = False
    oracle_threshold_ratio: Fraction = Fraction(0)
    oracle_min_absolute: int = 0
    chain_id: int = 1
    max_preemption_points: int = 2
    preemption_candidate_cap: int = 8
    max_schedules_per_seed: int = 128
    preemption_weight_mode: str = "extended"
    state_corpus_probability: Fraction = Fraction(1, 2)
    coverage_stagnation_generations: int = 10
    cache_dir: Optional[str] = None
    intent_adapters: Optional[str] = None
    max_extra_schedules: int = 4
    paper_findings: Optional[str] = None

    paper_design_version: str = "v1"
    max_attacker_sequences_per_user: int = 8
    max_attacker_mutation_depth: int = 2
    user_prefilter_policy: str = "hard"
    economic_state_policy: str = "validated"
    oracle_interaction_gate: bool = False

    def validate(self) -> None:

        if self.mode == "paper" and self.legacy_fixed_valuation:
            raise ValueError(
                "paper mode must not enable --legacy-fixed-valuation: "
                "fixed weights are excluded from finding confirmation"
            )


        if self.paper_design_version not in ("v1", "v2"):
            raise ValueError(
                "--paper-design-version must be v1 or v2, got %r"
                % (self.paper_design_version,))
        for name, value in (
            ("max_attacker_sequences_per_user",
             self.max_attacker_sequences_per_user),
            ("max_attacker_mutation_depth",
             self.max_attacker_mutation_depth),
        ):
            if isinstance(value, bool) or not isinstance(value, int) \
                    or value <= 0:
                raise ValueError(
                    "%s must be a positive integer, got %r"
                    % (name, value))


        extension_flags = (
            ("intent-oracle", self.features.intent_oracle),
            ("outer-sequence-evolution",
             self.features.outer_sequence_evolution),
            ("extra-seed-scheduling",
             self.features.extra_seed_scheduling),
            ("price-reporting", self.features.price_reporting),
            ("readonly-cache", self.features.readonly_cache),
        )
        enabled = [name for name, flag in extension_flags if flag]
        if self.mode == "legacy" and enabled:
            raise ValueError(
                "legacy mode must not enable Phase 5 extension flags: %s"
                % ", ".join(sorted(enabled)))
        for name, value in (
            ("max_extra_schedules", self.max_extra_schedules),
        ):
            if isinstance(value, bool) or not isinstance(value, int) or value <= 0:
                raise ValueError(
                    "%s must be a positive integer, got %r" % (name, value))
        if self.paper_findings and self.mode != "extended":
            raise ValueError(
                "--paper-findings is only meaningful in extended mode")
        if self.mode == "paper":
            for name in ("outer-sequence-evolution",
                         "extra-seed-scheduling", "price-reporting"):
                if name in enabled:
                    raise ValueError(
                        "paper mode must not enable %s: it is an extended "
                        "mode extension (illegal combination fails at "
                        "configuration time)" % name)
        parse_exact_ratio(self.oracle_threshold_ratio)
        if self.oracle_min_absolute < 0:
            raise ValueError("--oracle-min-absolute must be >= 0")
        chain_id = self.chain_id
        if isinstance(chain_id, bool) or not isinstance(chain_id, int) or chain_id <= 0:
            raise ValueError("chain id must be a positive integer, got %r" % (chain_id,))
        for name, value in (
            ("max_preemption_points", self.max_preemption_points),
            ("preemption_candidate_cap", self.preemption_candidate_cap),
            ("max_schedules_per_seed", self.max_schedules_per_seed),
        ):
            if isinstance(value, bool) or not isinstance(value, int) or value <= 0:
                raise ValueError("%s must be a positive integer, got %r" % (name, value))
        if self.preemption_weight_mode not in SUPPORTED_WEIGHT_MODES:
            raise ValueError(
                "unsupported preemption weight mode: %r" % (self.preemption_weight_mode,)
            )
        parse_exact_ratio(self.state_corpus_probability,
                          name="state-corpus-probability")
        if self.state_corpus_probability > 1:
            raise ValueError(
                "state-corpus-probability must be within [0, 1], got %r"
                % (self.state_corpus_probability,))
        if isinstance(self.coverage_stagnation_generations, bool) or \
                not isinstance(self.coverage_stagnation_generations, int) or \
                self.coverage_stagnation_generations <= 0:
            raise ValueError(
                "coverage-stagnation-generations must be a positive "
                "integer, got %r" % (self.coverage_stagnation_generations,))

    @classmethod
    def from_namespace(cls, namespace: Namespace) -> "TxRacerConfig":
        max_attacker_sequences_per_user = _namespace_compat_value(
            namespace,
            "max_attacker_sequences_per_user",
            ("legacy_max_attacker_sequences_per_victim",
             "max_attacker_sequences_per_victim"),
            8,
        )
        max_attacker_mutation_depth = _namespace_compat_value(
            namespace,
            "max_attacker_mutation_depth",
            (),
            2,
        )
        config = cls(
            mode=namespace.txracer_mode,
            execution_backend=namespace.execution_backend,
            features=FeatureFlags(
                shadow_economic_oracle=namespace.shadow_economic_oracle,
                asset_state_feedback=namespace.asset_state_feedback,
                preemption_scheduler=namespace.preemption_scheduler,
                intent_oracle=namespace.intent_oracle,
                outer_sequence_evolution=namespace.outer_sequence_evolution,
                extra_seed_scheduling=namespace.extra_seed_scheduling,
                price_reporting=namespace.price_reporting,
                readonly_cache=namespace.readonly_cache,
            ),
            asset_map=namespace.asset_map,
            findings_log=namespace.findings_log,
            stop_on_first_finding=namespace.stop_on_first_finding,
            legacy_fixed_valuation=namespace.legacy_fixed_valuation,
            legacy_finding_log=namespace.legacy_finding_log,
            oracle_threshold_ratio=namespace.oracle_threshold_ratio,
            oracle_min_absolute=namespace.oracle_min_absolute,
            chain_id=namespace.chain_id,
            max_preemption_points=namespace.max_preemption_points,
            preemption_candidate_cap=namespace.preemption_candidate_cap,
            max_schedules_per_seed=namespace.max_schedules_per_seed,
            preemption_weight_mode=(
                WEIGHT_MODE_PAPER
                if namespace.txracer_mode == "paper"
                else namespace.preemption_weight_mode
            ),
            state_corpus_probability=namespace.state_corpus_probability,
            coverage_stagnation_generations=(
                namespace.coverage_stagnation_generations),
            cache_dir=namespace.cache_dir,
            intent_adapters=namespace.intent_adapters,
            max_extra_schedules=namespace.max_extra_schedules,
            paper_findings=namespace.paper_findings,
            paper_design_version=namespace.paper_design_version,
            max_attacker_sequences_per_user=max_attacker_sequences_per_user,
            max_attacker_mutation_depth=max_attacker_mutation_depth,
            user_prefilter_policy="hard",
            economic_state_policy="validated",
            oracle_interaction_gate=False,
        )
        config.validate()
        if config.paper_design_version == "v2":
            from dataclasses import replace


            config = replace(
                config,
                features=FeatureFlags(
                    shadow_economic_oracle=(
                        config.features.shadow_economic_oracle),
                    asset_state_feedback=True,
                    preemption_scheduler=True,
                    intent_oracle=config.features.intent_oracle,
                    outer_sequence_evolution=(
                        config.features.outer_sequence_evolution),
                    extra_seed_scheduling=(
                        config.features.extra_seed_scheduling),
                    price_reporting=config.features.price_reporting,
                    readonly_cache=config.features.readonly_cache,
                ),
                user_prefilter_policy="priority-only",
                economic_state_policy="explicit-dependency",
                oracle_interaction_gate=True)
        return config

    def inactive_feature_warning(self) -> str:
        enabled = self.features.reserved_inactive_names()
        if not enabled:
            return ""
        return (
            "Parsed but not yet activated reserved feature flags: "
            + ", ".join(enabled)
        )

    @property
    def max_attacker_sequences_per_victim(self):

        return self.max_attacker_sequences_per_user


    @property
    def victim_prefilter_policy(self):

        return self.user_prefilter_policy


TxRacerConfig.__init__ = legacy_keyword_aliases(
    max_attacker_sequences_per_victim="max_attacker_sequences_per_user",
    victim_prefilter_policy="user_prefilter_policy",
)(TxRacerConfig.__init__)


def _namespace_compat_value(namespace, canonical_name, legacy_names, default):

    values = []
    for name in (canonical_name,) + tuple(legacy_names):
        if hasattr(namespace, name):
            value = getattr(namespace, name)
            if value is not None:
                values.append((name, value))
    if not values:
        return default
    selected_name, selected_value = values[0]
    for name, value in values[1:]:
        if value != selected_value:
            raise ValueError(
                "conflicting values for %s=%r and %s=%r"
                % (selected_name, selected_value, name, value)
            )
    return selected_value


def add_txracer_arguments(parser: ArgumentParser) -> None:
    group = parser.add_argument_group("TxRacer attack analysis")
    group.add_argument(
        "--mode",
        dest="txracer_mode",
        choices=SUPPORTED_MODES,
        default="legacy",
        help="TxRacer behavior mode (Phase 1 supports: legacy, paper).",
    )
    group.add_argument(
        "--execution-backend",
        choices=SUPPORTED_EXECUTION_BACKENDS,
        default="legacy",
        help="Execution backend (Phase 0 supports only: legacy).",
    )
    group.add_argument(
        "--shadow-economic-oracle",
        action="store_true",
        help="Phase 2-activated shadow economic oracle (default off): "
             "runs the per-asset economic oracle on the full planned "
             "schedule and records structured diffs without changing "
             "legacy findings.",
    )
    group.add_argument(
        "--asset-state-feedback",
        action="store_true",
        help="Phase 4-activated dynamic asset state feedback (default off): "
             "captures asset flows, validates concrete asset slots, "
             "maintains the min/max state corpus and feeds the Phase 3 "
             "prefilter and paper/extended asset weights with the same "
             "validated evidence.",
    )
    group.add_argument(
        "--preemption-scheduler",
        action="store_true",
        help="Phase 3-activated deterministic preemption scheduler "
             "(default off): replaces the legacy scenario B interleaving "
             "with exhaustive depth-1/2 exploration and fixed-budget "
             "stochastic depth-3..D exploration.",
    )
    group.add_argument(
        "--intent-oracle",
        action="store_true",
        help="Phase 5-B-activated IntentOracle (default off): NFT / claim / "
             "role / governance preemption classified SEPARATELY from the "
             "economic oracle; never produces FRONT_RUNNING_PROFIT and "
             "never changes paper economic findings.",
    )
    group.add_argument(
        "--outer-sequence-evolution",
        action="store_true",
        help="Phase 5-C-activated stagnation-driven outer sequence "
             "evolution (default off; only meaningful in extended mode): "
             "runs only after coverage/asset stagnation or cross-contract "
             "dependency failure, and never changes a paper base run.",
    )
    group.add_argument(
        "--extra-seed-scheduling",
        action="store_true",
        help="Deprecated Phase 5-E compatibility flag (default off; "
             "extended mode only); PP-priority extra scheduling is excluded "
             "from the final interleaving algorithm.",
    )
    group.add_argument(
        "--price-reporting",
        action="store_true",
        help="Phase 5-E price/decimals display extension (default off; "
             "display only, never used for finding confirmation).",
    )
    group.add_argument(
        "--readonly-cache",
        action="store_true",
        help="Phase 5-D read-only cache extension (default off): compile, "
             "Slither, ABI encoding and deployment-artifact caches with "
             "safe-miss semantics; results are bit-identical cold vs hot.",
    )
    group.add_argument(
        "--cache-dir",
        dest="cache_dir",
        default=None,
        help="Phase 5-D cache directory (default: .txracer_cache under the "
             "working directory when --readonly-cache is on).",
    )
    group.add_argument(
        "--intent-adapters",
        dest="intent_adapters",
        default=None,
        help="Phase 5-B optional versioned IntentOracle adapter config JSON "
             "(default: built-in ownerOf/balanceOf-style adapters).",
    )
    group.add_argument(
        "--max-extra-schedules",
        dest="max_extra_schedules",
        type=lambda value: positive_int(value,
                                        name="max-extra-schedules"),
        default=4,
        help="Deprecated Phase 5-E compatibility value (default 4; paper "
             "mode still rejects the extension flag); the final scheduler "
             "does not append PP-priority extra schedules.",
    )
    group.add_argument(
        "--paper-design-version",
        dest="paper_design_version",
        choices=("v1", "v2"),
        default="v1",
        help="Phase 6 paper design version: v1 keeps the Phase 5 "
             "copy/prune attacker derivation, hard prefilter and "
             "existing oracle; v2 enables the new semantic attacker "
             "derivation, economic-state policy, priority-only user "
             "prefilter and the P_delta oracle interaction gate. "
             "Selecting v2 ACTIVATES the necessary paths itself "
             "(preemption scheduler + asset state feedback are implied) "
             "-- it never silently runs the old path (default v1).",
    )
    group.add_argument(
        "--max-attacker-sequences-per-user",
        dest="max_attacker_sequences_per_user",
        type=lambda value: positive_int(
            value, name="max-attacker-sequences-per-user"),
        default=None,
        help="Phase 6 v2 attacker derivation budget K_r per user sequence "
             "including the base candidate Sr0 (default 8).",
    )
    group.add_argument(
        "--max-attacker-sequences-per-victim",
        dest="legacy_max_attacker_sequences_per_victim",
        type=lambda value: positive_int(
            value, name="max-attacker-sequences-per-victim"),
        default=None,
        help="Deprecated alias for --max-attacker-sequences-per-user.",
    )
    group.add_argument(
        "--max-attacker-mutation-depth",
        dest="max_attacker_mutation_depth",
        type=lambda value: positive_int(
            value, name="max-attacker-mutation-depth"),
        default=None,
        help="Phase 6 v2 attacker derivation maximum mutation depth "
             "(default 2).",
    )
    group.add_argument(
        "--paper-findings",
        dest="paper_findings",
        default=None,
        help="Phase 5-E extended mode: paper-mode findings.jsonl path to "
             "align with this extended run for the paper-vs-extended "
             "difference report.",
    )
    group.add_argument(
        "--asset-map",
        dest="asset_map",
        default=None,
        help="Optional asset variable map JSON. When provided it must exist "
             "and be valid; absence is a fatal error.",
    )
    group.add_argument(
        "--findings-log",
        dest="findings_log",
        default=None,
        help="Append-only JSONL log for findings (default: %s; "
             "never overwrites history)." % DEFAULT_FINDINGS_LOG,
    )
    group.add_argument(
        "--stop-on-first-finding",
        dest="stop_on_first_finding",
        action="store_true",
        help="Stop the campaign gracefully after the first recorded finding.",
    )
    group.add_argument(
        "--legacy-fixed-valuation",
        dest="legacy_fixed_valuation",
        action="store_true",
        help="Opt-in legacy fixed-weight valuation reporting plugin "
             "(default off; rejected in paper mode).",
    )
    group.add_argument(
        "--legacy-finding-log",
        dest="legacy_finding_log",
        action="store_true",
        help="Opt-in legacy plain-text vulnerabilities.log writer "
             "(default off; appends instead of overwriting).",
    )
    group.add_argument(
        "--oracle-threshold-ratio",
        dest="oracle_threshold_ratio",
        type=parse_exact_ratio,
        default=Fraction(0),
        help="Phase 2 economic oracle proportional threshold as an exact "
             "decimal or a/b fraction (default 0: strict deltas; legacy 3/100); never rounded through "
             "float.",
    )
    group.add_argument(
        "--oracle-min-absolute",
        dest="oracle_min_absolute",
        type=int,
        default=0,
        help="Phase 2 economic oracle minimum absolute threshold per asset "
             "(engineering mode; paper mode forces 0).",
    )
    group.add_argument(
        "--chain-id",
        dest="chain_id",
        type=positive_chain_id,
        default=1,
        help="Positive chain id used for ETH AssetId and recorded in shadow "
             "records (default 1).",
    )
    group.add_argument(
        "--max-preemption-points",
        dest="max_preemption_points",
        type=lambda value: positive_int(value, name="max-preemption-points"),
        default=2,
        help="Final interleaving scheduler: legacy option name retained; "
             "the value is the maximum interaction depth D (default 2).",
    )
    group.add_argument(
        "--preemption-candidate-cap",
        dest="preemption_candidate_cap",
        type=lambda value: positive_int(value, name="preemption-candidate-cap"),
        default=8,
        help="Legacy compatibility option (default 8); the final scheduler "
             "uses the complete preemption-point set and does not cap it.",
    )
    group.add_argument(
        "--max-schedules-per-seed",
        dest="max_schedules_per_seed",
        type=lambda value: positive_int(value, name="max-schedules-per-seed"),
        default=128,
        help="Legacy compatibility option (default 128); the final shallow "
             "layer is exhaustive and deep execution uses its fixed budget.",
    )
    group.add_argument(
        "--preemption-weight-mode",
        dest="preemption_weight_mode",
        choices=SUPPORTED_WEIGHT_MODES,
        default="extended",
        help="Legacy PP reporting weight mode: extended (default) or paper "
             "(paper mode forces paper); it does not rank or select PPs in "
             "the final scheduler.",
    )
    group.add_argument(
        "--state-corpus-probability",
        dest="state_corpus_probability",
        type=parse_probability_ratio,
        default=Fraction(1, 2),
        help="Phase 4 dual-corpus selection probability for the state "
             "corpus as an exact decimal or a/b fraction within [0, 1] "
             "(default 1/2); never rounded through float.",
    )
    group.add_argument(
        "--coverage-stagnation-generations",
        dest="coverage_stagnation_generations",
        type=lambda value: positive_int(
            value, name="coverage-stagnation-generations"),
        default=10,
        help="Phase 4 coverage stagnation threshold: rebuild the population "
             "after this many generations without new coverage (default 10).",
    )


def append_txracer_arguments(command: List[str], config: TxRacerConfig) -> None:
    command.extend(["--mode", config.mode])
    command.extend(["--execution-backend", config.execution_backend])
    for name in config.features.enabled_names():
        command.append("--" + name)
    if config.cache_dir:
        command.extend(["--cache-dir", config.cache_dir])
    if config.intent_adapters:
        command.extend(["--intent-adapters", config.intent_adapters])
    command.extend(["--max-extra-schedules",
                    str(config.max_extra_schedules)])
    if config.paper_findings:
        command.extend(["--paper-findings", config.paper_findings])
    command.extend(["--paper-design-version",
                    config.paper_design_version])
    command.extend(["--max-attacker-sequences-per-user",
                    str(config.max_attacker_sequences_per_user)])
    command.extend(["--max-attacker-mutation-depth",
                    str(config.max_attacker_mutation_depth)])
    if config.asset_map:
        command.extend(["--asset-map", config.asset_map])
    if config.findings_log:
        command.extend(["--findings-log", config.findings_log])
    if config.stop_on_first_finding:
        command.append("--stop-on-first-finding")
    if config.legacy_fixed_valuation:
        command.append("--legacy-fixed-valuation")
    if config.legacy_finding_log:
        command.append("--legacy-finding-log")
    command.extend(["--oracle-threshold-ratio", str(config.oracle_threshold_ratio)])
    if config.oracle_min_absolute:
        command.extend(["--oracle-min-absolute", str(config.oracle_min_absolute)])
    command.extend(["--chain-id", str(config.chain_id)])
    command.extend(["--max-preemption-points", str(config.max_preemption_points)])
    command.extend(["--preemption-candidate-cap", str(config.preemption_candidate_cap)])
    command.extend(["--max-schedules-per-seed", str(config.max_schedules_per_seed)])
    command.extend(["--preemption-weight-mode", config.preemption_weight_mode])
    command.extend(["--state-corpus-probability",
                    str(config.state_corpus_probability)])
    command.extend(["--coverage-stagnation-generations",
                    str(config.coverage_stagnation_generations)])


def parse_txracer_config(arguments: Sequence[str]) -> TxRacerConfig:

    parser = ArgumentParser(add_help=False)
    add_txracer_arguments(parser)
    namespace = parser.parse_args(arguments)
    return TxRacerConfig.from_namespace(namespace)
