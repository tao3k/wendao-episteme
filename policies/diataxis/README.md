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
- `path_validation.sql` contains optional read-only checks for project-local
  path and intent conflicts. It requires `project_diataxis_path_rule`.
- `diagnostic.toml` maps validation rows to Project Sentinel XML diagnostics.
- `path_diagnostic.toml` maps optional path conflict rows to Project Sentinel
  XML diagnostics.
- `../../prompts/anchor_v3_fixers/fix_diataxis.txt` constrains bounded intent
  metadata repair payload generation.
- `../../sources/diataxis/evolution.skill.md` defines the skillsc/BPMN source
  evolution flow for reference and practice review.
