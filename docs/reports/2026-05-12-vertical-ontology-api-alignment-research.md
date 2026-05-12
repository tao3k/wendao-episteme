# Wendao Vertical Ontology API Alignment Research

Date: 2026-05-12

## Scope

This report compares two ontology reference projects and translates their useful API ideas into a Wendao-native vertical ontology direction. It is a research and landing plan artifact, not a runtime implementation.

Reference inputs:

- [Microsoft Ontology Playground](https://github.com/microsoft/Ontology-Playground)
- [Palantir Foundry Platform Python Ontologies docs](https://github.com/palantir/foundry-platform-python/tree/develop/docs/v2/Ontologies)

Local research snapshots:

- Microsoft Ontology Playground: `9ec1275`
- Palantir Foundry Platform Python: `341f3e3`

## Reference Findings

### Microsoft Ontology Playground

The Microsoft reference is most useful as a vertical ontology authoring and exchange model. Its relevant lessons are:

- Treat ontology source as a designable catalogue of entity types, properties, relationships, and cardinalities.
- Keep RDF/XML import and export as a first-class exchange path.
- Support multiple vertical domains from the same ontology grammar instead of hardcoding one industry model.
- Represent practical modeling gaps explicitly: static properties, time-series properties, data bindings, relationship bindings, keys, display names, and governance constraints.

For Wendao, this reinforces the current RDF source direction under `ontology/` and the need for a pragmatic compilation layer that can turn RDF/TOML/rules into an object model usable by SDKs and agents.

### Palantir Foundry Ontologies

The Palantir reference is most useful as an API and SDK vocabulary. The relevant API nouns are:

- `Ontology`: catalogue-level metadata and full metadata loading.
- `ObjectType`: object schema metadata.
- `OntologyObject`: object retrieval, listing, search, count, and aggregation.
- `LinkedObject`: relationship traversal from one object to linked objects.
- `Action`: validated mutation surface.
- `Query`: parameterized read surface.
- `OntologyInterface`: shared cross-object interface surface.
- `OntologyTransaction`: transaction and branch-oriented mutation context.

Its strongest design separation is that ontology metadata, object data access, link traversal, action application, query execution, and interface access are independent API families. Wendao should adopt this noun split even if the transport is not REST-compatible.

## Compatibility Position

Wendao should target semantic API compatibility, not wire compatibility.

That means:

- Keep the same resource vocabulary where it is useful: ontology, object type, object, linked object, action, query, interface, transaction.
- Keep similar method semantics: get/list/search/aggregate/count/apply/execute.
- Preserve Wendao's native source authority: RDF/XML, TOML manifests, rule SQL, and policy Markdown remain the canonical source files.
- Compile source files into an API registry rather than hand-authoring SDK-only schemas.
- Avoid copying generated SDK code or binding Wendao to a Palantir-specific route shape.

## Wendao Target Architecture

The vertical ontology system should be layered as follows:

1. Source layer

   The existing ontology tree remains the canonical human-editable source. RDF defines class and relationship semantics. TOML manifests define source package boundaries and pragmatic extension metadata. SQL rules define deterministic policy checks. Policy Markdown explains domain intent.

2. Compilation layer

   A compiler reads source files and emits a normalized ontology registry:

   - ontology metadata
   - object type registry
   - property registry
   - link type registry
   - action type registry
   - query type registry
   - interface registry
   - validation rule registry
   - provenance and source-pack metadata

3. Serving layer

   Wendao can expose the registry and data operations through its own service boundary. The API vocabulary should remain close to the Palantir noun model, while transport can be Arrow Flight, gRPC, REST, or local SDK calls depending on the runtime package.

4. SDK layer

   A generated or registry-backed SDK should expose ontology operations through stable families:

   - `client.ontologies.ontology`
   - `client.ontologies.object_type`
   - `client.ontologies.object`
   - `client.ontologies.linked_object`
   - `client.ontologies.action`
   - `client.ontologies.query`
   - `client.ontologies.interface`
   - `client.ontologies.transaction`

## Vertical Industry Recipe

Each vertical industry pack should define the same seven surfaces.

### Object Types

Object types are durable domain entities with primary keys, display names, properties, and RDF class identity.

Examples:

- Healthcare: `Patient`, `Provider`, `Encounter`, `Diagnosis`, `MedicationOrder`
- Commercial Finance: `Party`, `Account`, `Transaction`, `Instrument`, `RiskExposure`
- Manufacturing: `Part`, `WorkOrder`, `Machine`, `Batch`, `Inspection`
- Education: `Learner`, `Course`, `Enrollment`, `Assessment`, `Credential`

### Link Types

Link types are named relationships between object types. They should carry cardinality and traversal names.

Examples:

- Healthcare: `Encounter.patient`, `Encounter.provider`, `Diagnosis.encounter`
- Commercial Finance: `Transaction.account`, `Account.owner`, `RiskExposure.instrument`
- Manufacturing: `WorkOrder.part`, `Inspection.batch`, `Batch.machine`
- Education: `Enrollment.learner`, `Enrollment.course`, `Assessment.course`

### Actions

Actions are validated commands. They should not be modeled as free-form writes. Each action should declare input parameters, affected object types, validation rules, required evidence, and transaction behavior.

Examples:

- Healthcare: `recordEncounter`, `addDiagnosis`, `reconcileMedication`
- Commercial Finance: `postTransaction`, `openAccount`, `recordRiskExposure`
- Manufacturing: `startWorkOrder`, `completeInspection`, `quarantineBatch`
- Education: `enrollLearner`, `recordAssessment`, `issueCredential`

### Queries

Queries are named read models with explicit parameters. They are better for agent usage than arbitrary ad hoc filters because the query name carries intent.

Examples:

- Healthcare: `patientsByCondition`, `encountersForProvider`
- Commercial Finance: `transactionsByAccount`, `exposuresByCounterparty`
- Manufacturing: `openWorkOrdersByLine`, `inspectionFailuresByBatch`
- Education: `learnerProgressByCourse`, `credentialsByLearner`

### Interfaces

Interfaces define cross-vertical abstractions. They should be sparse and stable.

Recommended initial interfaces:

- `Party`: a person, organization, institution, or counterparty.
- `Asset`: a thing that can be owned, operated, traded, produced, or inspected.
- `Event`: a time-bounded domain occurrence.
- `Evidence`: a source-backed fact used by rules, actions, or decisions.
- `AccountableAction`: a command or decision that requires actor, time, evidence, and validation status.

### Rules

Rules should stay deterministic and auditable. They should validate structural invariants and action preconditions.

Examples:

- A healthcare encounter must link to a patient and provider.
- A finance transaction must post to an account.
- A manufacturing work order must identify execution context.
- An education enrollment must link a learner and course.

### Provenance

Every vertical pack should preserve source provenance:

- source pack name
- source file
- RDF class or property IRI
- rule file
- policy document
- generated registry version

## Proposed Source Contract

The next source contract should extend the existing ontology manifest with API-facing declarations. A compact TOML shape is enough for the first slice:

```toml
[[object_types]]
api_name = "Patient"
rdf_class = "wendao:healthcare/Patient"
primary_key = ["patientId"]
display_name_property = "name"

[[link_types]]
api_name = "Encounter.patient"
from_object_type = "Encounter"
to_object_type = "Patient"
cardinality = "many_to_one"

[[action_types]]
api_name = "recordEncounter"
affected_object_types = ["Encounter", "Patient", "Provider"]
requires_evidence = true
validation_rules = ["healthcare.encounter_must_link_patient_provider"]

[[query_types]]
api_name = "encountersForProvider"
parameters = ["providerId", "timeRange"]
returns = "Encounter"

[[interface_types]]
api_name = "Party"
implemented_by = ["Patient", "Provider", "AccountOwner", "Learner"]
```

This contract keeps source files readable while giving a compiler enough structure to generate registry metadata and SDK stubs.

## Proposed SDK Shape

The first SDK should be registry-backed and read-first. A Python-facing shape can intentionally mirror the Palantir API nouns:

```python
ontology = client.ontologies.ontology.get("wendao")
metadata = client.ontologies.ontology.load_metadata(
    "wendao",
    object_types=["Patient", "Encounter"],
    link_types=["Encounter.patient"],
    action_types=["recordEncounter"],
    query_types=["encountersForProvider"],
    interface_types=["Party"],
)

patients = client.ontologies.object.search(
    ontology="wendao",
    object_type="Patient",
    where={"condition": "diabetes"},
    select=["patientId", "name"],
)

encounters = client.ontologies.linked_object.list(
    ontology="wendao",
    object_type="Patient",
    primary_key="patient-001",
    link_type="Patient.encounters",
)

result = client.ontologies.action.apply(
    ontology="wendao",
    action_type="recordEncounter",
    parameters={"patientId": "patient-001", "providerId": "provider-001"},
)

report = client.ontologies.query.execute(
    ontology="wendao",
    query="encountersForProvider",
    parameters={"providerId": "provider-001"},
)
```

The first implementation should make `action.apply` return validation results without performing irreversible mutations. That matches the safer interpretation of action APIs and fits Wendao's current rule-first maturity.

## Recommended Implementation Slices

### Slice 1: API Surface Manifest

Add a source-level API surface contract for object types, link types, action types, query types, and interface types. Validate that all declared API names point to existing RDF classes, relationships, rules, or policies.

Deliverables:

- API surface TOML contract
- schema validation tests
- examples for healthcare and commercial finance

### Slice 2: Ontology Registry Compiler

Compile RDF, manifests, SQL rules, and policy references into a normalized JSON or Arrow-friendly registry.

Deliverables:

- registry builder
- deterministic registry snapshot test
- provenance fields for every compiled object, link, action, query, and interface

### Slice 3: Read-First SDK Prototype

Expose the registry through a Python package or module that uses Palantir-like nouns while remaining Wendao-native.

Deliverables:

- `ontology.get`
- `ontology.load_metadata`
- `object_type.get/list`
- `object.search/list/count`
- `linked_object.list`
- `query.execute` as a registry-backed stub

### Slice 4: Action Validation Prototype

Add `action.apply` as a validation-only operation. It should return structured rule results and proposed object/link changes, not write state yet.

Deliverables:

- action input validation
- rule execution summary
- proposed transaction result object
- no irreversible mutation

### Slice 5: Vertical Pack Generator

Add a small generator that creates a new vertical pack skeleton with RDF, API surface TOML, rule folder, policy folder, and tests.

Deliverables:

- generator command or script
- generated healthcare and commercial finance parity fixtures
- documentation for adding a new vertical pack

## Decision

Wendao should build vertical ontologies from source-controlled RDF and policy files, then compile them into an API registry whose public vocabulary follows Palantir-style Ontologies nouns. Microsoft Ontology Playground is the better reference for vertical authoring and RDF exchange. Palantir Foundry is the better reference for SDK ergonomics and API resource boundaries.

The immediate next implementation slice should be the API surface manifest and validation tests. That gives healthcare and commercial finance a clear path from RDF ontology packs to SDK-facing object/action/query/interface metadata without forcing a service implementation prematurely.
