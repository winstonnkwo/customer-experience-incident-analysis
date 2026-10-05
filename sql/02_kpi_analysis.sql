/*
PROJECT: Customer Experience Incident Analysis
FILE: 02_kpi_analysis.sql
AUTHOR: Winston Nkwo

PURPOSE:
Calculate the core operational KPIs used to assess customer experience,
service performance, and the emerging incident.

Primary KPIs:
- Total Tickets
- Average CSAT
- FCR %
- SLA Breach %
- Average Resolution Time
- Average Payment Success Rate
*/


USE operations_intelligence;


-- ============================================================
-- 1. EXECUTIVE KPI BASELINE
-- ============================================================

SELECT
    COUNT(*) AS total_tickets,
    ROUND(AVG(csat), 2) AS average_csat,

    ROUND(
        100.0 * SUM(CASE WHEN fcr = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS fcr_percentage,

    ROUND(
        100.0 * SUM(CASE WHEN sla_breached = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS sla_breach_percentage,

    ROUND(AVG(resolution_time), 2) AS average_resolution_time

FROM tickets;


-- ============================================================
-- 2. PAYMENT SUCCESS RATE
-- ============================================================

SELECT
    ROUND(AVG(payment_success_rate), 2) AS average_payment_success_rate
FROM engineering;


-- ============================================================
-- 3. DAILY TICKET VOLUME AND CSAT
-- ============================================================

SELECT
    ticket_date,
    COUNT(*) AS ticket_volume,
    ROUND(AVG(csat), 2) AS average_csat
FROM tickets
GROUP BY ticket_date
ORDER BY ticket_date;


-- ============================================================
-- 4. DAILY FCR AND SLA PERFORMANCE
-- ============================================================

SELECT
    ticket_date,
    COUNT(*) AS total_tickets,

    ROUND(
        100.0 * SUM(CASE WHEN fcr = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS fcr_percentage,

    ROUND(
        100.0 * SUM(CASE WHEN sla_breached = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS sla_breach_percentage

FROM tickets
GROUP BY ticket_date
ORDER BY ticket_date;


-- ============================================================
-- 5. KPI PERFORMANCE BY ISSUE TYPE
-- ============================================================

SELECT
    issue_type,
    COUNT(*) AS ticket_volume,
    ROUND(AVG(csat), 2) AS average_csat,

    ROUND(
        100.0 * SUM(CASE WHEN fcr = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS fcr_percentage,

    ROUND(
        100.0 * SUM(CASE WHEN sla_breached = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS sla_breach_percentage,

    ROUND(AVG(resolution_time), 2) AS average_resolution_time

FROM tickets
GROUP BY issue_type
ORDER BY average_csat ASC;


-- ============================================================
-- 6. KPI PERFORMANCE BY TEAM
-- ============================================================

SELECT
    a.team,
    COUNT(*) AS ticket_volume,
    ROUND(AVG(t.csat), 2) AS average_csat,

    ROUND(
        100.0 * SUM(CASE WHEN t.fcr = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS fcr_percentage,

    ROUND(
        100.0 * SUM(CASE WHEN t.sla_breached = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS sla_breach_percentage,

    ROUND(AVG(t.resolution_time), 2) AS average_resolution_time

FROM tickets t
LEFT JOIN agents a
    ON t.agent_id = a.agent_id
GROUP BY a.team
ORDER BY average_csat ASC;


-- ============================================================
-- 7. KPI PERFORMANCE BY CUSTOMER TYPE
-- ============================================================

SELECT
    customer_type,
    COUNT(*) AS ticket_volume,
    ROUND(AVG(csat), 2) AS average_csat,

    ROUND(
        100.0 * SUM(CASE WHEN fcr = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS fcr_percentage,

    ROUND(
        100.0 * SUM(CASE WHEN sla_breached = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS sla_breach_percentage,

    ROUND(AVG(resolution_time), 2) AS average_resolution_time

FROM tickets
GROUP BY customer_type
ORDER BY average_csat ASC;


-- ============================================================
-- 8. SLA BREACHES BY ISSUE TYPE
-- ============================================================

SELECT
    issue_type,
    COUNT(*) AS total_tickets,

    SUM(
        CASE
            WHEN sla_breached = 'Yes' THEN 1
            ELSE 0
        END
    ) AS sla_breaches,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN sla_breached = 'Yes' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS sla_breach_percentage

FROM tickets
GROUP BY issue_type
ORDER BY sla_breaches DESC;


-- ============================================================
-- 9. NON-FCR ANALYSIS BY ISSUE
-- ============================================================

SELECT
    issue_type,
    COUNT(*) AS total_tickets,

    SUM(
        CASE
            WHEN fcr = 'No' THEN 1
            ELSE 0
        END
    ) AS non_fcr_contacts,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN fcr = 'No' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS non_fcr_percentage

FROM tickets
GROUP BY issue_type
ORDER BY repeat_contacts DESC;


-- ============================================================
-- 10. DAILY ENGINEERING HEALTH
-- ============================================================

SELECT
    event_date,
    api_errors,
    ROUND(payment_success_rate, 2) AS payment_success_rate
FROM engineering
ORDER BY event_date;
