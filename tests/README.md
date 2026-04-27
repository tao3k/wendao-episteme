# Wendao Episteme Tests

Run the repository-local Wendao command smoke tests with:

```bash
just test
```

Each theory owns an independent fixture document set under
`tests/fixtures/frameworks/<framework>/docs/`. Tests load one fixture root at a
time so Johnny.Decimal, Diataxis, ADR, Evergreen, MOC, Folgezettel, IBIS,
search reasoning, semantic consistency, conflict arbitration, and authorship
boundary scenarios do not share hidden state.

The smoke runner builds the superproject `wendao` binary once, then executes
the real Wendao surfaces directly from the superproject. The `justfile` keeps
command-level checks focused on exit status and compact diagnostics. The
superproject Rust unit suite snapshots the real `wendao-episteme`
`audit --template` compact outputs so every registered theory template keeps a
complete LLM-facing contract.

- `wendao lint markdown` validates fixture Markdown syntax and frontmatter.
- `wendao lint markdown` also carries negative frontmatter and `SKILL.md`
  fixtures that must fail through the command path.
- A paired valid `SKILL.md` fixture proves the repaired schema shape passes
  lint while `metadata.intents` remains optional.
- `wendao audit --template <framework>` prints registered authoring templates
  as compact LLM-oriented text, including severity-coded deterministic
  diagnostics and repair-action help lines. The smoke suite covers
  Johnny.Decimal, Diataxis, Evergreen Notes, ADR, MOC, Folgezettel, IBIS,
  Structural Proprioception, Search as Reasoning, Semantic Consistency, and
  Epistemic Sensemaking, and Temporal Scaffolding. The command itself rejects
  incomplete template contracts. A Rust snapshot test records all rendered
  theory outputs, including authority, path contract, deterministic
  diagnostics, LLM inputs, LLM outputs, examples, and verification sections.
- `wendao audit --load <episteme>` validates that the current Wendao audit path
  can load the thin root `episteme.toml` and its distributed manifests from
  either the repository root or the direct manifest file while auditing fixture
  docs.
- Repair-prompt shared tooling defaults are loaded from
  `prompts/anchor_v3_fixers/manifest.toml`; individual prompt entries must not
  redeclare `repair_tooling`.
- Source-evolution execution defaults are loaded from `sources/manifest.toml`;
  source-local registries must stay metadata-only and cannot redeclare
  `[execution]`.
- The Python alignment runner tests cover source URL resolution and Markdown
  chunking for report preparation. These tests do not perform network fetches
  and do not execute policy.

Leading frontmatter is the required document-level metadata carrier in these
fixtures. The common frontmatter contract applies to every Markdown fixture:
ordinary documents carry `title`, `kind`, `category`, `tags`, `description`,
`author`, minute-precision `date`, and `metadata.retrieval` entropy fields.
The three common classification axes are intentionally distinct: `kind` is the
reading/use mode, `category` is the primary project or domain bucket, and
`tags` are flexible cross-cutting retrieval hints. `SKILL.md` fixtures start
from that common contract, then add the strict skill extension fields; only
`metadata.intents` is optional in the skill-specific extension.
Diataxis fixtures cover the four ordinary-document kind values, an invalid
value, and a missing-value case. Other theory fixtures avoid custom drawer
syntax and only use fields owned by their current portable metadata contract.

Johnny.Decimal smoke fixtures intentionally stay in ordinary Markdown.
`wendao-episteme` does not define or test custom property syntax; it keeps the
theory asset, authoring-template command, and policy-query loading contract
until a parser-owned Johnny.Decimal metadata surface exists.

Evergreen fixtures cover the compact diagnostic repair surfaces used by LLM
fixers: an isolated note with no relation block, a note with an empty governed
relation block, and an oversized note that must produce an atomicity review
plan instead of an automatic rewrite. The fixtures intentionally cover only
deterministic surfaces. Source-grounded Evergreen principles such as concept
orientation, associative ontology preference, and title-as-API quality remain
review evidence rather than lint obligations.

The current `audit --load` implementation in Wendao is still a load/validate
and report-observability slice. It does not yet execute external episteme SQL
policies, so these smoke tests prove command interaction, manifest loading, and
the local fixture/policy contracts rather than full theory-specific policy
execution. Any future completion or repair of theory metadata belongs to
audit/repair flows, not to the current frontmatter lint contract.
