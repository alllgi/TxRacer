from copy import deepcopy

from fuzzer.txracer.compat import legacy_keyword_aliases
from fuzzer.txracer.execution.scenario_runner import ScenarioExecutionError

ASSET_PREFILTER_STATUS = "deferred_to_phase4"


class AttackerPruneError(Exception):
    pass


class AttackerPruneResult(object):


    def __init__(self, original, removed_calls, pruned,
                 non_prunable_failures=None, iterations=0,
                 original_ids=None, pruned_ids=None):
        self.original = list(original)
        self.removed_calls = list(removed_calls)
        self.pruned = list(pruned)
        self.non_prunable_failures = list(non_prunable_failures or [])
        self.iterations = int(iterations)
        self.original_ids = (
            list(original_ids)
            if original_ids is not None
            else ["trace-%d" % i for i in range(len(self.original))]
        )
        self.pruned_ids = (
            list(pruned_ids)
            if pruned_ids is not None
            else ["trace-%d" % i for i in range(len(self.pruned))]
        )

    def to_dict(self):
        return {
            "original": self.original,
            "removed_calls": self.removed_calls,
            "pruned": self.pruned,
            "non_prunable_failures": self.non_prunable_failures,
            "iterations": self.iterations,
            "original_ids": self.original_ids,
            "pruned_ids": self.pruned_ids,
        }


@legacy_keyword_aliases(victim_sequence='user_sequence')
def deep_clone_sequence(user_sequence, attacker_address):
    # Construct the attacker's replay without altering the user's original sequence.
    cloned = deepcopy(user_sequence)
    for tx in cloned:
        tx['transaction']['from'] = attacker_address
    return cloned


@legacy_keyword_aliases(victim_sequence='user_sequence')
def prune_attacker_sequence(runner, user_sequence, attacker_address):

    original = deep_clone_sequence(user_sequence, attacker_address)
    original_ids = ["trace-%d" % i for i in range(len(original))]
    current = original
    current_ids = list(original_ids)
    current_original_indices = list(range(len(original)))
    removed_calls = []
    non_prunable_failures = []
    iterations = 0

    while True:
        iterations += 1
        try:
            records = runner.execute_sequence(current, tx_ids=current_ids)
        except ScenarioExecutionError as internal_error:
            raise AttackerPruneError(
                "attacker pruning failed internally: %s" % internal_error
            )

        revert_indices = set()
        for index, record in enumerate(records):
            if record.status == "REVERT":
                revert_indices.add(index)
                removed_calls.append({
                    "tx_id": record.tx_id,
                    "original_tx_id": current_ids[index],
                    "original_position": current_original_indices[index],
                    "position": index,
                    "reason": record.reason,
                    "status": record.status,
                })
            elif record.status == "VALIDATION_ERROR":
                non_prunable_failures.append({
                    "tx_id": record.tx_id,
                    "original_tx_id": current_ids[index],
                    "original_position": current_original_indices[index],
                    "position": index,
                    "reason": record.reason,
                    "status": record.status,
                })

        if non_prunable_failures:

            break
        if not revert_indices:
            break
        current = [
            tx for index, tx in enumerate(current)
            if index not in revert_indices
        ]
        current_ids = [
            tx_id for index, tx_id in enumerate(current_ids)
            if index not in revert_indices
        ]
        current_original_indices = [
            orig_idx for index, orig_idx in enumerate(current_original_indices)
            if index not in revert_indices
        ]
        if not current:
            break

    return AttackerPruneResult(
        original=original,
        removed_calls=removed_calls,
        pruned=current,
        non_prunable_failures=non_prunable_failures,
        iterations=iterations,
        original_ids=original_ids,
        pruned_ids=current_ids,
    )




__all__ = [
    'ASSET_PREFILTER_STATUS',
    'AttackerPruneError',
    'AttackerPruneResult',
    'deep_clone_sequence',
    'prune_attacker_sequence',
]
