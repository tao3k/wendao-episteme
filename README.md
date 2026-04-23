# wendao-episteme

`wendao-episteme` is the epistemological foundation for Wendao. It defines the
theory-driven contracts that govern how knowledge objects are named, classified,
related, and revised across the Wendao ecosystem.

This repository is intentionally not an execution-engine package. It does not
own physical schemas, DDL, Rust validators, Julia analyzers, or generated lint
artifacts. Instead, it provides the portable contract layer and optional
read-only validation queries that downstream engines can execute against
Wendao-owned logical views. Source-evolution flows are expressed as `skill.md`
documents that consumers compile with `skillsc` into BPMN execution graphs.

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
- which stable Wendao SQL views and catalogs validation queries may read;
- which project-local semantic manifests consumers must provide;
- which source-evolution skills may be compiled into BPMN review flows.

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

## Johnny.Decimal Boundary

Johnny.Decimal is a syntax scaffold, not a universal entity dictionary.
`wendao-episteme` owns the stable syntax law: IDs must follow the
`XX.YY_semantic_name` topology and each category is bounded to `00` through
`99`.

Project-specific category meaning is not stored here. A consumer repository
must own its semantic map, usually as a project-local `topology.toml`. LLM
analysis may run only through a skillsc-compiled review flow that proposes a
diff to that local manifest. It must not mutate topology during `wendao audit`
or `wendao fix`.

Diátaxis has a different boundary. It is a closed ontology, so the four allowed
intents are part of this repository's policy contract.

## Source Evolution Skills

External reference analysis is not prompt engineering. The `sources/` tree
stores source registries plus one monolithic `evolution.skill.md` per
framework. Consumers compile that skill with `skillsc` into BPMN. The upstream
prototype proves the model: a large model compiles Markdown into a BPMN subset,
and each compiled `serviceTask` carries `skillsc:config` with a focused prompt,
tools, inputs, and outputs.

The prototype executor uses Node `bpmn-engine`; that is not the Wendao runtime
contract. The intended execution target is `qianji-bpmn-engine` with a host
bridge that dispatches `skillsc:config` service tasks. Until that adapter
exists, human review is represented as an output packet rather than a BPMN
`userTask` or `manualTask`.

The output is always reviewable evidence or a proposed diff. The skill flow must
not silently rewrite policy SQL, project topology manifests, or committed
knowledge graph identity.

## Repository Structure

```text
.
├── docs/
│   └── rfcs/           # Architecture and policy blueprints
├── policies/           # Portable framework policy contracts
├── prompts/            # AnchoR v3 repair-template surfaces
├── sources/            # Skillsc/BPMN source evolution flows
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
policies, bounded repair templates, and skill surfaces those tools consume.

Part of the Xiuxian Artisan Workshop.
