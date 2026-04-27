# Authorship Boundary Policy

This policy module defines the write-time authorship boundary for Project
AnchoR v3.

The boundary is enforced after Sentinel has reported a diagnostic and before
AnchoR writes a `SurgicalFix` payload. The consumer runtime must compare each
target byte range with parser-owned zone metadata from
`xiuxian-wendao-parsers`.

`validation.sql` is a read-only pre-write guard over request-scoped logical
views. It expects attempted repair payloads in `repair_payload_target` and
parser-owned byte-zone classifications in `parser_byte_zone`. A payload is
valid only when its target range is fully contained by one governed scaffold
zone.

Protected zones include ordinary paragraphs, lists, code blocks, mathematical
content, and decision rationale. Governed scaffold zones include metadata
drawers, relation blocks, footer blocks, and explicit Sentinel-reported safe
ranges.

When a payload crosses into protected author-owned prose, AnchoR must reject the
write and emit an authorship-boundary diagnostic instead of attempting a partial
write.

The repair LLM may only replan into an explicit scaffold range when Sentinel
provides exact original bytes or an equivalent compare-and-swap hash. Without
that evidence, the correct output is manual review.
