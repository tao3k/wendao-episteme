---
name: folgezettel-source-evolution
description: Review Folgezettel sources and draft a lineage policy evolution report
---

# Folgezettel Source Evolution

Review one configured Folgezettel source from `sources.toml`.

Use reference and practice sources to compare Wendao's lineage policy against
observable sequence-depth, parent-continuity, and readability patterns. Do not
edit files. Return evidence and a reviewable proposal only.

## Steps

1. Read the selected source entry from `sources.toml`.
2. Fetch the source overview.
   - For `website` sources, read the configured entrypoints under `url`.
   - For `github_repo` sources, inspect sequence metadata and note structure.
3. Read the current Folgezettel policy from
   `policies/folgezettel/validation.sql`.
4. Extract source-level lineage signals:
   - maximum visible sequence depth;
   - frequency of broken or ambiguous parent chains;
   - whether long chains are routed through MOCs or structure notes;
   - whether sequence identifiers are stable after note movement.
5. Compare the source signals with Wendao's current lineage checks.
6. If the source does not provide enough evidence, return an empty proposal and
   set `humanReviewRequired` to `false`.
7. If there are findings, write a concise evolution analysis with evidence,
   benefits, risks, and compatibility with preserving lineage continuity.
8. Draft the smallest reviewable policy proposal only when the finding is
   general, testable, and compatible with immutable note identity.
9. Return a JSON object with exactly these keys:
   - `markdownEvolutionAnalysis`
   - `evolutionPrDraft`
   - `humanReviewRequired`
