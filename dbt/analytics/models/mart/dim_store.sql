{{ config(materialized='table', schema='mart') }}

SELECT
    store_id,
    store_name,
    phone,
    email,
    street,
    city,
    state,
    zip_code
FROM {{ ref('stg_stores') }}
