{{ config(materialized='view', schema='staging') }}

SELECT
    category_id::INTEGER             AS category_id,
    NULLIF(TRIM(category_name), '')  AS category_name,
    _sdc_extracted_at                AS extracted_at
FROM {{ source('raw', 'categories') }}
