-- Optional Diátaxis path-intent validation for Wendao Episteme.
--
-- This file is intentionally read-only. It requires the consumer to expose a
-- request-scoped `project_diataxis_path_rule` view. The policy repository does
-- not hard-code project path semantics.

WITH intent_chunks AS (
  SELECT
    path AS file_path,
    doc_type,
    property_drawer_start,
    property_drawer_end,
    lower(COALESCE(
      properties->>'INTENT',
      properties->>'intent',
      properties->>'DIATAXIS',
      properties->>'diataxis'
    )) AS normalized_intent
  FROM repo_content_chunk
)
SELECT
  c.file_path,
  'DIATAXIS_PATH_CONFLICT' AS violation_type,
  c.property_drawer_start AS byte_start,
  c.property_drawer_end AS byte_end,
  c.normalized_intent AS current_intent,
  r.path_pattern AS path_pattern
FROM intent_chunks c
JOIN project_diataxis_path_rule r
  ON c.file_path LIKE r.path_pattern
WHERE c.doc_type = 'markdown'
  AND c.normalized_intent = lower(r.disallowed_intent);
