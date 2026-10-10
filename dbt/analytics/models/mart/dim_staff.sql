{{ config(materialized='table', schema='mart') }}

SELECT
    s.staff_id,
    s.full_name,
    s.email,
    s.phone,
    s.is_active,
    s.store_id,
    st.store_name,
    s.manager_id,
    m.full_name  AS manager_name
FROM {{ ref('stg_staffs') }} s
LEFT JOIN {{ ref('stg_staffs') }} m ON m.staff_id = s.manager_id
LEFT JOIN {{ ref('stg_stores') }} st ON st.store_id = s.store_id
