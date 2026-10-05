/*
PROJECT: Customer Experience Incident Analysis
FILE: 03_root_cause_analysis.sql
AUTHOR: Winston Nkwo

PURPOSE:
Investigate the drivers of the CSAT decline and identify the strongest
evidence associated with the July 19 operational incident.

Key investigation areas:
- CSAT trend around July 19
- API error deterioration
- Payment success deterioration
- Issue-level customer impact
- SLA breaches
- Non fcr contacts
- Customer-type impact
- Agent/team contribution

IMPORTANT:
The analysis establishes temporal association and operational evidence.
It does not claim definitive causation without timestamped deployment,
payment-provider, and application logs.
*/


USE operations_intelligence;


-- ============================================================
-- 1. CSAT TREND AROUND THE INCIDENT
-- ============================================================

SELECT
    ticket_date,
    COUNT(*) AS ticket_volume,
    ROUND(AVG(csat), 2) AS average_csat
FROM tickets
GROUP BY ticket_date
ORDER BY ticket_date;


-- ============================================================
-- 2. CSAT BEFORE AND AFTER JULY 19
-- ============================================================

SELECT
    CASE
        WHEN ticket_date < '2026-07-19' THEN 'Before July 19'
        ELSE 'July 19 and After'
    END AS incident_period,

    COUNT(*) AS ticket_volume,
    ROUND(AVG(csat), 2) AS average_csat,

    ROUND(AVG(resolution_time), 2) AS average_resolution_time

FROM tickets
GROUP BY
    CASE
        WHEN ticket_date < '2026-07-19' THEN 'Before July 19'
        ELSE 'July 19 and After'
    END;


-- ============================================================
-- 3. DAILY ENGINEERING HEALTH
-- ============================================================

SELECT
    event_date,
    api_errors,
    ROUND(payment_success_rate, 2) AS payment_success_rate,

    CASE
        WHEN event_date < '2026-07-19' THEN 'Before July 19'
        ELSE 'July 19 and After'
    END AS incident_period

FROM engineering
ORDER BY event_date;


-- ============================================================
-- 4. ENGINEERING PERFORMANCE BEFORE VS AFTER JULY 19
-- ============================================================

SELECT
    CASE
        WHEN event_date < '2026-07-19' THEN 'Before July 19'
        ELSE 'July 19 and After'
    END AS incident_period,

    ROUND(AVG(api_errors), 2) AS average_api_errors,
    ROUND(AVG(payment_success_rate), 2) AS average_payment_success

FROM engineering
GROUP BY
    CASE
        WHEN event_date < '2026-07-19' THEN 'Before July 19'
        ELSE 'July 19 and After'
    END;


-- ============================================================
-- 5. ISSUE TYPES DRIVING CUSTOMER DISSATISFACTION
-- ============================================================

SELECT
    issue_type,
    COUNT(*) AS ticket_volume,
    ROUND(AVG(csat), 2) AS average_csat,
    ROUND(AVG(resolution_time), 2) AS average_resolution_time,

    SUM(
        CASE
            WHEN fcr = 'No' THEN 1
            ELSE 0
        END
    ) AS non_fcr_contacts,

    SUM(
        CASE
            WHEN sla_breached = 'Yes' THEN 1
            ELSE 0
        END
    ) AS sla_breaches

FROM tickets
GROUP BY issue_type
ORDER BY average_csat ASC;


-- ============================================================
-- 6. PAYMENT FAILURE DEEP DIVE
-- ============================================================

SELECT
    issue_type,
    COUNT(*) AS ticket_volume,
    ROUND(AVG(csat), 2) AS average_csat,

    SUM(
        CASE
            WHEN fcr = 'No' THEN 1
            ELSE 0
        END
    ) AS non_fcr_contacts,

    SUM(
        CASE
            WHEN sla_breached = 'Yes' THEN 1
            ELSE 0
        END
    ) AS sla_breaches,

    ROUND(AVG(resolution_time), 2) AS average_resolution_time

FROM tickets
WHERE issue_type = 'Payment Failure'
GROUP BY issue_type;


-- ============================================================
-- 7. SLA BREACHES BY ISSUE TYPE
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
        100.0 *
        SUM(
            CASE
                WHEN sla_breached = 'Yes' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS sla_breach_rate

FROM tickets
GROUP BY issue_type
ORDER BY sla_breaches DESC;


-- ============================================================
-- 8. NON-FCR CONTACTS BY ISSUE TYPE
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
        100.0 *
        SUM(
            CASE
                WHEN fcr = 'No' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS non_fcr_percentage

FROM tickets
GROUP BY issue_type
ORDER BY non_fcr_contacts DESC;


-- ============================================================
-- 9. CUSTOMER TYPE IMPACT
-- ============================================================

SELECT
    customer_type,
    COUNT(*) AS ticket_volume,
    ROUND(AVG(csat), 2) AS average_csat,
    ROUND(AVG(resolution_time), 2) AS average_resolution_time,

    SUM(
        CASE
            WHEN fcr = 'No' THEN 1
            ELSE 0
        END
    ) AS non_fcr_contacts,

    SUM(
        CASE
            WHEN sla_breached = 'Yes' THEN 1
            ELSE 0
        END
    ) AS sla_breaches

FROM tickets
GROUP BY customer_type
ORDER BY average_csat ASC;


-- ============================================================
-- 10. TEAM PERFORMANCE AND CUSTOMER IMPACT
-- ============================================================

SELECT
    a.team,
    COUNT(*) AS ticket_volume,
    ROUND(AVG(t.csat), 2) AS average_csat,
    ROUND(AVG(t.resolution_time), 2) AS average_resolution_time,

    SUM(
        CASE
            WHEN t.fcr = 'No' THEN 1
            ELSE 0
        END
    ) AS non_fcr_contacts,

    SUM(
        CASE
            WHEN t.sla_breached = 'Yes' THEN 1
            ELSE 0
        END
    ) AS sla_breaches

FROM tickets t
LEFT JOIN agents a
    ON t.agent_id = a.agent_id
GROUP BY a.team
ORDER BY average_csat ASC;


-- ============================================================
-- 11. AGENT CONTRIBUTION
-- ============================================================

SELECT
    t.agent_id,
    a.team,
    COUNT(*) AS tickets_handled,
    ROUND(AVG(t.csat), 2) AS average_csat,
    ROUND(AVG(t.resolution_time), 2) AS average_resolution_time,

    SUM(
        CASE
            WHEN t.fcr = 'No' THEN 1
            ELSE 0
        END
    ) AS non_fcr_contacts,

    SUM(
        CASE
            WHEN t.sla_breached = 'Yes' THEN 1
            ELSE 0
        END
    ) AS sla_breaches

FROM tickets t
LEFT JOIN agents a
    ON t.agent_id = a.agent_id

GROUP BY t.agent_id, a.team
ORDER BY average_csat ASC;


-- ============================================================
-- 12. INCIDENT TIMELINE
-- ============================================================

SELECT
    e.event_date,
    e.api_errors,
    ROUND(e.payment_success_rate, 2) AS payment_success_rate,

    COALESCE(t.ticket_volume, 0) AS ticket_volume,
    ROUND(t.average_csat, 2) AS average_csat

FROM engineering e

LEFT JOIN (
    SELECT
        ticket_date,
        COUNT(*) AS ticket_volume,
        AVG(csat) AS average_csat
    FROM tickets
    GROUP BY ticket_date
) t
    ON e.event_date = t.ticket_date

ORDER BY e.event_date;


-- ============================================================
-- 13. JULY 19 INCIDENT SNAPSHOT
-- ============================================================

SELECT
    e.event_date,
    e.api_errors,
    ROUND(e.payment_success_rate, 2) AS payment_success_rate,

    COUNT(t.ticket_id) AS ticket_volume,
    ROUND(AVG(t.csat), 2) AS average_csat

FROM engineering e

LEFT JOIN tickets t
    ON e.event_date = t.ticket_date

WHERE e.event_date BETWEEN '2026-07-16' AND '2026-07-22'

GROUP BY
    e.event_date,
    e.api_errors,
    e.payment_success_rate

ORDER BY e.event_date;
