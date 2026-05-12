-- Read-only L1 commercial finance validation query.
--
-- Expected logical input views:
--   ontology_entity(entity_id, class_iri)
--   ontology_relation(source_id, target_id, predicate)
--
-- Reports transactions that are not posted by any financial account.

WITH transactions AS (
  SELECT entity_id
  FROM ontology_entity
  WHERE class_iri = 'https://wendao.ai/ontology/commercial-finance#Transaction'
),
posted_transactions AS (
  SELECT DISTINCT target_id
  FROM ontology_relation
  WHERE predicate = 'https://wendao.ai/ontology/commercial-finance#postsTransaction'
)
SELECT
  transaction.entity_id,
  'FINANCE_TRANSACTION_WITHOUT_ACCOUNT' AS violation_type
FROM transactions transaction
LEFT JOIN posted_transactions posted
  ON transaction.entity_id = posted.target_id
WHERE posted.target_id IS NULL;
