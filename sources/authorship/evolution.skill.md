---
name: temporal-scaffolding-source-evolution
description: Review authorship-boundary sources and draft a governed policy proposal
---

# Temporal Scaffolding Source Evolution

Review one configured authorship-boundary source from `sources.toml`.

Use the fetched source material only to improve diagnostic provenance, repair
guard wording, and authoring-template contracts. Do not edit files. Return
evidence and a reviewable proposal only.

## Workflow

1. Read the selected source entry from `sources.toml`.
2. Read the fetched normalized source text.
3. Read `policies/authorship/validation.sql`, `diagnostic.toml`, and
   `authoring_template.toml`.
4. Extract only write-time guard evidence:
   - protected author-owned byte zones;
   - governed scaffold zones;
   - exact `ByteRange` and CAS requirements;
   - manual-review behavior when no safe scaffold range exists.
5. Compare the source signals with the current authorship-boundary policy.
6. Return a proposal with source evidence, affected surfaces, and whether the
   change is deterministic or review-only.

## Output

Return Markdown with:

- `Source`
- `Evidence`
- `Policy Gap`
- `Deterministic Diagnostic Candidate`
- `Review-Only Candidate`
- `Compatibility Notes`
