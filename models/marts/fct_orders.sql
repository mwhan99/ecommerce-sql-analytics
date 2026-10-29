-- One row per order, with its totals, delivery timing and review.
with items as (
    select
        order_id,
        count(*)           as item_count,
        sum(price)         as item_revenue,
        sum(freight_value) as freight_total
    from {{ ref('stg_order_items') }}
    group by order_id
),

payments as (
    select order_id, sum(payment_value) as payment_total
    from {{ ref('stg_payments') }}
    group by order_id
)

select
    o.order_id,
    c.customer_unique_id,
    c.state                                   as customer_state,
    o.order_status,
    o.purchased_at,
    cast(date_trunc('month', o.purchased_at) as date) as order_month,
    coalesce(i.item_count, 0)                 as item_count,
    coalesce(i.item_revenue, 0)               as item_revenue,
    coalesce(i.freight_total, 0)              as freight_total,
    coalesce(p.payment_total, 0)              as payment_total,
    r.review_score,
    o.delivered_at,
    o.estimated_delivery_at,
    date_diff('day', o.purchased_at, o.delivered_at) as days_to_deliver,
    case
        when o.delivered_at is null then null
        else o.delivered_at > o.estimated_delivery_at
    end                                       as is_late,
    -- 1 = this person's first order, 2 = their second, ...
    row_number() over (
        partition by c.customer_unique_id
        order by o.purchased_at, o.order_id
    )                                         as customer_order_number
from {{ ref('stg_orders') }}       as o
join {{ ref('stg_customers') }}    as c on o.customer_id = c.customer_id
left join items                    as i on o.order_id = i.order_id
left join payments                 as p on o.order_id = p.order_id
left join {{ ref('stg_reviews') }} as r on o.order_id = r.order_id
