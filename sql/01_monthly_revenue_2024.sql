-- =========================================================
-- Q1: Monthly Revenue Report 2024
-- Business question: "What does our monthly revenue trend look like
-- in 2024, and which months performed best/worst?" (Board of Directors)
-- =========================================================

SELECT
    EXTRACT(MONTH FROM transaction_date)::INT AS month_number,
    TO_CHAR(transaction_date, 'Month') AS month_name,
    COUNT(DISTINCT transaction_id) AS total_transactions,
    SUM(total_paid) AS total_revenue,
    ROUND(AVG(total_paid)::numeric, 2) AS avg_order_value
FROM transaction_detail
WHERE EXTRACT(YEAR FROM transaction_date) = 2024
GROUP BY
    EXTRACT(MONTH FROM transaction_date),
    TO_CHAR(transaction_date, 'Month')
ORDER BY month_number;

-- Expected pattern (per slide context): revenue peaks in December
-- (Harbolnas 12.12 + year-end seasonality), with a trough around July.
