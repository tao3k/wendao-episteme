-- Read-only L1 software engineering validation query.
--
-- Expected logical input views:
--   ontology_entity(entity_id, class_iri)
--   ontology_relation(source_id, target_id, predicate)
--
-- Reports implementation artifacts that do not link to a governing decision.

WITH implementation_artifacts AS (
  SELECT entity_id
  FROM ontology_entity
  WHERE class_iri = 'https://wendao.ai/ontology/software-engineering#ImplementationArtifact'
),
decision_links AS (
  SELECT DISTINCT source_id
  FROM ontology_relation
  WHERE predicate = 'https://wendao.ai/ontology/software-engineering#implementsDecision'
)
SELECT
  artifact.entity_id,
  'IMPLEMENTATION_MISSING_DECISION_LINK' AS violation_type
FROM implementation_artifacts artifact
LEFT JOIN decision_links link
  ON artifact.entity_id = link.source_id
WHERE link.source_id IS NULL;
