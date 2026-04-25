# Johnny.Decimal Policy

Johnny.Decimal policy governs topological addressing.

The contract covers canonical addresses, collection boundaries, deterministic
path identity, and topology-preserving repair behavior. Synthesis or intent
signals may recommend review, but they must not silently rewrite identity.

Johnny.Decimal is a syntax scaffold, not a universal category dictionary. This
policy owns only the grammar and invariants:

- IDs use `XX.YY_semantic_name`.
- `XX` identifies a project-local category.
- `YY` is bounded to `00` through `99` inside that category.
- Existing category meaning is immutable unless a reviewed topology manifest
  change explicitly supersedes it.

Project-specific meaning belongs in the consumer repository's `topology.toml`.
LLM agents may propose changes to that manifest through a reviewable sync flow,
but runtime audit and fix commands must treat the committed manifest as
read-only law.

## Assets

- `validation.sql` contains read-only checks for missing and malformed
  document-level `:ID:` metadata.
- `diagnostic.toml` maps validation rows to Project Sentinel XML diagnostics.
- `../../prompts/anchor_v3_fixers/fix_jd_id.txt` constrains Project AnchoR v3
  repair payload generation.
- `../../sources/johnny_decimal/evolution.skill.md` defines the skillsc/BPMN
  source evolution flow for reference and practice review.
