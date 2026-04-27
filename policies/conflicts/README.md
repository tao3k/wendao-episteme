# Conflict Policies

This policy module exposes cross-framework arbitration checks.

Conflict queries do not replace framework-local validation. They surface cases
where two enacted policies produce competing remediation pressure and Sentinel
must apply the authority matrix from `policies/conflicts/manifest.toml`.

The SQL remains read-only. It emits arbitration diagnostics only; it must not
rewrite topology, document-kind metadata, ADR status, or relation edges.

The preferred authoring surface is common frontmatter plus framework-specific
metadata:

- document mode from top-level `kind`;
- ADR contract fields from `metadata.adr.type`, `metadata.adr.status`, and
  `metadata.adr.superseded_by`;
- topology coordinates from existing parser-owned `ID` fields or
  `metadata.johnny_decimal.coordinate`.

Legacy flat property names are accepted as parser input surfaces so existing
material can still be reviewed, but new notes should use the common
frontmatter contract.
