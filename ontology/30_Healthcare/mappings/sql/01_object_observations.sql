-- SELECT-only mapping from synthetic raw healthcare rows to ontology objects.

WITH object_rows AS (
  SELECT
    'healthcare.synthetic_care_delivery.v1' AS mapping_id,
    'episteme://30_Healthcare' AS domain,
    'Patient' AS object_type,
    'https://wendao.ai/ontology/healthcare#Patient' AS rdf_class,
    'healthcare://Patient/' || patient_id AS object_id,
    patient_name AS display_name,
    'raw_patients' AS source_table,
    patient_id AS source_row_id,
    sha256(patient_id || '|' || patient_name || '|' || source_system) AS source_hash
  FROM raw_patients
  UNION ALL
  SELECT
    'healthcare.synthetic_care_delivery.v1',
    'episteme://30_Healthcare',
    'CareProvider',
    'https://wendao.ai/ontology/healthcare#CareProvider',
    'healthcare://CareProvider/' || provider_id,
    provider_name,
    'raw_providers',
    provider_id,
    sha256(provider_id || '|' || provider_name || '|' || provider_kind || '|' || source_system)
  FROM raw_providers
  UNION ALL
  SELECT
    'healthcare.synthetic_care_delivery.v1',
    'episteme://30_Healthcare',
    'Encounter',
    'https://wendao.ai/ontology/healthcare#Encounter',
    'healthcare://Encounter/' || encounter_id,
    encounter_label,
    'raw_encounters',
    encounter_id,
    sha256(encounter_id || '|' || patient_id || '|' || provider_id || '|' || encounter_date || '|' || source_system)
  FROM raw_encounters
  UNION ALL
  SELECT
    'healthcare.synthetic_care_delivery.v1',
    'episteme://30_Healthcare',
    'MedicalCondition',
    'https://wendao.ai/ontology/healthcare#MedicalCondition',
    'healthcare://MedicalCondition/' || condition_id,
    condition_name,
    'raw_conditions',
    condition_id,
    sha256(condition_id || '|' || patient_id || '|' || condition_name || '|' || recorded_date || '|' || source_system)
  FROM raw_conditions
)
SELECT *
FROM object_rows
ORDER BY object_id
