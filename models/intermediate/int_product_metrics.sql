with order_items as (
    select * from {{ ref('stg_order_items') }}
),

products as (
    select * from {{ ref('stg_products') }}
),

orders as (
    select
        order_id,
        ordered_at,
        order_status
    from {{ ref('int_order_metrics') }}
),

-- aggregate sales per product
product_sales as (
    select
        oi.product_id,
        count(distinct oi.order_id)         as total_orders,
        sum(oi.order_item_id)               as total_units_sold,
        sum(oi.item_price)                  as total_revenue,
        avg(oi.item_price)                  as avg_selling_price,
        sum(oi.freight_price)               as total_freight_collected,
        min(o.ordered_at)                   as first_sold_at,
        max(o.ordered_at)                   as last_sold_at

    from order_items oi
    left join orders o using (order_id)
    where o.order_status = 'delivered'
    group by oi.product_id
),

-- join with product details and add ABC classification
final as (
    select
        ps.product_id,
        p.category_name,
        p.weight_grams,
        p.photos_count,

        ps.total_orders,
        ps.total_units_sold,
        ps.total_revenue,
        ps.avg_selling_price,
        ps.total_freight_collected,
        ps.first_sold_at,
        ps.last_sold_at,

        -- revenue rank
        rank() over (order by ps.total_revenue desc) as revenue_rank,

        -- ABC analysis: A = top 80% revenue, B = next 15%, C = bottom 5%
        case
            when sum(ps.total_revenue) over (
                order by ps.total_revenue desc
                rows between unbounded preceding and current row
            ) / sum(ps.total_revenue) over () <= 0.80
                then 'A - Top Performers'
            when sum(ps.total_revenue) over (
                order by ps.total_revenue desc
                rows between unbounded preceding and current row
            ) / sum(ps.total_revenue) over () <= 0.95
                then 'B - Mid Performers'
            else
                'C - Low Performers'
        end as abc_category

    from product_sales ps
    left join products p using (product_id)
)

select * from final
