import copy
from dataclasses import FrozenInstanceError
import json
import os
from pathlib import Path
import subprocess
import unittest

from eth_utils import function_signature_to_4byte_selector

from fuzzer.txracer.pipeline.core.model import Transaction, Sequence, Environment
from fuzzer.txracer.pipeline.backend.legacy_evm import LegacyExecutionBackend

USER = "0x" + "11" * 20
ATTACKER = "0x" + "22" * 20


def compile_fixture():
    solc = os.environ.get("TXRACER_SOLC")
    if not solc:
        raise unittest.SkipTest("Set TXRACER_SOLC to Solidity 0.4.26 for real EVM tests")
    path = Path(__file__).parent / "fixtures" / "transaction_pipeline.sol"
    result = subprocess.run([solc, "--combined-json", "abi,bin", str(path)],
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True, check=True)
    contracts = json.loads(result.stdout)["contracts"]
    return next(value for key, value in contracts.items() if key.endswith(":TransactionPipeline"))


def make_backend():
    compiled = compile_fixture()
    backend = LegacyExecutionBackend()
    backend.fund(USER, 10 ** 21)
    backend.fund(ATTACKER, 10 ** 21)
    contract = backend.deploy(USER, compiled["bin"], value=1000)
    return backend, contract, backend.snapshot("clean"), json.loads(compiled["abi"])


def tx(contract, signature, arguments=(), sender=USER, value=0, environment=None):
    types = signature.partition("(")[2].rstrip(")")
    return Transaction(contract, function_signature_to_4byte_selector(signature).hex(),
                       tuple(types.split(",")) if types else (), tuple(arguments), sender,
                       value=value, environment=environment or Environment())


class ModelTests(unittest.TestCase):
    def test_canonical_roundtrip_nested_array_and_bytes(self):
        arguments = [[1, 2], bytearray(b"abc")]
        original = Transaction(USER, "01020304", ("uint256[]", "bytes"), arguments, ATTACKER)
        sequence = Sequence([original])
        arguments[0].append(3)
        restored = Sequence.from_dict(json.loads(json.dumps(sequence.to_dict())))
        self.assertEqual(sequence, restored)
        self.assertEqual(sequence[0].calldata, restored[0].calldata)
        self.assertEqual(original.arguments[0], (1, 2))
        self.assertEqual(sequence.identity, restored.identity)

    def test_copy_and_candidates_share_no_mutable_inputs(self):
        original = Sequence([Transaction(USER, "01020304", ("uint256[]",), ([1],), ATTACKER)])
        cloned = copy.deepcopy(original)
        candidate = cloned.replace_transaction(0, cloned[0].changed(arguments=([2],)))
        self.assertEqual(original[0].arguments, ((1,),))
        self.assertEqual(candidate[0].arguments, ((2,),))
        with self.assertRaises(FrozenInstanceError):
            cloned[0].sender = USER


class ExecutionTests(unittest.TestCase):
    def setUp(self):
        self.backend, self.contract, self.baseline, self.abi = make_backend()

    def test_sequence_state_and_reproducible_baseline(self):
        sequence = Sequence([tx(self.contract, "prepare(uint256)", (9,)),
                             tx(self.contract, "consume(uint256)", (8,))])
        first = self.backend.execute_sequence(sequence, self.baseline)
        second = self.backend.execute_sequence(sequence, self.baseline)
        self.assertEqual(first, second)
        self.assertEqual(int.from_bytes(first.records[1].return_value, "big"), 1)
        self.assertEqual(first.status, "SUCCESS")
        result = self.backend.execute_sequence(Sequence([tx(self.contract, "reserve()")]), self.baseline)
        self.assertEqual(int.from_bytes(result.records[0].return_value, "big"), 7)
        self.assertEqual(self.backend.restores, 3)

    def test_same_computation_feedback_and_no_auxiliary_execution(self):
        sequence = Sequence([tx(self.contract, "prepare(uint256)", (9,)),
                             tx(self.contract, "payout(uint256)", (1,))])
        result = self.backend.execute_sequence(sequence, self.baseline)
        self.assertTrue(result.coverage)
        self.assertTrue(result.branches)
        self.assertTrue(result.records[0].writes)
        self.assertTrue(result.records[1].reads)
        self.assertEqual([f.amount for f in result.asset_flows if not f.attempted], [9])
        self.assertEqual(len(result.storage_changes), 1)
        self.assertIs(result.sequence, sequence)
        self.assertEqual(self.backend.executions, 2)
        _ = (sequence.identity, result.coverage, result.branches, result.status)
        self.assertEqual(self.backend.executions, 2)
        self.backend.restore(self.baseline)
        self.assertEqual(self.backend.storage(self.contract, 0), 7)
        self.assertEqual(self.backend.balance(self.contract), 1000)

    def test_explicit_environment_and_baseline_lifecycle(self):
        sequence = Sequence([tx(self.contract, "joint(uint256)", (100,), value=5,
                                environment=Environment(blocknumber=42))])
        self.assertEqual(self.backend.execute_sequence(sequence, self.baseline).status, "SUCCESS")
        self.assertEqual(self.backend.execute_sequence(sequence, self.baseline).status, "SUCCESS")
        without = sequence.replace_transaction(0, sequence[0].changed(environment=Environment()))
        self.assertEqual(self.backend.execute_sequence(without, self.baseline).records[0].status, "REVERT")
        with self.assertRaises(ValueError):
            self.backend.snapshot("clean")


if __name__ == "__main__":
    unittest.main()
