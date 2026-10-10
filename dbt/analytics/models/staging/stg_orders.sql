{{ config(materialized='view', schema='staging') }}

SELECT
    order_id::INTEGER       AS order_id,
    customer_id::INTEGER    AS customer_id,
    order_status::SMALLINT  AS order_status_code,
    CASE order_status
        WHEN 1 THEN 'Pending'
        WHEN 2 THEN 'Processing'
        WHEN 3 THEN 'Rejected'
        WHEN 4 THEN 'Completed'
    END                     AS order_status,
    order_date,
    required_date,
    shipped_date,
    store_id::INTEGER       AS store_id,
    staff_id::INTEGER       AS staff_id,
    _sdc_extracted_at       AS extracted_at
FROM {{ source('raw', 'orders') }}
