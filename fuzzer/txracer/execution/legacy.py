from pathlib import Path
import sys


try:


    from evm import InstrumentedEVM
except ModuleNotFoundError as error:
    if error.name != "evm":
        raise


    legacy_package_root = str(Path(__file__).resolve().parents[2])
    if legacy_package_root not in sys.path:
        sys.path.append(legacy_package_root)
    from evm import InstrumentedEVM


class LegacyExecutionBackend(InstrumentedEVM):
    backend_name = "legacy"
