# Stakeholder Update Template

## Purpose

Use this template to share a clear, simple, and business-friendly update when a dashboard vs source data mismatch issue is being investigated.

This template is useful for updating:

- Business stakeholders
- Marketing teams
- Reporting teams
- Project managers
- Data engineering leads
- Analytics teams

The goal is to explain the issue without making it too technical.

---

## 1. Update Title

Dashboard vs Source Data Mismatch Investigation Update


## 2. Issue Summary

Write a short summary of what was reported.

The campaign performance dashboard is showing different numbers compared to the source platform export for the same reporting period.

Example:
The dashboard is showing lower spend, clicks, and conversions compared to the source platform campaign data for selected Indian marketing campaigns.


## 3. Affected Area

Fill in the affected dashboard, metrics, and reporting period.

Dashboard / Report:
Affected page:
Affected metric(s):
Date range:
Market / Region:
Platform(s):
Reported by:
Current status:

### Example:

Dashboard / Report: Campaign Performance Dashboard
Affected page: Monthly Campaign Summary
Affected metric(s): Spend, clicks, conversions
Date range: 01-Jan-2026 to 31-Jan-2026
Market / Region: India
Platform(s): Google Ads, Meta Ads, YouTube Ads
Reported by: Marketing Analytics Team
Current status: Investigation completed


## 4. Investigation Completed

Summarise what checks were performed.

The following checks were completed as part of the investigation:

1. Source vs dashboard row count comparison
2. Total metric comparison
3. Missing campaign/record check
4. Duplicate record check
5. Campaign mapping validation
6. Platform-level comparison
7. Date-level comparison
8. Final reconciliation summary

Business-friendly version:
We compared the dashboard data against the source data at multiple levels, including total metrics, campaign-level records, platform-level data, and mapping reference data.


## 5. Key Findings

Write the most important findings in simple language.

Finding 1:
Finding 2:
Finding 3:
Finding 4:

Example:

Finding 1: The source data contains more campaign records than the dashboard export.

Finding 2: Some valid source campaign records are missing from the dashboard data.

Finding 3: A few missing records are linked to missing or inactive campaign mapping entries.

Finding 4: Because these records are missing, dashboard spend, clicks, and conversions are lower than the source platform totals.


## 6. Business Impact

Explain how the issue affects reporting or decision-making.

The dashboard may currently underreport selected campaign metrics. This can affect campaign performance reviews, budget discussions, and stakeholder confidence in the dashboard numbers.

Example:
Because some valid campaign records are missing from the dashboard export, the dashboard may show lower spend, clicks, and conversions than the source data. Business users should treat the affected dashboard numbers as under investigation until the mapping and reconciliation checks are completed.


## 7. Root Cause Summary

Explain the root cause in business-friendly language.

Avoid saying only technical things like:

The inner join removed records due to missing mapping keys.

Use simple wording like:
Some valid campaign records were not included in the dashboard because the campaign mapping table did not contain active mapping details for those campaigns.

Example:
The most likely root cause is missing or inactive campaign mapping records. These mapping gaps may have caused some valid source campaign records to be excluded from the dashboard reporting layer.


## 8. Recommended Action

List the next actions clearly.

| Action                                      | Owner                      | Priority | Status      |
| ------------------------------------------- | -------------------------- | -------- | ----------- |
| Review missing campaign mapping records     | Data / Analytics Team      | High     | Not started |
| Update inactive or missing mappings         | Data / Analytics Team      | High     | Not started |
| Re-run dashboard transformation or refresh  | Data Engineering Team      | High     | Not started |
| Re-run source vs dashboard reconciliation   | Data Engineering Team      | High     | Not started |
| Confirm corrected numbers with stakeholders | Reporting / Analytics Team | Medium   | Not started |


Short version:

Recommended next step is to update the missing/inactive campaign mapping records, refresh the reporting layer, and re-run the reconciliation checks to confirm that source and dashboard totals are aligned.


## 9. Current Status and Next Update

Use this section to tell stakeholders where the issue stands now.

Current status:
Next step:
Expected update:
Risk / dependency:

Example:
Current status: Initial investigation completed.
Next step: Review and update missing campaign mapping records.
Expected update: After mapping correction and dashboard refresh.
Risk / dependency: Final dashboard numbers may remain different until mapping updates are completed and the reporting layer is refreshed.


## 10. Final Stakeholder Message

Use this as a ready-to-send update.


Hi Team,

We have completed the initial investigation into the dashboard vs source data mismatch.

The dashboard is currently showing different values compared to the source platform data for selected campaign metrics. We compared the source data and dashboard export across row counts, total metrics, campaign-level records, platform-level data, duplicate checks, and campaign mapping records.

The main finding is that some valid source campaign records are missing from the dashboard export. A portion of these missing records appears to be linked to missing or inactive campaign mapping entries. Because of this, the dashboard may be underreporting metrics such as spend, clicks, and conversions for the affected campaigns.

Recommended next step is to review and update the missing/inactive campaign mapping records, refresh the reporting layer, and re-run the reconciliation checks to confirm that the dashboard numbers align with the source data.

We will share the next update after the mapping review and reconciliation validation are completed.

Thanks.







