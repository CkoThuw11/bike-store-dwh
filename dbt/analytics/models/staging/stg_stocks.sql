{{ config(materialized='view', schema='staging') }}

SELECT
    store_id::INTEGER    AS store_id,
    product_id::INTEGER  AS product_id,
    quantity::INTEGER    AS quantity,
    _sdc_extracted_at    AS extracted_at
FROM {{ source('raw', 'stocks') }}
