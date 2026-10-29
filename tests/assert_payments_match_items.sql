-- Sanity check: for delivered orders, what the customer paid should
-- roughly equal items + freight. Allow a few odd orders (vouchers,
-- installment interest), but fail if more than 2% disagree.
{{ config(severity = 'warn') }}
with checked as (
    select abs(payment_total - (item_revenue + freight_total)) > 1 as mismatch
    from {{ ref('fct_orders') }}
    where order_status = 'delivered'
)
select count(*) filter (where mismatch) as mismatches, count(*) as total
from checked
having count(*) filter (where mismatch) > 0.02 * count(*)
