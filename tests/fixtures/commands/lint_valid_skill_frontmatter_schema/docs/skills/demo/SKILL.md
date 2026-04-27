---
kind: SKILL.md
type: skill
title: Demo Skill
category: skills
tags:
  - demo
  - skill-schema
name: demo-skill
description: Use when validating repaired SKILL.md frontmatter in the episteme smoke suite.
author: xiuxian-artisan-workshop
date: 2026-04-26T09:30-07:00
metadata:
  retrieval:
    saliency_base: 5.5
    decay_rate: 0.05
  version: "1.0.0"
  source: "https://github.com/tao3k/xiuxian-artisan-workshop/tree/main/wendao-episteme/tests/fixtures/commands/lint_valid_skill_frontmatter_schema/docs/skills/demo"
  routing_keywords:
    - demo
    - skill schema
---

# Demo Skill

This fixture is the repaired counterpart to the invalid SKILL.md schema case.
It proves that lint accepts the required parser-owned skill identity and routing
metadata while keeping `metadata.intents` optional.
