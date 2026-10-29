-- One row per item in an order (order_item_id is 1, 2, 3... within an order).
select
    order_id,
    order_item_id,
    product_id,
    seller_id,
    cast(shipping_limit_date as timestamp) as shipping_limit_at,
    cast(price         as decimal(10, 2))  as price,
    cast(freight_value as decimal(10, 2))  as freight_value
from {{ source('olist', 'order_items') }}
