# Wendao Episteme Ontology Index

This index is the allocation authority for the first Wendao ontology surface.
It follows the Johnny.Decimal category model described by the cognitive
ontology RFC and keeps category meaning explicit before runtime integration.

## Category Allocation

| Range | Layer | Purpose |
| --- | --- | --- |
| `00-09` | L0 Foundation | Irreducible ontology primitives shared by all domains. |
| `10-49` | L1 Domain | Domain ontologies that inherit from L0 without encoding tenant-specific facts. |
| `50-99` | L2 Application | Project or tenant application ontologies that inherit from L0 and L1. |

## Active Categories

| Category | Layer | Directory | Authority |
| --- | --- | --- | --- |
| `00` | L0 Foundation | `00_Core_Primitives/` | Core identity, relation, action, provenance, and lifespan primitives. |
| `10` | L1 Domain | `10_Software_Engineering/` | Software engineering entities and relations. |
| `20` | L1 Domain | `20_Commercial_Finance/` | Commercial, banking, lending, and transaction entities. |
| `30` | L1 Domain | `30_Healthcare/` | Healthcare delivery, clinical event, condition, and procedure entities. |
| `40` | L1 Domain | `40_Manufacturing/` | Production equipment, work order, part, and quality entities. |
| `41` | L1 Domain | `41_Education/` | Learning, course, enrollment, instructor, and department entities. |
| `50` | L2 Application | `50_Xiuxian_Internal/` | Xiuxian and Wendao internal application ontology entrypoint. |

## Files

- `manifest.toml`: source-level domain manifest, rule mount map, and extension contract declaration.
- `api_surface.toml`: source-level object, link, action, query, and interface contract for SDK-facing ontology APIs.
- `registry.json`: deterministic compiled ontology registry snapshot for downstream importer and SDK design.
- `examples/local_project/ontology.toml`: example project-local ontology extension using `extends`.
- `00_Core_Primitives/00.01_entity.rdf`: entity identity and immutable trace primitives.
- `00_Core_Primitives/00.02_relation.rdf`: topology and composition primitives.
- `00_Core_Primitives/00.03_action.rdf`: actor, action, and evidence provenance primitives.
- `00_Core_Primitives/00.04_lifespan.rdf`: temporal validity and supersession primitives.
- `10_Software_Engineering/ontology.rdf`: first L1 software engineering ontology.
- `10_Software_Engineering/policies/architectural_decision_making.md`: domain-local policy note for implementation-to-decision evidence.
- `10_Software_Engineering/rules/`: read-only SQL validation queries for dependency and decision-link contracts.
- `20_Commercial_Finance/ontology.rdf`: L1 commercial and financial services ontology.
- `20_Commercial_Finance/rules/`: read-only SQL validation queries for commercial finance extensions.
- `30_Healthcare/ontology.rdf`: L1 healthcare ontology.
- `30_Healthcare/rules/`: read-only SQL validation queries for healthcare extensions.
- `40_Manufacturing/ontology.rdf`: L1 manufacturing ontology.
- `40_Manufacturing/rules/`: read-only SQL validation queries for manufacturing extensions.
- `41_Education/ontology.rdf`: L1 education ontology.
- `41_Education/rules/`: read-only SQL validation queries for education extensions.
- `50_Xiuxian_Internal/ontology.rdf`: first L2 Xiuxian/Wendao application ontology entrypoint.

## Extension Contract

Project-local extension files use TOML. The `ontology.metadata.extends` field
selects exactly one domain identifier from `manifest.toml`, such as
`episteme://10_Software_Engineering`. Downstream runtime code may mount only
the rules declared for that selected domain.

## API Surface Contract

The `api_surface.toml` file declares the SDK-facing ontology API surface without
owning generated SDK code. It maps RDF classes to object types, RDF object
properties to link types, domain SQL files to action validation rules, and
cross-domain abstractions to interface types. The first vertical API coverage
targets healthcare and commercial finance.

## Registry Snapshot

The `registry.json` file is a deterministic compiled snapshot of the source
ontology contracts. It combines manifest metadata, RDF classes and object
properties, API surface declarations, validation rules, and policy references.
It is used as an importer and SDK design handoff artifact, not as runtime
storage.

## Boundary

This directory defines ontology source artifacts only. It does not own parser
implementations, DuckDB DDL, Rust type layout, SQL execution, BPMN orchestration,
or generated SDK code.
