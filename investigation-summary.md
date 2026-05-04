
# Investigation Summary

## Purpose of This Investigation

The purpose of this investigation is to understand why the dashboard export data does not match the source platform campaign data.

In real-world data engineering projects, this type of issue is common when data moves through multiple layers such as:


Source Platform
    ↓
Raw Data Layer
    ↓
Transformation Layer
    ↓
Mapping / Business Logic Layer
    ↓
Reporting Table
    ↓
Dashboard

A mismatch can happen at any of these layers.

This investigation follows a structured SQL-based approach to compare the source data, dashboard export data, and campaign mapping reference data.

## Datasets Reviewed

This investigation uses three datasets.

### 1. Source Platform Campaign Data

File:

data/source_platform_campaign_data.csv

This dataset represents campaign performance data from the original marketing platform.

It is treated as the source dataset for this project.

### 2. Dashboard Export Campaign Data

File:

data/dashboard_export_campaign_data.csv

This dataset represents the data shown in the reporting dashboard or BI layer.

It is compared against the source platform data to identify mismatches.

### 3. Campaign Mapping Reference Data

File:

data/campaign_mapping_reference_data.csv

This dataset represents mapping logic used to classify campaigns by region, channel, campaign objective, and business category.

Mapping issues can cause valid source records to be excluded or classified incorrectly.


## Metrics Compared

The investigation compares key marketing analytics metrics:

| Metric      | Description                              |
| ----------- | ---------------------------------------- |
| impressions | Number of times an ad was shown          |
| clicks      | Number of times users clicked the ad     |
| spend_inr   | Campaign spend in Indian Rupees          |
| conversions | Number of successful actions/conversions |
| revenue_inr | Revenue generated in Indian Rupees       |


These metrics are compared between the source dataset and dashboard dataset.

## Main Checks Performed

This project will perform the following checks.

### 1. Record Count Check

The first check compares the total number of records in the source data and dashboard data.

Purpose:

Identify whether rows are missing
Identify whether extra rows exist
Confirm whether the dashboard contains the same level of data as the source

Example question:

Does the dashboard export contain the same number of rows as the source platform data?

### 2. Total Metrics Check

The second check compares total business metrics between both datasets.

Metrics checked:

Total impressions
Total clicks
Total spend
Total conversions
Total revenue

Purpose:

Identify whether the dashboard totals match the source totals
Understand the size of the mismatch
Find which metrics are affected

### 3. Missing Campaign Check

This check identifies campaigns that exist in the source data but are missing from the dashboard export.

Purpose:

Find campaigns dropped during transformation
Find campaigns excluded due to mapping issues
Find campaigns removed due to dashboard filters or join logic

Example question:

Which campaign IDs are present in the source data but missing from the dashboard export?

### 4. Extra Campaign Check

This check identifies campaigns that exist in the dashboard export but do not exist in the source platform data.

Purpose:

Find stale dashboard records
Find previously loaded records that were not removed
Find dashboard records coming from another source or incorrect load

### 5. Duplicate Record Check

This check identifies duplicate rows based on a business key.

Example business key:

campaign_id + campaign_date + platform + city + state

Purpose:

Find duplicate campaign records
Identify possible repeated file loads
Detect incremental load issues
Prevent inflated dashboard metrics

### 6. Mapping Validation Check

This check compares source campaigns against the campaign mapping reference table.

Purpose:

Identify campaign IDs missing from the mapping table
Identify invalid or incomplete mapping values
Understand whether mapping issues caused reporting exclusions

Example issue:

A campaign exists in the source data, but it does not have a valid mapping record. Because of this, it may be excluded from the dashboard reporting table.

### 7. Date-Level Comparison

This check compares metrics by date.

Purpose:

Identify whether the mismatch is happening on specific dates
Detect missing days
Find possible refresh or date filter issues

Example question:

Is the mismatch happening across the full period or only on selected dates?

### 8. Platform-Level Comparison

This check compares metrics by platform.

Purpose:

Identify whether one platform is causing most of the mismatch
Check if platform-specific data is missing or duplicated
Understand whether platform naming differences are affecting reporting

Example platforms:

Google Ads
Meta Ads
YouTube Ads
LinkedIn Ads
Programmatic Ads

### 9. City/State-Level Comparison

This check compares metrics by Indian city and state.

Purpose:

Identify whether mismatch is specific to certain regions
Check if regional mapping issues exist
Understand whether location-level filters are affecting dashboard totals

Example cities:

Hyderabad
Bengaluru
Mumbai
Delhi
Chennai
Pune

### 10. Final Reconciliation Check

The final check produces a summary of the mismatch between source and dashboard data.

The output should show:

Source totals
Dashboard totals
Difference amount
Difference percentage
Affected metrics
Possible root cause

This helps prepare the final root cause analysis and stakeholder update.

## Expected Findings

The investigation may identify one or more of the following findings:

Some campaigns are missing from the dashboard export
Some campaign IDs are missing from the mapping table
Duplicate records exist in either source or dashboard data
Dashboard totals are lower than source totals
Certain platforms or regions are affected more than others
Join or filter logic may be excluding valid records
Dashboard data may not have refreshed fully

## Investigation Output

At the end of the investigation, we should be able to produce:

A clear mismatch summary
A list of affected campaigns
A list of missing or duplicate records
Mapping issue findings
Metric-level reconciliation output
Root cause explanation
Final recommendations


## Summary

This investigation shows how a data engineer can move from a vague business issue like:

“The dashboard numbers do not match.”

to a structured technical explanation such as:

“The mismatch is mainly caused by missing campaign mapping records, which caused some valid source campaigns to be excluded from the dashboard reporting layer.”
