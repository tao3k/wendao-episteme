-- Optional Diátaxis path-kind validation for Wendao Episteme.
--
-- This file is intentionally read-only. It requires the consumer to expose a
-- request-scoped `project_diataxis_path_rule` view. The policy repository does
-- not hard-code project path semantics. It applies only to ordinary
-- documentation records, not parser-owned contract files such as SKILL.md.

WITH first_lines AS (
  SELECT
    path AS file_path,
    min(line_number) AS first_line_number
  FROM repo_content_chunk
  WHERE lower(language) = 'markdown'
  GROUP BY path
),
frontmatter_start AS (
  SELECT
    c.path AS file_path,
    c.line_number AS start_line
  FROM repo_content_chunk c
  JOIN first_lines f
    ON c.path = f.file_path
   AND c.line_number = f.first_line_number
  WHERE lower(c.language) = 'markdown'
    AND trim(c.line_text) = '---'
),
frontmatter_bounds AS (
  SELECT
    s.file_path,
    s.start_line,
    min(c.line_number) AS end_line
  FROM frontmatter_start s
  JOIN repo_content_chunk c
    ON c.path = s.file_path
   AND c.line_number > s.start_line
  WHERE lower(c.language) = 'markdown'
    AND trim(c.line_text) = '---'
  GROUP BY s.file_path, s.start_line
),
frontmatter_lines AS (
  SELECT
    c.path AS file_path,
    line_number,
    line_text
  FROM repo_content_chunk c
  JOIN frontmatter_bounds b
    ON c.path = b.file_path
   AND c.line_number > b.start_line
   AND c.line_number < b.end_line
  WHERE lower(c.language) = 'markdown'
),
kind_lines AS (
  SELECT
    file_path,
    line_number,
    lower(trim(regexp_extract(
      line_text,
      '^[[:space:]]*kind[[:space:]]*:[[:space:]]*(.+)$',
      1
    ))) AS normalized_kind
  FROM frontmatter_lines
  WHERE regexp_matches(
      lower(line_text),
      '^[[:space:]]*kind[[:space:]]*:'
    )
),
first_kind AS (
  SELECT
    file_path,
    line_number,
    normalized_kind
  FROM (
    SELECT
      file_path,
      line_number,
      normalized_kind,
      row_number() OVER (PARTITION BY file_path ORDER BY line_number) AS kind_rank
    FROM kind_lines
  )
  WHERE kind_rank = 1
)
SELECT
  c.file_path,
  'DIATAXIS_PATH_CONFLICT' AS violation_type,
  c.line_number AS byte_start,
  c.line_number AS byte_end,
  c.normalized_kind AS current_kind,
  r.path_pattern AS path_pattern
FROM first_kind c
JOIN project_diataxis_path_rule r
  ON c.file_path LIKE r.path_pattern
WHERE c.normalized_kind = lower(r.disallowed_kind)
  AND NOT regexp_matches(lower(c.file_path), '(^|/)skill[.]md$');
