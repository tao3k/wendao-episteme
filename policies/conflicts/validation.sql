-- Epistemic conflict arbitration validation for Wendao Episteme.
--
-- This file is intentionally read-only. It assumes Wendao has already
-- assembled the request-scoped SQL surface and exposed parser-owned logical
-- views.

WITH content_nodes AS (
  SELECT
    path AS file_path,
    title,
    COALESCE(
      properties->>'ID',
      properties->>'id',
      json_extract_string(properties, '$.metadata.id'),
      json_extract_string(properties, '$.metadata.adr.id'),
      title
    ) AS node_id,
    CASE
      WHEN regexp_matches(
        COALESCE(
          properties->>'ID',
          properties->>'id',
          json_extract_string(properties, '$.metadata.id'),
          json_extract_string(properties, '$.metadata.johnny_decimal.coordinate'),
          ''
        ),
        '^[0-9]{2}[.][0-9]{2}'
      )
        THEN substr(
          COALESCE(
            properties->>'ID',
            properties->>'id',
            json_extract_string(properties, '$.metadata.id'),
            json_extract_string(properties, '$.metadata.johnny_decimal.coordinate')
          ),
          1,
          2
        )
      ELSE ''
    END AS jd_root,
    lower(COALESCE(
      properties->>'KIND',
      properties->>'kind',
      json_extract_string(properties, '$.metadata.kind'),
      ''
    )) AS node_kind,
    lower(COALESCE(
      properties->>'TYPE',
      properties->>'type',
      json_extract_string(properties, '$.metadata.type'),
      json_extract_string(properties, '$.metadata.adr.type'),
      json_extract_string(properties, '$.metadata.ibis.type'),
      ''
    )) AS node_type,
    upper(COALESCE(
      properties->>'STATUS',
      properties->>'status',
      json_extract_string(properties, '$.metadata.status'),
      json_extract_string(properties, '$.metadata.lifecycle.status'),
      json_extract_string(properties, '$.metadata.adr.status'),
      ''
    )) AS status,
    COALESCE(
      properties->>'SUPERSEDED_BY',
      properties->>'superseded_by',
      properties->>'Superseded-By',
      properties->>'superseded-by',
      json_extract_string(properties, '$.metadata.superseded_by'),
      json_extract_string(properties, '$.metadata.adr.superseded_by')
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
decision_contract_vs_document_kind AS (
  SELECT
    file_path,
    'CONFLICT_DECISION_VS_DOCUMENT_KIND' AS violation_type,
    property_drawer_start AS byte_start,
    property_drawer_end AS byte_end,
    'decision-contract-vs-document-kind' AS conflict_id,
    'adr' AS primary_framework,
    'diataxis' AS secondary_framework,
    'Preserve the ADR contract. Reclassify the document kind or require a superseding decision record.' AS resolution,
    concat(node_id, ' document_kind=', node_kind) AS current_context
  FROM content_nodes
  WHERE (
      lower(file_path) LIKE '%/adr/%'
      OR node_type = 'adr'
    )
    AND node_kind IN ('tutorial', 'explanation')
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
FROM decision_contract_vs_document_kind

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
