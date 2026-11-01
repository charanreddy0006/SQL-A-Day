-- Day 97: SupportPulse — data-quality and sanity checks
-- Each query should return the expected result described in the comments.

-- 1. Expected base row counts: 5 agents, 6 customers, 25 tickets.
SELECT
    (SELECT COUNT(*) FROM agents) AS agents,
    (SELECT COUNT(*) FROM customers) AS customers,
    (SELECT COUNT(*) FROM tickets) AS tickets;

-- 2. Every ticket must reference an existing customer.
-- Expected: 0
SELECT COUNT(*) AS tickets_with_missing_customer
FROM tickets t
LEFT JOIN customers c USING (customer_id)
WHERE c.customer_id IS NULL;

-- 3. Every assigned agent must exist.
-- Expected: 0
SELECT COUNT(*) AS tickets_with_missing_agent
FROM tickets t
LEFT JOIN agents a USING (agent_id)
WHERE t.agent_id IS NOT NULL
  AND a.agent_id IS NULL;

-- 4. Confirm the dataset includes resolved and unresolved tickets.
SELECT status, COUNT(*) AS ticket_count
FROM tickets
GROUP BY status
ORDER BY status;

-- 5. Confirm that the sample contains both response and resolution breaches.
WITH policy AS (
    SELECT *
    FROM (VALUES
        ('Critical', INTERVAL '15 minutes', INTERVAL '4 hours'),
        ('High',     INTERVAL '1 hour',     INTERVAL '12 hours'),
        ('Medium',   INTERVAL '4 hours',    INTERVAL '48 hours'),
        ('Low',      INTERVAL '8 hours',    INTERVAL '120 hours')
    ) AS p(priority, response_target, resolution_target)
)
SELECT
    COUNT(*) FILTER (
        WHERE t.first_response_at IS NOT NULL
          AND t.first_response_at - t.created_at > p.response_target
    ) AS response_breaches,
    COUNT(*) FILTER (
        WHERE t.resolved_at IS NOT NULL
          AND t.resolved_at - t.created_at > p.resolution_target
    ) AS resolution_breaches
FROM tickets t
JOIN policy p USING (priority);

-- 6. No timestamp should occur before ticket creation.
-- Expected: 0
SELECT COUNT(*) AS invalid_timestamp_rows
FROM tickets
WHERE (first_response_at IS NOT NULL AND first_response_at < created_at)
   OR (resolved_at IS NOT NULL AND resolved_at < created_at);
