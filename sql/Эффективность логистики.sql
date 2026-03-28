SELECT 
    c.customer_state,
    ROUND(AVG(
        EXTRACT(DAY FROM (o.order_delivered_customer_date::timestamp - o.order_estimated_delivery_date::timestamp))
    )::numeric, 2) AS avg_delay_days
FROM olist_orders o
JOIN olist_customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered' 
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY avg_delay_days DESC
