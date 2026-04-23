---
name: ibis-source-evolution
description: Review IBIS sources and draft an argumentation policy evolution report
---

# IBIS Source Evolution

Review one configured IBIS source from `sources.toml`.

Use canonical and secondary sources to compare Wendao's IBIS policy against
issue, position, and argument graph conventions. Do not edit files. Return
evidence and a reviewable proposal only.

## Steps

1. Read the selected source entry from `sources.toml`.
2. Fetch the source overview.
   - For `website` sources, read the configured entrypoints under `url`.
   - For `paper` sources, extract the visible abstract and structural model.
3. Read the current IBIS policy from `policies/ibis/validation.sql`.
4. Extract source-level argumentation signals:
   - accepted IBIS node types;
   - required edge types between issues, positions, and arguments;
   - whether unresolved issues are allowed as temporary scaffolds;
   - whether placeholder positions are marked as human-review work.
5. Compare the source signals with Wendao's current unresolved-issue checks.
6. If the source does not provide enough evidence, return an empty proposal and
   set `humanReviewRequired` to `false`.
7. If there are findings, write a concise evolution analysis with evidence,
   benefits, risks, and compatibility with non-authoritative debate scaffolds.
8. Draft the smallest reviewable policy proposal only when the finding is
   general, testable, and compatible with preserving human adjudication.
9. Return a JSON object with exactly these keys:
   - `markdownEvolutionAnalysis`
   - `evolutionPrDraft`
   - `humanReviewRequired`
