-- Q9. When customers do come back, how long do they take?
--     (Tells marketing when a "come back" offer should go out.)
-- SQL shown: LAG() OVER (PARTITION BY ...) to compare each order with
-- the same customer's previous one.

with valid_orders as (
    select customer_unique_id, purchased_at
    from {{ ref('fct_orders') }}
    where order_status not in ('canceled', 'unavailable')
),

gaps as (
    select
        customer_unique_id,
        date_diff('day',
                  lag(purchased_at) over (partition by customer_unique_id
                                          order by purchased_at),
                  purchased_at) as days_since_previous
    from valid_orders
),

bucketed as (
    select
        case
            when days_since_previous = 0   then '1. Same day'
            when days_since_previous <= 30  then '2. 1-30 days'
            when days_since_previous <= 90  then '3. 31-90 days'
            when days_since_previous <= 180 then '4. 91-180 days'
            else                                 '5. 181+ days'
        end as time_to_next_order
    from gaps
    where days_since_previous is not null   -- first orders have no "previous"
)

select
    time_to_next_order,
    count(*)                                           as repeat_orders,
    round(100.0 * count(*) / sum(count(*)) over (), 1) as share_pct
from bucketed
group by time_to_next_order
order by time_to_next_order
