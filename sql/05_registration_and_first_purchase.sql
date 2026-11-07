-- =========================================================
-- Q5: Customer Registration Trend & Avg. Time-to-First-Purchase
-- Business question: "How long does it take a new customer to make
-- their first purchase, and is registration volume growing?"
-- (Customer/CRM team)
-- =========================================================

-- 5a. Monthly registration trend (all years)
SELECT
    DATE_TRUNC('month', registration_date::timestamp) AS reg_month,
    COUNT(*) AS new_registrations
FROM customer_detail
GROUP BY DATE_TRUNC('month', registration_date::timestamp)
ORDER BY reg_month;

-- 5b. Average days between registration and first purchase
WITH first_purchase AS (
    SELECT
        customer_id,
        MIN(order_date) AS first_purchase_date
    FROM order_detail
    WHERE is_valid = 1
    GROUP BY customer_id
)
SELECT
    ROUND(AVG(fp.first_purchase_date::DATE - c.registration_date::DATE)::numeric, 1) AS avg_days_to_first_purchase,
    COUNT(*) AS customers_with_purchase,
    (SELECT COUNT(*) FROM customer_detail) AS total_registered_customers,
    ROUND(
        (100.0 * COUNT(*) / NULLIF((SELECT COUNT(*) FROM customer_detail), 0))::numeric
    , 2) AS pct_registered_who_purchased
FROM first_purchase fp
JOIN customer_detail c ON fp.customer_id = c.customer_id;
