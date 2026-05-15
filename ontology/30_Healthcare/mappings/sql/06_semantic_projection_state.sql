-- SELECT-only read-model projection state for the synthetic healthcare mapping.

SELECT
  'healthcare.synthetic_care_delivery.v1' AS projection,
  'active' AS status,
  'fresh' AS staleness,
  count(*) AS source_object_count
FROM ontology_object_observation
