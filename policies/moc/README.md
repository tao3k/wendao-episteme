# MOC Policy

MOC policy governs navigation hubs for dense knowledge clusters.

A Map of Content is treated as a graph-routing surface, not as a subjective
summary quality score. The policy checks whether a dense path-first
Johnny.Decimal category has a declared MOC node and whether each declared MOC has
enough outgoing links to function as a useful route hub.

`validation.sql` is read-only policy logic over Wendao logical views. It derives
category scope from project metadata or path-first Johnny.Decimal coordinates,
reports dense scopes with no MOC, and reports MOC nodes with fewer than three
outgoing references. A MOC may be declared through `metadata.moc.role` values
such as `hub` or through the project-local `AC.00_*` path convention.

Repair is hub-scoped. The MOC fixer may add a small index block only inside an
explicitly reported range. It must not rewrite linked notes or create narrative
summaries on behalf of the author.

## Source Grounding

- [MOCs Overview](https://blog.linkingyourthinking.com/notes/mocs-overview)
  defines MOCs as notes that map contents and help users gather, develop, and
  navigate ideas.
- [MOCs definition](https://blog.linkingyourthinking.com/notes/mocs-%28defn%29)
  treats MOCs as mapping notes made from clustered links rather than plain
  indexes.
- [Maps](https://blog.linkingyourthinking.com/maps/) and
  [Habits Map](https://blog.linkingyourthinking.com/notes/habits-map) ground
  the route-hub behavior: maps connect notes so the reader can navigate the
  surrounding network.

The density threshold is a Wendao deterministic heuristic. The source material
uses scattered-note overwhelm as the creation trigger, while Wendao converts
that trigger into a reviewable count-based advisory.
