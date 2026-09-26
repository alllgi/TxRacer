# Evaluation

Keep labels and historical evidence separate from detector inputs.

Contract labels follow the existing event-target scoring convention: `positive`
identifies annotated targets; `negative` identifies other analyzable participants.
They are not a claim of independently established code-level safety or vulnerability.
Original evidence and label derivation are retained in [provenance/](provenance/).

Count each `(sample_id, contract_address)` separately. The 3,584 analyzable
occurrences contain 321 positives and 3,263 negatives. Two additional positives
have `input_available: false`; include them in the end-to-end denominator of 323.
For valid completed analyses, compute precision, recall, and F1 from TP/FP/FN/TN.
Report failures, timeouts, and coverage separately; they are not negative predictions.

For event recall, pair-based tools must match both endpoints of a reference
interaction; single-function tools may match either endpoint. An endpoint includes
the contract address and full function signature. Of 134 events, 126 have available
reference interactions; the other eight remain unavailable for this metric.
`AN` counts events with a complete interaction whose required contracts received
valid analysis; `DE` counts matching detections. Report `DE / AN` and end-to-end
recovery `DE / 126`. Keep function-only labels separate from complete interactions.

Count duplicate alerts once per occurrence. Zero denominators are undefined.
Compute combined scores from summed counts, and keep repeated runs separate.
