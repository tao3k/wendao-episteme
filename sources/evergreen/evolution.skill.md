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
   - For `website` sources, read every configured entrypoint under `url`.
   - For `github_repo` sources, inspect the repository overview and note
     structure.
3. Read the current Evergreen policy from `policies/evergreen/validation.sql`.
4. Extract source-level topology signals:
   - approximate link density;
   - isolated note examples;
   - typical note length;
   - relation placement conventions when visible;
   - whether relation blocks are missing, empty, or populated.
5. Split observations into two classes:
   - deterministic policy candidates that can be checked through Wendao
     logical views;
   - principle review signals that require human or LLM judgment.
6. Compare deterministic candidates with Wendao's current Evergreen thresholds.
   Treat concept orientation, title-as-API quality, associative ontology
   preference, and write-for-yourself practice as review evidence only.
7. If the source does not provide enough evidence, return an empty proposal and
   set `humanReviewRequired` to `false`.
8. If there are findings, write a concise evolution analysis with evidence,
   benefits, risks, and compatibility with bounded relation-block repair.
9. Draft the smallest reviewable policy proposal only when the finding is
   general, testable, and compatible with preserving author-owned prose.
10. Return a JSON object with exactly these keys:
   - `markdownEvolutionAnalysis`
   - `evolutionPrDraft`
   - `humanReviewRequired`
