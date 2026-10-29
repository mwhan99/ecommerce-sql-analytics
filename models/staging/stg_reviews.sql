-- A few orders have more than one review. Keep only the latest one,
-- so this model has exactly one row per order.
with ranked as (
    select
        review_id,
        order_id,
        cast(review_score as integer)            as review_score,
        cast(review_creation_date as timestamp)  as reviewed_at,
        row_number() over (
            partition by order_id
            order by cast(review_answer_timestamp as timestamp) desc, review_id
        ) as review_rank
    from {{ source('olist', 'order_reviews') }}
)

select review_id, order_id, review_score, reviewed_at
from ranked
where review_rank = 1
