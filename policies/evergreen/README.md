# Evergreen Policy

Evergreen policy governs graph connectivity and note atomicity.

The contract guards against knowledge silos, zero-degree nodes, semantic rot,
oversized monolith notes, and stale relation blocks. Repair proposals should be
advisory and range-bounded, such as relation-block link suggestions, rather than
whole-document rewrites.

The policy intentionally avoids subjective prose-quality scoring. It translates
Evergreen practice into computable graph and size contracts:

- isolated notes are detected through zero incoming and outgoing reference
  degree;
- oversized notes are detected through a line-count threshold;
- repair suggestions are limited to relation surfaces, not author-owned prose.

## Assets

- `validation.sql` contains read-only checks for connectivity and atomicity.
- `diagnostic.toml` maps validation rows to Project Sentinel XML diagnostics.
- `../../prompts/anchor_v3_fixers/fix_evergreen.txt` constrains relation-link
  repair payload generation.
- `../../sources/evergreen/evolution.skill.md` defines the skillsc/BPMN source
  evolution flow for reference and practice review.
