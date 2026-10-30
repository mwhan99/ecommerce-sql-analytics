-- The four spend segments together must cover all revenue (100%,
-- allowing 0.5 for rounding).
select sum(revenue_share_pct) as total
from {{ ref('rpt_customer_segments') }}
having abs(sum(revenue_share_pct) - 100) > 0.5
