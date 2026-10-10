-- =====================================================================================
-- Bike Store - Sales Overview: one plain SQL question per block (no filter variables).
--
-- For each block: + New -> SQL query -> database "Bike Store DWH" -> paste ONE block -> Run
--                 -> Visualization (type in the block header) -> Save to collection "Bike Store"
--                 -> add the saved question to the dashboard "Bike Store - Sales Overview".
--
-- Revenue definitions (computed in dbt, mart.fct_order_items):
--   booked_revenue    = net revenue of every order except Rejected   (headline KPI)
--   completed_revenue = net revenue of Completed orders only (status may lag up to 7 days)
-- Trend cards stop at April 2018: the sample data effectively ends there.
-- =====================================================================================


-- 1. Booked revenue  |  Visualization: Number (format: currency)
SELECT sum(booked_revenue) AS booked_revenue
FROM mart.fct_order_items;


-- 2. Completed revenue  |  Visualization: Number (format: currency)
SELECT sum(completed_revenue) AS completed_revenue
FROM mart.fct_order_items;


-- 3. Booked orders  |  Visualization: Number
SELECT count(DISTINCT order_id) AS booked_orders
FROM mart.fct_order_items
WHERE is_booked;


-- 4. Revenue trend by month  |  Visualization: Line (X = month, Y = booked_revenue, completed_revenue)
SELECT dim_date.month_start                    AS month,
       sum(fct_order_items.booked_revenue)     AS booked_revenue,
       sum(fct_order_items.completed_revenue)  AS completed_revenue
FROM mart.fct_order_items
JOIN mart.dim_date ON dim_date.date_day = fct_order_items.order_date
WHERE fct_order_items.order_date < DATE '2018-05-01'
GROUP BY 1
ORDER BY 1;


-- 5. Orders by status per month  |  Visualization: Bar, stacked (X = month, series = order_status, Y = orders)
SELECT dim_date.month_start                     AS month,
       fct_order_items.order_status             AS order_status,
       count(DISTINCT fct_order_items.order_id) AS orders
FROM mart.fct_order_items
JOIN mart.dim_date ON dim_date.date_day = fct_order_items.order_date
WHERE fct_order_items.order_date < DATE '2018-05-01'
GROUP BY 1, 2
ORDER BY 1, 2;


-- 6. Booked revenue by category  |  Visualization: Row
SELECT dim_product.category_name            AS category,
       sum(fct_order_items.booked_revenue)  AS booked_revenue
FROM mart.fct_order_items
JOIN mart.dim_product ON dim_product.product_id = fct_order_items.product_id
GROUP BY 1
ORDER BY 2 DESC;
