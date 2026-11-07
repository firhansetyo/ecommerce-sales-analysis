-- =========================================================
-- Q4: Funnel Conversion Rate per Channel (Organic, 2024)
-- Business question: "Which channel converts traffic into purchases
-- most effectively?" (Growth / Marketing team)
-- =========================================================

WITH funnel_2024_organic AS (
    SELECT *
    FROM funnel_detail
    WHERE event = 'Organic'
      AND EXTRACT(YEAR FROM funnel_date::timestamp) = 2024
)
SELECT
    channel_source,
    COUNT(*) AS total_funnel_events,
    COUNT(*) FILTER (WHERE status = 'Viewed')      AS viewed_count,
    COUNT(*) FILTER (WHERE status = 'Click')        AS click_count,
    COUNT(*) FILTER (WHERE status = 'Add to Cart')   AS add_to_cart_count,
    COUNT(*) FILTER (WHERE status = 'Purchase')      AS purchase_count,
    ROUND(
        (100.0 * COUNT(*) FILTER (WHERE status = 'Purchase')
        / NULLIF(COUNT(*) FILTER (WHERE status = 'Viewed'), 0))::numeric
    , 2) AS conversion_rate_pct
FROM funnel_2024_organic
GROUP BY channel_source
ORDER BY total_funnel_events DESC;

-- Interpretation note: highest-traffic channel (likely Website, by
-- 'Viewed' event count) is compared against its own conversion rate
-- to check the "high traffic, low conversion" pattern mentioned in
-- the original capstone slide.
