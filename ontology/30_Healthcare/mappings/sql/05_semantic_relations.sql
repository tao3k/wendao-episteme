-- SELECT-only read-model relation projection from link observations.

SELECT
  source_object_id AS source,
  link_type AS kind,
  target_object_id AS target,
  'fresh' AS read_model_projection_staleness
FROM ontology_link_observation
ORDER BY source, kind, target
