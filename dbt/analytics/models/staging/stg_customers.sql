{{ config(materialized='view', schema='staging') }}

SELECT
    customer_id::INTEGER                               AS customer_id,
    NULLIF(TRIM(first_name), '')                       AS first_name,
    NULLIF(TRIM(last_name), '')                        AS last_name,
    CONCAT_WS(' ', TRIM(first_name), TRIM(last_name))  AS full_name,
    NULLIF(TRIM(phone), '')                            AS phone,
    LOWER(NULLIF(TRIM(email), ''))                     AS email,
    NULLIF(TRIM(street), '')                           AS street,
    NULLIF(TRIM(city), '')                             AS city,
    UPPER(NULLIF(TRIM(state), ''))                     AS state,
    NULLIF(TRIM(zip_code), '')                         AS zip_code,
    _sdc_extracted_at                                  AS extracted_at
FROM {{ source('raw', 'customers') }}
