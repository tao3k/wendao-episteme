# MOC Policy

MOC policy governs navigation hubs for dense knowledge clusters.

A Map of Content is treated as a graph-routing surface, not as a subjective
summary quality score. The policy checks whether a dense Johnny.Decimal category
has a declared MOC node and whether each declared MOC has enough outgoing links
to function as a useful route hub.

`validation.sql` is read-only policy logic over Wendao logical views. It derives
category scope from node metadata, reports dense scopes with no MOC, and reports
MOC nodes with fewer than three outgoing references.

Repair is hub-scoped. The MOC fixer may add a small index block only inside an
explicitly reported range. It must not rewrite linked notes or create narrative
summaries on behalf of the author.
