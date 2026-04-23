-- Diátaxis intent validation for Wendao Episteme.
--
-- This file is intentionally read-only. Diátaxis is a closed ontology, so the
-- accepted values are part of this policy rather than a project-local manifest.

WITH intent_chunks AS (
  SELECT
    path AS file_path,
    doc_type,
    property_drawer_start,
    property_drawer_end,
    COALESCE(
      properties->>'INTENT',
      properties->>'intent',
      properties->>'DIATAXIS',
      properties->>'diataxis'
    ) AS current_intent
  FROM repo_content_chunk
)
SELECT
  file_path,
  'MISSING_DIATAXIS_INTENT' AS violation_type,
  COALESCE(property_drawer_start, 0) AS byte_start,
  COALESCE(property_drawer_end, 0) AS byte_end,
  CAST(NULL AS VARCHAR) AS current_intent
FROM intent_chunks
WHERE doc_type = 'markdown'
  AND current_intent IS NULL

UNION ALL

SELECT
  file_path,
  'INVALID_DIATAXIS_INTENT' AS violation_type,
  property_drawer_start AS byte_start,
  property_drawer_end AS byte_end,
  current_intent
FROM intent_chunks
WHERE doc_type = 'markdown'
  AND current_intent IS NOT NULL
  AND lower(current_intent) NOT IN (
    'tutorial',
    'how-to',
    'explanation',
    'reference'
  );
