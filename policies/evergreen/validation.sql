-- Evergreen connectivity and atomicity validation for Wendao Episteme.
--
-- This file is intentionally read-only. It treats Evergreen Notes as graph
-- topology and atomic-size constraints, not as a prose-quality judgment.

WITH markdown_lines AS (
  SELECT
    path AS file_path,
    line_number,
    line_text,
    title
  FROM repo_content_chunk
  WHERE doc_type = 'markdown'
),
markdown_notes AS (
  SELECT
    file_path,
    COALESCE(title, file_path) AS link_name,
    MAX(COALESCE(line_number, 0)) AS line_count
  FROM markdown_lines
  GROUP BY file_path, COALESCE(title, file_path)
),
relation_markers AS (
  SELECT
    file_path,
    line_number AS relation_start
  FROM markdown_lines
  WHERE trim(line_text) = ':RELATIONS:'
),
relation_ranges AS (
  SELECT
    marker.file_path,
    marker.relation_start,
    COALESCE(MIN(block_end.line_number), marker.relation_start + 16) AS relation_end
  FROM relation_markers marker
  LEFT JOIN markdown_lines block_end
    ON block_end.file_path = marker.file_path
   AND block_end.line_number > marker.relation_start
   AND trim(block_end.line_text) = ':END:'
  GROUP BY marker.file_path, marker.relation_start
),
relation_blocks AS (
  SELECT
    block.file_path,
    block.relation_start,
    block.relation_end,
    SUM(
      CASE
        WHEN line.line_text LIKE '%[[%' THEN 1
        ELSE 0
      END
    ) AS wiki_link_count
  FROM relation_ranges block
  LEFT JOIN markdown_lines line
    ON line.file_path = block.file_path
   AND line.line_number >= block.relation_start
   AND line.line_number <= block.relation_end
  GROUP BY block.file_path, block.relation_start, block.relation_end
),
relation_summary AS (
  SELECT
    file_path,
    MIN(relation_start) AS relation_start,
    MAX(relation_end) AS relation_end,
    COALESCE(SUM(wiki_link_count), 0) AS wiki_link_count,
    COUNT(*) AS relation_block_count
  FROM relation_blocks
  GROUP BY file_path
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
),
connectivity AS (
  SELECT
    n.file_path,
    n.line_count,
    COALESCE(o.edge_count, 0) + COALESCE(i.edge_count, 0) AS total_degree,
    relation.relation_start,
    relation.relation_end,
    COALESCE(relation.wiki_link_count, 0) AS wiki_link_count,
    CASE
      WHEN COALESCE(relation.relation_block_count, 0) = 0 THEN 'missing_relation_block'
      WHEN COALESCE(relation.wiki_link_count, 0) = 0 THEN 'empty_relation_block'
      ELSE 'present_relation_block'
    END AS relation_block_state
  FROM markdown_notes n
  LEFT JOIN out_degree o ON n.file_path = o.file_path
  LEFT JOIN in_degree i ON n.link_name = i.link_name
  LEFT JOIN relation_summary relation ON n.file_path = relation.file_path
),
orphan_missing_relation_block AS (
  SELECT
    file_path,
    'EVERGREEN_ORPHAN_MISSING_RELATION_BLOCK' AS violation_type,
    line_count AS byte_start,
    line_count AS byte_end,
    'degree' AS current_metric_name,
    total_degree AS current_metric_value,
    relation_block_state
  FROM connectivity
  WHERE total_degree = 0
    AND relation_block_state = 'missing_relation_block'
),
empty_relation_blocks AS (
  SELECT
    file_path,
    'EVERGREEN_EMPTY_RELATION_BLOCK' AS violation_type,
    relation_start AS byte_start,
    relation_end AS byte_end,
    'relation_links' AS current_metric_name,
    wiki_link_count AS current_metric_value,
    relation_block_state
  FROM connectivity
  WHERE relation_block_state = 'empty_relation_block'
),
bloated_notes AS (
  SELECT
    file_path,
    'EVERGREEN_BLOATED' AS violation_type,
    0 AS byte_start,
    line_count AS byte_end,
    'line_count' AS current_metric_name,
    line_count AS current_metric_value,
    relation_block_state
  FROM connectivity
  WHERE line_count > 300
)
SELECT
  file_path,
  violation_type,
  byte_start,
  byte_end,
  current_metric_name,
  current_metric_value,
  relation_block_state
FROM orphan_missing_relation_block

UNION ALL

SELECT
  file_path,
  violation_type,
  byte_start,
  byte_end,
  current_metric_name,
  current_metric_value,
  relation_block_state
FROM empty_relation_blocks

UNION ALL

SELECT
  file_path,
  violation_type,
  byte_start,
  byte_end,
  current_metric_name,
  current_metric_value,
  relation_block_state
FROM bloated_notes;
