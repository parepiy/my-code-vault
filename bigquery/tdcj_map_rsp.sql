with cj as(
  select
    barcode
    ,barcode_retail_price_1 as cj_rsp
    ,product_scm_status as cj_status
  from `tdshop-prod.cjx_gold.product_master`
  where dt = current_date()-1
),
picking as(
  SELECT distinct
    article_no
    ,td_picking_unit
  FROM `tdshop-prod.dimension.product` 
  WHERE created_d = current_date()-1
    and product_type = 'INVENTORY'
),
cj_bar as(
  select
    article_no as cj_article
    ,barcode as cj_barcode
  from `tdshop-prod.cjx_gold.product_master`
  where dt = current_date()-1
),
map as(
  select * from(
  select distinct
    td.article_no as td_article
    ,cj_bar.cj_article as cj_article
    ,row_number() over(partition by cj_bar.cj_article order by td.article_no) as row_num
  from picking as td
  left join cj_bar on cj_bar.cj_barcode = td.td_picking_unit
  )
  where row_num = 1
),
co as(
  SELECT distinct
    article_no
    ,barcode
    ,unit
    ,base_quantity
    ,order_from_code sup_code
    ,order_from_name sup_name
    ,max(unit_price)/base_quantity as cost_ex
  FROM `tdshop-prod.publish_assortment.td_nest_product_supplier_price_by_dc` 
  where dt = current_date()-1
    and cast(expire_date as date) >= current_date()
    and order_from_code in ('300000001','300000005')
  group by 1,2,3,4,5,6
)
select
  td.article_no as td_article
  ,regexp_replace(map.cj_article,r'^0+','') as cj_article
  ,product_name
  ,case when vat=true then 1.07 else 1 end as vat
  ,product_status
  ,td.barcode
  ,td.unit
  ,unit_factor
  ,retail_price_inc_vat as td_rsp
  ,co.cost_ex
  ,cj.cj_rsp
  ,cj.cj_status
from `tdshop-prod.dimension.product` as td
left join cj on cj.barcode = td.barcode
left join map on map.td_article = td.article_no
left join co on co.article_no = td.article_no
where created_d = current_date()-1
  and barcode_status = 'ACTIVE'
  and product_type = 'INVENTORY'
  and delivery_method = 'TD'
