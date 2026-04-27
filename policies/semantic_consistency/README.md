# Semantic Consistency Policy

Semantic Consistency policy governs cross-surface enum alignment.

The policy checks whether document lifecycle status values stay inside the
shared protocol vocabulary understood by Wendao governance tooling. It catches
status drift such as misspellings, unregistered lifecycle states, or local
aliases that have not been enacted.

`validation.sql` is read-only policy logic over Wendao logical views. It checks
common-frontmatter lifecycle status values against a small policy-owned
vocabulary. New documents should write status as
`metadata.lifecycle.status`; direct `STATUS` and `metadata.status` are accepted
only as parser-owned input surfaces for existing material.

`stale_read_validation.sql` is a separate optional policy query. It requires the
consumer to expose `project_content_fingerprint(path, content_hash)` as a
request-scoped view, then compares agent-maintained dependency hashes against
the live fingerprint surface. New agent-maintained notes should write
`metadata.agent.maintainer: agent` plus `metadata.dependencies.file` and
`metadata.dependencies.hash`.

Repair is metadata-scoped. The fixer may correct a status value only inside the
reported metadata range when the diagnostic provides exact bytes and a clear
canonical status. It must not reinterpret document authority or rewrite prose.

Stale-read diagnostics are planner-scoped. They should produce a reviewable plan
before any executor writes document prose. The diagnostic proves the recorded
read is stale; it does not authorize direct prose regeneration.
