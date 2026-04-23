---
name: evergreen-source-evolution
description: Review an Evergreen source and draft a graph policy evolution report
---

# Evergreen Source Evolution

Review one configured Evergreen source from `sources.toml`.

Use reference and practice sources to compare Wendao's Evergreen policy against
observable graph connectivity and note atomicity patterns. Do not edit files.
Return evidence and a reviewable proposal only.

## Steps

1. Read the selected source entry from `sources.toml`.
2. Fetch the source overview.
   - For `website` sources, read the configured entrypoints under `url`.
   - For `github_repo` sources, inspect the repository overview and note
     structure.
3. Read the current Evergreen policy from `policies/evergreen/validation.sql`.
4. Extract source-level topology signals:
   - approximate link density;
   - isolated note examples;
   - typical note length;
   - relation placement conventions when visible.
5. Compare the source signals with Wendao's current Evergreen thresholds.
6. If the source does not provide enough evidence, return an empty proposal and
   set `humanReviewRequired` to `false`.
7. If there are findings, write a concise evolution analysis with evidence,
   benefits, risks, and compatibility with bounded relation-block repair.
8. Draft the smallest reviewable policy proposal only when the finding is
   general, testable, and compatible with preserving author-owned prose.
9. Return a JSON object with exactly these keys:
   - `markdownEvolutionAnalysis`
   - `evolutionPrDraft`
   - `humanReviewRequired`
