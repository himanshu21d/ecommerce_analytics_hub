with date_spine as (
    select
        unnest(
            generate_series(
                date '2016-01-01',
                date '2019-12-31',
                interval '1 day'
            )
        )::date as date_day
),

final as (
    select
        date_day,
        year(date_day)                              as year,
        month(date_day)                             as month_num,
        monthname(date_day)                         as month_name,
        quarter(date_day)                           as quarter,
        dayofweek(date_day)                         as day_of_week,
        dayname(date_day)                           as day_name,
        date_trunc('week', date_day)::date          as week_start,
        date_trunc('month', date_day)::date         as month_start,
        date_trunc('quarter', date_day)::date       as quarter_start,

        -- useful flags
        case when dayofweek(date_day) in (0,6)
            then true else false
        end                                         as is_weekend,
        case when month(date_day) in (11, 12)
            then true else false
        end                                         as is_holiday_season

    from date_spine
)

select * from final