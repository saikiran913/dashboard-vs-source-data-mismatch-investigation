# Dashboard vs Source Data Mismatch Investigation Checklist

## Purpose

This checklist helps data engineers, analysts, and SQL learners investigate a dashboard vs source data mismatch in a structured way.

When a business user says:

> “The dashboard numbers are not matching the source data.”

do not immediately jump into SQL randomly.

Use this checklist to understand the issue, validate the data, identify the root cause, and communicate the finding clearly.

---

## 1. Understand the Reported Issue

Before writing SQL, first understand the business problem clearly.

### Questions to Ask

- Which dashboard is showing the mismatch?
- Which source/platform data is being compared?
- Which metric is mismatching?
- What date range is affected?
- Is the mismatch happening for all campaigns or selected campaigns?
- Is the issue reported for a specific platform?
- Is the issue reported for a specific city, state, or region?
- When was the issue first noticed?
- Who reported the issue?
- What is the expected number?
- What is the dashboard showing?

### Example

| Question | Example Answer |
|---|---|
| Dashboard affected | Campaign Performance Dashboard |
| Source compared | Google Ads / Meta Ads export |
| Metric affected | Spend and clicks |
| Date range | 01-Jan-2026 to 31-Jan-2026 |
| Region | India |
| Issue type | Dashboard is showing lower numbers |

---

## 2. Confirm the Source of Truth

Before comparing data, confirm which system should be treated as the correct source.

### Possible Source Systems

- Google Ads
- Meta Ads
- YouTube Ads
- LinkedIn Ads
- Programmatic platform
- CRM system
- Raw data table
- Source platform CSV export

### Questions to Ask

- Is the platform export treated as the source of truth?
- Is the raw data table treated as the source of truth?
- Is the dashboard using transformed data?
- Are there any business rules applied after source ingestion?
- Is the source export using the same date range as the dashboard?

### Why This Matters

If the source of truth is not clear, the investigation can become confusing.

The dashboard may be correct according to business logic, but different from the raw platform export because filters or transformations were applied.

---

## 3. Confirm Dataset Availability

Check whether all required datasets are available.

### Required Datasets in This Project

| Dataset | Purpose |
|---|---|
| `source_platform_campaign_data.csv` | Original platform/source data |
| `dashboard_export_campaign_data.csv` | Dashboard/reporting export |
| `campaign_mapping_reference_data.csv` | Campaign mapping/reference table |

### Validation Questions

- Is the source dataset available?
- Is the dashboard export available?
- Is the mapping table available?
- Are all files from the same reporting period?
- Are all files in the expected format?
- Are column names consistent?

---

## 4. Validate Table Structure

Before comparing metrics, confirm that both datasets have similar structure.

### Columns to Check

- `report_date`
- `platform`
- `campaign_id`
- `campaign_name`
- `state`
- `city`
- `device_type`
- `impressions`
- `clicks`
- `conversions`
- `spend_inr`

### Checks to Perform

- Are column names correct?
- Are data types correct?
- Are numeric columns stored as numbers?
- Are date columns formatted correctly?
- Are campaign IDs available in both datasets?
- Are any important columns missing?

---

## 5. Check Row Counts

Start with a simple record count comparison.

### SQL File


sql/02_compare_record_counts.sql

Questions to Answer
How many rows are in the source dataset?
How many rows are in the dashboard dataset?
Is the dashboard missing rows?
Does the dashboard have extra rows?
Is the mismatch happening by platform, date, or state?

### Expected Output

| Check     | Source Rows | Dashboard Rows | Difference | Status |
| --------- | ----------: | -------------: | ---------: | ------ |
| Row count |         500 |            485 |         15 | Fail   |


### Interpretation

If source rows are greater than dashboard rows, some records may be missing from the dashboard.

If dashboard rows are greater than source rows, there may be duplicate, stale, or extra records in the dashboard layer.

## 6. Compare Total Metrics

After row count comparison, compare business metrics.

### SQL File
sql/03_compare_total_metrics.sql

### Metrics to Compare
Total impressions
Total clicks
Total conversions
Total spend in INR

### Questions to Answer
Is dashboard spend matching source spend?
Are clicks matching?
Are impressions matching?
Are conversions matching?
Which metric has the highest difference?
What is the percentage difference?

### Expected Output
| Metric | Source Value | Dashboard Value | Difference | Status |
| ------ | -----------: | --------------: | ---------: | ------ |
| Spend  |   ₹12,50,000 |      ₹11,85,000 |    ₹65,000 | Fail   |
| Clicks |       48,500 |          46,900 |      1,600 | Fail   |

## 7. Check Missing Campaigns or Records

If dashboard totals are lower, check whether source records are missing from the dashboard.

### SQL File
sql/04_find_missing_campaigns.sql

### Questions to Answer
Which campaign IDs exist in source but not in dashboard?
Which campaign/date/platform records are missing?
Which platform has the most missing records?
Which state or city is affected?
How much spend is missing because of missing records?

### Business Key Used
campaign_id + report_date + platform + state + city + device_type

### Why This Matters

A campaign may exist in both datasets, but some dates, cities, or device records may still be missing.

That is why we compare at detailed business key level, not only campaign ID level.

## 8. Check Duplicate Records

If dashboard totals are higher than source, or if totals look suspicious, check duplicates.

### SQL File
sql/05_check_duplicate_records.sql

### Questions to Answer
Are there duplicate records in source data?
Are there duplicate records in dashboard data?
Which campaign/date/platform combinations are duplicated?
Are duplicates concentrated in one platform?
Are duplicates caused by repeated loads?

### Duplicate Business Key
campaign_id + report_date + platform + state + city + device_type

### Possible Causes
Same file loaded multiple times
Incremental load failed
Incorrect merge/upsert logic
Join created multiple records
No proper unique key was applied

## 9. Validate Campaign Mapping

Mapping issues are very common in marketing analytics reporting.

### Dataset Used
data/campaign_mapping_reference_data.csv

### Questions to Answer
Are all source campaigns available in the mapping table?
Are any mapping records missing?
Are any mapping records inactive?
Are business unit, channel, funnel stage, and region populated?
Are missing dashboard records connected to mapping issues?

### Why This Matters

If the reporting layer uses an inner join with mapping data, campaigns missing from the mapping table may be excluded from the dashboard.

### Example issue:

Source campaign exists, but mapping is missing.
Because of this, the campaign is not included in the reporting layer.

## 10. Compare by Breakdown Levels

Do not only compare overall totals.

Break down the mismatch by different dimensions.

### Recommended Breakdowns

| Breakdown   | Purpose                             |
| ----------- | ----------------------------------- |
| Date        | Find missing days or refresh delays |
| Platform    | Find platform-specific issues       |
| Campaign    | Find campaign-level mismatches      |
| State       | Find regional issues                |
| City        | Find city-level reporting gaps      |
| Device type | Find dashboard filter issues        |

### Example

If total spend is lower in the dashboard, check:

Overall spend
↓
Spend by platform
↓
Spend by campaign
↓
Spend by date
↓
Spend by city/state

This helps narrow down the issue.

## 11. Run Final Reconciliation

After all checks, run the final reconciliation query.

### SQL File
sql/06_final_reconciliation_query.sql

### This Should Summarise
Source row count
Dashboard row count
Row difference
Source spend
Dashboard spend
Spend difference
Missing records
Duplicate records
Mapping issues
Final investigation conclusion

## 12. Identify the Most Likely Root Cause

After reviewing SQL results, identify the most likely root cause.

### Possible Root Causes
| Root Cause        | Meaning                                        |
| ----------------- | ---------------------------------------------- |
| Missing records   | Source records are not present in dashboard    |
| Duplicate records | Same records are counted more than once        |
| Mapping issue     | Campaign mapping is missing or inactive        |
| Date mismatch     | Source and dashboard use different date ranges |
| Filter issue      | Dashboard applies additional filters           |
| Join issue        | Join logic excludes valid records              |
| Refresh delay     | Dashboard has not received latest data         |
| Aggregation issue | Metrics are grouped differently                |


## 13. Write the Root Cause Summary

Use:

templates/root-cause-template.md

A good root cause summary should explain:

What happened
Which data was affected
Which checks were performed
What caused the issue
What is the impact
What should be done next

### Example
The dashboard spend is lower than the source platform spend because 15 valid source records are missing from the dashboard export. These missing records are linked to campaigns with inactive or missing mapping records. As a result, these campaigns may have been excluded during the reporting transformation process.

## 14. Prepare Stakeholder Update

Use:

templates/stakeholder-update-template.md

The stakeholder update should be simple and business-friendly.

Avoid overly technical wording.

### Technical Version
The inner join between source and mapping table removed rows due to missing mapping keys.
Business-Friendly Version
Some valid campaign records were not included in the dashboard because their campaign mapping details were missing.


## 15. Final Investigation Checklist

Use this final checklist before closing the issue.

| Check                            | Completed? | Notes |
| -------------------------------- | ---------- | ----- |
| Business issue understood        |            |       |
| Source of truth confirmed        |            |       |
| Source dataset reviewed          |            |       |
| Dashboard dataset reviewed       |            |       |
| Mapping dataset reviewed         |            |       |
| Row count checked                |            |       |
| Total metrics compared           |            |       |
| Missing campaigns checked        |            |       |
| Duplicate records checked        |            |       |
| Mapping issues checked           |            |       |
| Date-level comparison done       |            |       |
| Platform-level comparison done   |            |       |
| State/city-level comparison done |            |       |
| Final reconciliation completed   |            |       |
| Root cause documented            |            |       |
| Stakeholder update prepared      |            |       |
| Recommendations added            |            |       |


## 16. Final Notes for Learners

A good data engineer does not only write SQL.

A good data engineer should also:

Understand the business problem
Ask the right questions
Compare the right datasets
Check multiple possible causes
Explain findings clearly
Recommend prevention steps

This checklist helps you practise that real-world investigation mindset.











