-- ADR state and reference validation for Wendao Episteme.
--
-- This file is intentionally read-only. It assumes Wendao has already
-- assembled the request-scoped SQL surface and exposed parser-owned logical
-- views. ADR status may be represented as a normalized lifecycle value or as a
-- MADR-style inline value such as `superseded by ADR-0123`.

WITH raw_adr_nodes AS (
  SELECT
    path AS file_path,
    title AS adr_title,
    COALESCE(properties->>'ID', properties->>'id', title) AS adr_id,
    COALESCE(properties->>'STATUS', properties->>'status') AS raw_status,
    COALESCE(
      properties->>'SUPERSEDED_BY',
      properties->>'superseded_by',
      properties->>'Superseded-By',
      properties->>'superseded-by'
    ) AS superseded_by,
    property_drawer_start,
    property_drawer_end
  FROM repo_content_chunk
  WHERE doc_type = 'markdown'
    AND (
      lower(path) LIKE '%/adr/%'
      OR upper(COALESCE(properties->>'TYPE', properties->>'type', '')) = 'ADR'
    )
),
adr_nodes AS (
  SELECT
    file_path,
    adr_title,
    adr_id,
    CASE
      WHEN upper(raw_status) LIKE 'SUPERSEDED BY %' THEN 'SUPERSEDED'
      ELSE upper(raw_status)
    END AS adr_status,
    COALESCE(
      superseded_by,
      nullif(regexp_extract(raw_status, '^[Ss][Uu][Pp][Ee][Rr][Ss][Ee][Dd][Ee][Dd][[:space:]]+[Bb][Yy][[:space:]]+(.+)$', 1), '')
    ) AS superseded_by,
    property_drawer_start,
    property_drawer_end
  FROM raw_adr_nodes
),
expired_adr_references AS (
  SELECT
    ref.path AS file_path,
    'ADR_EXPIRED_REFERENCE' AS violation_type,
    0 AS byte_start,
    0 AS byte_end,
    adr.adr_id AS target_adr_id,
    adr.adr_status AS target_adr_status,
    adr.superseded_by AS replacement_adr_id
  FROM reference_occurrence ref
  JOIN adr_nodes adr
    ON ref.name = adr.adr_id
    OR ref.name = adr.adr_title
  WHERE adr.adr_status IN ('DEPRECATED', 'SUPERSEDED')
),
broken_state_machine AS (
  SELECT
    file_path,
    'ADR_STATE_MACHINE_BROKEN' AS violation_type,
    COALESCE(property_drawer_start, 0) AS byte_start,
    COALESCE(property_drawer_end, 0) AS byte_end,
    adr_id AS target_adr_id,
    adr_status AS target_adr_status,
    superseded_by AS replacement_adr_id
  FROM adr_nodes
  WHERE adr_status = 'SUPERSEDED'
    AND superseded_by IS NULL
),
invalid_status AS (
  SELECT
    file_path,
    'ADR_INVALID_STATUS' AS violation_type,
    COALESCE(property_drawer_start, 0) AS byte_start,
    COALESCE(property_drawer_end, 0) AS byte_end,
    adr_id AS target_adr_id,
    adr_status AS target_adr_status,
    superseded_by AS replacement_adr_id
  FROM adr_nodes
  WHERE adr_status IS NULL
    OR adr_status NOT IN (
      'PROPOSED',
      'REJECTED',
      'ACCEPTED',
      'ACTIVE',
      'DEPRECATED',
      'SUPERSEDED'
    )
)
SELECT
  file_path,
  violation_type,
  byte_start,
  byte_end,
  target_adr_id,
  target_adr_status,
  replacement_adr_id
FROM expired_adr_references

UNION ALL

SELECT
  file_path,
  violation_type,
  byte_start,
  byte_end,
  target_adr_id,
  target_adr_status,
  replacement_adr_id
FROM broken_state_machine

UNION ALL

SELECT
  file_path,
  violation_type,
  byte_start,
  byte_end,
  target_adr_id,
  target_adr_status,
  replacement_adr_id
FROM invalid_status;
