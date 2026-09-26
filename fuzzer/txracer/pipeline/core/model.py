"""Immutable execution inputs."""

from dataclasses import dataclass, field, replace
import hashlib
import json
from typing import Any, Optional, Tuple

from eth_abi import encode_abi
from eth_utils import to_normalized_address


def freeze(value):
    if isinstance(value, (list, tuple)):
        return tuple(freeze(item) for item in value)
    if isinstance(value, (bytes, bytearray)):
        return bytes(value)
    if isinstance(value, (str, int, bool)) or value is None:
        return value
    raise TypeError("Unsupported ABI value: %s" % type(value).__name__)


def json_value(value):
    if isinstance(value, bytes):
        return {"bytes": value.hex()}
    if isinstance(value, tuple):
        return [json_value(item) for item in value]
    return value


def from_json_value(value):
    if isinstance(value, dict) and set(value) == {"bytes"}:
        return bytes.fromhex(value["bytes"])
    if isinstance(value, list):
        return tuple(from_json_value(item) for item in value)
    return value


@dataclass(frozen=True)
class Environment:
    blocknumber: Optional[int] = None
    timestamp: Optional[int] = None

    def __post_init__(self):
        for value in (self.blocknumber, self.timestamp):
            if value is not None and not 0 <= value < 2 ** 256:
                raise ValueError("Environment values must fit uint256")


@dataclass(frozen=True)
class Transaction:
    contract: str
    selector: str
    argument_types: Tuple[str, ...]
    arguments: Tuple[Any, ...]
    sender: str
    value: int = 0
    gas: int = 8000000
    environment: Environment = field(default_factory=Environment)

    def __post_init__(self):
        object.__setattr__(self, "contract", to_normalized_address(self.contract))
        object.__setattr__(self, "sender", to_normalized_address(self.sender))
        selector = self.selector.lower()
        if selector.startswith("0x"):
            selector = selector[2:]
        if len(selector) not in (0, 8):
            raise ValueError("Selector must be four bytes, or explicitly empty")
        bytes.fromhex(selector)
        object.__setattr__(self, "selector", selector)
        object.__setattr__(self, "argument_types", tuple(self.argument_types))
        object.__setattr__(self, "arguments", freeze(self.arguments))
        if not isinstance(self.environment, Environment):
            raise TypeError("Transaction environment must be canonical Environment")
        if len(self.arguments) != len(self.argument_types):
            raise ValueError("Argument/type count mismatch")
        if not 0 <= self.value < 2 ** 256 or not 0 < self.gas < 2 ** 256:
            raise ValueError("Invalid transaction value/gas")
        if not selector and self.arguments:
            raise ValueError("Empty calldata cannot carry ABI arguments")
        self.calldata

    @property
    def calldata(self):
        return bytes.fromhex(self.selector) + encode_abi(self.argument_types, self.arguments)

    def changed(self, **fields):
        return replace(self, **fields)

    def to_dict(self):
        return {"contract": self.contract, "selector": self.selector,
                "argument_types": list(self.argument_types),
                "arguments": json_value(self.arguments), "sender": self.sender,
                "value": self.value, "gas": self.gas,
                "environment": {"blocknumber": self.environment.blocknumber,
                                "timestamp": self.environment.timestamp}}

    @classmethod
    def from_dict(cls, data):
        data = dict(data)
        data["arguments"] = from_json_value(data.get("arguments", []))
        data["environment"] = Environment(**data.get("environment", {}))
        return cls(**data)


@dataclass(frozen=True)
class Sequence:
    transactions: Tuple[Transaction, ...]

    def __post_init__(self):
        object.__setattr__(self, "transactions", tuple(self.transactions))
        if not all(isinstance(tx, Transaction) for tx in self.transactions):
            raise TypeError("Sequence requires canonical Transactions")

    def __len__(self):
        return len(self.transactions)

    def __iter__(self):
        return iter(self.transactions)

    def __getitem__(self, index):
        return self.transactions[index]

    def replace_transaction(self, index, transaction):
        txs = list(self.transactions)
        txs[index] = transaction
        return Sequence(txs)

    @property
    def identity(self):


        payload = [{"contract": tx.contract, "sender": tx.sender, "value": tx.value,
                    "gas": tx.gas, "data": tx.calldata.hex(),
                    "environment": (tx.environment.blocknumber, tx.environment.timestamp)} for tx in self]
        raw = json.dumps(payload, sort_keys=True, separators=(",", ":"))
        return hashlib.sha256(raw.encode("utf8")).hexdigest()

    def to_dict(self):
        return [tx.to_dict() for tx in self]

    @classmethod
    def from_dict(cls, data):
        return cls(tuple(Transaction.from_dict(tx) for tx in data))


@dataclass(frozen=True)
class Baseline:
    name: str
    fingerprint: str


@dataclass(frozen=True)
class TransactionResult:
    tx_id: str
    transaction: Transaction
    status: str
    reason: Optional[str]
    reads: frozenset = frozenset()
    writes: frozenset = frozenset()
    coverage: frozenset = frozenset()
    branches: frozenset = frozenset()
    asset_flows: tuple = ()
    storage_changes: tuple = ()
    return_value: bytes = b""
    notes: tuple = ()
    computation: Any = field(default=None, compare=False, repr=False)

    @property
    def sender(self):
        return self.transaction.sender

    @property
    def to(self):
        return self.transaction.contract

    @property
    def func_hash(self):
        return self.transaction.selector


@dataclass(frozen=True)
class AssetObservationFailure:
    account: str
    asset: tuple
    status: str
    reason: str
    query_status: Optional[str] = None


@dataclass(frozen=True)
class ExecutionResult:
    sequence: Sequence
    baseline: Baseline
    records: Tuple[TransactionResult, ...]
    asset_balances: tuple = ()
    asset_observation_failures: tuple = ()
    asset_queries: tuple = ()

    @property
    def assets_complete(self):
        observed = {(account, asset) for account, asset, _ in self.asset_balances}
        return not self.asset_observation_failures and set(self.asset_queries).issubset(observed)

    @property
    def status(self):
        return "SUCCESS" if all(r.status == "SUCCESS" for r in self.records) else "NON_SUCCESS"

    @property
    def coverage(self):
        return frozenset().union(*(r.coverage for r in self.records))

    @property
    def branches(self):
        return frozenset().union(*(r.branches for r in self.records))

    @property
    def asset_flows(self):
        return tuple(flow for r in self.records for flow in r.asset_flows)

    @property
    def storage_changes(self):
        return tuple((r.tx_id,) + entry for r in self.records for entry in r.storage_changes)

    @property
    def trustworthy(self):
        return all(r.status not in ("VALIDATION_ERROR", "FAILED") and not r.notes
                   for r in self.records)
