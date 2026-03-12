with customers as (
    select * from {{ ref('stg_customers') }}
),

metrics as (
    select * from {{ ref('int_customer_metrics') }}
),

final as (
    select
        c.customer_id,
        c.customer_unique_id,
        c.city,
        c.state,
        c.zip_code,

        -- rfm metrics
        m.total_orders,
        m.total_spend,
        m.avg_order_value,
        m.days_since_last_order,
        m.first_order_at,
        m.last_order_at,
        m.total_items_bought,

        -- segments
        m.customer_segment,
        m.recency_score,
        m.frequency_score,
        m.monetary_score,
        m.rfm_total

    from customers c
    left join metrics m using (customer_id)
)

select * from final