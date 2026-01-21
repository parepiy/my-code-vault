with sa as(
  select
    article_no
    ,sum(total_sale_qty) total_qty
    ,count(distinct store_code) ctd_store
    ,count(distinct date) ctd_date
  from `tdshop-bi.bi_mart.bi_sales_summary_article`
  where date between date_trunc(date_sub(current_date(), interval 3 month),month) and current_date()-1
  group by 1
),

store as(
  select
    store_key
    ,td_nest_store_status
  from `tdshop-prod.dimension.store_location_v2`
  where created_d = current_date()-1
),

stock as(
  select
    article_no
    ,sum(quantity) total_stock
    ,count(distinct location) ctd_stock_store
  from(
    select
      location
      ,store.td_nest_store_status
      ,article_no
      ,quantity
    from `tdshop-prod.publish_inventory.td_nest_stock`
    left join store
      on store.store_key = location
    where dt = current_date()-1
      and store.td_nest_store_status = 'ACTIVE'
  )
  group by 1
),

sum_all as(
  select
    stock.article_no
    ,stock.total_stock
    ,stock.ctd_stock_store
    ,sa.ctd_store ctd_sales_store
    ,sa.ctd_date
    ,sa.total_qty
  from stock
  left join sa
    on sa.article_no = stock.article_no
)

select
  article_no
  ,round(sum_all.total_stock/sum_all.ctd_stock_store/(sum_all.total_qty/sum_all.ctd_sales_store/sum_all.ctd_date),2) store_doh
from sum_all
