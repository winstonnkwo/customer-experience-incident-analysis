/*
PROJECT: Customer Experience Incident Analysis
FILE: 04_workforce_analysis.sql
AUTHOR: Winston Nkwo

PURPOSE:
Assess whether the operational incident justifies additional workforce
capacity and establish evidence-based conditions for future recruitment.

Key questions:
1. How much workload is currently being generated?
2. How much productive capacity is required?
3. Which teams/agents are carrying the greatest workload?
4. Is the current incident sufficient evidence for permanent hiring?
5. What conditions should trigger future recruitment?

IMPORTANT:
The incident may temporarily inflate resolution time and workload.
Permanent hiring should therefore be based on stabilized demand and
post-incident capacity requirements rather than incident-period metrics alone.
*/


USE operations_intelligence;


-- ============================================================
-- 1. INSPECT WORKFORCE DATA
-- ============================================================

DESCRIBE workforce;


-- ============================================================
-- 2. CURRENT TICKET WORKLOAD
-- ============================================================

SELECT
    COUNT(*) AS total_tickets,

    ROUND(
        AVG(resolution_time),
        2
    ) AS average_resolution_minutes,

    ROUND(
        SUM(resolution_time) / 60,
        2
    ) AS total_workload_hours

FROM tickets;


-- ============================================================
-- 3. WORKLOAD BY TEAM
-- ============================================================

SELECT
    team,

    COUNT(*) AS ticket_volume,

    ROUND(
        AVG(resolution_time),
        2
    ) AS average_resolution_minutes,

    ROUND(
        SUM(resolution_time) / 60,
        2
    ) AS workload_hours

FROM tickets

GROUP BY team

ORDER BY workload_hours DESC;


-- ============================================================
-- 4. AGENT WORKLOAD
-- ============================================================

SELECT
    agent_id,
    team,

    COUNT(*) AS tickets_handled,

    ROUND(
        AVG(resolution_time),
        2
    ) AS average_resolution_minutes,

    ROUND(
        SUM(resolution_time) / 60,
        2
    ) AS workload_hours,

    ROUND(
        AVG(csat),
        2
    ) AS average_csat

FROM tickets

GROUP BY
    agent_id,
    team

ORDER BY workload_hours DESC;


-- ============================================================
-- 5. WORKLOAD CONCENTRATION
-- ============================================================

SELECT
    team,
    COUNT(*) AS ticket_volume,

    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM tickets),
        2
    ) AS percentage_of_total_volume

FROM tickets

GROUP BY team

ORDER BY percentage_of_total_volume DESC;


-- ============================================================
-- 6. INCIDENT-PERIOD WORKLOAD
-- ============================================================

SELECT
    CASE
        WHEN ticket_date < '2026-07-19'
            THEN 'Before July 19'
        ELSE 'July 19 and After'
    END AS incident_period,

    COUNT(*) AS ticket_volume,

    ROUND(
        AVG(resolution_time),
        2
    ) AS average_resolution_minutes,

    ROUND(
        SUM(resolution_time) / 60,
        2
    ) AS workload_hours,

    ROUND(
        AVG(csat),
        2
    ) AS average_csat

FROM tickets

GROUP BY
    CASE
        WHEN ticket_date < '2026-07-19'
            THEN 'Before July 19'
        ELSE 'July 19 and After'
    END;


-- ============================================================
-- 7. FTE REQUIREMENT ESTIMATE
-- ============================================================
/*
ASSUMPTION:
120 productive hours per agent per month.

Productive hours should exclude:
- breaks
- meetings
- training
- leave
- administrative work
- other non-ticket activities

Formula:

Required FTE =
Total workload hours / productive hours per agent
*/

SELECT

    COUNT(*) AS total_tickets,

    ROUND(
        AVG(resolution_time),
        2
    ) AS average_resolution_minutes,

    ROUND(
        SUM(resolution_time) / 60,
        2
    ) AS total_workload_hours,

    ROUND(
        (SUM(resolution_time) / 60) / 120,
        2
    ) AS estimated_required_fte

FROM tickets;


-- ============================================================
-- 8. FTE REQUIREMENT BY TEAM
-- ============================================================

SELECT

    team,

    COUNT(*) AS ticket_volume,

    ROUND(
        SUM(resolution_time) / 60,
        2
    ) AS workload_hours,

    ROUND(
        (SUM(resolution_time) / 60) / 120,
        2
    ) AS estimated_required_fte

FROM tickets

GROUP BY team

ORDER BY estimated_required_fte DESC;


-- ============================================================
-- 9. CURRENT AGENT BASE
-- ============================================================

SELECT
    COUNT(DISTINCT agent_id) AS active_agents
FROM tickets;


-- ============================================================
-- 10. AGENT BASE BY TEAM
-- ============================================================

SELECT
    team,
    COUNT(DISTINCT agent_id) AS active_agents,
    COUNT(*) AS ticket_volume,

    ROUND(
        COUNT(*) /
        COUNT(DISTINCT agent_id),
        2
    ) AS tickets_per_agent

FROM tickets

GROUP BY team

ORDER BY tickets_per_agent DESC;


-- ============================================================
-- 11. TICKETS PER AGENT VS CUSTOMER EXPERIENCE
-- ============================================================

SELECT
    agent_id,
    team,

    COUNT(*) AS tickets_handled,

    ROUND(
        AVG(csat),
        2
    ) AS average_csat,

    ROUND(
        AVG(resolution_time),
        2
    ) AS average_resolution_minutes

FROM tickets

GROUP BY
    agent_id,
    team

ORDER BY tickets_handled DESC;


-- ============================================================
-- 12. CAPACITY SCENARIO MODEL
-- ============================================================
/*
This scenario model demonstrates how management can test different
staffing assumptions.

Example:
- 5,000 monthly tickets
- 43.39 minute average handling/resolution time
- 120 productive hours per agent

Formula:

Workload hours =
Ticket volume × average resolution time / 60

Required FTE =
Workload hours / productive hours per agent
*/

SELECT

    5000 AS scenario_ticket_volume,

    43.39 AS scenario_average_resolution_minutes,

    120 AS productive_hours_per_agent,

    ROUND(
        (5000 * 43.39) / 60,
        2
    ) AS scenario_workload_hours,

    CEILING(
        ((5000 * 43.39) / 60) / 120
    ) AS estimated_required_fte;


-- ============================================================
-- 13. RECRUITMENT DECISION FRAMEWORK
-- ============================================================
/*
Permanent recruitment should NOT be triggered by incident-period
workload alone.

Recommended recruitment triggers:

1. Demand remains at least 15% above baseline.
2. Team utilization remains above approximately 85%.
3. SLA performance remains below the required service level.
4. Sustained overtime is required.
5. The demand forecast continues to show a capacity gap.
6. The technical/payment incident has already been stabilized.

The decision should therefore be based on sustained demand rather
than a temporary incident spike.
*/


-- ============================================================
-- 14. WORKFORCE DECISION SUMMARY
-- ============================================================

SELECT

    COUNT(*) AS observed_ticket_volume,

    ROUND(
        AVG(resolution_time),
        2
    ) AS observed_average_resolution_minutes,

    ROUND(
        SUM(resolution_time) / 60,
        2
    ) AS observed_workload_hours,

    COUNT(DISTINCT agent_id) AS current_active_agents,

    ROUND(
        (SUM(resolution_time) / 60) /
        COUNT(DISTINCT agent_id),
        2
    ) AS workload_hours_per_active_agent

FROM tickets;
