"""Load the existing taint capability without importing engine/__init__ (GA)."""

import importlib.util
from pathlib import Path

from fuzzer.txracer.execution import legacy

_path = Path(__file__).resolve().parents[3] / "engine" / "analysis" / "symbolic_taint_analysis.py"
_spec = importlib.util.spec_from_file_location("txracer_symbolic_capability", str(_path))
_module = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_module)
SymbolicTaintAnalyzer = _module.SymbolicTaintAnalyzer
