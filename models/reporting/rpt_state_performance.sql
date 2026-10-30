-- Q6. Which states bring the most revenue, and where is delivery worst?
-- SQL shown: GROUP BY with several metrics, RANK() window function.

with by_state as (
    select
        customer_state,
        count(*)                       as orders,
        sum(item_revenue)              as revenue,
        round(avg(days_to_deliver), 1) as avg_days_to_deliver,
        round(100.0 * avg(case when is_late then 1 else 0 end), 1) as late_pct,
        round(avg(review_score), 2)    as avg_review_score
    from {{ ref('fct_orders') }}
    where order_status not in ('canceled', 'unavailable')
    group by customer_state
)

select
    rank() over (order by revenue desc)                    as revenue_rank,
    customer_state,
    orders,
    revenue,
    round(100.0 * revenue / sum(revenue) over (), 1)       as revenue_share_pct,
    avg_days_to_deliver,
    late_pct,
    avg_review_score
from by_state
order by revenue_rank
