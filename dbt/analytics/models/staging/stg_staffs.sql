{{ config(materialized='view', schema='staging') }}

SELECT
    staff_id::INTEGER                                  AS staff_id,
    NULLIF(TRIM(first_name), '')                       AS first_name,
    NULLIF(TRIM(last_name), '')                        AS last_name,
    CONCAT_WS(' ', TRIM(first_name), TRIM(last_name))  AS full_name,
    LOWER(NULLIF(TRIM(email), ''))                     AS email,
    NULLIF(TRIM(phone), '')                            AS phone,
    active = 1                                         AS is_active,
    store_id::INTEGER                                  AS store_id,
    manager_id::INTEGER                                AS manager_id,
    _sdc_extracted_at                                  AS extracted_at
FROM {{ source('raw', 'staffs') }}
