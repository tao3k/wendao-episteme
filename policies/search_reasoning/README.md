# Search Reasoning Policy

Search Reasoning policy governs embedded query robustness.

The policy treats search statements as reasoning surfaces. Queries embedded in
Markdown should prefer stable semantic handles such as ids, tags, or intent
metadata over brittle exact path equality.

`validation.sql` is read-only policy logic over Wendao logical views. It scans
Markdown code fences for local SQL, DuckDB, and GraphQL query snippets whose
nearby lines hard-code `path` or `file_path` equality, including simple table
aliases.

Repair is query-scoped. The fixer may rewrite only the reported query range
when the diagnostic provides exact bytes and a stable replacement predicate. It
must not rewrite surrounding prose or change the query's intended result set
without human review.

## Source Grounding

- `wendao-search-as-reasoning-research` grounds repository exploration as a
  state-transition process over a `CodeGraph`.
- The source note grounds hierarchical structural UIDs such as
  `path/to/file::class::method`.
- Graph-distance pruning and priority-queue scheduling remain runtime planning
  signals. The deterministic policy focuses on authored query surfaces where
  brittle exact paths or unstructured symbol references are directly visible.
