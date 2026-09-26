from eth_abi import encode_abi


def _canonical_values(arg_types, args):

    values = []
    for arg_type, value in zip(arg_types, args):
        if isinstance(value, bytes):
            values.append({"bytes": value.hex()})
        elif isinstance(value, (list, tuple)):
            values.append(_canonical_values(
                [_list_element_type(arg_type)] * len(value), value))
        else:
            values.append(value)
    return values


def _list_element_type(arg_type):
    text = arg_type.strip()
    if text.endswith("]"):
        return text[: text.rfind("[")]
    return text


def encode_with_cache(cache, selector, arg_types, args):

    key_fields = {
        "selector": selector,
        "arg_types": list(arg_types),
        "arg_values": _canonical_values(arg_types, args),
    }
    fresh = encode_abi(list(arg_types), list(args))

    def _abi_semantic_validator(payload):
        validation = _validate_abi_payload(payload)
        if validation:
            return validation
        try:
            if bytes.fromhex(payload) != fresh:
                return "abi_encoding_mismatch"
        except ValueError as hex_error:
            return "payload is not valid hex: %s" % (hex_error,)
        return None

    if cache is not None:
        cached, reason = cache.get(key_fields,
                                   validate=_abi_semantic_validator)
        if cached is not None:
            return bytes.fromhex(cached), "hit"
        cache.put(key_fields, fresh.hex())
        return fresh, "miss"
    return fresh, "miss"


def _validate_abi_payload(payload):

    if not isinstance(payload, str):
        return "payload is not a hex string"
    try:
        bytes.fromhex(payload)
        return None
    except ValueError as hex_error:
        return "payload is not valid hex: %s" % (hex_error,)


__all__ = ["encode_with_cache"]
