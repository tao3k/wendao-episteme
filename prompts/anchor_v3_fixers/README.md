# AnchoR v3 Fixer Prompts

This directory contains prompt surfaces for Project AnchoR v3 repair planning.

Prompts must produce bounded repair payloads, not whole-document rewrites. A
valid repair proposal targets an explicit `ByteRange`, preserves provenance,
and is safe for Blake3 compare-and-swap validation before filesystem mutation.

`fix_jd_id.txt` is the Johnny.Decimal anchor repair prompt. It must emit only a
SurgicalFix JSON payload and must preserve exact original bytes for CAS checks.
