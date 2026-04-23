-- Epistemic conflict arbitration validation for Wendao Episteme.
--
-- This file is intentionally read-only. It assumes Wendao has already
-- assembled the request-scoped SQL surface and exposed parser-owned logical
-- views.

WITH content_nodes AS (
  SELECT
    path AS file_path,
    title,
    COALESCE(properties->>'ID', properties->>'id', title) AS node_id,
    CASE
      WHEN regexp_matches(COALESCE(properties->>'ID', properties->>'id', ''), '^[0-9]{2}[.][0-9]{2}')
        THEN substr(COALESCE(properties->>'ID', properties->>'id', ''), 1, 2)
      ELSE ''
    END AS jd_root,
    lower(COALESCE(properties->>'KIND', properties->>'kind', '')) AS node_kind,
    lower(COALESCE(properties->>'TYPE', properties->>'type', '')) AS node_type,
    lower(
      COALESCE(
        properties->>'INTENT',
        properties->>'intent',
        properties->>'DIATAXIS',
        properties->>'diataxis',
        ''
      )
    ) AS intent,
    upper(COALESCE(properties->>'STATUS', properties->>'status', '')) AS status,
    COALESCE(
      properties->>'SUPERSEDED_BY',
      properties->>'superseded_by',
      properties->>'Superseded-By',
      properties->>'superseded-by'
    ) AS superseded_by,
    COALESCE(property_drawer_start, 0) AS property_drawer_start,
    COALESCE(property_drawer_end, 0) AS property_drawer_end
  FROM repo_content_chunk
  WHERE doc_type = 'markdown'
),
resolved_edges AS (
  SELECT DISTINCT
    ref.path AS source_path,
    COALESCE(ref.line, 0) AS byte_start,
    COALESCE(ref.line, 0) AS byte_end,
    source.node_id AS source_id,
    source.jd_root AS source_root,
    target.file_path AS target_path,
    target.node_id AS target_id,
    target.jd_root AS target_root,
    lower(CAST(ref.hit_json AS VARCHAR)) AS edge_context
  FROM reference_occurrence ref
  JOIN content_nodes source
    ON ref.path = source.file_path
  JOIN content_nodes target
    ON ref.name = target.node_id
    OR ref.name = target.title
),
topology_vs_synthesis AS (
  SELECT
    source_path AS file_path,
    'CONFLICT_TOPOLOGY_VS_SYNTHESIS' AS violation_type,
    byte_start,
    byte_end,
    'topology-vs-synthesis' AS conflict_id,
    'johnny-decimal' AS primary_framework,
    'evergreen-notes' AS secondary_framework,
    'Keep the canonical address stable. Emit a repair recommendation or require an explicit move decision before relocation.' AS resolution,
    concat(source_id, ' -> ', target_id) AS current_context
  FROM resolved_edges
  WHERE source_root <> ''
    AND target_root <> ''
    AND source_root <> target_root
    AND (
      edge_context LIKE '%structural_relocation%'
      OR edge_context LIKE '%relocation%'
      OR edge_context LIKE '%move_suggestion%'
    )
),
decision_contract_vs_intent AS (
  SELECT
    file_path,
    'CONFLICT_DECISION_VS_INTENT' AS violation_type,
    property_drawer_start AS byte_start,
    property_drawer_end AS byte_end,
    'decision-contract-vs-intent' AS conflict_id,
    'adr' AS primary_framework,
    'diataxis' AS secondary_framework,
    'Preserve the ADR contract. Reclassify the intent layer or require a superseding decision record.' AS resolution,
    concat(node_id, ' intent=', intent) AS current_context
  FROM content_nodes
  WHERE (
      lower(file_path) LIKE '%/adr/%'
      OR node_type = 'adr'
    )
    AND intent IN ('tutorial', 'explanation')
),
deprecated_decision_reference AS (
  SELECT
    edge.source_path AS file_path,
    'CONFLICT_DEPRECATED_DECISION_REFERENCE' AS violation_type,
    edge.byte_start,
    edge.byte_end,
    'deprecated-decision-reference' AS conflict_id,
    'epistemic-sensemaking' AS primary_framework,
    'adr' AS secondary_framework,
    'Emit a disagreement diagnostic with provenance. Propose a contextual revision or supersession note before any write.' AS resolution,
    concat(edge.target_id, ' status=', target.status, ' superseded_by=', COALESCE(target.superseded_by, '')) AS current_context
  FROM resolved_edges edge
  JOIN content_nodes target
    ON edge.target_path = target.file_path
  WHERE (
      lower(target.file_path) LIKE '%/adr/%'
      OR target.node_type = 'adr'
    )
    AND target.status IN ('DEPRECATED', 'SUPERSEDED')
)
SELECT
  file_path,
  violation_type,
  byte_start,
  byte_end,
  conflict_id,
  primary_framework,
  secondary_framework,
  resolution,
  current_context
FROM topology_vs_synthesis

UNION ALL

SELECT
  file_path,
  violation_type,
  byte_start,
  byte_end,
  conflict_id,
  primary_framework,
  secondary_framework,
  resolution,
  current_context
FROM decision_contract_vs_intent

UNION ALL

SELECT
  file_path,
  violation_type,
  byte_start,
  byte_end,
  conflict_id,
  primary_framework,
  secondary_framework,
  resolution,
  current_context
FROM deprecated_decision_reference;
