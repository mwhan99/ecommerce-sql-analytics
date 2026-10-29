-- One row per customer_id. Olist gives a NEW customer_id for every order,
-- so customer_unique_id is the real "person" key.
select
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix as zip_code_prefix,
    customer_city            as city,
    customer_state           as state
from {{ source('olist', 'customers') }}
