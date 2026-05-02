If You Find This Useful

If this repository helps you understand real-world data engineering investigations, consider giving it a star.

It helps others discover the project and supports more practical data engineering learning resources.


# Dashboard vs Source Data Mismatch Investigation

## Project Overview

This repository is a real-world data engineering investigation project that shows how to identify and debug mismatches between dashboard numbers and source/platform data.

In many data engineering and analytics projects, business users often report issues like:

> “The dashboard spend does not match the source platform export.”  
> “The number of clicks in the report is different from the raw data.”  
> “Some campaigns are missing from the dashboard.”  
> “Revenue looks lower in the BI report compared to the source system.”

This project explains how a data engineer can investigate these issues using SQL, sample datasets, and a structured root cause analysis approach.

The project uses dummy marketing analytics data based on an Indian business scenario, including Indian campaign names, Indian cities/states, and spend values in Indian Rupees (INR).

---

## Project Goal

The goal of this project is to help students, freshers, junior data engineers, analysts, and SQL learners understand how real-world data mismatch investigations are handled.

This repository does not simply show SQL queries. It explains the full thinking process behind a data issue investigation:

1. Understand the business problem
2. Review the source and dashboard datasets
3. Compare record counts
4. Compare total metrics
5. Identify missing campaigns or records
6. Check for duplicate rows
7. Validate metric aggregation logic
8. Prepare a final reconciliation and root cause summary

By the end of this project, viewers should understand how to investigate a dashboard mismatch issue in a structured and professional way.

---

## Business Problem

A marketing analytics team is using a dashboard to monitor campaign performance across different Indian regions and digital platforms.

The dashboard shows key metrics such as:

- Impressions
- Clicks
- Spend
- Conversions
- Revenue

However, business users noticed that the dashboard numbers do not match the source platform export.

For example:

| Metric      | Source Platform | Dashboard Export | Difference  |
|---          |---:             |---:              |---:         |
| Spend       |    ₹12,50,000   |   ₹11,85,000     |  ₹65,000    |
| Clicks      |     48,500      |    46,900        |    1,600    |
| Conversions |     3,250       |    3,080         |     170     |

The data engineering team needs to investigate why the mismatch is happening.

Possible reasons could include:

- Missing campaigns in the dashboard
- Duplicate records in the source or dashboard table
- Date filter mismatch
- Timezone difference
- Incorrect campaign mapping
- Aggregation logic issue
- Join condition issue
- Dashboard filter issue
- Data refresh delay
- Transformation layer issue

This repository walks through how to investigate these possibilities step by step.

---

## Dataset Description

This project contains three dummy datasets.

All datasets are created for learning purposes only and do not contain any real company, client, customer, or production data.

### 1. Source Platform Campaign Data

File:

data/source_platform_campaign_data.csv



Investigation Workflow

This project follows a simple 8-step investigation process.

Step 1: Understand the Business Issue

Before writing SQL, the first step is to clearly understand the problem.

Example questions:

Which metric is mismatching?
Which dashboard is affected?
Which source system is considered correct?
What date range is affected?
Is the mismatch happening for all campaigns or only selected campaigns?
Is the issue related to spend, clicks, impressions, conversions, or revenue?
When was the issue first noticed?

This step is important because many data investigations fail when the problem is not clearly defined.

Step 2: Review the Datasets

The next step is to understand the available data.

In this project, we compare:
source_platform_campaign_data.csv

against:

dashboard_export_campaign_data.csv

We also review:

campaign_mapping_reference_data.csv

to check whether mapping logic is causing missing or incorrect records.


At this stage, we look at:

Table structure
Column names
Data types
Date fields
Metric fields
Campaign identifiers
Platform names
Mapping columns
Step 3: Compare Record Counts

The first SQL check is usually a record count comparison.

Example question:

Does the dashboard dataset have the same number of records as the source dataset?

If the source table has 500 rows but the dashboard export has fewer rows, this may indicate that some records were dropped during transformation or filtering.

This check helps identify high-level data loss.

Step 4: Compare Total Metrics

After checking record counts, we compare key metrics.

Important metrics include:

Total impressions
Total clicks
Total spend
Total conversions
Total revenue

This helps answer:

Are the total business numbers matching between source and dashboard?

If the totals do not match, we need to investigate at a more detailed level.

Step 5: Find Missing Campaigns

Sometimes the total numbers do not match because some campaigns exist in the source data but are missing from the dashboard export.

This project includes SQL logic to find:

Campaigns available in source but missing in dashboard
Campaigns available in dashboard but missing in source
Campaigns with incorrect mapping
Campaigns excluded because of join/filter conditions

This is one of the most common reasons for dashboard mismatch issues.

Step 6: Check Duplicate Records

Duplicate records can increase spend, clicks, impressions, conversions, and revenue.

In this step, we check whether the same campaign/date/platform combination appears more than once.

Example duplicate key:

campaign_id + campaign_date + platform + city + state

If duplicate records exist, the dashboard may show inflated numbers.

This is a very common issue in data pipelines and reporting systems.

Step 7: Validate Aggregation Logic

Sometimes the source data and dashboard data both contain the correct rows, but the numbers still do not match because the aggregation logic is different.

Examples:

Source is grouped by campaign and date
Dashboard is grouped by campaign, date, and city
Dashboard excludes cancelled campaigns
Dashboard filters only active campaigns
Dashboard applies mapping rules before aggregation
Dashboard uses rounded spend values

This project shows how SQL can be used to compare metrics at different grouping levels.

Step 8: Prepare Final Reconciliation Report

The final step is to prepare a clean explanation for business stakeholders.

A good final investigation report should include:

What issue was reported
What datasets were checked
What SQL checks were performed
What mismatch was found
What caused the issue
What action should be taken
How to prevent the issue in the future

This repository includes templates for:

root-cause-template.md
stakeholder-update-template.md
investigation-checklist.md

These templates help explain technical issues in a business-friendly way.

SQL Files Included

The sql/ folder contains step-by-step SQL scripts.

File	Purpose
01_create_tables.sql	Creates sample tables for source, dashboard, and mapping data
02_compare_record_counts.sql	Compares row counts between source and dashboard
03_compare_total_metrics.sql	Compares total spend, clicks, impressions, conversions, and revenue
04_find_missing_campaigns.sql	Finds campaigns missing from either source or dashboard
05_check_duplicate_records.sql	Checks duplicate records using business keys
06_final_reconciliation_query.sql	Produces a final reconciliation output

These scripts are designed for learning and can be adapted for BigQuery, Azure SQL, Synapse, or other SQL-based platforms.

What Viewers Will Learn

After going through this project, viewers will understand:

How dashboard and source data mismatches happen
How to approach a data issue investigation step by step
How to compare source and dashboard datasets using SQL
How to find missing campaigns or records
How to identify duplicate data
How mapping table issues can affect reporting
How incorrect joins can remove valid records
How to write a root cause summary
How to communicate findings to stakeholders
How data engineers investigate real production-style issues

This project is especially useful for people who want to move beyond basic SQL practice and understand real-world data engineering work.

Who This Project Is For

This project is useful for:

Data engineering students
Freshers preparing for data jobs
Junior data engineers
Data analysts
BI developers
Analytics engineers
SQL learners
Marketing analytics learners
Anyone building a real-world GitHub portfolio
Skills Demonstrated

This project demonstrates the following skills:

SQL data validation
Data reconciliation
Data quality checking
Root cause analysis
Marketing analytics understanding
Dashboard validation
Source-to-reporting comparison
BigQuery-style investigation thinking
Azure/Synapse-style investigation thinking
Technical documentation
Stakeholder communication

Real-World Use Case

In real companies, dashboards are often built on top of several layers:

Source Platform
    ↓
Raw Data Layer
    ↓
Transformation Layer
    ↓
Business Logic / Mapping Layer
    ↓
Reporting Table
    ↓
Dashboard

A mismatch can happen at any layer.

For example:

Source data may arrive late
Raw table may have duplicates
Transformation logic may exclude records
Mapping table may miss campaign IDs
Reporting table may aggregate incorrectly
Dashboard may apply hidden filters

This project helps viewers understand how to move through these layers logically.

Example Root Cause

A possible root cause in this project could be:

Some campaign records existed in the source platform data but were missing from the dashboard export because the campaign mapping table did not contain valid mapping records for those campaigns. As a result, those campaigns were excluded during the transformation or reporting process.

This type of issue is common in real-world marketing analytics pipelines.

Final Recommendation Example

To prevent this issue in the future:

Add automated source vs dashboard reconciliation checks
Validate campaign mapping completeness before dashboard refresh
Create duplicate detection checks
Add daily metric comparison checks
Monitor source data refresh status
Maintain a data quality checklist
Notify stakeholders when mismatches exceed an acceptable threshold

How to Use This Repository

You can use this repository in three ways:

1. Learn the Investigation Flow

Start with the README and understand the full mismatch investigation process.

2. Explore the Datasets

Open the files inside the data/ folder and understand the source, dashboard, and mapping datasets.

3. Run the SQL Checks

Use the SQL files in the sql/ folder to practice comparing datasets and identifying mismatch causes.

You can run the SQL scripts in:

BigQuery
Azure Synapse
Azure SQL Database
PostgreSQL
MySQL
SQLite, with small syntax changes
Future Improvements

Planned future improvements for this repository:

Add BigQuery-specific SQL version
Add Azure Synapse SQL version
Add Power BI validation example
Add Looker Studio validation example
Add Python-based reconciliation script
Add more mismatch scenarios
Add dashboard screenshots using dummy data
Add automated data quality checklist
Add interview-style explanation notes
Disclaimer

This project uses only dummy/sample data created for learning purposes.

It does not contain:

Real client data
Real company data
Real campaign data
Real customer data
Confidential business logic
Production system information

The purpose of this repository is educational. It is designed to help learners understand how real-world data mismatch investigations are handled by data engineers and analytics teams.

Author

Created by Sai Kiran Kommagoni

This repository is part of a real-world data engineering portfolio focused on:

SQL
BigQuery
GCP
Azure
Marketing analytics
Data quality
Dashboard validation
Data issue investigation
If You Find This Useful

If this repository helps you understand real-world data engineering investigations, consider giving it a star.

It helps others discover the project and supports more practical data engineering learning resources.


Use this commit message after updating:

```text
Improve main README with detailed project explanation
