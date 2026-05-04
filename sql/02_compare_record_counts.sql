/*
================================================================================
Project: Dashboard vs Source Data Mismatch Investigation
File: 02_compare_record_counts.sql

Purpose:
    Compare record counts between the source platform data and dashboard export
    data to identify whether rows are missing or extra.

Why this check matters:
    Before comparing spend, clicks, impressions, or conversions, a data engineer
    should first check whether both datasets have the same number of records.

    If the source has more rows than the dashboard, some records may have been
    dropped during transformation, mapping, filtering, or dashboard export.

    If the dashboard has more rows than the source, there may be duplicate data,
    stale data, or incorrect reporting logic.

SQL Style:
    Beginner-friendly standard SQL / SQLite-friendly format
================================================================================
*/


/*
================================================================================
Check 1: Count total rows in each dataset
================================================================================

Question:
    How many rows are available in source data and dashboard data?

Expected learning:
    This gives the first high-level signal of whether data is missing or extra.
================================================================================
*/

SELECT
    'source_platform_campaign_data' AS dataset_name,
    COUNT(*) AS total_rows
FROM source_platform_campaign_data

UNION ALL

SELECT
    'dashboard_export_campaign_data' AS dataset_name,
    COUNT(*) AS total_rows
FROM dashboard_export_campaign_data;


/*
================================================================================
Check 2: Show row count difference
================================================================================

Question:
    What is the exact difference between source row count and dashboard row count?

Interpretation:
    - If row_count_difference = 0, both datasets have the same number of rows.
    - If row_count_difference > 0, source has more rows than dashboard.
    - If row_count_difference < 0, dashboard has more rows than source.
================================================================================
*/

SELECT
    source_counts.source_total_rows,
    dashboard_counts.dashboard_total_rows,
    source_counts.source_total_rows - dashboard_counts.dashboard_total_rows
        AS row_count_difference
FROM
    (
        SELECT COUNT(*) AS source_total_rows
        FROM source_platform_campaign_data
    ) source_counts
CROSS JOIN
    (
        SELECT COUNT(*) AS dashboard_total_rows
        FROM dashboard_export_campaign_data
    ) dashboard_counts;


/*
================================================================================
Check 3: Add simple investigation status
================================================================================

Question:
    Does the row count comparison pass or fail?

This creates a beginner-friendly status column.
================================================================================
*/

SELECT
    source_counts.source_total_rows,
    dashboard_counts.dashboard_total_rows,
    source_counts.source_total_rows - dashboard_counts.dashboard_total_rows
        AS row_count_difference,

    CASE
        WHEN source_counts.source_total_rows = dashboard_counts.dashboard_total_rows
            THEN 'PASS - Row counts match'
        WHEN source_counts.source_total_rows > dashboard_counts.dashboard_total_rows
            THEN 'FAIL - Source has more rows than dashboard'
        WHEN source_counts.source_total_rows < dashboard_counts.dashboard_total_rows
            THEN 'FAIL - Dashboard has more rows than source'
        ELSE 'CHECK REQUIRED'
    END AS investigation_status

FROM
    (
        SELECT COUNT(*) AS source_total_rows
        FROM source_platform_campaign_data
    ) source_counts
CROSS JOIN
    (
        SELECT COUNT(*) AS dashboard_total_rows
        FROM dashboard_export_campaign_data
    ) dashboard_counts;


/*
================================================================================
Check 4: Compare row counts by platform
================================================================================

Question:
    Is the mismatch happening across all platforms or only selected platforms?

Why this matters:
    Sometimes the overall row count looks close, but one specific platform may
    have missing or extra rows.

Example:
    Google Ads may match, but Meta Ads may have missing rows.
================================================================================
*/

SELECT
    COALESCE(source_by_platform.platform, dashboard_by_platform.platform)
        AS platform,

    COALESCE(source_by_platform.source_rows, 0)
        AS source_rows,

    COALESCE(dashboard_by_platform.dashboard_rows, 0)
        AS dashboard_rows,

    COALESCE(source_by_platform.source_rows, 0)
        - COALESCE(dashboard_by_platform.dashboard_rows, 0)
        AS row_difference,

    CASE
        WHEN COALESCE(source_by_platform.source_rows, 0)
             = COALESCE(dashboard_by_platform.dashboard_rows, 0)
            THEN 'PASS'
        ELSE 'FAIL'
    END AS status

FROM
    (
        SELECT
            platform,
            COUNT(*) AS source_rows
        FROM source_platform_campaign_data
        GROUP BY platform
    ) source_by_platform

LEFT JOIN
    (
        SELECT
            platform,
            COUNT(*) AS dashboard_rows
        FROM dashboard_export_campaign_data
        GROUP BY platform
    ) dashboard_by_platform
    ON source_by_platform.platform = dashboard_by_platform.platform

UNION ALL

SELECT
    dashboard_by_platform.platform,
    0 AS source_rows,
    dashboard_by_platform.dashboard_rows,
    0 - dashboard_by_platform.dashboard_rows AS row_difference,
    'FAIL - Platform exists only in dashboard' AS status

FROM
    (
        SELECT
            platform,
            COUNT(*) AS dashboard_rows
        FROM dashboard_export_campaign_data
        GROUP BY platform
    ) dashboard_by_platform

LEFT JOIN
    (
        SELECT
            platform,
            COUNT(*) AS source_rows
        FROM source_platform_campaign_data
        GROUP BY platform
    ) source_by_platform
    ON dashboard_by_platform.platform = source_by_platform.platform

WHERE source_by_platform.platform IS NULL;


/*
================================================================================
Check 5: Compare row counts by report date
================================================================================

Question:
    Is data missing for a specific date?

Why this matters:
    If the dashboard missed one reporting day, total spend, clicks, impressions,
    and conversions will all be lower.
================================================================================
*/

SELECT
    COALESCE(source_by_date.report_date, dashboard_by_date.report_date)
        AS report_date,

    COALESCE(source_by_date.source_rows, 0)
        AS source_rows,

    COALESCE(dashboard_by_date.dashboard_rows, 0)
        AS dashboard_rows,

    COALESCE(source_by_date.source_rows, 0)
        - COALESCE(dashboard_by_date.dashboard_rows, 0)
        AS row_difference,

    CASE
        WHEN COALESCE(source_by_date.source_rows, 0)
             = COALESCE(dashboard_by_date.dashboard_rows, 0)
            THEN 'PASS'
        ELSE 'FAIL'
    END AS status

FROM
    (
        SELECT
            report_date,
            COUNT(*) AS source_rows
        FROM source_platform_campaign_data
        GROUP BY report_date
    ) source_by_date

LEFT JOIN
    (
        SELECT
            report_date,
            COUNT(*) AS dashboard_rows
        FROM dashboard_export_campaign_data
        GROUP BY report_date
    ) dashboard_by_date
    ON source_by_date.report_date = dashboard_by_date.report_date

UNION ALL

SELECT
    dashboard_by_date.report_date,
    0 AS source_rows,
    dashboard_by_date.dashboard_rows,
    0 - dashboard_by_date.dashboard_rows AS row_difference,
    'FAIL - Date exists only in dashboard' AS status

FROM
    (
        SELECT
            report_date,
            COUNT(*) AS dashboard_rows
        FROM dashboard_export_campaign_data
        GROUP BY report_date
    ) dashboard_by_date

LEFT JOIN
    (
        SELECT
            report_date,
            COUNT(*) AS source_rows
        FROM source_platform_campaign_data
        GROUP BY report_date
    ) source_by_date
    ON dashboard_by_date.report_date = source_by_date.report_date

WHERE source_by_date.report_date IS NULL;


/*
================================================================================
Check 6: Compare row counts by state
================================================================================

Question:
    Is the mismatch happening in a specific Indian state?

Why this matters:
    Regional mapping or filtering issues can cause records from selected states
    to be missing from the dashboard.
================================================================================
*/

SELECT
    COALESCE(source_by_state.state, dashboard_by_state.state)
        AS state,

    COALESCE(source_by_state.source_rows, 0)
        AS source_rows,

    COALESCE(dashboard_by_state.dashboard_rows, 0)
        AS dashboard_rows,

    COALESCE(source_by_state.source_rows, 0)
        - COALESCE(dashboard_by_state.dashboard_rows, 0)
        AS row_difference,

    CASE
        WHEN COALESCE(source_by_state.source_rows, 0)
             = COALESCE(dashboard_by_state.dashboard_rows, 0)
            THEN 'PASS'
        ELSE 'FAIL'
    END AS status

FROM
    (
        SELECT
            state,
            COUNT(*) AS source_rows
        FROM source_platform_campaign_data
        GROUP BY state
    ) source_by_state

LEFT JOIN
    (
        SELECT
            state,
            COUNT(*) AS dashboard_rows
        FROM dashboard_export_campaign_data
        GROUP BY state
    ) dashboard_by_state
    ON source_by_state.state = dashboard_by_state.state

UNION ALL

SELECT
    dashboard_by_state.state,
    0 AS source_rows,
    dashboard_by_state.dashboard_rows,
    0 - dashboard_by_state.dashboard_rows AS row_difference,
    'FAIL - State exists only in dashboard' AS status

FROM
    (
        SELECT
            state,
            COUNT(*) AS dashboard_rows
        FROM dashboard_export_campaign_data
        GROUP BY state
    ) dashboard_by_state

LEFT JOIN
    (
        SELECT
            state,
            COUNT(*) AS source_rows
        FROM source_platform_campaign_data
        GROUP BY state
    ) source_by_state
    ON dashboard_by_state.state = source_by_state.state

WHERE source_by_state.state IS NULL;


/*
================================================================================
Check 7: Final record count investigation summary
================================================================================

This gives a simple final conclusion for this file.
================================================================================
*/

SELECT
    'Record Count Check' AS check_name,

    source_counts.source_total_rows,
    dashboard_counts.dashboard_total_rows,

    source_counts.source_total_rows - dashboard_counts.dashboard_total_rows
        AS row_count_difference,

    CASE
        WHEN source_counts.source_total_rows = dashboard_counts.dashboard_total_rows
            THEN 'No row count mismatch found at overall level.'
        WHEN source_counts.source_total_rows > dashboard_counts.dashboard_total_rows
            THEN 'Source has more rows. Investigate missing records in dashboard.'
        WHEN source_counts.source_total_rows < dashboard_counts.dashboard_total_rows
            THEN 'Dashboard has more rows. Investigate duplicate, stale, or extra dashboard records.'
        ELSE 'Further investigation required.'
    END AS conclusion

FROM
    (
        SELECT COUNT(*) AS source_total_rows
        FROM source_platform_campaign_data
    ) source_counts
CROSS JOIN
    (
        SELECT COUNT(*) AS dashboard_total_rows
        FROM dashboard_export_campaign_data
    ) dashboard_counts;


/*
================================================================================
Learning Notes
================================================================================

1. Record count comparison is usually the first investigation step.

2. If row counts do not match, do not immediately assume the dashboard is wrong.
   First identify where the difference is happening:
       - by platform
       - by date
       - by state
       - by campaign
       - by device type

3. Row count mismatch does not always mean metric mismatch, but it is a strong
   signal that deeper investigation is required.

4. The next SQL file compares total metrics:
       - impressions
       - clicks
       - conversions
       - spend_inr
================================================================================
*/
