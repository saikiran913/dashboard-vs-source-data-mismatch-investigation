# Root Cause Analysis

## Purpose

This document explains the possible root causes behind the dashboard vs source data mismatch.

In a real-world data engineering project, the first reported issue may sound simple:

> “The dashboard numbers are not matching the source data.”

However, the actual root cause can exist in many different places, such as the source data, ingestion process, transformation logic, mapping table, reporting table, or dashboard filters.

This document helps break down the possible causes in a structured way.

---

## Reported Problem

The dashboard export is showing different campaign performance numbers compared to the source platform data.

The mismatch may affect metrics such as:

- Impressions
- Clicks
- Spend
- Conversions
- Revenue

The goal is to identify why the dashboard data does not match the source data and explain the issue clearly.

---

## Root Cause Investigation Areas

---

## 1. Missing Records in Dashboard

### What This Means

Some records exist in the source platform data but are not available in the dashboard export.

### Why This Can Happen

- Records were dropped during transformation
- Dashboard uses filters that exclude some campaigns
- Campaigns are missing from mapping/reference tables
- Source records failed to join with reporting tables
- Data refresh did not complete successfully

### How to Check

Compare unique campaign IDs between the source and dashboard datasets.

Example question:

> Which campaign IDs exist in the source data but not in the dashboard export?

### Expected SQL Check

Use a left join from source to dashboard and filter where dashboard campaign ID is null.

---

## 2. Extra Records in Dashboard

### What This Means

Some records appear in the dashboard export but are not present in the source platform data.

### Why This Can Happen

- Old/stale records were not removed
- Incremental loading logic failed
- Dashboard table contains records from another load
- Data was manually adjusted in the reporting layer
- Duplicate or historical records are being included

### How to Check

Compare dashboard campaign IDs against the source dataset.

Example question:

> Which records exist in dashboard export but not in the source data?

---

## 3. Duplicate Records

### What This Means

The same business record appears more than once in either source or dashboard data.

### Why This Can Happen

- Same file loaded multiple times
- Incremental load appended data instead of replacing it
- Wrong merge/upsert logic
- Missing primary/business key
- Multiple records created due to incorrect joins

### Example Business Key


campaign_id + campaign_date + platform + city + state

How to Check

Group by business key and count records greater than 1.

Business Impact

Duplicate records can inflate:

Spend
Clicks
Impressions
Conversions
Revenue

## 4. Mapping Table Issue
### What This Means

Campaign records may not have valid matching values in the mapping/reference table.

### Why This Can Happen
New campaign IDs were not added to the mapping table
Mapping table is outdated
Campaign names changed
Platform naming is inconsistent
Region/channel/business unit values are missing
Join condition expects exact matching values

### How to Check

Join source campaign data with the mapping reference table and find records where mapping values are null.

### Example Finding

18 source campaign records do not have valid campaign mapping. These records may be excluded from the dashboard reporting layer.

## 5. Date Filter Mismatch
### What This Means

The source data and dashboard export are not using the same date range.

### Why This Can Happen
Dashboard filter excludes one or more dates
Source export uses campaign date, dashboard uses load date
Timezone conversion changes the date
Dashboard default date range is different
Month-to-date or week-to-date logic is inconsistent
### How to Check

Compare minimum and maximum campaign dates in both datasets.

Also compare metrics by date to find which dates are missing or mismatched.

### Business Impact

Even one missing date can create a large mismatch in spend, clicks, or revenue.

## 6. Aggregation Logic Difference
### What This Means

The source and dashboard may calculate totals at different levels of detail.

### Why This Can Happen
Source is at campaign/date level
Dashboard is at campaign/date/city/platform level
Dashboard applies grouping after joining mapping data
Dashboard excludes inactive campaigns
Dashboard rounds spend or revenue values
Metrics are calculated before or after filtering

### How to Check

Aggregate both datasets at the same grain and compare results.

Recommended comparison levels:

Overall total
By date
By platform
By campaign
By city
By state

## 7. Join Logic Issue
### What This Means

The dashboard reporting table may lose valid records because of incorrect join logic.

### Why This Can Happen

An INNER JOIN between source data and mapping table can remove records when mapping is missing.

Example:

SELECT *
FROM source_platform_campaign_data s
INNER JOIN campaign_mapping_reference_data m
    ON s.campaign_id = m.campaign_id;

If a source campaign does not exist in the mapping table, it will not appear in the final dashboard table.

### How to Check

Compare inner join output with left join output.

If left join returns more rows than inner join, mapping gaps may be causing data loss.

## 8. Dashboard Filter Issue
### What This Means

The dashboard may apply filters that are not applied in the source export.

### Why This Can Happen

Dashboard may filter by:

Active campaigns only
Specific platforms
Specific cities/states
Specific campaign types
Mapped campaigns only
Approved campaigns only
Current month only
### How to Check

Review dashboard filters and compare them with source export filters.

If direct dashboard access is not available, compare dashboard export data with source data by platform, date, and campaign status.

## 9. Data Refresh Delay
### What This Means

The dashboard may not have received the latest source data yet.

### Why This Can Happen
Source data arrived late
Pipeline failed
Scheduled refresh did not complete
Dashboard cache is not updated
Reporting table is behind the source table
### How to Check

Compare latest available campaign date in both datasets.

Also check load date or refresh timestamp if available.

Example Finding

Source data is available until 31 January, but dashboard data is available only until 29 January.

## 10. Currency or Rounding Difference
### What This Means

Spend or revenue may differ due to rounding or currency handling.

### Why This Can Happen
Spend rounded in dashboard
Source contains decimal values
Dashboard uses converted values
Currency conversion applied in one layer but not another
Tax or fee adjustment applied in dashboard
### How to Check

Compare raw spend and revenue values before and after aggregation.

For this project, spend and revenue are represented in Indian Rupees.

## Root Cause Prioritisation

When multiple issues are found, root causes should be prioritised based on impact.

| Priority   | Root Cause Type      | Impact                              |
| ---------- | -------------------- | ----------------------------------- |
| High       | Missing records      | Directly reduces dashboard totals   |
| High       | Duplicate records    | Inflates dashboard or source totals |
| High       | Mapping table issue  | Can exclude valid campaigns         |
| Medium     | Date filter mismatch | Affects selected reporting periods  |
| Medium     | Join logic issue     | Can remove or duplicate records     |
| Low/Medium | Rounding issue       | Usually creates smaller differences |

## Expected Root Cause for This Project

For this dummy project, the expected root cause may include:

Some source campaigns are missing from the dashboard export
Some campaigns do not have valid mapping records
Some records may be duplicated
Dashboard totals are lower because not all source records are included

The final SQL checks will confirm which issue contributes most to the mismatch.

## How Root Cause Will Be Confirmed

The final root cause will be confirmed using these checks:

Record count comparison
Total metric comparison
Missing campaign check
Duplicate record check
Mapping validation check
Date-level comparison
Platform-level comparison
Final reconciliation query

## Final Root Cause Statement Format

A good root cause statement should be simple and clear.

Example:

The dashboard spend and click totals are lower than the source platform totals because some valid source campaign records are missing from the dashboard export. The missing records are mainly linked to campaigns that do not have valid mapping entries in the campaign mapping reference table. As a result, these records may have been excluded during the transformation or reporting process.

## Prevention Recommendations

To prevent similar issues in future:

Add source vs dashboard reconciliation checks
Validate mapping table completeness before dashboard refresh
Add duplicate record detection
Compare metrics by date, platform, and campaign
Add alerts when mismatch exceeds a threshold
Review join logic used in transformation layer
Document dashboard filters clearly
Maintain an investigation checklist for recurring issues

## Summary

Dashboard mismatches are not always caused by one simple error.

They can happen because of missing records, duplicate rows, mapping gaps, date filters, join issues, aggregation differences, or refresh delays.

A structured investigation helps identify the actual root cause and explain it clearly to both technical and non-technical stakeholders.


