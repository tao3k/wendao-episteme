-- IBIS argumentation graph validation for Wendao Episteme.
--
-- This file is intentionally read-only. It assumes Wendao has already
-- assembled the request-scoped SQL surface and exposed parser-owned logical
-- views.

WITH ibis_nodes AS (
  SELECT
    path AS file_path,
    title,
    COALESCE(
      NULLIF(properties->>'ID', ''),
      NULLIF(properties->>'id', ''),
      NULLIF(json_extract_string(properties, '$.metadata.ibis.id'), ''),
      title
    ) AS node_id,
    lower(
      COALESCE(
        NULLIF(properties->>'IBIS_TYPE', ''),
        NULLIF(properties->>'ibis_type', ''),
        NULLIF(json_extract_string(properties, '$.metadata.ibis.type'), ''),
        ''
      )
    ) AS ibis_type,
    COALESCE(
      NULLIF(properties->>'ISSUE', ''),
      NULLIF(properties->>'issue', ''),
      NULLIF(properties->>'TARGET_ISSUE', ''),
      NULLIF(properties->>'target_issue', ''),
      NULLIF(json_extract_string(properties, '$.metadata.ibis.issue'), ''),
      NULLIF(json_extract_string(properties, '$.metadata.ibis.target_issue'), '')
    ) AS target_issue,
    COALESCE(property_drawer_start, 0) AS byte_start,
    COALESCE(property_drawer_end, 0) AS byte_end
  FROM repo_content_chunk
  WHERE doc_type = 'markdown'
    AND COALESCE(
      NULLIF(properties->>'IBIS_TYPE', ''),
      NULLIF(properties->>'ibis_type', ''),
      NULLIF(json_extract_string(properties, '$.metadata.ibis.type'), '')
    ) IS NOT NULL
),
issues AS (
  SELECT *
  FROM ibis_nodes
  WHERE ibis_type = 'issue'
),
positions AS (
  SELECT *
  FROM ibis_nodes
  WHERE ibis_type = 'position'
),
invalid_node_types AS (
  SELECT
    file_path,
    'IBIS_INVALID_NODE_TYPE' AS violation_type,
    byte_start,
    byte_end,
    node_id AS ibis_node_id,
    ibis_type AS related_id,
    0 AS current_metric_value
  FROM ibis_nodes
  WHERE ibis_type NOT IN (
    'argument',
    'issue',
    'model_problem',
    'position',
    'question',
    'question_of_fact',
    'topic'
  )
),
position_issue_links AS (
  SELECT DISTINCT
    issue.file_path AS issue_file_path,
    position.file_path AS position_file_path
  FROM issues issue
  JOIN positions position
    ON position.target_issue = issue.node_id
    OR position.target_issue = issue.title

  UNION

  SELECT DISTINCT
    issue.file_path AS issue_file_path,
    position.file_path AS position_file_path
  FROM issues issue
  JOIN reference_occurrence ref
    ON ref.name = issue.node_id
    OR ref.name = issue.title
  JOIN positions position
    ON position.file_path = ref.path
),
position_counts AS (
  SELECT
    issue_file_path,
    COUNT(DISTINCT position_file_path) AS position_count
  FROM position_issue_links
  GROUP BY issue_file_path
),
unresolved_issues AS (
  SELECT
    issue.file_path,
    'IBIS_UNRESOLVED_ISSUE' AS violation_type,
    issue.byte_start,
    issue.byte_end,
    issue.node_id AS ibis_node_id,
    CAST(NULL AS VARCHAR) AS related_id,
    COALESCE(counts.position_count, 0) AS current_metric_value
  FROM issues issue
  LEFT JOIN position_counts counts
    ON issue.file_path = counts.issue_file_path
  WHERE COALESCE(counts.position_count, 0) = 0
),
dangling_positions AS (
  SELECT
    position.file_path,
    'IBIS_DANGLING_POSITION' AS violation_type,
    position.byte_start,
    position.byte_end,
    position.node_id AS ibis_node_id,
    position.target_issue AS related_id,
    0 AS current_metric_value
  FROM positions position
  LEFT JOIN issues issue
    ON position.target_issue = issue.node_id
    OR position.target_issue = issue.title
  WHERE position.target_issue IS NOT NULL
    AND issue.node_id IS NULL
)
SELECT
  file_path,
  violation_type,
  byte_start,
  byte_end,
  ibis_node_id,
  related_id,
  current_metric_value
FROM unresolved_issues

UNION ALL

SELECT
  file_path,
  violation_type,
  byte_start,
  byte_end,
  ibis_node_id,
  related_id,
  current_metric_value
FROM invalid_node_types

UNION ALL

SELECT
  file_path,
  violation_type,
  byte_start,
  byte_end,
  ibis_node_id,
  related_id,
  current_metric_value
FROM dangling_positions;
