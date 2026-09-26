from functools import wraps


def _same_value(left, right):
    if left is right:
        return True
    try:
        return bool(left == right)
    except (TypeError, ValueError):
        return False


def legacy_keyword_aliases(**aliases):


    def decorate(function):
        @wraps(function)
        def wrapped(*args, **kwargs):
            for legacy_name, canonical_name in aliases.items():
                if legacy_name not in kwargs:
                    continue
                legacy_value = kwargs.pop(legacy_name)
                if canonical_name in kwargs:
                    if not _same_value(kwargs[canonical_name], legacy_value):
                        raise TypeError(
                            "conflicting values for %r and legacy alias %r"
                            % (canonical_name, legacy_name)
                        )
                    continue
                kwargs[canonical_name] = legacy_value
            return function(*args, **kwargs)

        return wrapped

    return decorate


__all__ = ["legacy_keyword_aliases"]
