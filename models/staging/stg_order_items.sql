with source as (
    select * from {{ source('raw', 'raw_order_items') }}
),

cleaned as (
    select
        order_id,
        order_item_id,
        product_id,
        seller_id,
        cast(shipping_limit_date as timestamp) as shipping_limit_at,
        price                                  as item_price,
        freight_value                          as freight_price,
        price + freight_value                  as total_item_price
    from source
    where order_id is not null
)

select * from cleaned