"""Reuse the instrumented EVM, without its GA or fitness execution paths."""

import copy
import hashlib
import json
import rlp
from eth_abi import encode_abi

from eth_utils import ValidationError, to_canonical_address, to_normalized_address
from eth.vm.spoof import SpoofTransaction

from fuzzer.txracer.execution.legacy import LegacyExecutionBackend as Runtime
from fuzzer.txracer.execution.rw_trace import classify_execution, execute_transaction_with_computation
from fuzzer.txracer.assets.flow_tracker import FlowCollector
from fuzzer.txracer.assets.state_discovery import computation_storage_writes
from fuzzer.txracer.pipeline.backend.interface import ExecutionBackend
from fuzzer.txracer.pipeline.core.model import AssetObservationFailure, Baseline, ExecutionResult, TransactionResult
from fuzzer.txracer.pipeline.core.diagnostics import ExecutionAborted
from fuzzer.utils import settings


def runtime_input(transaction):

    return {"transaction": {"from": transaction.sender, "to": transaction.contract,
                            "value": transaction.value, "gaslimit": transaction.gas,
                            "data": transaction.calldata.hex()}}


def _state_content(value):
    if isinstance(value, dict):
        return [[_state_content(key), _state_content(item)]
                for key, item in sorted(value.items(), key=lambda pair: repr(pair[0]))]
    if isinstance(value, bytes):
        return {"bytes": value.hex()}
    if isinstance(value, (int, str)):
        return value
    return {"rlp": rlp.encode(value).hex()}


class LegacyExecutionBackend(ExecutionBackend):
    def __init__(self, runtime=None, vm_name="byzantium", chain_id=1):
        self._runtime = runtime if runtime is not None else Runtime()
        if self._runtime.vm is None:
            self._runtime.set_vm_by_name(vm_name)
        if getattr(self._runtime.storage_emulator, "_remote", None) is not None:
            raise ValueError("Execution baselines require materialized local state; live RPC lazy loading is not deterministic")
        self._snapshots = {}
        self._collector = FlowCollector(self._runtime, chain_id=chain_id)
        self.executions = 0
        self.restores = 0
        self._asset_accounts, self._asset_tokens = (), ()
        self.transaction_observer = None

    def state_fingerprint(self):

        state = self._runtime.storage_emulator.record()
        payload = [_state_content(state[key]) for key in ("account", "storage", "code")]
        return hashlib.sha256(json.dumps(payload, sort_keys=True).encode("utf8")).hexdigest()

    def configure_asset_queries(self, accounts, token_addresses=()):

        self._asset_accounts = tuple(sorted(set(to_normalized_address(a) for a in accounts)))
        self._asset_tokens = tuple(sorted(set(to_normalized_address(a) for a in token_addresses)))

    def _asset_balances(self):
        balances, failures, queries = [], [], []
        for account in self._asset_accounts:
            native = ("ETH", str(self._collector.chain_id), None)
            queries.append((account, native))
            balances.append((account, native, self.balance(account)))
            calldata = "0x70a08231" + encode_abi(["address"], [account]).hex()
            for token in self._asset_tokens:
                asset = ("ERC20", token, None)
                queries.append((account, asset))
                output, status, reason = self._read_asset_call(account, token, calldata)
                if status != "SUCCESS":
                    failures.append(AssetObservationFailure(account, asset, "unavailable", reason, status))
                elif len(output) != 32:
                    failures.append(AssetObservationFailure(
                        account, asset, "unsupported", "balanceOf returned %d bytes; expected 32" % len(output), status))
                else:
                    balances.append((account, asset, int.from_bytes(output, "big")))
        return tuple(balances), tuple(failures), tuple(queries)

    def _read_asset_call(self, sender, contract, calldata):

        checkpoint = self._runtime.storage_emulator.record()
        try:
            address = to_canonical_address(sender)
            tx = self._runtime.vm.create_unsigned_transaction(
                nonce=self._runtime.vm.state.get_nonce(address), gas_price=0,
                gas=settings.GAS_LIMIT, to=to_canonical_address(contract), value=0,
                data=bytes.fromhex(calldata[2:] if calldata.startswith("0x") else calldata))
            result = self._runtime.vm.state.apply_transaction(SpoofTransaction(tx, from_=address))
            status, reason = classify_execution(result)
            return bytes(result.output), status, reason
        except ValidationError as error:
            return b"", "VALIDATION_ERROR", str(error)
        finally:
            self._runtime.storage_emulator.discard(checkpoint)

    def fund(self, address, balance):

        self._runtime.vm.state.set_balance(to_canonical_address(address), int(balance))

    def balance(self, address):
        return self._runtime.vm.state.get_balance(to_canonical_address(address))

    def storage(self, address, slot):
        return self._runtime.vm.state.get_storage(to_canonical_address(address), int(slot))

    def deploy(self, sender, bytecode, value=0, gas=8000000):


        address = to_canonical_address(sender)
        tx = self._runtime.vm.create_unsigned_transaction(
            nonce=self._runtime.vm.state.get_nonce(address), gas_price=0,
            gas=gas, to=b"", value=value,
            data=bytes.fromhex(bytecode[2:] if bytecode.startswith("0x") else bytecode))
        result = self._runtime.vm.state.apply_transaction(SpoofTransaction(tx, from_=address))
        if result.is_error:
            raise RuntimeError("Deployment failed: %s" % result._error)
        return to_normalized_address(result.msg.storage_address)

    def snapshot(self, name):
        if name in self._snapshots:
            raise ValueError("Baseline name already exists: %s" % name)
        state = copy.deepcopy(self._runtime.storage_emulator.record())
        payload = [_state_content(state[key]) for key in ("account", "storage", "code")]
        fingerprint = hashlib.sha256(json.dumps(payload, sort_keys=True).encode("utf8")).hexdigest()
        baseline = Baseline(name, fingerprint)
        self._snapshots[name] = (baseline, state)
        return baseline

    def restore(self, baseline):
        entry = self._snapshots.get(baseline.name)
        if entry is None or entry[0] is not baseline:
            raise ValueError("Unknown baseline for this backend")
        self._runtime.storage_emulator.discard(copy.deepcopy(entry[1]))
        self._reset_environment()
        self.restores += 1

    def _reset_environment(self):
        state = self._runtime.vm.state
        for field in ("timestamp", "blocknumber", "balance", "call_return", "extcodesize", "returndatasize"):
            setattr(state, "fuzzed_" + field, None if field in ("timestamp", "blocknumber", "balance") else {})

    def execute_transaction(self, transaction, tx_id):
        self._reset_environment()
        state = self._runtime.vm.state
        state.fuzzed_blocknumber = transaction.environment.blocknumber
        state.fuzzed_timestamp = transaction.environment.timestamp
        stage = "transaction_execution"
        try:
            record, computation = execute_transaction_with_computation(
                self._runtime, runtime_input(transaction), tx_id, transaction.selector)
            self.executions += 1
            stage = "transaction_observation"
            coverage, branches, flows, changes, notes = set(), set(), [], [], list(record.notes)
            if computation is not None:
                flows = self._collector.collect(computation, record, tx_id)
                changes, extraction_notes = computation_storage_writes(computation)
                notes.extend(extraction_notes)
                frames = [computation]
                while frames:
                    frame = frames.pop()
                    address = to_normalized_address(frame.msg.code_address or frame.msg.storage_address)
                    trace = frame.trace or []
                    for index, entry in enumerate(trace):
                        coverage.add((address, entry["pc"]))
                        if entry["op"] == "JUMPI" and index + 1 < len(trace):
                            branches.add((address, entry["pc"], trace[index + 1]["pc"]))
                    frames.extend(frame.children)
            result = TransactionResult(
                tx_id, transaction, record.status, record.reason,
                frozenset(record.reads), frozenset(record.writes),
                frozenset(coverage), frozenset(branches), tuple(flows), tuple(changes),
                bytes(computation.output) if computation is not None else b"", tuple(notes), computation)
            if self.transaction_observer is not None:
                self.transaction_observer(result)
            return result
        except Exception as error:
            raise ExecutionAborted(stage, None) from error
        finally:
            self._reset_environment()

    def execute_sequence(self, sequence, baseline, tx_ids=None):
        ids = tuple(tx_ids) if tx_ids is not None else tuple("tx-%d" % i for i in range(len(sequence)))
        if len(ids) != len(sequence) or len(set(ids)) != len(ids):
            raise ValueError("Transaction IDs must be unique and aligned")
        records, stage, index = [], "restore", None
        try:
            self.restore(baseline)
            stage = "transaction_execution_or_observation"
            for index, (tx, tx_id) in enumerate(zip(sequence, ids)):
                records.append(self.execute_transaction(tx, tx_id))
            stage, index = "asset_observation", None
            balances, failures, queries = self._asset_balances()
            return ExecutionResult(sequence, baseline, tuple(records), balances, failures, queries)
        except Exception as error:
            if isinstance(error, ExecutionAborted):
                stage = error.stage
            raise ExecutionAborted(stage, ExecutionResult(sequence, baseline, tuple(records)), index) from error

    def read_call(self, sender, contract, calldata):

        return self._runtime.safe_read_call(sender, contract, calldata)
