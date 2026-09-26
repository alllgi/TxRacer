from enum import Enum

from eth_abi import decode_abi, encode_abi
from eth_utils import function_signature_to_4byte_selector
from eth_utils import to_canonical_address

from fuzzer.txracer.planner.sequence_planner import abi_encode_check
from fuzzer.txracer.compat import legacy_keyword_aliases

ADAPTER_SCHEMA_VERSION = 1
INTENT_SCHEMA_VERSION = 1
INTENT_ADAPTER_SCHEMA_ERROR = "intent adapter config invalid"

NFT_OWNERSHIP_PREEMPTION = "NFT_OWNERSHIP_PREEMPTION"
CLAIM_RIGHT_PREEMPTION = "CLAIM_RIGHT_PREEMPTION"
ROLE_OR_GOVERNANCE_PREEMPTION = "ROLE_OR_GOVERNANCE_PREEMPTION"
GENERIC_ORDER_DEPENDENCY = "GENERIC_ORDER_DEPENDENCY"
NONE = "NONE"

INTENT_CLASSIFICATIONS = (
    NFT_OWNERSHIP_PREEMPTION,
    CLAIM_RIGHT_PREEMPTION,
    ROLE_OR_GOVERNANCE_PREEMPTION,
    GENERIC_ORDER_DEPENDENCY,
    NONE,
)


class IntentReadError(Exception):
    pass


class IntentFailure(Enum):


    REVERT = "REVERT"
    READ_FAILED = "READ_FAILED"
    UNSUPPORTED = "UNSUPPORTED"
    INTERNAL_ERROR = "INTERNAL_ERROR"


class IntentReadResult(object):
    def __init__(self, ok, value, failure=None, detail=None):
        self.ok = bool(ok)
        self.value = value
        self.failure = failure
        self.detail = detail

    def to_dict(self):
        return {
            "ok": self.ok,
            "value": self.value,
            "failure": self.failure,
            "detail": self.detail,
        }


class ReadOnlyIntentAdapter(object):


    RETURN_TYPES = {
        "address": ["address"],
        "bool": ["bool"],
        "uint256": ["uint256"],
        "int256": ["int256"],
        "bytes32": ["bytes32"],
    }

    def __init__(self, name, target, selector, arg_types, param_sources,
                 return_interpretation, return_types=None,
                 fixed_args=None, description=None, schema_version=None):
        self.name = name
        self.target = target
        self.selector = selector
        self.arg_types = list(arg_types)
        self.param_sources = list(param_sources)
        self.return_interpretation = return_interpretation
        self.return_types = list(return_types or self.RETURN_TYPES[
            return_interpretation])
        self.fixed_args = dict(fixed_args or {})
        self.description = description or ""
        self.schema_version = schema_version or ADAPTER_SCHEMA_VERSION
        if len(self.param_sources) != len(self.arg_types):
            raise ValueError(
                "adapter %s: %d param sources for %d argument types"
                % (name, len(self.param_sources), len(self.arg_types)))

    @legacy_keyword_aliases(victim_address='user_address')
    def build_args(self, user_address, attacker_address):

        args = []
        for index, source in enumerate(self.param_sources):
            if source in ("user_address", "victim_address", "attacker_address"):
                args.append(
                    user_address
                    if source in ("user_address", "victim_address")
                    else attacker_address
                )
            elif source.startswith("fixed:"):
                key = source[len("fixed:"):]
                args.append(self.fixed_args.get(key))
            else:
                args.append(self.fixed_args.get(source))
        return args

    def to_dict(self):
        return {
            "schema_version": self.schema_version,
            "name": self.name,
            "target": self.target,
            "selector": self.selector,
            "arg_types": list(self.arg_types),
            "param_sources": list(self.param_sources),
            "return_interpretation": self.return_interpretation,
            "return_types": list(self.return_types),
            "fixed_args": dict(self.fixed_args),
            "description": self.description,
            "failure_semantics": (
                "REVERT/READ_FAILED/UNSUPPORTED/INTERNAL_ERROR degrade "
                "the evaluation; never guessed"),
        }

    @classmethod
    def from_dict(cls, payload):
        return cls(
            name=payload["name"],
            target=payload["target"],
            selector=payload["selector"],
            arg_types=payload.get("arg_types") or [],
            param_sources=payload.get("param_sources") or [],
            return_interpretation=payload.get("return_interpretation",
                                              "bool"),
            return_types=payload.get("return_types"),
            fixed_args=payload.get("fixed_args") or {},
            description=payload.get("description"),
            schema_version=payload.get("schema_version"),
        )


DEFAULT_ADAPTERS = {
    "ownerOf": ReadOnlyIntentAdapter(
        name="ownerOf", target=None, selector="ownerOf(uint256)",
        arg_types=["uint256"], param_sources=["fixed:tokenId"],
        return_interpretation="address",
        description="ERC721 exact token ownership"),
    "balanceOf1155": ReadOnlyIntentAdapter(
        name="balanceOf1155", target=None,
        selector="balanceOf(address,uint256)",
        arg_types=["address", "uint256"],
        param_sources=["victim_address", "fixed:tokenId"],
        return_interpretation="uint256",
        description="ERC1155 exact (contract,id) balance"),
}


class IntentEvidence(object):


    def __init__(self, classification, adapter_name, target, selector,
                 args, baseline_value, candidate_value, failure=None,
                 detail=None, suppression=None, block_profile=None,
                 schema_version=None, confidence=None,
                 adapter_provenance=None, stage=None,
                 schedule_identity=None, baseline_read=None,
                 candidate_read=None, standard=None, token_id=None):
        self.classification = classification
        self.adapter_name = adapter_name
        self.target = target
        self.selector = selector
        self.args = list(args)
        self.baseline_value = baseline_value
        self.candidate_value = candidate_value
        self.failure = failure
        self.detail = detail
        self.suppression = suppression
        self.block_profile = dict(block_profile or {})
        self.schema_version = schema_version or INTENT_SCHEMA_VERSION
        self.confidence = confidence
        self.adapter_provenance = dict(adapter_provenance or {})
        self.stage = stage
        self.schedule_identity = schedule_identity
        self.baseline_read = (baseline_read.to_dict()
                              if baseline_read is not None else None)
        self.candidate_read = (candidate_read.to_dict()
                               if candidate_read is not None else None)
        self.standard = standard
        self.token_id = token_id

    def to_dict(self):
        return {
            "schema_version": self.schema_version,
            "classification": self.classification,
            "adapter": self.adapter_name,
            "adapter_provenance": dict(self.adapter_provenance),
            "target": self.target,
            "selector": self.selector,
            "args": list(self.args),
            "baseline_value": self.baseline_value,
            "candidate_value": self.candidate_value,
            "baseline_read": self.baseline_read,
            "candidate_read": self.candidate_read,
            "stage": self.stage,
            "schedule_identity": self.schedule_identity,
            "failure": self.failure,
            "detail": self.detail,
            "suppression": self.suppression,
            "confidence": self.confidence,
            "block_profile": dict(self.block_profile),
            "standard": self.standard,
            "token_id": self.token_id,
            "note": "intent evidence; never FRONT_RUNNING_PROFIT; "
                    "does not change paper economic findings",
        }


class IntentResult(object):


    def __init__(self, classification, evidences, reasons):
        self.classification = classification
        self.evidences = list(evidences)
        self.reasons = list(reasons)

    def to_dict(self):
        return {
            "classification": self.classification,
            "evidences": [e.to_dict() for e in self.evidences],
            "reasons": list(self.reasons),
        }


class BaselineIntentState(object):


    @legacy_keyword_aliases(victim_address='user_address')
    def __init__(self, reads, user_address, attacker_address):
        self.reads = dict(reads)
        self.user_address = user_address
        self.attacker_address = attacker_address

    @property
    def victim_address(self):

        return self.user_address

    @victim_address.setter
    def victim_address(self, value):
        self.user_address = value




def validate_adapter_config(payload):

    from eth_utils import function_signature_to_4byte_selector
    errors = []
    if not isinstance(payload, dict):
        return ["adapter config must be an object"]
    adapters = payload.get("adapters") if "adapters" in payload else payload
    schema_version = payload.get("schema_version")
    if schema_version is not None and int(schema_version) != 1:
        errors.append("unsupported adapter schema_version %r"
                      % (schema_version,))
    if not isinstance(adapters, dict) or not adapters:
        errors.append("no adapters defined")
        return errors
    for name, entry in sorted(adapters.items()):
        if isinstance(entry, ReadOnlyIntentAdapter):
            continue
        if not isinstance(entry, dict):
            errors.append("adapter %r is not an object" % (name,))
            continue
        target = entry.get("target")
        if not isinstance(target, str) or not target:
            errors.append("adapter %r: missing/empty target" % (name,))
        selector = entry.get("selector")
        if not isinstance(selector, str) or not selector:
            errors.append("adapter %r: missing selector" % (name,))
        else:
            hexish = all(c in "0123456789abcdef" for c in selector.lower())
            if hexish:
                if len(selector) != 8:
                    errors.append("adapter %r: selector must be 4 bytes"
                                  % name)
            else:

                if "(" not in selector or ")" not in selector:
                    errors.append(
                        "adapter %r: selector must be a 4-byte hex "
                        "selector or a function signature, got %r"
                        % (name, selector))
                else:
                    try:
                        function_signature_to_4byte_selector(selector)
                    except Exception:  # noqa: BLE001
                        errors.append(
                            "adapter %r: unparseable selector %r"
                            % (name, selector))
        arg_types = entry.get("arg_types")
        param_sources = entry.get("param_sources")
        if not isinstance(arg_types, list) or not arg_types:
            errors.append("adapter %r: arg_types must be a non-empty "
                          "list" % (name,))
            arg_types = arg_types or []
        if not isinstance(param_sources, list) or len(param_sources) != len(
                arg_types):
            errors.append(
                "adapter %r: param_sources must match arg_types length"
                % (name,))
            param_sources = param_sources or []
        for index, source in enumerate(param_sources):
            if source not in ("user_address", "victim_address", "attacker_address") \
                    and not str(source).startswith("fixed:"):
                errors.append(
                    "adapter %r: unknown param source %r at index %d"
                    % (name, source, index))
        if arg_types:
            try:
                encode_check = abi_encode_check(arg_types)
                if encode_check:
                    errors.append("adapter %r: %s" % (name, encode_check))
            except Exception as check_error:  # noqa: BLE001
                errors.append("adapter %r: %s" % (name, check_error))
        interpretation = entry.get("return_interpretation", "bool")
        if interpretation not in ReadOnlyIntentAdapter.RETURN_TYPES:
            errors.append("adapter %r: unknown return_interpretation %r"
                          % (name, interpretation))
    return errors


def _is_token_scoped(adapter):

    return any(source == "fixed:tokenId"
               for source in getattr(adapter, "param_sources", []))


def _canonical_address(value):
    if isinstance(value, bytes):
        return to_canonical_address(value).hex()
    return str(value).lower()


def _compare_ownership(baseline_read, candidate_read, user, attacker):

    if baseline_read is None or candidate_read is None:
        return False
    return (
        _canonical_address(baseline_read) == user
        and _canonical_address(candidate_read) == attacker
    )


def _compare_uint(user_base, user_cand, attacker_base, attacker_cand):

    if None in (user_base, user_cand, attacker_base, attacker_cand):
        return False
    return user_cand < user_base and attacker_cand > attacker_base


def _compare_bool(user_base, user_cand, attacker_base, attacker_cand,
                  consumed_right=False):

    if None in (user_base, user_cand, attacker_base, attacker_cand):
        return False
    if consumed_right:
        return (user_base is True and user_cand is False
                and attacker_base is True and attacker_cand is False)
    return (user_base is True and user_cand is False
            and attacker_base is False and attacker_cand is True)


class IntentOracle(object):


    def __init__(self, adapters=None, chain_id=1, block_profile=None,
                 schema_version=None):
        if adapters is None:

            self.adapters = _deep_copy_adapters(DEFAULT_ADAPTERS)
        else:
            self.adapters = dict(adapters)
        self.chain_id = int(chain_id)
        self.block_profile = dict(block_profile or {})
        self.schema_version = schema_version or INTENT_SCHEMA_VERSION


    def _adapter_for(self, name):
        return self.adapters.get(name)

    def _read_token(self, reader, resolver, standard, token_contract,
                    token_id, user_address, attacker_address):

        if standard == "ERC721":
            adapter = self._adapter_for("ownerOf")
            if adapter is None:
                return {
                    "ok": False,
                    "evidence": self._failure_evidence(
                        "ownerOf", token_contract, "ownerOf(uint256)",
                        [token_id], None, None,
                        IntentFailure.UNSUPPORTED.value,
                        "no ownerOf adapter configured", "baseline",
                        adapter=None, standard=standard,
                        token_id=token_id),
                }
            target = resolver(adapter.target, token_contract)
            read = reader(target, adapter.selector, adapter.arg_types,
                          [token_id], adapter.return_types)
            result = {"ok": read.ok, "read": read, "standard": standard,
                      "adapter": adapter, "args": [token_id]}
            if read.ok:
                result["value"] = read.value
            return result
        if standard == "ERC1155":
            adapter = self._adapter_for("balanceOf1155")
            if adapter is None:
                return {
                    "ok": False,
                    "evidence": self._failure_evidence(
                        "balanceOf1155", token_contract,
                        "balanceOf(address,uint256)",
                        [user_address, token_id], None, None,
                        IntentFailure.UNSUPPORTED.value,
                        "no balanceOf1155 adapter configured", "baseline",
                        adapter=None, standard=standard,
                        token_id=token_id),
                }
            target = resolver(adapter.target, token_contract)
            user_read = reader(
                target, adapter.selector, adapter.arg_types,
                [user_address, token_id], adapter.return_types)
            attacker_read = reader(
                target, adapter.selector, adapter.arg_types,
                [attacker_address, token_id], adapter.return_types)
            result = {
                "ok": user_read.ok and attacker_read.ok,
                "victim_read": user_read,
                "attacker_read": attacker_read,
                "standard": standard, "adapter": adapter,
                "args": [user_address, token_id],
            }
            return result
        return {
            "ok": False,
            "evidence": self._failure_evidence(
                "unknown", token_contract, "", [token_id], None, None,
                IntentFailure.UNSUPPORTED.value,
                "unknown asset standard %r" % (standard,), "baseline",
                adapter=None, standard=standard, token_id=token_id,
                args=[token_id]),
        }

    def _failure_evidence(self, adapter_name, target, selector, args,
                          baseline_value, candidate_value, failure,
                          detail, stage, adapter=None, standard=None,
                          token_id=None, schedule_identity=None):
        return IntentEvidence(
            classification=None, adapter_name=adapter_name, target=target,
            selector=selector, args=list(args or []),
            baseline_value=baseline_value, candidate_value=candidate_value,
            failure=failure, detail=detail, stage=stage,
            schedule_identity=schedule_identity,
            block_profile=self.block_profile, confidence=None,
            adapter_provenance=(adapter.to_dict()
                                if adapter is not None else {
                                    "schema_version":
                                        ADAPTER_SCHEMA_VERSION,
                                    "failure_semantics": (
                                        "REVERT/READ_FAILED/UNSUPPORTED/"
                                        "INTERNAL_ERROR degrade the "
                                        "evaluation; never guessed"),
                                }),
            standard=standard, token_id=token_id)

    @legacy_keyword_aliases(victim_address='user_address')
    def capture_baseline(self, reader, resolver, user_address,
                         attacker_address, token_ids):

        reads = {}
        for standard, token_contract, token_id in sorted(token_ids):
            key = ("token", standard,
                   _canonical_address(token_contract), token_id)
            reads[key] = self._read_token(
                reader, resolver, standard, token_contract, token_id,
                user_address, attacker_address)
        for name in sorted(self.adapters):
            adapter = self.adapters[name]
            if getattr(adapter, "target", None) is None:
                continue
            if _is_token_scoped(adapter):
                continue
            reads[("adapter", name)] = self._read_adapter(
                reader, resolver, adapter, user_address, attacker_address)
        return BaselineIntentState(reads, user_address, attacker_address)

    def _read_adapter(self, reader, resolver, adapter, user_address,
                      attacker_address):
        target = resolver(adapter.target, None)
        if target is None:
            return {
                "ok": False,
                "evidence": self._failure_evidence(
                    adapter.name, adapter.target, adapter.selector,
                    [], None, None, IntentFailure.UNSUPPORTED.value,
                    "adapter target unresolved", "baseline",
                    adapter=adapter),
            }
        user_args = adapter.build_args(user_address, attacker_address)
        attacker_args = adapter.build_args(attacker_address, user_address)
        user_read = reader(target, adapter.selector, adapter.arg_types,
                             user_args, adapter.return_types)
        attacker_read = reader(target, adapter.selector, adapter.arg_types,
                               attacker_args, adapter.return_types)
        return {
            "ok": user_read.ok and attacker_read.ok,
            "victim_read": user_read,
            "attacker_read": attacker_read,
            "victim_args": user_args,
            "attacker_args": attacker_args,
        }

    def _token_failure(self, entry, stage, schedule_identity=None):

        prebuilt = entry.get("evidence")
        if prebuilt is not None:
            prebuilt.stage = stage
            prebuilt.schedule_identity = schedule_identity
            return prebuilt
        read = entry.get("read") or entry.get("victim_read")
        failure_kind = (read.failure if read is not None
                        else IntentFailure.READ_FAILED.value)
        detail = (read.detail if read is not None else "read failed")
        return self._failure_evidence(
            entry.get("adapter_name") or "ownerOf",
            entry.get("target"), entry.get("selector") or "",
            entry.get("args") or [], None, None, failure_kind, detail,
            stage, adapter=entry.get("adapter"),
            standard=entry.get("standard"),
            token_id=entry.get("token_id"),
            schedule_identity=schedule_identity)


    @legacy_keyword_aliases(victim_address='user_address')
    def evaluate_candidate(self, baseline, reader, resolver,
                           user_address, attacker_address, token_ids,
                           candidate_label=None,
                           protocol_allows_first_come=False,
                           schedule_identity=None):

        evidences = []
        reasons = []
        failed = []
        preemption_found = None
        changed = False

        for standard, token_contract, token_id in sorted(token_ids):
            key = ("token", standard,
                   _canonical_address(token_contract), token_id)
            baseline_entry = baseline.reads.get(key)
            candidate_entry = self._read_token(
                reader, resolver, standard, token_contract, token_id,
                user_address, attacker_address)
            if candidate_entry is None:
                continue
            if baseline_entry is None or not baseline_entry.get("ok"):
                failed.append(self._token_failure(
                    baseline_entry, "baseline",
                    schedule_identity=schedule_identity))
                continue
            if not candidate_entry.get("ok"):
                failed.append(self._token_failure(
                    candidate_entry, "candidate",
                    schedule_identity=schedule_identity))
                continue
            adapter = candidate_entry.get("adapter")
            provenance = (adapter.to_dict()
                          if adapter is not None else {})
            if standard == "ERC721":
                baseline_owner = baseline_entry.get("value")
                candidate_owner = candidate_entry.get("value")
                changed = changed or baseline_owner != candidate_owner
                if _compare_ownership(baseline_owner, candidate_owner,
                                      user_address, attacker_address):
                    suppression = self._first_come_suppression(
                        protocol_allows_first_come)
                    if suppression:
                        reasons.append(suppression)
                    classification = (
                        GENERIC_ORDER_DEPENDENCY if suppression
                        else NFT_OWNERSHIP_PREEMPTION)
                    if preemption_found is None and not suppression:
                        preemption_found = classification
                    evidences.append(IntentEvidence(
                        classification=classification,
                        adapter_name=adapter.name,
                        target=token_contract,
                        selector=adapter.selector,
                        args=[token_id],
                        baseline_value=baseline_owner,
                        candidate_value=candidate_owner,
                        suppression=suppression,
                        confidence="high" if not suppression else "low",
                        block_profile=self.block_profile,
                        adapter_provenance=provenance,
                        stage="candidate",
                        schedule_identity=schedule_identity,
                        baseline_read=baseline_entry.get("read"),
                        candidate_read=candidate_entry.get("read"),
                        standard=standard, token_id=token_id))
                else:
                    evidences.append(IntentEvidence(
                        classification=None,
                        adapter_name=adapter.name,
                        target=token_contract,
                        selector=adapter.selector,
                        args=[token_id],
                        baseline_value=baseline_owner,
                        candidate_value=candidate_owner,
                        suppression=("no_both_sided_change: victim did "
                                     "not lose or attacker did not gain "
                                     "the same token id"),
                        confidence="low",
                        block_profile=self.block_profile,
                        adapter_provenance=provenance,
                        stage="candidate",
                        schedule_identity=schedule_identity,
                        baseline_read=baseline_entry.get("read"),
                        candidate_read=candidate_entry.get("read"),
                        standard=standard, token_id=token_id))
            elif standard == "ERC1155":
                baseline_user = baseline_entry.get("victim_read").value
                baseline_attacker = baseline_entry.get(
                    "attacker_read").value
                candidate_user = candidate_entry.get(
                    "victim_read").value
                candidate_attacker = candidate_entry.get(
                    "attacker_read").value
                changed = changed or (
                    baseline_user != candidate_user
                    or baseline_attacker != candidate_attacker)
                if _compare_uint(baseline_user, candidate_user,
                                 baseline_attacker,
                                 candidate_attacker):
                    suppression = self._first_come_suppression(
                        protocol_allows_first_come)
                    if suppression:
                        reasons.append(suppression)
                    classification = (
                        GENERIC_ORDER_DEPENDENCY if suppression
                        else NFT_OWNERSHIP_PREEMPTION)
                    if preemption_found is None and not suppression:
                        preemption_found = classification
                    evidences.append(IntentEvidence(
                        classification=classification,
                        adapter_name=adapter.name,
                        target=token_contract,
                        selector=adapter.selector,
                        args=[user_address, token_id],
                        baseline_value=baseline_user,
                        candidate_value=candidate_user,
                        suppression=suppression,
                        confidence="high" if not suppression else "low",
                        block_profile=self.block_profile,
                        adapter_provenance=provenance,
                        stage="candidate",
                        schedule_identity=schedule_identity,
                        baseline_read=baseline_entry.get("victim_read"),
                        candidate_read=candidate_entry.get(
                            "victim_read"),
                        standard=standard, token_id=token_id))
                else:
                    evidences.append(IntentEvidence(
                        classification=None,
                        adapter_name=adapter.name,
                        target=token_contract,
                        selector=adapter.selector,
                        args=[user_address, token_id],
                        baseline_value=baseline_user,
                        candidate_value=candidate_user,
                        suppression=("no_both_sided_change on the exact "
                                     "(contract,id) or different id"),
                        confidence="low",
                        block_profile=self.block_profile,
                        adapter_provenance=provenance,
                        stage="candidate",
                        schedule_identity=schedule_identity,
                        baseline_read=baseline_entry.get("victim_read"),
                        candidate_read=candidate_entry.get(
                            "victim_read"),
                        standard=standard, token_id=token_id))
            else:
                failed.append(self._failure_evidence(
                    "unknown", token_contract, "", [token_id], None,
                    None, IntentFailure.UNSUPPORTED.value,
                    "unknown asset standard %r" % (standard,),
                    "candidate", standard=standard, token_id=token_id,
                    schedule_identity=schedule_identity))

        for name in sorted(self.adapters):
            adapter = self.adapters[name]
            if getattr(adapter, "target", None) is None:
                continue
            if _is_token_scoped(adapter):
                continue
            key = ("adapter", name)
            baseline_adapter = baseline.reads.get(key)
            candidate_adapter = self._read_adapter(
                reader, resolver, adapter, user_address,
                attacker_address)
            provenance = adapter.to_dict()
            if baseline_adapter is None or not baseline_adapter.get("ok"):
                failed.append(self._adapter_failure_evidence(
                    baseline_adapter, adapter, "baseline",
                    schedule_identity=schedule_identity))
                continue
            if not candidate_adapter.get("ok"):
                failed.append(self._adapter_failure_evidence(
                    candidate_adapter, adapter, "candidate",
                    schedule_identity=schedule_identity))
                continue
            user_base = baseline_adapter["victim_read"].value
            attacker_base = baseline_adapter["attacker_read"].value
            user_cand = candidate_adapter["victim_read"].value
            attacker_cand = candidate_adapter["attacker_read"].value
            changed = changed or (
                user_base != user_cand or attacker_base != attacker_cand)
            interpretation = adapter.return_interpretation
            preempted = False
            claim_kind = (self._classify_adapter(adapter)
                          == CLAIM_RIGHT_PREEMPTION)
            if interpretation in ("address", "bytes32"):
                preempted = _compare_ownership(
                    user_base, user_cand, user_address,
                    attacker_address) and _compare_ownership(
                        attacker_base, attacker_cand, user_address,
                        attacker_address)
            elif interpretation == "bool":
                preempted = _compare_bool(
                    user_base, user_cand, attacker_base,
                    attacker_cand, consumed_right=claim_kind)
            elif interpretation in ("uint256", "int256"):
                preempted = _compare_uint(user_base, user_cand,
                                          attacker_base, attacker_cand)
            if preempted:
                classification = self._classify_adapter(adapter)
                suppression = self._first_come_suppression(
                    protocol_allows_first_come)
                if suppression:
                    reasons.append(suppression)
                    classification = GENERIC_ORDER_DEPENDENCY
                elif preemption_found is None:
                    preemption_found = classification
                evidences.append(IntentEvidence(
                    classification=classification,
                    adapter_name=adapter.name, target=adapter.target,
                    selector=adapter.selector,
                    args=candidate_adapter.get("victim_args") or [],
                    baseline_value=user_base,
                    candidate_value=user_cand,
                    suppression=suppression,
                    confidence="high" if not suppression else "low",
                    block_profile=self.block_profile,
                    adapter_provenance=provenance,
                    stage="candidate",
                    schedule_identity=schedule_identity,
                    baseline_read=baseline_adapter["victim_read"],
                    candidate_read=candidate_adapter["victim_read"]))
            else:
                evidences.append(IntentEvidence(
                    classification=None, adapter_name=adapter.name,
                    target=adapter.target, selector=adapter.selector,
                    args=candidate_adapter.get("victim_args") or [],
                    baseline_value=user_base,
                    candidate_value=user_cand,
                    suppression=("no_both_sided_change or different "
                                 "parameters"),
                    confidence="low", block_profile=self.block_profile,
                    adapter_provenance=provenance,
                    stage="candidate",
                    schedule_identity=schedule_identity,
                    baseline_read=baseline_adapter["victim_read"],
                    candidate_read=candidate_adapter["victim_read"]))

        evidences.extend(failed)
        if preemption_found is not None:
            classification = preemption_found
        elif failed:
            classification = GENERIC_ORDER_DEPENDENCY
            reasons.append("adapter failures degraded the evaluation; "
                           "no intent classification guessed")
        elif changed:
            classification = GENERIC_ORDER_DEPENDENCY
            reasons.append("state changed but no both-sided intent "
                           "evidence; generic order dependency (hint only)")
        else:
            classification = NONE
            reasons.append("baseline and candidate intent reads agree; "
                           "no order dependence")
        return IntentResult(classification, evidences, reasons)

    def _adapter_failure_evidence(self, entry, adapter, stage,
                                  schedule_identity=None):
        if entry is not None and entry.get("evidence") is not None:
            evidence = entry["evidence"]
            evidence.stage = stage
            evidence.schedule_identity = schedule_identity
            return evidence
        user_read = (entry or {}).get("victim_read")
        attacker_read = (entry or {}).get("attacker_read")
        failed_read = user_read or attacker_read
        failure_kind = (failed_read.failure if failed_read is not None
                        else IntentFailure.READ_FAILED.value)
        detail = (failed_read.detail if failed_read is not None
                  else "adapter read failed")
        return self._failure_evidence(
            adapter.name, adapter.target, adapter.selector,
            (entry or {}).get("victim_args") or [], None, None,
            failure_kind, detail, stage, adapter=adapter,
            schedule_identity=schedule_identity)

    @staticmethod
    def _classify_adapter(adapter):
        name = adapter.name.lower()
        if "claim" in name:
            return CLAIM_RIGHT_PREEMPTION
        if any(token in name for token in ("role", "govern", "vot",
                                           "position")):
            return ROLE_OR_GOVERNANCE_PREEMPTION
        return CLAIM_RIGHT_PREEMPTION

    @staticmethod
    def _first_come_suppression(protocol_allows_first_come):
        if not protocol_allows_first_come:
            return None
        return ("policy_allowed_first_come: the protocol explicitly "
                "permits first-come allocation; downgraded to a low-"
                "confidence hint, not an economic finding")


def build_adapters(payload):

    if payload is None:
        return _deep_copy_adapters(DEFAULT_ADAPTERS)
    if isinstance(payload, dict) and "adapters" not in payload \
            and "schema_version" not in payload:

        errors = validate_adapter_config({"adapters": payload})
        if errors:
            raise ValueError("; ".join(errors))
        adapters = {}
        for name, entry in sorted(payload.items()):
            if isinstance(entry, ReadOnlyIntentAdapter):
                adapters[name] = entry
                continue
            entry = dict(entry)
            entry["name"] = name
            adapters[name] = ReadOnlyIntentAdapter.from_dict(entry)
        return _merge_adapters(adapters)
    errors = validate_adapter_config(payload)
    if errors:
        raise ValueError("; ".join(errors))
    if isinstance(payload, dict) and "adapters" in payload:
        payload = payload["adapters"]
    adapters = {}
    for name, entry in sorted(payload.items()):
        if isinstance(entry, ReadOnlyIntentAdapter):
            adapters[name] = entry
            continue
        entry = dict(entry)
        entry["name"] = name
        adapters[name] = ReadOnlyIntentAdapter.from_dict(entry)
    return _merge_adapters(adapters)


def _deep_copy_adapters(adapters):
    from copy import deepcopy
    return {name: deepcopy(adapter)
            for name, adapter in sorted(adapters.items())}


def _merge_adapters(explicit):

    merged = _deep_copy_adapters(DEFAULT_ADAPTERS)
    merged.update(_deep_copy_adapters(explicit))
    return merged


def _coerce_args(arg_types, args):

    from eth_utils import to_bytes
    coerced = []
    for index, arg_type in enumerate(arg_types):
        value = args[index]
        text = arg_type
        if isinstance(value, str):
            if text.startswith("bytes"):
                try:
                    value = to_bytes(hexstr=value)
                except Exception:  # noqa: BLE001
                    value = value.encode("utf-8", errors="replace")
            elif text.startswith(("uint", "int")):
                try:
                    value = int(value)
                except (TypeError, ValueError):

                    pass
        coerced.append(value)
    return coerced


def evm_intent_reader(evm, block_profile=None):


    def reader(contract_address, selector, arg_types, args, return_types):
        try:
            if not all(character in "0123456789abcdef" for character in
                       selector.lower()):

                selector = function_signature_to_4byte_selector(
                    selector).hex()

            coerced_args = _coerce_args(arg_types, args)


            calldata = selector + encode_abi(arg_types, coerced_args).hex()
        except Exception as encode_error:  # noqa: BLE001
            return IntentReadResult(
                False, None, IntentFailure.INTERNAL_ERROR.value,
                str(encode_error))
        handle = None
        try:
            handle = evm.storage_emulator.record()
        except Exception as snapshot_error:  # noqa: BLE001

            return IntentReadResult(
                False, None, IntentFailure.INTERNAL_ERROR.value,
                "storage snapshot failed: %s" % (snapshot_error,))
        outcome = IntentReadResult(
            False, None, IntentFailure.INTERNAL_ERROR.value,
            "intent read did not complete")
        try:
            canonical = to_canonical_address(contract_address)
            code = evm.get_code(canonical)
            if not code:
                outcome = IntentReadResult(
                    False, None, IntentFailure.UNSUPPORTED.value,
                    "no code at adapter target %s" % (contract_address,))
                return outcome
            read_only_input = {
                "transaction": {
                    "from": _reader_sender(evm),
                    "to": contract_address,
                    "value": 0,
                    "data": calldata,
                    "gaslimit": 2000000,
                },
                "block": {}, "global_state": {}, "environment": {},
            }
            execution = evm.deploy_transaction(read_only_input,
                                               gas_price=0)
            if execution.is_error:
                outcome = IntentReadResult(
                    False, None, IntentFailure.REVERT.value,
                    str(getattr(execution, "_error", "reverted")))
                return outcome
            raw = getattr(execution, "output", None)
            if not raw:
                outcome = IntentReadResult(
                    False, None, IntentFailure.READ_FAILED.value,
                    "empty return data from %s" % (contract_address,))
                return outcome
            decoded = decode_abi(return_types, raw)
            value = decoded[0] if len(decoded) == 1 else list(decoded)
            outcome = IntentReadResult(True, value)
            return outcome
        except Exception as read_error:  # noqa: BLE001
            outcome = IntentReadResult(
                False, None, IntentFailure.INTERNAL_ERROR.value,
                str(read_error))
            return outcome
        finally:


            if handle is not None:
                try:
                    evm.storage_emulator.discard(handle)
                except Exception as restore_error:  # noqa: BLE001
                    return IntentReadResult(
                        False, None, IntentFailure.INTERNAL_ERROR.value,
                        "snapshot discard failed: %s" % (restore_error,))

    return reader


def _reader_sender(evm):

    return "0x" + hashlib_reader_address()[:40]


def hashlib_reader_address():
    import hashlib
    return hashlib.sha256(b"txracer-intent-reader").hexdigest()

    """A deterministic read caller with balance (never a fuzz account)."""
    from fuzzer.utils import settings
    address = getattr(settings, "INTENT_READER_ADDRESS", None)
    if address:
        return address
    import hashlib
    address = "0x" + hashlib.sha256(b"txracer-intent-reader").hexdigest()[:40]
    return address


def identity_resolver(mapping):

    def resolver(target, default):
        if target is None:
            return default
        if str(target).startswith("0x"):
            return target
        return mapping.get(target)
    return resolver


__all__ = [
    "ADAPTER_SCHEMA_VERSION",
    "BaselineIntentState",
    "CLAIM_RIGHT_PREEMPTION",
    "DEFAULT_ADAPTERS",
    "GENERIC_ORDER_DEPENDENCY",
    "INTENT_CLASSIFICATIONS",
    "INTENT_SCHEMA_VERSION",
    "IntentEvidence",
    "IntentFailure",
    "IntentOracle",
    "IntentReadResult",
    "IntentResult",
    "NFT_OWNERSHIP_PREEMPTION",
    "ReadOnlyIntentAdapter",
    "ROLE_OR_GOVERNANCE_PREEMPTION",
    "build_adapters",
    "evm_intent_reader",
    "identity_resolver",
]
