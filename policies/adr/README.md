# ADR Policy

ADR policy governs decision-record integrity, lifecycle state, and dependency
contagion across the knowledge graph.

The contract covers status, supersession, active decision references, expired
reference detection, and semantic drift. Deprecated or superseded references
should surface as Project Sentinel disagreement diagnostics before any Project
AnchoR v3 repair is planned.

`validation.sql` is read-only policy logic. It inspects ADR nodes exposed by
Wendao logical views, reports references to expired decision contracts, and
checks that superseded records provide a `SUPERSEDED_BY` pointer.

Accepted lifecycle values are:

- `PROPOSED`
- `ACCEPTED`
- `ACTIVE`
- `DEPRECATED`
- `SUPERSEDED`

Repair is pointer-scoped. The ADR fixer may replace an expired ADR link with a
reported successor id, but it must not rewrite decision rationale or edit the
ADR record itself.
