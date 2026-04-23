# Diátaxis Policy

Diátaxis policy governs reader-intent classification.

The contract maps documents to tutorials, how-to guides, explanations, and
reference material. A mismatch should normally produce an intent diagnostic or
metadata repair proposal instead of relocating the canonical node identity.

Diátaxis is a closed ontology. The only accepted intent values are:

- `tutorial`
- `how-to`
- `explanation`
- `reference`

Unlike Johnny.Decimal category meaning, these values are universal policy
surface in `wendao-episteme`, not project-local manifest entries.

## Assets

- `validation.sql` contains read-only checks for missing or unknown Diátaxis
  intent metadata.
- `diagnostic.toml` maps validation rows to Project Sentinel XML diagnostics.
