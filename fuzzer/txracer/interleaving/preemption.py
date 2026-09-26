from fuzzer.txracer.interleaving.modes import (
    SUPPORTED_WEIGHT_MODES,
    WEIGHT_MODE_EXTENDED,
    WEIGHT_MODE_PAPER,
)
from fuzzer.txracer.compat import legacy_keyword_aliases


def _conflict_type(user_rw, attacker_rw, key):
    w_w = key in user_rw.writes and key in attacker_rw.writes
    w_r = key in user_rw.writes and key in attacker_rw.reads
    r_w = key in user_rw.reads and key in attacker_rw.writes
    if w_w:
        return "W-W"
    if w_r:
        return "W-R"
    if r_w:
        return "R-W"
    return None


class PreemptionPoint(object):


    @legacy_keyword_aliases(
        a_idx="user_idx",
        b_idx="attacker_idx",
        a_tx_id="user_tx_id",
        b_tx_id="attacker_tx_id",
        reverted_a="user_reverted",
        reverted_b="attacker_reverted",
    )
    def __init__(self, user_idx, attacker_idx, user_tx_id, attacker_tx_id,
                 conflict_keys,
                 conflict_types, asset_keys, weights, decomposition,
                 user_reverted=False, attacker_reverted=False):
        self.user_idx = user_idx
        self.attacker_idx = attacker_idx
        self.user_tx_id = user_tx_id
        self.attacker_tx_id = attacker_tx_id
        self.conflict_keys = set(conflict_keys)
        self.conflict_types = dict(conflict_types)
        self.asset_keys = set(asset_keys)
        self.weights = dict(weights)
        self.decomposition = dict(decomposition)
        self.user_reverted = bool(user_reverted)
        self.attacker_reverted = bool(attacker_reverted)

    @property
    def a_idx(self):
        return self.user_idx

    @property
    def b_idx(self):
        return self.attacker_idx

    @property
    def a_tx_id(self):
        return self.user_tx_id

    @property
    def b_tx_id(self):
        return self.attacker_tx_id

    @property
    def reverted_a(self):
        return self.user_reverted

    @property
    def reverted_b(self):
        return self.attacker_reverted

    def weight_for(self, weight_mode):
        return self.weights.get(weight_mode, 0)

    def to_dict(self, weight_mode=None):
        mode = weight_mode or WEIGHT_MODE_EXTENDED
        return {
            "a_idx": self.user_idx,
            "b_idx": self.attacker_idx,
            "a_tx_id": self.user_tx_id,
            "b_tx_id": self.attacker_tx_id,
            "conflict_keys": [list(key) for key in sorted(self.conflict_keys)],
            "conflict_types": {
                "%s:%d" % (key[0], key[1]): kind
                for key, kind in sorted(
                    self.conflict_types.items(),
                    key=lambda item: (item[0][0], item[0][1]),
                )
            },
            "asset_keys": [list(key) for key in sorted(self.asset_keys)],
            "reverted_a": self.user_reverted,
            "reverted_b": self.attacker_reverted,
            "weights": self.weights,
            "decomposition": self.decomposition,
            "weight_mode": mode,
            "weight": self.weight_for(mode),
        }


def _point_weights(conflict_keys, asset_keys, user_rw, attacker_rw):
    write_write = user_rw.writes & attacker_rw.writes
    asset_ww = len(asset_keys & write_write)
    asset_rw = len(asset_keys) - asset_ww
    generic = len(conflict_keys - asset_keys)
    extended = 4 * asset_ww + 2 * asset_rw + 1 * generic

    paper = len(asset_keys & (user_rw.writes | attacker_rw.writes))
    return (
        {"paper": paper, "extended": extended},
        {"asset_write_write": asset_ww, "asset_read_write": asset_rw,
         "generic_write": generic},
    )


@legacy_keyword_aliases(victim_rw_sets='user_rw_sets')
def find_all_preemption_points(user_rw_sets, attacker_rw_sets):

    points = []
    for a_idx, user in enumerate(user_rw_sets):
        for b_idx, attacker in enumerate(attacker_rw_sets):
            conflict_keys = (
                (user.writes & attacker.reads)
                | (user.reads & attacker.writes)
                | (user.writes & attacker.writes)
            )
            if not conflict_keys:
                continue
            conflict_types = {
                key: _conflict_type(user, attacker, key)
                for key in conflict_keys
            }
            asset_keys = conflict_keys & (
                user.asset_reads
                | user.asset_writes
                | attacker.asset_reads
                | attacker.asset_writes
            )
            weights, decomposition = _point_weights(
                conflict_keys, asset_keys, user, attacker)
            points.append(PreemptionPoint(
                user_idx=a_idx,
                attacker_idx=b_idx,
                user_tx_id=user.tx_id,
                attacker_tx_id=attacker.tx_id,
                conflict_keys=conflict_keys,
                conflict_types=conflict_types,
                asset_keys=asset_keys,
                weights=weights,
                decomposition=decomposition,
                user_reverted=user.reverted,
                attacker_reverted=attacker.reverted,
            ))
    return points


def sort_preemption_points(points, weight_mode=WEIGHT_MODE_EXTENDED):

    if weight_mode not in SUPPORTED_WEIGHT_MODES:
        raise ValueError("unsupported weight mode: %r" % (weight_mode,))
    return sorted(
        points,
        key=lambda point: (
            -point.weight_for(weight_mode),
            point.user_idx,
            point.attacker_idx,
            point.user_tx_id or "",
            point.attacker_tx_id or "",
            sorted(point.conflict_keys),
        ),
    )


__all__ = [
    "SUPPORTED_WEIGHT_MODES",
    "WEIGHT_MODE_EXTENDED",
    "WEIGHT_MODE_PAPER",
    "PreemptionPoint",
    "find_all_preemption_points",
    "sort_preemption_points",
]
