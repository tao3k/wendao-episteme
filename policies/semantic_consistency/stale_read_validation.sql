-- Semantic consistency stale-read validation for Wendao Episteme.
--
-- This file is intentionally read-only. It assumes Wendao has already
-- assembled the request-scoped SQL surface and exposed a consumer-owned
-- content fingerprint view.

WITH agent_generated_notes AS (
  SELECT
    path AS file_path,
    COALESCE(property_drawer_start, 0) AS byte_start,
    COALESCE(property_drawer_end, 0) AS byte_end,
    COALESCE(
      properties->>'DEPENDS_ON_FILE',
      properties->>'depends_on_file',
      json_extract_string(properties, '$.metadata.dependencies.file'),
      json_extract_string(properties, '$.metadata.depends_on.file')
    ) AS dependency_path,
    COALESCE(
      properties->>'DEPENDS_ON_HASH',
      properties->>'depends_on_hash',
      json_extract_string(properties, '$.metadata.dependencies.hash'),
      json_extract_string(properties, '$.metadata.depends_on.hash')
    ) AS recorded_hash
  FROM repo_content_chunk
  WHERE doc_type = 'markdown'
    AND lower(
      COALESCE(
        properties->>'MAINTAINER',
        properties->>'maintainer',
        json_extract_string(properties, '$.metadata.maintainer'),
        json_extract_string(properties, '$.metadata.agent.maintainer'),
        ''
      )
    ) = 'agent'
)
SELECT
  agent.file_path,
  'CONSISTENCY_STALE_READ_DETECTED' AS violation_type,
  agent.byte_start,
  agent.byte_end,
  agent.dependency_path,
  agent.recorded_hash,
  live.content_hash AS live_hash
FROM agent_generated_notes agent
JOIN project_content_fingerprint live
  ON agent.dependency_path = live.path
WHERE agent.dependency_path IS NOT NULL
  AND agent.recorded_hash IS NOT NULL
  AND agent.recorded_hash <> live.content_hash;
