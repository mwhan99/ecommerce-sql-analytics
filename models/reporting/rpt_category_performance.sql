-- Q7. Which product categories drive revenue, and how concentrated is it?
-- SQL shown: joins, RANK(), running total with SUM() OVER (ORDER BY ...).

with by_category as (
    select
        i.category,
        count(*)                      as items_sold,
        sum(i.price)                  as revenue,
        round(avg(i.price), 2)        as avg_price,
        round(avg(o.review_score), 2) as avg_review_score
    from {{ ref('fct_order_items') }} as i
    join {{ ref('fct_orders') }}      as o on i.order_id = o.order_id
    where i.order_status not in ('canceled', 'unavailable')
    group by i.category
)

select
    rank() over (order by revenue desc)                         as revenue_rank,
    category,
    items_sold,
    revenue,
    avg_price,
    avg_review_score,
    round(100.0 * revenue / sum(revenue) over (), 1)            as revenue_share_pct,
    -- running total: share of revenue from this category and all above it
    round(100.0 * sum(revenue) over (order by revenue desc
                                     rows unbounded preceding)
          / sum(revenue) over (), 1)                            as cumulative_share_pct
from by_category
order by revenue_rank
