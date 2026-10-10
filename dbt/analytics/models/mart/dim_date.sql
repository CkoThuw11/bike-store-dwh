{{ config(materialized='table', schema='mart') }}

-- Calendar covering every order, required and shipped date (whole years).
WITH order_dates AS (
    SELECT
        MIN(order_date)                                         AS first_date,
        MAX(GREATEST(order_date, required_date, shipped_date))  AS last_date
    FROM {{ ref('stg_orders') }}
),

bounds AS (
    SELECT
        DATE_TRUNC('year', first_date)::DATE                               AS start_date,
        (DATE_TRUNC('year', last_date) + INTERVAL '1 year - 1 day')::DATE  AS end_date
    FROM order_dates
),

days AS (
    SELECT GENERATE_SERIES(start_date, end_date, INTERVAL '1 day')::DATE  AS date_day
    FROM bounds
)

SELECT
    date_day,
    EXTRACT(YEAR FROM date_day)::INTEGER     AS year,
    EXTRACT(QUARTER FROM date_day)::INTEGER  AS quarter,
    EXTRACT(MONTH FROM date_day)::INTEGER    AS month,
    TO_CHAR(date_day, 'FMMonth')             AS month_name,
    DATE_TRUNC('month', date_day)::DATE      AS month_start,
    DATE_TRUNC('week', date_day)::DATE       AS week_start,
    EXTRACT(ISODOW FROM date_day)::INTEGER   AS day_of_week,
    TO_CHAR(date_day, 'FMDay')               AS day_name,
    EXTRACT(ISODOW FROM date_day) IN (6, 7)  AS is_weekend
FROM days
