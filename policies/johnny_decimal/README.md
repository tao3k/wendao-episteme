# Johnny.Decimal Policy

Johnny.Decimal policy governs topological addressing.

The contract covers canonical addresses, collection boundaries, deterministic
path identity, and topology-preserving repair behavior. Synthesis or intent
signals may recommend review, but they must not silently rewrite identity.

## Assets

- `validation.sql` contains read-only checks for missing and malformed
  `:ID:` property drawers.
- `diagnostic.toml` maps validation rows to Project Sentinel XML diagnostics.
- `../../prompts/anchor_v3_fixers/fix_jd_id.txt` constrains Project AnchoR v3
  repair payload generation.
