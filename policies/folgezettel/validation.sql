-- Folgezettel lineage validation for Wendao Episteme.
--
-- This file is intentionally read-only. It assumes Wendao has already
-- assembled the request-scoped SQL surface and exposed parser-owned logical
-- views.

WITH sequence_nodes AS (
  SELECT
    path AS file_path,
    COALESCE(
      properties->>'SEQUENCE',
      properties->>'sequence',
      properties->>'FOLGEZETTEL',
      properties->>'folgezettel'
    ) AS sequence_id,
    property_drawer_start,
    property_drawer_end
  FROM repo_content_chunk
  WHERE doc_type = 'markdown'
),
normalized_sequences AS (
  SELECT
    file_path,
    sequence_id,
    regexp_replace(sequence_id, '[A-Za-z0-9]$', '') AS parent_sequence_id,
    COALESCE(property_drawer_start, 0) AS byte_start,
    COALESCE(property_drawer_end, 0) AS byte_end
  FROM sequence_nodes
  WHERE sequence_id IS NOT NULL
    AND sequence_id <> ''
),
broken_lineage AS (
  SELECT
    child.file_path,
    'FOLGEZETTEL_BROKEN_LINEAGE' AS violation_type,
    child.byte_start,
    child.byte_end,
    child.sequence_id AS current_sequence,
    child.parent_sequence_id AS related_sequence
  FROM normalized_sequences child
  LEFT JOIN normalized_sequences parent
    ON child.parent_sequence_id = parent.sequence_id
  WHERE child.parent_sequence_id <> ''
    AND parent.sequence_id IS NULL
),
duplicate_sequences AS (
  SELECT
    node.file_path,
    'FOLGEZETTEL_DUPLICATE_SEQUENCE' AS violation_type,
    node.byte_start,
    node.byte_end,
    node.sequence_id AS current_sequence,
    node.sequence_id AS related_sequence
  FROM normalized_sequences node
  JOIN (
    SELECT
      sequence_id
    FROM normalized_sequences
    GROUP BY sequence_id
    HAVING COUNT(DISTINCT file_path) > 1
  ) duplicate
    ON node.sequence_id = duplicate.sequence_id
),
invalid_sequences AS (
  SELECT
    file_path,
    'FOLGEZETTEL_INVALID_SEQUENCE' AS violation_type,
    byte_start,
    byte_end,
    sequence_id AS current_sequence,
    CAST(NULL AS VARCHAR) AS related_sequence
  FROM normalized_sequences
  WHERE NOT regexp_matches(sequence_id, '^[0-9]+[A-Za-z0-9]*$')
)
SELECT
  file_path,
  violation_type,
  byte_start,
  byte_end,
  current_sequence,
  related_sequence
FROM broken_lineage

UNION ALL

SELECT
  file_path,
  violation_type,
  byte_start,
  byte_end,
  current_sequence,
  related_sequence
FROM duplicate_sequences

UNION ALL

SELECT
  file_path,
  violation_type,
  byte_start,
  byte_end,
  current_sequence,
  related_sequence
FROM invalid_sequences;
