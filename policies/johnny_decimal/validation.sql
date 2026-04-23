-- Johnny.Decimal anchor syntax validation for Wendao Episteme.
--
-- This file is intentionally read-only. It assumes Wendao has already
-- assembled the request-scoped SQL surface and exposed parser-owned logical
-- views. Do not add DDL, mutations, schema setup, or physical type mirrors.
--
-- Semantic category meaning is project-local and must come from the consumer
-- repository's enacted topology manifest.

SELECT
  path AS file_path,
  'MISSING_ID' AS violation_type,
  0 AS byte_start,
  0 AS byte_end,
  CAST(NULL AS VARCHAR) AS current_id
FROM repo_content_chunk
WHERE doc_type = 'markdown'
  AND (properties->>'ID') IS NULL

UNION ALL

SELECT
  path AS file_path,
  'INVALID_JD_FORMAT' AS violation_type,
  property_drawer_start AS byte_start,
  property_drawer_end AS byte_end,
  properties->>'ID' AS current_id
FROM repo_content_chunk
WHERE doc_type = 'markdown'
  AND (properties->>'ID') IS NOT NULL
  AND NOT regexp_matches(properties->>'ID', '^\\d{2}\\.\\d{2}_[a-z0-9][a-z0-9_-]*$');
