# Folgezettel Policy

Folgezettel policy governs sequence continuity for notes that opt into
lineage-style identifiers.

The policy treats `SEQUENCE` metadata as a causal extension chain. A child
sequence must have an existing parent sequence, and each sequence id must be
globally unique inside the audited graph.

`validation.sql` is read-only policy logic over Wendao logical views. It reports
broken parent chains, duplicate sequence ids, and malformed sequence ids.

Repair is metadata-scoped. The Folgezettel fixer may rewrite only the reported
sequence metadata range when the diagnostic includes exact bytes and a
reviewable replacement candidate. It must not create parent notes or rewrite
note prose.
