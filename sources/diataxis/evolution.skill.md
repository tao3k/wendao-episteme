---
name: diataxis-source-evolution
description: Review Diátaxis guidance and draft an intent policy evolution report
---

# Diátaxis Source Evolution

Review one configured Diátaxis source from `sources.toml`.

Use official sources to check whether Wendao policy has drifted from canonical
Diátaxis guidance. Use practice sources to identify intent-classification
patterns worth reviewing. Do not edit files. Return evidence and a reviewable
proposal only.

## Steps

1. Read the selected source entry from `sources.toml`.
2. Fetch the source overview.
   - For `website` sources, read the configured entrypoints under `url`.
   - For `github_repo` sources, inspect the repository overview and
     documentation structure.
3. Read the current Diátaxis policy from `policies/diataxis/validation.sql`.
4. If the source has `authority = "canonical_reference"`, compare the official
   guidance with Wendao's four accepted intent values.
5. If the source is a practice source, inspect how it separates tutorials,
   how-to guides, explanation, and reference.
6. If there are no findings, return an empty proposal and set
   `humanReviewRequired` to `false`.
7. If there are findings, write a concise evolution analysis with evidence,
   benefits, risks, and compatibility with a closed intent ontology.
8. Draft the smallest reviewable policy proposal only when the finding is
   general, testable, and compatible with preserving document identity.
   Do not propose a fifth Diátaxis intent. For terms such as "concept" or
   "cookbook", propose aliasing, routing guidance, or manual review instead.
9. Return a JSON object with exactly these keys:
   - `markdownEvolutionAnalysis`
   - `evolutionPrDraft`
   - `humanReviewRequired`
