import hashlib
import json
from typing import Dict, Optional, Tuple

StorageKey = Tuple[str, int]


class BoundaryRecord(object):


    def __init__(self, min_value=None, min_seed_hash=None,
                 max_value=None, max_seed_hash=None):
        self.min_value = min_value
        self.min_seed_hash = min_seed_hash
        self.max_value = max_value
        self.max_seed_hash = max_seed_hash

    @property
    def observed(self):
        return self.min_value is not None

    def to_dict(self):
        return {
            "min_value": self.min_value,
            "min_seed_hash": self.min_seed_hash,
            "max_value": self.max_value,
            "max_seed_hash": self.max_seed_hash,
        }

    @classmethod
    def from_dict(cls, payload):
        return cls(
            min_value=payload.get("min_value"),
            min_seed_hash=payload.get("min_seed_hash"),
            max_value=payload.get("max_value"),
            max_seed_hash=payload.get("max_seed_hash"),
        )


def seed_hash_for(sequence, slot_key, side, state_ref, snapshot_ref=None,
                  role=None, chromosome=None, value=None,
                  initial_value=None, evidence_ref=None):

    canonical = json.dumps({
        "role": role,
        "sequence": sequence,
        "chromosome": chromosome,
        "slot": [slot_key[0], slot_key[1]],
        "side": side,
        "value": value,
        "initial_value": initial_value,
        "state_ref": state_ref,
        "snapshot_ref": snapshot_ref,
        "evidence_ref": evidence_ref,
    }, sort_keys=True, default=str)
    return hashlib.sha256(canonical.encode("utf-8")).hexdigest()[:16]


class StateCorpus(object):


    def __init__(self):
        self.boundaries = {}
        self.state_corpus = {}
        self.diagnostics = []


        self._range_only_keys = set()


    def observe(self, slot_key, value, sequence, state_ref,
                snapshot_ref=None, role=None, chromosome=None,
                evidence_ref=None, initial_value=None):

        if slot_key not in self.boundaries:
            self.boundaries[slot_key] = BoundaryRecord()
        record = self.boundaries[slot_key]
        value = int(value)
        if not record.observed:
            self._set_min(slot_key, record, value, sequence, state_ref,
                          snapshot_ref, role, chromosome, evidence_ref,
                          initial_value)
            self._set_max(slot_key, record, value, sequence, state_ref,
                          snapshot_ref, role, chromosome, evidence_ref,
                          initial_value)
            return "first_observation"
        replaced = []
        if value < record.min_value:
            self._set_min(slot_key, record, value, sequence, state_ref,
                          snapshot_ref, role, chromosome, evidence_ref,
                          initial_value)
            replaced.append("min")
        if value > record.max_value:
            self._set_max(slot_key, record, value, sequence, state_ref,
                          snapshot_ref, role, chromosome, evidence_ref,
                          initial_value)
            replaced.append("max")
        return "replaced:%s" % ",".join(replaced) if replaced else "equal"

    def _set_min(self, slot_key, record, value, sequence, state_ref,
                 snapshot_ref, role, chromosome, evidence_ref,
                 initial_value=None):
        seed = self._build_seed(slot_key, "min", value, sequence, state_ref,
                                snapshot_ref, role, chromosome, evidence_ref,
                                initial_value)
        self.state_corpus[(slot_key, "min")] = seed
        record.min_value = value
        record.min_seed_hash = seed["seed_hash"]

    def _set_max(self, slot_key, record, value, sequence, state_ref,
                 snapshot_ref, role, chromosome, evidence_ref,
                 initial_value=None):
        seed = self._build_seed(slot_key, "max", value, sequence, state_ref,
                                snapshot_ref, role, chromosome, evidence_ref,
                                initial_value)
        self.state_corpus[(slot_key, "max")] = seed
        record.max_value = value
        record.max_seed_hash = seed["seed_hash"]

    def _build_seed(self, slot_key, side, value, sequence, state_ref,
                    snapshot_ref, role, chromosome, evidence_ref,
                    initial_value=None):

        from copy import deepcopy
        sequence_copy = deepcopy(sequence)
        chromosome_copy = deepcopy(chromosome)
        seed_hash = seed_hash_for(
            sequence_copy, slot_key, side, state_ref,
            snapshot_ref=snapshot_ref, role=role,
            chromosome=chromosome_copy, value=int(value),
            initial_value=initial_value, evidence_ref=evidence_ref)
        return {
            "role": role,
            "slot": [slot_key[0], slot_key[1]],
            "side": side,
            "value": int(value),
            "initial_value": initial_value,
            "seed_hash": seed_hash,


            "sequence": sequence_copy,
            "chromosome": chromosome_copy,
            "state_ref": state_ref,
            "snapshot_ref": snapshot_ref,
            "evidence_ref": evidence_ref,
        }


    def drop_slot(self, slot_key, reason):

        removed = False
        for key in list(self.state_corpus):
            if key[0] == slot_key:
                del self.state_corpus[key]
                removed = True
        if slot_key in self.boundaries:
            del self.boundaries[slot_key]
            removed = True
        if removed:
            self.diagnostics.append({
                "slot": [slot_key[0], slot_key[1]],
                "reason": reason,
            })

    def observe_range(self, slot_key, values, sequence, state_ref,
                      snapshot_ref=None, role=None, chromosome=None,
                      evidence_ref=None, initial_value=None):

        if not values:

            return "empty_range"
        self._range_only_keys.add(slot_key)
        if slot_key not in self.boundaries:
            self.boundaries[slot_key] = BoundaryRecord()
        lower = min(int(v) for v in values)
        upper = max(int(v) for v in values)
        record = self.boundaries[slot_key]
        updated = []
        if not record.observed:
            self._set_min(slot_key, record, lower, sequence, state_ref,
                          snapshot_ref, role, chromosome, evidence_ref,
                          initial_value)
            self._set_max(slot_key, record, upper, sequence, state_ref,
                          snapshot_ref, role, chromosome, evidence_ref,
                          initial_value)
            return "first_range"
        if lower < record.min_value:
            self._set_min(slot_key, record, lower, sequence, state_ref,
                          snapshot_ref, role, chromosome, evidence_ref,
                          initial_value)
            updated.append("min")
        if upper > record.max_value:
            self._set_max(slot_key, record, upper, sequence, state_ref,
                          snapshot_ref, role, chromosome, evidence_ref,
                          initial_value)
            updated.append("max")
        return "replaced:%s" % ",".join(updated) if updated else "equal"

    def sync_validated(self, validated_asset_slots, invalidation_reason=
                       "slot no longer validated"):

        for slot_key in list(self.boundaries):
            if slot_key in self._range_only_keys:

                continue
            if slot_key not in validated_asset_slots:
                self.drop_slot(slot_key, invalidation_reason)


    def bound_violation(self):

        return len(self.state_corpus) > 2 * len(self.boundaries)

    def to_dict(self):
        return {
            "boundaries": {
                "%s:%d" % (key[0], key[1]): record.to_dict()
                for key, record in sorted(self.boundaries.items())
            },
            "state_corpus": {
                "%s:%d:%s" % (key[0][0], key[0][1], key[1]): seed
                for key, seed in sorted(
                    self.state_corpus.items(),
                    key=lambda item: (item[0][0][0], item[0][0][1],
                                      item[0][1]))
            },
            "diagnostics": self.diagnostics,
        }

    @classmethod
    def from_dict(cls, payload):
        corpus = cls()
        for key_text, record_payload in (payload.get("boundaries") or {}).items():
            address, slot = key_text.rsplit(":", 1)
            corpus.boundaries[(address, int(slot))] = BoundaryRecord.from_dict(
                record_payload)
        for key_text, seed in (payload.get("state_corpus") or {}).items():
            address, slot, side = key_text.rsplit(":", 2)
            corpus.state_corpus[(address, int(slot)), side] = seed
        corpus.diagnostics = list(payload.get("diagnostics") or [])
        return corpus

    def stats(self):
        min_count = sum(1 for (_key, side) in self.state_corpus
                        if side == "min")
        return {
            "slots": len(self.boundaries),
            "corpus_size": len(self.state_corpus),
            "min_seeds": min_count,
            "max_seeds": len(self.state_corpus) - min_count,
            "bound": 2 * len(self.boundaries),
        }


__all__ = [
    "BoundaryRecord",
    "StateCorpus",
    "StorageKey",
    "seed_hash_for",
]
