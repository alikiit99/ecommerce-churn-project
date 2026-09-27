 -- total number of customers
SELECT COUNT(customer_id) AS number_of_customers 
FROM customers;


-- count customers by gender
SELECT gender, COUNT(customer_id) AS customer_count
FROM customers
GROUP BY gender;


-- count customers by subscription
SELECT subscription_type, COUNT(subscription_type) AS customer_subscription 
FROM customers 
WHERE subscription_type IS NOT NULL
GROUP BY subscription_type;


-- count the total churn customer 
SELECT
 churn, 
 COUNT(customer_id) AS customer_count 
 FROM customers 
 WHERE churn IS NOT NULL
 GROUP BY churn;

