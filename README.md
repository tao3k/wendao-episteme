# wendao-episteme

`wendao-episteme` is the epistemological foundation for Wendao. It defines the
theory-driven contracts that govern how knowledge objects are named, classified,
related, and revised across the Wendao ecosystem.

This repository is intentionally not an execution-engine package. It does not
own physical schemas, DDL, Rust validators, Julia analyzers, or generated lint
artifacts. Instead, it provides the portable contract layer and optional
read-only validation queries that downstream engines can execute against
Wendao-owned logical views.

The current architecture blueprint is
[`docs/rfcs/wendao-episteme-cognitive-policy-blueprint-rfc.md`](docs/rfcs/wendao-episteme-cognitive-policy-blueprint-rfc.md).

## Core Epistemologies

- **Johnny.Decimal:** Topological addressing rules for stable knowledge
  coordinates, bounded collections, and deterministic path identity.
- **Diátaxis:** Intent classification rules for tutorials, how-to guides,
  explanations, and reference material.
- **ADR:** Decision-record contracts for status, supersession, and architectural
  consistency.
- **Evergreen Notes:** Synthesis rules for atomicity, durable links, and
  progressive refinement without creating knowledge silos.
- **Temporal Scaffolding:** Human-AI authorship boundaries for structural
  maintenance without whole-document rewrites.
- **Epistemic Sensemaking:** Consensus-oriented evolution for deprecated
  references, conflicting claims, and visible remediation proposals.

## Contract Model

The repository treats each epistemology as a policy module with explicit
authority, ownership, and conflict behavior. The current manifest is
[`episteme.toml`](episteme.toml).

The manifest records:

- which knowledge fields a framework owns;
- whether violations are errors, warnings, or advisory signals;
- how conflicts between frameworks should be resolved;
- which stable Wendao SQL views and catalogs validation queries may read.

This keeps the knowledge laws stable while allowing Wendao to choose the most
appropriate execution substrate for a given environment.

## Conflict Policy

`episteme.toml` should define priority and conflict behavior between theories.
The priority is not a simple execution order. It is an authority model for
deciding which invariant wins when two frameworks disagree.

For example, if an Evergreen synthesis link suggests relocating a note across a
Johnny.Decimal boundary, the canonical topological address remains stable until
an explicit move decision is recorded. The synthesis signal can become a repair
recommendation, but it must not silently rewrite identity.

## Repository Structure

```text
.
├── docs/
│   └── rfcs/           # Architecture and policy blueprints
├── policies/           # Portable framework policy contracts
├── prompts/            # AnchoR v3 repair-template surfaces
├── README.md
└── episteme.toml       # Manifest for framework authority and conflict policy
```

## Integration Boundary

Wendao loaders may consume this repository as a submodule and compile the
manifested contracts into runtime-specific validators. DuckDB, Apache Arrow,
Rust, Julia, and LLM-assisted repair loops are implementation choices of the
consumer, not source artifacts owned by this repository.

SQL files in this repository, when present, are policy-local validation queries
only. They must be read-only `SELECT` statements over request-scoped Wendao SQL
surfaces such as `wendao_sql_tables`, `wendao_sql_columns`,
`repo_content_chunk`, and `repo_entity`. They must not define tables, mutate
state, create schema, or encode Arrow/Rust type ownership.

Project Sentinel owns diagnostic rendering and XML emission. Project AnchoR v3
owns `ByteRange` repair planning, Blake3 compare-and-swap validation, overlap
detection, and final filesystem writes. `wendao-episteme` only defines the
policies and prompt surfaces those tools consume.

Part of the Xiuxian Artisan Workshop.
