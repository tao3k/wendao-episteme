---
title: Brittle Query
kind: reference
category: search_reasoning
tags:
  - episteme
  - search_reasoning
description: Fixture for the search_reasoning framework.
author: xiuxian-artisan-workshop
date: 2026-04-26T09:30-07:00
metadata:
  retrieval:
    saliency_base: 5.5
    decay_rate: 0.05
---

# Brittle Query

```sql
SELECT *
FROM repo_content_chunk
WHERE file_path = 'docs/10_system/10.01_kernel.md';
```
