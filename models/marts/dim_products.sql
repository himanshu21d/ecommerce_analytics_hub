with products as (
    select * from {{ ref('stg_products') }}
),

metrics as (
    select * from {{ ref('int_product_metrics') }}
),

final as (
    select
        p.product_id,
        p.category_name,
        p.weight_grams,
        p.photos_count,
        p.length_cm,
        p.height_cm,
        p.width_cm,

        -- performance metrics
        m.total_orders,
        m.total_units_sold,
        m.total_revenue,
        m.avg_selling_price,
        m.first_sold_at,
        m.last_sold_at,
        m.revenue_rank,
        m.abc_category

    from products p
    left join metrics m using (product_id)
)

select * from final
