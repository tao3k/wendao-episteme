# Johnny.Decimal Policy

Johnny.Decimal policy governs topological addressing.

The contract covers canonical addresses, collection boundaries, deterministic
path identity, and topology-preserving repair behavior. Synthesis or intent
signals may recommend review, but they must not silently rewrite identity.

Johnny.Decimal is a syntax scaffold, not a universal category dictionary. This
policy owns only the grammar and invariants:

- Canonical Johnny.Decimal coordinates use `AC.ID`, for example `15.52`.
- `A` anchors the area range, such as `10-19`.
- `AC` identifies the project-local category.
- `ID` is the item slot inside that category.
- Wendao path-first filenames may render a coordinate as
  `AC.ID_semantic_name.md`; the slug is a local filename aid, not part of the
  Johnny.Decimal coordinate.
- Standard-zero slots may be reserved for JDex, inbox, task, template, link,
  someday, and archive functions.
- This repository does not define a custom property syntax for storing IDs.
- Runtime validation requires a parser-owned Johnny.Decimal metadata surface
  before it can emit syntax-derived findings.
- Existing category meaning is immutable unless a reviewed topology manifest
  change explicitly supersedes it.

Project-specific meaning belongs in the consumer repository's `topology.toml`.
LLM agents may propose changes to that manifest through a reviewable sync flow,
but runtime audit and fix commands must treat the committed manifest as
read-only law.

## Theory Boundary

Johnny.Decimal gives Wendao a topological coordinate system. The coordinate is
stable identity, not an intent label, lifecycle state, or prose summary. Other
frameworks may recommend reclassification, synthesis, or relation repair, but
they must not silently rewrite the coordinate.

Category semantics are project-local. `15` may mean travel in one knowledge
base and something else in another. `wendao-episteme` therefore owns the shape
and immutability law, while the consumer repository owns the category catalog.

## Source Grounding

This policy is grounded in the official Johnny.Decimal public reference,
especially:

- [A system to organise your life](https://johnnydecimal.com/)
- [11.02 Areas and categories](https://johnnydecimal.com/10-19-concepts/11-core/11.02-areas-and-categories/)
- [11.03 IDs](https://johnnydecimal.com/10-19-concepts/11-core/11.03-ids/)
- [11.05 The JDex](https://johnnydecimal.com/10-19-concepts/11-core/11.05-the-index/)
- [11.06 Saving files](https://johnnydecimal.com/10-19-concepts/11-core/11.06-saving-files/)
- [12.03 The standard zeros](https://johnnydecimal.com/10-19-concepts/12-advanced/12.03-the-standard-zeros/)
- [12.05 AC.ID notation](https://johnnydecimal.com/10-19-concepts/12-advanced/12.05-acid-notation/)
- [13.21 Expand an area](https://johnnydecimal.com/10-19-concepts/13-system-expansion/13.21-expand-an-area/)

Only mechanically observable path and topology invariants become deterministic
diagnostics. Category meaning, category breadth, standard-zero adoption,
expanded-area schemes, and JDex content remain project-local review evidence
unless the consumer repository supplies a governed topology manifest.

## Runtime Boundary

This policy intentionally stays inert until Wendao exposes a governed
Johnny.Decimal metadata surface. A downstream engine may map its own parser
surface into the query columns, but this repository must not hard-code a
temporary property syntax or physical parser column as universal law.

The safe evolution path is:

1. keep this policy as the theory contract;
2. add parser-owned metadata extraction in the Wendao parser/runtime boundary;
3. expose a stable logical view for Johnny.Decimal IDs;
4. activate syntax-derived validation only after that view is governed.

## Authoring Template Flow

The first authoring flow is path-first. Before creating a document, an LLM
should request a deterministic Johnny.Decimal template from Wendao. That
template gives the model the project topology, occupied coordinates, and the
diagnostic vocabulary it must obey. The path may include a local filename slug,
but the stable coordinate is the numeric `AC.ID` prefix.

The template phase is not adjudication. It is an authoring contract. The LLM may
propose a path such as `docs/10_wendao/10.03_audit_template_flow.md`, but the
proposal is valid only after `wendao lint markdown` and `wendao audit` verify
the created content.

The deterministic path-first diagnostics are:

- `invalid_coordinate_shape`
- `unknown_category`
- `duplicate_coordinate`
- `path_category_mismatch`
- `unassigned_note_advisory`
- `category_capacity_warning`

LLM output must remain a reviewable create, move, or rename plan. It must not
silently update `topology.toml`, invent a new category, or bypass the post-write
lint and audit checks.

## Assets

- `validation.sql` preserves the read-only policy-query shape for downstream
  engines. It intentionally emits no findings until a governed Johnny.Decimal
  metadata surface exists.
- `diagnostic.toml` maps validation rows to Project Sentinel XML diagnostics.
- `authoring_template.toml` defines the path-first creation contract for
  `wendao audit --template johnny-decimal`.
- `../../prompts/anchor_v3_fixers/fix_jd_id.txt` constrains Project AnchoR v3
  repair payload generation.
- `../../sources/johnny_decimal/evolution.skill.md` defines the skillsc/BPMN
  source evolution flow for reference and practice review.
