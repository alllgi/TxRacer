class InteractionValidationError(Exception):
    pass


def _order_index(order):

    index = {}
    for position, (label, tx_id) in enumerate(order):
        qualified = "%s:%s" % (label, tx_id)
        if qualified in index:
            raise InteractionValidationError(
                "duplicate stable id %r in order (appears at %d and %d)"
                % (qualified, index[qualified], position))
        index[qualified] = position
    return index


def _validate_orders(baseline_order, candidate_order):

    baseline_ids = {"%s:%s" % (label, tx_id)
                   for label, tx_id in baseline_order}
    candidate_ids = {"%s:%s" % (label, tx_id)
                     for label, tx_id in candidate_order}
    if baseline_ids != candidate_ids:
        raise InteractionValidationError(
            "baseline and candidate stable ID sets differ: baseline has "
            "%d ids, candidate has %d ids (missing %r, extra %r)"
            % (len(baseline_ids), len(candidate_ids),
               sorted(baseline_ids - candidate_ids),
               sorted(candidate_ids - baseline_ids)))
    baseline_index = _order_index(baseline_order)
    candidate_index = _order_index(candidate_order)
    if len(baseline_index) != len(baseline_order):
        raise InteractionValidationError(
            "baseline order contains duplicate stable ids")
    if len(candidate_index) != len(candidate_order):
        raise InteractionValidationError(
            "candidate order contains duplicate stable ids")
    return baseline_index, candidate_index


def reversed_preemption_pairs(baseline_order, candidate_order,
                              preemption_pairs):

    if not isinstance(baseline_order, (list, tuple)) or not isinstance(
            candidate_order, (list, tuple)):
        raise InteractionValidationError(
            "baseline/candidate orders must be lists of (label, tx_id)")
    baseline_index, candidate_index = _validate_orders(
        baseline_order, candidate_order)
    reversed_pairs = []
    for point in preemption_pairs:
        user_tx_id = getattr(
            point, "user_tx_id", getattr(point, "a_tx_id", None))
        attacker_tx_id = getattr(
            point, "attacker_tx_id", getattr(point, "b_tx_id", None))
        if user_tx_id is None or attacker_tx_id is None:
            raise InteractionValidationError(
                "preemption pair missing user/attacker tx id")
        user_key = "v:%s" % user_tx_id
        attacker_key = "a:%s" % attacker_tx_id
        for order_name, index in (("baseline", baseline_index),
                                  ("candidate", candidate_index)):
            if user_key not in index:
                raise InteractionValidationError(
                    "PP user tx %r not present in the %s order"
                    % (user_tx_id, order_name))
            if attacker_key not in index:
                raise InteractionValidationError(
                    "PP attacker tx %r not present in the %s order"
                    % (attacker_tx_id, order_name))
        baseline_user_pos = baseline_index[user_key]
        baseline_attacker_pos = baseline_index[attacker_key]
        candidate_user_pos = candidate_index[user_key]
        candidate_attacker_pos = candidate_index[attacker_key]
        baseline_order_ok = baseline_user_pos < baseline_attacker_pos
        candidate_flipped = candidate_attacker_pos < candidate_user_pos
        if baseline_order_ok and candidate_flipped:
            reversed_pairs.append({
                "victim_tx_id": user_tx_id,
                "attacker_tx_id": attacker_tx_id,
                "baseline_victim_position": baseline_user_pos,
                "baseline_attacker_position": baseline_attacker_pos,
                "candidate_victim_position": candidate_user_pos,
                "candidate_attacker_position": candidate_attacker_pos,
            })
    return reversed_pairs


__all__ = [
    "InteractionValidationError",
    "reversed_preemption_pairs",
]
