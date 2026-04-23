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

`fix_diataxis.txt` is the Diátaxis intent metadata repair prompt. It must emit
only a SurgicalFix JSON payload scoped to metadata, and it must choose only one
closed-ontology value: `tutorial`, `how-to`, `explanation`, or `reference`.

`fix_adr_reference.txt` is the ADR expired-reference repair prompt. It must emit
only a SurgicalFix JSON payload scoped to the reported decision pointer, and it
must not rewrite decision rationale, surrounding prose, or the ADR record
itself.
