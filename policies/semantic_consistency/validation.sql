-- Semantic consistency status validation for Wendao Episteme.
--
-- This file is intentionally read-only. It assumes Wendao has already
-- assembled the request-scoped SQL surface and exposed parser-owned logical
-- views.

WITH allowed_statuses(status) AS (
  VALUES
    ('DRAFT'),
    ('PROPOSED'),
    ('ACCEPTED'),
    ('ACTIVE'),
    ('HARDENING'),
    ('HARDENED'),
    ('DEPRECATED'),
    ('SUPERSEDED')
),
content_statuses AS (
  SELECT
    path AS file_path,
    upper(trim(COALESCE(properties->>'STATUS', properties->>'status'))) AS current_status,
    COALESCE(property_drawer_start, 0) AS byte_start,
    COALESCE(property_drawer_end, 0) AS byte_end
  FROM repo_content_chunk
  WHERE doc_type = 'markdown'
    AND COALESCE(properties->>'STATUS', properties->>'status') IS NOT NULL
)
SELECT
  content.file_path,
  'SEMANTIC_CONSISTENCY_INVALID_STATUS' AS violation_type,
  content.byte_start,
  content.byte_end,
  content.current_status
FROM content_statuses content
LEFT JOIN allowed_statuses allowed
  ON content.current_status = allowed.status
WHERE content.current_status <> ''
  AND allowed.status IS NULL;
