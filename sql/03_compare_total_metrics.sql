/*
================================================================================
Project: Dashboard vs Source Data Mismatch Investigation
File: 03_compare_total_metrics.sql

Purpose:
    Compare total marketing metrics between the source platform data and
    dashboard export data.

Why this check matters:
    Even if row counts look similar, the actual business metrics may still
    be different.

    In real reporting projects, business users usually care about questions like:

        - Why is dashboard spend lower than source spend?
        - Why are clicks different?
        - Why are conversions not matching?
        - Which platform or state is causing the mismatch?

SQL Style:
    Beginner-friendly standard SQL / SQLite-friendly format
================================================================================
*/


/*
================================================================================
Check 1: Compare overall total metrics
================================================================================

Question:
    Do total impressions, clicks, conversions, and spend match between
    source data and dashboard data?

This is the first business-level comparison.
================================================================================
*/

SELECT
    'source_platform_campaign_data' AS dataset_name,
    SUM(impressions) AS total_impressions,
    SUM(clicks) AS total_clicks,
    SUM(conversions) AS total_conversions,
    ROUND(SUM(spend_inr), 2) AS total_spend_inr
FROM source_platform_campaign_data

UNION ALL

SELECT
    'dashboard_export_campaign_data' AS dataset_name,
    SUM(impressions) AS total_impressions,
    SUM(clicks) AS total_clicks,
    SUM(conversions) AS total_conversions,
    ROUND(SUM(spend_inr), 2) AS total_spend_inr
FROM dashboard_export_campaign_data;


/*
================================================================================
Check 2: Show overall metric differences
================================================================================

Question:
    What is the exact difference between source totals and dashboard totals?

Interpretation:
    Positive difference:
        Source value is higher than dashboard value.

    Negative difference:
        Dashboard value is higher than source value.

    Zero difference:
        Both values match.
================================================================================
*/

SELECT
    source_totals.source_impressions,
    dashboard_totals.dashboard_impressions,
    source_totals.source_impressions - dashboard_totals.dashboard_impressions
        AS impressions_difference,

    source_totals.source_clicks,
    dashboard_totals.dashboard_clicks,
    source_totals.source_clicks - dashboard_totals.dashboard_clicks
        AS clicks_difference,

    source_totals.source_conversions,
    dashboard_totals.dashboard_conversions,
    source_totals.source_conversions - dashboard_totals.dashboard_conversions
        AS conversions_difference,

    ROUND(source_totals.source_spend_inr, 2) AS source_spend_inr,
    ROUND(dashboard_totals.dashboard_spend_inr, 2) AS dashboard_spend_inr,
    ROUND(source_totals.source_spend_inr - dashboard_totals.dashboard_spend_inr, 2)
        AS spend_difference_inr

FROM
    (
        SELECT
            SUM(impressions) AS source_impressions,
            SUM(clicks) AS source_clicks,
            SUM(conversions) AS source_conversions,
            SUM(spend_inr) AS source_spend_inr
        FROM source_platform_campaign_data
    ) source_totals
CROSS JOIN
    (
        SELECT
            SUM(impressions) AS dashboard_impressions,
            SUM(clicks) AS dashboard_clicks,
            SUM(conversions) AS dashboard_conversions,
            SUM(spend_inr) AS dashboard_spend_inr
        FROM dashboard_export_campaign_data
    ) dashboard_totals;


/*
================================================================================
Check 3: Add percentage difference
================================================================================

Question:
    How big is the mismatch in percentage terms?

Why this matters:
    A difference of ₹1,000 may be small for a large campaign but large for
    a small campaign.

    Percentage difference helps understand impact.
================================================================================
*/

SELECT
    source_totals.source_impressions,
    dashboard_totals.dashboard_impressions,
    source_totals.source_impressions - dashboard_totals.dashboard_impressions
        AS impressions_difference,
    ROUND(
        ((source_totals.source_impressions - dashboard_totals.dashboard_impressions) * 100.0)
        / NULLIF(source_totals.source_impressions, 0),
        2
    ) AS impressions_difference_percentage,

    source_totals.source_clicks,
    dashboard_totals.dashboard_clicks,
    source_totals.source_clicks - dashboard_totals.dashboard_clicks
        AS clicks_difference,
    ROUND(
        ((source_totals.source_clicks - dashboard_totals.dashboard_clicks) * 100.0)
        / NULLIF(source_totals.source_clicks, 0),
        2
    ) AS clicks_difference_percentage,

    source_totals.source_conversions,
    dashboard_totals.dashboard_conversions,
    source_totals.source_conversions - dashboard_totals.dashboard_conversions
        AS conversions_difference,
    ROUND(
        ((source_totals.source_conversions - dashboard_totals.dashboard_conversions) * 100.0)
        / NULLIF(source_totals.source_conversions, 0),
        2
    ) AS conversions_difference_percentage,

    ROUND(source_totals.source_spend_inr, 2) AS source_spend_inr,
    ROUND(dashboard_totals.dashboard_spend_inr, 2) AS dashboard_spend_inr,
    ROUND(source_totals.source_spend_inr - dashboard_totals.dashboard_spend_inr, 2)
        AS spend_difference_inr,
    ROUND(
        ((source_totals.source_spend_inr - dashboard_totals.dashboard_spend_inr) * 100.0)
        / NULLIF(source_totals.source_spend_inr, 0),
        2
    ) AS spend_difference_percentage

FROM
    (
        SELECT
            SUM(impressions) AS source_impressions,
            SUM(clicks) AS source_clicks,
            SUM(conversions) AS source_conversions,
            SUM(spend_inr) AS source_spend_inr
        FROM source_platform_campaign_data
    ) source_totals
CROSS JOIN
    (
        SELECT
            SUM(impressions) AS dashboard_impressions,
            SUM(clicks) AS dashboard_clicks,
            SUM(conversions) AS dashboard_conversions,
            SUM(spend_inr) AS dashboard_spend_inr
        FROM dashboard_export_campaign_data
    ) dashboard_totals;


/*
================================================================================
Check 4: Metric comparison by platform
================================================================================

Question:
    Which platform is causing the biggest mismatch?

Why this matters:
    Sometimes the overall mismatch is mainly caused by one platform.

Example:
    Google Ads may match correctly, but Meta Ads or Programmatic Ads may have
    missing records or incorrect transformation logic.
================================================================================
*/

SELECT
    source_by_platform.platform,

    source_by_platform.source_impressions,
    COALESCE(dashboard_by_platform.dashboard_impressions, 0) AS dashboard_impressions,
    source_by_platform.source_impressions
        - COALESCE(dashboard_by_platform.dashboard_impressions, 0)
        AS impressions_difference,

    source_by_platform.source_clicks,
    COALESCE(dashboard_by_platform.dashboard_clicks, 0) AS dashboard_clicks,
    source_by_platform.source_clicks
        - COALESCE(dashboard_by_platform.dashboard_clicks, 0)
        AS clicks_difference,

    source_by_platform.source_conversions,
    COALESCE(dashboard_by_platform.dashboard_conversions, 0) AS dashboard_conversions,
    source_by_platform.source_conversions
        - COALESCE(dashboard_by_platform.dashboard_conversions, 0)
        AS conversions_difference,

    ROUND(source_by_platform.source_spend_inr, 2) AS source_spend_inr,
    ROUND(COALESCE(dashboard_by_platform.dashboard_spend_inr, 0), 2)
        AS dashboard_spend_inr,
    ROUND(
        source_by_platform.source_spend_inr
        - COALESCE(dashboard_by_platform.dashboard_spend_inr, 0),
        2
    ) AS spend_difference_inr,

    CASE
        WHEN source_by_platform.source_impressions = COALESCE(dashboard_by_platform.dashboard_impressions, 0)
         AND source_by_platform.source_clicks = COALESCE(dashboard_by_platform.dashboard_clicks, 0)
         AND source_by_platform.source_conversions = COALESCE(dashboard_by_platform.dashboard_conversions, 0)
         AND ROUND(source_by_platform.source_spend_inr, 2)
             = ROUND(COALESCE(dashboard_by_platform.dashboard_spend_inr, 0), 2)
            THEN 'PASS'
        ELSE 'FAIL'
    END AS status

FROM
    (
        SELECT
            platform,
            SUM(impressions) AS source_impressions,
            SUM(clicks) AS source_clicks,
            SUM(conversions) AS source_conversions,
            SUM(spend_inr) AS source_spend_inr
        FROM source_platform_campaign_data
        GROUP BY platform
    ) source_by_platform

LEFT JOIN
    (
        SELECT
            platform,
            SUM(impressions) AS dashboard_impressions,
            SUM(clicks) AS dashboard_clicks,
            SUM(conversions) AS dashboard_conversions,
            SUM(spend_inr) AS dashboard_spend_inr
        FROM dashboard_export_campaign_data
        GROUP BY platform
    ) dashboard_by_platform
    ON source_by_platform.platform = dashboard_by_platform.platform

ORDER BY ABS(
    source_by_platform.source_spend_inr
    - COALESCE(dashboard_by_platform.dashboard_spend_inr, 0)
) DESC;


/*
================================================================================
Check 5: Metric comparison by report date
================================================================================

Question:
    Is the mismatch happening on specific dates?

Why this matters:
    If one or two dates are missing from the dashboard, this may indicate:
        - data refresh delay
        - failed load
        - date filter issue
        - partial pipeline run
================================================================================
*/

SELECT
    source_by_date.report_date,

    source_by_date.source_impressions,
    COALESCE(dashboard_by_date.dashboard_impressions, 0) AS dashboard_impressions,
    source_by_date.source_impressions
        - COALESCE(dashboard_by_date.dashboard_impressions, 0)
        AS impressions_difference,

    source_by_date.source_clicks,
    COALESCE(dashboard_by_date.dashboard_clicks, 0) AS dashboard_clicks,
    source_by_date.source_clicks
        - COALESCE(dashboard_by_date.dashboard_clicks, 0)
        AS clicks_difference,

    source_by_date.source_conversions,
    COALESCE(dashboard_by_date.dashboard_conversions, 0) AS dashboard_conversions,
    source_by_date.source_conversions
        - COALESCE(dashboard_by_date.dashboard_conversions, 0)
        AS conversions_difference,

    ROUND(source_by_date.source_spend_inr, 2) AS source_spend_inr,
    ROUND(COALESCE(dashboard_by_date.dashboard_spend_inr, 0), 2)
        AS dashboard_spend_inr,
    ROUND(
        source_by_date.source_spend_inr
        - COALESCE(dashboard_by_date.dashboard_spend_inr, 0),
        2
    ) AS spend_difference_inr,

    CASE
        WHEN source_by_date.source_impressions = COALESCE(dashboard_by_date.dashboard_impressions, 0)
         AND source_by_date.source_clicks = COALESCE(dashboard_by_date.dashboard_clicks, 0)
         AND source_by_date.source_conversions = COALESCE(dashboard_by_date.dashboard_conversions, 0)
         AND ROUND(source_by_date.source_spend_inr, 2)
             = ROUND(COALESCE(dashboard_by_date.dashboard_spend_inr, 0), 2)
            THEN 'PASS'
        ELSE 'FAIL'
    END AS status

FROM
    (
        SELECT
            report_date,
            SUM(impressions) AS source_impressions,
            SUM(clicks) AS source_clicks,
            SUM(conversions) AS source_conversions,
            SUM(spend_inr) AS source_spend_inr
        FROM source_platform_campaign_data
        GROUP BY report_date
    ) source_by_date

LEFT JOIN
    (
        SELECT
            report_date,
            SUM(impressions) AS dashboard_impressions,
            SUM(clicks) AS dashboard_clicks,
            SUM(conversions) AS dashboard_conversions,
            SUM(spend_inr) AS dashboard_spend_inr
        FROM dashboard_export_campaign_data
        GROUP BY report_date
    ) dashboard_by_date
    ON source_by_date.report_date = dashboard_by_date.report_date

ORDER BY rsource_by_date.report_date;


/*
================================================================================
Check 6: Metric comparison by state
================================================================================

Question:
    Is the mismatch concentrated in specific Indian states?

Why this matters:
    State-level mismatches can indicate regional mapping issues or dashboard
    filters excluding certain regions.
================================================================================
*/

SELECT
    source_by_state.state,

    source_by_state.source_impressions,
    COALESCE(dashboard_by_state.dashboard_impressions, 0) AS dashboard_impressions,
    source_by_state.source_impressions
        - COALESCE(dashboard_by_state.dashboard_impressions, 0)
        AS impressions_difference,

    source_by_state.source_clicks,
    COALESCE(dashboard_by_state.dashboard_clicks, 0) AS dashboard_clicks,
    source_by_state.source_clicks
        - COALESCE(dashboard_by_state.dashboard_clicks, 0)
        AS clicks_difference,

    source_by_state.source_conversions,
    COALESCE(dashboard_by_state.dashboard_conversions, 0) AS dashboard_conversions,
    source_by_state.source_conversions
        - COALESCE(dashboard_by_state.dashboard_conversions, 0)
        AS conversions_difference,

    ROUND(source_by_state.source_spend_inr, 2) AS source_spend_inr,
    ROUND(COALESCE(dashboard_by_state.dashboard_spend_inr, 0), 2)
        AS dashboard_spend_inr,
    ROUND(
        source_by_state.source_spend_inr
        - COALESCE(dashboard_by_state.dashboard_spend_inr, 0),
        2
    ) AS spend_difference_inr,

    CASE
        WHEN source_by_state.source_impressions = COALESCE(dashboard_by_state.dashboard_impressions, 0)
         AND source_by_state.source_clicks = COALESCE(dashboard_by_state.dashboard_clicks, 0)
         AND source_by_state.source_conversions = COALESCE(dashboard_by_state.dashboard_conversions, 0)
         AND ROUND(source_by_state.source_spend_inr, 2)
             = ROUND(COALESCE(dashboard_by_state.dashboard_spend_inr, 0), 2)
            THEN 'PASS'
        ELSE 'FAIL'
    END AS status

FROM
    (
        SELECT
            state,
            SUM(impressions) AS source_impressions,
            SUM(clicks) AS source_clicks,
            SUM(conversions) AS source_conversions,
            SUM(spend_inr) AS source_spend_inr
        FROM source_platform_campaign_data
        GROUP BY state
    ) source_by_state

LEFT JOIN
    (
        SELECT
            state,
            SUM(impressions) AS dashboard_impressions,
            SUM(clicks) AS dashboard_clicks,
            SUM(conversions) AS dashboard_conversions,
            SUM(spend_inr) AS dashboard_spend_inr
        FROM dashboard_export_campaign_data
        GROUP BY state
    ) dashboard_by_state
    ON source_by_state.state = dashboard_by_state.state

ORDER BY ABS(
    source_by_state.source_spend_inr
    - COALESCE(dashboard_by_state.dashboard_spend_inr, 0)
) DESC;


/*
================================================================================
Check 7: Metric comparison by device type
================================================================================

Question:
    Is the mismatch related to a device category?

Why this matters:
    Some dashboard filters may include only selected devices such as mobile,
    desktop, or tablet.
================================================================================
*/

SELECT
    source_by_device.device_type,

    source_by_device.source_impressions,
    COALESCE(dashboard_by_device.dashboard_impressions, 0) AS dashboard_impressions,
    source_by_device.source_impressions
        - COALESCE(dashboard_by_device.dashboard_impressions, 0)
        AS impressions_difference,

    source_by_device.source_clicks,
    COALESCE(dashboard_by_device.dashboard_clicks, 0) AS dashboard_clicks,
    source_by_device.source_clicks
        - COALESCE(dashboard_by_device.dashboard_clicks, 0)
        AS clicks_difference,

    source_by_device.source_conversions,
    COALESCE(dashboard_by_device.dashboard_conversions, 0) AS dashboard_conversions,
    source_by_device.source_conversions
        - COALESCE(dashboard_by_device.dashboard_conversions, 0)
        AS conversions_difference,

    ROUND(source_by_device.source_spend_inr, 2) AS source_spend_inr,
    ROUND(COALESCE(dashboard_by_device.dashboard_spend_inr, 0), 2)
        AS dashboard_spend_inr,
    ROUND(
        source_by_device.source_spend_inr
        - COALESCE(dashboard_by_device.dashboard_spend_inr, 0),
        2
    ) AS spend_difference_inr,

    CASE
        WHEN source_by_device.source_impressions = COALESCE(dashboard_by_device.dashboard_impressions, 0)
         AND source_by_device.source_clicks = COALESCE(dashboard_by_device.dashboard_clicks, 0)
         AND source_by_device.source_conversions = COALESCE(dashboard_by_device.dashboard_conversions, 0)
         AND ROUND(source_by_device.source_spend_inr, 2)
             = ROUND(COALESCE(dashboard_by_device.dashboard_spend_inr, 0), 2)
            THEN 'PASS'
        ELSE 'FAIL'
    END AS status

FROM
    (
        SELECT
            device_type,
            SUM(impressions) AS source_impressions,
            SUM(clicks) AS source_clicks,
            SUM(conversions) AS source_conversions,
            SUM(spend_inr) AS source_spend_inr
        FROM source_platform_campaign_data
        GROUP BY device_type
    ) source_by_device

LEFT JOIN
    (
        SELECT
            device_type,
            SUM(impressions) AS dashboard_impressions,
            SUM(clicks) AS dashboard_clicks,
            SUM(conversions) AS dashboard_conversions,
            SUM(spend_inr) AS dashboard_spend_inr
        FROM dashboard_export_campaign_data
        GROUP BY device_type
    ) dashboard_by_device
    ON source_by_device.device_type = dashboard_by_device.device_type

ORDER BY ABS(
    source_by_device.source_spend_inr
    - COALESCE(dashboard_by_device.dashboard_spend_inr, 0)
) DESC;


/*
================================================================================
Check 8: Final metric investigation summary
================================================================================

This gives a simple final conclusion for this file.
================================================================================
*/

SELECT
    'Total Metric Comparison' AS check_name,

    source_totals.source_impressions,
    dashboard_totals.dashboard_impressions,
    source_totals.source_impressions - dashboard_totals.dashboard_impressions
        AS impressions_difference,

    source_totals.source_clicks,
    dashboard_totals.dashboard_clicks,
    source_totals.source_clicks - dashboard_totals.dashboard_clicks
        AS clicks_difference,

    source_totals.source_conversions,
    dashboard_totals.dashboard_conversions,
    source_totals.source_conversions - dashboard_totals.dashboard_conversions
        AS conversions_difference,

    ROUND(source_totals.source_spend_inr, 2) AS source_spend_inr,
    ROUND(dashboard_totals.dashboard_spend_inr, 2) AS dashboard_spend_inr,
    ROUND(source_totals.source_spend_inr - dashboard_totals.dashboard_spend_inr, 2)
        AS spend_difference_inr,

    CASE
        WHEN source_totals.source_impressions = dashboard_totals.dashboard_impressions
         AND source_totals.source_clicks = dashboard_totals.dashboard_clicks
         AND source_totals.source_conversions = dashboard_totals.dashboard_conversions
         AND ROUND(source_totals.source_spend_inr, 2)
             = ROUND(dashboard_totals.dashboard_spend_inr, 2)
            THEN 'PASS - All total metrics match.'
        ELSE 'FAIL - One or more total metrics do not match. Further investigation required.'
    END AS conclusion

FROM
    (
        SELECT
            SUM(impressions) AS source_impressions,
            SUM(clicks) AS source_clicks,
            SUM(conversions) AS source_conversions,
            SUM(spend_inr) AS source_spend_inr
        FROM source_platform_campaign_data
    ) source_totals
CROSS JOIN
    (
        SELECT
            SUM(impressions) AS dashboard_impressions,
            SUM(clicks) AS dashboard_clicks,
            SUM(conversions) AS dashboard_conversions,
            SUM(spend_inr) AS dashboard_spend_inr
        FROM dashboard_export_campaign_data
    ) dashboard_totals;


/*
================================================================================
Learning Notes
================================================================================

1. Metric comparison is one of the most important investigation steps.

2. Always compare both:
       - overall totals
       - breakdown-level totals

3. If total spend is mismatching, break it down by:
       - platform
       - report date
       - campaign
       - state
       - city
       - device type

4. A metric mismatch can be caused by:
       - missing records
       - duplicate records
       - different filters
       - mapping exclusions
       - join issues
       - aggregation differences

5. The next SQL file will identify missing campaigns between source
   and dashboard datasets.
================================================================================
*/
