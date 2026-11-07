-- =========================================================
-- VIEW: dashboard_sales_detail
-- Purpose: A denormalized "mart layer" view joining order, product,
-- transaction, and payment data — built so a BI tool (Looker Studio)
-- can consume a single flat table instead of joining 4 raw tables
-- on every query.
--
-- This mirrors a common real-world pattern: raw/OLTP tables stay
-- normalized (separate), while a transformation layer (here: a SQL
-- VIEW; in production this might be a dbt model or warehouse table)
-- prepares a "ready-to-visualize" table for downstream BI tools.
-- =========================================================

CREATE OR REPLACE VIEW dashboard_sales_detail AS
SELECT
    o.order_id,
    o.order_date,
    o.channel_type AS channel,
    p.category,
    pm.payment_method AS payment_method_label,
    o.quantity,
    o.before_discount AS gross_sales,
    o.discount_item AS discount,
    o.after_discount AS net_sales,
    p.cogs AS cogs_per_unit,
    (o.after_discount - (p.cogs * o.quantity)) AS profit_proxy,
    EXTRACT(YEAR FROM o.order_date::timestamp)::INT AS order_year,
    TO_CHAR(o.order_date::timestamp, 'YYYY-MM') AS order_month
FROM order_detail o
JOIN product_detail p
    ON o.sku_id = p.sku_id
JOIN transaction_detail t
    ON o.transaction_id = t.transaction_id
JOIN payment_detail pm
    ON t.payment_method = pm.id
WHERE o.is_valid = 1;

-- =========================================================
-- Sanity check: row count and total net sales should match
-- the equivalent Python-built dashboard_data.csv
-- (expected: 21,703 rows, ~Rp 89.4 billion total net sales,
-- ~23.45% overall margin)
-- =========================================================
SELECT
    COUNT(*) AS total_rows,
    SUM(net_sales) AS total_net_sales,
    SUM(profit_proxy) AS total_profit,
    ROUND((SUM(profit_proxy) / NULLIF(SUM(net_sales), 0))::numeric * 100, 2) AS overall_margin_pct
FROM dashboard_sales_detail;

-- =========================================================
-- To export for Looker Studio: run the query below, then use
-- Supabase SQL Editor's "Export" button (top right of results)
-- to download as CSV.
-- =========================================================
SELECT * FROM dashboard_sales_detail;

-- =========================================================
-- Security hardening (applied after Supabase flagged the objects
-- as UNRESTRICTED / Security Definer)
-- - Enable Row Level Security on all raw tables (no policies = the
--   public REST API cannot read them; SQL Editor via postgres role
--   is unaffected)
-- - Make the view run with the caller's permissions (security invoker)
-- - Revoke public API access to the view
-- =========================================================
ALTER TABLE customer_detail    ENABLE ROW LEVEL SECURITY;
ALTER TABLE funnel_detail      ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_detail       ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_detail     ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_detail     ENABLE ROW LEVEL SECURITY;
ALTER TABLE transaction_detail ENABLE ROW LEVEL SECURITY;

ALTER VIEW dashboard_sales_detail SET (security_invoker = true);
REVOKE ALL ON dashboard_sales_detail FROM anon, authenticated;
