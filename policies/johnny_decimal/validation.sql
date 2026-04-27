-- Johnny.Decimal topology validation for Wendao Episteme.
--
-- This file is intentionally read-only. It assumes Wendao has already
-- assembled the request-scoped SQL surface and exposed parser-owned logical
-- views. Do not add DDL, mutations, schema setup, or physical type mirrors.
--
-- Semantic area/category meaning, standard-zero reservations, and any JDex
-- evidence are project-local and must come from the consumer repository's
-- enacted topology manifest.
--
-- Wendao Episteme does not define a custom property-drawer syntax. Until a
-- parser-owned Johnny.Decimal metadata surface exists, this query preserves the
-- policy contract shape without emitting syntax-derived findings. That surface
-- should expose the numeric AC.ID coordinate separately from any path slug.

SELECT
  path AS file_path,
  CAST(NULL AS VARCHAR) AS violation_type,
  0 AS byte_start,
  0 AS byte_end,
  CAST(NULL AS VARCHAR) AS current_id
FROM repo_content_chunk
WHERE doc_type = 'markdown'
  AND FALSE;
