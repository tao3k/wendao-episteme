-- Read-only L1 software engineering validation query.
--
-- Expected logical input view:
--   ontology_relation(source_id, target_id, predicate)
--
-- This query reports dependency cycles for software components. It is a policy
-- source artifact only; execution is owned by a downstream Wendao SQL surface.

WITH RECURSIVE dependency_edges AS (
  SELECT
    source_id,
    target_id
  FROM ontology_relation
  WHERE predicate = 'https://wendao.ai/ontology/core#dependsOn'
),
dependency_paths AS (
  SELECT
    source_id AS start_id,
    target_id AS current_id,
    1 AS depth,
    list_value(source_id, target_id) AS path_history
  FROM dependency_edges

  UNION ALL

  SELECT
    path.start_id,
    edge.target_id AS current_id,
    path.depth + 1 AS depth,
    list_append(path.path_history, edge.target_id) AS path_history
  FROM dependency_paths path
  JOIN dependency_edges edge
    ON path.current_id = edge.source_id
  WHERE path.depth < 32
    AND (
      edge.target_id = path.start_id
      OR NOT list_contains(path.path_history, edge.target_id)
    )
)
SELECT DISTINCT
  start_id,
  current_id,
  depth,
  CAST(path_history AS VARCHAR) AS cycle_path,
  'ONTOLOGY_DEPENDENCY_CYCLE' AS violation_type
FROM dependency_paths
WHERE depth > 1
  AND start_id = current_id;
