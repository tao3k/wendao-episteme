-- Structural Proprioception cycle validation for Wendao Episteme.
--
-- This file is intentionally read-only. It assumes Wendao has already
-- assembled the request-scoped SQL surface and exposed parser-owned logical
-- views.

WITH RECURSIVE graph_nodes AS (
  SELECT DISTINCT
    path AS file_path,
    title,
    COALESCE(properties->>'ID', properties->>'id', title) AS node_id
  FROM repo_content_chunk
  WHERE doc_type = 'markdown'
),
resolved_edges AS (
  SELECT DISTINCT
    ref.path AS source_path,
    target.file_path AS target_path,
    ref.name AS reference_name
  FROM reference_occurrence ref
  JOIN graph_nodes target
    ON ref.name = target.node_id
    OR ref.name = target.title
  WHERE ref.path <> target.file_path
),
link_paths AS (
  SELECT
    source_path AS start_node,
    target_path AS current_node,
    1 AS depth,
    list_value(source_path, target_path) AS path_history
  FROM resolved_edges

  UNION ALL

  SELECT
    path.start_node,
    edge.target_path AS current_node,
    path.depth + 1 AS depth,
    list_append(path.path_history, edge.target_path) AS path_history
  FROM link_paths path
  JOIN resolved_edges edge
    ON path.current_node = edge.source_path
  WHERE path.depth < 5
    AND (
      edge.target_path = path.start_node
      OR NOT list_contains(path.path_history, edge.target_path)
    )
),
cycles AS (
  SELECT DISTINCT
    start_node AS file_path,
    'PROPRIOCEPTION_CIRCULAR_DEPENDENCY' AS violation_type,
    0 AS byte_start,
    0 AS byte_end,
    CAST(path_history AS VARCHAR) AS current_context,
    depth AS current_metric_value
  FROM link_paths
  WHERE depth > 1
    AND start_node = current_node
),
doc_observations AS (
  SELECT
    path AS file_path,
    trim(observed_symbol) AS observed_symbol,
    COALESCE(property_drawer_start, 0) AS byte_start,
    COALESCE(property_drawer_end, 0) AS byte_end
  FROM repo_content_chunk,
    unnest(
      string_split(
        COALESCE(properties->>'OBSERVE', properties->>'observe'),
        ','
      )
    ) AS observed(observed_symbol)
  WHERE doc_type = 'markdown'
    AND COALESCE(properties->>'OBSERVE', properties->>'observe') IS NOT NULL
),
semantic_drift AS (
  SELECT
    observation.file_path,
    'PROPRIOCEPTION_SEMANTIC_DRIFT' AS violation_type,
    observation.byte_start,
    observation.byte_end,
    observation.observed_symbol AS current_context,
    1 AS current_metric_value
  FROM doc_observations observation
  LEFT JOIN local_symbol symbol
    ON lower(observation.observed_symbol) = lower(symbol.name)
    OR lower(observation.observed_symbol) LIKE concat('%', lower(symbol.name), '%')
    OR lower(symbol.signature) LIKE concat('%', lower(observation.observed_symbol), '%')
  WHERE observation.observed_symbol <> ''
    AND symbol.name IS NULL
)
SELECT
  file_path,
  violation_type,
  byte_start,
  byte_end,
  current_context,
  current_metric_value
FROM cycles

UNION ALL

SELECT
  file_path,
  violation_type,
  byte_start,
  byte_end,
  current_context,
  current_metric_value
FROM semantic_drift;
