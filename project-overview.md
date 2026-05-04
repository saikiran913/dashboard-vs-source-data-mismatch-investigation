# Project Overview

## What This Project Is About

This project explains how to investigate a common real-world data issue:

> Dashboard numbers do not match the source/platform data.

In many companies, dashboards are used by business teams to track performance. These dashboards are usually built on top of multiple data layers such as raw data, transformation tables, mapping tables, reporting tables, and BI tools.

When the dashboard numbers do not match the original source data, data engineers need to investigate where the mismatch is happening.

This project shows that investigation process using dummy marketing analytics data.

---

## Example Scenario

A marketing team is reviewing campaign performance for Indian digital campaigns.

The source platform export shows one set of numbers, but the dashboard export shows different numbers.

Example mismatch:

| Metric         | Source Platform | Dashboard Export |        Issue                      |
|---             |---:             |---:              |---                                |
| Spend          | Higher          | Lower            | Some campaign spend is missing    |
| Clicks         | Higher          | Lower            | Some records may be excluded      |
| Conversions    | Higher          | Lower            | Mapping or filter issue may exist |

The goal is to understand why the dashboard does not match the source data.

---

## Why This Project Matters

In real data engineering work, creating pipelines is only one part of the job.

A data engineer also needs to:

- Validate data quality
- Investigate reporting mismatches
- Compare source and reporting layers
- Find missing records
- Identify duplicate data
- Check transformation logic
- Explain root causes clearly
- Communicate findings to stakeholders

This project helps learners understand that real-world data engineering is not only about writing code. It is also about solving business data problems.

---

## Datasets Used

This project uses three dummy datasets:

### 1. Source Platform Campaign Data

This represents the original campaign performance data from a marketing platform.

File:
data/source_platform_campaign_data.csv

### 2. Dashboard Export Campaign Data

This represents the data exported from a BI dashboard or reporting table.

File:
data/dashboard_export_campaign_data.csv

### 3. Campaign Mapping Reference Data

This represents a mapping/reference table used to classify campaigns.

File:
data/campaign_mapping_reference_data.csv

## Main Investigation Questions

This project tries to answer questions such as:

Does the dashboard have the same number of records as the source?
Are total impressions, clicks, spend, conversions, and revenue matching?
Are any campaigns missing from the dashboard?
Are there duplicate records in either dataset?
Are mapping table issues causing records to be excluded?
Is the mismatch happening for specific platforms, cities, states, or dates?
What is the likely root cause?
What should be recommended to prevent the issue again?

## Investigation Approach

The project follows this flow:

<img width="393" height="433" alt="image" src="https://github.com/user-attachments/assets/fa8349c5-1c5a-4b8e-bed4-78828407d9e5" />

## Skills Practiced

This project helps learners practice:

SQL validation checks
Data reconciliation
Data quality investigation
Marketing analytics metrics
Source vs dashboard comparison
Root cause analysis
Technical documentation
Business-friendly communication

## Expected Outcome

At the end of this project, the learner should be able to explain:

Why dashboard mismatches happen
How to compare two datasets using SQL
How to identify missing or duplicate records
How campaign mapping can affect reporting
How to prepare a simple investigation summary
How to communicate findings professionally

## Important Note

All data used in this project is dummy data.

This project does not use any real company, client, campaign, customer, or production data.


