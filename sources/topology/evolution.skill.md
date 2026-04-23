---
name: workspace-topology-sync
description: Draft an append-only topology manifest proposal for a consumer repository
---

# Workspace Topology Sync

Review one consumer repository topology snapshot.

Use the committed consumer `topology.toml` as the enacted semantic map. Use
workspace structure and symbol evidence to detect unmapped areas. Do not edit
files. Return evidence and a reviewable append-only proposal only.

## Steps

1. Read the current consumer topology manifest from the configured default
   path.
2. Read workspace evidence from the configured request-scoped views.
3. Identify directories, crates, packages, or symbol clusters that are not
   covered by an enacted topology category.
4. Reject any proposal that renames, renumbers, deletes, or changes the meaning
   of an existing category.
5. For each unmapped area, propose the smallest new category or subcategory that
   preserves existing Johnny.Decimal identity.
6. If no unmapped areas exist, return an empty proposal and set
   `humanReviewRequired` to `false`.
7. If additions are needed, write concise evidence for each proposed coordinate.
8. Draft a TOML diff that only appends new entries or adds new path bindings.
9. Return a JSON object with exactly these keys:
   - `workspaceStructureSnapshot`
   - `proposedTopologyDiff`
   - `rejectedMutations`
   - `humanReviewRequired`
