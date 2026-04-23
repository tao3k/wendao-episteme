# Authorship Boundary Policy

This policy module defines the write-time authorship boundary for Project
AnchoR v3.

It is not a SQL validation module. The boundary is enforced after Sentinel has
reported a diagnostic and before AnchoR writes a `SurgicalFix` payload. The
consumer runtime must compare each target byte range with parser-owned zone
metadata from `xiuxian-wendao-parsers`.

Protected zones include ordinary paragraphs, lists, code blocks, mathematical
content, and decision rationale. Governed scaffold zones include metadata
drawers, relation blocks, footer blocks, and explicit Sentinel-reported safe
ranges.

When a payload crosses into protected author-owned prose, AnchoR must reject the
write and emit an authorship-boundary diagnostic instead of attempting a partial
write.
