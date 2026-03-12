with orders as (
    select * from {{ ref('stg_orders') }}
),

order_items as (
    select * from {{ ref('stg_order_items') }}
),

payments as (
    select
        order_id,
        sum(payment_value) as total_payment
    from {{ ref('stg_order_payments') }}
    group by order_id
),

order_items_agg as (
    select
        order_id,
        count(order_item_id)    as total_items,
        sum(item_price)         as total_item_price,
        sum(freight_price)      as total_freight,
        sum(total_item_price)   as order_value
    from order_items
    group by order_id
),

final as (
    select
        o.order_id,
        o.customer_id,
        o.order_status,
        o.ordered_at,
        o.delivered_at,
        o.delivery_days,

        -- order financials
        oi.total_items,
        oi.total_item_price,
        oi.total_freight,
        oi.order_value,
        p.total_payment,

        -- time dimensions for dashboard
        date_trunc('month', o.ordered_at) as order_month,
        date_trunc('week', o.ordered_at)  as order_week,
        year(o.ordered_at)                as order_year,
        month(o.ordered_at)               as order_month_num

    from orders o
    left join order_items_agg oi using (order_id)
    left join payments p using (order_id)
)

select * from final