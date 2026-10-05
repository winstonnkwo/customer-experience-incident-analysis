/*
PROJECT: Customer Experience Incident Analysis
AUTHOR: Winston Nkwo
PURPOSE:
Initial exploration and validation of the Operations Intelligence dataset.

Business context:
Investigate a significant CSAT decline and identify potential operational,
technical, and workforce drivers.

Database: operations_intelligence
*/

USE operations_intelligence;


-- ============================================================
-- 1. DATASET STRUCTURE
-- ============================================================

SHOW TABLES;


-- Inspect the structure of the main operational tables

DESCRIBE tickets;

DESCRIBE agents;

DESCRIBE engineering;

DESCRIBE workforce;

DESCRIBE qa_scores;

DESCRIBE marketing;


-- ============================================================
-- 2. RECORD COUNTS
-- ============================================================

SELECT
    'tickets' AS table_name,
    COUNT(*) AS record_count
FROM tickets

UNION ALL

SELECT
    'agents',
    COUNT(*)
FROM agents

UNION ALL

SELECT
    'engineering',
    COUNT(*)
FROM engineering

UNION ALL

SELECT
    'workforce',
    COUNT(*)
FROM workforce

UNION ALL

SELECT
    'qa_scores',
    COUNT(*)
FROM qa_scores

UNION ALL

SELECT
    'marketing',
    COUNT(*)
FROM marketing;


-- ============================================================
-- 3. SAMPLE OPERATIONAL DATA
-- ============================================================

SELECT *
FROM tickets
LIMIT 10;


SELECT *
FROM agents
LIMIT 10;


SELECT *
FROM engineering
LIMIT 10;


SELECT *
FROM workforce
LIMIT 10;


-- ============================================================
-- 4. TICKET DATE RANGE
-- ============================================================

SELECT
    MIN(ticket_date) AS earliest_ticket_date,
    MAX(ticket_date) AS latest_ticket_date
FROM tickets;


-- ============================================================
-- 5. TICKET VOLUME BY DAY
-- ============================================================

SELECT
    ticket_date,
    COUNT(*) AS ticket_volume
FROM tickets
GROUP BY ticket_date
ORDER BY ticket_date;


-- ============================================================
-- 6. ISSUE TYPE DISTRIBUTION
-- ============================================================

SELECT
    issue_type,
    COUNT(*) AS ticket_volume
FROM tickets
GROUP BY issue_type
ORDER BY ticket_volume DESC;


-- ============================================================
-- 7. CUSTOMER TYPE DISTRIBUTION
-- ============================================================

SELECT
    customer_type,
    COUNT(*) AS ticket_volume
FROM tickets
GROUP BY customer_type
ORDER BY ticket_volume DESC;


-- ============================================================
-- 8. TEAM DISTRIBUTION
-- ============================================================

SELECT
    a.team,
    COUNT(*) AS ticket_volume
FROM tickets t
LEFT JOIN agents a
    ON t.agent_id = a.agent_id
GROUP BY a.team
ORDER BY ticket_volume DESC;


-- ============================================================
-- 9. AGENT DISTRIBUTION
-- ============================================================

SELECT
    agent_id,
    COUNT(*) AS tickets_handled
FROM tickets
GROUP BY agent_id
ORDER BY tickets_handled DESC;


-- ============================================================
-- 10. BASIC CSAT DISTRIBUTION
-- ============================================================

SELECT
    csat,
    COUNT(*) AS response_count
FROM tickets
GROUP BY csat
ORDER BY csat;


-- ============================================================
-- 11. NULL / MISSING VALUE CHECK
-- ============================================================

SELECT
    SUM(ticket_id IS NULL) AS missing_ticket_id,
    SUM(ticket_date IS NULL) AS missing_ticket_date,
    SUM(agent_id IS NULL) AS missing_agent_id,
    SUM(issue_type IS NULL) AS missing_issue_type,
    SUM(customer_type IS NULL) AS missing_customer_type,
    SUM(csat IS NULL) AS missing_csat,
    SUM(resolution_time IS NULL) AS missing_resolution_time,
    SUM(fcr IS NULL) AS missing_fcr,
    SUM(sla_breached IS NULL) AS missing_sla_status
FROM tickets;


-- ============================================================
-- 12. INITIAL DATA QUALITY CHECK
-- ============================================================

SELECT
    COUNT(*) AS total_tickets,
    COUNT(DISTINCT ticket_id) AS unique_ticket_ids,
    COUNT(DISTINCT agent_id) AS active_agents,
    COUNT(DISTINCT team) AS teams,
    COUNT(DISTINCT issue_type) AS issue_types,
    COUNT(DISTINCT customer_type) AS customer_types
FROM tickets;
