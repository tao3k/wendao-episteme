# IBIS Policy

IBIS policy governs argumentation graph structure for documents that opt into
Issue-Based Information System metadata.

The policy checks whether an `Issue` node has at least one `Position` response
and whether explicit position targets resolve to known issues. It does not
decide which position is correct.

`validation.sql` is read-only policy logic over Wendao logical views. It uses
metadata and reference occurrences to detect unresolved issues and dangling
positions.

Repair is debate-scaffold scoped. The IBIS fixer may add a placeholder position
only inside an explicitly reported range. It must not fabricate decisions,
arguments, or evidence.
