{{ config(materialized='table', schema='mart') }}

SELECT
    customer_id,
    full_name,
    first_name,
    last_name,
    email,
    phone,
    street,
    city,
    state,
    zip_code
FROM {{ ref('stg_customers') }}
