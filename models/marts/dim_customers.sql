-- One row per real person (customer_unique_id). Canceled and unavailable
-- orders don't count toward spend or order count.
with valid_orders as (
    select *
    from {{ ref('fct_orders') }}
    where order_status not in ('canceled', 'unavailable')
),

first_order as (
    select customer_unique_id, customer_state, purchased_at, order_month
    from {{ ref('fct_orders') }}
    where customer_order_number = 1
)

select
    f.customer_unique_id,
    f.customer_state,
    f.purchased_at                 as first_order_at,
    f.order_month                  as cohort_month,
    count(v.order_id)              as order_count,
    coalesce(sum(v.item_revenue), 0) as lifetime_revenue,
    max(v.purchased_at)            as last_order_at,
    count(v.order_id) > 1          as is_repeat_customer
from first_order       as f
left join valid_orders as v on f.customer_unique_id = v.customer_unique_id
group by all
