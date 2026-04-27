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
- **Diátaxis:** Document-kind classification rules for tutorials, how-to guides,
  explanations, and reference material.
- **ADR:** Decision-record contracts for status, supersession, and architectural
  consistency.
- **Evergreen Notes:** Synthesis rules for atomicity, durable links, and
  progressive refinement without creating knowledge silos.
- **MOC:** Route-hub rules for dense note clusters that need explicit maps of
  content.
- **Folgezettel:** Lineage-sequence rules for parent continuity and causal
  extension chains.
- **IBIS:** Argumentation-graph rules for issues, positions, and unresolved
  debate scaffolds.
- **Structural Proprioception:** Graph-health rules for detecting circular
  dependencies and topology hazards.
- **Search as Reasoning:** Query robustness rules for replacing brittle path
  equality with stable semantic predicates.
- **Semantic Consistency:** Protocol-alignment rules for lifecycle metadata and
  cross-surface enum vocabulary.
- **Temporal Scaffolding:** Human-AI authorship boundaries for structural
  maintenance without whole-document rewrites.
- **Epistemic Sensemaking:** Consensus-oriented evolution for deprecated
  references, conflicting claims, and visible remediation proposals.

## Contract Model

The repository treats each epistemology as a policy module with explicit
authority, ownership, and conflict behavior. The root
[`episteme.toml`](episteme.toml) is intentionally thin: it records global
boundaries and imports distributed manifests from `policies/`, `prompts/`, and
`sources/`.

The distributed manifests record:

- which knowledge fields a framework owns;
- whether violations are errors, warnings, or advisory signals;
- how conflicts between frameworks should be resolved;
- which stable Wendao SQL views and catalogs validation queries may read;
- which project-local semantic manifests consumers must provide;
- which write-time repair guards must protect author-owned byte ranges;
- which source-evolution skills may be compiled into BPMN review flows.

This keeps the knowledge laws stable while allowing Wendao to choose the most
appropriate execution substrate for a given environment.

The common Markdown frontmatter contract is parser-owned and applies to every
Markdown document. It requires `title`, `kind`, `category`, `tags`,
`description`, `author`, minute-precision `date`, and
`metadata.retrieval.saliency_base` / `metadata.retrieval.decay_rate`. `kind`
is the controlled reading/use-mode axis, `category` is the primary project or
domain bucket, and `tags` are flexible cross-cutting retrieval hints. `SKILL.md`
frontmatter extends this common contract with `type`, `name`,
`metadata.version`, `metadata.source`, and `metadata.routing_keywords`; only
`metadata.intents` is optional in the skill-specific extension.

## Conflict Policy

`policies/conflicts/manifest.toml` defines priority and conflict behavior
between theories. The priority is not a simple execution order. It is an
authority model for deciding which invariant wins when two frameworks
disagree.

For example, if an Evergreen synthesis link suggests relocating a note across a
Johnny.Decimal boundary, the canonical topological address remains stable until
an explicit move decision is recorded. The synthesis signal can become a repair
recommendation, but it must not silently rewrite identity.

Cross-framework conflicts may also be surfaced by read-only arbitration
queries under `policies/conflicts/`. Those queries do not execute repair. They
emit Sentinel diagnostics that carry the winning framework, losing framework,
and enacted resolution from the manifest.

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

`wendao episteme sync` is modeled as an on-demand Topology Architect review
flow. It reads the consumer manifest and workspace evidence, then emits only an
append-only topology diff. Existing category identity, assigned coordinates,
and committed anchor ids are not mutable through this flow.

Diátaxis has a different boundary. It is a closed ontology, so the four allowed
ordinary-document kinds are part of the common frontmatter contract.

Diátaxis repair is metadata-scoped. LLM repair may classify a document into one
of the four document-kind values, but it must not relocate the node or rewrite
prose to make the classification fit.

Path and document-kind conflicts are project-local. Consumers may expose
optional path-rule views for those checks, but this repository does not
hard-code workspace directory semantics into the universal Diátaxis policy.

## Evergreen Boundary

Evergreen Notes are enforced as graph and size contracts, not subjective writing
judgments. `wendao-episteme` checks connectivity and atomicity through stable
logical views, then limits repair suggestions to relation surfaces.

For isolated notes, LLM repair may suggest `[[WikiLinks]]` only inside a
governed `:RELATIONS:` block or an explicitly reported insertion range. It must
not rewrite author-owned prose to force graph connectivity.

## MOC Boundary

Maps of Content are enforced as navigation hubs for dense scopes. The policy
detects scopes whose note count exceeds the hub threshold and MOC nodes whose
out-degree is too low to route readers.

MOC repair is index-scoped. AnchoR may add a compact route index only inside an
explicit insertion range in an existing MOC file. It must not create new notes,
move notes, or write narrative summaries as if they were authored conclusions.

## Folgezettel Boundary

Folgezettel policy applies only to notes that opt into sequence metadata. It
checks parent-chain continuity, uniqueness, and accepted alphanumeric sequence
shape.

Folgezettel repair is metadata-scoped. A fixer may adjust the reported
`SEQUENCE` line only when the diagnostic provides exact bytes and a reviewable
replacement candidate. It must not fabricate a missing parent note.

## ADR Boundary

ADR policy treats decision records as lifecycle contracts. It checks status
values, supersession pointers, and references to expired decisions through
read-only logical views.

An `ACTIVE` ADR remains the governing contract until another ADR explicitly
supersedes or deprecates it. When a document references a `DEPRECATED` or
`SUPERSEDED` ADR, Sentinel should emit a disagreement diagnostic. AnchoR repair
may replace the stale decision pointer only when the diagnostic provides an
exact byte range and a successor id. It must not rewrite decision rationale or
the ADR record itself.

## IBIS Boundary

IBIS policy treats argumentation as an explicit graph. It checks that `Issue`
nodes have at least one detected `Position` response and that position targets
resolve to known issues.

IBIS repair is debate-scaffold scoped. AnchoR may add a placeholder
`Position: Pending Analysis` only inside an explicit range. It must not decide
the issue, fabricate arguments, or resolve an architectural disagreement.

## Structural Proprioception Boundary

Structural Proprioception policy gives the graph a bounded self-awareness
contract. It detects short circular dependencies by resolving reference
occurrences against known node titles and ids, then walking the graph with a
bounded recursive query. It also supports Sentinel v2-style semantic drift
checks by comparing document `OBSERVE` metadata against the `local_symbol`
view.

Repair is relation- or metadata-scoped. AnchoR may soften one selected relation
edge or update one reported observation pointer only when Sentinel provides
exact bytes and the chosen target. It must not globally rewrite topology,
rename code symbols, or remove multiple links.

## Search Reasoning Boundary

Search as Reasoning policy treats embedded queries as reasoning artifacts. SQL,
DuckDB, or GraphQL snippets should avoid brittle exact path equality when a
stable id, topology, intent, or tag predicate is available.

Code-symbol references should use structural UIDs such as
`path/to/file::owner::symbol` when the parser can resolve the symbol through
`local_symbol`.

Repair is query-scoped. AnchoR may replace only the brittle predicate range when
the diagnostic provides a stable semantic replacement. UID repair may replace
only the reported reference text. It must preserve query intent and leave
surrounding prose untouched.

## Semantic Consistency Boundary

Semantic Consistency policy keeps lifecycle metadata inside the enacted Wendao
status vocabulary: `DRAFT`, `PROPOSED`, `ACCEPTED`, `ACTIVE`, `HARDENING`,
`HARDENED`, `DEPRECATED`, and `SUPERSEDED`.

Agent-maintained notes may opt into stale-read detection through the optional
`project_content_fingerprint` view. A hash mismatch is a planner review signal,
not authority for direct prose mutation.

Repair is metadata-scoped. AnchoR may correct only the reported status value
when the canonical replacement is unambiguous. New lifecycle vocabulary must go
through source evolution review before it becomes valid.

## Conflict Arbitration Boundary

Conflict arbitration applies the manifest's authority matrix after individual
policies have produced evidence. `topology-vs-synthesis` preserves
Johnny.Decimal identity over Evergreen relocation pressure.
`decision-contract-vs-document-kind` preserves ADR authority over Diátaxis
document-kind metadata. `deprecated-decision-reference` routes stale ADR pointers through
Sensemaking before mutation.

Only the ADR-vs-Diátaxis case has a bounded metadata repair prompt because its
safe resolution is local document-kind reclassification. Topology, authorship, and
consensus conflicts remain recommendation or review flows unless Sentinel
reports an explicit safe range.

## Authorship Boundary Defense

Temporal Scaffolding is enforced at write time by Project AnchoR v3. The parser
substrate owns byte-zone classification. Author-owned zones such as paragraphs,
lists, code blocks, mathematical content, and decision rationale are protected
from automated repair.

Only scaffold zones may receive default fixes: metadata drawers, relation
blocks, footer blocks, or explicit Sentinel-reported governed ranges. If a
payload crosses into protected prose, AnchoR must reject the write and emit an
authorship-boundary diagnostic. The replan prompt may move the proposal to a
safe scaffold range only when Sentinel provides exact bytes for that range.

Repair prompt defaults live in `prompts/anchor_v3_fixers/manifest.toml`.
Individual prompt entries declare prompt identity, framework, path, and
write-mode only; shared repair tooling must not be repeated per entry.

## Source Evolution Skills

External reference analysis is not prompt engineering. The `sources/` tree
stores source registries plus one monolithic `evolution.skill.md` per
framework. Consumers compile that skill with `skillsc` into BPMN. The upstream
prototype proves the model: a large model compiles Markdown into a BPMN subset,
and each compiled `serviceTask` carries `skillsc:config` with a focused prompt,
tools, inputs, and outputs.

Execution defaults live in `sources/manifest.toml`. Individual
`sources/*/sources.toml` files declare only source metadata; they must not
redeclare `[execution]` blocks.

The repository-local `tools/wendao_episteme_align` runner prepares
Codex-assisted alignment reports from those source registries. It fetches
practice sources, normalizes Markdown, chunks source text, and writes a Codex
evidence-extraction prompt packet under `$PRJ_CACHE_HOME/episteme/alignment/`.
It is report preparation only: it does not call an external model API, execute
policy, mutate `policies/`, or replace `wendao audit` / `wendao lint`.

The prototype executor uses Node `bpmn-engine`; that is not the Wendao runtime
contract. The intended execution target is `qianji-bpmn-engine` with a host
bridge that dispatches `skillsc:config` service tasks. Until that adapter
exists, human review is represented as an output packet rather than a BPMN
`userTask` or `manualTask`.

The output is always reviewable evidence or a proposed diff. The skill flow must
not silently rewrite policy SQL, project topology manifests, or committed
knowledge graph identity.

Topology sync uses the same skill model, but it is on-demand rather than a
scheduled external-source review. Its source files live under
`sources/topology/` and its output is a reviewable consumer `topology.toml`
diff.

## Repository Structure

```text
.
├── docs/
│   └── rfcs/           # Architecture and policy blueprints
├── policies/           # Portable framework policy manifests and contracts
├── prompts/            # AnchoR v3 repair-template manifests and surfaces
├── sources/            # Skillsc/BPMN source evolution manifests and flows
├── README.md
└── episteme.toml       # Thin root manifest that imports distributed policy
```

## Integration Boundary

Wendao loaders may consume this repository as a submodule and compile the
manifested contracts into runtime-specific validators. DuckDB, Apache Arrow,
Rust, Julia, and LLM-assisted repair loops are implementation choices of the
consumer, not source artifacts owned by this repository.

SQL files in this repository, when present, are policy-local validation queries
only. They must be read-only `SELECT` statements over request-scoped Wendao SQL
surfaces such as `wendao_sql_tables`, `wendao_sql_columns`,
`repo_content_chunk`, `repo_entity`, and `reference_occurrence`. They must not
define tables, mutate state, create schema, or encode Arrow/Rust type
ownership.

Project Sentinel owns diagnostic rendering and XML emission. Project AnchoR v3
owns `ByteRange` repair planning, Blake3 compare-and-swap validation, overlap
detection, and final filesystem writes. `wendao-episteme` only defines the
policies, bounded repair templates, and skill surfaces those tools consume.

Part of the Xiuxian Artisan Workshop.
