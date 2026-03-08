## Customer Risk Segmentation and Spending Intelligence

## Title: Aurora Bank Customer Risk & Spending Analysis

## Table of Contents

- [Overview](#overview)
- [Data Source](#data-source)
- [Problem Statement](#problem-statement)
- [Tools and Methodology](#tools-and-methodology)
- [Dashboard](#dashboard)
- [Key Analysis Findings](#key-analysis-findings)
- [Limitations](#limitations)
- [Recommendations](#recommendations)
- [Conclusion ](#conclusion)
- [Links](#links)

## Overview

This project analyzes customer financial health, transaction behavior, and portfolio risk exposure for Aurora Bank. The goal was to segment customers based on risk levels using Debt-to-Income (DTI) and credit score metrics while uncovering spending patterns across merchant categories.

The analysis provides strategic insights to improve underwriting decisions, enhance portfolio quality, and drive revenue growth through data-driven segmentation.

<ul>
  <li>Identified 20% high-risk customers using DTI & credit scoring</li>
  <li>Analyzed 8+ Merchant Categories for revenue drivers</li>
  <li>Delivered credit risk recommendations for portfolio improvement</li>
</ul>

## Data Source

The dataset consists of five relational tables:

Users Data – Demographics, income, debt, credit score
Cards Data – Card type, credit limit, chip usage
Transactions Data – Transaction amount, location, MCC, errors
MCC Codes – Merchant category classification

The data models simulate a retail banking environment with customer-level financial and transactional records.

## Problem Statement

Aurora Bank needs to understand:

Which customers pose high default risk?
How spending behavior differs across risk segments?
Which merchant categories drive revenue?
Where potential fraud or abnormal behavior may exist?

## Specific Business Problems Being Addressed:

Identifying high-risk customers using DTI and credit score thresholds
Analyzing total debt distribution across customers
Understanding transaction frequency and value by merchant category
Linking spending behavior to credit risk exposure
Supporting underwriting, marketing, and credit limit decisions
Monitoring transaction errors and abnormal activity

## Success Criteria:

The analysis aims to:

Reduce default exposure
Improve credit risk monitoring
Optimize portfolio allocation
Enhance product targeting by risk tier
Identify early fraud warning signals

## Tools and Methodology

*Tools:* 

Microsoft SQL Server – Data extraction and transformation
Power BI – Dashboard creation and interactive visualization
DAX – Risk calculations and financial measures
Excel – Preliminary validation

## Methodology:

Data Cleaning:
Validated relational integrity between users, cards, and transactions. Checked for inconsistencies in income, debt, and credit scores.

## Risk Modeling:

Created a Debt-to-Income Ratio (DTI):
DTI = Total Debt ÷ Annual Income

## Applied risk segmentation rules:

High Risk: DTI > 0.50 OR Credit Score < 600
Medium Risk: Moderate leverage and stable credit
Low Risk: Strong financial health

## Data Processing:
Used DAX measures to compute:

Risk distribution
Average transaction value
Spend by Merchant Category Code (MCC)
Spending behavior by risk segment
Geographic spending analysis

## Visualization:
Built a comprehensive Power BI dashboard for executive-level reporting.

## Project Files

📊 **Power BI Dashboard**
- [Download Power BI File](Aurora_Bank.pbix)

📄 **Project Report**
- [View PDF Report](Aurora_Bank.pdf)

📑 **Presentation**
- [View PowerPoint Presentation](Aurora_Bank_Presentation.pptx)

📑 **Microsoft SQL**
- [View Microsof SQL](Aurora_BanK.pptx)

## Dashboard
## Risk Distribution Overview

Displays portfolio segmentation across Low, Medium, and High Risk customers.

## Spending Analysis

Breakdown of total spend, transaction frequency, and average value by Merchant Category Code.

## Geographic Insights

Spending distribution across merchant locations.

## Behavioral Risk Lens

Spending patterns segmented by risk tier to identify early warning signals.

## Key Analysis Findings
*Portfolio Risk Distribution*

Low Risk: ~45%
Medium Risk: ~35%
High Risk: ~20%

## High-risk customers typically exhibit:

Elevated DTI (>50%)
Credit scores below 600
Higher leverage relative to income

## Risk & Spending Insights
Merchant Category Trends

Groceries → High frequency, low value (engagement driver)
Travel → Low frequency, high value (revenue driver)
Retail & Dining → Strong contribution to interchange income

## Behavioral Observations

High-risk customers show elevated spending in cash-like and luxury categories
Certain geographic areas show higher concentration of failed transactions
Error patterns (e.g., incorrect PIN attempts) reveal customer experience gaps

## Fraud & Credit Signals

*Watch for:*

High-risk customers making unusually high travel purchases
Rapid increase in spending relative to income
High-value transactions inconsistent with customer income profile

## Recommendations

1. Credit Risk Strategy
   
Tighten approvals for DTI above 50%
Implement dynamic credit limit adjustments
Increase monitoring for low credit score customers

3. Product Strategy

Offer premium products to low-risk customers
Structured repayment plans for medium-risk segment
Behavioral monitoring for high-risk customers

3. Marketing Strategy

Cashback incentives on high-frequency MCCs (groceries, dining)
Partner with high-spend merchant categories
Launch region-based campaigns based on spending clusters

## Limitations

No time-series trend analysis (limited historical timeline)
No explicit fraud labels for supervised fraud modeling
Limited behavioral indicators beyond financial metrics
No macroeconomic factors integrated into risk scoring

## Conclusion

This analysis demonstrates how combining financial health indicators with transactional behavior creates a powerful risk intelligence framework.

By segmenting customers using DTI and credit score while mapping their spending patterns, Aurora Bank can proactively manage credit exposure, optimize product offerings, and detect early warning signals of financial distress or fraud.

The project highlights the value of data-driven banking decisions in improving portfolio stability and long-term profitability.

## Links

Power BI Dashboard: [[(https://drive.google.com/drive/folders/1KkeyXAmaJ7yBg49DTcd1AfHSlFV0gcZW?usp=sharing)]
Project Files: ([https://github.com/FaithAdedolapo/Transaction-and-Risk-Analysis-Aurora-Bank-.git))
