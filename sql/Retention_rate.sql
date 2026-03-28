WITH first_order AS (
SELECT
customer_unique_id,
MIN(DATE_TRUNC('month', order_purchase_timestamp::timestamp)) AS cohort_month
FROM olist_orders AS o
JOIN olist_customers AS c USING(customer_id)
GROUP BY customer_unique_id
),
all_orders AS (
SELECT
customer_unique_id,
DATE_TRUNC('month', order_purchase_timestamp::timestamp) AS order_month
FROM olist_orders AS o
JOIN olist_customers AS c USING(customer_id)
),
retention_raw as(
SELECT
cohort_month,
(EXTRACT(YEAR FROM order_month) - EXTRACT(YEAR FROM cohort_month)) * 12 +
(EXTRACT(MONTH FROM order_month) - EXTRACT(MONTH FROM cohort_month)) AS period_number,
COUNT(DISTINCT a.customer_unique_id) AS active_users
FROM all_orders AS a
JOIN first_order AS f USING(customer_unique_id)
GROUP BY cohort_month, period_number
),
cohort_size AS (
SELECT
cohort_month,
COUNT(customer_unique_id) AS total_customers
FROM first_order
GROUP BY cohort_month
)
SELECT
r.cohort_month,
period_number,
active_users,
total_customers,
round(active_users::numeric / total_customers * 100, 2) AS retention_rate
FROM  retention_raw AS r
join cohort_size AS c using(cohort_month)
ORDER BY r.cohort_month, period_number
