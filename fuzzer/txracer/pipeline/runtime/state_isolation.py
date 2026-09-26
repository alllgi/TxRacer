"""Restore setup checkpoints after offline probes, including exceptional exits."""
from contextlib import contextmanager


def verify_state(backend, baseline):
    actual = backend.state_fingerprint()
    if actual != baseline.fingerprint:
        raise RuntimeError("State isolation failed: account/storage/code differ from required setup")
    state = backend._runtime.vm.state
    for name in ("timestamp", "blocknumber", "balance", "call_return", "extcodesize", "returndatasize"):
        if getattr(state, "fuzzed_" + name, None) not in (None, {}):
            raise RuntimeError("State isolation failed: transient execution environment remains")
    return actual


@contextmanager
def isolated_state(backend, baseline, diagnostics=None, phase="probe"):
    """Each phase begins and ends at the same full post-setup checkpoint."""
    try:
        backend.restore(baseline)
        verify_state(backend, baseline)
    except BaseException:
        if diagnostics is not None:
            diagnostics["state_restore_success"] = False
        raise
    try:
        yield
    finally:
        try:
            backend.restore(baseline)
            fingerprint = verify_state(backend, baseline)
        except BaseException:
            if diagnostics is not None:
                diagnostics["state_restore_success"] = False
            raise
        if diagnostics is not None:
            if diagnostics.get("state_restore_success") is not False:
                diagnostics["state_restore_success"] = True
            diagnostics.setdefault("state_checks", []).append(dict(phase=phase, fingerprint=fingerprint))
