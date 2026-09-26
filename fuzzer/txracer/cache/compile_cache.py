import hashlib
import json
import os
import re

from fuzzer.txracer.cache import CacheKeyError


IMPORT_PATTERNS = (
    r"import\s+[\"']([^\"']+)[\"']\s*;?",
    r"import\s+\*\s+as\s+\w+\s+from\s+[\"']([^\"']+)[\"']\s*;?",
    r"import\s+\{[^}]*\}\s+from\s+[\"']([^\"']+)[\"']\s*;?",
    r"import\s+\w+\s+as\s+\w+\s+from\s+[\"']([^\"']+)[\"']\s*;?",
    r"import\s+[\"']([^\"']+)[\"']\s+as\s+\w+\s*;?",
)


def _iter_import_paths(content):

    for pattern in IMPORT_PATTERNS:
        for match in re.finditer(pattern, content):
            yield match.group(1)


def _resolve_import(base_dir, imported):

    candidate = None
    if imported.startswith("/"):
        candidate = os.path.abspath(imported)
    elif ":" in imported:
        candidate = os.path.abspath(os.path.join(
            base_dir, imported.split(":", 1)[1]))
    else:
        candidate = os.path.abspath(os.path.join(base_dir, imported))
    if os.path.isfile(candidate):
        return candidate
    return None


def source_file_hashes(source_path):

    hashes = {}
    visited = set()
    missing = set()

    def _walk(file_path):
        absolute = os.path.abspath(file_path)
        if absolute in visited:
            return
        visited.add(absolute)
        logical = absolute
        try:
            with open(absolute, "rb") as handle:
                content_bytes = handle.read()
            hashes[logical] = hashlib.sha256(content_bytes).hexdigest()
        except OSError:
            missing.add(absolute)
            return
        try:
            content = content_bytes.decode("utf-8", errors="replace")
        except Exception:  # noqa: BLE001
            return
        base_dir = os.path.dirname(absolute)
        for imported in _iter_import_paths(content):
            resolved = _resolve_import(base_dir, imported)
            if resolved is None:
                missing.add(imported)
                continue
            _walk(resolved)

    _walk(source_path)
    for logical in sorted(missing):
        hashes["missing-import:%s" % logical] = "missing"
    return hashes


def compile_key(source_path, solc_version, evm_version,
                optimizer_enabled=False, optimizer_runs=200, via_ir=False,
                remappings=None, libraries=None, metadata_settings=None,
                config_fields=None):

    source_hashes = source_file_hashes(source_path)
    if not source_hashes:
        raise CacheKeyError("cannot hash source files for %r"
                            % (source_path,))
    return {
        "source_hashes": dict(sorted(source_hashes.items())),
        "solc_version": str(solc_version),
        "evm_version": str(evm_version),
        "optimizer_enabled": bool(optimizer_enabled),
        "optimizer_runs": int(optimizer_runs),
        "via_ir": bool(via_ir),
        "remappings": sorted(remappings or []),
        "libraries": dict(sorted((libraries or {}).items())),
        "metadata_settings": metadata_settings,
        "config": dict(sorted((config_fields or {}).items())),
    }


def compile_with_cache(cache, source_path, solc_version, evm_version,
                       compile_fn, config_fields=None):

    key_fields = compile_key(source_path, solc_version, evm_version,
                             config_fields=config_fields)
    if cache is not None:
        cached, reason = cache.get(
            key_fields, validate=_validate_compile_payload)
        if cached is not None:
            return cached, "hit"
    output = compile_fn(solc_version, evm_version, source_path)
    if output is not None and cache is not None:
        cache.put(key_fields, output)
    return output, "miss"


def _validate_compile_payload(payload):

    if not isinstance(payload, dict):
        return "payload is not an object"
    if not isinstance(payload.get("contracts"), dict):
        return "missing contracts"
    if not isinstance(payload.get("sources"), dict):
        return "missing sources"
    if not payload["contracts"]:
        return "empty contracts"
    return None


def deployment_plan_key(contract_name, bytecode_hash, constructor_args_hash,
                        link_config, deploy_order, config_fields=None):

    return {
        "contract": contract_name,
        "bytecode_hash": bytecode_hash,
        "constructor_args_hash": constructor_args_hash,
        "link_config": dict(sorted((link_config or {}).items())),
        "deploy_order": list(deploy_order or []),
        "config": dict(sorted((config_fields or {}).items())),
    }


def deployment_plan_with_cache(cache, key_fields, compute_fn):

    if cache is not None:
        cached, reason = cache.get(
            key_fields, validate=_validate_deployment_payload)
        if cached is not None:
            return cached, "hit"
    plan = compute_fn()
    if plan is not None and cache is not None:
        cache.put(key_fields, plan)
    return plan, "miss"


def _validate_deployment_payload(payload):

    if not isinstance(payload, dict):
        return "payload is not an object"
    if not isinstance(payload.get("bytecode"), str):
        return "missing bytecode"
    if not isinstance(payload.get("deploy_order"), list):
        return "missing deploy_order"
    return None


__all__ = [
    "compile_key",
    "compile_with_cache",
    "deployment_plan_key",
    "deployment_plan_with_cache",
    "source_file_hashes",
]
