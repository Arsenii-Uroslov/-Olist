SELECT
payment_type,
ROUND(AVG(payment_value)::numeric,2) AS avg_revenue
FROM olist_order_payments
GROUP BY payment_type
ORDER BY avg_revenue DESC
