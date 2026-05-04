# Business Problem

## Background

A marketing analytics team is using a dashboard to monitor digital campaign performance across different Indian regions, cities, and platforms.

The dashboard is used by business users to track important campaign metrics such as:

- Impressions
- Clicks
- Spend
- Conversions
- Revenue

The source platform data is treated as the original data coming from advertising platforms such as Google Ads, Meta Ads, YouTube Ads, LinkedIn Ads, and Programmatic platforms.

The dashboard is expected to show the same numbers after data ingestion, transformation, mapping, and reporting logic are applied.

---

## Reported Issue

Business users noticed that the dashboard numbers are not matching the source platform export.

Example issue raised by a stakeholder:

> “The campaign performance dashboard is showing lower spend and clicks compared to the source platform export for the same date range. Can the data engineering team investigate why the numbers are different?”

This type of issue is common in real-world data engineering and analytics projects.

---

## Example Mismatch

The source platform export shows higher numbers than the dashboard export.

| Metric | Source Platform | Dashboard Export | Difference |
|---|---:|---:|---:|
| Impressions | Higher | Lower | Missing volume |
| Clicks | Higher | Lower | Missing clicks |
| Spend | Higher | Lower | Missing spend |
| Conversions | Higher | Lower | Missing conversions |
| Revenue | Higher | Lower | Missing revenue |

The exact difference needs to be identified using SQL validation checks.

---

## Business Impact

A dashboard mismatch can create serious problems for business teams.

If the dashboard numbers are wrong, the team may:

- Underestimate campaign performance
- Overestimate campaign performance
- Make incorrect budget decisions
- Lose trust in reporting
- Spend extra time manually validating numbers
- Delay weekly or monthly reporting
- Escalate the issue to data engineering or analytics teams

For marketing analytics, even a small mismatch in spend, clicks, or conversions can affect campaign decisions and performance reviews.

---

## Possible Causes

The mismatch may happen due to one or more of the following reasons:

### 1. Missing Campaign Records

Some campaigns may exist in the source data but may not appear in the dashboard export.

This can happen if records are dropped during transformation or filtering.

---

### 2. Mapping Table Issues

Campaigns may be excluded if they do not have valid mapping in the reference table.

For example, if a campaign ID is missing from the mapping table, the reporting layer may fail to classify it correctly.

---

### 3. Duplicate Records

Duplicate records can increase totals in either the source data or dashboard data.

This can happen when the same file is loaded more than once or when incremental loads are not handled properly.

---

### 4. Date Filter Mismatch

The source platform and dashboard may be using different date ranges.

For example:

- Source export: 1 January to 31 January
- Dashboard filter: 2 January to 31 January

Even one missing day can create a visible mismatch.

---

### 5. Aggregation Logic Difference

The source data and dashboard data may be grouped differently.

For example:

- Source grouped by campaign and date
- Dashboard grouped by campaign, date, city, and platform

Different grouping logic can cause mismatched totals if not handled correctly.

---

### 6. Join Logic Issue

The dashboard reporting table may join source data with a mapping table.

If the join is incorrect, valid records may be removed or duplicated.

Example:
INNER JOIN campaign_mapping_reference_data

### 7. Dashboard Filter Issue

The dashboard may have filters that are not obvious to the user.

Examples:

Only active campaigns
Only selected platforms
Only selected cities
Only mapped campaigns
Excluding test campaigns

Hidden filters can make dashboard totals different from the source export.

## Investigation Objective

The objective of this project is to investigate why the dashboard export does not fully match the source platform data.

The investigation will focus on:

Comparing record counts
Comparing total metrics
Finding missing campaigns
Checking duplicate records
Reviewing campaign mapping issues
Identifying possible transformation or join problems
Preparing a clear root cause explanation

## Success Criteria

The investigation is successful when we can answer:

Which metrics are mismatching?
How large is the mismatch?
Which campaigns, dates, platforms, cities, or states are affected?
Are records missing from the dashboard?
Are duplicate records present?
Is the campaign mapping table causing the issue?
What is the most likely root cause?
What should be done to prevent the issue in future?

## Final Expected Output

The final output of this investigation should include:

SQL validation results
List of mismatched campaigns or records
Duplicate record findings
Missing campaign findings
Root cause summary
Business-friendly explanation
Final recommendations
