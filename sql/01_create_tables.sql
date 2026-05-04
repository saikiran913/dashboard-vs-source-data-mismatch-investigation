 /*
================================================================================
Project: Dashboard vs Source Data Mismatch Investigation
File: 01_create_tables.sql

Purpose:
    Create the base tables required for investigating mismatch between
    source platform campaign data and dashboard export data.

Dataset Type:
    Dummy Indian marketing analytics data

Currency:
    INR

SQL Style:
    Beginner-friendly standard SQL / SQLite-friendly format

Why this file exists:
    Before comparing source data and dashboard data, we first need to create
    the table structures.

Tables created in this script:
    1. source_platform_campaign_data
    2. dashboard_export_campaign_data
    3. campaign_mapping_reference_data

Recommended beginner tools:
    - VS Code with SQLite extension
    - DB Browser for SQLite
    - SQLiteStudio
    - PostgreSQL
    - MySQL
    - Free online SQL editors

Note:
    This script avoids cloud-specific syntax so beginners can practise locally.
================================================================================
*/


/*
================================================================================
Clean up existing tables
================================================================================

These DROP statements are useful during practice.

If you already created the tables earlier and want to recreate them,
these commands will remove the old versions first.

In real production systems, you should be careful with DROP TABLE commands.
================================================================================
*/

DROP TABLE IF EXISTS source_platform_campaign_data;
DROP TABLE IF EXISTS dashboard_export_campaign_data;
DROP TABLE IF EXISTS campaign_mapping_reference_data;


/*
================================================================================
1. SOURCE PLATFORM CAMPAIGN DATA TABLE
================================================================================

This table represents the original marketing platform data.

In a real-world project, this data may come from platforms such as:

    - Google Ads
    - Meta Ads
    - YouTube Ads
    - LinkedIn Ads
    - Programmatic platforms

For this project, this table is treated as the source of truth.

If dashboard numbers do not match, we compare the dashboard export against
this source table.
================================================================================
*/

CREATE TABLE source_platform_campaign_data (
    source_row_id TEXT,
    report_date TEXT,
    platform TEXT,
    campaign_id TEXT,
    campaign_name TEXT,
    state TEXT,
    city TEXT,
    device_type TEXT,
    impressions INTEGER,
    clicks INTEGER,
    conversions INTEGER,
    spend_inr REAL
);


/*
================================================================================
2. DASHBOARD EXPORT CAMPAIGN DATA TABLE
================================================================================

This table represents the data exported from a BI dashboard or reporting layer.

In a real-world project, this could be an export from:

    - Power BI
    - Looker Studio
    - Tableau
    - Excel dashboard
    - Final reporting table

The dashboard data is expected to match the source data.

However, in this project, the dashboard dataset contains intentional mismatch
issues so learners can practise investigation.

Possible issues include:

    - Missing campaign records
    - Duplicate records
    - Filtered-out rows
    - Aggregation differences
    - Mapping-related exclusions
================================================================================
*/

CREATE TABLE dashboard_export_campaign_data (
    dashboard_row_id TEXT,
    report_date TEXT,
    platform TEXT,
    campaign_id TEXT,
    campaign_name TEXT,
    state TEXT,
    city TEXT,
    device_type TEXT,
    impressions INTEGER,
    clicks INTEGER,
    conversions INTEGER,
    spend_inr REAL
);


/*
================================================================================
3. CAMPAIGN MAPPING REFERENCE DATA TABLE
================================================================================

This table represents campaign mapping or classification data.

In real marketing analytics projects, mapping tables are used to classify
campaigns into business-friendly fields.

Examples:

    - Business unit
    - Marketing channel
    - Funnel stage
    - Region
    - Account manager
    - Mapping status

Mapping issues are one of the most common reasons why dashboard numbers
do not match source data.

For example:
    If source campaign records do not have a valid mapping entry,
    those records may be excluded during reporting table creation.
================================================================================
*/

CREATE TABLE campaign_mapping_reference_data (
    mapping_row_id TEXT,
    campaign_id TEXT,
    campaign_name TEXT,
    normalized_campaign_name TEXT,
    business_unit TEXT,
    marketing_channel TEXT,
    funnel_stage TEXT,
    region TEXT,
    state TEXT,
    account_manager TEXT,
    mapping_status TEXT,
    mapping_comment TEXT
);


/*
================================================================================
Important Note About Loading CSV Files
================================================================================

This script only creates the empty tables.

After running this script, you need to import the CSV files into these tables.

CSV files:

    data/source_platform_campaign_data.csv
    data/dashboard_export_campaign_data.csv
    data/campaign_mapping_reference_data.csv

If you are using DB Browser for SQLite:

    1. Open your SQLite database
    2. Run this table creation script
    3. Go to File > Import > Table from CSV file
    4. Select the CSV file
    5. Import it into the matching table

If you are using VS Code SQLite extension:

    1. Create or open a .db file
    2. Run this SQL script
    3. Import the CSV files using SQLite extension features
       or another SQLite import method

If you are using PostgreSQL or MySQL:

    Use the import CSV feature available in your SQL tool.
================================================================================
*/


/*
================================================================================
Optional Check 1: Confirm tables exist and data is loaded
================================================================================

After importing the CSV files, run this query.

Expected result:
    Each table should return around 500 rows if the full dummy datasets
    are loaded correctly.
================================================================================
*/

SELECT
    'source_platform_campaign_data' AS table_name,
    COUNT(*) AS total_rows
FROM source_platform_campaign_data

UNION ALL

SELECT
    'dashboard_export_campaign_data' AS table_name,
    COUNT(*) AS total_rows
FROM dashboard_export_campaign_data

UNION ALL

SELECT
    'campaign_mapping_reference_data' AS table_name,
    COUNT(*) AS total_rows
FROM campaign_mapping_reference_data;


/*
================================================================================
Optional Check 2: Preview sample records
================================================================================

These queries help beginners quickly inspect the data after loading.
================================================================================
*/

SELECT *
FROM source_platform_campaign_data
LIMIT 10;

SELECT *
FROM dashboard_export_campaign_data
LIMIT 10;

SELECT *
FROM campaign_mapping_reference_data
LIMIT 10;


/*
================================================================================
Optional Check 3: Review date range
================================================================================

This helps confirm the reporting period available in each campaign dataset.

The report_date column is stored as TEXT for beginner-friendly local SQL usage.
The values should still follow a date format such as YYYY-MM-DD.
================================================================================
*/

SELECT
    'source_platform_campaign_data' AS table_name,
    MIN(report_date) AS min_report_date,
    MAX(report_date) AS max_report_date
FROM source_platform_campaign_data

UNION ALL

SELECT
    'dashboard_export_campaign_data' AS table_name,
    MIN(report_date) AS min_report_date,
    MAX(report_date) AS max_report_date
FROM dashboard_export_campaign_data;


/*
================================================================================
Optional Check 4: Review quick metric totals
================================================================================

This gives a first quick view of total metrics before deeper investigation.

At this stage, we are not solving the mismatch yet.
We are only confirming that data exists and can be aggregated.
================================================================================
*/

SELECT
    'source_platform_campaign_data' AS table_name,
    SUM(impressions) AS total_impressions,
    SUM(clicks) AS total_clicks,
    SUM(conversions) AS total_conversions,
    ROUND(SUM(spend_inr), 2) AS total_spend_inr
FROM source_platform_campaign_data

UNION ALL

SELECT
    'dashboard_export_campaign_data' AS table_name,
    SUM(impressions) AS total_impressions,
    SUM(clicks) AS total_clicks,
    SUM(conversions) AS total_conversions,
    ROUND(SUM(spend_inr), 2) AS total_spend_inr
FROM dashboard_export_campaign_data;


/*
================================================================================
Optional Check 5: Check unique campaign count
================================================================================

This check helps learners understand whether the source and dashboard
contain the same number of unique campaigns.

A mismatch here may indicate missing or extra campaigns.
================================================================================
*/

SELECT
    'source_platform_campaign_data' AS table_name,
    COUNT(DISTINCT campaign_id) AS unique_campaign_count
FROM source_platform_campaign_data

UNION ALL

SELECT
    'dashboard_export_campaign_data' AS table_name,
    COUNT(DISTINCT campaign_id) AS unique_campaign_count
FROM dashboard_export_campaign_data

UNION ALL

SELECT
    'campaign_mapping_reference_data' AS table_name,
    COUNT(DISTINCT campaign_id) AS unique_campaign_count
FROM campaign_mapping_reference_data;


/*
================================================================================
Learning Notes
================================================================================

1. This script creates three simple tables for local SQL practice.

2. The source table represents original platform data.

3. The dashboard table represents reporting/dashboard data.

4. The mapping table represents campaign classification logic.

5. The next step is to compare record counts between source and dashboard.

6. In real-world projects, table creation may happen in tools like:
       - BigQuery
       - Azure Synapse
       - Snowflake
       - Databricks
       - PostgreSQL
       - SQL Server

7. For this beginner-friendly repository, we start with simple SQL first.
   Later, we can add separate BigQuery and Azure versions.
================================================================================
*/
