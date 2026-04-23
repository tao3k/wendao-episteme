-- Diátaxis intent validation for Wendao Episteme.
--
-- This file is intentionally read-only. Diátaxis is a closed ontology, so the
-- accepted values are part of this policy rather than a project-local manifest.

SELECT
  path AS file_path,
  'MISSING_DIATAXIS_INTENT' AS violation_type,
  0 AS byte_start,
  0 AS byte_end,
  CAST(NULL AS VARCHAR) AS current_intent
FROM repo_content_chunk
WHERE doc_type = 'markdown'
  AND COALESCE(properties->>'diataxis', properties->>'intent') IS NULL

UNION ALL

SELECT
  path AS file_path,
  'INVALID_DIATAXIS_INTENT' AS violation_type,
  property_drawer_start AS byte_start,
  property_drawer_end AS byte_end,
  COALESCE(properties->>'diataxis', properties->>'intent') AS current_intent
FROM repo_content_chunk
WHERE doc_type = 'markdown'
  AND COALESCE(properties->>'diataxis', properties->>'intent') IS NOT NULL
  AND lower(COALESCE(properties->>'diataxis', properties->>'intent')) NOT IN (
    'tutorial',
    'how-to',
    'explanation',
    'reference'
  );
