---
name: semantic-consistency-source-evolution
description: Review semantic consistency sources and draft a protocol-alignment policy evolution report
---

# Semantic Consistency Source Evolution

Review one configured semantic consistency source from `sources.toml`.

Use local research and practice sources to compare Wendao's status vocabulary
and protocol-alignment policy against deterministic harness and stale-read
requirements. Do not edit files. Return evidence and a reviewable proposal
only.

## Steps

1. Read the selected source entry from `sources.toml`.
2. Fetch the source overview.
   - For `local_doc` sources, read the configured repository-relative path.
   - For `website` sources, read the configured entrypoints under `url`.
3. Read the current policy from `policies/semantic_consistency/validation.sql`.
4. Extract protocol-alignment signals:
   - accepted lifecycle states;
   - stale-read or content-hash guard requirements;
   - Sentinel v2 stable-file analysis requirements;
   - status aliases that require human enactment;
   - cross-runtime terminology drift risks.
5. Compare the source signals with Wendao's current status vocabulary.
6. If the source does not provide enough evidence, return an empty proposal and
   set `humanReviewRequired` to `false`.
7. If there are findings, write a concise evolution analysis with evidence,
   benefits, risks, and compatibility with governed status metadata.
8. Draft the smallest reviewable policy proposal only when the finding is
   general, testable, and compatible with preserving authority boundaries.
9. Return a JSON object with exactly these keys:
   - `markdownEvolutionAnalysis`
   - `evolutionPrDraft`
   - `humanReviewRequired`
