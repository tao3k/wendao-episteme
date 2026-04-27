# AnchoR v3 Fixer Prompts

This directory contains prompt surfaces for Project AnchoR v3 repair planning.

Prompts must produce bounded repair payloads, not whole-document rewrites. A
valid repair proposal targets an explicit `ByteRange`, preserves provenance,
and is safe for Blake3 compare-and-swap validation before filesystem mutation.

`fix_jd_id.txt` is the Johnny.Decimal anchor repair prompt. It must emit only a
SurgicalFix JSON payload and must preserve exact original bytes for CAS checks.

`fix_evergreen.txt` is the Evergreen relation-link repair prompt. It must emit
only a SurgicalFix JSON payload scoped to a relation block or explicitly
reported insertion range, and it must not rewrite author-owned prose.

`fix_diataxis.txt` is the Diátaxis document-kind metadata repair prompt. It
must emit only a SurgicalFix JSON payload scoped to common frontmatter
metadata, and it must choose only one closed-ontology value: `tutorial`,
`how-to`, `explanation`, or `reference`.

`fix_adr_reference.txt` is the ADR expired-reference repair prompt. It must emit
only a SurgicalFix JSON payload scoped to the reported decision pointer, and it
must not rewrite decision rationale, surrounding prose, or the ADR record
itself.

`fix_moc_empty.txt` is the MOC empty-hub repair prompt. It must emit only a
SurgicalFix JSON payload scoped to an existing MOC route-index range, and it
must not create new notes or narrative summaries.

`fix_folgezettel.txt` is the Folgezettel sequence repair prompt. It must emit
only a SurgicalFix JSON payload scoped to sequence metadata, and it must not
create parent notes or rewrite note prose.

`fix_ibis.txt` is the IBIS debate-scaffold repair prompt. It must emit only a
SurgicalFix JSON payload scoped to a placeholder position range, and it must not
decide issues or fabricate arguments.

`fix_proprioception_cycle.txt` is the Structural Proprioception cycle repair
prompt. It must emit only a SurgicalFix JSON payload scoped to one selected
relation edge, and it must not globally rewrite graph topology.

`fix_proprioception_observe.txt` is the Structural Proprioception observation
drift repair prompt. It must emit only a SurgicalFix JSON payload scoped to one
reported `OBSERVE` metadata range, and it must not rename code symbols.

`fix_search_reasoning.txt` is the Search Reasoning query repair prompt. It must
emit only a SurgicalFix JSON payload scoped to a brittle query predicate or
reported structural UID reference, and it must preserve query intent.

`fix_semantic_consistency.txt` is the Semantic Consistency status repair prompt.
It must emit only a SurgicalFix JSON payload scoped to status metadata, and it
must use only enacted lifecycle values.

`fix_conflict_decision_document_kind.txt` is the conflict-arbitration repair
prompt for ADR-vs-Diátaxis document-kind collisions. It must preserve the ADR
contract and edit only the reported common frontmatter kind range.

`fix_authorship_boundary.txt` is the Temporal Scaffolding replan prompt. It
must not produce a write into protected author prose. It may target only a
Sentinel-reported scaffold range with exact original bytes.
