-- Q1. How are orders, customers and revenue trending month to month?
-- SQL shown: GROUP BY, COUNT(DISTINCT), LAG() window function, NULLIF.
-- "Valid" orders exclude canceled and unavailable ones throughout.

with monthly as (
    select
        order_month,
        -- Olist's export is thin before Jan 2017 and after Aug 2018
        order_month between date '2017-01-01' and date '2018-08-01'
                                            as is_complete_month,
        count(*)                            as orders,
        count(distinct customer_unique_id)  as customers,
        sum(item_revenue)                   as revenue
    from {{ ref('fct_orders') }}
    where order_status not in ('canceled', 'unavailable')
    group by order_month, is_complete_month
),

with_previous as (
    select
        *,
        -- LAG looks one row back: last month's revenue, in date order
        lag(revenue) over (order by order_month) as prev_month_revenue,
        lag(is_complete_month) over (order by order_month) as prev_month_complete
    from monthly
)

select
    order_month,
    orders,
    customers,
    revenue,
    round(revenue / orders, 2)                       as avg_order_value,
    prev_month_revenue,
    -- growth only means something when both months are complete;
    -- NULLIF avoids dividing by zero (gives NULL instead of an error)
    case when is_complete_month and prev_month_complete then
        round(100.0 * (revenue - prev_month_revenue)
              / nullif(prev_month_revenue, 0), 1)
    end                                              as revenue_mom_pct,
    is_complete_month
from with_previous
order by order_month
