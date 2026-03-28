WITH monthly_sales AS (
    SELECT 
        date_trunc('month', order_purchase_timestamp::timestamp) AS month,
        ROUND(SUM(payment_value)::numeric, 2) AS revenue
    FROM olist_orders o
    JOIN olist_order_payments p ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY month
)
SELECT 
    month,
    revenue AS current_month_revenue,
    LAG(revenue) OVER (ORDER BY month) AS previous_month_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY month)) / 
        LAG(revenue) OVER (ORDER BY month) * 100, 2
    ) AS mom_growth_pct
FROM monthly_sales
ORDER BY month

