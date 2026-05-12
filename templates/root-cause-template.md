# Root Cause Analysis Template

## Purpose

Use this template to document the root cause of a dashboard vs source data mismatch.

This template is useful when a stakeholder reports an issue like:

> “The dashboard numbers are not matching the source data.”

The goal is to explain the issue clearly, show what was checked, identify the root cause, and recommend the next action.

---

## 1. Issue Summary

### Reported Issue

Write a short summary of the issue.

Example:

The campaign performance dashboard is showing lower spend and clicks compared to the source platform export for the same reporting period.

### Affected Dashboard / Report
Dashboard name:
Report page:
Metric affected:
Date range:
Region / market:
Reported by:
Reported date:

## 2. Source of Truth

Confirm which dataset or system is treated as the correct source.

Source of truth:
Source file/table:
Dashboard export file/table:
Mapping/reference file/table:

Example:

The source platform campaign dataset is treated as the source of truth for this investigation.

## 3. Datasets Reviewed

List the datasets used in the investigation.

| Dataset               | Purpose                                 | File/Table Name                   |
| --------------------- | --------------------------------------- | --------------------------------- |
| Source platform data  | Original campaign performance data      | `source_platform_campaign_data`   |
| Dashboard export data | Data shown in dashboard/reporting layer | `dashboard_export_campaign_data`  |
| Campaign mapping data | Campaign classification/reference table | `campaign_mapping_reference_data` |


## 4. Checks Performed

Tick or update the checks completed during the investigation.

| Check                     | Completed? | SQL File Used                       | Notes |
| ------------------------- | ---------- | ----------------------------------- | ----- |
| Row count comparison      | Yes / No   | `02_compare_record_counts.sql`      |       |
| Total metric comparison   | Yes / No   | `03_compare_total_metrics.sql`      |       |
| Missing campaign check    | Yes / No   | `04_find_missing_campaigns.sql`     |       |
| Duplicate record check    | Yes / No   | `05_check_duplicate_records.sql`    |       |
| Mapping validation        | Yes / No   | `06_final_reconciliation_query.sql` |       |
| Platform-level comparison | Yes / No   | `03_compare_total_metrics.sql`      |       |
| Date-level comparison     | Yes / No   | `03_compare_total_metrics.sql`      |       |
| Final reconciliation      | Yes / No   | `06_final_reconciliation_query.sql` |       |

## 5. Key Findings

Summarise the important findings from the SQL checks.

### Row Count Finding
Source row count:
Dashboard row count:
Difference:
Status:

Example:

The source dataset contains more rows than the dashboard export, which suggests that some source records may be missing from the dashboard.

### Metric Difference Finding
Source impressions:
Dashboard impressions:
Impressions difference:

Source clicks:
Dashboard clicks:
Clicks difference:

Source conversions:
Dashboard conversions:
Conversions difference:

Source spend INR:
Dashboard spend INR:
Spend difference INR:


### Missing Records Finding
Missing source records in dashboard:
Missing unique campaigns:
Missing spend impact:
Affected platforms:
Affected states/cities:


### Duplicate Records Finding
Source duplicate groups:
Dashboard duplicate groups:
Estimated extra duplicate rows:
Affected spend:


### Mapping Issue Finding
Campaigns missing mapping:
Inactive mapping records:
Invalid mapping records:
Affected business units/channels:

## 6. Root Cause

Write the final root cause in simple language.

### Technical Root Cause
Write the technical reason here.

Example:
Some valid source campaign records were not included in the dashboard export because the related campaign IDs were missing or inactive in the campaign mapping reference table. This likely caused the reporting transformation layer to exclude those records during the dashboard data preparation process.

### Business-Friendly Root Cause
Write the business-friendly explanation here.

Example:
The dashboard is showing lower numbers because some valid campaign records were not included in the reporting layer due to missing campaign mapping details.


## 7. Business Impact

Explain how the issue affects business users.
| Area                          | Impact                                                |
| ----------------------------- | ----------------------------------------------------- |
| Spend reporting               | Dashboard spend may be lower than actual source spend |
| Click reporting               | Clicks may be underreported                           |
| Conversion reporting          | Conversion totals may be incomplete                   |
| Campaign performance analysis | Some campaigns may look weaker than they actually are |
| Stakeholder trust             | Business users may lose confidence in the dashboard   |

Short impact summary:
Because some campaign records are missing from the dashboard, business users may make decisions using incomplete campaign performance numbers.


## 8. Recommended Fix

List the actions needed to fix the issue.

| Recommendation                                    | Owner                 | Priority | Notes |
| ------------------------------------------------- | --------------------- | -------- | ----- |
| Fix missing campaign mapping records              | Data / Analytics Team | High     |       |
| Re-run dashboard transformation after mapping fix | Data Engineering Team | High     |       |
| Validate source vs dashboard totals after refresh | Data Engineering Team | High     |       |
| Add mapping completeness check                    | Data Engineering Team | Medium   |       |
| Add automated reconciliation check                | Data Engineering Team | Medium   |       |



## 9. Prevention Steps

Add steps to avoid the same issue in future.

Add daily source vs dashboard reconciliation checks
Validate mapping completeness before dashboard refresh
Add duplicate record checks before reporting
Monitor data refresh status
Document dashboard filters clearly
Add alerts when metric mismatch exceeds tolerance
Maintain a standard investigation checklist
Review mapping table updates regularly

## 10. Final Root Cause Statement

Use this final format for the investigation report.

The dashboard mismatch was mainly caused by [root cause]. This affected [metrics/records/campaigns] for [date range/platform/region]. The issue caused the dashboard to show [higher/lower] values compared to the source data. The recommended fix is to [fix action], then re-run validation using the reconciliation SQL checks.


Example:
The dashboard mismatch was mainly caused by missing and inactive campaign mapping records. This affected spend, clicks, and conversions for selected campaigns across Indian regions. The issue caused the dashboard to show lower values compared to the source platform data. The recommended fix is to update the campaign mapping table, refresh the reporting layer, and re-run the reconciliation SQL checks.







