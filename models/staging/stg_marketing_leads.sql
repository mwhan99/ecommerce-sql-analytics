-- One row per lead: a business that signed up showing interest in selling on Olist.
select
    mql_id,
    cast(first_contact_date as date) as first_contact_date,
    landing_page_id,
    coalesce(origin, 'unknown')      as origin
from {{ source('olist', 'marketing_qualified_leads') }}
