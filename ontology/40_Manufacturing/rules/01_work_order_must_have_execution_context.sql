-- Read-only L1 manufacturing validation query.
--
-- Expected logical input views:
--   ontology_entity(entity_id, class_iri)
--   ontology_relation(source_id, target_id, predicate)
--
-- Reports work orders that are not executed by a machine or do not consume a part.

WITH work_orders AS (
  SELECT entity_id
  FROM ontology_entity
  WHERE class_iri = 'https://wendao.ai/ontology/manufacturing#WorkOrder'
),
machine_execution AS (
  SELECT DISTINCT target_id
  FROM ontology_relation
  WHERE predicate = 'https://wendao.ai/ontology/manufacturing#executesWorkOrder'
),
part_consumption AS (
  SELECT DISTINCT source_id
  FROM ontology_relation
  WHERE predicate = 'https://wendao.ai/ontology/manufacturing#consumesPart'
)
SELECT
  work_order.entity_id,
  'MANUFACTURING_WORK_ORDER_MISSING_CONTEXT' AS violation_type
FROM work_orders work_order
LEFT JOIN machine_execution machine
  ON work_order.entity_id = machine.target_id
LEFT JOIN part_consumption part
  ON work_order.entity_id = part.source_id
WHERE machine.target_id IS NULL
   OR part.source_id IS NULL;
