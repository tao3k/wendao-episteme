# Evergreen Policy

Evergreen policy governs graph connectivity and note atomicity.

The contract guards against knowledge silos, zero-degree nodes, semantic rot,
oversized monolith notes, and stale relation blocks. Repair proposals should be
advisory and range-bounded, such as relation-block link suggestions, rather than
whole-document rewrites.

The policy intentionally avoids subjective prose-quality scoring. It translates
Evergreen practice into computable graph and size contracts:

- isolated notes are detected through zero incoming and outgoing reference
  degree and split into missing-relation-block versus empty-relation-block
  repair surfaces;
- oversized notes are detected through a line-count threshold;
- repair suggestions are limited to relation surfaces, not author-owned prose.

## Source Grounding

This policy is grounded in Andy Matuschak's public working notes, especially:

- [Evergreen notes](https://notes.andymatuschak.org/Evergreen_notes)
- [Evergreen notes should be atomic](https://notes.andymatuschak.org/Evergreen_notes_should_be_atomic)
- [Evergreen notes should be concept-oriented](https://notes.andymatuschak.org/Evergreen_notes_should_be_concept-oriented)
- [Evergreen notes should be densely linked](https://notes.andymatuschak.org/Evergreen_notes_should_be_densely_linked)
- [Prefer associative ontologies to hierarchical taxonomies](https://notes.andymatuschak.org/Prefer_associative_ontologies_to_hierarchical_taxonomies)
- [Evergreen note titles are like APIs](https://notes.andymatuschak.org/Evergreen_note_titles_are_like_APIs)
- [Evergreen note maintenance approximates spaced repetition](https://notes.andymatuschak.org/Evergreen_note_maintenance_approximates_spaced_repetition)

Only mechanically observable parts become deterministic diagnostics. Dense
linking becomes graph-degree and relation-block checks. Atomicity becomes a
line-count review signal, not an automatic split. Concept orientation, sharp
title/API quality, associative ontology preference, and write-for-yourself
practice remain LLM review evidence because they require judgment and local
intent.

The deterministic diagnostic vocabulary is:

- `EVERGREEN_ORPHAN_MISSING_RELATION_BLOCK`
- `EVERGREEN_EMPTY_RELATION_BLOCK`
- `EVERGREEN_BLOATED`

## Assets

- `validation.sql` contains read-only checks for connectivity and atomicity.
- `diagnostic.toml` maps validation rows to Project Sentinel XML diagnostics.
- `../../prompts/anchor_v3_fixers/fix_evergreen.txt` constrains relation-link
  repair payload generation.
- `../../sources/evergreen/evolution.skill.md` defines the skillsc/BPMN source
  evolution flow for reference and practice review.
