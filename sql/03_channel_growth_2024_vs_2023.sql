-- =========================================================
-- Q3: Channel Growth 2024 vs 2023
-- Business question: "Which sales channel grew the most in 2024
-- compared to 2023?" (Marketing Manager)
-- =========================================================

WITH channel_yearly AS (
    SELECT
        channel_type,
        EXTRACT(YEAR FROM order_date)::INT AS order_year,
        COUNT(DISTINCT order_id) AS total_orders,
        SUM(after_discount) AS total_sales_value
    FROM order_detail
    WHERE is_valid = 1
      AND EXTRACT(YEAR FROM order_date) IN (2023, 2024)
    GROUP BY channel_type, EXTRACT(YEAR FROM order_date)
)
SELECT
    channel_type,
    MAX(CASE WHEN order_year = 2023 THEN total_sales_value END) AS sales_2023,
    MAX(CASE WHEN order_year = 2024 THEN total_sales_value END) AS sales_2024,
    ROUND(
        (100.0 * (MAX(CASE WHEN order_year = 2024 THEN total_sales_value END)
                  - MAX(CASE WHEN order_year = 2023 THEN total_sales_value END))
        / NULLIF(MAX(CASE WHEN order_year = 2023 THEN total_sales_value END), 0))::numeric
    , 2) AS yoy_growth_pct
FROM channel_yearly
GROUP BY channel_type
ORDER BY yoy_growth_pct DESC;

-- Follow-up: new customer count by registration_channel in 2024,
-- to identify which channel acquires the most NEW customers
-- (distinct from which channel sells the most).
SELECT
    registration_channel,
    COUNT(DISTINCT customer_id) AS new_customers_2024
FROM customer_detail
WHERE EXTRACT(YEAR FROM registration_date::date) = 2024
GROUP BY registration_channel
ORDER BY new_customers_2024 DESC;
