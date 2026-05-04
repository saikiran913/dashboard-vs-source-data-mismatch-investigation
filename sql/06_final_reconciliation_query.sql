/*
================================================================================
Project: Dashboard vs Source Data Mismatch Investigation
File: 06_final_reconciliation_query.sql

Purpose:
    Create a final reconciliation summary between source platform data and
    dashboard export data.

Why this file matters:
    In real-world data engineering investigations, after checking row counts,
    total metrics, missing records, and duplicate records, we need to prepare
    a final summary.

    This file helps answer:

        - Do source and dashboard record counts match?
        - Do total metrics match?
        - How much is the spend/click/conversion mismatch?
        - Are records missing from dashboard?
        - Are duplicate records present?
        - Are campaign mapping issues present?
        - What is the final investigation status?

SQL Style:
    Beginner-friendly standard SQL / SQLite-friendly format
================================================================================
*/


/*
================================================================================
Check 1: Final source vs dashboard summary
================================================================================

This query gives one high-level reconciliation output.

It compares:
    - row count
    - impressions
    - clicks
    - conversions
    - spend_inr

Interpretation:
    Positive difference means source is higher than dashboard.
    Negative difference means dashboard is higher than source.
================================================================================
*/

SELECT
    'Final Source vs Dashboard Reconciliation' AS check_name,

    source_summary.source_total_rows,
    dashboard_summary.dashboard_total_rows,
    source_summary.source_total_rows - dashboard_summary.dashboard_total_rows
        AS row_count_difference,

    source_summary.source_impressions,
    dashboard_summary.dashboard_impressions,
    source_summary.source_impressions - dashboard_summary.dashboard_impressions
        AS impressions_difference,

    source_summary.source_clicks,
    dashboard_summary.dashboard_clicks,
    source_summary.source_clicks - dashboard_summary.dashboard_clicks
        AS clicks_difference,

    source_summary.source_conversions,
    dashboard_summary.dashboard_conversions,
    source_summary.source_conversions - dashboard_summary.dashboard_conversions
        AS conversions_difference,

    ROUND(source_summary.source_spend_inr, 2) AS source_spend_inr,
    ROUND(dashboard_summary.dashboard_spend_inr, 2) AS dashboard_spend_inr,
    ROUND(source_summary.source_spend_inr - dashboard_summary.dashboard_spend_inr, 2)
        AS spend_difference_inr,

    ROUND(
        ((source_summary.source_spend_inr - dashboard_summary.dashboard_spend_inr) * 100.0)
        / NULLIF(source_summary.source_spend_inr, 0),
        2
    ) AS spend_difference_percentage,

    CASE
        WHEN source_summary.source_total_rows = dashboard_summary.dashboard_total_rows
         AND source_summary.source_impressions = dashboard_summary.dashboard_impressions
         AND source_summary.source_clicks = dashboard_summary.dashboard_clicks
         AND source_summary.source_conversions = dashboard_summary.dashboard_conversions
         AND ROUND(source_summary.source_spend_inr, 2) = ROUND(dashboard_summary.dashboard_spend_inr, 2)
            THEN 'PASS - Source and dashboard match at overall level.'
        ELSE 'FAIL - Source and dashboard do not match. Further investigation required.'
    END AS final_status

FROM
    (
        SELECT
            COUNT(*) AS source_total_rows,
            SUM(impressions) AS source_impressions,
            SUM(clicks) AS source_clicks,
            SUM(conversions) AS source_conversions,
            SUM(spend_inr) AS source_spend_inr
        FROM source_platform_campaign_data
    ) source_summary
CROSS JOIN
    (
        SELECT
            COUNT(*) AS dashboard_total_rows,
            SUM(impressions) AS dashboard_impressions,
            SUM(clicks) AS dashboard_clicks,
            SUM(conversions) AS dashboard_conversions,
            SUM(spend_inr) AS dashboard_spend_inr
        FROM dashboard_export_campaign_data
    ) dashboard_summary;


/*
================================================================================
Check 2: Final investigation health check
================================================================================

This query summarises the major investigation areas:

    1. Overall row count difference
    2. Overall spend difference
    3. Missing source records from dashboard
    4. Duplicate groups in source
    5. Duplicate groups in dashboard
    6. Campaign mapping issues

This is useful for a final investigation report.
================================================================================
*/

WITH
source_summary AS (
    SELECT
        COUNT(*) AS source_total_rows,
        SUM(impressions) AS source_impressions,
        SUM(clicks) AS source_clicks,
        SUM(conversions) AS source_conversions,
        SUM(spend_inr) AS source_spend_inr
    FROM source_platform_campaign_data
),

dashboard_summary AS (
    SELECT
        COUNT(*) AS dashboard_total_rows,
        SUM(impressions) AS dashboard_impressions,
        SUM(clicks) AS dashboard_clicks,
        SUM(conversions) AS dashboard_conversions,
        SUM(spend_inr) AS dashboard_spend_inr
    FROM dashboard_export_campaign_data
),

missing_records AS (
    SELECT
        COUNT(*) AS missing_record_count,
        COUNT(DISTINCT s.campaign_id) AS missing_campaign_count,
        COALESCE(SUM(s.impressions), 0) AS missing_impressions,
        COALESCE(SUM(s.clicks), 0) AS missing_clicks,
        COALESCE(SUM(s.conversions), 0) AS missing_conversions,
        COALESCE(SUM(s.spend_inr), 0) AS missing_spend_inr
    FROM source_platform_campaign_data s
    LEFT JOIN dashboard_export_campaign_data d
        ON s.campaign_id = d.campaign_id
       AND s.report_date = d.report_date
       AND s.platform = d.platform
       AND s.state = d.state
       AND s.city = d.city
       AND s.device_type = d.device_type
    WHERE d.campaign_id IS NULL
),

source_duplicates AS (
    SELECT
        COUNT(*) AS source_duplicate_group_count,
        COALESCE(SUM(record_count - 1), 0) AS source_extra_duplicate_rows
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
        ) duplicate_source_groups
),

dashboard_duplicates AS (
    SELECT
        COUNT(*) AS dashboard_duplicate_group_count,
        COALESCE(SUM(record_count - 1), 0) AS dashboard_extra_duplicate_rows
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
        ) duplicate_dashboard_groups
),

mapping_issues AS (
    SELECT
        COUNT(DISTINCT s.campaign_id) AS source_campaigns_missing_mapping
    FROM source_platform_campaign_data s
    LEFT JOIN campaign_mapping_reference_data m
        ON s.campaign_id = m.campaign_id
    WHERE m.campaign_id IS NULL
       OR m.mapping_status IS NULL
       OR LOWER(m.mapping_status) <> 'active'
)

SELECT
    source_summary.source_total_rows,
    dashboard_summary.dashboard_total_rows,
    source_summary.source_total_rows - dashboard_summary.dashboard_total_rows
        AS row_count_difference,

    ROUND(source_summary.source_spend_inr, 2) AS source_spend_inr,
    ROUND(dashboard_summary.dashboard_spend_inr, 2) AS dashboard_spend_inr,
    ROUND(source_summary.source_spend_inr - dashboard_summary.dashboard_spend_inr, 2)
        AS spend_difference_inr,

    missing_records.missing_record_count,
    missing_records.missing_campaign_count,
    ROUND(missing_records.missing_spend_inr, 2) AS missing_spend_inr,

    source_duplicates.source_duplicate_group_count,
    source_duplicates.source_extra_duplicate_rows,

    dashboard_duplicates.dashboard_duplicate_group_count,
    dashboard_duplicates.dashboard_extra_duplicate_rows,

    mapping_issues.source_campaigns_missing_mapping,

    CASE
        WHEN source_summary.source_total_rows = dashboard_summary.dashboard_total_rows
         AND ROUND(source_summary.source_spend_inr, 2) = ROUND(dashboard_summary.dashboard_spend_inr, 2)
         AND missing_records.missing_record_count = 0
         AND source_duplicates.source_duplicate_group_count = 0
         AND dashboard_duplicates.dashboard_duplicate_group_count = 0
         AND mapping_issues.source_campaigns_missing_mapping = 0
            THEN 'PASS - No major mismatch issues found.'

        WHEN missing_records.missing_record_count > 0
         AND mapping_issues.source_campaigns_missing_mapping > 0
            THEN 'FAIL - Missing dashboard records and campaign mapping issues found.'

        WHEN missing_records.missing_record_count > 0
            THEN 'FAIL - Source records are missing from dashboard.'

        WHEN dashboard_duplicates.dashboard_duplicate_group_count > 0
            THEN 'FAIL - Dashboard contains duplicate business records.'

        WHEN source_duplicates.source_duplicate_group_count > 0
            THEN 'FAIL - Source contains duplicate business records.'

        WHEN mapping_issues.source_campaigns_missing_mapping > 0
            THEN 'FAIL - Source campaigns have missing or inactive mapping records.'

        ELSE 'CHECK REQUIRED - Mismatch found but root cause needs deeper investigation.'
    END AS investigation_conclusion

FROM source_summary
CROSS JOIN dashboard_summary
CROSS JOIN missing_records
CROSS JOIN source_duplicates
CROSS JOIN dashboard_duplicates
CROSS JOIN mapping_issues;


/*
================================================================================
Check 3: Final mismatch by platform
================================================================================

This helps identify which platform contributes most to the mismatch.

Useful for stakeholder explanation:
    "Most of the mismatch is coming from Meta Ads and Programmatic Ads."
================================================================================
*/

SELECT
    source_by_platform.platform,

    source_by_platform.source_rows,
    COALESCE(dashboard_by_platform.dashboard_rows, 0) AS dashboard_rows,
    source_by_platform.source_rows - COALESCE(dashboard_by_platform.dashboard_rows, 0)
        AS row_difference,

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
        WHEN source_by_platform.source_rows = COALESCE(dashboard_by_platform.dashboard_rows, 0)
         AND ROUND(source_by_platform.source_spend_inr, 2)
             = ROUND(COALESCE(dashboard_by_platform.dashboard_spend_inr, 0), 2)
            THEN 'PASS'
        ELSE 'FAIL'
    END AS status

FROM
    (
        SELECT
            platform,
            COUNT(*) AS source_rows,
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
            COUNT(*) AS dashboard_rows,
            SUM(impressions) AS dashboard_impressions,
            SUM(clicks) AS dashboard_clicks,
            SUM(conversions) AS dashboard_conversions,
            SUM(spend_inr) AS dashboard_spend_inr
        FROM dashboard_export_campaign_data
        GROUP BY platform
    ) dashboard_by_platform
    ON source_by_platform.platform = dashboard_by_platform.platform

ORDER BY
    ABS(
        source_by_platform.source_spend_inr
        - COALESCE(dashboard_by_platform.dashboard_spend_inr, 0)
    ) DESC;


/*
================================================================================
Check 4: Final mismatch by campaign
================================================================================

This query identifies the campaign-level differences.

Why this matters:
    Even if platform-level numbers show the issue, campaign-level output helps
    identify the exact campaigns that need fixing.
================================================================================
*/

SELECT
    source_by_campaign.campaign_id,
    source_by_campaign.campaign_name,
    source_by_campaign.platform,

    source_by_campaign.source_rows,
    COALESCE(dashboard_by_campaign.dashboard_rows, 0) AS dashboard_rows,
    source_by_campaign.source_rows - COALESCE(dashboard_by_campaign.dashboard_rows, 0)
        AS row_difference,

    ROUND(source_by_campaign.source_spend_inr, 2) AS source_spend_inr,
    ROUND(COALESCE(dashboard_by_campaign.dashboard_spend_inr, 0), 2)
        AS dashboard_spend_inr,
    ROUND(
        source_by_campaign.source_spend_inr
        - COALESCE(dashboard_by_campaign.dashboard_spend_inr, 0),
        2
    ) AS spend_difference_inr,

    source_by_campaign.source_clicks,
    COALESCE(dashboard_by_campaign.dashboard_clicks, 0) AS dashboard_clicks,
    source_by_campaign.source_clicks
        - COALESCE(dashboard_by_campaign.dashboard_clicks, 0)
        AS clicks_difference,

    source_by_campaign.source_conversions,
    COALESCE(dashboard_by_campaign.dashboard_conversions, 0) AS dashboard_conversions,
    source_by_campaign.source_conversions
        - COALESCE(dashboard_by_campaign.dashboard_conversions, 0)
        AS conversions_difference,

    CASE
        WHEN COALESCE(dashboard_by_campaign.dashboard_rows, 0) = 0
            THEN 'Campaign missing from dashboard'
        WHEN source_by_campaign.source_rows <> COALESCE(dashboard_by_campaign.dashboard_rows, 0)
            THEN 'Row count mismatch for campaign'
        WHEN ROUND(source_by_campaign.source_spend_inr, 2)
             <> ROUND(COALESCE(dashboard_by_campaign.dashboard_spend_inr, 0), 2)
            THEN 'Metric mismatch for campaign'
        ELSE 'Campaign matches'
    END AS campaign_status

FROM
    (
        SELECT
            campaign_id,
            campaign_name,
            platform,
            COUNT(*) AS source_rows,
            SUM(spend_inr) AS source_spend_inr,
            SUM(clicks) AS source_clicks,
            SUM(conversions) AS source_conversions
        FROM source_platform_campaign_data
        GROUP BY
            campaign_id,
            campaign_name,
            platform
    ) source_by_campaign

LEFT JOIN
    (
        SELECT
            campaign_id,
            campaign_name,
            platform,
            COUNT(*) AS dashboard_rows,
            SUM(spend_inr) AS dashboard_spend_inr,
            SUM(clicks) AS dashboard_clicks,
            SUM(conversions) AS dashboard_conversions
        FROM dashboard_export_campaign_data
        GROUP BY
            campaign_id,
            campaign_name,
            platform
    ) dashboard_by_campaign
    ON source_by_campaign.campaign_id = dashboard_by_campaign.campaign_id
   AND source_by_campaign.platform = dashboard_by_campaign.platform

WHERE
    source_by_campaign.source_rows <> COALESCE(dashboard_by_campaign.dashboard_rows, 0)
    OR ROUND(source_by_campaign.source_spend_inr, 2)
       <> ROUND(COALESCE(dashboard_by_campaign.dashboard_spend_inr, 0), 2)
    OR source_by_campaign.source_clicks
       <> COALESCE(dashboard_by_campaign.dashboard_clicks, 0)
    OR source_by_campaign.source_conversions
       <> COALESCE(dashboard_by_campaign.dashboard_conversions, 0)

ORDER BY
    ABS(
        source_by_campaign.source_spend_inr
        - COALESCE(dashboard_by_campaign.dashboard_spend_inr, 0)
    ) DESC;


/*
================================================================================
Check 5: Final mapping issue summary
================================================================================

This query identifies campaigns from source data that have missing or inactive
mapping records.

Why this matters:
    Mapping issues are a very common reason why records disappear from
    dashboards and reporting tables.
================================================================================
*/

SELECT
    s.campaign_id,
    s.campaign_name,
    s.platform,
    COUNT(*) AS source_record_count,
    ROUND(SUM(s.spend_inr), 2) AS source_spend_inr,

    m.business_unit,
    m.marketing_channel,
    m.funnel_stage,
    m.region,
    m.mapping_status,
    m.mapping_comment,

    CASE
        WHEN m.campaign_id IS NULL
            THEN 'Mapping missing'
        WHEN m.mapping_status IS NULL
            THEN 'Mapping status missing'
        WHEN LOWER(m.mapping_status) <> 'active'
            THEN 'Mapping inactive or invalid'
        ELSE 'Mapping active'
    END AS mapping_issue_status

FROM source_platform_campaign_data s
LEFT JOIN campaign_mapping_reference_data m
    ON s.campaign_id = m.campaign_id

WHERE
    m.campaign_id IS NULL
    OR m.mapping_status IS NULL
    OR LOWER(m.mapping_status) <> 'active'

GROUP BY
    s.campaign_id,
    s.campaign_name,
    s.platform,
    m.business_unit,
    m.marketing_channel,
    m.funnel_stage,
    m.region,
    m.mapping_status,
    m.mapping_comment

ORDER BY
    source_spend_inr DESC;


/*
================================================================================
Check 6: Final stakeholder-friendly conclusion
================================================================================

This query gives a simple text conclusion that can be copied into an
investigation summary or stakeholder update.
================================================================================
*/

WITH
source_summary AS (
    SELECT
        COUNT(*) AS source_total_rows,
        SUM(spend_inr) AS source_spend_inr
    FROM source_platform_campaign_data
),

dashboard_summary AS (
    SELECT
        COUNT(*) AS dashboard_total_rows,
        SUM(spend_inr) AS dashboard_spend_inr
    FROM dashboard_export_campaign_data
),

missing_records AS (
    SELECT
        COUNT(*) AS missing_record_count,
        COUNT(DISTINCT s.campaign_id) AS missing_campaign_count,
        COALESCE(SUM(s.spend_inr), 0) AS missing_spend_inr
    FROM source_platform_campaign_data s
    LEFT JOIN dashboard_export_campaign_data d
        ON s.campaign_id = d.campaign_id
       AND s.report_date = d.report_date
       AND s.platform = d.platform
       AND s.state = d.state
       AND s.city = d.city
       AND s.device_type = d.device_type
    WHERE d.campaign_id IS NULL
),

mapping_issues AS (
    SELECT
        COUNT(DISTINCT s.campaign_id) AS mapping_issue_campaign_count
    FROM source_platform_campaign_data s
    LEFT JOIN campaign_mapping_reference_data m
        ON s.campaign_id = m.campaign_id
    WHERE m.campaign_id IS NULL
       OR m.mapping_status IS NULL
       OR LOWER(m.mapping_status) <> 'active'
)

SELECT
    'Stakeholder Summary' AS summary_type,

    CASE
        WHEN source_summary.source_total_rows = dashboard_summary.dashboard_total_rows
         AND ROUND(source_summary.source_spend_inr, 2) = ROUND(dashboard_summary.dashboard_spend_inr, 2)
         AND missing_records.missing_record_count = 0
         AND mapping_issues.mapping_issue_campaign_count = 0
            THEN
                'The source platform data and dashboard export match at the overall level. No major mismatch was found.'

        WHEN missing_records.missing_record_count > 0
         AND mapping_issues.mapping_issue_campaign_count > 0
            THEN
                'The dashboard is not matching the source data mainly because some valid source records are missing from the dashboard export. Some of these records are also linked to missing or inactive campaign mapping entries, which may have caused them to be excluded from reporting.'

        WHEN missing_records.missing_record_count > 0
            THEN
                'The dashboard is not matching the source data because some valid source records are missing from the dashboard export. The affected records should be reviewed by campaign, platform, date, and region.'

        WHEN mapping_issues.mapping_issue_campaign_count > 0
            THEN
                'Some source campaigns have missing or inactive mapping records. These mapping gaps may affect reporting classification and should be fixed before dashboard refresh.'

        ELSE
                'A mismatch exists between source and dashboard data, but the main cause requires further investigation across filters, joins, duplicates, and refresh logic.'
    END AS stakeholder_friendly_conclusion,

    source_summary.source_total_rows,
    dashboard_summary.dashboard_total_rows,
    source_summary.source_total_rows - dashboard_summary.dashboard_total_rows
        AS row_count_difference,

    ROUND(source_summary.source_spend_inr, 2) AS source_spend_inr,
    ROUND(dashboard_summary.dashboard_spend_inr, 2) AS dashboard_spend_inr,
    ROUND(source_summary.source_spend_inr - dashboard_summary.dashboard_spend_inr, 2)
        AS spend_difference_inr,

    missing_records.missing_record_count,
    missing_records.missing_campaign_count,
    ROUND(missing_records.missing_spend_inr, 2) AS missing_spend_inr,

    mapping_issues.mapping_issue_campaign_count

FROM source_summary
CROSS JOIN dashboard_summary
CROSS JOIN missing_records
CROSS JOIN mapping_issues;


/*
================================================================================
Learning Notes
================================================================================

1. Final reconciliation is the point where technical checks become a clear
   investigation story.

2. A good final reconciliation should not only show numbers. It should explain:
       - what is mismatching
       - where the mismatch is happening
       - why it may be happening
       - what should be checked next
       - what stakeholders need to know

3. In real projects, the final output may be shared with:
       - data engineering team
       - BI/reporting team
       - marketing analytics team
       - business stakeholders
       - project managers

4. The best data engineers do not only write SQL.
   They explain the issue clearly and recommend the next action.

5. After this SQL file, update:
       - investigation-summary.md
       - root-cause-analysis.md
       - final-recommendations.md
       - stakeholder-update-template.md
================================================================================
*/
