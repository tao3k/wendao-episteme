# Wendao Ontology RDF Foundation Implementation Report

## Scope

This slice implements the first physical RDF ontology surface under
`ontology/`. It follows the cognitive ontology RFC and creates the minimum
source artifacts needed before any parser, SQL execution, or SDK generation
work begins.

The slice was then extended with a research pass over Microsoft Ontology
Playground. The added L1 verticals mirror the reference catalogue's healthcare,
finance, manufacturing, and education coverage while preserving Wendao's local
L0 inheritance model.

The pragmatic extensibility RFC is implemented as a source-level contract:
`ontology/manifest.toml` declares domains and their rule mounts, and
`ontology/examples/local_project/ontology.toml` demonstrates the user-facing
TOML extension shape. Runtime compilation and SQL execution remain deferred.

## RFC Coverage

- `2026-05-10-wendao-cognitive-ontology-and-deduction-loop-rfc.md`: creates
  the `ontology/` directory and Johnny.Decimal category allocation surface.
- `2026-05-11-wendao-l0-foundation-ontology-four-pillars-rfc.md`: materializes
  L0 entity, topology, action/provenance, and lifespan primitives as RDF files.
- `2026-05-11-wendao-pragmatic-ontology-extensibility-and-sql-validation-rfc.md`:
  adds a domain-local read-only SQL validation example under the L1 software
  engineering ontology.
- `2026-05-11-wendao-ontology-sdk-generation-rfc.md`: records the RDF source
  boundary that a future OSDK generator can consume, but does not implement
  generation.

## Physical Layout

```text
ontology/
├── Index.md
├── manifest.toml
├── examples/
│   └── local_project/
│       └── ontology.toml
├── 00_Core_Primitives/
│   ├── 00.01_entity.rdf
│   ├── 00.02_relation.rdf
│   ├── 00.03_action.rdf
│   └── 00.04_lifespan.rdf
├── 10_Software_Engineering/
│   ├── ontology.rdf
│   ├── policies/
│   │   └── architectural_decision_making.md
│   └── rules/
│       ├── 01_architecture_dependency_dag.sql
│       └── 02_implementation_must_link_decision.sql
├── 20_Commercial_Finance/
│   ├── ontology.rdf
│   └── rules/
│       └── 01_transaction_must_post_to_account.sql
├── 30_Healthcare/
│   ├── ontology.rdf
│   └── rules/
│       └── 01_encounter_must_link_patient_provider.sql
├── 40_Manufacturing/
│   ├── ontology.rdf
│   └── rules/
│       └── 01_work_order_must_have_execution_context.sql
├── 41_Education/
│   ├── ontology.rdf
│   └── rules/
│       └── 01_enrollment_must_link_learner_course.sql
└── 50_Xiuxian_Internal/
    ├── ontology.rdf
    └── README.md
```

## L0 Foundation Mapping

The first L0 surface maps the four RFC pillars into RDF primitives:

- Existence: `BaseEntity`, `id`, `createdAt`.
- Topology: `dependsOn`, `partOf`.
- Action and provenance: `Actor`, `Action`, `Evidence`, `performs`,
  `modifies`, `creates`, `basedOn`.
- Spacetime and mutability: `Lifespan`, `validFrom`, `validTo`,
  `hasLifespan`, `supersedes`.

## L1 and L2 Initial Mapping

The L1 software engineering ontology defines only the minimal domain classes
needed for later implementation work:

- `SoftwareComponent`
- `DecisionRecord`
- `ImplementationArtifact`
- `implementsDecision`
- `ownsArtifact`

Four additional L1 vertical ontologies are included as first-pass domain
entrypoints:

- Commercial and finance: `Customer`, `FinancialAccount`, `Transaction`,
  `Loan`, `Collateral`, `ownsAccount`, `postsTransaction`, `securedBy`.
- Healthcare: `Patient`, `CareProvider`, `Encounter`, `MedicalCondition`,
  `ClinicalProcedure`, `hasEncounter`, `diagnosedWith`, `performedBy`.
- Manufacturing: `Machine`, `Sensor`, `WorkOrder`, `Part`,
  `QualityInspection`, `monitoredBy`, `executesWorkOrder`, `consumesPart`.
- Education: `Learner`, `Instructor`, `Course`, `Department`, `Enrollment`,
  `enrollsIn`, `forCourse`, `teaches`, `offeredBy`.

The L2 Xiuxian internal ontology defines only application entrypoint classes:

- `WendaoSemanticSurface`
- `EpistemePolicyModule`

## Validation Surface

The SQL file under `10_Software_Engineering/rules/` is a read-only policy
artifact. It assumes a downstream logical view named `ontology_relation` and
reports dependency cycles through a recursive query. It does not create,
alter, insert, update, delete, attach, or copy database state.

The pragmatic extensibility layer adds a manifest-driven mount contract:

- `ontology/manifest.toml` declares domain ids, RDF files, policies, and SQL
  rule files.
- `ontology/api_surface.toml` declares the SDK-facing object, link, action,
  query, and interface surface for the first healthcare and commercial finance
  vertical packs.
- `ontology/examples/local_project/ontology.toml` selects
  `episteme://10_Software_Engineering` through `ontology.metadata.extends`.
- Contract tests prove that the selected extension target is known and that the
  selected domain's rules live under its domain-local `rules/` directory.
- Contract tests also prove that the API surface links object types to RDF
  classes, link types to RDF object properties, actions to declared SQL rules,
  queries to object types, and interfaces to implemented object types.
- SQL remains source-only and read-only in this slice.

## Explicit Non-Goals

This slice does not implement:

- RDF parsing or RDF validation in Rust.
- TOML ontology extension compilation.
- DuckDB or DataFusion execution of ontology rules.
- BPMN deduction-loop orchestration.
- OSDK generation.
- Runtime schema ownership inside `wendao-episteme`.
- Direct vendoring of third-party RDF catalogue files into the canonical
  ontology source tree.

## Follow-Up Slices

1. Add a runtime importer design that compiles `ontology.toml` into internal
   triples without moving schema ownership into `wendao-episteme`.
2. Add a read-only RDF syntax validation command or test harness for
   `wendao-episteme`.
3. Add request-scoped ontology logical views for downstream SQL execution.
4. Execute one selected domain rule against a fixture relation table before
   enabling agent self-healing payloads.
