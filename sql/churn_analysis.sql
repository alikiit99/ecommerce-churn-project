-- Check the churn distribution
SELECT
    churn,
    COUNT(*) AS customer_count
FROM customers
WHERE churn IS NOT NULL
GROUP BY churn
ORDER BY churn;


--Calculate total customers, churned customers, retained customers, and churn rate
SELECT
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) AS churned_customers,
    SUM(CASE WHEN churn = 0 THEN 1 ELSE 0 END) AS retained_customers,
    ROUND(
        100.0 * SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS churn_rate
FROM customers;


-- Analyze churn rate by gender
SELECT
    gender,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS churn_rate
FROM customers
WHERE gender IS NOT NULL
GROUP BY gender
ORDER BY churn_rate DESC;


-- Compare churn across subscription types
SELECT
    subscription_type,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS churn_rate
FROM customers
WHERE subscription_type IS NOT NULL
GROUP BY subscription_type
ORDER BY churn_rate DESC;


-- Compare average customer behavior by churn status
SELECT
    churn,
    COUNT(*) AS customer_count,
    ROUND(AVG(age), 2) AS avg_age,
    ROUND(AVG(tenure), 2) AS avg_tenure,
    ROUND(AVG(usage_frequency), 2) AS avg_usage_frequency,
    ROUND(AVG(support_calls), 2) AS avg_support_calls,
    ROUND(AVG(payment_delay), 2) AS avg_payment_delay,
    ROUND(AVG(total_spend), 2) AS avg_total_spend,
    ROUND(AVG(last_interaction), 2) AS avg_last_interaction
FROM customers
WHERE churn IS NOT NULL
GROUP BY churn;


-- Find customers with frequent support interactions
SELECT
    customer_id,
    support_calls,
    churn
FROM customers
WHERE support_calls >= 7
ORDER BY support_calls DESC;


-- Find customers with significant payment delays
SELECT
    customer_id,
    payment_delay,
    churn
FROM customers
WHERE payment_delay >= 20
ORDER BY payment_delay DESC;


--Create a simple churn-risk classification
SELECT
    customer_id,
    support_calls,
    payment_delay,
    usage_frequency,
    last_interaction,
    churn,
    CASE
        WHEN support_calls >= 7
             AND payment_delay >= 20
             AND usage_frequency <= 10
            THEN 'High Risk'

        WHEN support_calls >= 5
             OR payment_delay >= 15
            THEN 'Medium Risk'

        ELSE 'Low Risk'
    END AS risk_level
FROM customers
ORDER BY
    CASE
        WHEN support_calls >= 7
             AND payment_delay >= 20
             AND usage_frequency <= 10 THEN 1
        WHEN support_calls >= 5
             OR payment_delay >= 15 THEN 2
        ELSE 3
    END;


-- Identify high-value customers who have churned

SELECT
    customer_id,
    subscription_type,
    contract_length,
    total_spend,
    churn
FROM customers
WHERE churn = 1
ORDER BY total_spend DESC
LIMIT 20;


-- Analyze churn across tenure groups
SELECT
    CASE
        WHEN tenure <= 12 THEN '0-12 Months'
        WHEN tenure <= 24 THEN '13-24 Months'
        WHEN tenure <= 48 THEN '25-48 Months'
        ELSE '49+ Months'
    END AS tenure_group,

    COUNT(*) AS total_customers,

    SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) AS churned_customers,

    ROUND(
        100.0 * SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS churn_rate

FROM customers
GROUP BY tenure_group
ORDER BY churn_rate DESC;


-- Create a customer-level risk dataset using a CTE
WITH customer_risk AS (
    SELECT
        customer_id,
        age,
        gender,
        tenure,
        usage_frequency,
        support_calls,
        payment_delay,
        subscription_type,
        contract_length,
        total_spend,
        last_interaction,
        churn,

        CASE
            WHEN support_calls >= 7
                 AND payment_delay >= 20
                 THEN 'High Risk'

            WHEN support_calls >= 5
                 OR payment_delay >= 15
                 THEN 'Medium Risk'

            ELSE 'Low Risk'
        END AS risk_level
    FROM customers
)

SELECT
    risk_level,
    COUNT(*) AS customers,
    SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS churn_rate
FROM customer_risk
GROUP BY risk_level
ORDER BY churn_rate DESC;


-- Churn by tenure
SELECT
    CASE
        WHEN tenure < 6 THEN '0-5 months'
        WHEN tenure < 12 THEN '6-11 months'
        WHEN tenure < 24 THEN '1-2 years'
        ELSE '2+ years'
    END AS tenure_group,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS churn_rate
FROM customers
GROUP BY
    CASE
        WHEN tenure < 6 THEN '0-5 months'
        WHEN tenure < 12 THEN '6-11 months'
        WHEN tenure < 24 THEN '1-2 years'
        ELSE '2+ years'
    END
ORDER BY churn_rate DESC;