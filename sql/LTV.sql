WITH first_order AS (
SELECT
customer_unique_id,
MIN(DATE_TRUNC('month', order_purchase_timestamp::timestamp)) AS cohort_month
FROM olist_orders AS o
JOIN olist_customers AS c USING(customer_id)
GROUP BY customer_unique_id
),
payments AS(
SELECT
customer_unique_id,
DATE_TRUNC('month', order_purchase_timestamp::timestamp) AS order_month,
SUM(payment_value) AS revenue
FROM olist_orders AS o
JOIN olist_customers AS c USING(customer_id)
JOIN olist_order_payments AS p USING(order_id)
GROUP BY customer_unique_id, order_month
),
cohort_size AS (
SELECT
cohort_month,
COUNT(customer_unique_id) AS total_customers
FROM first_order
GROUP BY cohort_month
)
SELECT
f.cohort_month,
(EXTRACT(YEAR FROM order_month) - EXTRACT(YEAR FROM cohort_month)) * 12 +
(EXTRACT(MONTH FROM order_month) - EXTRACT(MONTH FROM cohort_month)) AS period_number,
SUM(SUM(revenue)) OVER(
PARTITION BY f.cohort_month
ORDER BY (EXTRACT(YEAR FROM order_month) - EXTRACT(YEAR FROM cohort_month)) * 12 +
(EXTRACT(MONTH FROM order_month) - EXTRACT(MONTH FROM cohort_month))
) / total_customers AS cumulative_ltv
FROM first_order AS f
JOIN payments AS p USING(customer_unique_id)
JOIN cohort_size AS s USING(cohort_month)
GROUP BY f.cohort_month, period_number, total_customers
ORDER BY f.cohort_month, period_number