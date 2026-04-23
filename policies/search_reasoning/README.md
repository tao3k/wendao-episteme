# Search Reasoning Policy

Search Reasoning policy governs embedded query robustness.

The policy treats search statements as reasoning surfaces. Queries embedded in
Markdown should prefer stable semantic handles such as ids, tags, or intent
metadata over brittle exact path equality.

`validation.sql` is read-only policy logic over Wendao logical views. It scans
Markdown code fences for local SQL, DuckDB, and GraphQL query snippets whose
nearby lines hard-code `path` or `file_path` equality.

Repair is query-scoped. The fixer may rewrite only the reported query range
when the diagnostic provides exact bytes and a stable replacement predicate. It
must not rewrite surrounding prose or change the query's intended result set
without human review.
