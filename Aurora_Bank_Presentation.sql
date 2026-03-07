----INFO CHECK

SELECT *
	FROM users_data;

SELECT COUNT (*) AS total_user_data
	FROM users_data;

SELECT *
	FROM cards_data

SELECT COUNT (*) as total_card_data
	FROM cards_data;

SELECT *
	FROM transactions_data;

SELECT COUNT (*)
	FROM transactions_data

SELECT *
	FROM mcc_codes

SELECT COUNT (*) as total_mcc_codes
	FROM mcc_codes;


SELECT TOP 10 *
	FROM users_data

SELECT COUNT (errors) AS rows_with_errors
	FROM transactions_data


--- Question 1: Who are Aurora Bank’s risky customers?

SELECT 
    id AS client_id,
    yearly_income,
    total_debt,
    ROUND(total_debt / yearly_income, 2) AS debt_to_income_ratio,
    credit_score
FROM users_data
WHERE yearly_income > 0
ORDER BY debt_to_income_ratio DESC;


--- RISK SEGMENTATION FRAMEWORK (Aurora Bank)

---  Card Exposure
---	1. Number of credit cards
--- 2. Total credit limit

	

       
--- BASE RISK METRICS (CTE)
---We’ll classify customers into Low / Medium / High risk using 3 signals:
--- Debt-to-Income Ratio (DTI) ---	DTI = total_debt / yearly_income

WITH risk_metrics AS (
    SELECT 
        id AS client_id,
        yearly_income,
        total_debt,
        credit_score,
        num_credit_cards,
        CASE 
            WHEN yearly_income = 0 OR yearly_income IS NULL THEN NULL
            ELSE ROUND(
                CAST(total_debt AS FLOAT) / CAST(yearly_income AS FLOAT),
                2
            )
        END AS debt_to_income_ratio
    FROM users_data
)
SELECT *
FROM risk_metrics;

    --- *NULLIF prevents divide-by-zero errors

--- ASSIGN RISK SEGMENTS
  --	Credit Score -- < 580 → poor, 580–669 → fair, 670–739 → good, ≥ 740 → excellent

WITH risk_metrics AS (
    SELECT 
        id AS client_id,
        yearly_income,
        total_debt,
        credit_score,
        num_credit_cards,
        ROUND(total_debt / NULLIF(yearly_income, 0), 2) AS debt_to_income_ratio
    FROM users_data
)
SELECT 
    client_id,
    yearly_income,
    total_debt,
    debt_to_income_ratio,
    credit_score,
    num_credit_cards,
    CASE
        WHEN debt_to_income_ratio > 0.50 OR credit_score < 600 THEN 'High Risk'
        WHEN debt_to_income_ratio BETWEEN 0.30 AND 0.50 OR credit_score BETWEEN 600 AND 699 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_segment
FROM risk_metrics
ORDER BY debt_to_income_ratio DESC;


--- RISK DISTRIBUTION (Management View)
    --- RISK RULES (Simple & Defensible)
		--- Risk Level	Criteria --- LOW	DTI < 0.30 AND credit_score ≥ 700, MEDIUM	DTI 0.30–0.50 OR credit_score 600–699, HIGH	DTI > 0.50 OR credit_score < 600

WITH risk_metrics AS (
    SELECT 
        id AS client_id,
        ROUND(total_debt / NULLIF(yearly_income, 0), 2) AS debt_to_income_ratio,
        credit_score
    FROM users_data
)
SELECT 
    CASE
        WHEN debt_to_income_ratio > 0.50 OR credit_score < 600 THEN 'High Risk'
        WHEN debt_to_income_ratio BETWEEN 0.30 AND 0.50 OR credit_score BETWEEN 600 AND 699 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_segment,
    COUNT(*) AS total_customers
FROM risk_metrics
GROUP BY 
    CASE
        WHEN debt_to_income_ratio > 0.50 OR credit_score < 600 THEN 'High Risk'
        WHEN debt_to_income_ratio BETWEEN 0.30 AND 0.50 OR credit_score BETWEEN 600 AND 699 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END;

---HIGH-RISK CUSTOMERS TO WATCH

SELECT *
FROM (
    SELECT 
        id AS client_id,
        yearly_income,
        total_debt,
        credit_score,
        ROUND(total_debt / NULLIF(yearly_income, 0), 2) AS dti
    FROM users_data
) t
WHERE dti > 0.50
   OR credit_score < 600
ORDER BY dti DESC;

--- *** I segmented customers into risk categories using debt-to-income ratios and credit scores, which are standard indicators in retail banking. This helped identify customers at risk of default and those eligible for premium financial products.

--- Spending patterns by MCC (what people actually spend on)
        --- Understand customer spending behavior by Merchant Category Code (MCC)
        --- We want to answer:
        --- 1.What categories get the most money?
        --- 2.What categories are used most often?
        --- 3. How does spending differ by risk segment?
        --- 4. What categories might signal risk or fraud?

--Total spend & transaction count by MCC
SELECT 
    m.description AS merchant_category,
    COUNT(t.id) AS total_transactions,
    ROUND(SUM(t.amount), 2) AS total_spend,
    ROUND(AVG(t.amount), 2) AS avg_transaction_value
FROM transactions_data t
JOIN mcc_codes m
    ON t.mcc = m.mcc_id
GROUP BY m.description
ORDER BY total_spend DESC;

-- What this tells Aurora Bank
    ---1. Where money actually goes
    ---2. Which categories drive revenue volume vs frequency

 ---  FREQUENCY vs VALUE
        --- Have many small transactions (e.g. groceries) vs Have few but large transactions (e.g. travel)

        SELECT 
    m.description AS merchant_category,
    COUNT(*) AS txn_count,
    ROUND(SUM(t.amount), 2) AS total_spend,
    ROUND(SUM(t.amount) / COUNT(*), 2) AS avg_txn_value
FROM transactions_data t
JOIN mcc_codes m
    ON t.mcc = m.mcc_id
GROUP BY m.description
ORDER BY txn_count DESC;

---OP SPENDING CATEGORIES BY LOCATION
            ---Regional marketing + branch strategy

SELECT 
    merchant_state,
    m.description AS merchant_category,
    ROUND(SUM(t.amount), 2) AS total_spend
FROM transactions_data t
JOIN mcc_codes m
    ON t.mcc = m.mcc_id
GROUP BY merchant_state, m.description
ORDER BY merchant_state, total_spend DESC;


---RISK-BASED SPENDING
        ---What do high-risk customers spend money on?

WITH risk_metrics AS (
    SELECT 
        id AS client_id, 
        CASE 
            WHEN yearly_income = 0 OR yearly_income IS NULL THEN NULL
            ELSE CAST(total_debt AS FLOAT) / CAST(yearly_income AS FLOAT)
        END AS dti,
        credit_score
    FROM users_data
),
risk_segments AS (
    SELECT 
        client_id,
        CASE
            WHEN dti > 0.50 OR credit_score < 600 THEN 'High Risk'
            WHEN dti BETWEEN 0.30 AND 0.50 OR credit_score BETWEEN 600 AND 699 THEN 'Medium Risk'
            ELSE 'Low Risk'
        END AS risk_segment
    FROM risk_metrics
)
SELECT 
    r.risk_segment,
    m.description AS merchant_category,
    COUNT(t.id) AS txn_count,
    ROUND(SUM(t.amount), 2) AS total_spend
FROM transactions_data t
JOIN risk_segments r
    ON t.client_id = r.client_id
JOIN mcc_codes m
    ON t.mcc = m.mcc_id
GROUP BY r.risk_segment, m.description
ORDER BY r.risk_segment, total_spend DESC;


 ---HIGH-RISK SPENDING RED FLAGS
        ---Luxury / travel spend by low credit score users for Potential early warning signals

SELECT 
    m.description AS merchant_category,
    ROUND(AVG(t.amount), 2) AS avg_txn_amount,
    COUNT(*) AS txn_count
FROM transactions_data t
JOIN mcc_codes m
    ON t.mcc = m.mcc_id
JOIN users_data u
    ON t.client_id = u.id
WHERE 
    u.credit_score < 600
GROUP BY m.description
ORDER BY avg_txn_amount DESC;


--- POWER BI KPIs 
--- Total Spend by MCC
--- Avg Transaction Value by MCC
--- MCC Spend by Risk Segment
--- High-Risk Spend %

---I analyzed transaction data by Merchant Category Codes to identify high-value and high-frequency spending categories and overlaid customer risk profiles to understand how spending behavior varies by credit risk.

--- UNUSUALLY HIGH TRANSACTIONS
        ---Anything > 3 standard deviations is statistically abnormal and Very common fraud-detection technique

SELECT *
FROM (
    SELECT 
        id AS transaction_id,
        client_id,
        amount,
        ROUND(AVG(amount) OVER (), 2) AS avg_amount,
        ROUND(STDEV(amount) OVER (), 2) AS std_dev,
        ROUND(AVG(amount) OVER () + 3 * STDEV(amount) OVER (), 2) AS upper_threshold
    FROM transactions_data
    -- WHERE amount > 0   -- optional filter
) sub
WHERE amount > upper_threshold
ORDER BY amount DESC;


---CUSTOMER-LEVEL SPENDING SPIKES

WITH customer_stats AS (
    SELECT 
        client_id,
        AVG(amount) AS avg_amount,
        STDEV(amount) AS std_dev
    FROM transactions_data
    GROUP BY client_id
)
SELECT 
    t.id AS transaction_id,
    t.client_id,
    t.amount,
    cs.avg_amount,
    cs.std_dev
FROM transactions_data t
JOIN customer_stats cs
    ON t.client_id = cs.client_id
WHERE t.amount > cs.avg_amount + 3 * cs.std_dev
ORDER BY t.amount DESC;

--- GEOGRAPHIC ANOMALIES
        --- Same card used in different states (or cities) too frequently
SELECT 
    card_id,
    COUNT(DISTINCT merchant_state) AS states_used
FROM transactions_data
GROUP BY card_id
HAVING COUNT(DISTINCT merchant_state) > 5
ORDER BY states_used DESC;

---REPEATED FAILED TRANSACTIONS
        --- Red flags: Repeated PIN failures, Card testing behavior, Bots

SELECT 
    client_id,
    COUNT(*) AS error_count
FROM transactions_data
WHERE errors IS NOT NULL
GROUP BY client_id
HAVING COUNT(*) > 10
ORDER BY error_count DESC;


---HIGH-RISK CUSTOMERS WITH ABNORMAL SPENDING

WITH risk_segments AS (
    SELECT 
        id AS client_id,
        CASE 
            WHEN yearly_income = 0 OR yearly_income IS NULL THEN NULL
            ELSE CAST(total_debt AS FLOAT) / CAST(yearly_income AS FLOAT)
        END AS dti,
        credit_score
    FROM users_data
),
flagged_customers AS (
    SELECT 
        client_id
    FROM risk_segments
    WHERE dti > 0.5 OR credit_score < 600
)
SELECT 
    t.id AS transaction_id,
    t.client_id,
    t.amount,
    t.merchant_state,
    t.date
FROM transactions_data t
JOIN flagged_customers f
    ON t.client_id = f.client_id
WHERE t.amount > 5000
ORDER BY t.amount DESC;

---RAPID SUCCESSIVE TRANSACTIONS
    ---Indicates: Automated testing, Compromised cards
    SELECT 
    client_id,
    card_id,
    date,
    COUNT(*) AS txn_count
FROM transactions_data
GROUP BY client_id, card_id, date
HAVING COUNT(*) > 20
ORDER BY txn_count DESC;


--- POWER BI VISUALS
    ---   1. Customer Risk Overview
    SELECT 
    CASE
        WHEN yearly_income = 0 OR yearly_income IS NULL THEN 'Unknown'
        WHEN (CAST(total_debt AS FLOAT) / CAST(yearly_income AS FLOAT)) > 0.50 OR credit_score < 600 THEN 'High Risk'
        WHEN (CAST(total_debt AS FLOAT) / CAST(yearly_income AS FLOAT)) BETWEEN 0.30 AND 0.50 OR credit_score BETWEEN 600 AND 699 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_segment,
    COUNT(*) AS customer_count,
    ROUND(AVG(credit_score), 0) AS avg_credit_score,
    ROUND(AVG(total_debt), 2) AS avg_debt,
    ROUND(AVG(yearly_income), 2) AS avg_income
FROM users_data
GROUP BY 
    CASE
        WHEN yearly_income = 0 OR yearly_income IS NULL THEN 'Unknown'
        WHEN (CAST(total_debt AS FLOAT) / CAST(yearly_income AS FLOAT)) > 0.50 OR credit_score < 600 THEN 'High Risk'
        WHEN (CAST(total_debt AS FLOAT) / CAST(yearly_income AS FLOAT)) BETWEEN 0.30 AND 0.50 OR credit_score BETWEEN 600 AND 699 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END;


    --- 2. SPENDING BY MCC SUMMARY
    SELECT 
    m.description AS merchant_category,
    COUNT(t.id) AS transaction_count,
    ROUND(SUM(t.amount), 2) AS total_spend,
    ROUND(AVG(t.amount), 2) AS avg_transaction_value
FROM transactions_data t
JOIN mcc_codes m
    ON t.mcc = m.mcc_id
GROUP BY m.description;


-- 3. FRAUD & ANOMALY SUMMARY
SELECT 
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN errors IS NOT NULL THEN 1 ELSE 0 END) AS failed_transactions,
    ROUND(
        CAST(SUM(CASE WHEN errors IS NOT NULL THEN 1 ELSE 0 END) AS FLOAT) 
        / COUNT(*) * 100,
        2
    ) AS failed_transaction_rate
FROM transactions_data;

    ---4. Geographic Spending Overview 
 SELECT 
    merchant_state,
    COUNT(*) AS transaction_count,
    ROUND(SUM(amount), 2) AS total_spend
FROM transactions_data
GROUP BY merchant_state;


--- I designed Power BI–ready SQL summary tables to support risk monitoring, spending analysis, and fraud detection, enabling fast and scalable dashboarding.


---- POWER BI PRESENATATION

--- Risk Distribution

WITH risk_table AS (
    SELECT 
        id AS client_id,
        yearly_income,
        total_debt,
        credit_score,
        CASE
            WHEN (total_debt * 1.0 / NULLIF(yearly_income,0) > 0.5 OR credit_score < 600)
                THEN 'High Risk'
            WHEN (total_debt * 1.0 / NULLIF(yearly_income,0) BETWEEN 0.3 AND 0.5
                  OR credit_score BETWEEN 600 AND 700)
                THEN 'Medium Risk'
            ELSE 'Low Risk'
        END AS risk_segment
    FROM users_data
)

SELECT
    risk_segment,
    COUNT(*) AS customer_count
FROM risk_table
GROUP BY risk_segment;



---Avg Income vs Debt by Risk

WITH risk_table AS (
    SELECT 
        id AS client_id,
        yearly_income,
        total_debt,
        credit_score,
        (total_debt * 1.0 / NULLIF(yearly_income,0)) AS debt_to_income,
        CASE
            WHEN (total_debt * 1.0 / NULLIF(yearly_income,0) > 0.5 OR credit_score < 600)
                THEN 'High Risk'
            WHEN (total_debt * 1.0 / NULLIF(yearly_income,0) BETWEEN 0.3 AND 0.5
                  OR credit_score BETWEEN 600 AND 700)
                THEN 'Medium Risk'
            ELSE 'Low Risk'
        END AS risk_segment
    FROM users_data
)

SELECT
    risk_segment,
    ROUND(AVG(yearly_income),2) AS avg_income,
    ROUND(AVG(total_debt),2) AS avg_debt,
    ROUND(AVG(debt_to_income),2) AS avg_dti
FROM risk_table
GROUP BY risk_segment
ORDER BY avg_dti DESC;



---Score Buckets for credit score distribution

SELECT
    CASE
        WHEN credit_score < 500 THEN 'Very Poor (<500)'
        WHEN credit_score BETWEEN 500 AND 599 THEN 'Poor (500-599)'
        WHEN credit_score BETWEEN 600 AND 699 THEN 'Fair (600-699)'
        WHEN credit_score BETWEEN 700 AND 749 THEN 'Good (700-749)'
        ELSE 'Excellent (750+)'
    END AS credit_score_band,
    COUNT(*) AS customer_count
FROM users_data
GROUP BY
    CASE
        WHEN credit_score < 500 THEN 'Very Poor (<500)'
        WHEN credit_score BETWEEN 500 AND 599 THEN 'Poor (500-599)'
        WHEN credit_score BETWEEN 600 AND 699 THEN 'Fair (600-699)'
        WHEN credit_score BETWEEN 700 AND 749 THEN 'Good (700-749)'
        ELSE 'Excellent (750+)'
    END
ORDER BY customer_count DESC;



---- Average Transaction Value

SELECT
    ROUND(AVG(amount), 2) AS avg_transaction_value
FROM transactions_data;

