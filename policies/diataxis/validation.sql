-- Diátaxis document-kind validation for Wendao Episteme.
--
-- This file is intentionally read-only. Diátaxis is a closed ontology, so the
-- accepted values are part of this policy rather than a project-local manifest.
-- Wendao Episteme uses leading frontmatter metadata, not custom property
-- drawer syntax, as the portable document-level carrier. Diátaxis applies to
-- ordinary documentation records; parser-owned contract files such as SKILL.md
-- may use their own kind values.

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
    c.line_number,
    c.line_text
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
    ))) AS current_kind
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
    current_kind
  FROM (
    SELECT
      file_path,
      line_number,
      current_kind,
      row_number() OVER (PARTITION BY file_path ORDER BY line_number) AS kind_rank
    FROM kind_lines
  )
  WHERE kind_rank = 1
)
SELECT
  file_path,
  'INVALID_DOCUMENT_KIND' AS violation_type,
  line_number AS byte_start,
  line_number AS byte_end,
  current_kind
FROM first_kind
WHERE current_kind IS NOT NULL
  AND NOT regexp_matches(lower(file_path), '(^|/)skill[.]md$')
  AND lower(current_kind) NOT IN (
    'tutorial',
    'how-to',
    'explanation',
    'reference'
  );
