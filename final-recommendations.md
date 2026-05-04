
# Final Recommendations

## Purpose

This document provides final recommendations after investigating the dashboard vs source data mismatch.

The goal is not only to identify the current issue, but also to prevent similar mismatches from happening again in future reporting cycles.

---

## Summary of the Issue

The dashboard export data does not fully match the source platform campaign data.

The mismatch may affect key marketing analytics metrics such as:

- Impressions
- Clicks
- Spend
- Conversions
- Revenue

Based on the investigation framework, possible causes include:

- Missing records in the dashboard export
- Campaign mapping gaps
- Duplicate records
- Date filter mismatches
- Join logic issues
- Aggregation differences
- Dashboard filter differences
- Data refresh delays

---

## Recommendation 1: Add Source vs Dashboard Reconciliation Checks

A reconciliation check should compare source data and dashboard/reporting data before the dashboard is published or refreshed.

The check should compare:

- Record counts
- Total impressions
- Total clicks
- Total spend
- Total conversions
- Total revenue

Example output:

| Check | Source Value | Dashboard Value | Difference | Status |
|---|---:|---:|---:|---|
| Total Spend | ₹12,50,000 | ₹11,85,000 | ₹65,000 | Failed |
| Total Clicks | 48,500 | 46,900 | 1,600 | Failed |

This helps detect mismatch issues before business users see incorrect numbers.

---

## Recommendation 2: Validate Campaign Mapping Completeness

Campaign mapping should be checked before the data reaches the reporting layer.

A mapping validation check should identify:

- Campaign IDs missing from the mapping table
- Campaigns with blank region values
- Campaigns with blank channel values
- Campaigns with invalid business unit values
- Campaigns with inconsistent platform names

This is important because mapping issues can cause valid records to be excluded from the dashboard.

---

## Recommendation 3: Use Left Joins for Investigation

During investigation, use `LEFT JOIN` instead of only relying on `INNER JOIN`.

An `INNER JOIN` can remove valid source records if mapping records are missing.

Example:


SELECT
    s.campaign_id,
    s.campaign_name,
    m.region,
    m.channel
FROM source_platform_campaign_data s
LEFT JOIN campaign_mapping_reference_data m
    ON s.campaign_id = m.campaign_id
WHERE m.campaign_id IS NULL;

## Recommendation 4: Add Duplicate Record Checks

Duplicate records should be checked regularly using a business key.

Example business key:

campaign_id + campaign_date + platform + city + state

Duplicate records can inflate dashboard metrics and create incorrect reporting.

A duplicate check should be added before data is loaded into final reporting tables.

## Recommendation 5: Compare Data at Multiple Levels

Do not compare only overall totals.

Mismatch should be checked at multiple levels:

Overall total
Date level
Platform level
Campaign level
City level
State level

This helps identify where the mismatch is happening.

Example:

Level	Purpose
Date level	Finds missing or delayed data by day
Platform level	Identifies platform-specific issues
Campaign level	Finds missing or incorrect campaigns
City/State level	Finds regional mapping/filter issues

## Recommendation 6: Document Dashboard Filters Clearly

Dashboard filters should be clearly documented.

Common dashboard filters include:

Date range
Platform
Campaign status
Region
Channel
City/state
Active campaigns only
Mapped campaigns only

If the source export and dashboard filters are different, the numbers may not match.

A filter documentation section should be added to every dashboard validation process.

## Recommendation 7: Add Data Refresh Monitoring

The dashboard may show old data if the data pipeline or dashboard refresh fails.

Data refresh monitoring should check:

Latest available source date
Latest dashboard date
Last successful pipeline run
Last dashboard refresh time
Failed or delayed loads

This helps identify whether the mismatch is caused by stale dashboard data.

## Recommendation 8: Create a Standard Investigation Checklist

A reusable investigation checklist should be used whenever a dashboard mismatch is reported.

The checklist should include:

Confirm affected dashboard
Confirm affected metric
Confirm date range
Confirm source of truth
Compare row counts
Compare total metrics
Check missing records
Check duplicate records
Check mapping table
Check dashboard filters
Check data refresh status
Prepare root cause summary

This helps data engineers investigate issues consistently.

## Recommendation 9: Define Acceptable Tolerance Thresholds

Not every small mismatch needs escalation.

For some metrics, a small difference may happen due to rounding, late-arriving data, or currency precision.

Example tolerance rules:

| Metric      | Suggested Tolerance |
| ----------- | ------------------: |
| Spend       |                0.5% |
| Clicks      |                0.1% |
| Impressions |                0.1% |
| Revenue     |                0.5% |
| Conversions |                0.1% |


If the difference is above the threshold, the issue should be investigated.

## Recommendation 10: Share Business-Friendly Updates

Technical findings should be translated into simple language for stakeholders.

Instead of saying:

The inner join removed rows due to null mapping keys.

Say:

Some valid campaign records were not included in the dashboard because the campaign mapping table did not contain matching records for them.

This makes the issue easier for business users to understand.

## Suggested Future Process

A better future process could look like this:

<img width="482" height="380" alt="image" src="https://github.com/user-attachments/assets/bac2ca29-671a-4e6b-b3bf-cea0d93b0374" />

This creates a stronger reporting process and reduces dashboard trust issues.

## Final Recommendation Summary

The most important recommendations are:

Add source vs dashboard reconciliation checks
Validate campaign mapping completeness
Check duplicate records before reporting
Compare data at multiple levels
Document dashboard filters clearly
Monitor refresh delays
Use a standard investigation checklist
Communicate findings in business-friendly language

## Expected Benefit

If these recommendations are implemented, the team can:

Detect mismatches earlier
Reduce manual investigation time
Improve dashboard trust
Avoid incorrect business decisions
Improve data quality
Create a repeatable issue investigation process
Help technical and business teams communicate better

## Final Note

Dashboard mismatches are common in real-world data projects.

The goal is not only to fix one mismatch, but to create a repeatable process that helps data teams investigate, explain, and prevent similar issues in future.

