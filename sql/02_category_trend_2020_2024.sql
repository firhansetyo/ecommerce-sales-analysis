-- =========================================================
-- Q2: Category Sales Trend 2020-2024
-- Business question: "Which product categories are growing and
-- which are declining year over year?" (Warehouse Manager)
-- =========================================================

SELECT
    p.category,
    EXTRACT(YEAR FROM o.order_date)::INT AS order_year,
    SUM(o.quantity) AS total_quantity_sold,
    SUM(o.after_discount) AS total_sales_value
FROM order_detail o
JOIN product_detail p ON o.sku_id = p.sku_id
WHERE o.is_valid = 1
GROUP BY p.category, EXTRACT(YEAR FROM o.order_date)
ORDER BY p.category, order_year;

-- Follow-up: YoY % change per category (2021 -> 2024), to spot
-- biggest decline/growth categories (e.g. Food & Beverage decline,
-- Books & Stationery growth, per slide insight).
SELECT
    category,
    order_year,
    total_quantity_sold,
    LAG(total_quantity_sold) OVER (PARTITION BY category ORDER BY order_year) AS prev_year_quantity,
    ROUND(
        (100.0 * (total_quantity_sold - LAG(total_quantity_sold) OVER (PARTITION BY category ORDER BY order_year))
        / NULLIF(LAG(total_quantity_sold) OVER (PARTITION BY category ORDER BY order_year), 0))::numeric
    , 2) AS yoy_growth_pct
FROM (
    SELECT
        p.category,
        EXTRACT(YEAR FROM o.order_date)::INT AS order_year,
        SUM(o.quantity) AS total_quantity_sold
    FROM order_detail o
    JOIN product_detail p ON o.sku_id = p.sku_id
    WHERE o.is_valid = 1
    GROUP BY p.category, EXTRACT(YEAR FROM o.order_date)
) yearly
ORDER BY category, order_year;
