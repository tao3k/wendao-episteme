# Structural Proprioception Policy

Structural Proprioception policy governs graph-health self-awareness for Wendao
knowledge graphs.

The policy checks whether resolved reference edges form short circular
dependencies. It treats cycles as structural hazards because they can trap
navigation, retrieval, and repair flows inside self-reinforcing loops.

`validation.sql` is read-only policy logic over Wendao logical views. It derives
resolved edges by matching `reference_occurrence.name` against
`repo_content_chunk` titles and stable ids, then uses a bounded recursive walk
to detect cycles. It also checks `metadata.proprioception.observe` or equivalent
parser-owned observation metadata against the current `local_symbol` surface.

Repair is relation-scoped. The fixer may soften or remove only a reported
relation edge when the diagnostic includes exact bytes and a chosen cut edge.
It must not rewrite note prose or restructure the graph globally.

## Source Grounding

- `wendao-structural-proprioception-research` grounds topology self-awareness
  through hierarchical document structure, local/global query analysis,
  `PageIndex`, and `LinkGraph`.
- `wendao-project-sentinel-v2` grounds symbol observation and
  `SemanticDriftSignal` generation from source changes.
- Cycle detection is a Wendao graph-health heuristic. It is deterministic
  because the resolved edge walk is available in logical views, but repair must
  remain edge-scoped and reviewable.
