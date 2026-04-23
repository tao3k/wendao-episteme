# Policies

This directory contains portable policy contracts for Wendao knowledge
governance.

Policies describe domain invariants. They do not contain parser implementation,
physical schemas, DDL, or filesystem write logic. Consumers may compile these
contracts into the execution substrate that fits their runtime.

Read-only SQL validation queries may live beside the policy they enforce as
`validation.sql`. They may inspect Wendao-owned logical views and catalogs, but
they must not define schema or encode Arrow/Rust type ownership.
