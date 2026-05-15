-- SELECT-only read-model object projection from object observations.

SELECT
  object_id AS id,
  object_type AS kind,
  display_name AS title,
  'active' AS status,
  (
    SELECT count(*)
    FROM ontology_link_observation link
    WHERE link.source_object_id = object_obs.object_id
       OR link.target_object_id = object_obs.object_id
  ) AS relation_count,
  'fresh' AS read_model_projection_staleness
FROM ontology_object_observation object_obs
ORDER BY id
