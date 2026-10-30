-- Q10. Which marketing channels bring sellers who actually sign up and sell?
--      (FanDuel analogue: media/acquisition performance by channel.)
-- SQL shown: a funnel built from LEFT JOINs, conditional counts, MEDIAN.
-- Limitation: leads run Jun 2017-May 2018 but orders stop in Oct 2018,
-- so late sign-ups have had little time to sell.

with seller_sales as (
    select seller_id, count(distinct order_id) as orders, sum(price) as revenue
    from {{ ref('fct_order_items') }}
    where order_status not in ('canceled', 'unavailable')
    group by seller_id
),

funnel as (
    select
        l.origin,
        l.mql_id,
        d.mql_id is not null                               as became_seller,
        date_diff('day', l.first_contact_date, d.won_at)   as days_to_close,
        s.seller_id is not null                            as made_a_sale,
        coalesce(s.revenue, 0)                             as seller_revenue
    from {{ ref('stg_marketing_leads') }}   as l
    left join {{ ref('stg_closed_deals') }} as d on l.mql_id = d.mql_id
    left join seller_sales                  as s on d.seller_id = s.seller_id
)

select
    origin                                                              as channel,
    count(*)                                                            as leads,
    sum(case when became_seller then 1 else 0 end)                      as sellers_signed,
    round(100.0 * avg(case when became_seller then 1 else 0 end), 1)    as lead_to_seller_pct,
    median(days_to_close)                                               as median_days_to_close,
    sum(case when made_a_sale then 1 else 0 end)                        as sellers_with_sales,
    round(sum(seller_revenue), 2)                                       as revenue_from_sellers,
    round(sum(seller_revenue) / count(*), 2)                            as revenue_per_lead
from funnel
group by origin
order by leads desc
