from fractions import Fraction
from typing import Dict, List, Optional

ZERO_SLOT_HINT = None


class StaticCandidate(object):


    def __init__(self, variable, candidate_reason, confidence="1/2",
                 source_location=None, source_hash=None,
                 analyzer_version=None, contract=None, is_mapping=False,
                 slot_hint=None):
        self.variable = variable
        self.contract = contract or variable.split(".")[0]
        self.candidate_reason = list(candidate_reason)

        self.confidence = str(confidence) if isinstance(confidence, str) else str(Fraction(confidence))
        self.source_location = source_location
        self.source_hash = source_hash
        self.analyzer_version = analyzer_version
        self.is_mapping = bool(is_mapping)
        self.slot_hint = slot_hint

    def confidence_fraction(self):
        return Fraction(self.confidence)

    def to_dict(self):
        return {
            "variable": self.variable,
            "contract": self.contract,
            "candidate_reason": sorted(self.candidate_reason),
            "confidence": self.confidence,
            "source_location": self.source_location,
            "source_hash": self.source_hash,
            "analyzer_version": self.analyzer_version,
            "is_mapping": self.is_mapping,
            "slot_hint": self.slot_hint,
        }

    @classmethod
    def from_dict(cls, payload):
        return cls(
            variable=payload["variable"],
            candidate_reason=payload.get("candidate_reason") or [],
            confidence=payload.get("confidence", "1/2"),
            source_location=payload.get("source_location"),
            source_hash=payload.get("source_hash"),
            analyzer_version=payload.get("analyzer_version"),
            contract=payload.get("contract"),
            is_mapping=payload.get("is_mapping", False),
            slot_hint=payload.get("slot_hint"),
        )

    def __repr__(self):
        return "StaticCandidate(%r, %r)" % (self.variable, self.confidence)


def _candidate_sort_key(candidate):

    return (
        -candidate.confidence_fraction(),
        candidate.contract or "",
        candidate.variable,
        candidate.source_location or "",
    )


def sort_static_candidates(candidates):

    return sorted(candidates, key=_candidate_sort_key)


class StaticCandidateIndex(object):


    def __init__(self, candidates=None, source_hash=None,
                 analyzer_version=None):
        self.candidates = list(candidates or [])
        self.source_hash = source_hash
        self.analyzer_version = analyzer_version

    @classmethod
    def from_dicts(cls, payloads, source_hash=None, analyzer_version=None):
        return cls(
            [StaticCandidate.from_dict(p) for p in payloads],
            source_hash=source_hash,
            analyzer_version=analyzer_version,
        )

    def get(self, variable):
        for candidate in self.candidates:
            if candidate.variable == variable:
                return candidate
        return None

    def sorted(self):
        return sort_static_candidates(self.candidates)

    def apply_storage_layout(self, storage_layout):

        by_label = {}
        for entry in (storage_layout or {}).get("storage") or []:
            by_label[entry.get("label")] = entry.get("slot")
        for candidate in self.candidates:
            short_name = candidate.variable.split(".")[-1]
            if short_name in by_label:
                candidate.slot_hint = by_label[short_name]
        return self

    def to_dicts(self):
        return [candidate.to_dict() for candidate in self.candidates]

    def to_dict(self):
        return {
            "source_hash": self.source_hash,
            "analyzer_version": self.analyzer_version,
            "candidates": self.to_dicts(),
        }

    @classmethod
    def from_dict(cls, payload):
        return cls.from_dicts(
            payload.get("candidates") or [],
            source_hash=payload.get("source_hash"),
            analyzer_version=payload.get("analyzer_version"),
        )


def legacy_asset_analysis_to_candidates(legacy_output, source_hash=None,
                                        analyzer_version="legacy_asset_analyse"):

    reason_keywords = {
        "transfer": "written_by_transfer",
        "balance": "name_match",
        "allowance": "name_match",
        "supply": "name_match",
        "owner": "name_match",
        "deposit": "written_by_transfer",
        "withdraw": "written_by_transfer",
        "claim": "written_by_transfer",
    }
    candidates = []
    for canonical_name, info in sorted(legacy_output.items()):
        reasons = [info.get("reason") or "static_analysis"]
        lowered = canonical_name.lower()
        for keyword, reason in reason_keywords.items():
            if keyword in lowered and reason not in reasons:
                reasons.append(reason)
        candidates.append(StaticCandidate(
            variable=canonical_name,
            candidate_reason=reasons,
            confidence="1/2",
            source_location=None,
            source_hash=source_hash,
            analyzer_version=analyzer_version,
            is_mapping=bool(info.get("is_mapping")),
            slot_hint=info.get("slot"),
        ))
    return candidates


def analyze_static_candidates(source_file, solc_path=None,
                              analyzer_version="legacy_asset_analyse"):

    import hashlib
    from asset_analyse import AssetAnalyzer
    from slither import Slither
    try:
        with open(str(source_file), "rb") as handle:
            source_bytes = handle.read()
        source_hash = hashlib.sha256(source_bytes).hexdigest()
        slither = Slither(str(source_file), solc=solc_path)
        legacy_output = AssetAnalyzer(slither).run()
    except Exception as analysis_error:
        raise StaticAnalysisError(
            "static candidate analysis failed for %s: %s"
            % (source_file, analysis_error))
    candidates = legacy_asset_analysis_to_candidates(
        legacy_output, source_hash=source_hash,
        analyzer_version=analyzer_version)
    _attach_slither_locations(candidates, slither)
    return StaticCandidateIndex(
        candidates,
        source_hash=source_hash,
        analyzer_version=analyzer_version,
    )


def _attach_slither_locations(candidates, slither):

    by_contract = {}
    for contract in slither.contracts:
        by_contract[contract.name] = contract
    for candidate in candidates:
        contract_name, _, short_name = candidate.variable.rpartition(".")
        if not contract_name:
            continue
        contract = by_contract.get(contract_name)
        if contract is None:
            continue
        state_var = contract.get_state_variable_from_name(short_name)
        if state_var is None or not state_var.source_mapping:
            continue
        mapping = state_var.source_mapping
        filename = mapping.get("filename_absolute") or mapping.get("filename")
        lines = mapping.get("lines")
        location = None
        if filename:
            location = str(filename)
            if lines:
                location = "%s:%s" % (location, lines[0])
        candidate.source_location = location


class StaticAnalysisError(Exception):
    pass


__all__ = [
    "StaticAnalysisError",
    "StaticCandidate",
    "StaticCandidateIndex",
    "analyze_static_candidates",
    "legacy_asset_analysis_to_candidates",
    "sort_static_candidates",
]
