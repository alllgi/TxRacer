import os
from typing import List, Optional

from eth_hash.auto import keccak
from eth_utils import encode_hex, to_normalized_address

from fuzzer.txracer.assets.identity import (
    erc1155_asset,
    erc20_asset,
    erc721_asset,
    eth_asset,
)
from fuzzer.txracer.execution.rw_trace import (
    TxExecutionInternalError,
    execute_transaction_with_computation,
)
from fuzzer.txracer.execution.scenario_runner import ScenarioExecutionError

ZERO_ADDRESS = "0x0000000000000000000000000000000000000000"

TOPIC_TRANSFER = "0x" + keccak(b"Transfer(address,address,uint256)").hex()
TOPIC_TRANSFER_SINGLE = "0x" + keccak(
    b"TransferSingle(address,address,address,uint256,uint256)").hex()
TOPIC_TRANSFER_BATCH = "0x" + keccak(
    b"TransferBatch(address,address,address,uint256[],uint256[])").hex()

_TRANSFER_OPCODES = ("CALL", "CALLCODE")
_CHILD_CREATING_OPS = ("CALL", "CALLCODE", "DELEGATECALL",
                      "STATICCALL", "CREATE", "CREATE2")


class AssetFlow(object):


    def __init__(self, asset_id, sender, recipient, amount, tx_id,
                 call_depth, instruction_index, emitter, evidence):
        self.asset_id = asset_id
        self.sender = sender
        self.recipient = recipient
        self.amount = int(amount)
        self.tx_id = tx_id
        self.call_depth = int(call_depth)
        self.instruction_index = int(instruction_index)
        self.emitter = emitter
        self.evidence = dict(evidence)

    @property
    def attempted(self):
        return bool(self.evidence.get("attempted"))

    @property
    def ambiguous(self):
        return self.asset_id is None

    def sort_key(self):
        return (
            self.tx_id,
            self.instruction_index,
            self.asset_id if self.asset_id is not None else (),
            self.sender,
            self.recipient,
        )

    def to_dict(self):
        return {
            "asset_id": self.asset_id,
            "sender": self.sender,
            "recipient": self.recipient,
            "amount": self.amount,
            "tx_id": self.tx_id,
            "call_depth": self.call_depth,
            "instruction_index": self.instruction_index,
            "emitter": self.emitter,
            "evidence": self.evidence,
        }

    def __repr__(self):
        return "AssetFlow(%r, %s -> %s, %d, tx=%s)" % (
            self.asset_id, self.sender, self.recipient,
            self.amount, self.tx_id)


def normalize_address(address_bytes):
    return to_normalized_address(encode_hex(address_bytes))


def _topic_address(topic_value):

    return to_normalized_address("0x" + ("%064x" % topic_value)[-40:])


def _word(data, offset):
    return int.from_bytes(data[offset:offset + 32], "big")


class FlowCollector(object):


    def __init__(self, evm, chain_id=1, standard_resolver=None, mode="legacy"):
        self.evm = evm
        self.chain_id = int(chain_id)

        self.standard_resolver = standard_resolver
        self.mode = mode
        self.diagnostics = []
        self.unsupported = []


    def execute_sequence(self, sequence, tx_ids=None):

        try:
            self.evm.restore_from_snapshot()
        except Exception as restore_error:
            raise ScenarioExecutionError(
                "snapshot restore failed: %s" % restore_error)
        if tx_ids is None:
            tx_ids = ["trace-%d" % i for i in range(len(sequence))]
        if len(tx_ids) != len(sequence):
            raise ScenarioExecutionError(
                "tx_ids count %d does not match sequence length %d"
                % (len(tx_ids), len(sequence)))
        records, computations, flows = [], [], []
        for i, tx_input in enumerate(sequence):
            try:
                record, computation = execute_transaction_with_computation(
                    self.evm, tx_input, tx_id=tx_ids[i])
            except TxExecutionInternalError as internal_error:
                raise ScenarioExecutionError(
                    "trace tx %d (%s) internal failure: %s"
                    % (i, tx_ids[i], internal_error))
            records.append(record)
            computations.append(computation)
            if computation is not None:
                flows.extend(self.collect(computation, record, tx_ids[i]))
        flows.sort(key=AssetFlow.sort_key)
        return records, computations, flows


    def collect(self, computation, record, tx_id):

        tx_ok = record.status == "SUCCESS"
        sequence_index = [0]
        flows = []

        root_msg = computation.msg
        root_value = getattr(root_msg, "value", 0) or 0
        root_transfer = getattr(root_msg, "should_transfer_value", True)
        if root_value > 0 and root_transfer:
            sender = normalize_address(root_msg.sender)
            recipient = normalize_address(root_msg.storage_address)
            if sender != recipient:
                flows.append(self._flow(
                    eth_asset(self.chain_id), sender, recipient,
                    root_value, tx_id, 1,
                    self._next_index(sequence_index), recipient,
                    "eth_call", not tx_ok, tx_value=True))

        for frame, path_ok in self._iter_frames(computation):
            frame_ok = path_ok and not frame.is_error
            confirmed = tx_ok and frame_ok

            flows.extend(self._collect_eth(frame, confirmed, tx_id,
                                           sequence_index))
            flows.extend(self._collect_logs(frame, confirmed, tx_id,
                                            sequence_index))
            flows.extend(self._collect_selfdestruct(
                frame, confirmed, tx_id, sequence_index))
        return flows

    def _iter_frames(self, computation):
        stack = [(computation, True)]
        while stack:
            frame, path_ok = stack.pop()
            yield frame, path_ok
            frame_ok = path_ok and not frame.is_error
            for child in reversed(frame.children):
                stack.append((child, frame_ok))

    def _next_index(self, sequence_index):
        value = sequence_index[0]
        sequence_index[0] += 1
        return value


    def _collect_eth(self, frame, confirmed, tx_id, sequence_index):

        flows = []
        create_entries = [
            entry for entry in (frame.trace or [])
            if entry.get("op") in _CHILD_CREATING_OPS
        ]
        frame_addr = normalize_address(
            getattr(frame.msg, "storage_address", b""))
        aligned = len(create_entries) == len(frame.children)
        if not aligned:


            self.diagnostics.append({
                "tx_id": tx_id,
                "kind": "call_identity_unreliable",
                "detail": "frame %s has %d children but %d creating "
                          "entries; child-to-instruction identity is "
                          "unreliable, no pc guessed"
                          % (frame_addr, len(frame.children),
                             len(create_entries)),
            })
        for index, child in enumerate(frame.children):

            entry = create_entries[index] if aligned else None
            msg = child.msg
            value = getattr(msg, "value", 0) or 0
            should_transfer = getattr(msg, "should_transfer_value", False)
            if value <= 0 or not should_transfer:

                continue
            sender = normalize_address(msg.sender)
            recipient = normalize_address(msg.storage_address)
            if sender == recipient:

                continue
            index = self._next_index(sequence_index)
            depth = getattr(msg, "depth", 0) + 1


            child_ok = not getattr(child, "is_error", False)
            attempted = not (confirmed and child_ok)
            pc = entry.get("pc") if entry else None
            evidence = {
                "kind": "eth_create" if getattr(msg, "is_create", False)
                else "eth_call",
                "pc": pc,
                "sink_pc": pc,
                "call_depth": depth,
                "frame_storage_address": frame_addr,
                "attempted": attempted,
            }
            flows.append(AssetFlow(
                asset_id=eth_asset(self.chain_id),
                sender=sender,
                recipient=recipient,
                amount=value,
                tx_id=tx_id,
                call_depth=depth,
                instruction_index=index,
                emitter=recipient,
                evidence=evidence,
            ))
        return flows
        return flows


    def _collect_logs(self, frame, confirmed, tx_id, sequence_index):
        flows = []
        entries = getattr(frame, "_log_entries", None) or []
        depth = getattr(getattr(frame, "msg", None), "depth", 0) + 1
        frame_addr = normalize_address(getattr(frame.msg, "storage_address", b""))


        log_trace_entries = [
            entry for entry in (frame.trace or [])
            if entry.get("op", "").startswith("LOG")
        ]
        entry_iter = iter(log_trace_entries)
        for _counter, account, topics, data in entries:
            index = self._next_index(sequence_index)
            emitter = normalize_address(account)
            trace_entry = next(entry_iter, None)
            sink_pc = trace_entry.get("pc") if trace_entry else None
            topic0 = ("0x%064x" % topics[0]) if topics else None
            if topic0 == TOPIC_TRANSFER:
                flows.extend(self._decode_transfer(
                    emitter, topics, data, tx_id, depth, index,
                    confirmed, frame_addr, sink_pc))
            elif topic0 == TOPIC_TRANSFER_SINGLE:
                flows.extend(self._decode_transfer_single(
                    emitter, topics, data, tx_id, depth, index,
                    confirmed, frame_addr, sink_pc))
            elif topic0 == TOPIC_TRANSFER_BATCH:
                flows.extend(self._decode_transfer_batch(
                    emitter, topics, data, tx_id, depth, index,
                    confirmed, frame_addr, sink_pc))
            else:

                continue
        return flows

    def _flow(self, asset_id, sender, recipient, amount, tx_id, depth,
              index, emitter, kind, attempted, **extra):
        evidence = {"kind": kind, "attempted": attempted}
        evidence.update(extra)
        return AssetFlow(
            asset_id=asset_id, sender=sender, recipient=recipient,
            amount=amount, tx_id=tx_id, call_depth=depth,
            instruction_index=index, emitter=emitter, evidence=evidence)

    def _mark_mint_burn(self, sender, recipient, evidence):
        if sender == ZERO_ADDRESS:
            evidence["mint"] = True
        if recipient == ZERO_ADDRESS:
            evidence["burn"] = True
        return evidence

    def _decode_transfer(self, emitter, topics, data, tx_id, depth, index,
                         confirmed, frame_addr, sink_pc=None):
        topic_count = len(topics) - 1

        if len(topics) < 3:
            self.diagnostics.append({
                "tx_id": tx_id, "emitter": emitter,
                "kind": "malformed_transfer",
                "detail": "Transfer requires at least 3 topics, got %d"
                          % len(topics),
            })
            return []
        from_addr = _topic_address(topics[1])
        to_addr = _topic_address(topics[2])
        standard = None
        if self.standard_resolver is not None:
            standard = self.standard_resolver(self.evm, emitter)
        if standard is None and self.standard_resolver is not None:
            self.diagnostics.append({
                "tx_id": tx_id, "emitter": emitter,
                "kind": "ambiguous_transfer",
                "detail": "standard resolver returned None; no guess made",
            })
            return [self._flow(
                None, from_addr, to_addr, 0, tx_id, depth, index,
                emitter, "transfer_ambiguous", not confirmed,
                topic_count=topic_count,
                frame_storage_address=frame_addr,
                sink_pc=sink_pc)]
        if standard is None:

            standard = "ERC721" if topic_count == 3 else "ERC20"

        if standard == "ERC721":
            if topic_count != 3:
                self.diagnostics.append({
                    "tx_id": tx_id, "emitter": emitter,
                    "kind": "ambiguous_transfer",
                    "detail": "ERC721 transfer without token-id topic; "
                              "no guess made",
                })
                return [self._flow(
                    None, from_addr, to_addr, 0, tx_id, depth, index,
                    emitter, "transfer_ambiguous", not confirmed,
                    topic_count=topic_count,
                    frame_storage_address=frame_addr,
                    sink_pc=sink_pc)]
            token_id = topics[3]
            flow = self._flow(
                erc721_asset(emitter, token_id), from_addr, to_addr, 1,
                tx_id, depth, index, emitter, "transfer", not confirmed,
                topic_count=topic_count, token_id=token_id,
                standard="ERC721",
                standard_evidence="behavioral_topic_count"
                if self.standard_resolver is None else "resolver",
                frame_storage_address=frame_addr,
                sink_pc=sink_pc)
            self._mark_mint_burn(from_addr, to_addr, flow.evidence)
            return [flow]

        if len(data) != 32:
            self.diagnostics.append({
                "tx_id": tx_id, "emitter": emitter,
                "kind": "malformed_transfer",
                "detail": "ERC20-style transfer amount must be exactly "
                          "32 bytes, got %d" % len(data),
            })
            return [self._flow(
                None, from_addr, to_addr, 0, tx_id, depth, index, emitter,
                "transfer_ambiguous", not confirmed,
                topic_count=topic_count, malformed=True,
                frame_storage_address=frame_addr,
                sink_pc=sink_pc)]
        amount = _word(data, 0)
        flow = self._flow(
            erc20_asset(emitter), from_addr, to_addr, amount, tx_id, depth,
            index, emitter, "transfer", not confirmed,
            topic_count=topic_count,
            standard="ERC20",
            standard_evidence="behavioral_topic_count"
            if self.standard_resolver is None else "resolver",
            frame_storage_address=frame_addr,
            sink_pc=sink_pc)
        self._mark_mint_burn(from_addr, to_addr, flow.evidence)
        return [flow]

    def _decode_transfer_single(self, emitter, topics, data, tx_id, depth,
                                index, confirmed, frame_addr, sink_pc=None):
        if len(topics) != 4 or len(data) != 64:
            self.diagnostics.append({
                "tx_id": tx_id, "emitter": emitter,
                "kind": "malformed_transfer_single",
                "detail": "TransferSingle requires 3 topics and 64 bytes "
                          "of data, got %d topics / %d bytes"
                          % (len(topics), len(data)),
            })
            return []
        operator = _topic_address(topics[1])
        from_addr = _topic_address(topics[2])
        to_addr = _topic_address(topics[3])
        token_id = _word(data, 0)
        amount = _word(data, 32)
        flow = self._flow(
            erc1155_asset(emitter, token_id), from_addr, to_addr, amount,
            tx_id, depth, index, emitter, "transfer_single", not confirmed,
            operator=operator, token_id=token_id,
            frame_storage_address=frame_addr,
            sink_pc=sink_pc)
        self._mark_mint_burn(from_addr, to_addr, flow.evidence)
        return [flow]

    def _decode_transfer_batch(self, emitter, topics, data, tx_id, depth,
                               index, confirmed, frame_addr, sink_pc=None):
        if len(topics) != 4 or len(data) < 128:
            self.diagnostics.append({
                "tx_id": tx_id, "emitter": emitter,
                "kind": "malformed_transfer_batch",
                "detail": "TransferBatch payload too short: %d bytes"
                          % len(data),
            })
            return []
        offset_ids = _word(data, 0)
        offset_amounts = _word(data, 32)
        ids_head = offset_ids + 32
        if offset_ids != 64 or ids_head + 32 > len(data):
            self.diagnostics.append({
                "tx_id": tx_id, "emitter": emitter,
                "kind": "malformed_transfer_batch",
                "detail": "unexpected id array offset %d" % offset_ids,
            })
            return []
        id_count = _word(data, offset_ids)
        amounts_head = offset_amounts + 32
        if offset_amounts != 64 + 32 + 32 * id_count or \
                amounts_head + 32 > len(data):
            self.diagnostics.append({
                "tx_id": tx_id, "emitter": emitter,
                "kind": "malformed_transfer_batch",
                "detail": "unexpected amount array offset %d (ids=%d)"
                          % (offset_amounts, id_count),
            })
            return []
        amount_count = _word(data, offset_amounts)
        if id_count != amount_count:
            self.diagnostics.append({
                "tx_id": tx_id, "emitter": emitter,
                "kind": "malformed_transfer_batch",
                "detail": "ids length %d != amounts length %d; no partial "
                          "flow recorded" % (id_count, amount_count),
            })
            return []
        if ids_head + 32 * id_count > len(data) or \
                amounts_head + 32 * amount_count > len(data):
            self.diagnostics.append({
                "tx_id": tx_id, "emitter": emitter,
                "kind": "malformed_transfer_batch",
                "detail": "array data exceeds payload length",
            })
            return []
        operator = _topic_address(topics[1])
        from_addr = _topic_address(topics[2])
        to_addr = _topic_address(topics[3])
        flows = []
        for i in range(id_count):
            token_id = _word(data, ids_head + 32 * i)
            amount = _word(data, amounts_head + 32 * i)
            flow = self._flow(
                erc1155_asset(emitter, token_id), from_addr, to_addr,
                amount, tx_id, depth, index + i, emitter,
                "transfer_batch", not confirmed,
                operator=operator, token_id=token_id, batch_index=i,
                frame_storage_address=frame_addr,
                sink_pc=sink_pc)
            self._mark_mint_burn(from_addr, to_addr, flow.evidence)
            flows.append(flow)
        return flows


    def _collect_selfdestruct(self, frame, confirmed, tx_id, sequence_index):
        flows = []
        events = getattr(frame, "fuzzed_selfdestruct_events", None) or []
        depth = getattr(getattr(frame, "msg", None), "depth", 0) + 1
        for event in events:
            index = self._next_index(sequence_index)
            sender = normalize_address(event["storage_address"])
            recipient = normalize_address(event["beneficiary"])
            if sender == recipient:
                continue
            flows.append(self._flow(
                eth_asset(self.chain_id), sender, recipient,
                int(event["amount"]), tx_id, depth, index, sender,
                "selfdestruct", not confirmed,
                pc=event.get("pc"),
                sink_pc=event.get("pc"),
                frame_storage_address=normalize_address(
                    event["storage_address"])))
        return flows


__all__ = [
    "TOPIC_TRANSFER",
    "TOPIC_TRANSFER_BATCH",
    "TOPIC_TRANSFER_SINGLE",
    "ZERO_ADDRESS",
    "AssetFlow",
    "FlowCollector",
]
