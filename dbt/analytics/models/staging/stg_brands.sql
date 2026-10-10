{{ config(materialized='view', schema='staging') }}

SELECT
    brand_id::INTEGER             AS brand_id,
    NULLIF(TRIM(brand_name), '')  AS brand_name,
    _sdc_extracted_at             AS extracted_at
FROM {{ source('raw', 'brands') }}
