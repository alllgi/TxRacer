import hashlib
import json
import os


class AssetMapError(Exception):
    pass


class AssetMapInfo(object):


    def __init__(self, path=None, provided=False, loaded=False, sha256=None,
                 slot_count=0, diagnostics=None):
        self.path = path
        self.provided = provided
        self.loaded = loaded
        self.sha256 = sha256
        self.slot_count = slot_count
        self.diagnostics = list(diagnostics if diagnostics is not None else [])

    def to_dict(self):
        return {
            "path": self.path,
            "provided": self.provided,
            "loaded": self.loaded,
            "sha256": self.sha256,
            "slot_count": self.slot_count,
            "diagnostics": self.diagnostics,
        }


def load_asset_map(path=None):

    if not path:
        return AssetMapInfo()

    if not os.path.exists(path):
        raise AssetMapError(
            "explicit asset map not found: %s (fail fast, refusing to continue)" % path
        )

    sha256 = None
    try:
        with open(path, "rb") as handle:
            raw = handle.read()
        sha256 = hashlib.sha256(raw).hexdigest()
        parsed = json.loads(raw.decode("utf-8"))
        if not isinstance(parsed, dict):
            raise AssetMapError(
                "asset map %s is not a JSON object" % path
            )
    except AssetMapError:
        raise
    except (ValueError, UnicodeDecodeError) as parse_error:
        raise AssetMapError("asset map %s is malformed: %s" % (path, parse_error))

    slot_count = 0
    for var_info in parsed.values():
        if isinstance(var_info, dict) and "slot" in var_info and not var_info.get("is_mapping"):
            try:
                int(var_info["slot"])
                slot_count += 1
            except (TypeError, ValueError):
                continue

    return AssetMapInfo(
        path=path,
        provided=True,
        loaded=True,
        sha256=sha256,
        slot_count=slot_count,
    )


__all__ = ["AssetMapError", "AssetMapInfo", "load_asset_map"]
