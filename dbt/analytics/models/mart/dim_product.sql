{{ config(materialized='table', schema='mart') }}

SELECT
    p.product_id,
    p.product_name,
    p.brand_id,
    b.brand_name,
    p.category_id,
    c.category_name,
    p.model_year,
    p.list_price  AS catalog_list_price
FROM {{ ref('stg_products') }} p
LEFT JOIN {{ ref('stg_brands') }} b ON b.brand_id = p.brand_id
LEFT JOIN {{ ref('stg_categories') }} c ON c.category_id = p.category_id
