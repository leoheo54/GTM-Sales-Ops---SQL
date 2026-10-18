-- GTM & Sales Operations Analysis
-- Run after loading the CSVs into the tables defined in 01_schema.sql.
-- Dialect: PostgreSQL

-- 1) Executive scorecard: pipeline, closed-won ACV, win rate, average deal size.
SELECT
    COUNT(*) FILTER (WHERE NOT is_closed) AS open_opportunities,
    SUM(acv_usd) FILTER (WHERE NOT is_closed) AS open_pipeline_acv_usd,
    COUNT(*) FILTER (WHERE is_closed) AS closed_opportunities,
    COUNT(*) FILTER (WHERE is_won) AS closed_won_opportunities,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE is_won)
        / NULLIF(COUNT(*) FILTER (WHERE is_closed), 0), 2
    ) AS win_rate_pct,
    ROUND(AVG(acv_usd) FILTER (WHERE is_won), 2) AS avg_won_acv_usd
FROM opportunities;

-- 2) Pipeline and closed-won ACV by region.
SELECT
    a.region,
    COUNT(*) FILTER (WHERE NOT o.is_closed) AS open_opportunities,
    SUM(o.acv_usd) FILTER (WHERE NOT o.is_closed) AS open_pipeline_acv_usd,
    SUM(o.acv_usd) FILTER (WHERE o.is_won) AS won_acv_usd
FROM opportunities o
JOIN accounts a ON a.account_id = o.account_id
GROUP BY a.region
ORDER BY open_pipeline_acv_usd DESC NULLS LAST;

-- 3) Funnel conversion by current stage.
-- This is a stage distribution, not a true cohort conversion rate.
SELECT
    stage,
    COUNT(*) AS opportunity_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_all_opportunities
FROM opportunities
GROUP BY stage
ORDER BY CASE stage
    WHEN 'Prospecting' THEN 1
    WHEN 'Qualification' THEN 2
    WHEN 'Discovery' THEN 3
    WHEN 'Proposal' THEN 4
    WHEN 'Negotiation' THEN 5
    WHEN 'Closed Won' THEN 6
    WHEN 'Closed Lost' THEN 7
    ELSE 8
END;

-- 4) Win rate and ACV by sales motion.
SELECT
    sales_motion,
    COUNT(*) FILTER (WHERE is_closed) AS closed_opportunities,
    COUNT(*) FILTER (WHERE is_won) AS won_opportunities,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE is_won)
        / NULLIF(COUNT(*) FILTER (WHERE is_closed), 0), 2
    ) AS win_rate_pct,
    ROUND(AVG(acv_usd) FILTER (WHERE is_won), 2) AS avg_won_acv_usd
FROM opportunities
GROUP BY sales_motion
ORDER BY win_rate_pct DESC NULLS LAST;

-- 5) Discount analysis: compare discount bands with win rate.
SELECT
    CASE
        WHEN discount_pct < 5 THEN '0-4%'
        WHEN discount_pct < 10 THEN '5-9%'
        WHEN discount_pct < 15 THEN '10-14%'
        WHEN discount_pct < 20 THEN '15-19%'
        ELSE '20%+'
    END AS discount_band,
    COUNT(*) FILTER (WHERE is_closed) AS closed_opportunities,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE is_won)
        / NULLIF(COUNT(*) FILTER (WHERE is_closed), 0), 2
    ) AS win_rate_pct,
    ROUND(AVG(acv_usd) FILTER (WHERE is_won), 2) AS avg_won_acv_usd
FROM opportunities
GROUP BY discount_band
ORDER BY MIN(discount_pct);

-- 6) Rep performance. Include only closed opportunities in win-rate denominator.
SELECT
    r.sales_rep_name,
    r.region,
    COUNT(*) FILTER (WHERE o.is_closed) AS closed_opportunities,
    COUNT(*) FILTER (WHERE o.is_won) AS wins,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE o.is_won)
        / NULLIF(COUNT(*) FILTER (WHERE o.is_closed), 0), 2
    ) AS win_rate_pct,
    SUM(o.acv_usd) FILTER (WHERE o.is_won) AS won_acv_usd
FROM sales_reps r
LEFT JOIN opportunities o ON o.sales_rep_id = r.sales_rep_id
GROUP BY r.sales_rep_id, r.sales_rep_name, r.region
ORDER BY won_acv_usd DESC NULLS LAST;

-- 7) Stale pipeline: open opportunities with no completed activity in the last 30 days.
-- Change CURRENT_DATE to a fixed date when reproducing a historical snapshot.
WITH last_activity AS (
    SELECT opportunity_id, MAX(activity_date) AS last_completed_activity_date
    FROM activities
    WHERE completed = TRUE
    GROUP BY opportunity_id
)
SELECT
    o.opportunity_id,
    o.opportunity_name,
    a.account_name,
    o.stage,
    o.acv_usd,
    o.close_date,
    la.last_completed_activity_date,
    CURRENT_DATE - COALESCE(la.last_completed_activity_date, o.created_date) AS days_since_last_touch
FROM opportunities o
JOIN accounts a ON a.account_id = o.account_id
LEFT JOIN last_activity la ON la.opportunity_id = o.opportunity_id
WHERE o.is_closed = FALSE
  AND CURRENT_DATE - COALESCE(la.last_completed_activity_date, o.created_date) > 30
ORDER BY days_since_last_touch DESC, o.acv_usd DESC;

-- 8) Monthly bookings trend: closed-won ACV by close month.
SELECT
    DATE_TRUNC('month', close_date)::DATE AS close_month,
    COUNT(*) AS deals_won,
    SUM(acv_usd) AS booked_acv_usd
FROM opportunities
WHERE is_won = TRUE
GROUP BY DATE_TRUNC('month', close_date)::DATE
ORDER BY close_month;

-- 9) Product line performance.
SELECT
    product_line,
    COUNT(*) FILTER (WHERE is_closed) AS closed_opportunities,
    COUNT(*) FILTER (WHERE is_won) AS wins,
    SUM(acv_usd) FILTER (WHERE is_won) AS won_acv_usd,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE is_won)
        / NULLIF(COUNT(*) FILTER (WHERE is_closed), 0), 2
    ) AS win_rate_pct
FROM opportunities
GROUP BY product_line
ORDER BY won_acv_usd DESC NULLS LAST;

-- 10) Activity coverage: completed activities per opportunity, by stage.
WITH activity_counts AS (
    SELECT opportunity_id, COUNT(*) FILTER (WHERE completed) AS completed_activities
    FROM activities
    GROUP BY opportunity_id
)
SELECT
    o.stage,
    COUNT(*) AS opportunities,
    ROUND(AVG(COALESCE(ac.completed_activities, 0)), 2) AS avg_completed_activities
FROM opportunities o
LEFT JOIN activity_counts ac ON ac.opportunity_id = o.opportunity_id
GROUP BY o.stage
ORDER BY avg_completed_activities DESC;

-- 11) Account segment view for GTM planning.
SELECT
    a.region,
    a.company_size_segment,
    COUNT(DISTINCT a.account_id) AS accounts,
    COUNT(o.opportunity_id) AS opportunities,
    SUM(o.acv_usd) FILTER (WHERE o.is_won) AS won_acv_usd,
    ROUND(
        100.0 * COUNT(o.opportunity_id) FILTER (WHERE o.is_won)
        / NULLIF(COUNT(o.opportunity_id) FILTER (WHERE o.is_closed), 0), 2
    ) AS win_rate_pct
FROM accounts a
LEFT JOIN opportunities o ON o.account_id = a.account_id
GROUP BY a.region, a.company_size_segment
ORDER BY won_acv_usd DESC NULLS LAST;

-- 12) Lost reason analysis.
SELECT
    lost_reason,
    COUNT(*) AS lost_deals,
    SUM(acv_usd) AS lost_acv_usd,
    ROUND(AVG(discount_pct), 2) AS avg_discount_pct
FROM opportunities
WHERE stage = 'Closed Lost'
GROUP BY lost_reason
ORDER BY lost_acv_usd DESC;
