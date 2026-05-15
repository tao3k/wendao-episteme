-- SELECT-only mapping from synthetic raw healthcare rows to ontology relations.

WITH link_rows AS (
  SELECT
    'healthcare.synthetic_care_delivery.v1' AS mapping_id,
    'episteme://30_Healthcare' AS domain,
    'Patient.encounters' AS link_type,
    'https://wendao.ai/ontology/healthcare#hasEncounter' AS rdf_property,
    'healthcare://Patient/' || patient_id AS source_object_id,
    'healthcare://Encounter/' || encounter_id AS target_object_id,
    'raw_encounters' AS source_table,
    encounter_id AS source_row_id,
    sha256('hasEncounter|' || patient_id || '|' || encounter_id || '|' || source_system) AS source_hash
  FROM raw_encounters
  UNION ALL
  SELECT
    'healthcare.synthetic_care_delivery.v1',
    'episteme://30_Healthcare',
    'CareProvider.performsEncounter',
    'https://wendao.ai/ontology/core#performs',
    'healthcare://CareProvider/' || provider_id,
    'healthcare://Encounter/' || encounter_id,
    'raw_encounters',
    encounter_id,
    sha256('performs|' || provider_id || '|' || encounter_id || '|' || source_system)
  FROM raw_encounters
  UNION ALL
  SELECT
    'healthcare.synthetic_care_delivery.v1',
    'episteme://30_Healthcare',
    'Patient.conditions',
    'https://wendao.ai/ontology/healthcare#diagnosedWith',
    'healthcare://Patient/' || patient_id,
    'healthcare://MedicalCondition/' || condition_id,
    'raw_conditions',
    condition_id,
    sha256('diagnosedWith|' || patient_id || '|' || condition_id || '|' || source_system)
  FROM raw_conditions
)
SELECT *
FROM link_rows
ORDER BY source_object_id, rdf_property, target_object_id
