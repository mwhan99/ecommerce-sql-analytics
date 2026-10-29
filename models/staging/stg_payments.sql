-- An order can be paid in several parts (e.g. voucher + credit card).
select
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    cast(payment_value as decimal(10, 2)) as payment_value
from {{ source('olist', 'order_payments') }}
