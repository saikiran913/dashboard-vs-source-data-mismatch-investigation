# Local SQL Testing Guide

## Purpose

This guide explains how to test the SQL scripts in this project on a local computer without using any cloud platform.

The project can be tested using a free tool called **DB Browser for SQLite**.

This is useful for students, freshers, and beginners who want to practise SQL locally without using BigQuery, Azure, Snowflake, or any paid cloud service.

---

## Tool Used

### DB Browser for SQLite

DB Browser for SQLite is a free desktop tool that allows you to:

- Create a local database
- Create tables
- Import CSV files
- Run SQL queries
- View query results
- Practise SQL without cloud setup

Official website:

[https://sqlitebrowser.org/](https://sqlitebrowser.org/dl/)

# Step 1: Download and Install DB Browser for SQLite
Go to the official website:
[https://sqlitebrowser.org/](https://sqlitebrowser.org/dl/)
Download the version suitable for your operating system.
Install the application.
Open DB Browser for SQLite.

# Step 2: Create a Local Database
Open DB Browser for SQLite.
Click:
New Database
Save the database file with this name:
dashboard_mismatch_project.db
Recommended location:
dashboard-vs-source-data-mismatch-investigation/
If a table creation window appears, you can close/cancel it because we will create tables using SQL scripts.

# Step 3: Run the Table Creation Script
Go to the Execute SQL tab.
Open the file:
sql/01_create_tables.sql
Copy the full SQL script.
Paste it into the SQL editor.
Run the script.

This will create three empty tables:

source_platform_campaign_data
dashboard_export_campaign_data
campaign_mapping_reference_data

# Step 4: Import Source Platform CSV Data
Go to:
File > Import > Table from CSV file
Select this file:
data/source_platform_campaign_data.csv
Use this table name:
source_platform_campaign_data
Make sure these options are selected:
Column names in first line: Yes
Field separator: Comma
Encoding: UTF-8
Complete the import.

# Step 5: Import Dashboard Export CSV Data
Go to:
File > Import > Table from CSV file
Select this file:
data/dashboard_export_campaign_data.csv
Use this table name:
dashboard_export_campaign_data
Make sure these options are selected:
Column names in first line: Yes
Field separator: Comma
Encoding: UTF-8
Complete the import.

# Step 6: Import Campaign Mapping CSV Data
Go to:
File > Import > Table from CSV file
Select this file:
data/campaign_mapping_reference_data.csv
Use this table name:
campaign_mapping_reference_data
Make sure these options are selected:
Column names in first line: Yes
Field separator: Comma
Encoding: UTF-8
Complete the import.

# Step 7: Confirm Data Loaded Successfully

Run this query:

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

Expected result:

Each table should show around 500 rows.

If the row counts are showing correctly, the data import is successful.

# Step 8: Run SQL Scripts in Order

Run the SQL scripts in this order:

1. sql/01_create_tables.sql
2. sql/02_compare_record_counts.sql
3. sql/03_compare_total_metrics.sql
4. sql/04_find_missing_campaigns.sql
5. sql/05_check_duplicate_records.sql
6. sql/06_final_reconciliation_query.sql

Recommended approach:

Do not run the full file at once in the beginning.

Instead, run one SQL block at a time.

This helps you understand:

What each query is checking
What result is returned
Where the mismatch is happening
How the investigation moves step by step

# step 9: What Each SQL Script Does
SQL File	Purpose
01_create_tables.sql	Creates the three tables needed for this project
02_compare_record_counts.sql	Compares row counts between source and dashboard data
03_compare_total_metrics.sql	Compares impressions, clicks, conversions, and spend
04_find_missing_campaigns.sql	Finds source records missing from dashboard export
05_check_duplicate_records.sql	Checks duplicate records in source and dashboard data
06_final_reconciliation_query.sql	Creates final reconciliation and stakeholder-friendly summary

# Step 10: Save Your Work

After importing data and running queries, save the database.

The local database file may look like this:

dashboard_mismatch_project.db

This file is only for local testing.

It should not be uploaded to GitHub.
