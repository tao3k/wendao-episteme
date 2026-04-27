# IBIS Policy

IBIS policy governs argumentation graph structure for documents that opt into
Issue-Based Information System metadata.

The policy checks whether an `Issue` node has at least one `Position` response
and whether explicit position targets resolve to known issues. It also reports
unknown IBIS node types so metadata typos do not silently drop documents from
the argumentation graph. It does not decide which position is correct.

`validation.sql` is read-only policy logic over Wendao logical views. It uses
metadata and reference occurrences to detect unresolved issues and dangling
positions. Common frontmatter may declare IBIS fields at `metadata.ibis.*`.

Repair is debate-scaffold scoped. The IBIS fixer may add a placeholder position
only inside an explicitly reported range. It must not fabricate decisions,
arguments, or evidence.

## Source Grounding

- [Issues as Elements of Information Systems](https://escholarship.org/content/qt5cj786v8/qt5cj786v8.pdf)
  grounds IBIS as a discourse support system with topics, issues, questions of
  fact, positions, arguments, and model problems.
- [Issue-based information system](https://en.wikipedia.org/wiki/Issue-based_information_system)
  summarizes the common three-node graph of issues, positions, and arguments.
- The deterministic policy only checks graph scaffolding: issue response
  coverage, dangling position targets, and recognized node vocabulary. Argument
  quality and decision correctness remain review-only.
