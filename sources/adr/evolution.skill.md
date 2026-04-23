---
name: adr-source-evolution
description: Review ADR sources and draft a decision-contract policy evolution report
---

# ADR Source Evolution

Review one configured ADR source from `sources.toml`.

Use canonical sources to check whether Wendao policy has drifted from accepted
ADR lifecycle and structure guidance. Use practice sources to identify
decision-log patterns worth reviewing. Do not edit files. Return evidence and a
reviewable proposal only.

## Steps

1. Read the selected source entry from `sources.toml`.
2. Fetch the source overview.
   - For `website` sources, read the configured entrypoints under `url`.
   - For `github_repo` sources, inspect the repository overview, template
     examples, and decision-log conventions.
3. Read the current ADR policy from `policies/adr/validation.sql`.
4. Extract source-level decision-contract signals:
   - lifecycle status names;
   - supersession conventions;
   - required and recommended sections;
   - treatment of decision consequences and alternatives.
5. Compare the source signals with Wendao's current ADR policy.
6. If there are no findings, return an empty proposal and set
   `humanReviewRequired` to `false`.
7. If there are findings, write a concise evolution analysis with evidence,
   benefits, risks, and compatibility with immutable decision contracts.
8. Draft the smallest reviewable policy proposal only when the finding is
   general, testable, and compatible with preserving recorded decisions.
   External template fields may become recommended checks first; do not make
   them hard requirements without explicit human review.
9. Return a JSON object with exactly these keys:
   - `markdownEvolutionAnalysis`
   - `evolutionPrDraft`
   - `humanReviewRequired`
