-- Day 97: SupportPulse — analytical SQL
-- PostgreSQL 14+

-- SLA policy used throughout this file:
-- Critical: response 15 min, resolution 4 hours
-- High:     response  1 hour, resolution 12 hours
-- Medium:   response  4 hours, resolution 48 hours
-- Low:      response  8 hours, resolution 120 hours

-- 1. TICKET-LEVEL SLA AUDIT
WITH policy AS (
    SELECT *
    FROM (VALUES
        ('Critical', INTERVAL '15 minutes', INTERVAL '4 hours'),
        ('High',     INTERVAL '1 hour',     INTERVAL '12 hours'),
        ('Medium',   INTERVAL '4 hours',    INTERVAL '48 hours'),
        ('Low',      INTERVAL '8 hours',    INTERVAL '120 hours')
    ) AS p(priority, response_target, resolution_target)
),
ticket_metrics AS (
    SELECT
        t.ticket_id,
        t.subject,
        t.priority,
        t.status,
        a.agent_name,
        c.company_name,
        t.created_at,
        t.first_response_at,
        t.resolved_at,
        p.response_target,
        p.resolution_target,
        t.first_response_at - t.created_at AS response_time,
        t.resolved_at - t.created_at AS resolution_time
    FROM tickets t
    JOIN policy p USING (priority)
    JOIN customers c USING (customer_id)
    LEFT JOIN agents a USING (agent_id)
)
SELECT
    ticket_id,
    priority,
    subject,
    agent_name,
    response_time,
    resolution_time,
    CASE
        WHEN first_response_at IS NULL THEN 'Awaiting response'
        WHEN response_time > response_target THEN 'Breached'
        ELSE 'Met'
    END AS response_sla_status,
    CASE
        WHEN resolved_at IS NULL THEN 'Unresolved'
        WHEN resolution_time > resolution_target THEN 'Breached'
        ELSE 'Met'
    END AS resolution_sla_status
FROM ticket_metrics
ORDER BY created_at, ticket_id;


-- 2. SLA BREACH SUMMARY BY PRIORITY
WITH policy AS (
    SELECT *
    FROM (VALUES
        ('Critical', INTERVAL '15 minutes', INTERVAL '4 hours'),
        ('High',     INTERVAL '1 hour',     INTERVAL '12 hours'),
        ('Medium',   INTERVAL '4 hours',    INTERVAL '48 hours'),
        ('Low',      INTERVAL '8 hours',    INTERVAL '120 hours')
    ) AS p(priority, response_target, resolution_target)
),
audited AS (
    SELECT
        t.*,
        p.response_target,
        p.resolution_target,
        (t.first_response_at - t.created_at) AS response_time,
        (t.resolved_at - t.created_at) AS resolution_time
    FROM tickets t
    JOIN policy p USING (priority)
)
SELECT
    priority,
    COUNT(*) AS total_tickets,
    COUNT(*) FILTER (
        WHERE first_response_at IS NOT NULL
          AND response_time > response_target
    ) AS response_breaches,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE first_response_at IS NOT NULL
              AND response_time > response_target
        ) / NULLIF(COUNT(*) FILTER (WHERE first_response_at IS NOT NULL), 0),
        2
    ) AS response_breach_pct,
    COUNT(*) FILTER (
        WHERE resolved_at IS NOT NULL
          AND resolution_time > resolution_target
    ) AS resolution_breaches,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE resolved_at IS NOT NULL
              AND resolution_time > resolution_target
        ) / NULLIF(COUNT(*) FILTER (WHERE resolved_at IS NOT NULL), 0),
        2
    ) AS resolution_breach_pct
FROM audited
GROUP BY priority
ORDER BY
    CASE priority
        WHEN 'Critical' THEN 1
        WHEN 'High' THEN 2
        WHEN 'Medium' THEN 3
        ELSE 4
    END;


-- 3. AGENT PERFORMANCE SCORECARD
WITH policy AS (
    SELECT *
    FROM (VALUES
        ('Critical', INTERVAL '15 minutes', INTERVAL '4 hours'),
        ('High',     INTERVAL '1 hour',     INTERVAL '12 hours'),
        ('Medium',   INTERVAL '4 hours',    INTERVAL '48 hours'),
        ('Low',      INTERVAL '8 hours',    INTERVAL '120 hours')
    ) AS p(priority, response_target, resolution_target)
),
agent_ticket_metrics AS (
    SELECT
        a.agent_id,
        a.agent_name,
        a.team_name,
        t.ticket_id,
        t.status,
        t.first_response_at - t.created_at AS response_time,
        t.resolved_at - t.created_at AS resolution_time,
        p.response_target,
        p.resolution_target
    FROM agents a
    LEFT JOIN tickets t ON t.agent_id = a.agent_id
    LEFT JOIN policy p ON p.priority = t.priority
)
SELECT
    agent_name,
    team_name,
    COUNT(ticket_id) AS assigned_tickets,
    COUNT(ticket_id) FILTER (WHERE status = 'Resolved') AS resolved_tickets,
    ROUND(AVG(EXTRACT(EPOCH FROM response_time) / 60)
        FILTER (WHERE response_time IS NOT NULL), 1) AS avg_response_minutes,
    COUNT(ticket_id) FILTER (
        WHERE response_time > response_target
    ) AS response_breaches,
    COUNT(ticket_id) FILTER (
        WHERE resolution_time > resolution_target
    ) AS resolution_breaches
FROM agent_ticket_metrics
GROUP BY agent_id, agent_name, team_name
ORDER BY resolution_breaches DESC, assigned_tickets DESC;


-- 4. RANK AGENTS BY AVERAGE FIRST-RESPONSE TIME WITHIN EACH TEAM
WITH response_stats AS (
    SELECT
        a.team_name,
        a.agent_name,
        AVG(EXTRACT(EPOCH FROM (t.first_response_at - t.created_at)) / 60)
            AS avg_response_minutes
    FROM agents a
    JOIN tickets t ON t.agent_id = a.agent_id
    WHERE t.first_response_at IS NOT NULL
    GROUP BY a.team_name, a.agent_id, a.agent_name
)
SELECT
    team_name,
    agent_name,
    ROUND(avg_response_minutes::NUMERIC, 1) AS avg_response_minutes,
    DENSE_RANK() OVER (
        PARTITION BY team_name
        ORDER BY avg_response_minutes
    ) AS response_rank
FROM response_stats
ORDER BY team_name, response_rank, agent_name;


-- 5. DAILY OPERATIONAL TREND
WITH policy AS (
    SELECT *
    FROM (VALUES
        ('Critical', INTERVAL '15 minutes', INTERVAL '4 hours'),
        ('High',     INTERVAL '1 hour',     INTERVAL '12 hours'),
        ('Medium',   INTERVAL '4 hours',    INTERVAL '48 hours'),
        ('Low',      INTERVAL '8 hours',    INTERVAL '120 hours')
    ) AS p(priority, response_target, resolution_target)
),
daily AS (
    SELECT
        t.created_at::DATE AS ticket_date,
        COUNT(*) AS tickets_created,
        COUNT(*) FILTER (WHERE t.status = 'Resolved') AS currently_resolved,
        COUNT(*) FILTER (
            WHERE t.resolved_at IS NOT NULL
              AND t.resolved_at - t.created_at > p.resolution_target
        ) AS resolution_breaches
    FROM tickets t
    JOIN policy p USING (priority)
    GROUP BY t.created_at::DATE
)
SELECT
    ticket_date,
    tickets_created,
    currently_resolved,
    resolution_breaches,
    SUM(tickets_created) OVER (
        ORDER BY ticket_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_tickets
FROM daily
ORDER BY ticket_date;


-- 6. OPEN-TICKET RISK QUEUE
-- This section intentionally uses CURRENT_TIMESTAMP. Results change with run time.
WITH policy AS (
    SELECT *
    FROM (VALUES
        ('Critical', INTERVAL '15 minutes', INTERVAL '4 hours'),
        ('High',     INTERVAL '1 hour',     INTERVAL '12 hours'),
        ('Medium',   INTERVAL '4 hours',    INTERVAL '48 hours'),
        ('Low',      INTERVAL '8 hours',    INTERVAL '120 hours')
    ) AS p(priority, response_target, resolution_target)
),
open_tickets AS (
    SELECT
        t.ticket_id,
        t.subject,
        t.priority,
        t.status,
        a.agent_name,
        t.created_at,
        t.first_response_at,
        t.created_at + p.response_target AS response_deadline,
        t.created_at + p.resolution_target AS resolution_deadline
    FROM tickets t
    JOIN policy p USING (priority)
    LEFT JOIN agents a USING (agent_id)
    WHERE t.resolved_at IS NULL
)
SELECT
    ticket_id,
    priority,
    subject,
    agent_name,
    CASE
        WHEN first_response_at IS NOT NULL THEN 'Response received'
        WHEN CURRENT_TIMESTAMP > response_deadline THEN 'Response SLA breached'
        ELSE 'Response SLA at risk'
    END AS response_risk,
    CASE
        WHEN CURRENT_TIMESTAMP > resolution_deadline THEN 'Resolution SLA breached'
        ELSE 'Resolution SLA pending'
    END AS resolution_risk,
    ROUND(EXTRACT(EPOCH FROM (response_deadline - CURRENT_TIMESTAMP)) / 60, 1)
        AS response_minutes_remaining,
    ROUND(EXTRACT(EPOCH FROM (resolution_deadline - CURRENT_TIMESTAMP)) / 60, 1)
        AS resolution_minutes_remaining
FROM open_tickets
ORDER BY resolution_deadline;
