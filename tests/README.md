# Wendao Episteme Tests

Run the repository-local Wendao command smoke tests with:

```bash
tests/run.sh
```

Each theory owns an independent fixture document set under
`tests/fixtures/frameworks/<framework>/docs/`. Tests load one fixture root at a
time so Johnny.Decimal, Diataxis, ADR, Evergreen, MOC, Folgezettel, IBIS,
search reasoning, semantic consistency, and conflict arbitration scenarios do
not share hidden state.

The smoke runner executes the real Wendao surfaces from the superproject:

- `wendao lint markdown` validates fixture Markdown syntax and frontmatter.
- `wendao audit --load <episteme>` validates that the current Wendao audit path
  can load the episteme manifest from either the repository root or the direct
  `episteme.toml` file while auditing fixture docs.

Leading frontmatter is the required document-level metadata carrier in these
fixtures, but the smoke suite only relies on schema-owned frontmatter fields
that Wendao currently types explicitly. In practice that means the fixtures
carry a leading `title` and do not encode theory-specific fields such as
`ID`, `INTENT`, or `STATUS` as if they were part of the frontmatter schema.

Body-local `:PROPERTIES:` drawers remain Wendao's local and atomic metadata
syntax. The smoke fixtures intentionally keep one local drawer example inside
`johnny_decimal/docs/missing_id.md` to ensure that command-driven audit
continues to see document metadata and local atomic metadata as distinct
surfaces.

The current `audit --load` implementation in Wendao is still a load/validate
and report-observability slice. It does not yet execute external episteme SQL
policies, so these smoke tests prove command interaction and manifest loading
rather than full theory-specific policy execution. Any future completion or
repair of theory metadata belongs to audit/repair flows, not to the current
frontmatter lint contract.
