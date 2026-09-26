# Security and responsible use

TxRacer constructs candidate attack transaction sequences, explores attacker/user
interleavings, and records replay evidence for smart-contract security analysis.
This is a dual-use capability: the same evidence that helps an auditor reproduce
an issue may help someone construct an attack against real on-chain assets.

## Real on-chain asset risk

Attack candidates can reveal transaction-order manipulation, economic loss, or
asset-transfer paths. Findings may expose sensitive contract behavior even when
they were produced with a local EVM and synthetic accounts. Do not treat a finding
as proof of a profitable live attack: deployed state, transaction inclusion, fees,
and application intent still require review. Likewise, zero findings do not prove
that deployed assets are safe.

## Authorized testing

Use TxRacer only on contracts and environments for which you have explicit
authorization, and stay within the owner's agreed scope. Use isolated test state,
synthetic assets, and dedicated test accounts. Never provide production signing
keys or broadcast generated attack sequences against live assets outside that
authorization. The documented standalone runner executes in a local EVM and does
not submit transactions to a public chain.

## Handling attack evidence

Treat transaction sequences, attack parameters, and replay records as sensitive
security material. Store them with access limited to the authorized audit team.
Do not commit private keys, private target configurations, or actionable evidence
for an unpatched deployment to this repository.

Report validated issues privately to the affected contract owner's published
security contact or disclosure program. Share enough evidence for authorized
reproduction, coordinate remediation, and avoid publishing attack instructions
for an unpatched target.

## Interpreting the attacker role

`attacker` explicitly identifies the adversarial account. `attacker_sequence`,
`attacker_transaction_ids`, and asset-gain fields describe simulated attack
behavior; they are not authorization to use that behavior against someone else's
assets. The naming and security guidance make this risk visible to readers and
maintainers throughout the analysis pipeline.
