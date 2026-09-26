import random
from typing import Optional, Set, Tuple

from eth.vm.spoof import SpoofTransaction
from eth_utils import (
    ValidationError,
    decode_hex,
    encode_hex,
    to_canonical_address,
    to_normalized_address,
)
from eth_abi import decode_abi, encode_abi

from fuzzer.utils.utils import convert_stack_value_to_int

StorageKey = Tuple[str, int]


class TxExecutionInternalError(Exception):
    pass


class TxExecutionRecord(object):


    def __init__(
        self,
        tx_id,
        sender,
        to,
        func_hash,
        status,
        reason=None,
        reads=None,
        writes=None,
        notes=None,
    ):
        self.tx_id = tx_id
        self.sender = sender
        self.to = to
        self.func_hash = func_hash
        self.status = status
        self.reason = reason
        self.reads = reads if reads is not None else set()
        self.writes = writes if writes is not None else set()
        self.notes = list(notes if notes is not None else [])

    def to_dict(self):
        return {
            "tx_id": self.tx_id,
            "sender": self.sender,
            "to": self.to,
            "func_hash": self.func_hash,
            "status": self.status,
            "reason": self.reason,
            "reads": [list(key) for key in sorted(self.reads)],
            "writes": [list(key) for key in sorted(self.writes)],
            "notes": sorted(self.notes),
        }


def canonical_contract_address(address_str):

    if address_str is None:
        return None
    return to_normalized_address(address_str)


def classify_execution(result):

    if not getattr(result, "is_error", False):
        return "SUCCESS", None

    error = getattr(result, "_error", None)
    if isinstance(error, ValidationError):
        return "VALIDATION_ERROR", str(error)

    error_name = error.__class__.__name__ if error is not None else ""
    if error_name == "Revert" or getattr(result, "output", None):
        return "REVERT", get_revert_reason(result)
    return "FAILED", str(error)


def get_revert_reason(result):

    if not result.is_error:
        return "SUCCESS"
    revert_data = result.output
    if not revert_data or len(revert_data) < 4:
        return "FAILED (%s)" % (getattr(result, "_error", ""))
    error_selector = revert_data[:4]
    if error_selector == b"\x08\xc3y\xa0":
        try:
            unpacked_reason = decode_abi(["string"], revert_data[4:])
            return "REVERT: %s" % unpacked_reason[0]
        except Exception as decode_error:
            return "FAILED (Malformed Revert Data: %s)" % revert_data.hex()
    return "FAILED (%s)" % (getattr(result, "_error", ""))


def extract_storage_keys(trace, target_address):

    reads = set()
    writes = set()
    notes = []
    for instruction in trace:
        op = instruction.get("op")
        if op not in ("SLOAD", "SSTORE"):
            continue
        stack = instruction.get("stack") or []
        if not stack:
            continue
        try:
            slot = convert_stack_value_to_int(stack[-1])
        except Exception as convert_error:
            notes.append(
                "unattributed storage access (%s): stack value not convertible: %s"
                % (op, convert_error)
            )
            continue
        depth = instruction.get("depth", 1)
        if depth == 1 and target_address:
            key = (canonical_contract_address(target_address), slot)
        else:
            notes.append(
                "unattributed storage access (%s) at depth %s: no call-context "
                "address in trace; not attributed, not fabricated" % (op, depth)
            )
            continue
        if op == "SLOAD":
            reads.add(key)
        else:
            writes.add(key)
    return reads, writes, notes


def _frame_storage_address(frame):

    msg = getattr(frame, "msg", None)
    address = getattr(msg, "storage_address", None)
    if isinstance(address, (bytes, bytearray)):
        if len(address) != 20:
            return None
        return to_normalized_address(encode_hex(bytes(address)))
    if isinstance(address, str):
        try:
            return canonical_contract_address(address)
        except Exception:
            return None
    return None


def extract_computation_storage_keys(computation):

    reads = set()
    writes = set()
    notes = []
    stack = [(computation, not bool(getattr(computation, "is_error", False)))]
    while stack:
        frame, ancestors_committed = stack.pop()
        frame_address = _frame_storage_address(frame)
        frame_committed = (
            ancestors_committed
            and not bool(getattr(frame, "is_error", False))
        )
        for instruction in getattr(frame, "trace", None) or []:
            op = instruction.get("op")
            if op not in ("SLOAD", "SSTORE"):
                continue
            raw_stack = instruction.get("stack") or []
            if not raw_stack:
                notes.append(
                    "unattributed storage access (%s): missing stack" % op)
                continue
            try:
                slot = convert_stack_value_to_int(raw_stack[-1])
            except Exception as convert_error:
                notes.append(
                    "unattributed storage access (%s): stack value not "
                    "convertible: %s" % (op, convert_error))
                continue
            if frame_address is None:
                notes.append(
                    "unattributed storage access (%s): frame has no concrete "
                    "storage address" % op)
                continue
            key = (frame_address, int(slot))
            if op == "SLOAD":
                reads.add(key)
            elif frame_committed:
                writes.add(key)
        for child in reversed(getattr(frame, "children", None) or []):
            stack.append((child, frame_committed))
    return reads, writes, notes


def find_preemption_pairs(alice_rw_sets, bob_rw_sets):

    preemption_pairs = []
    for i, rw_a in enumerate(alice_rw_sets):
        for j, rw_b in enumerate(bob_rw_sets):
            if not rw_a["writes"].isdisjoint(rw_b["reads"]) or \
                    not rw_a["reads"].isdisjoint(rw_b["writes"]) or \
                    not rw_a["writes"].isdisjoint(rw_b["writes"]):
                if not any(p["A_idx"] == i or p["B_idx"] == j for p in preemption_pairs):
                    preemption_pairs.append(
                        {
                            "A_idx": i,
                            "B_idx": j,
                            "A_func": rw_a.get("func_hash"),
                            "B_func": rw_b.get("func_hash"),
                        }
                    )
    return preemption_pairs


def build_tx_calldata(func_hash, arg_types, arg_values):

    if func_hash == "fallback":
        return random.choice(["", "00000000"])
    if func_hash == "constructor":
        return None
    if func_hash is None:
        return None
    encoded_args = encode_abi(arg_types, arg_values).hex()
    return func_hash + encoded_args


def _prepare_and_apply(evm, tx_input, tx_id):

    try:
        tx_data = tx_input["transaction"]
        sender_str = tx_data["from"]
        to_str = tx_data["to"]
        sender_addr_canon = to_canonical_address(sender_str)
        nonce = evm.vm.state.get_nonce(sender_addr_canon)
        tx = evm.vm.create_unsigned_transaction(
            nonce=nonce,
            gas_price=0,
            gas=tx_data["gaslimit"],
            to=to_canonical_address(to_str) if to_str else None,
            value=tx_data["value"],
            data=decode_hex(tx_data["data"]),
        )
        spoofed_tx = SpoofTransaction(tx, from_=sender_addr_canon)
        result = evm.vm.state.apply_transaction(spoofed_tx)
    except ValidationError as validation_error:
        return None, validation_error
    except Exception as internal_error:
        raise TxExecutionInternalError(
            "tx %s internal failure during transaction preparation or execution: %s"
            % (tx_id, internal_error)
        )
    return result, sender_str


def _derive_func_hash(tx_input, func_hash):

    if func_hash is not None:
        return func_hash
    data = (tx_input.get("transaction") or {}).get("data") or ""
    if isinstance(data, bytes):
        if len(data) >= 4:
            return data[:4].hex()
        return None
    if isinstance(data, str) and len(data) >= 8:
        return data[:8]
    return None


def execute_transaction_with_computation(evm, tx_input, tx_id, func_hash=None):

    derived_hash = _derive_func_hash(tx_input, func_hash)
    computation, sender_or_error = _prepare_and_apply(evm, tx_input, tx_id)
    if computation is None:
        return TxExecutionRecord(
            tx_id=tx_id,
            sender=None,
            to=None,
            func_hash=derived_hash,
            status="VALIDATION_ERROR",
            reason=str(sender_or_error),
        ), None

    to_str = tx_input["transaction"]["to"]
    status, reason = classify_execution(computation)
    reads, writes, notes = extract_computation_storage_keys(computation)
    return TxExecutionRecord(
        tx_id=tx_id,
        sender=sender_or_error,
        to=to_str,
        func_hash=derived_hash,
        status=status,
        reason=reason,
        reads=reads,
        writes=writes,
        notes=notes,
    ), computation


def execute_transaction_with_rw_trace(evm, tx_input, tx_id, func_hash=None):

    record, _computation = execute_transaction_with_computation(
        evm, tx_input, tx_id, func_hash=func_hash)
    return record


__all__ = [
    "StorageKey",
    "TxExecutionInternalError",
    "TxExecutionRecord",
    "build_tx_calldata",
    "canonical_contract_address",
    "classify_execution",
    "execute_transaction_with_computation",
    "execute_transaction_with_rw_trace",
    "extract_computation_storage_keys",
    "extract_storage_keys",
    "find_preemption_pairs",
    "get_revert_reason",
]
