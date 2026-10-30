-- Q3. How concentrated is revenue? Who are the "VIPs"?
--     (FanDuel analogue: VIP player tiers.)
-- SQL shown: NTILE() window function, CASE WHEN, a window over an
-- aggregate (SUM(SUM(...)) OVER ()) to get each segment's share.

with ranked as (
    select
        customer_unique_id,
        order_count,
        lifetime_revenue,
        -- split customers into 100 equal groups by spend; 1 = top 1%
        ntile(100) over (order by lifetime_revenue desc) as spend_percentile
    from {{ ref('dim_customers') }}
    where order_count > 0
),

segmented as (
    select
        *,
        case
            when spend_percentile = 1   then '1. VIP (top 1%)'
            when spend_percentile <= 10 then '2. High value (top 2-10%)'
            when spend_percentile <= 50 then '3. Mid value (top 11-50%)'
            else                             '4. Low value (bottom 50%)'
        end as segment
    from ranked
)

select
    segment,
    count(*)                                         as customers,
    sum(lifetime_revenue)                            as revenue,
    round(100.0 * sum(lifetime_revenue)
          / sum(sum(lifetime_revenue)) over (), 1)   as revenue_share_pct,
    round(avg(lifetime_revenue), 2)                  as avg_spend,
    min(lifetime_revenue)                            as min_spend,
    round(avg(order_count), 2)                       as avg_orders,
    round(100.0 * avg(case when order_count > 1 then 1 else 0 end), 1)
                                                     as repeat_rate_pct
from segmented
group by segment
order by segment
