-- SELECT-only read-model object projection from object observations.

SELECT
  object_id AS id,
  object_type AS kind,
  display_name AS title,
  'active' AS status,
  CAST(1.0 AS DOUBLE) AS confidence_score,
  'dataset_ontology_mapping' AS confidence_source,
  CAST(0 AS BIGINT) AS owner_count,
  '[]' AS owners_json,
  source_table AS provenance_source,
  mapping_id AS provenance_recorded_by,
  source_hash AS provenance_recorded_at,
  '[]' AS verification_required_json,
  '[]' AS verification_evidence_json,
  (
    SELECT count(*)
    FROM ontology_link_observation link
    WHERE link.source_object_id = object_obs.object_id
       OR link.target_object_id = object_obs.object_id
  )::BIGINT AS relation_count,
  source_table AS source_path,
  mapping_id AS read_model_source_revision,
  mapping_id AS read_model_projection_revision,
  'fresh' AS read_model_projection_staleness
FROM ontology_object_observation object_obs
ORDER BY id
