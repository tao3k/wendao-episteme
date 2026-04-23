# Structural Proprioception Policy

Structural Proprioception policy governs graph-health self-awareness for Wendao
knowledge graphs.

The policy checks whether resolved reference edges form short circular
dependencies. It treats cycles as structural hazards because they can trap
navigation, retrieval, and repair flows inside self-reinforcing loops.

`validation.sql` is read-only policy logic over Wendao logical views. It derives
resolved edges by matching `reference_occurrence.name` against
`repo_content_chunk` titles and stable ids, then uses a bounded recursive walk
to detect cycles.

Repair is relation-scoped. The fixer may soften or remove only a reported
relation edge when the diagnostic includes exact bytes and a chosen cut edge.
It must not rewrite note prose or restructure the graph globally.
