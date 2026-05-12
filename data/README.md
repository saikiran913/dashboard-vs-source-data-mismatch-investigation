
# Dataset Documentation

## Purpose

This folder contains the dummy datasets used for the **Dashboard vs Source Data Mismatch Investigation** project.

The datasets are created for learning and practice purposes. They help students, freshers, junior data engineers, analysts, and SQL learners understand how to investigate mismatches between source/platform data and dashboard/reporting data.

The data is based on a simple Indian marketing analytics scenario using:

- Indian states and cities
- Indian campaign-style names
- Marketing platforms
- Device types
- Campaign performance metrics
- Spend values in Indian Rupees (INR)

---

## Files Included

This folder contains three main datasets:

```text
source_platform_campaign_data.csv
dashboard_export_campaign_data.csv
campaign_mapping_reference_data.csv
````

---

## 1. Source Platform Campaign Data

File name:
source_platform_campaign_data.csv


### Purpose

This dataset represents the original campaign performance data coming from marketing platforms.

In this project, this dataset is treated as the **source of truth**.

In a real-world company, this type of data may come from:

* Google Ads
* Meta Ads
* YouTube Ads
* LinkedIn Ads
* Programmatic platforms
* Marketing platform CSV exports
* Raw ingestion tables

### Columns

| Column Name     | Description                                    |
| --------------- | ---------------------------------------------- |
| `source_row_id` | Unique row identifier for source records       |
| `report_date`   | Campaign reporting date                        |
| `platform`      | Marketing platform name                        |
| `campaign_id`   | Unique campaign identifier                     |
| `campaign_name` | Campaign name                                  |
| `state`         | Indian state                                   |
| `city`          | Indian city                                    |
| `device_type`   | Device type such as Mobile, Desktop, or Tablet |
| `impressions`   | Number of ad impressions                       |
| `clicks`        | Number of ad clicks                            |
| `conversions`   | Number of conversions                          |
| `spend_inr`     | Campaign spend in Indian Rupees                |

### How It Is Used

This dataset is compared against the dashboard export dataset to check whether dashboard numbers match the source data.

---

## 2. Dashboard Export Campaign Data

File name:
dashboard_export_campaign_data.csv



### Purpose

This dataset represents the data exported from a dashboard or final reporting layer.

In a real-world company, this data may come from:

* Power BI dashboard export
* Looker Studio report export
* Tableau dashboard export
* Excel reporting file
* Final reporting table
* BI semantic layer

This dataset is expected to match the source platform data, but in this project it contains intentional mismatch scenarios for investigation practice.

### Columns

| Column Name        | Description                                        |
| ------------------ | -------------------------------------------------- |
| `dashboard_row_id` | Unique row identifier for dashboard records        |
| `report_date`      | Campaign reporting date                            |
| `platform`         | Marketing platform name                            |
| `campaign_id`      | Unique campaign identifier                         |
| `campaign_name`    | Campaign name                                      |
| `state`            | Indian state                                       |
| `city`             | Indian city                                        |
| `device_type`      | Device type such as Mobile, Desktop, or Tablet     |
| `impressions`      | Number of ad impressions shown in dashboard        |
| `clicks`           | Number of ad clicks shown in dashboard             |
| `conversions`      | Number of conversions shown in dashboard           |
| `spend_inr`        | Campaign spend shown in dashboard in Indian Rupees |

### How It Is Used

This dataset is compared against the source platform dataset to identify:

* Missing records
* Metric differences
* Campaign-level mismatches
* Platform-level mismatches
* State/city-level mismatches
* Device-level mismatches

---

## 3. Campaign Mapping Reference Data

File name:
campaign_mapping_reference_data.csv


### Purpose

This dataset represents a campaign mapping or reference table.

In real marketing analytics projects, mapping tables are used to classify raw campaign data into business-friendly reporting fields.

For example, a raw campaign may need to be mapped to:

* Business unit
* Marketing channel
* Funnel stage
* Region
* Account manager
* Mapping status

Mapping tables are very important because dashboard/reporting layers often depend on them.

If mapping records are missing or inactive, valid source records may be excluded from reporting.

### Columns

| Column Name                | Description                                                  |
| -------------------------- | ------------------------------------------------------------ |
| `mapping_row_id`           | Unique row identifier for mapping records                    |
| `campaign_id`              | Campaign ID used for joining with source/dashboard data      |
| `campaign_name`            | Original campaign name                                       |
| `normalized_campaign_name` | Cleaned or standardised campaign name                        |
| `business_unit`            | Business unit classification                                 |
| `marketing_channel`        | Marketing channel classification                             |
| `funnel_stage`             | Funnel stage such as Awareness, Consideration, or Conversion |
| `region`                   | Regional classification                                      |
| `state`                    | Indian state                                                 |
| `account_manager`          | Dummy account manager name                                   |
| `mapping_status`           | Status of mapping such as Active, Inactive, or Missing       |
| `mapping_comment`          | Notes about the mapping record                               |

### How It Is Used

This dataset is used to check whether campaign mapping issues are causing dashboard mismatches.

For example:
A campaign exists in the source data, but the campaign ID is missing or inactive in the mapping reference table.


This can cause the campaign to be excluded from dashboard reporting.

---

## Dataset Relationship

The three datasets are connected using `campaign_id`.


source_platform_campaign_data
        |
        | campaign_id
        ↓
campaign_mapping_reference_data
        |
        | campaign_id
        ↓
dashboard_export_campaign_data


Simple relationship:


Source data = original campaign performance records

Dashboard data = reporting/exported campaign performance records

Mapping data = campaign classification and business logic reference



## Main Join Key

The main join key used across datasets is:


campaign_id


However, for detailed record-level comparison, this project uses a fuller business key:


campaign_id + report_date + platform + state + city + device_type


This is important because a campaign may exist in both source and dashboard datasets, but some specific dates, cities, states, or devices may still be missing.

---

## Metrics Available

The main metrics used in this project are:

| Metric        | Meaning                                     |
| ------------- | ------------------------------------------- |
| `impressions` | Number of times an ad was shown             |
| `clicks`      | Number of times users clicked the ad        |
| `conversions` | Number of successful actions or conversions |
| `spend_inr`   | Advertising spend in Indian Rupees          |

---

## Dimensions Available

The main dimensions used in this project are:

| Dimension           | Meaning                 |
| ------------------- | ----------------------- |
| `report_date`       | Reporting date          |
| `platform`          | Marketing platform      |
| `campaign_id`       | Campaign identifier     |
| `campaign_name`     | Campaign name           |
| `state`             | Indian state            |
| `city`              | Indian city             |
| `device_type`       | Device category         |
| `business_unit`     | Business classification |
| `marketing_channel` | Marketing channel       |
| `funnel_stage`      | Customer journey stage  |
| `region`            | Regional grouping       |
| `mapping_status`    | Mapping validity/status |

---

## Example Investigation Questions

These datasets can help answer questions like:

1. Does the dashboard have the same number of rows as the source?
2. Are total impressions, clicks, conversions, and spend matching?
3. Which campaigns are missing from the dashboard?
4. Which source records are not present in the dashboard export?
5. Are any duplicate records present?
6. Are mapping table issues causing records to be excluded?
7. Which platform has the largest mismatch?
8. Which Indian state or city is affected most?
9. Is the mismatch related to a specific device type?
10. What is the final root cause of the mismatch?

---

## Expected Learning Outcome

After using these datasets, learners should understand how to:

* Load CSV files into a local SQL database
* Create tables from dataset schemas
* Compare source and dashboard data
* Investigate missing campaign records
* Check duplicate records
* Validate campaign mapping issues
* Calculate metric differences
* Prepare a root cause explanation
* Communicate findings clearly

---

## How to Use These Datasets

### Step 1: Create Tables

Run:

sql/01_create_tables.sql


This creates the required empty tables.

### Step 2: Import CSV Files

Import the CSV files into the matching tables:

| CSV File                              | Table Name                        |
| ------------------------------------- | --------------------------------- |
| `source_platform_campaign_data.csv`   | `source_platform_campaign_data`   |
| `dashboard_export_campaign_data.csv`  | `dashboard_export_campaign_data`  |
| `campaign_mapping_reference_data.csv` | `campaign_mapping_reference_data` |

### Step 3: Run SQL Checks

Run the SQL scripts in this order:

```text
sql/02_compare_record_counts.sql
sql/03_compare_total_metrics.sql
sql/04_find_missing_campaigns.sql
sql/05_check_duplicate_records.sql
sql/06_final_reconciliation_query.sql
```

---

## Recommended Local Tool

For beginners, the easiest tool is:

DB Browser for SQLite


You can follow the local setup guide here:


sql/LOCAL_SQL_TESTING_GUIDE.md


---

## Important Notes

These datasets are dummy datasets.

They do not contain:

* Real company data
* Real client data
* Real customer data
* Real campaign data
* Confidential business information
* Production system data

The data is created only for learning, practice, and portfolio-building purposes.

---

## Why Dummy Data Is Used

Dummy data is used because real business data is usually confidential.

Using dummy data allows learners to practise realistic data engineering investigation scenarios without exposing sensitive information.

This is also a good practice for public GitHub repositories.

---

## Final Note

These datasets are designed to support a real-world style data engineering investigation.

The goal is not only to practise SQL, but also to learn how a data engineer thinks when a dashboard number does not match the source data.

The focus is on:


Understand the issue
Compare the datasets
Find the mismatch
Identify the root cause
Explain the finding
Recommend the fix

