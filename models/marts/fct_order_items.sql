-- One row per item sold, with product category and seller location,
-- for category and seller analysis.
select
    i.order_id,
    i.order_item_id,
    o.purchased_at,
    o.order_month,
    o.order_status,
    o.customer_unique_id,
    o.customer_state,
    i.product_id,
    p.category,
    i.seller_id,
    s.state as seller_state,
    i.price,
    i.freight_value
from {{ ref('stg_order_items') }} as i
join {{ ref('fct_orders') }}      as o on i.order_id = o.order_id
left join {{ ref('stg_products') }} as p on i.product_id = p.product_id
left join {{ ref('stg_sellers') }}  as s on i.seller_id = s.seller_id
