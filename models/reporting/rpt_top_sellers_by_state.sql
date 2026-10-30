-- Q8. Who are the top 3 sellers in each state?
-- SQL shown: ROW_NUMBER() OVER (PARTITION BY ...) - the classic
-- "top N per group" interview question.

with seller_revenue as (
    select
        seller_id,
        seller_state,
        count(distinct order_id) as orders,
        sum(price)               as revenue
    from {{ ref('fct_order_items') }}
    where order_status not in ('canceled', 'unavailable')
    group by seller_id, seller_state
),

ranked as (
    select
        *,
        -- restart the numbering at 1 for every state
        row_number() over (partition by seller_state
                           order by revenue desc) as rank_in_state
    from seller_revenue
)

select seller_state, rank_in_state, seller_id, orders, revenue
from ranked
where rank_in_state <= 3
order by seller_state, rank_in_state
