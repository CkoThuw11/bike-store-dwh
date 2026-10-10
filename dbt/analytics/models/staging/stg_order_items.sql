{{ config(materialized='view', schema='staging') }}

SELECT
    order_id::INTEGER           AS order_id,
    item_id::INTEGER            AS item_id,
    product_id::INTEGER         AS product_id,
    quantity::INTEGER           AS quantity,
    list_price::NUMERIC(10, 2)  AS list_price,
    discount::NUMERIC(4, 2)     AS discount,
    _sdc_extracted_at           AS extracted_at
FROM {{ source('raw', 'order_items') }}
