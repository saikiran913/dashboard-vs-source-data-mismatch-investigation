# Common Root Causes of Dashboard vs Source Data Mismatch

## Purpose

This document explains the most common reasons why dashboard numbers do not match source/platform data.

When a stakeholder says:

> “The dashboard numbers are not matching the source data.”

the issue can happen for many reasons. This document helps learners understand the most common root causes and how to investigate them.

---

## 1. Missing Records in Dashboard

### What It Means

Some records exist in the source/platform data but are missing from the dashboard or reporting layer.

### Example

The source platform has 500 campaign records, but the dashboard export has only 485 records.

### Why It Happens

- Records failed during transformation
- Dashboard filters excluded records
- Mapping table is missing campaign IDs
- Reporting layer uses an inner join
- Pipeline did not fully refresh
- Some files were not loaded

### How to Check

Use:
sql/04_find_missing_campaigns.sql



### What to Look For
Campaigns available in source but missing from dashboard
Missing records by date
Missing records by platform
Missing records by city/state
Missing records connected to mapping gaps

### Business Impact

Dashboard totals may be lower than source totals.

Affected metrics may include:

Spend
Clicks
Impressions
Conversions


## 2. Duplicate Records
### What It Means

The same business record appears more than once.

### Example

The same campaign/date/platform/city/device combination appears two or more times.

### Why It Happens
Same CSV file loaded multiple times
Incremental load appended records instead of replacing them
Merge/upsert logic failed
Join created multiple matching rows
No proper unique business key was used

### How to Check

Use:

sql/05_check_duplicate_records.sql

### Business Key Example
campaign_id + report_date + platform + state + city + device_type

### Business Impact

Duplicate records can increase totals incorrectly.

Dashboard or source data may show inflated:

Spend
Clicks
Impressions
Conversions


## 3. Campaign Mapping Issues
### What It Means

Campaigns are missing from the mapping table or have inactive/invalid mapping records.

### Example

A campaign exists in the source data, but it does not exist in the campaign mapping reference table.

### Why It Happens
New campaigns were launched but not added to mapping
Mapping table is outdated
Campaign name changed
Campaign ID changed
Mapping status is inactive
Business unit, channel, funnel, or region is blank

### How to Check

Use mapping validation logic in:

sql/04_find_missing_campaigns.sql
sql/06_final_reconciliation_query.sql

### Business Impact

If reporting logic depends on mapping, unmapped campaigns may be excluded from the dashboard.

This can make dashboard numbers lower than source data.



## 4. Join Logic Issues
### What It Means

The SQL join used in transformation or reporting removes or duplicates records.

### Example

Using an INNER JOIN between source data and mapping data can remove campaigns that do not exist in the mapping table.

SELECT
    s.*
FROM source_platform_campaign_data s
INNER JOIN campaign_mapping_reference_data m
    ON s.campaign_id = m.campaign_id;



If a campaign is missing from the mapping table, it will not appear in the final output.

### Why It Happens
Inner join used when left join was needed
Join key is incorrect
Campaign ID format is inconsistent
Campaign name used instead of campaign ID
Mapping table contains duplicate campaign IDs
Join is performed at the wrong level of detail

### How to Check

Compare:

Source data before join
Source data after join
Left join output
Inner join output

### Business Impact

Valid records may disappear from reporting tables or become duplicated.

## 5. Date Range Mismatch
### What It Means

Source data and dashboard data are not using the same date range.

### Example

Source export covers:

01-Jan-2026 to 31-Jan-2026

Dashboard filter covers:

02-Jan-2026 to 31-Jan-2026

One missing day can cause a visible mismatch.

### Why It Happens
Dashboard default filter is different
Source export uses campaign date
Dashboard uses load date
Timezone conversion changes date
Month-to-date logic differs
Dashboard excludes latest day

### How to Check

Use date-level checks in:

sql/02_compare_record_counts.sql
sql/03_compare_total_metrics.sql

### Business Impact

Metrics may be lower or higher depending on which dates are included.

## 6. Dashboard Filter Issues
### What It Means

The dashboard applies filters that are not applied in the source export.

Example Filters
Active campaigns only
Selected platforms only
Selected cities/states only
Mapped campaigns only
Current month only
Excluding test campaigns
Excluding paused campaigns

### Why It Happens
Hidden filters in dashboard
Page-level filters
Report-level filters
User-specific filters
Default slicers
Filter logic not documented

### How to Check

Compare dashboard filters with source export filters.

Also check metrics by:

Platform
Campaign
Date
State
City
Device type

### Business Impact

Dashboard may be correct according to its filters, but different from the raw source export.


## 7. Aggregation Logic Difference
### What It Means

Source and dashboard data are grouped or calculated differently.

### Example

Source data is at this level:

campaign_id + report_date

Dashboard data is at this level:

campaign_id + report_date + state + city + device_type

If aggregation is not handled correctly, totals may not match.

### Why It Happens
Different grouping levels
Metrics calculated before filtering in one layer
Metrics calculated after filtering in another layer
Dashboard applies rounding
Dashboard excludes null values
Dashboard uses calculated fields

### How to Check

Compare metrics at the same grain:

campaign_id + report_date + platform + state + city + device_type

### Business Impact

Overall numbers may look different even when records appear similar.

## 8. Data Refresh Delay
### What It Means

Dashboard data is not updated to the latest source data.

### Example

Source data is available until:

31-Jan-2026

Dashboard data is available only until:

29-Jan-2026

### Why It Happens
Pipeline failed
Dashboard refresh failed
Source data arrived late
Scheduled job did not run
Reporting table is behind raw table
Dashboard cache is outdated

### How to Check

Compare minimum and maximum report dates in both datasets.

Use:

sql/01_create_tables.sql
sql/02_compare_record_counts.sql
sql/03_compare_total_metrics.sql

### Business Impact

Dashboard may underreport latest performance.



## 9. Platform Naming Differences
### What It Means

The same platform is written differently across datasets.

### Example

Source data:

Meta Ads

Dashboard data:

Facebook Ads

or

Google Ads

Dashboard data:

Google

### Why It Happens
Manual naming differences
Platform names changed during transformation
Mapping table standardises names differently
Case sensitivity
Extra spaces
Abbreviations

### How to Check

Compare distinct platform names in both datasets.

### Example:

SELECT DISTINCT platform
FROM source_platform_campaign_data;

SELECT DISTINCT platform
FROM dashboard_export_campaign_data;


### Business Impact

Join or grouping logic may fail if names are inconsistent.

## 10. Data Type or Formatting Issues
### What It Means

Columns may look similar but have different formats.

### Examples

Campaign ID in source:

CMP001

Campaign ID in dashboard:

cmp001

Spend in source:

12500.50

Spend in dashboard:

12,500.50

Date in source:

2026-01-31

Date in dashboard:

31/01/2026

### Why It Happens
CSV import issue
Date format issue
Numeric fields imported as text
Extra spaces in IDs
Upper/lowercase mismatch
Special characters in campaign names

### How to Check

Review:

Column formats
Data types
Distinct values
Null values
Leading/trailing spaces
Date format consistency

### Business Impact

Joins may fail, filters may behave incorrectly, and aggregations may produce wrong totals.


### Summary Table
| Root Cause              | Dashboard Impact                  | Common SQL Check              |
| ----------------------- | --------------------------------- | ----------------------------- |
| Missing records         | Dashboard totals lower            | Left join source to dashboard |
| Duplicate records       | Totals inflated                   | Group by business key         |
| Mapping issues          | Records excluded or misclassified | Join source to mapping        |
| Join issues             | Records removed or duplicated     | Compare before/after join     |
| Date mismatch           | Wrong reporting period            | Compare min/max dates         |
| Dashboard filters       | Dashboard differs from source     | Compare by dimensions         |
| Aggregation differences | Totals mismatch                   | Group at same grain           |
| Refresh delay           | Latest data missing               | Compare latest report date    |
| Naming differences      | Joins/grouping fail               | Compare distinct values       |
| Formatting issues       | Matching fails                    | Check data types and formats  |


###Final Note

Most dashboard mismatch issues are not solved by one query.

A good investigation usually combines:

Row count checks
Metric comparison
Missing record checks
Duplicate checks
Mapping validation
Date-level comparison
Platform-level comparison
Final reconciliation

This is why the project uses multiple SQL scripts instead of only one query.






