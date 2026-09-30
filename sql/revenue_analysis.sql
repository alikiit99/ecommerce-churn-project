-- Estimate total spend associated with churned customers
SELECT
    SUM(total_spend) AS churned_customer_spend,
    ROUND(
        100.0 * SUM(CASE WHEN churn = 1 THEN total_spend ELSE 0 END)
        / SUM(total_spend),
        2
    ) AS percentage_spend_from_churned_customers
FROM customers;


--Revenue lost because of churn 

SELECT
    SUM(CASE
        WHEN churn = 1 THEN total_spend
        ELSE 0
    END) AS revenue_lost
FROM customers;

-- Compare monthly, quarterly, and annual contracts
SELECT
    contract_length,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS churn_rate
FROM customers    
WHERE contract_length IS NOT NULL
GROUP BY contract_length
ORDER BY churn_rate DESC;

-- Revenue comparison between churned and retained customers
SELECT
    churn,
    COUNT(*) AS customer_count,
    ROUND(SUM(total_spend), 2) AS total_revenue,
    ROUND(AVG(total_spend), 2) AS average_revenue_per_customer,
    ROUND(MIN(total_spend), 2) AS minimum_revenue,
    ROUND(MAX(total_spend), 2) AS maximum_revenue

FROM customers
WHERE churn IS NOT NULL
GROUP BY churn
ORDER BY churn;


-- Revenue by subscription type
SELECT
    subscription_type,
    COUNT(*) AS total_customers,

    ROUND(SUM(total_spend), 2) AS total_revenue,

    ROUND(AVG(total_spend), 2) AS average_revenue_per_customer,

    SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) AS churned_customers,

    ROUND(
        100.0 *
        SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS churn_rate

FROM customers
WHERE subscription_type IS NOT NULL
GROUP BY subscription_type
ORDER BY total_revenue DESC;



-- Revenue and churn by contract length
SELECT
    contract_length,
    COUNT(*) AS total_customers,

    ROUND(SUM(total_spend), 2) AS total_revenue,

    ROUND(AVG(total_spend), 2) AS average_revenue_per_customer,

    SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) AS churned_customers,

    ROUND(
        100.0 *
        SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS churn_rate

FROM customers
WHERE contract_length IS NOT NULL
GROUP BY contract_length
ORDER BY total_revenue DESC;

-- Top 20 highest-value customers
SELECT
    customer_id,
    subscription_type,
    contract_length,
    tenure,
    total_spend,
    churn,

    CASE
        WHEN churn = 1 THEN 'Churned'
        ELSE 'Retained'
    END AS customer_status

FROM customers

WHERE total_spend IS NOT NULL

ORDER BY total_spend DESC

LIMIT 20;


-- Revenue at risk by customer risk level

WITH customer_risk AS (
    SELECT
        customer_id,
        total_spend,
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
)

SELECT
    risk_level,

    COUNT(*) AS total_customers,

    ROUND(SUM(total_spend), 2) AS total_revenue,

    ROUND(AVG(total_spend), 2) AS average_revenue_per_customer,

    SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) AS churned_customers,

    ROUND(
        SUM(
            CASE
                WHEN churn = 1 THEN total_spend
                ELSE 0
            END
        ),
        2
    ) AS revenue_at_risk,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN churn = 1 THEN total_spend
                ELSE 0
            END
        )
        / NULLIF(SUM(total_spend), 0),
        2
    ) AS revenue_risk_percentage

FROM customer_risk

GROUP BY risk_level

ORDER BY revenue_at_risk DESC;


-- Revenue and churn by contract length
SELECT
    contract_length,
    COUNT(*) AS total_customers,

    ROUND(SUM(total_spend), 2) AS total_revenue,

    ROUND(AVG(total_spend), 2) AS average_revenue_per_customer,

    SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) AS churned_customers,

    ROUND(
        100.0 *
        SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS churn_rate

FROM customers
WHERE contract_length IS NOT NULL
GROUP BY contract_length
ORDER BY total_revenue DESC;

-- Revenue analysis by tenure group
SELECT
    CASE
        WHEN tenure < 6 THEN '0-5 months'
        WHEN tenure < 12 THEN '6-11 months'
        WHEN tenure < 24 THEN '1-2 years'
        ELSE '2+ years'
    END AS tenure_group,

    COUNT(*) AS total_customers,

    ROUND(SUM(total_spend), 2) AS total_revenue,

    ROUND(AVG(total_spend), 2) AS average_revenue_per_customer,

    SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) AS churned_customers,

    ROUND(
        100.0 *
        SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END)
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

ORDER BY total_revenue DESC;


-- High-value customers who may be at risk of churn

WITH customer_risk AS (
    SELECT
        customer_id,
        subscription_type,
        contract_length,
        tenure,
        total_spend,
        churn,
        support_calls,
        payment_delay,
        usage_frequency,

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
)

SELECT
    customer_id,
    subscription_type,
    contract_length,
    tenure,
    total_spend,
    support_calls,
    payment_delay,
    usage_frequency,
    risk_level,
    churn

FROM customer_risk

WHERE risk_level IN ('High Risk', 'Medium Risk')
  AND churn = 0

ORDER BY total_spend DESC;


-- Revenue and churn by gender
SELECT
    gender,

    COUNT(*) AS total_customers,

    ROUND(SUM(total_spend), 2) AS total_revenue,

    ROUND(AVG(total_spend), 2) AS average_revenue_per_customer,

    SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) AS churned_customers,

    ROUND(
        100.0 *
        SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS churn_rate,

    ROUND(
        SUM(
            CASE
                WHEN churn = 1 THEN total_spend
                ELSE 0
            END
        ),
        2
    ) AS churned_revenue

FROM customers

WHERE gender IS NOT NULL

GROUP BY gender

ORDER BY total_revenue DESC;


-- Revenue contribution by subscription type

WITH subscription_revenue AS (
    SELECT
        subscription_type,
        SUM(total_spend) AS total_revenue
    FROM customers
    WHERE subscription_type IS NOT NULL
    GROUP BY subscription_type
)

SELECT
    subscription_type,

    ROUND(total_revenue, 2) AS total_revenue,

    ROUND(
        100.0 * total_revenue
        / SUM(total_revenue) OVER (),
        2
    ) AS revenue_contribution_percentage

FROM subscription_revenue

ORDER BY total_revenue DESC;
