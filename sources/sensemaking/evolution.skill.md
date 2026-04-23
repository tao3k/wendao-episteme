---
name: sensemaking-conflict-evolution
description: Review conflict diagnostics and draft a consensus-preserving policy proposal
---

# Sensemaking Conflict Evolution

Review one configured conflict source from `sources.toml`.

Use the conflict matrix as the enacted arbitration law. Use Sentinel v2 planning
material only to improve diagnostic provenance and review flow. Do not edit
files. Return evidence and a reviewable proposal only.

## Steps

1. Read the selected source entry from `sources.toml`.
2. Read `episteme.toml` and identify the relevant `[[conflicts]]` record.
3. Read `policies/conflicts/validation.sql` and its diagnostic mapping.
4. If the selected source is Sentinel v2 planning material, extract only
   provenance, drift, and disagreement-routing requirements.
5. Compare the source signals with the current conflict policy.
6. Keep authority order stable unless a human reviewer has already accepted a
   governance change.
7. If there are no findings, return an empty proposal and set
   `humanReviewRequired` to `false`.
8. If there are findings, write a concise evolution analysis with evidence,
   risks, and the affected conflict id.
9. Draft the smallest reviewable policy proposal only when the finding improves
   conflict visibility without authorizing runtime mutation.
10. Return a JSON object with exactly these keys:
    - `markdownEvolutionAnalysis`
    - `evolutionPrDraft`
    - `humanReviewRequired`
