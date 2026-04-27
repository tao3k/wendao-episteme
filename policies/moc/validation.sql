-- MOC navigation hub validation for Wendao Episteme.
--
-- This file is intentionally read-only. It assumes Wendao has already
-- assembled the request-scoped SQL surface and exposed parser-owned logical
-- views.

WITH raw_content_nodes AS (
  SELECT
    path AS file_path,
    lower(
      COALESCE(
        properties->>'MOC_ROLE',
        properties->>'moc_role',
        json_extract_string(properties, '$.metadata.moc.role'),
        ''
      )
    ) AS moc_role,
    COALESCE(
      NULLIF(
        regexp_extract(COALESCE(properties->>'JD_CATEGORY', properties->>'jd_category'), '^([0-9]{2})', 1),
        ''
      ),
      NULLIF(
        regexp_extract(
          json_extract_string(properties, '$.metadata.johnny_decimal.category'),
          '^([0-9]{2})',
          1
        ),
        ''
      ),
      NULLIF(
        regexp_extract(COALESCE(properties->>'ID', properties->>'id', ''), '^([0-9]{2})[.][0-9]{2}', 1),
        ''
      ),
      NULLIF(
        regexp_extract(path, '(^|/)([0-9]{2})[_-][^/]+/', 2),
        ''
      ),
      NULLIF(
        regexp_extract(path, '(^|/)([0-9]{2})[.][0-9]{2}[^/]*[.]md$', 2),
        ''
      )
    ) AS scope_id,
    property_drawer_end
  FROM repo_content_chunk
  WHERE doc_type = 'markdown'
),
content_nodes AS (
  SELECT
    file_path,
    scope_id,
    property_drawer_end,
    moc_role IN ('moc', 'hub', 'route_hub')
      OR regexp_matches(lower(file_path), '(^|/)[0-9]{2}[.]00[^/]*[.]md$') AS is_moc
  FROM raw_content_nodes
),
category_counts AS (
  SELECT
    scope_id,
    MIN(file_path) AS sample_file_path,
    COUNT(DISTINCT file_path) AS note_count
  FROM content_nodes
  WHERE scope_id IS NOT NULL
    AND NOT is_moc
  GROUP BY scope_id
),
moc_scopes AS (
  SELECT DISTINCT scope_id
  FROM content_nodes
  WHERE scope_id IS NOT NULL
    AND is_moc
),
density_without_moc AS (
  SELECT
    sample_file_path AS file_path,
    'MOC_REQUIRED_FOR_DENSITY' AS violation_type,
    0 AS byte_start,
    0 AS byte_end,
    category.scope_id,
    'note_count' AS current_metric_name,
    note_count AS current_metric_value
  FROM category_counts category
  LEFT JOIN moc_scopes moc
    ON category.scope_id = moc.scope_id
  WHERE category.note_count > 15
    AND moc.scope_id IS NULL
),
moc_out_degree AS (
  SELECT
    moc.file_path,
    COALESCE(moc.property_drawer_end, 0) AS byte_start,
    COALESCE(moc.property_drawer_end, 0) AS byte_end,
    moc.scope_id,
    COUNT(DISTINCT out_ref.name) AS out_degree
  FROM content_nodes moc
  LEFT JOIN reference_occurrence out_ref
    ON moc.file_path = out_ref.path
  WHERE moc.is_moc
  GROUP BY
    moc.file_path,
    moc.property_drawer_end,
    moc.scope_id
),
empty_hubs AS (
  SELECT
    file_path,
    'MOC_EMPTY_HUB' AS violation_type,
    byte_start,
    byte_end,
    scope_id,
    'out_degree' AS current_metric_name,
    out_degree AS current_metric_value
  FROM moc_out_degree
  WHERE out_degree < 3
)
SELECT
  file_path,
  violation_type,
  byte_start,
  byte_end,
  scope_id,
  current_metric_name,
  current_metric_value
FROM density_without_moc

UNION ALL

SELECT
  file_path,
  violation_type,
  byte_start,
  byte_end,
  scope_id,
  current_metric_name,
  current_metric_value
FROM empty_hubs;
