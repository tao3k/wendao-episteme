-- SELECT-only read-model projection state for the synthetic healthcare mapping.

SELECT
  'healthcare.synthetic_care_delivery.v1' AS projection,
  'active' AS status,
  'healthcare.synthetic_care_delivery.v1' AS source_revision,
  'healthcare.synthetic_care_delivery.v1' AS current_source_revision,
  'healthcare.synthetic_care_delivery.v1' AS projection_revision,
  'fresh' AS staleness,
  CAST(count(*) AS BIGINT) AS source_object_count,
  '[]' AS source_objects_json,
  'ontology_object_observation' AS source_path
FROM ontology_object_observation
