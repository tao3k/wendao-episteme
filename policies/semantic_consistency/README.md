# Semantic Consistency Policy

Semantic Consistency policy governs cross-surface enum alignment.

The policy checks whether document lifecycle status values stay inside the
shared protocol vocabulary understood by Wendao governance tooling. It catches
status drift such as misspellings, unregistered lifecycle states, or local
aliases that have not been enacted.

`validation.sql` is read-only policy logic over Wendao logical views. It checks
metadata status values against a small policy-owned vocabulary.

`stale_read_validation.sql` is a separate optional policy query. It requires the
consumer to expose `project_content_fingerprint(path, content_hash)` as a
request-scoped view, then compares agent-maintained dependency hashes against
the live fingerprint surface.

Repair is metadata-scoped. The fixer may correct a status value only inside the
reported metadata range when the diagnostic provides exact bytes and a clear
canonical status. It must not reinterpret document authority or rewrite prose.

Stale-read diagnostics are planner-scoped. They should produce a reviewable plan
before any executor writes document prose.
