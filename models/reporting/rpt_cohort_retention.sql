-- Q2. Of the customers who first bought in a given month (a "cohort"),
--     what share came back to buy again 1, 2, 3... months later?
-- SQL shown: CTEs, MIN() to find a first date, DATE_DIFF, joining
-- aggregates back together.

with valid_orders as (
    select customer_unique_id, order_month
    from {{ ref('fct_orders') }}
    where order_status not in ('canceled', 'unavailable')
),

first_month as (
    -- each customer's cohort = the month of their first valid order
    select customer_unique_id, min(order_month) as cohort_month
    from valid_orders
    group by customer_unique_id
),

cohort_size as (
    select cohort_month, count(*) as cohort_customers
    from first_month
    group by cohort_month
),

activity as (
    -- how many of each cohort ordered in each later month
    select
        f.cohort_month,
        date_diff('month', f.cohort_month, v.order_month) as months_since_first,
        count(distinct v.customer_unique_id)              as active_customers
    from valid_orders as v
    join first_month  as f on v.customer_unique_id = f.customer_unique_id
    group by f.cohort_month, months_since_first
)

select
    a.cohort_month,
    s.cohort_customers,
    a.months_since_first,
    a.active_customers,
    round(100.0 * a.active_customers / s.cohort_customers, 2) as retention_pct
from activity    as a
join cohort_size as s on a.cohort_month = s.cohort_month
order by a.cohort_month, a.months_since_first
