-- Q5. How much does late delivery hurt customer satisfaction?
-- SQL shown: DATE_DIFF, CASE WHEN buckets, conditional averages.

with delivered as (
    select
        review_score,
        -- positive = days late, negative = days early
        date_diff('day', estimated_delivery_at, delivered_at) as days_vs_estimate
    from {{ ref('fct_orders') }}
    where order_status = 'delivered'
      and delivered_at is not null      -- 8 delivered orders have no date
      and review_score is not null
),

bucketed as (
    select
        review_score,
        case
            when days_vs_estimate <= 0  then '1. On time or early'
            when days_vs_estimate <= 3  then '2. 1-3 days late'
            when days_vs_estimate <= 7  then '3. 4-7 days late'
            when days_vs_estimate <= 14 then '4. 8-14 days late'
            else                             '5. 15+ days late'
        end as delivery_bucket
    from delivered
)

select
    delivery_bucket,
    count(*)                                                        as orders,
    round(100.0 * count(*) / sum(count(*)) over (), 1)              as share_of_orders_pct,
    round(avg(review_score), 2)                                     as avg_review_score,
    round(100.0 * avg(case when review_score = 1 then 1 else 0 end), 1) as one_star_pct,
    round(100.0 * avg(case when review_score = 5 then 1 else 0 end), 1) as five_star_pct
from bucketed
group by delivery_bucket
order by delivery_bucket
