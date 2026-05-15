-- SELECT-only evidence rows for synthetic healthcare mapping observations.

WITH evidence_rows AS (
  SELECT
    'evidence:raw_patients:' || patient_id AS evidence_id,
    'table_row' AS evidence_kind,
    'raw_patients' AS source_table,
    patient_id AS source_row_id,
    sha256(patient_id || '|' || patient_name || '|' || source_system) AS source_hash,
    'Patient row for ' || patient_name AS evidence_text
  FROM raw_patients
  UNION ALL
  SELECT
    'evidence:raw_providers:' || provider_id,
    'table_row',
    'raw_providers',
    provider_id,
    sha256(provider_id || '|' || provider_name || '|' || provider_kind || '|' || source_system),
    'Care provider row for ' || provider_name
  FROM raw_providers
  UNION ALL
  SELECT
    'evidence:raw_encounters:' || encounter_id,
    'table_row',
    'raw_encounters',
    encounter_id,
    sha256(encounter_id || '|' || patient_id || '|' || provider_id || '|' || encounter_date || '|' || source_system),
    'Encounter row for ' || encounter_label
  FROM raw_encounters
  UNION ALL
  SELECT
    'evidence:raw_conditions:' || condition_id,
    'table_row',
    'raw_conditions',
    condition_id,
    sha256(condition_id || '|' || patient_id || '|' || condition_name || '|' || recorded_date || '|' || source_system),
    'Condition row for ' || condition_name
  FROM raw_conditions
)
SELECT *
FROM evidence_rows
ORDER BY evidence_id
