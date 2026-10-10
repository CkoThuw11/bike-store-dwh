{{ config(materialized='view', schema='staging') }}

SELECT
    store_id::INTEGER               AS store_id,
    NULLIF(TRIM(store_name), '')    AS store_name,
    NULLIF(TRIM(phone), '')         AS phone,
    LOWER(NULLIF(TRIM(email), ''))  AS email,
    NULLIF(TRIM(street), '')        AS street,
    NULLIF(TRIM(city), '')          AS city,
    UPPER(NULLIF(TRIM(state), ''))  AS state,
    NULLIF(TRIM(zip_code), '')      AS zip_code,
    _sdc_extracted_at               AS extracted_at
FROM {{ source('raw', 'stores') }}
