#tier TD
with dim as(
  select distinct
    article_key
    ,product_name
    ,product_status as status
    ,family
    ,class
    ,class_key
    ,sub_class
    ,sub_class_key
  from `tdshop-prod.dimension.product`
  where created_d = current_date()-1
  	and product_type = 'INVENTORY'
  	and segment <> 'PROMOTION'
)
select
  sa.article_no
  ,dim.product_name
  ,dim.status, dim.family, dim.class, dim.class_key
  ,dim.sub_class, dim.sub_class_key
  ,sum(after_refund_net_sale_amount_ex_vat) as sale_ex
  ,sum(after_refund_total_sale_qty) as total_qty
from `tdshop-prod.fact.sales_receipt` as sa
left join dim on dim.article_key = sa.article_no
where created_d between date_sub(date_trunc(current_date(),month),interval 3 month) and last_day(date_sub(current_date(),interval 1 month))
  and lower(dim.status) in ('active','hold_buy','out_of_stock','new')
group by 1,2,3,4,5,6,7,8
;
#tier CJX
with dim as(
  select distinct
    article_no
    ,product_name
    ,product_status as status
    ,family
    ,class_key
    ,class
    ,sub_class_key
    ,sub_class
  from `cjx-data-core.cjx_data_mart_prod.mart_console_dim_product`
  where dt = current_date()-1
)
select
  sa.article_no
  ,dim.product_name
  ,dim.status, dim.family, dim.class, dim.class_key
  ,dim.sub_class, dim.sub_class_key
  ,sum(after_refund_net_sale_amount_exc_vat) as sale_ex
  ,sum(after_refund_total_sale_qty) as total_qty
from `cjx-data-core.cjx_data_mart_prod.mart_console_sales` as sa
left join dim on dim.article_no = sa.article_no
where receipt_date between DATE_SUB(DATE_TRUNC(CURRENT_DATE(), MONTH), INTERVAL 3 MONTH) AND LAST_DAY(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH))
  and lower(dim.status) in ('active','hold_buy','out_of_stock','new')
  and sa.article_no like '2%'
group by 1,2,3,4,5,6,7,8
