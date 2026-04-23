---
name: search-reasoning-source-evolution
description: Review search reasoning sources and draft a query-robustness policy evolution report
---

# Search Reasoning Source Evolution

Review one configured search reasoning source from `sources.toml`.

Use local research and practice sources to compare Wendao's query-robustness
policy against state-transition search, graph-distance pruning, and semantic
predicate requirements. Do not edit files. Return evidence and a reviewable
proposal only.

## Steps

1. Read the selected source entry from `sources.toml`.
2. Fetch the source overview.
   - For `local_doc` sources, read the configured repository-relative path.
   - For `website` sources, read the configured entrypoints under `url`.
3. Read the current policy from `policies/search_reasoning/validation.sql`.
4. Extract query-robustness signals:
   - whether path equality is acceptable;
   - preferred stable predicates;
   - graph-distance or intent-aware filtering guidance;
   - query performance tradeoffs that require human review.
5. Compare the source signals with Wendao's current brittle-query policy.
6. If the source does not provide enough evidence, return an empty proposal and
   set `humanReviewRequired` to `false`.
7. If there are findings, write a concise evolution analysis with evidence,
   benefits, risks, and compatibility with stable semantic query contracts.
8. Draft the smallest reviewable policy proposal only when the finding is
   general, testable, and compatible with preserving query intent.
9. Return a JSON object with exactly these keys:
   - `markdownEvolutionAnalysis`
   - `evolutionPrDraft`
   - `humanReviewRequired`
