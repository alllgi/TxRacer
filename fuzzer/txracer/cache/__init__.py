import hashlib
import json
import os

CACHE_SCHEMA_VERSION = 2


class CacheKeyError(Exception):
    pass


class ReadOnlyCache(object):


    def __init__(self, cache_dir, kind, schema_version=CACHE_SCHEMA_VERSION,
                 enabled=True):
        self.kind = kind
        self.schema_version = int(schema_version)
        self.enabled = bool(enabled)
        self.cache_dir = os.path.join(cache_dir, kind) if enabled else None
        self.stats = {
            "hits": 0,
            "misses": 0,
            "corruptions": 0,
            "invalidations": 0,
            "write_failures": 0,
        }
        if enabled:
            os.makedirs(self.cache_dir, exist_ok=True)


    def key_for(self, key_fields):

        try:
            canonical = json.dumps(key_fields, sort_keys=True,
                                   default=_json_default)
        except (TypeError, ValueError) as key_error:
            raise CacheKeyError(str(key_error))
        return hashlib.sha256(canonical.encode("utf-8")).hexdigest()


    def get(self, key_fields, validate=None):

        if not self.enabled:
            return None, "disabled"
        try:
            digest = self.key_for(key_fields)
        except CacheKeyError as key_error:
            self.stats["misses"] += 1
            return None, "key_error:%s" % (key_error,)
        path = os.path.join(self.cache_dir, "%s.json" % digest)
        try:
            with open(path, "r", encoding="utf-8") as handle:
                payload = json.load(handle)
        except OSError:
            self.stats["misses"] += 1
            return None, "missing"
        except ValueError as parse_error:
            self.stats["corruptions"] += 1
            self.stats["misses"] += 1
            self._remove(path)
            return None, "corrupt:%s" % (parse_error,)
        if payload.get("schema_version") != self.schema_version:
            self.stats["invalidations"] += 1
            self.stats["misses"] += 1
            self._remove(path)
            return None, "schema_version_mismatch"
        if payload.get("kind") != self.kind:
            self.stats["corruptions"] += 1
            self.stats["misses"] += 1
            self._remove(path)
            return None, "corrupt:kind_mismatch"
        stored_hash = payload.get("payload_hash")
        if not isinstance(stored_hash, str) or len(stored_hash) != 64:
            self.stats["corruptions"] += 1
            self.stats["misses"] += 1
            self._remove(path)
            return None, "corrupt:payload_hash_missing"
        try:
            computed = self._payload_hash(payload.get("payload"))
        except (TypeError, ValueError):
            self.stats["corruptions"] += 1
            self.stats["misses"] += 1
            self._remove(path)
            return None, "corrupt:payload_unhashable"
        if computed != stored_hash:
            self.stats["corruptions"] += 1
            self.stats["misses"] += 1
            self._remove(path)
            return None, "corrupt:payload_hash_mismatch"
        try:
            if payload.get("key") != key_fields:
                self.stats["invalidations"] += 1
                self.stats["misses"] += 1
                self._remove(path)
                return None, "key_mismatch"
        except CacheKeyError:
            self.stats["misses"] += 1
            return None, "key_error"
        if validate is not None:
            validation = validate(payload.get("payload"))
            if validation:
                self.stats["corruptions"] += 1
                self.stats["misses"] += 1
                self._remove(path)
                return None, "corrupt:validation:%s" % (validation,)


        self.stats["hits"] += 1
        return payload.get("payload"), None

    def put(self, key_fields, payload):

        if not self.enabled:
            return False
        try:
            digest = self.key_for(key_fields)
            path = os.path.join(self.cache_dir, "%s.json" % digest)
            temp_path = "%s.tmp" % path
            with open(temp_path, "w", encoding="utf-8") as handle:
                json.dump({
                    "kind": self.kind,
                    "schema_version": self.schema_version,
                    "key": key_fields,
                    "payload_hash": self._payload_hash(payload),
                    "payload": payload,
                }, handle, sort_keys=True, default=_json_default)
            os.replace(temp_path, path)
            return True
        except (OSError, TypeError, ValueError):
            self.stats["write_failures"] += 1
            return False

    @staticmethod
    def _payload_hash(payload):

        canonical = json.dumps(payload, sort_keys=True,
                               default=_json_default)
        return hashlib.sha256(canonical.encode("utf-8")).hexdigest()

    def path_for(self, key_fields):
        return os.path.join(self.cache_dir,
                            "%s.json" % self.key_for(key_fields))

    def _remove(self, path):
        try:
            os.remove(path)
        except OSError:
            pass

    def clean(self):

        if not self.enabled or not os.path.isdir(self.cache_dir):
            return 0
        removed = 0
        for name in os.listdir(self.cache_dir):
            if name.endswith(".json") or name.endswith(".tmp"):
                try:
                    os.remove(os.path.join(self.cache_dir, name))
                    removed += 1
                except OSError:
                    pass
        self.stats = {key: 0 for key in self.stats}
        return removed

    def to_dict(self):
        return {
            "kind": self.kind,
            "enabled": self.enabled,
            "schema_version": self.schema_version,
            "cache_dir": self.cache_dir,
            "stats": dict(self.stats),
        }


class CacheManager(object):


    def __init__(self, cache_dir, enabled=True):
        self.cache_dir = cache_dir
        self.enabled = bool(enabled)
        self.compile_cache = ReadOnlyCache(
            cache_dir, "compile", enabled=enabled)
        self.planner_cache = ReadOnlyCache(
            cache_dir, "planner", enabled=enabled)
        self.abi_cache = ReadOnlyCache(
            cache_dir, "abi_encode", enabled=enabled)
        self.deployment_cache = ReadOnlyCache(
            cache_dir, "deployment", enabled=enabled)

    def clean(self):
        total = 0
        for cache in (self.compile_cache, self.planner_cache,
                      self.abi_cache, self.deployment_cache):
            total += cache.clean()
        return total

    def to_dict(self):
        return {
            "enabled": self.enabled,
            "cache_dir": self.cache_dir,
            "caches": {
                cache.kind: cache.to_dict()
                for cache in (self.compile_cache, self.planner_cache,
                              self.abi_cache, self.deployment_cache)
            },
        }


def _json_default(value):
    if isinstance(value, (set, frozenset)):
        return sorted(value)
    if isinstance(value, bytes):
        return value.hex()
    raise TypeError("not JSON serializable: %r" % (value,))


__all__ = [
    "CACHE_SCHEMA_VERSION",
    "CacheKeyError",
    "CacheManager",
    "ReadOnlyCache",
]
