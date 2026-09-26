import hashlib
import json
from collections import defaultdict, deque

from eth_abi import encode_abi
from eth_utils import keccak

SCHEMA_VERSION = 1

HIGH_VALUE_KEYWORDS = [
    "burn", "mint", "swap", "deposit", "withdraw", "claim", "stake",
    "unstake", "redeem", "borrow", "repay", "liquidate", "purchase",
    "approve", "addliquidity", "transfer", "vest", "bid", "auction",
]


class PlannerError(Exception):
    pass


def _zero_value_for(abi_type):

    text = abi_type.strip()
    if text.endswith("]") and "[" in text:

        base = text
        dimensions = []
        while base.endswith("]"):
            close = base.rfind("]")
            open_bracket = base.rfind("[", 0, close)
            dimension_text = base[open_bracket + 1:close]
            if dimension_text:
                dimensions.append(int(dimension_text))
            else:
                dimensions.append(None)
            base = base[:open_bracket]
        result = _zero_value_for(base)
        for dimension in reversed(dimensions):
            if dimension is None:
                result = []
            else:
                result = [result] * dimension
        return result
    if text == "address":
        return b"\x00" * 20
    if text in ("bool",):
        return False
    if text in ("string", "bytes"):
        return ""
    if text in ("function",):
        return b"\x00" * 24
    if text.startswith("bytes"):
        return b"\x00" * (int(text[5:]) // 8)
    if text.startswith("uint"):
        return 0
    if text.startswith("int"):
        return 0
    if text.startswith("("):
        inner = text[1:-1]
        types = _split_top_level(inner)
        return [_zero_value_for(t) for t in types]
    raise ValueError("cannot build zero value for %r" % (text,))


def _split_top_level(text):

    parts = []
    depth = 0
    current = []
    for char in text:
        if char in "([":
            depth += 1
        elif char in ")]":
            depth -= 1
        if char == "," and depth == 0:
            parts.append("".join(current).strip())
            current = []
        else:
            current.append(char)
    tail = "".join(current).strip()
    if tail:
        parts.append(tail)
    return [part for part in parts if part]


def abi_encode_check(arg_types):

    try:
        values = [_zero_value_for(t) for t in arg_types]
        encode_abi(arg_types, values)
        return None
    except Exception as encode_error:  # noqa: BLE001 - structured skip
        return "abi_encoding_unsupported:%s" % (encode_error,)


def _resolve_struct_type(param_type):

    from slither.core.solidity_types.user_defined_type import (
        UserDefinedType,
    )

    if isinstance(param_type, UserDefinedType):
        underlying = param_type.type

        if getattr(underlying, "kind", None) is not None or hasattr(
                underlying, "functions"):
            return "address"
        struct = getattr(underlying, "type", None)
        if struct is None:
            struct = underlying
        members = getattr(struct, "elems_ordered", None) or getattr(
            struct, "members", None)
        if not members:
            return None
        resolved = []
        for member in members:
            member_type = getattr(member, "type", None)
            if member_type is None:
                return None
            sub = _resolve_struct_type(member_type)
            if sub is None:
                return None
            resolved.append(sub)


        return "(%s)" % ",".join(resolved)
    return str(param_type)


def canonical_signature(function_name, abi_types):

    return "%s(%s)" % (function_name, ",".join(abi_types))


def function_selector(signature):

    return keccak(text=signature)[:4].hex()


def _function_flag(function, name):

    attribute = getattr(function, name, None)
    if attribute is None:
        return False, False
    if callable(attribute):
        try:
            return bool(attribute()), True
        except Exception:  # noqa: BLE001
            return False, False
    return bool(attribute), True


def _stable_task_sort_key(task):
    return (
        -float(task.get("score", 0.0)),
        task.get("contract", ""),
        task.get("signature", ""),
    )


class ContractPlan(object):


    def __init__(self, name, kind, constructor, libraries, fallback,
                 receive, dependencies, state_variables, abi):
        self.name = name
        self.kind = kind
        self.constructor = constructor
        self.libraries = libraries
        self.fallback = fallback
        self.receive = receive
        self.dependencies = dependencies
        self.state_variables = state_variables
        self.abi = abi

    def to_dict(self):
        return {
            "name": self.name,
            "kind": self.kind,
            "constructor": self.constructor,
            "libraries": sorted(self.libraries),
            "fallback": self.fallback,
            "receive": self.receive,
            "dependencies": sorted(self.dependencies),
            "state_variables": sorted(self.state_variables),
            "abi": self.abi,
        }


class FunctionCandidate(object):


    def __init__(self, contract, name, signature, selector, abi_types,
                 reasons, confidence, reads, writes, source_location,
                 is_payable, is_fallback, is_receive, is_constructor,
                 call_contracts, state_variables):
        self.contract = contract
        self.name = name
        self.signature = signature
        self.selector = selector
        self.abi_types = list(abi_types)
        self.reasons = list(reasons)
        self.confidence = confidence
        self.reads = sorted(set(reads))
        self.writes = sorted(set(writes))
        self.source_location = source_location
        self.is_payable = bool(is_payable)
        self.is_fallback = bool(is_fallback)
        self.is_receive = bool(is_receive)
        self.is_constructor = bool(is_constructor)
        self.call_contracts = sorted(set(call_contracts))
        self.state_variables = sorted(set(state_variables))

    def to_dict(self):
        return {
            "contract": self.contract,
            "name": self.name,
            "signature": self.signature,
            "selector": self.selector,
            "abi_types": list(self.abi_types),
            "reasons": list(self.reasons),
            "confidence": self.confidence,
            "reads": list(self.reads),
            "writes": list(self.writes),
            "source_location": self.source_location,
            "is_payable": self.is_payable,
            "is_fallback": self.is_fallback,
            "is_receive": self.is_receive,
            "is_constructor": self.is_constructor,
            "call_contracts": self.call_contracts,
            "state_variables": self.state_variables,
        }


class SequencePlanner(object):


    def __init__(self, source_file, solc_path=None, planner_failure_mode="fail"):
        self.source_file = str(source_file)
        self.solc_path = solc_path
        self.planner_failure_mode = planner_failure_mode
        self.slither = None
        self.solc_version = None
        self.analyzer_version = analyzer_version()
        self.contracts = []
        self.candidates = []
        self.skipped = []
        self.limitations = []
        self._contract_by_name = {}


    def run(self):

        try:
            self._load_slither()
            self._plan_contracts()
            self._plan_candidates()
            self._order_deployment()
            sequence = self._initial_sequence()
        except Exception as plan_error:  # noqa: BLE001 - PlannerError below
            raise PlannerError(
                "sequence planning failed for %s: %s: %s"
                % (self.source_file, type(plan_error).__name__, plan_error))
        return self._build_template(sequence)

    def _load_slither(self):
        from slither import Slither
        try:
            self.slither = Slither(
                self.source_file, solc=self.solc_path)
        except Exception as slither_error:  # noqa: BLE001
            raise PlannerError(
                "slither analysis failed for %s: %s"
                % (self.source_file, slither_error))
        units = getattr(self.slither, "compilation_units", None) or []
        if units:
            version = getattr(units[0], "solc_version", None)
            if version:
                self.solc_version = str(version)

    def _contract_state_variables(self, contract):
        names = []
        for var in getattr(contract, "state_variables", None) or []:
            names.append("%s.%s" % (contract.name, var.name))
        return sorted(names)

    def _contract_constructor(self, contract):
        constructor = getattr(contract, "constructor", None)
        if constructor is None:
            return None
        try:
            params = [
                {"name": p.name,
                 "abi_type": self._canonical_param_type(p.type)}
                for p in (constructor.parameters or [])
            ]
        except Exception as param_error:  # noqa: BLE001
            return {"error": str(param_error)}
        return {"parameters": params}

    def _canonical_param_type(self, param_type):

        text = str(param_type)
        base = text.split("[")[0] if "[" in text else text
        from slither.core.solidity_types.user_defined_type import (
            UserDefinedType,
        )
        if isinstance(param_type, UserDefinedType):
            base = _resolve_struct_type(param_type)
            if base is None:
                raise ValueError("unresolvable user-defined type %r" % (text,))
        if "[" in text:
            suffix = text[text.index("["):]
            return base + suffix
        return base

    def _plan_contracts(self):
        self._contract_by_name = {}
        for contract in self.slither.contracts:
            if contract.is_interface:
                continue
            libraries = set()
            for library_call in getattr(contract, "all_library_calls",
                                        None) or []:
                try:
                    libraries.add(library_call.called.name)
                except Exception as library_error:  # noqa: BLE001
                    self.limitations.append(
                        "library_call_extraction_failed:%s:%s"
                        % (contract.name, library_error))
            call_contracts = set()
            for function in contract.functions:
                for high_level_call in getattr(function, "high_level_calls",
                                               None) or []:
                    try:
                        callee = high_level_call[0]
                        call_contracts.add(callee.name)
                    except Exception as call_error:  # noqa: BLE001
                        self.limitations.append(
                            "high_level_call_extraction_failed:%s:%s"
                            % (contract.name, call_error))
            fallback = None
            receive = None
            for function in contract.functions:
                is_fallback, fallback_ok = _function_flag(
                    function, "is_fallback")
                is_receive, receive_ok = _function_flag(
                    function, "is_receive")
                if not fallback_ok or not receive_ok:
                    self.limitations.append(
                        "fallback_receive_detection_unavailable:%s"
                        % (contract.name,))
                if is_fallback:
                    fallback = function.full_name
                if is_receive:
                    receive = function.full_name
            abi_entries = []
            try:
                for function in contract.functions:
                    if function.is_constructor:
                        continue
                    entry = {"type": "function", "name": function.name,
                             "stateMutability":
                                 "payable" if function.payable else "nonpayable"}
                    abi_entries.append(entry)
            except Exception as abi_error:  # noqa: BLE001
                self.limitations.append(
                    "abi_extraction_failed:%s:%s"
                    % (contract.name, abi_error))
            plan = ContractPlan(
                name=contract.name,
                kind=getattr(contract, "kind", None) or contract.contract_kind,
                constructor=self._contract_constructor(contract),
                libraries=sorted(libraries),
                fallback=fallback,
                receive=receive,
                dependencies=sorted(call_contracts - {contract.name}),
                state_variables=self._contract_state_variables(contract),
                abi=abi_entries,
            )
            self.contracts.append(plan)
            self._contract_by_name[contract.name] = plan
        self.contracts.sort(key=lambda plan: plan.name)

    def _plan_candidates(self):
        for contract in self.slither.contracts:
            if contract.is_interface:
                continue
            for function in contract.functions:
                if function.is_constructor:
                    continue
                is_fallback, _fb_ok = _function_flag(
                    function, "is_fallback")
                is_receive, _rc_ok = _function_flag(
                    function, "is_receive")
                if is_fallback or is_receive:
                    continue
                if function.visibility not in ("public", "external"):
                    continue
                candidate = self._build_candidate(contract, function)
                if candidate is None:
                    continue
                self.candidates.append(candidate)
        self.candidates.sort(
            key=lambda c: (c.contract, c.signature))

    def _build_candidate(self, contract, function):
        name = function.name
        abi_types = []
        for param in (function.parameters or []):
            try:
                abi_types.append(self._canonical_param_type(param.type))
            except ValueError as type_error:
                self.skipped.append({
                    "contract": contract.name,
                    "signature": canonical_signature(name, []),
                    "reason": "abi_unsupported:%s" % (type_error,),
                })
                return None
        encode_reason = abi_encode_check(abi_types)
        if encode_reason is not None:
            self.skipped.append({
                "contract": contract.name,
                "signature": canonical_signature(name, abi_types),
                "reason": encode_reason,
            })
            return None
        signature = canonical_signature(name, abi_types)
        reasons = []
        if function.payable:
            reasons.append("payable")
        lowered = name.lower()
        for keyword in HIGH_VALUE_KEYWORDS:
            if keyword in lowered:
                reasons.append("keyword:%s" % keyword)
                break
        reads = set()
        writes = set()
        state_variables = set()
        for var in getattr(function, "state_variables_read", None) or []:
            reads.add("%s.%s" % (contract.name, var.name))
            state_variables.add("%s.%s" % (contract.name, var.name))
        for var in getattr(function, "state_variables_written", None) or []:
            writes.add("%s.%s" % (contract.name, var.name))
            state_variables.add("%s.%s" % (contract.name, var.name))
        self._propagate_internal_rw(function, reads, writes, state_variables)
        call_contracts = set()
        for high_level_call in getattr(function, "high_level_calls",
                                       None) or []:
            try:
                call_contracts.add(high_level_call[0].name)
            except Exception:  # noqa: BLE001
                continue

        confidence = 2
        if function.payable:
            confidence += 1
        if any(reason.startswith("keyword:") for reason in reasons):
            confidence += 1
        if writes:
            confidence += 1
        confidence = min(confidence, 5)
        source_location = None
        mapping = function.source_mapping
        if mapping:
            filename = mapping.get("filename_absolute") or mapping.get(
                "filename_used") or mapping.get("filename_short")
            if filename:
                source_location = str(filename)
                lines = mapping.get("lines")
                if lines:
                    source_location = "%s:%s" % (source_location, lines[0])
        return FunctionCandidate(
            contract=contract.name, name=name, signature=signature,
            selector=function_selector(signature), abi_types=abi_types,
            reasons=reasons, confidence="%d/5" % confidence,
            reads=reads, writes=writes, source_location=source_location,
            is_payable=function.payable, is_fallback=False,
            is_receive=False, is_constructor=False,
            call_contracts=call_contracts, state_variables=state_variables)

    def _propagate_internal_rw(self, function, reads, writes, state_variables):

        seen = set()

        def _visit(func):
            if id(func) in seen:
                return
            seen.add(id(func))
            for var in getattr(func, "state_variables_read", None) or []:
                reads.add("%s.%s" % (func.contract.name, var.name))
                state_variables.add("%s.%s" % (func.contract.name, var.name))
            for var in getattr(func, "state_variables_written", None) or []:
                writes.add("%s.%s" % (func.contract.name, var.name))
                state_variables.add("%s.%s" % (func.contract.name, var.name))
            for callee in getattr(func, "internal_calls", None) or []:
                try:
                    _visit(callee)
                except Exception:  # noqa: BLE001
                    continue

        _visit(function)

    def _order_deployment(self):

        names = [plan.name for plan in self.contracts]
        in_degree = {}
        edges = defaultdict(list)
        for plan in self.contracts:
            in_degree[plan.name] = 0
        for plan in self.contracts:
            deps = set(plan.libraries) | set(plan.dependencies)
            for dep in deps:
                if dep in self._contract_by_name:
                    edges[dep].append(plan.name)
                    in_degree[plan.name] += 1
                else:
                    self.limitations.append(
                        "deployment_dependency_unresolved:%s->%s"
                        % (plan.name, dep))
        queue = deque(sorted(
            [name for name in names if in_degree[name] == 0]))
        order = []
        while queue:
            name = queue.popleft()
            order.append(name)
            for follower in sorted(edges.get(name, [])):
                in_degree[follower] -= 1
                if in_degree[follower] == 0:
                    queue.append(follower)
        if len(order) != len(names):
            cyclic = sorted(set(names) - set(order))
            self.limitations.append(
                "deployment_dependency_cycle:%s" % ",".join(cyclic))
            order.extend(cyclic)
        for plan in self.contracts:
            plan.deployment_index = order.index(plan.name)

    def _initial_sequence(self):

        by_key = {(c.contract, c.signature): c for c in self.candidates}
        pending = list(self.candidates)
        satisfied_writes = set()
        sequence = []
        while pending:
            progressed = False
            for candidate in list(pending):
                if set(candidate.reads).issubset(satisfied_writes):
                    sequence.append(candidate)
                    satisfied_writes.update(candidate.writes)
                    pending.remove(candidate)
                    progressed = True
            if not progressed and pending:
                forced = sorted(
                    pending,
                    key=lambda c: (
                        -int(c.confidence.split("/")[0]),
                        c.contract, c.signature))[0]
                sequence.append(forced)
                satisfied_writes.update(forced.writes)
                pending.remove(forced)
        return sequence


    def _source_hashes(self):
        hashes = {}
        try:
            source_code = getattr(self.slither, "source_code", None) or {}
            for filename in sorted(source_code):
                content = source_code[filename]
                if not isinstance(content, str):
                    continue
                hashes[filename] = hashlib.sha256(
                    content.encode("utf-8")).hexdigest()
        except Exception:  # noqa: BLE001
            try:
                with open(self.source_file, "rb") as handle:
                    hashes[self.source_file] = hashlib.sha256(
                        handle.read()).hexdigest()
            except OSError:
                pass
        return hashes

    def _build_template(self, sequence):
        template = {
            "schema_version": SCHEMA_VERSION,
            "source_hashes": self._source_hashes(),
            "solc_version": self.solc_version,
            "analyzer": {
                "name": "slither",
                "version": self.analyzer_version,
            },
            "contracts": {
                plan.name: plan.to_dict()
                for plan in self.contracts
            },
            "deployment_order": [
                plan.name
                for plan in sorted(
                    self.contracts,
                    key=lambda plan: plan.deployment_index)
            ],
            "candidate_functions": [
                candidate.to_dict()
                for candidate in self.candidates
            ],
            "skipped_functions": list(self.skipped),
            "sequence": [
                {
                    "contract": candidate.contract,
                    "signature": candidate.signature,
                    "score": float(int(candidate.confidence.split("/")[0])),
                }
                for candidate in sequence
            ],
            "limitations": list(self.limitations),
        }
        full = {
            "schema_version": template["schema_version"],
            "source_hashes": template["source_hashes"],
            "solc_version": template["solc_version"],
            "analyzer": template["analyzer"],
            "contracts": template["contracts"],
            "deployment_order": template["deployment_order"],
            "candidate_functions": template["candidate_functions"],
            "skipped_functions": template["skipped_functions"],
            "sequence": template["sequence"],
            "limitations": template["limitations"],
        }
        template["content_hash"] = hashlib.sha256(
            json.dumps(full, sort_keys=True).encode("utf-8")).hexdigest()
        return template


def plan_sequence_template(source_file, solc_path=None,
                           planner_failure_mode="fail", cache=None):

    if cache is not None:
        key_fields = _planner_cache_key(source_file, solc_path,
                                        planner_failure_mode)


        cached, reason = cache.get(
            key_fields, validate=_validate_planner_template)
        if cached is not None:
            return cached
    planner = SequencePlanner(
        source_file, solc_path=solc_path,
        planner_failure_mode=planner_failure_mode)
    try:
        template = planner.run()
        if cache is not None:
            try:
                cache.put(_planner_cache_key(source_file, solc_path,
                                             planner_failure_mode),
                          template)
            except Exception:  # noqa: BLE001 - cache failures are non-fatal
                pass
        return template
    except PlannerError as plan_error:
        if planner_failure_mode == "fallback":

            return {
                "schema_version": SCHEMA_VERSION,
                "source_hashes": {},
                "solc_version": None,
                "analyzer": {"name": "slither",
                             "version": planner.analyzer_version},
                "contracts": {},
                "deployment_order": [],
                "candidate_functions": [],
                "skipped_functions": [],
                "sequence": [],
                "limitations": [],
                "planner_failure": str(plan_error),
            }
        raise


def normalize_sequence_template(payload):

    if isinstance(payload, list):
        tasks = payload
    elif isinstance(payload, dict):
        if isinstance(payload.get("sequence"), list):
            tasks = payload["sequence"]
        elif isinstance(payload.get("master_sequence"), list):
            tasks = payload["master_sequence"]
        else:
            raise PlannerError(
                "unsupported sequence template payload: no sequence or "
                "master_sequence list found")
    else:
        raise PlannerError(
            "unsupported sequence template payload type: %s"
            % (type(payload).__name__,))
    for index, task in enumerate(tasks):
        if not isinstance(task, dict):
            raise PlannerError(
                "sequence template task %d is not an object" % index)
        if not task.get("contract") or not task.get("signature"):
            raise PlannerError(
                "sequence template task %d misses contract/signature"
                % index)
    return tasks


__all__ = [
    "FunctionCandidate",
    "PlannerError",
    "SCHEMA_VERSION",
    "SequencePlanner",
    "abi_encode_check",
    "canonical_signature",
    "function_selector",
    "normalize_sequence_template",
    "plan_sequence_template",
]


def analyzer_version():

    try:
        import pkg_resources
        return "slither-%s" % pkg_resources.get_distribution(
            "slither-analyzer").version
    except Exception:  # noqa: BLE001
        try:
            from importlib import metadata
            return "slither-%s" % metadata.version(
                "slither-analyzer")
        except Exception:  # noqa: BLE001
            return "slither-unknown"


def _planner_cache_key(source_file, solc_path, planner_failure_mode):

    from fuzzer.txracer.cache.compile_cache import source_file_hashes
    hashes = source_file_hashes(source_file)
    solc_version = None
    if solc_path:
        try:
            import subprocess as _sp
            probe = _sp.run([solc_path, "--version"],
                            capture_output=True, text=True, timeout=30)
            for token in probe.stdout.split():
                if token.count(".") == 2 and token[0].isdigit():
                    solc_version = token
                    break
        except Exception:  # noqa: BLE001
            solc_version = None
    return {
        "source_hashes": dict(sorted(hashes.items())),
        "solc_path": solc_path,
        "solc_version": solc_version,
        "planner_failure_mode": planner_failure_mode,
        "analyzer": analyzer_version(),
    }


def _validate_planner_template(template):

    if not isinstance(template, dict):
        return "payload is not an object"
    for field in ("schema_version", "source_hashes", "solc_version",
                  "analyzer", "contracts", "deployment_order",
                  "candidate_functions", "skipped_functions",
                  "sequence", "limitations", "content_hash"):
        if field not in template:
            return "missing field %r" % (field,)
    try:
        full = {
            "schema_version": template["schema_version"],
            "source_hashes": template["source_hashes"],
            "solc_version": template["solc_version"],
            "analyzer": template["analyzer"],
            "contracts": template["contracts"],
            "deployment_order": template["deployment_order"],
            "candidate_functions": template["candidate_functions"],
            "skipped_functions": template["skipped_functions"],
            "sequence": template["sequence"],
            "limitations": template["limitations"],
        }
        expected = hashlib.sha256(
            json.dumps(full, sort_keys=True).encode(
                "utf-8")).hexdigest()
    except (KeyError, TypeError, ValueError) as content_error:
        return "content unhashable: %s" % (content_error,)
    if template.get("content_hash") != expected:
        return "content_hash mismatch"
    return None
