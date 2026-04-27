---
kind: SKILL.md
title: Demo Skill
category: skills
tags:
  - demo
  - skill-schema
description: Invalid SKILL.md schema fixture for command smoke tests.
author: xiuxian-artisan-workshop
date: 2026-04-26T09:30-07:00
name: demo-skill
metadata:
  retrieval:
    saliency_base: 5.5
    decay_rate: 0.05
  version: "1.0.0"
  routing_keywords: demo
---

# Demo Skill

This fixture keeps the common frontmatter valid while omitting `type` and
`metadata.source` and using the wrong shape for `metadata.routing_keywords`.
