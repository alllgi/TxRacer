#!/usr/bin/env python3


import argparse
import json
import shutil
import sys

from fuzzer.txracer.planner.sequence_planner import (
    PlannerError,
    plan_sequence_template,
)

DEFAULT_OUTPUT = "sequence_template.json"


def _find_solc(explicit_path):

    if explicit_path:
        if not shutil.which(explicit_path) and not _is_executable_file(
                explicit_path):
            raise PlannerError(
                "solc path %r does not exist or is not executable"
                % (explicit_path,))
        return explicit_path
    found = shutil.which("solc")
    if not found:
        raise PlannerError(
            "--solc not provided and no solc binary found on PATH")
    return found


def _is_executable_file(path):
    import os
    return os.path.isfile(path) and os.access(path, os.X_OK)


def main():
    parser = argparse.ArgumentParser(
        description="Generate a stable function sequence template "
                    "sequence_template.json from static Slither analysis.")
    parser.add_argument("solidity_file", help="Path to the Solidity "
                        "source file (.sol).")
    parser.add_argument(
        "-o", "--output", default=DEFAULT_OUTPUT,
        help="Path to the output JSON file (default: %s)."
        % DEFAULT_OUTPUT)
    parser.add_argument(
        "--solc", dest="solc_path", default=None,
        help="Path to the solc binary. If not provided, solc is looked "
             "up on PATH.")
    parser.add_argument(
        "--planner-failure-mode", dest="planner_failure_mode",
        choices=("fail", "fallback"), default="fail",
        help="Failure mode when planning fails: fail exits non-zero "
             "(default); fallback writes a template with an explicit "
             "planner_failure record and an empty sequence.")
    parser.add_argument(
        "--readonly-cache", dest="readonly_cache", action="store_true",
        help="Phase 5-D: use the read-only Slither/planner cache "
             "(default off).")
    parser.add_argument(
        "--cache-dir", dest="cache_dir", default=None,
        help="Phase 5-D: cache directory (default .txracer_cache).")
    args = parser.parse_args()

    solc_path = _find_solc(args.solc_path)
    planner_cache = None
    if args.readonly_cache:
        from fuzzer.txracer.cache import CacheManager
        cache_manager = CacheManager(
            args.cache_dir or ".txracer_cache", enabled=True)
        planner_cache = cache_manager.planner_cache
    print("[*] Planning sequence template for %s (solc %s)"
          % (args.solidity_file, solc_path))
    template = plan_sequence_template(
        args.solidity_file, solc_path=solc_path,
        planner_failure_mode=args.planner_failure_mode,
        cache=planner_cache)
    with open(args.output, "w", encoding="utf-8") as handle:
        json.dump(template, handle, indent=2, sort_keys=True)
        handle.write("\n")
    if template.get("planner_failure"):
        print("[!] Planning failed (fallback mode): %s"
              % template["planner_failure"], file=sys.stderr)
    else:
        print("[*] Successfully wrote %s (content hash %s, %d candidates, "
              "%d skipped, sequence length %d)"
              % (args.output, template["content_hash"],
                 len(template["candidate_functions"]),
                 len(template["skipped_functions"]),
                 len(template["sequence"])))


if __name__ == "__main__":
    try:
        main()
    except PlannerError as plan_error:
        print("[!] %s" % plan_error, file=sys.stderr)
        sys.exit(1)
    except Exception as unexpected_error:  # noqa: BLE001
        print("[!] Unexpected error: %s" % unexpected_error, file=sys.stderr)
        sys.exit(1)
