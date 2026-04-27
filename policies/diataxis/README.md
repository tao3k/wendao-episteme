# Diátaxis Policy

Diátaxis policy governs document-kind classification.

The contract maps documents to tutorials, how-to guides, explanations, and
reference material. A mismatch should normally produce a document-kind
diagnostic or metadata repair proposal instead of relocating the canonical node
identity.

Diátaxis is a closed ontology. The only accepted common frontmatter `kind`
values for ordinary documentation documents are:

- `tutorial`
- `how-to`
- `explanation`
- `reference`

Unlike Johnny.Decimal category meaning, these values are universal policy
surface in `wendao-episteme`, not project-local manifest entries. The portable
metadata carrier is the common leading-frontmatter `kind` field, which belongs
to the common frontmatter contract for every Markdown file.

`SKILL.md` files and other non-document contract files may use their own
parser-owned `kind` values. Diátaxis does not classify those files unless a
consumer first maps them into ordinary documentation records.

## Source Grounding

This policy is grounded in the official Diátaxis reference, especially:

- [Diátaxis](https://diataxis.fr/)
- [Tutorials](https://diataxis.fr/tutorials/)
- [How-to guides](https://diataxis.fr/how-to-guides/)
- [Reference](https://diataxis.fr/reference/)
- [Explanation](https://diataxis.fr/explanation/)
- [Applying Diátaxis](https://diataxis.fr/application/)

The source-grounded deterministic contract is the four-kind ontology:
tutorials are learning-oriented, how-to guides are goal-oriented, reference is
information-oriented, and explanation is understanding-oriented. Prose-quality
judgment, ideal document structure, and mixed-purpose refactoring remain
review evidence rather than automatic rewrite authority.

## Mode Boundaries

- `tutorial` teaches a learner through a guided sequence.
- `how-to` helps an already-oriented reader complete a concrete task.
- `explanation` develops conceptual understanding, trade-offs, or causality.
- `reference` records stable facts for lookup.

Body prose is not a metadata carrier. Policy SQL only reads the first YAML
frontmatter block so examples, quoted text, or repair instructions in the body
cannot accidentally classify a document.

## Compact Diagnostics

- `invalid_document_kind`: replace the existing value with one closed
  ontology value without changing body prose.
- `diataxis_path_conflict`: review the project-local path rule conflict; do
  not move the document automatically.

## Assets

- `validation.sql` contains read-only checks for unknown Diátaxis document-kind
  metadata. Missing common frontmatter fields are enforced by the Rust Markdown
  linter before policy audit. The SQL excludes `SKILL.md` by file path because
  skills are parser-owned contract files, not ordinary documentation records.
- `path_validation.sql` contains optional read-only checks for project-local
  path and document-kind conflicts. It requires `project_diataxis_path_rule`
  with `path_pattern` and `disallowed_kind` columns.
- `authoring_template.toml` renders the compact LLM-facing Diátaxis authoring
  contract through `wendao audit --template diataxis`.
- `diagnostic.toml` maps validation rows to Project Sentinel XML diagnostics.
- `path_diagnostic.toml` maps optional path conflict rows to Project Sentinel
  XML diagnostics.
- `../../prompts/anchor_v3_fixers/fix_diataxis.txt` constrains bounded
  document-kind metadata repair payload generation.
- `../../sources/diataxis/evolution.skill.md` defines the skillsc/BPMN source
  evolution flow for reference and practice review.
