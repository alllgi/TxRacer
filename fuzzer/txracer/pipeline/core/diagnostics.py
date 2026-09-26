"""Serializable abort diagnostics; no retry or recovery policy."""

from dataclasses import asdict
import traceback


def is_memory_error(error):

    for _ in range(32):
        if isinstance(error, MemoryError):
            return True
        if error is None:
            return False
        error = error.__cause__ if error.__cause__ is not None else error.__context__
    return False


class ExecutionAborted(RuntimeError):
    def __init__(self, stage, partial_result, transaction_index=None):
        super().__init__("Execution aborted during %s" % stage)
        self.stage = stage
        self.partial_result = partial_result
        self.transaction_index = transaction_index


class CampaignAborted(RuntimeError):
    def __init__(self, summary):
        super().__init__("Campaign aborted; partial summary available")
        self.summary = summary


def execution_summary(result):
    if result is None:
        return None
    return {
        "sequence": result.sequence.to_dict(), "baseline": vars(result.baseline),
        "records": [dict(tx_id=r.tx_id, transaction=r.transaction.to_dict(),
                         status=r.status, reason=r.reason, reads=sorted(r.reads),
                         writes=sorted(r.writes), coverage=sorted(r.coverage),
                         branches=sorted(r.branches), notes=r.notes,
                         return_value=r.return_value.hex(),
                         asset_flows=[flow.to_dict() for flow in r.asset_flows],
                         storage_changes=r.storage_changes) for r in result.records],
        "asset_balances": result.asset_balances,
        "asset_queries": result.asset_queries,
        "asset_observation_failures": [asdict(item) for item in result.asset_observation_failures],
    }


def exception_summary(error):
    if is_memory_error(error):
        return {"type": "MemoryError", "message": "allocation failed", "resource_error": True}
    cause = error
    while cause.__cause__ is not None:
        cause = cause.__cause__
    diagnostic = {"type": type(cause).__name__, "message": str(cause),
                  "traceback": "".join(traceback.format_exception(type(error), error, error.__traceback__))}
    if isinstance(error, ExecutionAborted):
        diagnostic.update(backend_stage=error.stage, transaction_index=error.transaction_index,
                          partial_execution=execution_summary(error.partial_result))
    return diagnostic
