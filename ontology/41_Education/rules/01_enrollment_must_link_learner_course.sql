-- Read-only L1 education validation query.
--
-- Expected logical input views:
--   ontology_entity(entity_id, class_iri)
--   ontology_relation(source_id, target_id, predicate)
--
-- Reports enrollments that are not connected to both learner and course.

WITH enrollments AS (
  SELECT entity_id
  FROM ontology_entity
  WHERE class_iri = 'https://wendao.ai/ontology/education#Enrollment'
),
learner_links AS (
  SELECT DISTINCT target_id
  FROM ontology_relation
  WHERE predicate = 'https://wendao.ai/ontology/education#enrollsIn'
),
course_links AS (
  SELECT DISTINCT source_id
  FROM ontology_relation
  WHERE predicate = 'https://wendao.ai/ontology/education#forCourse'
)
SELECT
  enrollment.entity_id,
  'EDUCATION_ENROLLMENT_MISSING_CONTEXT' AS violation_type
FROM enrollments enrollment
LEFT JOIN learner_links learner
  ON enrollment.entity_id = learner.target_id
LEFT JOIN course_links course
  ON enrollment.entity_id = course.source_id
WHERE learner.target_id IS NULL
   OR course.source_id IS NULL;
