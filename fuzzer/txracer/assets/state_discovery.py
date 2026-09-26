from collections import defaultdict
from typing import Dict, List, Optional, Set, Tuple

from eth_utils import encode_hex, to_normalized_address

from fuzzer.utils.utils import convert_stack_value_to_int

StorageKey = Tuple[str, int]


class AssetSlotEvidence(object):


    def __init__(self, storage_key, asset_id, tx_id, flow_ref,
                 dependency_kind, source_instruction, sink_instruction,
                 guard_ref=None, static_reasons=None, confidence="dynamic"):
        self.storage_key = storage_key
        self.asset_id = asset_id
        self.tx_id = tx_id
        self.flow_ref = flow_ref
        self.dependency_kind = dependency_kind
        self.source_instruction = source_instruction
        self.sink_instruction = sink_instruction
        self.guard_ref = guard_ref
        self.static_reasons = list(static_reasons or [])
        self.confidence = confidence

    def to_dict(self):
        return {
            "storage_key": [self.storage_key[0], self.storage_key[1]],
            "asset_id": self.asset_id,
            "tx_id": self.tx_id,
            "flow_ref": self.flow_ref,
            "dependency_kind": self.dependency_kind,
            "source_instruction": self.source_instruction,
            "sink_instruction": self.sink_instruction,
            "guard_ref": self.guard_ref,
            "static_reasons": sorted(self.static_reasons),
            "confidence": self.confidence,
        }

    def signature(self):

        return (self.storage_key, self.asset_id, self.dependency_kind,
                self.flow_ref, self.source_instruction,
                self.sink_instruction, self.guard_ref)


def frame_storage_address(frame):
    return to_normalized_address(
        encode_hex(getattr(frame.msg, "storage_address", b"")))


def frame_storage_accesses(frame):

    reads, writes = set(), set()
    for entry in frame.trace or []:
        op = entry.get("op")
        if op not in ("SLOAD", "SSTORE"):
            continue
        stack = entry.get("stack") or []
        if not stack:
            continue
        try:
            slot = convert_stack_value_to_int(stack[-1])
        except Exception:
            continue
        key = (frame_storage_address(frame), int(slot))
        if op == "SLOAD":
            reads.add(key)
        else:
            writes.add(key)
    return reads, writes


def computation_storage_writes(computation):

    writes = []
    notes = []
    stack = [computation]
    while stack:
        frame = stack.pop()
        frame_address = frame_storage_address(frame)
        for entry in frame.trace or []:
            if entry.get("op") != "SSTORE":
                continue
            raw_stack = entry.get("stack") or []
            if len(raw_stack) < 2:
                notes.append(
                    "SSTORE value extraction failed: stack missing "
                    "slot/value at frame %s" % (frame_address,))
                continue
            try:
                slot = convert_stack_value_to_int(raw_stack[-1])
                value = convert_stack_value_to_int(raw_stack[-2])
            except Exception as convert_error:  # noqa: BLE001
                notes.append(
                    "SSTORE value extraction failed at frame %s: %s"
                    % (frame_address, convert_error))
                continue
            if frame_address is None:
                notes.append(
                    "SSTORE without attributable storage owner: skipped")
                continue
            writes.append((frame_address, int(slot), int(value)))
        stack.extend(frame.children)
    return writes, notes


def computation_storage_accesses(computation):

    reads, writes = set(), set()
    stack = [computation]
    while stack:
        frame = stack.pop()
        frame_reads, frame_writes = frame_storage_accesses(frame)
        reads |= frame_reads
        writes |= frame_writes
        stack.extend(frame.children)
    return reads, writes


_TAINT_EFFECTS = {
    "ADD": (2, 1), "MUL": (2, 1), "SUB": (2, 1), "DIV": (2, 1),
    "SDIV": (2, 1), "MOD": (2, 1), "SMOD": (2, 1), "ADDMOD": (3, 1),
    "MULMOD": (3, 1), "EXP": (2, 1), "SIGNEXTEND": (2, 1),
    "LT": (2, 1), "GT": (2, 1), "SLT": (2, 1), "SGT": (2, 1), "EQ": (2, 1),
    "ISZERO": (1, 1), "AND": (2, 1), "OR": (2, 1), "XOR": (2, 1),
    "NOT": (1, 1), "BYTE": (2, 1), "SHL": (2, 1), "SHR": (2, 1),
    "SAR": (2, 1),
    "BALANCE": (1, 1), "CALLDATALOAD": (1, 1), "EXTCODESIZE": (1, 1),
    "EXTCODEHASH": (1, 1), "BLOCKHASH": (1, 1),
    "MLOAD": (1, 1), "SLOAD": (1, 1),
    "POP": (1, 0), "JUMP": (1, 0), "JUMPI": (2, 0),
    "CREATE": (3, 1), "CALL": (7, 1), "CALLCODE": (7, 1),
    "DELEGATECALL": (6, 1), "STATICCALL": (6, 1),
    "RETURN": (2, 0), "REVERT": (2, 0), "SELFDESTRUCT": (1, 0),
    "LOG0": (2, 0), "LOG1": (3, 0), "LOG2": (4, 0), "LOG3": (5, 0),
    "LOG4": (6, 0),
    "SSTORE": (2, 0),
    "JUMPDEST": (0, 0), "STOP": (0, 0), "INVALID": (0, 0),
    "PC": (0, 1), "MSIZE": (0, 1), "GAS": (0, 1),
    "ADDRESS": (0, 1), "ORIGIN": (0, 1), "CALLER": (0, 1),
    "CALLVALUE": (0, 1), "CALLDATASIZE": (0, 1), "CODESIZE": (0, 1),
    "GASPRICE": (0, 1), "COINBASE": (0, 1), "TIMESTAMP": (0, 1),
    "NUMBER": (0, 1), "DIFFICULTY": (0, 1), "GASLIMIT": (0, 1),
    "RETURNDATASIZE": (0, 1),
}

_MEMORY_WRITERS = ("MSTORE", "MSTORE8", "CALLDATACOPY", "CODECOPY",
                   "EXTCODECOPY", "RETURNDATACOPY")
_TERMINATORS = ("STOP", "RETURN", "REVERT", "INVALID", "SELFDESTRUCT")
_PUSHES = tuple("PUSH%d" % n for n in range(1, 33))
_DUPS = tuple("DUP%d" % n for n in range(1, 17))
_SWAPS = tuple("SWAP%d" % n for n in range(1, 17))


def _slot_label(storage_address, slot, pc):
    return ("slot", storage_address, int(slot), int(pc))


def _tainted_slots(taint):
    return {label for label in taint if label[0] == "slot"}


class BackwardDependencyAnalyzer(object):


    def __init__(self):
        self.limitations = []

    def analyze(self, computation):

        results = []
        stack = [computation]
        while stack:
            frame = stack.pop()
            results.append({
                "storage_address": frame_storage_address(frame),
                "sinks": self._analyze_frame(frame),
            })
            stack.extend(frame.children)
        return results

    def _analyze_frame(self, frame):
        storage_address = frame_storage_address(frame)
        stack_taint = []
        memory = {}
        sinks = []

        for entry in frame.trace or []:
            op = entry.get("op")
            if op is None:
                continue


            real_stack = entry.get("stack") or []
            if len(stack_taint) != len(real_stack):
                self.limitations.append(
                    "taint stack divergence at %s: taint=%d real=%d"
                    % (op, len(stack_taint), len(real_stack)))
                return []
            if op in _TERMINATORS:
                if op == "SELFDESTRUCT":
                    sink = self._sink_from_stack(
                        stack_taint, 1, "to", entry)
                    if sink:
                        sinks.append(sink)
                break
            if op in _PUSHES:
                stack_taint.append(frozenset())
                continue
            if op in _DUPS:
                n = int(op[3:])
                if len(stack_taint) < n:
                    self.limitations.append(
                        "duplicate beyond stack depth at %s" % op)
                    return []
                stack_taint.append(stack_taint[-n])
                continue
            if op in _SWAPS:
                n = int(op[4:])
                if len(stack_taint) < n + 1:
                    self.limitations.append(
                        "swap beyond stack depth at %s" % op)
                    return []
                stack_taint[-1], stack_taint[-1 - n] = (
                    stack_taint[-1 - n], stack_taint[-1])
                continue
            if op == "SHA3":
                if len(stack_taint) < 2:
                    self.limitations.append("sha3 underflow")
                    return []
                size, offset = self._top_ints(stack_taint, 2, entry)
                if offset is None:
                    return []
                region = self._memory_union(memory, offset, size)
                stack_taint.pop()
                stack_taint.pop()
                stack_taint.append(frozenset(region))
                continue
            if op in _MEMORY_WRITERS:
                pops = {"MSTORE": 2, "MSTORE8": 2, "CALLDATACOPY": 3,
                        "CODECOPY": 3, "EXTCODECOPY": 4,
                        "RETURNDATACOPY": 3}[op]
                if len(stack_taint) < pops:
                    self.limitations.append("%s underflow" % op)
                    return []
                if op == "MSTORE":

                    offset_taint = stack_taint[-1]
                    value_taint = stack_taint[-2]
                    offset = self._top_int(offset_taint, entry)
                    if offset is None:
                        return []
                    memory[offset & ~31] = frozenset(value_taint)
                elif op == "MSTORE8":
                    offset_taint = stack_taint[-1]
                    value_taint = stack_taint[-2]
                    offset = self._top_int(offset_taint, entry)
                    if offset is None:
                        return []
                    word = offset & ~31
                    memory[word] = frozenset(value_taint)
                del stack_taint[-pops:]
                continue
            if op == "MLOAD":
                if not stack_taint:
                    return []
                offset_taint = stack_taint[-1]
                offset = self._top_int(offset_taint, entry)
                if offset is None:
                    return []
                stack_taint[-1] = frozenset(
                    memory.get(offset & ~31, frozenset()))
                continue
            if op == "SLOAD":
                if not stack_taint:
                    return []
                slot_taint = stack_taint[-1]
                slot = self._top_int(slot_taint, entry)
                if slot is None:
                    return []
                stack_taint[-1] = frozenset(
                    {_slot_label(storage_address, slot, entry.get("pc"))})
                continue
            if op == "SSTORE":
                del stack_taint[-2:]
                continue
            if op in ("CALL", "CALLCODE"):
                if len(stack_taint) < 7:
                    self.limitations.append("%s underflow" % op)
                    return []
                value_taint = stack_taint[-3]
                to_taint = stack_taint[-2]
                amount_sink = self._sink_from_taint(
                    value_taint, "amount", entry)
                to_sink = self._sink_from_taint(
                    to_taint, "to", entry)
                for sink in (amount_sink, to_sink):
                    if sink:
                        sinks.append(sink)
                del stack_taint[-7:]
                stack_taint.append(frozenset())
                continue
            if op in ("DELEGATECALL", "STATICCALL"):
                if len(stack_taint) < 6:
                    return []
                del stack_taint[-6:]
                stack_taint.append(frozenset())
                continue
            if op == "CREATE":
                if len(stack_taint) < 3:
                    return []
                del stack_taint[-3:]
                stack_taint.append(frozenset())
                continue
            if op.startswith("LOG"):
                num_topics = int(op[3:])
                pops = 2 + num_topics
                if len(stack_taint) < pops:
                    return []

                mstart_taint = stack_taint[-1]
                msize_taint = stack_taint[-2]
                mstart = self._top_int(mstart_taint, entry)
                msize = self._top_int(msize_taint, entry)
                if mstart is None or msize is None:
                    return []
                data_sink = self._sink_from_taint(
                    frozenset(self._memory_union(memory, mstart, msize)),
                    "amount", entry)
                if data_sink:
                    sinks.append(data_sink)
                topic_taints = stack_taint[-2 - num_topics:-2][::-1]
                kinds = ("from", "to", "token_id")
                for i, topic_taint in enumerate(topic_taints):
                    if i >= len(kinds):
                        break
                    sink = self._sink_from_taint(
                        topic_taint, kinds[i], entry)
                    if sink:
                        sinks.append(sink)
                del stack_taint[-pops:]
                continue
            if op == "JUMPI":
                if len(stack_taint) < 2:
                    return []
                cond_taint = stack_taint[-2]
                guard = self._sink_from_taint(cond_taint, "guard", entry)
                if guard:
                    sinks.append(guard)
                del stack_taint[-2:]
                continue
            if op in _TAINT_EFFECTS:
                pops, pushes = _TAINT_EFFECTS[op]
                if len(stack_taint) < pops:
                    self.limitations.append("%s underflow" % op)
                    return []
                popped = stack_taint[-pops:] if pops else []
                if pops:
                    del stack_taint[-pops:]
                if op == "CALLDATALOAD":
                    offset = self._top_int(
                        popped[0], entry) if popped else None
                    stack_taint.append(
                        frozenset({("calldata", offset)}
                                  if offset is not None else set()))
                elif pushes:
                    stack_taint.append(frozenset().union(*popped))
                continue

            self.limitations.append(
                "untracked opcode %r in frame %s"
                % (op, storage_address))
            return []

        return sinks

    def _top_int(self, taint, entry):

        stack = entry.get("stack") or []
        if not stack:
            return None
        try:
            return convert_stack_value_to_int(stack[-1])
        except Exception:
            return None

    def _top_ints(self, _taint, count, entry):
        stack = entry.get("stack") or []
        if len(stack) < count:
            return None, None
        values = []
        for item in stack[-count:]:
            try:
                values.append(convert_stack_value_to_int(item))
            except Exception:
                return None, None
        return values[0], values[1]

    def _memory_union(self, memory, offset, size):
        labels = set()
        if size <= 0:
            return labels
        for word_offset in range(offset & ~31, offset + size, 32):
            labels |= memory.get(word_offset, frozenset())
        return labels

    def _sink_from_stack(self, stack_taint, depth, kind, entry):
        if len(stack_taint) < depth:
            return None
        return self._sink_from_taint(
            stack_taint[-depth], kind, entry)

    def _sink_from_taint(self, taint, kind, entry):
        slots = _tainted_slots(taint)
        if not slots:
            return None
        return {
            "op": entry.get("op"),
            "pc": entry.get("pc"),
            "kind": kind,


            "slots": sorted(
                {(label[1], label[2], label[3]) for label in slots}),
            "guard": kind == "guard",
        }


class ValidationLedger(object):


    def __init__(self, static_index=None, validation_log_limit=None,
                 evidence_log_limit=None, incremental=False):
        from fuzzer.txracer.retention import History
        from collections import Counter
        self.static_index = static_index
        self.incremental = incremental
        self._economic_states = set()
        self._context_validated = {}
        self._validation_counts = Counter()


        self._ctx_txs = {}
        self._slot_assets = defaultdict(set)
        self._evidence_log = History(evidence_log_limit)
        self.validation_log = History(validation_log_limit)
        self.validated_asset_slots = {}
        self._observed_keys = set()
        self._taint_uncertain_keys = set()


    def observe(self, tx_id, sequence_hash, state_ref, reads, writes,
                evidences, static_reasons=None, taint_clean=True):

        ctx = (sequence_hash, state_ref)
        tx_map = self._ctx_txs.setdefault(ctx, {})
        signature_set = frozenset(e.signature() for e in evidences)
        entry = tx_map.get(tx_id)
        if entry is None:
            tx_map[tx_id] = {
                "reads": set(reads), "writes": set(writes),
                "count": 1, "sets": {signature_set},
                "original_set": signature_set,
            }
        else:
            entry["reads"] |= set(reads)
            entry["writes"] |= set(writes)
            entry["count"] += 1
            entry["sets"].add(signature_set)
        static_reasons = static_reasons or {}
        for evidence in evidences:
            if evidence.asset_id is None:
                continue
            self._slot_assets[evidence.storage_key].add(evidence.asset_id)
            evidence_dict = evidence.to_dict()
            evidence_dict["taint_clean"] = bool(taint_clean)
            self._evidence_log.append(evidence_dict)
            if taint_clean and evidence_dict.get("dependency_kind") in self._ECONOMIC_SINK_KINDS:
                key = evidence_dict.get("storage_key")
                if isinstance(key, (list, tuple)) and len(key) == 2:
                    self._economic_states.add((str(key[0]), int(key[1])))
            if not taint_clean:
                self._taint_uncertain_keys.add(evidence.storage_key)
            if evidence.storage_key in static_reasons:
                evidence.static_reasons.extend(
                    static_reasons[evidence.storage_key])
        self._observed_keys |= set(reads) | set(writes)
        self._revalidate(ctx)


    _ECONOMIC_SINK_KINDS = ("amount", "token_id")

    @property
    def discovered_economic_states(self):

        if self.incremental or self._evidence_log.limit is not None:
            return set(self._economic_states)
        keys = set()
        for evidence in self._evidence_log:
            if evidence.get("taint_clean", True) is False:
                continue
            if evidence.get("dependency_kind") not in (
                    self._ECONOMIC_SINK_KINDS):
                continue
            key_entry = evidence.get("storage_key")
            if not isinstance(key_entry, (list, tuple)) or len(
                    key_entry) != 2:
                continue
            keys.add((str(key_entry[0]), int(key_entry[1])))
        return keys

    def economic_state_confidence(self, key):

        key = (str(key[0]), int(key[1]))
        if key in self.validated_asset_slots:
            return "replay_confirmed"
        if self._cross_transaction(key):
            return "cross_transaction_confirmed"
        return "dependency_only"

    def _cross_transaction(self, key):
        for tx_map in self._ctx_txs.values():
            writers = [tx_id for tx_id, entry in tx_map.items()
                       if key in entry["writes"]]
            readers = [tx_id for tx_id, entry in tx_map.items()
                       if key in entry["reads"]]
            if writers and readers and set(writers) != set(readers):
                return True
            if len(writers) > 1:
                return True
        return False


    @staticmethod
    def _project(signature_set, key, asset):
        return frozenset(
            sig for sig in signature_set
            if sig[0] == key and sig[1] == asset)

    def _context_cross_tx(self, ctx, key):

        tx_map = self._ctx_txs.get(ctx, {})
        found = False
        pairs = set()
        tx_ids = sorted(tx_map)
        for i in range(len(tx_ids)):
            for j in range(i + 1, len(tx_ids)):
                a_id, b_id = tx_ids[i], tx_ids[j]
                a, b = tx_map[a_id], tx_map[b_id]
                if (key in a["writes"] and key in b["reads"]) or \
                        (key in a["reads"] and key in b["writes"]) or \
                        (key in a["writes"] and key in b["writes"]):
                    found = True
                    pairs.add((a_id, b_id))
        return found, sorted(pairs)

    def _context_guard(self, ctx, key):
        for entry in self._ctx_txs.get(ctx, {}).values():
            for sig in entry["original_set"]:
                if sig[0] == key and sig[2] == "guard":
                    return True
        return False

    def _context_replay_stable(self, ctx, key, asset):

        for entry in self._ctx_txs.get(ctx, {}).values():
            if entry["count"] < 2:
                continue
            projected = {
                self._project(entry_set, key, asset)
                for entry_set in entry["sets"]
            }
            if len(projected) == 1 and any(projected):
                return True
        return False

    def _context_dynamic(self, ctx, key, asset):
        for entry in self._ctx_txs.get(ctx, {}).values():
            if self._project(entry["original_set"], key, asset):
                return True
        return False


    def _revalidate(self, changed_context=None):
        if self.incremental:
            if changed_context is not None:
                self._revalidate_context(changed_context)
            else:
                self._context_validated.clear()
                self._validation_counts.clear()
                self.validated_asset_slots.clear()
                for ctx in sorted(self._ctx_txs):
                    self._revalidate_context(ctx)
            return
        validated = {}
        candidate_keys = set()
        for ctx, tx_map in self._ctx_txs.items():
            for entry in tx_map.values():
                for sig in entry["original_set"]:
                    candidate_keys.add(sig[0])
        if self.static_index is not None:
            for candidate in self.static_index.candidates:
                if candidate.slot_hint is not None and \
                        (candidate.contract, candidate.slot_hint) in \
                        self._observed_keys:
                    candidate_keys.add((candidate.contract,
                                        candidate.slot_hint))
        for key in sorted(candidate_keys):
            assets = self._slot_assets.get(key) or set()
            if not assets:
                self._validate_static_only(key)
                continue
            for asset in sorted(assets, key=str):
                if self._validate(key, asset):
                    validated.setdefault(key, set()).add(asset)
        self.validated_asset_slots = validated

    def _revalidate_context(self, ctx):


        candidates = {(sig[0], sig[1]) for entry in self._ctx_txs[ctx].values()
                      for sig in entry["original_set"] if sig[1] is not None}
        accepted = {(key, asset) for key, asset in sorted(candidates, key=str)
                    if self._validate_context(ctx, key, asset)}
        previous = self._context_validated.get(ctx, set())
        for key, asset in previous - accepted:
            self._validation_counts[(key, asset)] -= 1
            if not self._validation_counts[(key, asset)]:
                del self._validation_counts[(key, asset)]
                self.validated_asset_slots[key].remove(asset)
                if not self.validated_asset_slots[key]:
                    del self.validated_asset_slots[key]
        for key, asset in accepted - previous:
            self._validation_counts[(key, asset)] += 1
            self.validated_asset_slots.setdefault(key, set()).add(asset)
        if accepted:
            self._context_validated[ctx] = accepted
        else:
            self._context_validated.pop(ctx, None)

    def _validate_static_only(self, key):
        static_only = bool(self._static_hits(key))
        verdict = {
            "storage_key": [key[0], key[1]],
            "asset_id": None,
            "accepted": False,
            "reasons": ["static_only" if static_only
                        else "no_dynamic_evidence"],
            "evidence_pairs": [],
            "context": None,
        }
        self.validation_log.append(verdict)

    def _validate(self, key, asset):

        accepted_any = False
        for ctx in sorted(self._ctx_txs):
            if self._validate_context(ctx, key, asset):
                accepted_any = True
        return accepted_any

    def _validate_context(self, ctx, key, asset):
        dynamic = self._context_dynamic(ctx, key, asset)
        cross_tx, pairs = self._context_cross_tx(ctx, key)
        guard = self._context_guard(ctx, key)
        replay_stable = self._context_replay_stable(ctx, key, asset)
        reasons = []
        if not dynamic:
            reasons.append("no_dynamic_evidence")
        if not cross_tx and not guard:
            reasons.append("no_cross_tx_relation")
        if not replay_stable:
            reasons.append("single_observation_no_replay")
        accepted = dynamic and (cross_tx or guard) and replay_stable
        self.validation_log.append({
            "storage_key": [key[0], key[1]], "asset_id": asset,
            "accepted": accepted, "reasons": reasons, "evidence_pairs": pairs,
            "context": {"sequence_hash": ctx[0], "state_ref": ctx[1]},
        })
        return accepted

    def _static_hits(self, key):
        hits = []
        if self.static_index is None:
            return hits
        contract = key[0]
        for candidate in self.static_index.candidates:
            if candidate.contract == contract and candidate.slot_hint == key[1]:
                hits.append(candidate.variable)
        return hits


    def replay_verify(self, key, asset, evm, sequence, target_index,
                      tx_ids, chain_id, collector, state_ref=None):

        from fuzzer.txracer.execution.rw_trace import (
            execute_transaction_with_computation,
        )
        from fuzzer.txracer.execution.scenario_runner import (
            ScenarioExecutionError,
        )
        if tx_ids is None:
            tx_ids = ["trace-%d" % i for i in range(len(sequence))]
        try:
            evm.restore_from_snapshot()
        except Exception as restore_error:
            raise ScenarioExecutionError(
                "snapshot restore failed: %s" % restore_error)
        target_records = []
        for i, tx_input in enumerate(sequence):
            record, computation = execute_transaction_with_computation(
                evm, tx_input, tx_id=tx_ids[i])
            target_records.append((record, computation))
        if target_index >= len(target_records):
            return False
        record, computation = target_records[target_index]
        if computation is None or record.status != "SUCCESS":
            return False
        sequence_hash = self._sequence_hash(sequence)
        target_flows = [
            flow for flow in collector.collect(computation, record,
                                               tx_ids[target_index])
            if not flow.ambiguous and not flow.attempted
        ]
        analyzer = BackwardDependencyAnalyzer()
        replayed_evidences = link_flow_evidence(
            analyzer, computation, target_flows, tx_ids[target_index])
        ctx = (sequence_hash, state_ref)
        entry = self._ctx_txs.get(ctx, {}).get(tx_ids[target_index])
        if entry is None:
            return False
        original_projected = self._project(
            entry["original_set"], key, asset)
        replayed_projected = self._project(
            frozenset(e.signature() for e in replayed_evidences),
            key, asset)
        if not original_projected or original_projected != replayed_projected:

            return False

        entry["count"] += 1
        entry["sets"].add(
            frozenset(e.signature() for e in replayed_evidences))
        self._slot_assets[key].add(asset)
        self._revalidate(ctx)
        return True

    def _sequence_hash(self, txs):
        import hashlib
        import json
        canonical = json.dumps(txs, sort_keys=True, default=str)
        return hashlib.sha256(canonical.encode("utf-8")).hexdigest()[:16]


    def to_dict(self):
        return {
            "validated_asset_slots": {
                "%s:%d" % (key[0], key[1]):
                    sorted(asset_ids)
                for key, asset_ids in sorted(
                    self.validated_asset_slots.items())
            },
            "validation_log": self.validation_log,
            "evidence_count": self._evidence_log.total,
            "validation_retention": self.validation_log.retention(),
            "evidence_retention": self._evidence_log.retention(),
        }


def link_flow_evidence(analyzer, computation, flows, tx_id):

    evidences = []
    frame_sink_results = analyzer.analyze(computation)
    for result in frame_sink_results:
        frame_addr = result["storage_address"]
        frame_sinks = result["sinks"]
        if not frame_sinks:
            continue
        frame_flows = [
            flow for flow in flows
            if flow.tx_id == tx_id
            and flow.evidence.get("frame_storage_address") == frame_addr
            and not flow.attempted
            and not flow.ambiguous
        ]
        if not frame_flows:
            continue


        flows_by_pc = {}
        for flow in frame_flows:
            sink_pc = flow.evidence.get("sink_pc")
            if sink_pc is None:
                analyzer.limitations.append(
                    "flow without sink_pc in frame %s (kind %s)"
                    % (frame_addr, flow.evidence.get("kind")))
                continue
            flows_by_pc.setdefault(flow.evidence["kind"], {}) \
                .setdefault(sink_pc, []).append(flow)

        def _flows_for_pc(kind_groups, pc):
            matched = []
            for kind in kind_groups:
                matched.extend(flows_by_pc.get(kind, {}).get(pc, []))
            return matched

        for sink in frame_sinks:
            if sink["kind"] == "guard":

                for flow in frame_flows:
                    flow_pc = flow.evidence.get("sink_pc")
                    if flow_pc is not None and flow_pc > sink["pc"]:
                        evidences.extend(_evidence_for(flow, sink, tx_id))
                continue
            if sink["kind"] == "amount":
                if sink["op"] == "SELFDESTRUCT":
                    kind_groups = ("selfdestruct",)
                elif sink["op"].startswith("LOG"):
                    kind_groups = ("transfer", "transfer_single",
                                   "transfer_batch")
                else:
                    kind_groups = ("eth_call", "eth_create")
                matched = _flows_for_pc(kind_groups, sink["pc"])
                if matched:
                    for flow in matched:
                        evidences.extend(_evidence_for(flow, sink, tx_id))
                else:
                    analyzer.limitations.append(
                        "unmatched %s amount sink at pc %s in frame %s"
                        % (sink["op"], sink["pc"], frame_addr))
                continue

            kind_groups = ("transfer", "transfer_single",
                           "transfer_batch")
            matched = _flows_for_pc(kind_groups, sink["pc"])
            for flow in matched:
                evidences.extend(_evidence_for(flow, sink, tx_id))
            continue
    return evidences


def _evidence_for(flow, sink, tx_id):
    evidences = []
    for slot in sink["slots"]:
        address, slot_value, source_pc = slot
        evidences.append(AssetSlotEvidence(
            storage_key=(address, slot_value), asset_id=flow.asset_id,
            tx_id=tx_id,
            flow_ref="%s@%s" % (flow.evidence["kind"],
                                flow.evidence.get("sink_pc")),
            dependency_kind=sink["kind"],

            source_instruction=source_pc,
            sink_instruction=sink["pc"],
            guard_ref=sink.get("guard") or None,
        ))
    return evidences


__all__ = [
    "AssetSlotEvidence",
    "BackwardDependencyAnalyzer",
    "StorageKey",
    "ValidationLedger",
    "computation_storage_accesses",
    "frame_storage_accesses",
    "frame_storage_address",
    "link_flow_evidence",
]
