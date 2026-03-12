with order_metrics as (
    select * from {{ ref('int_order_metrics') }}
),
category_translations as (
    select * from {{ ref('category_translations') }}
),
customer_metrics as (
    select
        customer_id,
        customer_segment,
        recency_score,
        frequency_score,
        monetary_score,
        rfm_total
    from {{ ref('int_customer_metrics') }}
),

order_items as (
    select * from {{ ref('stg_order_items') }}
),

products as (
    select
        product_id,
        category_name,
        abc_category,
        revenue_rank
    from {{ ref('int_product_metrics') }}
),

final as (
    select
        -- keys
        oi.order_id,
        oi.order_item_id,
        oi.product_id,
        om.customer_id,
        oi.seller_id,

        -- dates
        om.ordered_at,
        om.delivered_at,
        om.order_month,
        om.order_week,
        om.order_year,
        om.order_month_num,

        -- financials
        oi.item_price,
        oi.freight_price,
        oi.total_item_price,
        om.order_value,
        om.total_items,
        om.delivery_days,

        -- order info
        om.order_status,

        -- customer dimensions
        cm.customer_segment,
        cm.rfm_total,

        -- product dimensions
        coalesce(ct.category_name_english, p.category_name) as category_name,
        p.abc_category,
        p.revenue_rank

    from order_items oi
    left join order_metrics om  using (order_id)
    left join customer_metrics cm on om.customer_id = cm.customer_id
    left join products p on oi.product_id = p.product_id
    left join category_translations ct on p.category_name = ct.category_name 

    where om.order_status = 'delivered'
)

select * from final