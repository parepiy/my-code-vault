with hist as(
  select
    t.article_no
    ,t.dt
    ,lower(t.product_status) as status
    ,case
      when lower(t.product_status) not in ('clear','clear_promotion') then 1
      when lag(lower(t.product_status)) over (
        partition by t.article_no
        order by t.dt
      ) != lower(t.product_status) then 1
      else 0
    end as break_flag
  from `cjx-data-core.cjx_data_mart_prod.mart_console_dim_product` t
  where t.dt <= current_date()-1
  QUALIFY
  -- เอาเฉพาะ product ที่ล่าสุดเป็น clear / clear_promotion
  LAST_VALUE(LOWER(product_status)) OVER (
    PARTITION BY article_no
    ORDER BY dt
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
  ) IN ('clear','clear_promotion')
),
grp as(
  select
    article_no
    ,dt
    ,status
    ,sum(break_flag) over (
      partition by article_no
      order by dt
      rows between unbounded preceding and current row
    ) as grp_id
  from hist
),
last_grp as(
  select
    article_no
    ,status
    ,max(grp_id) as last_grp_id
  from grp
  where lower(status) in ('clear','clear_promotion')
  group by 1,2
)

select
  g.article_no
  ,g.status
  ,min(g.dt) as status_start_date
  ,date_diff(max(g.dt),min(g.dt),day)+1 as consecutive_days
from grp g
join last_grp l
  on g.article_no = l.article_no
  and g.status = l.status
  and g.grp_id = l.last_grp_id
where g.article_no = '20019352'
group by g.article_no, g.status
order by g.article_no, g.status

