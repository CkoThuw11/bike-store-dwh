{{ config(materialized='table', schema='mart') }}

-- Grain: one row per order line item.
WITH lines AS (
    SELECT
        i.order_id,
        i.item_id,
        o.order_date,
        o.required_date,
        o.shipped_date,
        o.customer_id,
        o.store_id,
        o.staff_id,
        i.product_id,
        o.order_status_code,
        i.quantity,
        i.list_price,
        i.discount,
        i.quantity * i.list_price                     AS gross_amount,
        i.quantity * i.list_price * i.discount        AS discount_amount,
        i.quantity * i.list_price * (1 - i.discount)  AS net_revenue,
        o.extracted_at                                AS order_extracted_at
    FROM {{ ref('stg_order_items') }} i
    LEFT JOIN {{ ref('stg_orders') }} o ON o.order_id = i.order_id
)

SELECT
    l.order_id,
    l.item_id,
    l.order_date,
    l.required_date,
    l.shipped_date,
    l.customer_id,
    l.store_id,
    l.staff_id,
    l.product_id,
    l.order_status_code,
    s.order_status,
    s.is_booked,
    s.is_completed,
    l.quantity,
    l.list_price,
    l.discount,
    l.gross_amount,
    l.discount_amount,
    l.net_revenue,
    CASE WHEN s.is_booked THEN l.net_revenue ELSE 0 END     AS booked_revenue,
    CASE WHEN s.is_completed THEN l.net_revenue ELSE 0 END  AS completed_revenue,
    l.order_extracted_at
FROM lines l
LEFT JOIN {{ ref('dim_order_status') }} s ON s.order_status_code = l.order_status_code
