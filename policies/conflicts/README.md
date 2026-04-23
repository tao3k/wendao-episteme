# Conflict Policies

This policy module exposes cross-framework arbitration checks.

Conflict queries do not replace framework-local validation. They surface cases
where two enacted policies produce competing remediation pressure and Sentinel
must apply the authority matrix from `episteme.toml`.

The SQL remains read-only. It emits arbitration diagnostics only; it must not
rewrite topology, intent metadata, ADR status, or relation edges.
