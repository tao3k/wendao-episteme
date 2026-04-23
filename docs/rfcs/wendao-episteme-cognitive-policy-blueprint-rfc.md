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
- provide bounded repair-template surfaces for Project AnchoR v3;
- provide skillsc/BPMN source evolution flows for reference and practice policy
  learning;
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

Empirical learning flows are different from repair prompts. They must be
authored as `skill.md` source files and compiled by `skillsc` into BPMN. The
current `skillsc` prototype compiles Markdown with a large model and emits a
bounded BPMN subset where executable work appears as `serviceTask` nodes with
`skillsc:config` extension elements.

The prototype's Node `bpmn-engine` executor is informative but not normative for
Wendao. The target executor is `qianji-bpmn-engine`. Wendao should preserve the
`skillsc:config` task contract while replacing the prototype runtime with a
Qianji host bridge.

This keeps the parser substrate, policy layer, audit tooling, and remediation
tooling independently evolvable.

## Theoretical Framework

### Johnny.Decimal

Johnny.Decimal defines topological addressing policy. It constrains canonical
addresses, collection boundaries, and the deterministic relationship between
logical identity and workspace structure.

It has high authority because identity and topology must not be rewritten by
advisory synthesis signals.

Johnny.Decimal is only the topology grammar. It is not a universal category
catalog. `wendao-episteme` owns syntax rules such as `XX.YY_semantic_name` and
the `00` through `99` entity range inside each category. The consuming
repository owns semantic category meaning through a project-local topology
manifest.

### Diátaxis

Diátaxis defines document intent policy. It maps knowledge nodes into tutorials,
how-to guides, explanations, and reference material.

It governs reader-task classification, not physical identity. A Diátaxis
mismatch should normally reclassify intent metadata or request curation rather
than relocate a node.

Unlike Johnny.Decimal semantics, Diátaxis is a closed ontology. The allowed
values are part of this repository's policy contract: `tutorial`, `how-to`,
`explanation`, and `reference`.

### Architecture Decision Records

ADR policy governs decision contracts. It validates status, supersession,
scope, and references between active and deprecated decisions.

An active decision must not semantically drift without an auditable decision
record. Deprecated references should surface as consensus problems rather than
silent rewrites.

The hard policy surface is the ADR lifecycle state machine and its dependency
contagion. A `SUPERSEDED` record must point to a successor contract, and new
material must not continue to reference `DEPRECATED` or `SUPERSEDED` contracts
without a visible diagnostic.

Automated repair is pointer-scoped. AnchoR v3 may replace a stale ADR link with
the successor id reported by Sentinel, but it must not rewrite the decision
rationale, change status history, or edit the ADR body outside an explicit
range.

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

### MOC

MOC policy governs route hubs for dense note clusters. It treats a Map of
Content as a graph-navigation surface, not as a subjective summary quality
score.

The policy checks for scopes whose note count exceeds the hub threshold without
an explicit MOC node and for MOC nodes whose outgoing references are too sparse
to function as route hubs.

Automated repair is index-scoped. AnchoR v3 may add a compact route index only
inside an explicit range in an existing MOC file. Missing MOC creation remains a
manual governance action.

### Folgezettel

Folgezettel policy governs lineage-sequence metadata for notes that opt into
causal extension chains. A child sequence must have an existing parent sequence,
and sequence ids must remain unique across the audited graph.

The policy does not replace Johnny.Decimal identity. Folgezettel records a
knowledge-growth path, while Johnny.Decimal remains the canonical topology.

Automated repair is metadata-scoped. AnchoR v3 may rewrite only the reported
sequence range when the diagnostic includes exact bytes and a reviewable
replacement candidate. It must not create parent notes or rewrite prose.

### IBIS

IBIS policy governs argumentation graph structure. It checks that issues have
position responses and that positions target known issues.

IBIS is not an adjudication engine. It surfaces unresolved discourse so humans
can close the loop or record a decision through ADR.

Automated repair is debate-scaffold scoped. AnchoR v3 may add a placeholder
position only inside an explicit range. It must not decide the issue, fabricate
arguments, or mark a resolution.

### Structural Proprioception

Structural Proprioception policy governs graph-health self-awareness. It checks
whether resolved reference edges form bounded circular dependencies that can
trap navigation, search, or repair flows.

The policy is intentionally based on stable SQL surfaces. Because
`reference_occurrence` exposes reference names rather than resolved target
paths, the validation query resolves targets by matching reference names against
known node titles and ids from `repo_content_chunk`.

Sentinel v2 extends the same boundary to source alignment. Documents may use
`OBSERVE` metadata to name code symbols they claim to describe. The
Proprioception policy compares those names with the `local_symbol` view and
reports semantic drift when a documented symbol disappears from the latest
symbol index.

Automated repair is relation- or metadata-scoped. AnchoR v3 may soften one
selected relation edge or update one reported observation pointer only when
Sentinel reports exact bytes and the selected target. It must not rewrite
author prose, rename code symbols, move nodes, or perform global graph surgery.

### Search as Reasoning

Search as Reasoning policy treats embedded queries as reasoning artifacts.
Hard-coded path equality is fragile because it couples retrieval behavior to a
physical file location rather than a stable semantic identity.

The policy scans Markdown code fences for SQL, DuckDB, and GraphQL snippets
that use exact `path` or `file_path` predicates. It reports those snippets as
query-fragility diagnostics.

The policy also checks code-symbol references that resolve through
`local_symbol`. A cross-file symbol reference should use a structural UID such
as `path/to/file::owner::symbol`, not a bare symbol name.

Automated repair is query- or reference-scoped. AnchoR v3 may replace a brittle
predicate with a stable id, topology, intent, or tag predicate only when the
diagnostic provides exact bytes and an unambiguous replacement. It may replace
a reported bare symbol with a structural UID. It must preserve query intent.

### Semantic Consistency

Semantic Consistency policy governs lifecycle vocabulary alignment across
documentation, audit, and repair surfaces. It keeps status values inside the
enacted vocabulary that Wendao tooling understands.

The policy checks status metadata against the enacted values `DRAFT`,
`PROPOSED`, `ACCEPTED`, `ACTIVE`, `HARDENING`, `HARDENED`, `DEPRECATED`, and
`SUPERSEDED`.

Agent-maintained notes may opt into stale-read detection. When a document
records `DEPENDS_ON_FILE` and `DEPENDS_ON_HASH`, the optional
`project_content_fingerprint` view lets Sentinel compare the recorded hash with
the live dependency hash.

Automated repair is metadata-scoped for status typos only. AnchoR v3 may
correct a misspelled status only when the replacement is unambiguous. Stale-read
diagnostics route to planner review; they are not authority for direct prose
mutation. New lifecycle values require source evolution review before becoming
valid protocol vocabulary.

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

### Conflict Arbitration Matrix

The conflict matrix in `episteme.toml` is the jurisprudence layer for
cross-framework disagreement. `authority_rank` chooses the governing invariant;
`[[conflicts]]` records the enacted precedent and resolution text.

`policies/conflicts/validation.sql` exposes a read-only Sentinel surface for
selected conflicts:

- `topology-vs-synthesis` keeps Johnny.Decimal identity stable when synthesis
  pressure crosses a topological boundary;
- `decision-contract-vs-intent` preserves ADR contract authority when reader
  intent metadata classifies a decision as tutorial or explanation material;
- `deprecated-decision-reference` routes stale ADR pointers through
  Sensemaking before mutation.

Conflict diagnostics are arbitration packets. They do not perform repair.
Only the ADR-vs-Diátaxis case has a bounded AnchoR prompt because its safe
resolution is local intent metadata reclassification.
The `sources/sensemaking` skill surface is the review flow for evolving these
precedents without runtime mutation.

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
- stable logical views such as `repo_content_chunk`, `repo_entity`, and
  `reference_occurrence`;
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

Validation queries may read project-local manifests only after Wendao exposes
them as request-scoped logical views. The manifest file itself belongs to the
consumer repository, not to `wendao-episteme`.

## AnchoR v3 Repair Contract

Project AnchoR v3 performs surgical remediation. It must operate on explicit
byte ranges and must use compare-and-swap checks before writing.

Required repair constraints:

- every payload targets a known `ByteRange`;
- payloads include the original byte content or an equivalent Blake3 guard;
- overlapping payloads must be rejected or merged by a deterministic planner;
- target ranges must remain inside parser-reported scaffold zones unless
  Sentinel reports another governed safe range;
- whole-document rewrites are outside the default contract;
- LLM output is never an authority source;
- final writes must preserve provenance and expose unresolved disagreements.

This makes AI useful for scaffolding work while preventing it from overwriting
human reasoning, mathematical derivations, code examples, or decision records
outside the declared range.

### Authorship Boundary Defense

Temporal Scaffolding becomes a physical write-time guard in Project AnchoR v3.
The parser substrate classifies byte ranges into protected author zones and
governed scaffold zones. Protected zones include paragraphs, lists, code
blocks, mathematical content, and decision rationale. Governed scaffold zones
include metadata drawers, relation blocks, footer blocks, and explicit
Sentinel-reported safe ranges.

AnchoR must reject any `SurgicalFix` whose target range is not fully contained
by one governed scaffold zone. The failure diagnostic is
`Episteme_AuthorshipBoundary_Violation` with conflict id
`authorship-vs-structural-repair`. The replan prompt may move the proposal into
a safe scaffold range only when Sentinel provides exact original bytes for that
range.

## Source Evolution Contract

Source learning is a scheduled review flow, not a runtime mutation path.
Each framework may define a `sources/<framework>/sources.toml` registry and one
monolithic `evolution.skill.md` file.

The registry selects external sources and scheduling metadata. The skill file
owns the source workflow. Consumers compile it with `skillsc` into BPMN before
execution.

The prototype supports a deliberately small BPMN subset: `startEvent`,
`endEvent`, `serviceTask`, `exclusiveGateway`, `parallelGateway`, boundary error
events, and `sequenceFlow`. Each `serviceTask` uses
`implementation="${environment.services.runAgent}"` and carries
`skillsc:prompt`, `skillsc:tools`, `skillsc:inputs`, and `skillsc:outputs`.

Until the Qianji adapter exists, source skills must not require BPMN `userTask`
or `manualTask`. Human review is represented as a review packet and
`humanReviewRequired` output variable. A later `qianji-bpmn-engine` integration
may map that review packet onto a typed host-blocking task without changing the
policy source.

For Johnny.Decimal, this means official references and external practice can
influence policy only through evidence and a reviewable `Evolution_PR_Draft`.
LLM analysis must not silently edit `policies/johnny_decimal/validation.sql`,
consumer `topology.toml`, or any committed category meaning.

Topology manifest sync is an on-demand review flow, not scheduled external
source learning. `sources/topology/evolution.skill.md` reads the consumer
topology manifest and workspace evidence, then emits an append-only
`Proposed_Topology_Diff`. It must reject renumbering, renaming, deleting, or
moving existing categories and anchor ids.

For ADR, external templates may influence recommended checks through evidence
and review. They must not become hard-required sections until a human accepts
the proposal and records the governance change.

For MOC, Folgezettel, and IBIS, external sources may influence thresholds and
recommended checks only through reviewable evidence packets. They must not
silently change route-hub thresholds, lineage depth policy, or argumentation
status semantics during audit or repair.

For Structural Proprioception, Search as Reasoning, and Semantic Consistency,
local research notes may inform policy evolution only through source skills.
They must not silently change cycle depth, query predicate policy, or status
vocabulary during audit or repair.

## Repository Structure

```text
wendao-episteme/
├── docs/
│   └── rfcs/
├── policies/
│   ├── adr/
│   ├── authorship/
│   ├── conflicts/
│   ├── diataxis/
│   ├── evergreen/
│   ├── folgezettel/
│   ├── ibis/
│   ├── johnny_decimal/
│   ├── moc/
│   ├── proprioception/
│   ├── search_reasoning/
│   └── semantic_consistency/
├── sources/
│   ├── adr/
│   │   ├── sources.toml
│   │   └── evolution.skill.md
│   ├── diataxis/
│   │   ├── sources.toml
│   │   └── evolution.skill.md
│   ├── evergreen/
│   │   ├── sources.toml
│   │   └── evolution.skill.md
│   ├── folgezettel/
│   │   ├── sources.toml
│   │   └── evolution.skill.md
│   ├── ibis/
│   │   ├── sources.toml
│   │   └── evolution.skill.md
│   ├── johnny_decimal/
│   │   ├── sources.toml
│   │   └── evolution.skill.md
│   ├── moc/
│   │   ├── sources.toml
│   │   └── evolution.skill.md
│   ├── proprioception/
│   │   ├── sources.toml
│   │   └── evolution.skill.md
│   ├── search_reasoning/
│   │   ├── sources.toml
│   │   └── evolution.skill.md
│   ├── semantic_consistency/
│   │   ├── sources.toml
│   │   └── evolution.skill.md
│   ├── sensemaking/
│   │   ├── sources.toml
│   │   └── evolution.skill.md
│   └── topology/
│       ├── sources.toml
│       └── evolution.skill.md
├── prompts/
│   └── anchor_v3_fixers/
├── README.md
└── episteme.toml
```

The `policies/` tree contains portable policy contracts. The `prompts/` tree
contains repair-template surfaces for bounded AnchoR v3 payload generation.
The `sources/` tree contains skillsc source files for reference and practice
evolution workflows. It must not contain static source `prompt.txt` flows.

Policy directories may contain read-only `validation.sql` diagnostics. The
repository intentionally has no `schemas/` tree and no DDL source model.

Consumer repositories may contain project-local topology manifests such as
`topology.toml`. Those manifests encode local category meaning. They are not
copied into `wendao-episteme`.

## Consumer Boundary

`xiuxian-wendao` loads the submodule and schedules policy checks.

`xiuxian-wendao-parsers` provides parser substrate objects such as section and
block cores. It must not own episteme policy logic.

Project Sentinel owns diagnostic rendering and audit protocol execution.

Project AnchoR v3 owns byte-range planning, CAS validation, overlap detection,
and final filesystem mutation.

Topology sync and source learning are separate build-time or review-time skill
flows. A Topology Architect Skill may scan the consumer manifest, workspace
structure, local symbols, and existing notes to propose an append-only diff in
the consumer repository. It must not update topology during `wendao audit`, and
it must not silently change the meaning of existing category numbers.

Compiled BPMN is not the policy source of record. The Markdown skill and source
registry are the governed source artifacts. Generated BPMN should be treated as
a build artifact unless a downstream release process explicitly pins it.

## Roadmap

1. Define the Diátaxis policy contract and Sentinel diagnostic mapping.
2. Define AnchoR v3 payload templates for missing identifier drawers.
3. Define Johnny.Decimal topology checks for address and path consistency.
4. Define Evergreen connectivity and atomicity audits.
5. Define ADR sensemaking checks for deprecated references and supersession
   drift.
6. Define skillsc/BPMN source evolution flows for reference and external
   practice review.
7. Add read-only validation queries only after the target Wendao SQL view is
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

## Diátaxis Closed Loop

Diátaxis enforcement is a closed-ontology intent loop:

1. `policies/diataxis/validation.sql` emits read-only diagnostics for missing
   or unknown intent metadata. It recognizes common property casing variants
   such as `INTENT`, `intent`, `DIATAXIS`, and `diataxis`.
2. Project Sentinel maps query rows to `Episteme_Diataxis_Violation` XML
   diagnostics.
3. `prompts/anchor_v3_fixers/fix_diataxis.txt` constrains LLM repair output to
   metadata-scoped `SurgicalFix` payloads. It may choose only `tutorial`,
   `how-to`, `explanation`, or `reference`.

Diátaxis repair must not relocate a node, rewrite prose, or change topological
identity. It classifies reader intent only.

Project-local path conflicts are handled separately by
`policies/diataxis/path_validation.sql`. That optional query requires the
consumer to expose `project_diataxis_path_rule`; `wendao-episteme` does not
hard-code workspace path semantics such as which directories may contain
tutorials.

## Evergreen Closed Loop

Evergreen enforcement is a graph-first policy loop:

1. `policies/evergreen/validation.sql` emits read-only diagnostics for isolated
   notes and notes that exceed the atomicity line-count threshold.
2. Project Sentinel maps query rows to `Episteme_Evergreen_Violation` XML
   diagnostics with metric evidence.
3. `prompts/anchor_v3_fixers/fix_evergreen.txt` constrains LLM repair output to
   relation-block `SurgicalFix` payloads. It must not rewrite author-owned
   prose or force connectivity outside a governed range.

Evergreen policy remains advisory by default. A relation suggestion can improve
connectivity, but it is not authority to relocate, split, or rewrite the note.

## Topology Manifest Sync

Johnny.Decimal semantics are enacted through a project-local `topology.toml`.
That file is an immutable contract once committed. If a module reorganization
requires new categories, the change must enter through an explicit diff or pull
request.

The sync flow has three responsibilities:

1. discover candidate topology pressure from code, dependency graphs, and notes;
2. propose manifest additions without changing existing meaning;
3. emit reviewable diffs and provenance for human approval.

The `topology_manifest` contract is append-only. The Topology Architect Skill
may propose new categories, new subcategories, or unmapped path bindings. It
must reject proposals that rename existing categories, renumber categories,
delete categories, rewrite existing anchor ids, or move existing notes.

The sync source files are `sources/topology/sources.toml` and
`sources/topology/evolution.skill.md`. They are governed source artifacts; the
consumer `topology.toml` remains outside this repository.

The runtime flow remains deterministic:

1. `wendao audit` loads `wendao-episteme` syntax policy;
2. Wendao reads the committed project-local `topology.toml`;
3. SQL and graph checks validate notes against the enacted map;
4. Sentinel and AnchoR v3 handle diagnostics and range-bounded repairs.

LLM agents execute governed skills. Git commits enact laws. SQL executes laws.

## Johnny.Decimal Source Learning Loop

Johnny.Decimal source learning is a skill-driven loop:

1. `sources/johnny_decimal/sources.toml` selects reference and practice sources
   plus scheduling metadata.
2. `sources/johnny_decimal/evolution.skill.md` is compiled by the
   `skillsc` prototype into BPMN with `skillsc:config` service-task metadata.
3. The target Wendao runtime executes the compiled graph through
   `qianji-bpmn-engine`, not through the prototype's Node `bpmn-engine`.
4. The BPMN flow runs fetch, parser mapping, and source audit tasks. Official
   references produce canonical drift reports; external practice sources may
   produce SQL deviation XML.
5. The BPMN flow routes non-empty audit reports into critique and policy
   proposal tasks.
6. Any policy change exits as an `Evolution_PR_Draft` for human review, never as
   an automatic runtime write.

## Diátaxis Source Learning Loop

Diátaxis source learning is a skill-driven loop:

1. `sources/diataxis/sources.toml` selects official and practice sources plus
   scheduling metadata.
2. `sources/diataxis/evolution.skill.md` is compiled by the `skillsc` prototype
   into BPMN with `skillsc:config` service-task metadata.
3. The target Wendao runtime executes the compiled graph through
   `qianji-bpmn-engine`, not through the prototype's Node `bpmn-engine`.
4. The BPMN flow compares canonical Diátaxis guidance against Wendao's closed
   intent ontology and reviews external intent-classification practice.
5. Terms such as "concept" or "cookbook" may produce aliasing, routing, or
   manual-review proposals, but not a fifth Diátaxis intent.
6. Any policy change exits as an `Evolution_PR_Draft` for human review, never as
   an automatic runtime write.

## Evergreen Source Learning Loop

Evergreen source learning is a skill-driven loop:

1. `sources/evergreen/sources.toml` selects reference and practice sources plus
   scheduling metadata.
2. `sources/evergreen/evolution.skill.md` is compiled by the `skillsc`
   prototype into BPMN with `skillsc:config` service-task metadata.
3. The target Wendao runtime executes the compiled graph through
   `qianji-bpmn-engine`, not through the prototype's Node `bpmn-engine`.
4. The BPMN flow extracts graph signals such as link density, isolated note
   examples, typical note length, and visible relation placement conventions.
5. Any policy change exits as an `Evolution_PR_Draft` for human review, never as
   an automatic runtime write.
