-- Evergreen connectivity and atomicity validation for Wendao Episteme.
--
-- This file is intentionally read-only. It treats Evergreen Notes as graph
-- topology and atomic-size constraints, not as a prose-quality judgment.

WITH markdown_notes AS (
  SELECT
    path AS file_path,
    COALESCE(title, path) AS link_name,
    MAX(COALESCE(line_number, 0)) AS line_count
  FROM repo_content_chunk
  WHERE doc_type = 'markdown'
  GROUP BY path, COALESCE(title, path)
),
out_degree AS (
  SELECT
    path AS file_path,
    COUNT(*) AS edge_count
  FROM reference_occurrence
  GROUP BY path
),
in_degree AS (
  SELECT
    name AS link_name,
    COUNT(*) AS edge_count
  FROM reference_occurrence
  GROUP BY name
)
SELECT
  n.file_path,
  'EVERGREEN_ORPHAN' AS violation_type,
  0 AS byte_start,
  0 AS byte_end,
  'degree' AS current_metric_name,
  COALESCE(o.edge_count, 0) + COALESCE(i.edge_count, 0) AS current_metric_value
FROM markdown_notes n
LEFT JOIN out_degree o ON n.file_path = o.file_path
LEFT JOIN in_degree i ON n.link_name = i.link_name
WHERE COALESCE(o.edge_count, 0) = 0
  AND COALESCE(i.edge_count, 0) = 0

UNION ALL

SELECT
  n.file_path,
  'EVERGREEN_BLOATED' AS violation_type,
  0 AS byte_start,
  0 AS byte_end,
  'line_count' AS current_metric_name,
  n.line_count AS current_metric_value
FROM markdown_notes n
WHERE n.line_count > 300;
