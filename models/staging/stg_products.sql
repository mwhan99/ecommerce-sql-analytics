-- Category names are in Portuguese; add the English name from the
-- translation table. Original column names are misspelled ("lenght").
select
    p.product_id,
    p.product_category_name                                      as category_pt,
    coalesce(t.product_category_name_english, p.product_category_name, 'unknown')
                                                                 as category,
    cast(p.product_photos_qty as integer)                        as photos_qty,
    cast(p.product_weight_g   as integer)                        as weight_g
from {{ source('olist', 'products') }} as p
left join {{ source('olist', 'category_translation') }} as t
    on p.product_category_name = t.product_category_name
