# Folgezettel Policy

Folgezettel policy governs sequence continuity for notes that opt into
lineage-style identifiers.

The policy treats `SEQUENCE` metadata as a causal extension chain. A child
sequence must have an existing parent sequence, and each sequence id must be
globally unique inside the audited graph. Common frontmatter may declare the
sequence at `metadata.folgezettel.sequence`; flat `sequence` and `SEQUENCE`
fields remain parser-owned compatibility inputs for the same logical field.

`validation.sql` is read-only policy logic over Wendao logical views. It reports
broken parent chains, duplicate sequence ids, and malformed sequence ids.
The accepted alphanumeric sequence shape is a Wendao local opt-in convention;
the source material grounds sequence and parent/child continuity, not a single
universal ID grammar.

Repair is metadata-scoped. The Folgezettel fixer may rewrite only the reported
sequence metadata range when the diagnostic includes exact bytes and a
reviewable replacement candidate. It must not create parent notes or rewrite
note prose.

## Source Grounding

- [Folgezettel](https://zettelkasten.de/folgezettel/) translates the term as
  "sequence of notes" and frames the topic as an active debate rather than a
  single mandatory practice.
- [Understanding Hierarchy by Translating Folgezettel and Structure Zettel](https://zettelkasten.de/posts/understanding-hierarchy-translating-folgezettel/)
  grounds the unique identifier and hierarchy/address aspects of the technique.
- [No, Luhmann Was Not About Folgezettel](https://zettelkasten.de/posts/luhmann-folgezettel-truth/)
  describes Folgezettel as parent/child and direct intended connections while
  arguing that links can also realize the underlying principle.
