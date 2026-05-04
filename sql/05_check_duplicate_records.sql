/*
================================================================================
Project: Dashboard vs Source Data Mismatch Investigation
File: 05_check_duplicate_records.sql

Purpose:
    Identify duplicate records in source platform data and dashboard export data.

Why this check matters:
    Duplicate records can inflate metrics such as:
        - impressions
        - clicks
        - conversions
        - spend_inr

    In real-world data pipelines, duplicates can happen when:
        - the same file is loaded twice
        - incremental loads append instead of replacing records
        - merge/upsert logic fails
        - joins create multiple records
        - there is no proper business key

SQL Style:
    Beginner-friendly standard SQL / SQLite-friendly format
================================================================================
*/


/*
================================================================================
Business Key Used for Duplicate Checks
================================================================================

A business key is a combination of columns that should uniquely identify
one campaign performance record.

For this project, we use:

    campaign_id + report_date + platform + state + city + device_type

If the same combination appears more than once, it may be a duplicate.

Note:
    In real projects, the correct business key depends on the actual data model.
================================================================================
*/


/*
================================================================================
Check 1: Duplicate records in source data
================================================================================

Question:
    Does the source platform data contain duplicate records?

Why this matters:
    If source data has duplicates, source totals may be inflated before the
    data even reaches the dashboard.
================================================================================
*/

SELECT
    campaign_id,
    report_date,
    platform,
    state,
    city,
    device_type,
    COUNT(*) AS duplicate_count,
    SUM(impressions) AS total_impressions,
    SUM(clicks) AS total_clicks,
    SUM(conversions) AS total_conversions,
    ROUND(SUM(spend_inr), 2) AS total_spend_inr
FROM source_platform_campaign_data
GROUP BY
    campaign_id,
    report_date,
    platform,
    state,
    city,
    device_type
HAVING COUNT(*) > 1
ORDER BY
    duplicate_count DESC,
    total_spend_inr DESC;


/*
================================================================================
Check 2: Duplicate records in dashboard data
================================================================================

Question:
    Does the dashboard export contain duplicate records?

Why this matters:
    If dashboard data has duplicates, dashboard totals may be inflated.
================================================================================
*/

SELECT
    campaign_id,
    report_date,
    platform,
    state,
    city,
    device_type,
    COUNT(*) AS duplicate_count,
    SUM(impressions) AS total_impressions,
    SUM(clicks) AS total_clicks,
    SUM(conversions) AS total_conversions,
    ROUND(SUM(spend_inr), 2) AS total_spend_inr
FROM dashboard_export_campaign_data
GROUP BY
    campaign_id,
    report_date,
    platform,
    state,
    city,
    device_type
HAVING COUNT(*) > 1
ORDER BY
    duplicate_count DESC,
    total_spend_inr DESC;


/*
================================================================================
Check 3: Count duplicate groups in both datasets
================================================================================

Question:
    How many duplicate groups exist in source and dashboard data?

A duplicate group means one business key appears more than once.
================================================================================
*/

SELECT
    'source_platform_campaign_data' AS dataset_name,
    COUNT(*) AS duplicate_group_count
FROM
    (
        SELECT
            campaign_id,
            report_date,
            platform,
            state,
            city,
            device_type,
            COUNT(*) AS record_count
        FROM source_platform_campaign_data
        GROUP BY
            campaign_id,
            report_date,
            platform,
            state,
            city,
            device_type
        HAVING COUNT(*) > 1
    ) source_duplicates

UNION ALL

SELECT
    'dashboard_export_campaign_data' AS dataset_name,
    COUNT(*) AS duplicate_group_count
FROM
    (
        SELECT
            campaign_id,
            report_date,
            platform,
            state,
            city,
            device_type,
            COUNT(*) AS record_count
        FROM dashboard_export_campaign_data
        GROUP BY
            campaign_id,
            report_date,
            platform,
            state,
            city,
            device_type
        HAVING COUNT(*) > 1
    ) dashboard_duplicates;


/*
================================================================================
Check 4: Calculate metric impact of source duplicates
================================================================================

Question:
    If duplicates exist in source data, how much metric value is affected?

Why this matters:
    This helps estimate how much impressions, clicks, conversions, and spend
    may be over-counted due to duplicate source records.
================================================================================
*/

SELECT
    COUNT(*) AS duplicate_group_count,
    SUM(duplicate_count) AS total_records_in_duplicate_groups,
    SUM(duplicate_count - 1) AS estimated_extra_duplicate_rows,
    SUM(total_impressions) AS affected_impressions,
    SUM(total_clicks) AS affected_clicks,
    SUM(total_conversions) AS affected_conversions,
    ROUND(SUM(total_spend_inr), 2) AS affected_spend_inr
FROM
    (
        SELECT
            campaign_id,
            report_date,
            platform,
            state,
            city,
            device_type,
            COUNT(*) AS duplicate_count,
            SUM(impressions) AS total_impressions,
            SUM(clicks) AS total_clicks,
            SUM(conversions) AS total_conversions,
            SUM(spend_inr) AS total_spend_inr
        FROM source_platform_campaign_data
        GROUP BY
            campaign_id,
            report_date,
            platform,
            state,
            city,
            device_type
        HAVING COUNT(*) > 1
    ) source_duplicate_summary;


/*
================================================================================
Check 5: Calculate metric impact of dashboard duplicates
================================================================================

Question:
    If duplicates exist in dashboard data, how much metric value is affected?

Why this matters:
    This helps estimate how much dashboard metrics may be over-counted due to
    duplicate reporting records.
================================================================================
*/

SELECT
    COUNT(*) AS duplicate_group_count,
    SUM(duplicate_count) AS total_records_in_duplicate_groups,
    SUM(duplicate_count - 1) AS estimated_extra_duplicate_rows,
    SUM(total_impressions) AS affected_impressions,
    SUM(total_clicks) AS affected_clicks,
    SUM(total_conversions) AS affected_conversions,
    ROUND(SUM(total_spend_inr), 2) AS affected_spend_inr
FROM
    (
        SELECT
            campaign_id,
            report_date,
            platform,
            state,
            city,
            device_type,
            COUNT(*) AS duplicate_count,
            SUM(impressions) AS total_impressions,
            SUM(clicks) AS total_clicks,
            SUM(conversions) AS total_conversions,
            SUM(spend_inr) AS total_spend_inr
        FROM dashboard_export_campaign_data
        GROUP BY
            campaign_id,
            report_date,
            platform,
            state,
            city,
            device_type
        HAVING COUNT(*) > 1
    ) dashboard_duplicate_summary;


/*
================================================================================
Check 6: Duplicate records by platform
================================================================================

Question:
    Are duplicate records concentrated in a specific platform?

Why this matters:
    If duplicates are mostly in one platform, the issue may be caused by a
    platform-specific load or transformation problem.
================================================================================
*/

SELECT
    'source_platform_campaign_data' AS dataset_name,
    platform,
    COUNT(*) AS duplicate_group_count,
    SUM(duplicate_count - 1) AS estimated_extra_duplicate_rows,
    ROUND(SUM(total_spend_inr), 2) AS affected_spend_inr
FROM
    (
        SELECT
            platform,
            campaign_id,
            report_date,
            state,
            city,
            device_type,
            COUNT(*) AS duplicate_count,
            SUM(spend_inr) AS total_spend_inr
        FROM source_platform_campaign_data
        GROUP BY
            platform,
            campaign_id,
            report_date,
            state,
            city,
            device_type
        HAVING COUNT(*) > 1
    ) source_platform_duplicates
GROUP BY
    platform

UNION ALL

SELECT
    'dashboard_export_campaign_data' AS dataset_name,
    platform,
    COUNT(*) AS duplicate_group_count,
    SUM(duplicate_count - 1) AS estimated_extra_duplicate_rows,
    ROUND(SUM(total_spend_inr), 2) AS affected_spend_inr
FROM
    (
        SELECT
            platform,
            campaign_id,
            report_date,
            state,
            city,
            device_type,
            COUNT(*) AS duplicate_count,
            SUM(spend_inr) AS total_spend_inr
        FROM dashboard_export_campaign_data
        GROUP BY
            platform,
            campaign_id,
            report_date,
            state,
            city,
            device_type
        HAVING COUNT(*) > 1
    ) dashboard_platform_duplicates
GROUP BY
    platform
ORDER BY
    affected_spend_inr DESC;


/*
================================================================================
Check 7: Duplicate records by report date
================================================================================

Question:
    Are duplicates concentrated on a specific date?

Why this matters:
    Date-level duplicate patterns may indicate repeated file loads or failed
    incremental logic for a specific reporting day.
================================================================================
*/

SELECT
    'source_platform_campaign_data' AS dataset_name,
    report_date,
    COUNT(*) AS duplicate_group_count,
    SUM(duplicate_count - 1) AS estimated_extra_duplicate_rows,
    ROUND(SUM(total_spend_inr), 2) AS affected_spend_inr
FROM
    (
        SELECT
            report_date,
            campaign_id,
            platform,
            state,
            city,
            device_type,
            COUNT(*) AS duplicate_count,
            SUM(spend_inr) AS total_spend_inr
        FROM source_platform_campaign_data
        GROUP BY
            report_date,
            campaign_id,
            platform,
            state,
            city,
            device_type
        HAVING COUNT(*) > 1
    ) source_date_duplicates
GROUP BY
    report_date

UNION ALL

SELECT
    'dashboard_export_campaign_data' AS dataset_name,
    report_date,
    COUNT(*) AS duplicate_group_count,
    SUM(duplicate_count - 1) AS estimated_extra_duplicate_rows,
    ROUND(SUM(total_spend_inr), 2) AS affected_spend_inr
FROM
    (
        SELECT
            report_date,
            campaign_id,
            platform,
            state,
            city,
            device_type,
            COUNT(*) AS duplicate_count,
            SUM(spend_inr) AS total_spend_inr
        FROM dashboard_export_campaign_data
        GROUP BY
            report_date,
            campaign_id,
            platform,
            state,
            city,
            device_type
        HAVING COUNT(*) > 1
    ) dashboard_date_duplicates
GROUP BY
    report_date
ORDER BY
    report_date;


/*
================================================================================
Check 8: Compare unique row IDs with total rows
================================================================================

Question:
    Are row IDs unique?

Why this matters:
    Technical row IDs should usually be unique.
    If row IDs repeat, it may indicate a data load issue.
================================================================================
*/

SELECT
    'source_platform_campaign_data' AS dataset_name,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT source_row_id) AS unique_row_ids,
    COUNT(*) - COUNT(DISTINCT source_row_id) AS duplicate_row_id_count
FROM source_platform_campaign_data

UNION ALL

SELECT
    'dashboard_export_campaign_data' AS dataset_name,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT dashboard_row_id) AS unique_row_ids,
    COUNT(*) - COUNT(DISTINCT dashboard_row_id) AS duplicate_row_id_count
FROM dashboard_export_campaign_data;


/*
================================================================================
Check 9: Final duplicate investigation summary
================================================================================

This gives a simple final conclusion for duplicate checks.
================================================================================
*/

SELECT
    dataset_name,
    duplicate_group_count,
    estimated_extra_duplicate_rows,

    CASE
        WHEN duplicate_group_count = 0
            THEN 'PASS - No duplicate business keys found.'
        ELSE 'FAIL - Duplicate business keys found. Investigate load, join, or incremental logic.'
    END AS conclusion

FROM
    (
        SELECT
            'source_platform_campaign_data' AS dataset_name,
            COUNT(*) AS duplicate_group_count,
            COALESCE(SUM(record_count - 1), 0) AS estimated_extra_duplicate_rows
        FROM
            (
                SELECT
                    campaign_id,
                    report_date,
                    platform,
                    state,
                    city,
                    device_type,
                    COUNT(*) AS record_count
                FROM source_platform_campaign_data
                GROUP BY
                    campaign_id,
                    report_date,
                    platform,
                    state,
                    city,
                    device_type
                HAVING COUNT(*) > 1
            ) source_duplicate_groups

        UNION ALL

        SELECT
            'dashboard_export_campaign_data' AS dataset_name,
            COUNT(*) AS duplicate_group_count,
            COALESCE(SUM(record_count - 1), 0) AS estimated_extra_duplicate_rows
        FROM
            (
                SELECT
                    campaign_id,
                    report_date,
                    platform,
                    state,
                    city,
                    device_type,
                    COUNT(*) AS record_count
                FROM dashboard_export_campaign_data
                GROUP BY
                    campaign_id,
                    report_date,
                    platform,
                    state,
                    city,
                    device_type
                HAVING COUNT(*) > 1
            ) dashboard_duplicate_groups
    ) duplicate_summary;


/*
================================================================================
Learning Notes
================================================================================

1. Duplicate checks are important in every data reconciliation project.

2. A row ID duplicate is a technical duplicate issue.

3. A business key duplicate is usually more important for reporting accuracy.

4. Duplicate records can happen due to:
       - repeated file loads
       - incorrect incremental loads
       - incorrect joins
       - missing primary keys
       - manual data uploads

5. Duplicates can inflate source or dashboard totals.

6. The next SQL file will create a final reconciliation summary combining
   record count, metric, missing record, and duplicate investigation results.
================================================================================
*/
