-- One row per lead that became a seller. seller_id links to the orders data.
select
    mql_id,
    seller_id,
    cast(won_date as timestamp)                     as won_at,
    business_segment,
    lead_type,
    business_type,
    cast(declared_monthly_revenue as decimal(12, 2)) as declared_monthly_revenue
from {{ source('olist', 'closed_deals') }}
