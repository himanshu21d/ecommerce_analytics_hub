
-- QUERY 1: Month-over-Month Revenue Growth
-- Business Question: Is revenue trending up?

with monthly_revenue as (
    select
        order_month,
        order_year,
        order_month_num,
        round(sum(item_price), 2)        as revenue,
        count(distinct order_id)          as orders,
        round(avg(item_price), 2)         as avg_order_value
    from main.fct_sales
    group by order_month, order_year, order_month_num
),

with_growth as (
    select
        *,
        lag(revenue) over (order by order_month) as prev_month_revenue,
        round(
            (revenue - lag(revenue) over (order by order_month))
            / nullif(lag(revenue) over (order by order_month), 0) * 100
        , 2) as mom_growth_pct
    from monthly_revenue
)

select * from with_growth
order by order_month;



-- QUERY 2: Revenue by Category (Top 10)
-- Business Question: Which categories drive revenue?

select
    category_name,
    count(distinct order_id)              as total_orders,
    round(sum(item_price), 2)             as total_revenue,
    round(avg(item_price), 2)             as avg_order_value,
    round(sum(item_price) * 100.0 /
        sum(sum(item_price)) over (), 2)  as revenue_share_pct
from main.fct_sales
where category_name is not null
group by category_name
order by total_revenue desc
limit 10;



-- QUERY 3: Customer Segment Analysis
-- Business Question: Where is revenue coming from by segment?

select
    customer_segment,
    count(distinct customer_id)           as total_customers,
    count(distinct order_id)              as total_orders,
    round(sum(item_price), 2)             as total_revenue,
    round(avg(item_price), 2)             as avg_order_value,
    round(sum(item_price) /
        nullif(count(distinct customer_id), 0), 2) as revenue_per_customer
from main.fct_sales
group by customer_segment
order by total_revenue desc;



-- QUERY 4: Cohort Revenue Analysis
-- Business Question: Do customers spend more over time?

with customer_cohorts as (
    select
        customer_id,
        date_trunc('month', min(ordered_at))::date as cohort_month
    from main.fct_sales
    group by customer_id
),

cohort_data as (
    select
        c.cohort_month,
        date_trunc('month', f.ordered_at)::date as order_month,
        datediff('month', c.cohort_month,
            date_trunc('month', f.ordered_at)::date
        ) as months_since_first_order,
        count(distinct f.customer_id) as customers,
        round(sum(f.item_price), 2)   as revenue
    from main.fct_sales f
    left join customer_cohorts c using (customer_id)
    group by c.cohort_month, order_month, months_since_first_order
)

select
    cohort_month,
    months_since_first_order,
    customers,
    revenue,
    round(revenue / nullif(customers, 0), 2) as revenue_per_customer
from cohort_data
order by cohort_month, months_since_first_order;


-- QUERY 5: ABC Product Analysis
-- Business Question: Which products should we focus on?
select
    abc_category,
    count(distinct product_id)            as total_products,
    count(distinct order_id)              as total_orders,
    round(sum(item_price), 2)             as total_revenue,
    round(sum(item_price) * 100.0 /
        sum(sum(item_price)) over (), 2)  as revenue_share_pct,
    round(avg(item_price), 2)             as avg_price
from main.fct_sales
group by abc_category
order by total_revenue desc;