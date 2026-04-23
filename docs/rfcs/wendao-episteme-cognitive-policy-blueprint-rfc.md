# RFC: Wendao-Episteme Cognitive Policy Blueprint

Status: Draft

## Objective

`wendao-episteme` is the policy and contract repository for Wendao knowledge
governance. It separates domain policy from parser substrate and remediation
engines.

The repository exists to define what a healthy knowledge graph means. It does
not define how Markdown is parsed, how diagnostics are rendered, or how files
are written back to disk.

The primary objectives are:

- decouple cognitive policy from `xiuxian-wendao-parsers`;
- provide machine-readable audit contracts for Project Sentinel;
- provide repair prompt surfaces for Project AnchoR v3;
- preserve human authorship by limiting automated repair to explicit byte
  ranges;
- prevent semantic rot, knowledge silos, and unaudited decision drift.

## Boundary Decision

`wendao-episteme` owns domain policy. It does not own parser internals, physical
schemas, DDL, Rust validators, Julia analyzers, XML renderers, or filesystem
write engines.

The repository may contain read-only validation queries. Those queries are
policy expressions, not schema definitions. They must run against stable Wendao
logical views and catalog tables assembled by the request-scoped SQL surface.

Consumer systems may compile the policies in this repository into DataFusion or
DuckDB queries, graph traversals, Rust checks, Julia analysis jobs, or
LLM-assisted repair plans. Those compiled artifacts are implementation details
of the consumer.

This keeps the parser substrate, policy layer, audit tooling, and remediation
tooling independently evolvable.

## Theoretical Framework

### Johnny.Decimal

Johnny.Decimal defines topological addressing policy. It constrains canonical
addresses, collection boundaries, and the deterministic relationship between
logical identity and workspace structure.

It has high authority because identity and topology must not be rewritten by
advisory synthesis signals.

### Diátaxis

Diátaxis defines document intent policy. It maps knowledge nodes into tutorials,
how-to guides, explanations, and reference material.

It governs reader-task classification, not physical identity. A Diátaxis
mismatch should normally reclassify intent metadata or request curation rather
than relocate a node.

### Architecture Decision Records

ADR policy governs decision contracts. It validates status, supersession,
scope, and references between active and deprecated decisions.

An active decision must not semantically drift without an auditable decision
record. Deprecated references should surface as consensus problems rather than
silent rewrites.

### Evergreen Notes

Evergreen Notes are modeled as graph constraints, not as a file format. The
policy guards against knowledge silos and semantic rot by checking connectivity,
atomicity, and durable relation surfaces.

Audit examples include isolated notes with zero in-degree or out-degree,
oversized monolith documents that violate atomicity, and stale relation blocks
that no longer match the surrounding graph.

Remediation should be advisory by default. For example, an isolated note may
receive suggested wiki-link insertions for a relation block, but the system must
not rewrite the author's core prose to force connectivity.

### Temporal Scaffolding

Temporal Scaffolding defines the human-AI authorship boundary. AI should carry
the structural maintenance burden while preserving the human author's reasoning
surface.

In Wendao, this maps to Project AnchoR v3. The model may produce precise
`ByteRange` payloads for missing identifiers, hash alignment, Diátaxis metadata,
or relation-block suggestions. It must not perform whole-document rewrites or
touch unrelated prose.

### Epistemic Sensemaking

Epistemic Sensemaking defines consensus-oriented evolution. An audit result is a
machine-level disagreement statement, not an automatic command to mutate the
graph.

When a deprecated ADR is still referenced by new code or documents, Sentinel
should report the disagreement with provenance and range information. LLM repair
logic may propose a contextual fix, but the final write path must preserve
authority, provenance, and conflict visibility.

## Sentinel Audit Contract

Project Sentinel consumes `wendao-episteme` policies and emits machine-readable
diagnostics.

A diagnostic should include:

- the policy id and framework id;
- severity and confidence;
- the affected source path;
- the exact `ByteRange` when a local range is known;
- provenance for the evidence that triggered the diagnostic;
- a remediation class such as `manual_review`, `metadata_patch`,
  `relation_block_insert`, or `decision_supersession`.

The XML protocol is owned by Sentinel. This repository may define semantic
requirements for the diagnostic payload, but it does not own the renderer.

## SQL Validation Contract

SQL in `wendao-episteme` is allowed only as read-only validation logic. It must
not create, alter, drop, insert, update, delete, merge, copy, attach, or mutate
anything.

Validation queries may inspect:

- `wendao_sql_tables`;
- `wendao_sql_columns`;
- stable logical views such as `repo_content_chunk` and `repo_entity`;
- other stable Wendao views explicitly exposed through the same catalog
  contract.

Validation queries must not define schemas. Type ownership belongs to
`xiuxian-wendao-parsers`, Rust structs, and Arrow `RecordBatch` layouts exposed
by the Wendao engine. A policy query may discover columns through
`wendao_sql_columns`, but it must not duplicate the physical schema in SQL.

The SQL execution surface is request-scoped. Project Sentinel and Wendao may
assemble temporary read surfaces for a specific audit, but `wendao-episteme`
must not ship DDL or persistent setup scripts that attempt to shape that
surface.

Policy-local validation queries may live beside the policy they enforce. For
example, Johnny.Decimal anchor checks are defined in
`policies/johnny_decimal/validation.sql`.

## AnchoR v3 Repair Contract

Project AnchoR v3 performs surgical remediation. It must operate on explicit
byte ranges and must use compare-and-swap checks before writing.

Required repair constraints:

- every payload targets a known `ByteRange`;
- payloads include the original byte content or an equivalent Blake3 guard;
- overlapping payloads must be rejected or merged by a deterministic planner;
- whole-document rewrites are outside the default contract;
- LLM output is never an authority source;
- final writes must preserve provenance and expose unresolved disagreements.

This makes AI useful for scaffolding work while preventing it from overwriting
human reasoning, mathematical derivations, code examples, or decision records
outside the declared range.

## Repository Structure

```text
wendao-episteme/
├── docs/
│   └── rfcs/
├── policies/
│   ├── adr/
│   ├── diataxis/
│   ├── evergreen/
│   └── johnny_decimal/
├── prompts/
│   └── anchor_v3_fixers/
├── README.md
└── episteme.toml
```

The `policies/` tree contains portable policy contracts. The `prompts/` tree
contains repair-template surfaces for bounded AnchoR v3 payload generation.

Policy directories may contain read-only `validation.sql` diagnostics. The
repository intentionally has no `schemas/` tree and no DDL source model.

## Consumer Boundary

`xiuxian-wendao` loads the submodule and schedules policy checks.

`xiuxian-wendao-parsers` provides parser substrate objects such as section and
block cores. It must not own episteme policy logic.

Project Sentinel owns diagnostic rendering and audit protocol execution.

Project AnchoR v3 owns byte-range planning, CAS validation, overlap detection,
and final filesystem mutation.

## Roadmap

1. Define the Diátaxis policy contract and Sentinel diagnostic mapping.
2. Define AnchoR v3 payload templates for missing identifier drawers.
3. Define Johnny.Decimal topology checks for address and path consistency.
4. Define Evergreen connectivity and atomicity audits.
5. Define ADR sensemaking checks for deprecated references and supersession
   drift.
6. Add read-only validation queries only after the target Wendao SQL view is
   visible through `wendao_sql_tables` and `wendao_sql_columns`.

## Johnny.Decimal Closed Loop

Johnny.Decimal anchor enforcement is a three-stage policy loop:

1. `policies/johnny_decimal/validation.sql` emits read-only diagnostics for
   missing `:ID:` property drawers and invalid `XX.YY_semantic_name` anchors.
2. Project Sentinel maps query rows to
   `Episteme_JohnnyDecimal_Violation` XML diagnostics with `ByteRange`
   coordinates and original bytes.
3. `prompts/anchor_v3_fixers/fix_jd_id.txt` constrains LLM repair output to a
   `SurgicalFix` JSON payload that Project AnchoR v3 can validate through
   Blake3 compare-and-swap and overlap checks before writing.

The LLM infers semantic routing. It does not execute writes, bypass CAS guards,
or rewrite the surrounding document.
