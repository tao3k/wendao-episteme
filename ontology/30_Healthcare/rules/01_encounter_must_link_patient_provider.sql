-- Read-only L1 healthcare validation query.
--
-- Expected logical input views:
--   ontology_entity(entity_id, class_iri)
--   ontology_relation(source_id, target_id, predicate)
--
-- Reports encounters that are not linked from a patient or provider action.

WITH encounters AS (
  SELECT entity_id
  FROM ontology_entity
  WHERE class_iri = 'https://wendao.ai/ontology/healthcare#Encounter'
),
patient_links AS (
  SELECT DISTINCT target_id
  FROM ontology_relation
  WHERE predicate = 'https://wendao.ai/ontology/healthcare#hasEncounter'
),
provider_links AS (
  SELECT DISTINCT target_id
  FROM ontology_relation
  WHERE predicate = 'https://wendao.ai/ontology/core#performs'
)
SELECT
  encounter.entity_id,
  'HEALTHCARE_ENCOUNTER_MISSING_CONTEXT' AS violation_type
FROM encounters encounter
LEFT JOIN patient_links patient
  ON encounter.entity_id = patient.target_id
LEFT JOIN provider_links provider
  ON encounter.entity_id = provider.target_id
WHERE patient.target_id IS NULL
   OR provider.target_id IS NULL;
