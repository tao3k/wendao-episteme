---
name: johnny-decimal-source-evolution
description: Review a Johnny.Decimal source and draft a policy evolution report
---

# Johnny.Decimal Source Evolution

Review one configured Johnny.Decimal source from `sources.toml`.

Use official sources to check whether Wendao policy has drifted from canonical
Johnny.Decimal guidance. Use practice sources to identify deliberate topology
patterns worth reviewing. Do not edit files. Return evidence and a reviewable
proposal only.

## Steps

1. Read the selected source entry from `sources.toml`.
2. Fetch the source overview.
   - For `website` sources, read the configured entrypoints under `url`.
   - For `github_repo` sources, inspect the repository overview and note
     structure.
3. Read the current Johnny.Decimal policy from
   `policies/johnny_decimal/validation.sql`.
4. If the source has `authority = "canonical_reference"`, compare the official
   guidance with the current Wendao policy and list any drift.
5. If the source is a practice source, inspect its topology conventions and
   separate accidental local mistakes from deliberate design choices.
6. If there are no findings, return an empty proposal and set
   `humanReviewRequired` to `false`.
7. If there are findings, write a concise evolution analysis with evidence,
   benefits, risks, and compatibility with stable Johnny.Decimal identity.
8. Draft the smallest reviewable policy proposal only when the finding is
   general, testable, and compatible with identity immutability.
9. Return a JSON object with exactly these keys:
   - `markdownEvolutionAnalysis`
   - `evolutionPrDraft`
   - `humanReviewRequired`
