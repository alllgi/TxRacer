"""Link compiler-declared library slots to deployed instances."""


def link_template(bytecode, references, bindings=None, deployed=None):
    encoded = bytecode[2:] if bytecode.startswith('0x') else bytecode
    spans = []
    for source, libraries in references.items():
        for library, locations in libraries.items():
            key = source + ':' + library
            if bindings is None:
                # A zero-address mask is for bytecode inspection only.
                replacement = '00' * 20
            else:
                instance = bindings.get(key)
                if not isinstance(instance, str) or not instance.startswith('@') or instance[1:] not in deployed:
                    raise ValueError('Missing real deployed library instance: ' + key)
                replacement = deployed[instance[1:]]
                replacement = replacement[2:] if replacement.startswith('0x') else replacement
                if len(replacement) != 40 or int(replacement, 16) == 0:
                    raise ValueError('Invalid deployed library address: ' + key)
            for location in locations:
                start, length = location['start'] * 2, location['length'] * 2
                if length != 40 or start < 0 or start + length > len(encoded):
                    raise ValueError('Invalid compiler library link span')
                spans.append((start, start + length, replacement))
    end = 0
    for start, stop, replacement in sorted(spans):
        if start < end:
            raise ValueError('Overlapping compiler library link spans')
        encoded = encoded[:start] + replacement + encoded[stop:]
        end = stop
    try:
        bytes.fromhex(encoded)
    except ValueError:
        raise ValueError('Unresolved placeholders outside declared library links')
    return encoded
