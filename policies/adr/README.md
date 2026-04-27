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

## Source Grounding

This policy is grounded in the public ADR reference surface, especially:

- [Architectural Decision Records](https://adr.github.io/)
- [ADR Templates](https://adr.github.io/adr-templates/)
- [MADR](https://adr.github.io/madr/)

The source-grounded deterministic contract is the decision record lifecycle:
ADR records capture a single decision and its rationale, record status, and
preserve consequences and trade-offs for later readers. Template-specific
sections such as decision drivers, considered options, decision makers, and
confirmation remain review evidence unless a consumer repository adopts them as
governed metadata.

Accepted lifecycle values are:

- `PROPOSED`
- `REJECTED`
- `ACCEPTED`
- `ACTIVE`
- `DEPRECATED`
- `SUPERSEDED`

`SUPERSEDED` may be represented by a normalized status plus a separate
`SUPERSEDED_BY` pointer, or by an inline MADR-style status such as
`superseded by ADR-0123`.

Repair is pointer-scoped. The ADR fixer may replace an expired ADR link with a
reported successor id, but it must not rewrite decision rationale or edit the
ADR record itself.
