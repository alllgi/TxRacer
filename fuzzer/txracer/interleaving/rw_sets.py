from fuzzer.txracer.compat import legacy_keyword_aliases


class TransactionRWSet(object):


    def __init__(self, tx_id, sender, reads, writes,
                 asset_reads=None, asset_writes=None, reverted=False,
                 notes=None):
        self.tx_id = tx_id
        self.sender = sender
        self.reads = set(reads)
        self.writes = set(writes)
        self.asset_reads = set(asset_reads if asset_reads is not None else ())
        self.asset_writes = set(asset_writes if asset_writes is not None else ())
        self.reverted = bool(reverted)
        self.notes = list(notes if notes is not None else [])

    def to_dict(self):
        return {
            "tx_id": self.tx_id,
            "sender": self.sender,
            "reads": [list(key) for key in sorted(self.reads)],
            "writes": [list(key) for key in sorted(self.writes)],
            "asset_reads": [list(key) for key in sorted(self.asset_reads)],
            "asset_writes": [list(key) for key in sorted(self.asset_writes)],
            "reverted": self.reverted,
            "notes": sorted(self.notes),
        }


class AnchorPairResult(object):


    def __init__(self, user_rw=None, attacker_rw=None, ur_result=None,
                 ru_result=None, skip_reason=None):
        self.user_rw = list(user_rw or ())
        self.attacker_rw = list(attacker_rw or ())
        self.ur_result = ur_result
        self.ru_result = ru_result
        self.skip_reason = skip_reason

    @property
    def anchor_results(self):
        if self.skip_reason is not None:
            return {}
        return {"UR": self.ur_result, "RU": self.ru_result}


def _asset_subset(keys, predicate):
    if predicate is None:
        return set()
    return {key for key in keys if predicate(key)}


def rw_set_from_record(record, asset_key_predicate=None):

    return TransactionRWSet(
        tx_id=record.tx_id,
        sender=record.sender,
        reads=record.reads,
        writes=record.writes,
        asset_reads=_asset_subset(record.reads, asset_key_predicate),
        asset_writes=_asset_subset(record.writes, asset_key_predicate),
        reverted=record.status != "SUCCESS",
        notes=list(record.notes),
    )


def _union_anchor_records(first, second, asset_key_predicate):

    if len(first) != len(second):
        raise ValueError("anchor record counts differ")
    result = []
    for first_record, second_record in zip(first, second):
        if first_record.tx_id != second_record.tx_id:
            raise ValueError(
                "anchor transaction IDs differ: %r != %r"
                % (first_record.tx_id, second_record.tx_id))
        reads = set(first_record.reads) | set(second_record.reads)
        writes = set(first_record.writes) | set(second_record.writes)
        result.append(TransactionRWSet(
            tx_id=first_record.tx_id,
            sender=first_record.sender or second_record.sender,
            reads=reads,
            writes=writes,
            asset_reads=_asset_subset(reads, asset_key_predicate),
            asset_writes=_asset_subset(writes, asset_key_predicate),
            reverted=(first_record.status != "SUCCESS"
                      or second_record.status != "SUCCESS"),
            notes=list(first_record.notes) + list(second_record.notes),
        ))
    return result


def _stable_ids(sequence, ids):
    if ids is None:
        return ["trace-%d" % index for index in range(len(sequence))]
    if len(ids) != len(sequence):
        raise ValueError(
            "stable id count %d does not match sequence length %d"
            % (len(ids), len(sequence)))
    return list(ids)


def _split_anchor_records(ur_records, ru_records, user_count, attacker_count):
    ur_user = ur_records[:user_count]
    ur_attacker = ur_records[user_count:user_count + attacker_count]
    ru_attacker = ru_records[:attacker_count]
    ru_user = ru_records[attacker_count:attacker_count + user_count]
    return ur_user, ru_user, ur_attacker, ru_attacker


@legacy_keyword_aliases(victim_sequence='user_sequence', victim_ids='user_ids')
def collect_rw_sets(runner, user_sequence, attacker_sequence,
                    asset_key_predicate=None, user_ids=None,
                    attacker_ids=None):

    from fuzzer.txracer.interleaving.scheduler import sequence_pair_skip_reason

    if sequence_pair_skip_reason(user_sequence, attacker_sequence) is not None:
        return [], []
    user_ids = _stable_ids(user_sequence, user_ids)
    attacker_ids = _stable_ids(attacker_sequence, attacker_ids)
    ur_records = runner.execute_sequence(
        list(user_sequence) + list(attacker_sequence),
        tx_ids=user_ids + attacker_ids)
    ru_records = runner.execute_sequence(
        list(attacker_sequence) + list(user_sequence),
        tx_ids=attacker_ids + user_ids)
    ur_user, ru_user, ur_attacker, ru_attacker = _split_anchor_records(
        ur_records, ru_records, len(user_sequence), len(attacker_sequence))
    return (
        _union_anchor_records(ur_user, ru_user, asset_key_predicate),
        _union_anchor_records(ur_attacker, ru_attacker, asset_key_predicate),
    )


@legacy_keyword_aliases(victim_sequence='user_sequence', victim_addr='user_addr', victim_ids='user_ids')
def collect_anchor_rw_sets(runner, user_sequence, attacker_sequence,
                           user_addr=None, attacker_addr=None,
                           asset_key_predicate=None, user_ids=None,
                           attacker_ids=None):

    from fuzzer.txracer.interleaving.scheduler import sequence_pair_skip_reason

    skip_reason = sequence_pair_skip_reason(user_sequence, attacker_sequence)
    if skip_reason is not None:
        return AnchorPairResult(skip_reason=skip_reason)
    user_ids = _stable_ids(user_sequence, user_ids)
    attacker_ids = _stable_ids(attacker_sequence, attacker_ids)
    if user_addr is None:
        user_addr = user_sequence[0]["transaction"]["from"]
    if attacker_addr is None:
        attacker_addr = attacker_sequence[0]["transaction"]["from"]

    ur_result = runner.run_baseline(
        user_sequence, attacker_sequence, user_addr, attacker_addr,
        user_ids=user_ids, attacker_ids=attacker_ids)
    ru_result = runner.run_candidate(
        list(attacker_sequence) + list(user_sequence), user_addr, attacker_addr,
        tx_ids=attacker_ids + user_ids)
    ur_user, ru_user, ur_attacker, ru_attacker = _split_anchor_records(
        ur_result.tx_results, ru_result.tx_results,
        len(user_sequence), len(attacker_sequence))
    return AnchorPairResult(
        user_rw=_union_anchor_records(
            ur_user, ru_user, asset_key_predicate),
        attacker_rw=_union_anchor_records(
            ur_attacker, ru_attacker, asset_key_predicate),
        ur_result=ur_result,
        ru_result=ru_result,
    )


__all__ = [
    "AnchorPairResult",
    "TransactionRWSet",
    "collect_anchor_rw_sets",
    "collect_rw_sets",
    "rw_set_from_record",
]
