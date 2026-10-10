{{ config(materialized='table', schema='mart') }}

-- Fixed list of source status codes and the revenue definitions that depend on them:
--   booked    = every status except Rejected (headline revenue)
--   completed = Completed only
SELECT *
FROM (
    VALUES
        (1::SMALLINT, 'Pending',    1, TRUE,  FALSE),
        (2::SMALLINT, 'Processing', 2, TRUE,  FALSE),
        (3::SMALLINT, 'Rejected',   4, FALSE, FALSE),
        (4::SMALLINT, 'Completed',  3, TRUE,  TRUE)
) AS s (order_status_code, order_status, sort_order, is_booked, is_completed)
