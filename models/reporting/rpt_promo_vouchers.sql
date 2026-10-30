-- Q4. Do customers who used a voucher on their FIRST order come back
--     more often, or spend more, than those who didn't?
--     (FanDuel analogue: does "generosity" - bonuses, free bets - pay off?)
-- SQL shown: LEFT JOIN to flag a group, COALESCE, comparing groups.
-- Limitation: this is a comparison, not an experiment. Voucher users may
-- differ from others to begin with, so it can't prove vouchers CAUSE
-- anything. A proper answer needs a holdout test (A/B test).

with voucher_orders as (
    select order_id, sum(payment_value) as voucher_value
    from {{ ref('stg_payments') }}
    where payment_type = 'voucher'
    group by order_id
),

first_orders as (
    select
        o.customer_unique_id,
        o.item_revenue,
        o.review_score,
        v.order_id is not null        as used_voucher,
        coalesce(v.voucher_value, 0)  as voucher_value
    from {{ ref('fct_orders') }} as o
    left join voucher_orders     as v on o.order_id = v.order_id
    where o.customer_order_number = 1
      and o.order_status not in ('canceled', 'unavailable')
)

select
    case when f.used_voucher then 'Voucher on first order'
         else 'No voucher' end                       as first_order_group,
    count(*)                                         as customers,
    round(avg(f.item_revenue), 2)                    as avg_first_order_value,
    round(avg(f.voucher_value), 2)                   as avg_voucher_value,
    round(100.0 * avg(case when c.order_count > 1 then 1 else 0 end), 2)
                                                     as repeat_rate_pct,
    round(avg(c.lifetime_revenue), 2)                as avg_lifetime_revenue,
    round(avg(f.review_score), 2)                    as avg_first_review_score
from first_orders as f
join {{ ref('dim_customers') }} as c on f.customer_unique_id = c.customer_unique_id
group by first_order_group
order by first_order_group desc
