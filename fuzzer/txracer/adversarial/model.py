import hashlib
import json

from fuzzer.txracer.compat import legacy_keyword_aliases

ADVERSARIAL_SCHEMA_VERSION = 1

OPERATOR_PARAMETER_MUTATION = "parameter_mutation"
OPERATOR_STATE_AWARE_INSERTION = "state_aware_insertion"
OPERATOR_FLOW_REVERSAL = "flow_reversal"

OPERATORS = (
    OPERATOR_PARAMETER_MUTATION,
    OPERATOR_STATE_AWARE_INSERTION,
    OPERATOR_FLOW_REVERSAL,
)


def canonical_transaction_content(transactions):

    return json.dumps(transactions, sort_keys=True, default=str)


def transaction_content_hash(transactions):
    canonical = canonical_transaction_content(transactions)
    return hashlib.sha256(canonical.encode("utf-8")).hexdigest()


class AttackerCandidate(object):


    @legacy_keyword_aliases(victim_sequence_id="user_sequence_id")
    def __init__(self, candidate_id, parent_candidate_id,
                 user_sequence_id, operator_chain, transactions,
                 transaction_ids=None, depth=0, diagnostics=None,
                 economic_state_intersections=None):
        self.schema_version = ADVERSARIAL_SCHEMA_VERSION
        self.candidate_id = str(candidate_id)
        self.parent_candidate_id = str(parent_candidate_id or "")
        self.user_sequence_id = str(user_sequence_id or "")
        self.operator_chain = list(operator_chain)

        self.transactions = _deep_copy(transactions)
        if transaction_ids is None:
            transaction_ids = ["trace-%d" % i
                               for i in range(len(self.transactions))]
        if len(transaction_ids) != len(self.transactions):
            raise ValueError(
                "candidate %s: %d transaction ids for %d transactions"
                % (candidate_id, len(transaction_ids),
                   len(self.transactions)))
        self.transaction_ids = list(transaction_ids)
        self.depth = int(depth)
        self.diagnostics = list(diagnostics or [])
        self.economic_state_intersections = list(
            economic_state_intersections or [])
        self.content_hash = transaction_content_hash(self.transactions)

    @property
    def victim_sequence_id(self):

        return self.user_sequence_id

    @victim_sequence_id.setter
    def victim_sequence_id(self, value):
        self.user_sequence_id = str(value or "")

    def to_dict(self):
        return {
            "schema_version": self.schema_version,
            "candidate_id": self.candidate_id,
            "parent_candidate_id": self.parent_candidate_id,
            "victim_sequence_id": self.user_sequence_id,
            "operator_chain": list(self.operator_chain),
            "transactions": self.transactions,
            "transaction_ids": list(self.transaction_ids),
            "depth": self.depth,
            "content_hash": self.content_hash,
            "diagnostics": list(self.diagnostics),
            "economic_state_intersections": list(
                self.economic_state_intersections),
        }

    def __repr__(self):
        return "AttackerCandidate(%r, depth=%d, ops=%r)" % (
            self.candidate_id, self.depth, self.operator_chain)


def _deep_copy(transactions):
    from copy import deepcopy
    return deepcopy(transactions)




__all__ = [
    'ADVERSARIAL_SCHEMA_VERSION',
    'OPERATOR_FLOW_REVERSAL',
    'OPERATOR_PARAMETER_MUTATION',
    'OPERATOR_STATE_AWARE_INSERTION',
    'OPERATORS',
    'AttackerCandidate',
    'canonical_transaction_content',
    'transaction_content_hash',
]
