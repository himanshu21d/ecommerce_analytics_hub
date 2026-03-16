with orders as (
    select * from {{ ref('int_order_metrics') }}
),

-- step 1: aggregate raw metrics per customer
customer_orders as (
    select
        customer_id,

        -- Recency: days since last order (lower = better)
        datediff('day', max(ordered_at), current_date) as days_since_last_order,

        -- Frequency: how many orders
        count(distinct order_id)                        as total_orders,

        -- Monetary: total spend
        sum(order_value)                                as total_spend,

        -- extra useful metrics
        avg(order_value)                                as avg_order_value,
        min(ordered_at)                                 as first_order_at,
        max(ordered_at)                                 as last_order_at,
        sum(total_items)                                as total_items_bought

    from orders
    group by customer_id
),

-- step 2: score each dimension 1-5 using NTILE
rfm_scored as (
    select
        *,
        -- recency: higher score = more recent (reverse order)
        ntile(5) over (order by days_since_last_order desc, customer_id) as recency_score,
        -- frequency: higher score = more orders
        ntile(5) over (order by total_orders, customer_id)               as frequency_score,
        -- monetary: higher score = more spend
        ntile(5) over (order by total_spend, customer_id)                as monetary_score
    from customer_orders
),

-- step 3: assign human-readable segments
final as (
    select
        *,
        recency_score + frequency_score + monetary_score as rfm_total,

        case
            when recency_score >= 4 and frequency_score >= 4
                then 'Champions'
            when recency_score >= 3 and frequency_score >= 3
                then 'Loyal Customers'
            when recency_score >= 4 and frequency_score <= 2
                then 'New Customers'
            when recency_score <= 2 and frequency_score >= 3
                then 'At Risk'
            when recency_score <= 2 and frequency_score <= 2
                then 'Lost'
            else
                'Needs Attention'
        end as customer_segment

    from rfm_scored
)

select * from final