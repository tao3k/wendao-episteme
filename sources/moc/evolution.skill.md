---
name: moc-source-evolution
description: Review MOC sources and draft a route-hub policy evolution report
---

# MOC Source Evolution

Review one configured MOC source from `sources.toml`.

Use practice sources to compare Wendao's MOC policy against observable route
hub density, link count, and index-shape patterns. Do not edit files. Return
evidence and a reviewable proposal only.

## Steps

1. Read the selected source entry from `sources.toml`.
2. Fetch the source overview.
   - For `website` sources, read the configured entrypoints under `url`.
   - For `github_repo` sources, inspect the repository overview and note
     structure.
3. Read the current MOC policy from `policies/moc/validation.sql`.
4. Extract source-level route-hub signals:
   - approximate number of linked notes per hub;
   - whether hubs appear before or after cluster density grows;
   - whether hubs contain index-only links or authored summaries;
   - whether hub thresholds appear stable across examples.
5. Compare the source signals with Wendao's current density and out-degree
   thresholds.
6. If the source does not provide enough evidence, return an empty proposal and
   set `humanReviewRequired` to `false`.
7. If there are findings, write a concise evolution analysis with evidence,
   benefits, risks, and compatibility with bounded MOC index repair.
8. Draft the smallest reviewable policy proposal only when the finding is
   general, testable, and compatible with preserving note identity.
9. Return a JSON object with exactly these keys:
   - `markdownEvolutionAnalysis`
   - `evolutionPrDraft`
   - `humanReviewRequired`
