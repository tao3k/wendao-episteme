-- Search reasoning query-fragility validation for Wendao Episteme.
--
-- This file is intentionally read-only. It assumes Wendao has already
-- assembled the request-scoped SQL surface and exposed parser-owned logical
-- views.

WITH line_windows AS (
  SELECT
    path AS file_path,
    line_number,
    line_text,
    lower(COALESCE(line_text, '')) AS line_lower,
    lower(COALESCE(lead(line_text, 1) OVER line_scope, '')) AS next_1,
    lower(COALESCE(lead(line_text, 2) OVER line_scope, '')) AS next_2,
    lower(COALESCE(lead(line_text, 3) OVER line_scope, '')) AS next_3,
    lower(COALESCE(lead(line_text, 4) OVER line_scope, '')) AS next_4,
    lower(COALESCE(lead(line_text, 5) OVER line_scope, '')) AS next_5
  FROM repo_content_chunk
  WHERE doc_type = 'markdown'
  WINDOW line_scope AS (PARTITION BY path ORDER BY line_number)
),
query_fences AS (
  SELECT
    file_path,
    line_number,
    concat_ws(' ', line_lower, next_1, next_2, next_3, next_4, next_5) AS query_context
  FROM line_windows
  WHERE regexp_matches(line_lower, '^```(sql|duckdb|graphql)')
),
brittle_queries AS (
  SELECT
    file_path,
    'SEARCH_REASONING_BRITTLE_QUERY' AS violation_type,
    line_number AS byte_start,
    line_number AS byte_end,
    query_context
  FROM query_fences
  WHERE regexp_matches(
      query_context,
      '(^|[[:space:]])where[[:space:]]+([a-z_][a-z0-9_]*[.])?(path|file_path)[[:space:]]*='
    )
    OR regexp_matches(
      query_context,
      '(^|[[:space:]])(path|file_path)[[:space:]]*:[[:space:]]*["'']'
    )
),
code_symbol_references AS (
  SELECT DISTINCT
    ref.path AS file_path,
    ref.line AS byte_start,
    ref.line AS byte_end,
    ref.name AS current_reference
  FROM reference_occurrence ref
  JOIN local_symbol symbol
    ON ref.name = symbol.name
  WHERE ref.name NOT LIKE '%::%'
    AND ref.path <> symbol.path
),
brittle_uid_references AS (
  SELECT
    file_path,
    'SEARCH_REASONING_BRITTLE_UID' AS violation_type,
    byte_start,
    byte_end,
    current_reference AS query_context
  FROM code_symbol_references
)
SELECT
  file_path,
  violation_type,
  byte_start,
  byte_end,
  query_context
FROM brittle_queries

UNION ALL

SELECT
  file_path,
  violation_type,
  byte_start,
  byte_end,
  query_context
FROM brittle_uid_references;
