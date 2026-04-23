---
name: structural-proprioception-source-evolution
description: Review structural proprioception sources and draft a graph-health policy evolution report
---

# Structural Proprioception Source Evolution

Review one configured structural proprioception source from `sources.toml`.

Use local research and practice sources to compare Wendao's graph-health policy
against observable cycle, depth, and topology-awareness requirements. Do not
edit files. Return evidence and a reviewable proposal only.

## Steps

1. Read the selected source entry from `sources.toml`.
2. Fetch the source overview.
   - For `local_doc` sources, read the configured repository-relative path.
   - For `website` sources, read the configured entrypoints under `url`.
3. Read the current policy from `policies/proprioception/validation.sql`.
4. Extract graph-health signals:
   - cycle-detection depth;
   - Sentinel v2 symbol-drift detection semantics;
   - topology compression or hierarchy requirements;
   - whether detected loops require hard errors or advisory review;
   - relation-edge softening and observation metadata boundaries.
5. Compare the source signals with Wendao's current cycle policy.
6. If the source does not provide enough evidence, return an empty proposal and
   set `humanReviewRequired` to `false`.
7. If there are findings, write a concise evolution analysis with evidence,
   benefits, risks, and compatibility with bounded relation repair.
8. Draft the smallest reviewable policy proposal only when the finding is
   general, testable, and compatible with preserving node identity.
9. Return a JSON object with exactly these keys:
   - `markdownEvolutionAnalysis`
   - `evolutionPrDraft`
   - `humanReviewRequired`
