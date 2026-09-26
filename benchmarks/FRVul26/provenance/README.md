# Provenance

`index.jsonl` maps unified sample IDs to original records. `metadata/` and
`annotations/` preserve the original event records and detailed annotations.
`paths.jsonl` records original data paths, current file locations, and SHA-256 hashes;
`links.jsonl` records the original relative symbolic links. `assets/` preserves
additional original data files, shared by content.

Contract labels preserve the existing scoring mapping: observed sandwich targets
are positive for CISBL7; reported vulnerable contracts are positive for DeFiHackLabs.
Other analyzable occurrences are negative under this event-target convention.
Original fields such as review status, evidence scope, and negative assertions
remain unchanged. This reorganization adds no independent review or replay validation.
