import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


class StandaloneSmokeTests(unittest.TestCase):
    def test_all_production_modules_in_standalone_runner(self):
        solc = os.environ.get("TXRACER_SOLC")
        if not solc:
            self.skipTest("Set TXRACER_SOLC for the synthetic standalone smoke")
        root = Path(__file__).resolve().parents[1]

        code = '''
import socket, sys
def offline(*args, **kwargs):
    raise AssertionError("Synthetic smoke must stay offline")
socket.socket.connect = offline
socket.create_connection = offline
from fuzzer.txracer.pipeline.runner import main
main(sys.argv[1:])
'''
        with tempfile.TemporaryDirectory(prefix="txracer-smoke-") as directory:
            output = Path(directory) / "result.json"
            result = subprocess.run([sys.executable, "-c", code, "examples/smoke.json",
                                     "--solc", solc, "--iterations", "6", "--output", str(output)],
                                    cwd=str(root), stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                                    universal_newlines=True, timeout=180)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            payload = json.loads(output.read_text())
        exploration = payload["exploration"]
        executed = [event for event in exploration["user_events"] if event["event"] == "executed"]
        self.assertTrue(any(event["source"] == "initial" for event in executed))
        self.assertTrue(any(event["source"] == "smt" for event in executed), executed)
        self.assertTrue(any(event["source"] == "smt" and event["coverage_admission"] for event in executed))
        self.assertGreater(exploration["economic_representatives"], 0)
        for operator in ("parameter_mutation", "state_aware_insertion", "flow_reversal"):
            self.assertTrue(any(event["operator"] == operator and event["admitted"] > 0
                                for event in exploration["inference_events"]), operator)
        self.assertTrue(any(event["event"] == "oracle_evaluated" for event in exploration["interaction_events"]))
        self.assertTrue(any(event.get("depth") == 2 for event in exploration["interaction_events"]))
        for seed in exploration["coverage_corpus"] + exploration["economic_corpus"]:
            self.assertEqual(seed["baseline"], payload["baseline"])
            self.assertTrue(seed["sequence"])
            self.assertTrue(seed["reasons"])


if __name__ == "__main__":
    unittest.main()
