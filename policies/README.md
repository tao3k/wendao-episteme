# Policies

This directory contains portable policy contracts for Wendao knowledge
governance.

Policies describe domain invariants. They do not contain parser implementation,
physical schemas, DDL, or filesystem write logic. Consumers may compile these
contracts into the execution substrate that fits their runtime.

Each policy module owns a local `manifest.toml`. The root `episteme.toml`
imports these distributed manifests instead of duplicating framework,
diagnostic, authoring-template, repair-guard, or arbitration registrations.

Read-only SQL validation queries may live beside the policy they enforce as
`validation.sql`. They may inspect Wendao-owned logical views and catalogs, but
they must not define schema or encode Arrow/Rust type ownership.

The `conflicts/` policy module is a cross-framework arbitration surface. It
does not own a new theory; it exposes read-only diagnostics when enacted
frameworks produce competing remediation pressure.

The `authorship/` policy module is a write-time guard surface. Its
`validation.sql` is a read-only pre-write query over request-scoped repair
payloads and parser-owned byte-zone metadata before filesystem mutation.

The `protocols/` policy module owns global diagnostic and repair protocol
settings that are shared by multiple theory modules.
