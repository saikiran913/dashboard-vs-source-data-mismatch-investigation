/*
================================================================================
Project: Dashboard vs Source Data Mismatch Investigation
File: 04_find_missing_campaigns.sql

Purpose:
    Identify campaigns and records that exist in the source platform data
    but are missing from the dashboard export data.

Why this check matters:
    If dashboard totals are lower than source totals, one common reason is that
    some source records were not included in the final dashboard/reporting layer.

    This can happen because of:
        - missing campaign mapping
        - dashboard filters
        - transformation logic
        - failed joins
        - incomplete refresh
        - manual exclusions

SQL Style:
    Beginner-friendly standard SQL / SQLite-friendly format
================================================================================
*/


/*
================================================================================
Check 1: Find campaign IDs in source but missing from dashboard
================================================================================

Question:
    Which campaigns exist in the source data but do not exist in the dashboard?

Why this matters:
    These campaigns may explain why dashboard totals are lower.
================================================================================
*/

SELECT DISTINCT
    s.campaign_id,
    s.campaign_name,
    s.platform,
    s.state,
    s.city
FROM source_platform_campaign_data s
LEFT JOIN dashboard_export_campaign_data d
    ON s.campaign_id = d.campaign_id
WHERE d.campaign_id IS NULL
ORDER BY
    s.platform,
    s.state,
    s.city,
    s.campaign_id;


/*
================================================================================
Check 2: Count missing source campaigns
================================================================================

Question:
    How many unique source campaigns are missing from the dashboard?
================================================================================
*/

SELECT
    COUNT(DISTINCT s.campaign_id) AS missing_campaign_count
FROM source_platform_campaign_data s
LEFT JOIN dashboard_export_campaign_data d
    ON s.campaign_id = d.campaign_id
WHERE d.campaign_id IS NULL;


/*
================================================================================
Check 3: Find detailed missing source records
================================================================================

Question:
    Which exact source records are missing from the dashboard?

Important:
    Campaign ID alone may not be enough.
    A campaign can exist in both datasets, but some dates, cities, states,
    platforms, or devices may still be missing.

Business key used here:
    campaign_id + report_date + platform + state + city + device_type
================================================================================
*/

SELECT
    s.source_row_id,
    s.report_date,
    s.platform,
    s.campaign_id,
    s.campaign_name,
    s.state,
    s.city,
    s.device_type,
    s.impressions,
    s.clicks,
    s.conversions,
    s.spend_inr
FROM source_platform_campaign_data s
LEFT JOIN dashboard_export_campaign_data d
    ON s.campaign_id = d.campaign_id
   AND s.report_date = d.report_date
   AND s.platform = d.platform
   AND s.state = d.state
   AND s.city = d.city
   AND s.device_type = d.device_type
WHERE d.campaign_id IS NULL
ORDER BY
    s.report_date,
    s.platform,
    s.campaign_id;


/*
================================================================================
Check 4: Calculate metric impact of missing records
================================================================================

Question:
    How much spend, clicks, impressions, and conversions are missing because
    these source records are not present in the dashboard?

Why this matters:
    This translates the technical issue into business impact.
================================================================================
*/

SELECT
    COUNT(*) AS missing_record_count,
    COUNT(DISTINCT s.campaign_id) AS missing_unique_campaigns,
    SUM(s.impressions) AS missing_impressions,
    SUM(s.clicks) AS missing_clicks,
    SUM(s.conversions) AS missing_conversions,
    ROUND(SUM(s.spend_inr), 2) AS missing_spend_inr
FROM source_platform_campaign_data s
LEFT JOIN dashboard_export_campaign_data d
    ON s.campaign_id = d.campaign_id
   AND s.report_date = d.report_date
   AND s.platform = d.platform
   AND s.state = d.state
   AND s.city = d.city
   AND s.device_type = d.device_type
WHERE d.campaign_id IS NULL;


/*
================================================================================
Check 5: Missing records by platform
================================================================================

Question:
    Which platform has the highest missing data impact?

Why this matters:
    This helps identify whether the issue is platform-specific.
================================================================================
*/

SELECT
    s.platform,
    COUNT(*) AS missing_record_count,
    COUNT(DISTINCT s.campaign_id) AS missing_campaign_count,
    SUM(s.impressions) AS missing_impressions,
    SUM(s.clicks) AS missing_clicks,
    SUM(s.conversions) AS missing_conversions,
    ROUND(SUM(s.spend_inr), 2) AS missing_spend_inr
FROM source_platform_campaign_data s
LEFT JOIN dashboard_export_campaign_data d
    ON s.campaign_id = d.campaign_id
   AND s.report_date = d.report_date
   AND s.platform = d.platform
   AND s.state = d.state
   AND s.city = d.city
   AND s.device_type = d.device_type
WHERE d.campaign_id IS NULL
GROUP BY
    s.platform
ORDER BY
    missing_spend_inr DESC;


/*
================================================================================
Check 6: Missing records by state
================================================================================

Question:
    Which Indian states are most affected by missing dashboard records?

Why this matters:
    State-level analysis helps identify regional reporting or mapping issues.
================================================================================
*/

SELECT
    s.state,
    COUNT(*) AS missing_record_count,
    COUNT(DISTINCT s.campaign_id) AS missing_campaign_count,
    SUM(s.impressions) AS missing_impressions,
    SUM(s.clicks) AS missing_clicks,
    SUM(s.conversions) AS missing_conversions,
    ROUND(SUM(s.spend_inr), 2) AS missing_spend_inr
FROM source_platform_campaign_data s
LEFT JOIN dashboard_export_campaign_data d
    ON s.campaign_id = d.campaign_id
   AND s.report_date = d.report_date
   AND s.platform = d.platform
   AND s.state = d.state
   AND s.city = d.city
   AND s.device_type = d.device_type
WHERE d.campaign_id IS NULL
GROUP BY
    s.state
ORDER BY
    missing_spend_inr DESC;


/*
================================================================================
Check 7: Missing records by report date
================================================================================

Question:
    Are missing records concentrated on specific dates?

Why this matters:
    If missing records are concentrated on one or two dates, the issue may be
    related to refresh delay, failed file load, or date filter mismatch.
================================================================================
*/

SELECT
    s.report_date,
    COUNT(*) AS missing_record_count,
    COUNT(DISTINCT s.campaign_id) AS missing_campaign_count,
    SUM(s.impressions) AS missing_impressions,
    SUM(s.clicks) AS missing_clicks,
    SUM(s.conversions) AS missing_conversions,
    ROUND(SUM(s.spend_inr), 2) AS missing_spend_inr
FROM source_platform_campaign_data s
LEFT JOIN dashboard_export_campaign_data d
    ON s.campaign_id = d.campaign_id
   AND s.report_date = d.report_date
   AND s.platform = d.platform
   AND s.state = d.state
   AND s.city = d.city
   AND s.device_type = d.device_type
WHERE d.campaign_id IS NULL
GROUP BY
    s.report_date
ORDER BY
    s.report_date;


/*
================================================================================
Check 8: Missing records by device type
================================================================================

Question:
    Is the dashboard missing data for a specific device type?

Why this matters:
    A dashboard may accidentally filter out mobile, desktop, or tablet data.
================================================================================
*/

SELECT
    s.device_type,
    COUNT(*) AS missing_record_count,
    COUNT(DISTINCT s.campaign_id) AS missing_campaign_count,
    SUM(s.impressions) AS missing_impressions,
    SUM(s.clicks) AS missing_clicks,
    SUM(s.conversions) AS missing_conversions,
    ROUND(SUM(s.spend_inr), 2) AS missing_spend_inr
FROM source_platform_campaign_data s
LEFT JOIN dashboard_export_campaign_data d
    ON s.campaign_id = d.campaign_id
   AND s.report_date = d.report_date
   AND s.platform = d.platform
   AND s.state = d.state
   AND s.city = d.city
   AND s.device_type = d.device_type
WHERE d.campaign_id IS NULL
GROUP BY
    s.device_type
ORDER BY
    missing_spend_inr DESC;


/*
================================================================================
Check 9: Check whether missing dashboard records also have mapping issues
================================================================================

Question:
    Are the missing source records linked to campaigns that are missing or
    invalid in the campaign mapping reference table?

Why this matters:
    If missing dashboard records also have mapping issues, it suggests the
    dashboard/reporting layer may be excluding records because mapping is
    incomplete.
================================================================================
*/

SELECT
    s.campaign_id,
    s.campaign_name,
    s.platform,
    s.state,
    s.city,
    s.device_type,
    m.business_unit,
    m.marketing_channel,
    m.funnel_stage,
    m.region,
    m.mapping_status,
    m.mapping_comment,
    COUNT(*) AS missing_record_count,
    ROUND(SUM(s.spend_inr), 2) AS missing_spend_inr
FROM source_platform_campaign_data s
LEFT JOIN dashboard_export_campaign_data d
    ON s.campaign_id = d.campaign_id
   AND s.report_date = d.report_date
   AND s.platform = d.platform
   AND s.state = d.state
   AND s.city = d.city
   AND s.device_type = d.device_type
LEFT JOIN campaign_mapping_reference_data m
    ON s.campaign_id = m.campaign_id
WHERE d.campaign_id IS NULL
GROUP BY
    s.campaign_id,
    s.campaign_name,
    s.platform,
    s.state,
    s.city,
    s.device_type,
    m.business_unit,
    m.marketing_channel,
    m.funnel_stage,
    m.region,
    m.mapping_status,
    m.mapping_comment
ORDER BY
    missing_spend_inr DESC;


/*
================================================================================
Check 10: Final missing campaign investigation summary
================================================================================

This gives a simple final conclusion for this file.
================================================================================
*/

SELECT
    'Missing Campaign / Record Check' AS check_name,
    COUNT(*) AS missing_record_count,
    COUNT(DISTINCT s.campaign_id) AS missing_campaign_count,
    SUM(s.impressions) AS missing_impressions,
    SUM(s.clicks) AS missing_clicks,
    SUM(s.conversions) AS missing_conversions,
    ROUND(SUM(s.spend_inr), 2) AS missing_spend_inr,

    CASE
        WHEN COUNT(*) = 0
            THEN 'PASS - No missing source records found in dashboard.'
        ELSE 'FAIL - Some source records are missing from dashboard. Investigate mapping, filters, joins, or refresh process.'
    END AS conclusion

FROM source_platform_campaign_data s
LEFT JOIN dashboard_export_campaign_data d
    ON s.campaign_id = d.campaign_id
   AND s.report_date = d.report_date
   AND s.platform = d.platform
   AND s.state = d.state
   AND s.city = d.city
   AND s.device_type = d.device_type
WHERE d.campaign_id IS NULL;


/*
================================================================================
Learning Notes
================================================================================

1. Missing campaign checks help explain why dashboard totals may be lower.

2. Always check missing records at different levels:
       - campaign level
       - full business key level
       - platform level
       - state/city level
       - date level
       - device level

3. Campaign ID alone is not always enough.
   A campaign may exist in both datasets, but some dates or cities may be
   missing from the dashboard.

4. If missing records also have mapping issues, the root cause may be related
   to incomplete campaign mapping or join logic.

5. The next SQL file will check duplicate records.
================================================================================
*/
