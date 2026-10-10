{{ config(materialized='view', schema='staging') }}

SELECT
    product_id::INTEGER             AS product_id,
    NULLIF(TRIM(product_name), '')  AS product_name,
    brand_id::INTEGER               AS brand_id,
    category_id::INTEGER            AS category_id,
    model_year::SMALLINT            AS model_year,
    list_price::NUMERIC(10, 2)      AS list_price,
    _sdc_extracted_at               AS extracted_at
FROM {{ source('raw', 'products') }}
