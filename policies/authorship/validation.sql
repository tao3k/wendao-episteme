-- Temporal Scaffolding authorship-boundary validation for Wendao Episteme.
--
-- This file is intentionally read-only. It assumes the write planner has
-- exposed attempted repair payloads and parser-owned byte-zone classifications
-- as request-scoped logical views.

WITH allowed_zones(zone_kind) AS (
  VALUES
    ('metadata_drawer'),
    ('relation_block'),
    ('footer_block'),
    ('sentinel_reported_governed_range')
),
attempts AS (
  SELECT
    file_path,
    attempted_start,
    attempted_end,
    COALESCE(provenance, '') AS provenance,
    COALESCE(remediation_class, '') AS remediation_class
  FROM repair_payload_target
),
contained_allowed_zones AS (
  SELECT
    attempt.file_path,
    attempt.attempted_start,
    attempt.attempted_end,
    zone.zone_kind
  FROM attempts attempt
  JOIN parser_byte_zone zone
    ON attempt.file_path = zone.file_path
   AND attempt.attempted_start >= zone.byte_start
   AND attempt.attempted_end <= zone.byte_end
  JOIN allowed_zones allowed
    ON zone.zone_kind = allowed.zone_kind
),
overlapping_zones AS (
  SELECT
    attempt.file_path,
    attempt.attempted_start,
    attempt.attempted_end,
    string_agg(DISTINCT zone.zone_kind, ',') AS attempted_zone
  FROM attempts attempt
  LEFT JOIN parser_byte_zone zone
    ON attempt.file_path = zone.file_path
   AND attempt.attempted_start < zone.byte_end
   AND attempt.attempted_end > zone.byte_start
  GROUP BY
    attempt.file_path,
    attempt.attempted_start,
    attempt.attempted_end
)
SELECT
  attempt.file_path,
  'AUTHORSHIP_BOUNDARY_VIOLATION' AS violation_type,
  attempt.attempted_start,
  attempt.attempted_end,
  COALESCE(overlap.attempted_zone, 'unknown') AS attempted_zone,
  'metadata_drawer,relation_block,footer_block,sentinel_reported_governed_range' AS allowed_zones,
  'authorship-vs-structural-repair' AS conflict_id,
  attempt.provenance,
  attempt.remediation_class
FROM attempts attempt
LEFT JOIN contained_allowed_zones allowed
  ON attempt.file_path = allowed.file_path
 AND attempt.attempted_start = allowed.attempted_start
 AND attempt.attempted_end = allowed.attempted_end
LEFT JOIN overlapping_zones overlap
  ON attempt.file_path = overlap.file_path
 AND attempt.attempted_start = overlap.attempted_start
 AND attempt.attempted_end = overlap.attempted_end
WHERE allowed.file_path IS NULL;
