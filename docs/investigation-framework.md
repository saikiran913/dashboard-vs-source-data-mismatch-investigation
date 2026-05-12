# Dashboard vs Source Data Mismatch Investigation Framework

## Purpose

This document explains the complete investigation framework used in this project.

The goal is to help learners understand how a data engineer should approach a dashboard vs source data mismatch issue in a structured way.

When someone says:

> “The dashboard numbers are not matching the source data.”

the correct approach is not to randomly write SQL queries.

A good data engineer should follow a clear investigation flow:

1. Understand the issue
2. Confirm the source of truth
3. Review the datasets
4. Compare row counts
5. Compare business metrics
6. Find missing or extra records
7. Check duplicates and mapping issues
8. Prepare a final explanation and recommendation

---

## 1. Understand the Business Issue

Before checking the data, first understand what the business user is reporting.

Ask simple questions:

- Which dashboard is affected?
- Which metric is mismatching?
- What is the expected number?
- What is the dashboard showing?
- What date range is being compared?
- Which platform, campaign, city, state, or region is affected?
- When was the mismatch first noticed?

Example:

The marketing team reported that the campaign performance dashboard is showing lower spend and clicks compared to the source platform export for January 2026.


Why this step matters:

If the issue is not clearly understood, the investigation can go in the wrong direction.

## 2. Confirm the Source of Truth

The next step is to confirm which dataset or system should be treated as the correct source.

In this project, the source of truth is:

source_platform_campaign_data.csv

The dashboard data being checked is:

dashboard_export_campaign_data.csv

The mapping/reference data is:

campaign_mapping_reference_data.csv

### Questions to ask:

Is the source platform export considered correct?
Is the dashboard based on raw data or transformed data?
Are any filters or business rules applied in the dashboard?
Is the mapping table used before dashboard reporting?
Are all datasets from the same reporting period?

Why this step matters:

Sometimes the source export and dashboard are not expected to match exactly because the dashboard may apply filters, mappings, or exclusions.

## 3. Review the Dataset Structure

Before comparing numbers, review the columns available in each dataset.

### Important columns in this project:

report_date
platform
campaign_id
campaign_name
state
city
device_type
impressions
clicks
conversions
spend_inr

### The mapping dataset includes:

campaign_id
campaign_name
normalized_campaign_name
business_unit
marketing_channel
funnel_stage
region
state
account_manager
mapping_status
mapping_comment

### Checks to perform:

Are all required columns available?
Are campaign IDs available in all relevant datasets?
Are date columns formatted correctly?
Are metric columns numeric?
Are platform, state, city, and device values consistent?
Are there any missing or blank values?

Why this step matters:

Many data issues happen because columns are missing, wrongly formatted, or inconsistent between files.


## 4. Compare Row Counts

The first SQL investigation step is row count comparison.

SQL file:

sql/02_compare_record_counts.sql

Purpose:

To check whether the source data and dashboard data contain the same number of rows.

Example result:
| Dataset               | Row Count |
| --------------------- | --------: |
| Source platform data  |       500 |
| Dashboard export data |       485 |


What this means:

If the source has more rows than the dashboard, some records may be missing from the dashboard.

If the dashboard has more rows than the source, the dashboard may contain duplicates, stale records, or extra records.

Recommended breakdowns:

Overall row count
Row count by platform
Row count by report date
Row count by state

Why this step matters:

Row count comparison gives the first signal of whether data loss or extra data exists.

## 5. Compare Total Business Metrics

After row counts, compare the important business metrics.

SQL file:

sql/03_compare_total_metrics.sql

Metrics checked:

Impressions
Clicks
Conversions
Spend in INR

### Example result:
| Metric      |    Source | Dashboard | Difference |
| ----------- | --------: | --------: | ---------: |
| Impressions | 1,250,000 | 1,180,000 |     70,000 |
| Clicks      |    48,500 |    46,900 |      1,600 |
| Spend INR   | 12,50,000 | 11,85,000 |     65,000 |


### Questions to answer:

Which metric is mismatching?
Is the dashboard lower or higher than the source?
What is the difference amount?
What is the percentage difference?
Is the mismatch small or significant?

### Recommended breakdowns:

Overall totals
By platform
By report date
By state
By device type

Why this step matters:

Business users care about metrics. This step converts the investigation from row-level checks to business impact.

## 6. Find Missing Campaigns and Records

If dashboard totals are lower than the source, check for missing records.

SQL file:

sql/04_find_missing_campaigns.sql

Main question:

Which records exist in source data but are missing from dashboard data?

Important comparison key:

campaign_id + report_date + platform + state + city + device_type

Why not only campaign ID?

Because a campaign may exist in both datasets, but some dates, cities, states, or device records may still be missing.

Checks to perform:

Missing campaign IDs
Missing detailed source records
Missing records by platform
Missing records by state
Missing records by report date
Missing records by device type
Metric impact of missing records

Example finding:

15 source records are missing from the dashboard export. These missing records account for ₹65,000 in spend and 1,600 clicks.


Why this step matters:

Missing records are one of the most common reasons for dashboard totals being lower than source totals.

## 7. Check Duplicate Records

If dashboard totals are higher than expected, or if numbers look inflated, check for duplicates.

SQL file:

sql/05_check_duplicate_records.sql

Duplicate business key used:

campaign_id + report_date + platform + state + city + device_type

Checks to perform:

Duplicate records in source data
Duplicate records in dashboard data
Duplicate groups by platform
Duplicate groups by report date
Duplicate row ID checks
Estimated extra duplicate rows

Possible causes:

Same CSV file loaded multiple times
Incremental load appended instead of replacing
Join logic created duplicate rows
No proper unique key was applied
Merge/upsert logic failed

Example finding:
The dashboard export contains duplicate records for selected campaign/date/platform combinations, which may inflate spend and click totals.


Why this step matters:

Duplicates can make dashboards look higher than source data or create confusing metric mismatches.

## 8. Validate Campaign Mapping

Marketing analytics dashboards often depend on mapping/reference tables.

Mapping dataset:

campaign_mapping_reference_data.csv

Mapping fields include:

business_unit
marketing_channel
funnel_stage
region
mapping_status
mapping_comment

Checks to perform:

Source campaigns missing from mapping table
Campaigns with inactive mapping status
Campaigns with blank business unit
Campaigns with blank marketing channel
Campaigns with blank funnel stage
Campaigns with inconsistent region/state values

Why mapping matters:

If the reporting layer uses mapping data and the mapping is missing, valid source records may be excluded from the dashboard.

Example issue:
A source campaign exists in the platform data, but it has no active mapping record. Because of this, the campaign may not appear in the dashboard reporting layer.


Why this step matters:

Mapping issues are very common in real-world campaign reporting and marketing analytics projects.

## 9. Run Final Reconciliation

After completing all individual checks, run the final reconciliation query.

SQL file:

sql/06_final_reconciliation_query.sql

The final reconciliation should summarise:

Source row count
Dashboard row count
Row count difference
Source metric totals
Dashboard metric totals
Metric differences
Missing record count
Missing campaign count
Duplicate record count
Mapping issue count
Final investigation conclusion

Example conclusion:
The dashboard mismatch is mainly caused by missing source records in the dashboard export. Some of these missing records are linked to missing or inactive campaign mapping entries.


Why this step matters:

This step connects all SQL checks into one final investigation story.

## 10. Communicate Findings Clearly

The final step is to explain the issue in a way that both technical and non-technical stakeholders can understand.

Use these templates:

templates/root-cause-template.md
templates/stakeholder-update-template.md

Avoid overly technical wording.

Technical version:

The inner join between source and mapping removed rows due to missing campaign mapping keys.

Business-friendly version:
Some valid campaign records were not included in the dashboard because their campaign mapping details were missing.

A good stakeholder update should include:

What issue was reported
What data was checked
What was found
What caused the mismatch
What the business impact is
What action is recommended
When the next update will be shared

Why this step matters:

A data engineer’s job is not only to find the issue. It is also to explain the issue clearly and help the team take the right action.

## Complete Investigation Flow
Business issue reported
        ↓
Confirm source of truth
        ↓
Review datasets and columns
        ↓
Compare row counts
        ↓
Compare total metrics
        ↓
Find missing source records
        ↓
Check duplicate records
        ↓
Validate campaign mapping
        ↓
Run final reconciliation
        ↓
Prepare root cause summary
        ↓
Share stakeholder update
        ↓
Recommend prevention steps

## Final Prevention Checklist

To prevent similar issues in future, teams should add:

Daily source vs dashboard reconciliation checks
Mapping completeness validation
Duplicate record checks
Data refresh monitoring
Dashboard filter documentation
Metric tolerance thresholds
Automated alerts for major mismatches
Clear ownership for mapping updates
Standard issue investigation templates

## Final Note

This framework is designed for beginner-friendly learning, but the same thinking applies in real projects using:

BigQuery
Azure Synapse
Azure SQL
Snowflake
Databricks SQL
PostgreSQL
Power BI
Looker Studio
Tableau

The tools may change, but the investigation mindset stays the same:

Understand the issue
Compare the right data
Find the mismatch
Explain the root cause
Recommend the fix



