WITH dc_sup AS (
  SELECT DISTINCT
    article_no,
    barcode,
    unit,
    base_quantity,
    order_from_code AS sup_code,
    order_from_name AS sup_name,
    unit_price,
    (unit_price / base_quantity) AS cost_unit,
    expire_date
  FROM `tdshop-prod.publish_assortment.td_nest_product_supplier_price_by_dc`
  WHERE dt = CURRENT_DATE() - 1
    AND CAST(expire_date AS DATE) >= CURRENT_DATE()
    AND order_from_code IN ('300000001', '300000005')
  UNION ALL
  SELECT DISTINCT
    article_no,
    barcode,
    unit,
    base_quantity,
    order_form_code AS sup_code,
    order_from_name AS sup_name,
    unit_price,
    (unit_price / base_quantity) AS cost_unit,
    expire_date
  FROM `tdshop-prod.publish_assortment.td_nest_product_supplier_price_by_store`
  WHERE dt = CURRENT_DATE() - 1
    AND CAST(expire_date AS DATE) >= CURRENT_DATE()
    AND order_form_code IN ('300000001', '300000005')
),
sup as(
  SELECT *
  FROM (
    SELECT *,
      ROW_NUMBER() OVER (PARTITION BY article_no ORDER BY expire_date DESC) AS row_num
    FROM dc_sup
  )
  WHERE row_num = 1
),
art as(
  select
    article_no
    ,sum(net_amount_incl_vat) as art_sale
  from `tdshop-bi.bi_mart.bi_sales_receipt`
  where receipt_date between date_trunc(date_sub(current_date(), interval 3 month),month) and current_date()-1
  group by 1
),
mix as(
  select
    barcode
    ,sum(net_amount_incl_vat) as bar_sale
  from `tdshop-bi.bi_mart.bi_sales_receipt`
  where receipt_date between date_trunc(date_sub(current_date(), interval 3 month),month) and current_date()-1
  group by barcode
  order by 1
),
cj as(
  select
    barcode
    ,article_no
    ,barcode_retail_price_1 as cj_rsp
    ,product_scm_status as cj_status
  from `tdshop-prod.cjx_gold.product_master`
  where dt = current_date()-1
)

select
  dim.article_no
  ,product_name
  ,product_status as status
  ,family
  ,class
  ,sub_class
  ,product_location_guideline as location
  ,flavor
  ,dim.brand
  ,case when vat=true then 1.07 else 1 end as vat
  ,dim.barcode
  ,dim.unit
  ,unit_factor
  ,(mix.bar_sale/art.art_sale) as percent_sale
  ,(td_moving_avg_cost_ex_vat*unit_factor) as moving_ex
  ,(wsp_base_unit_inc_vat*unit_factor) as wsp_in
  ,retail_price_inc_vat as rsp_in
  ,sup.sup_code
  ,sup.sup_name
  ,sup.barcode as order_barcode
  ,sup.cost_unit*unit_factor as cost_ex
  ,regexp_replace(cj.article_no,r'^0+','') as cj_article
  ,cj.cj_rsp
  ,cj.cj_status
from `tdshop-prod.dimension.product` as dim
left join sup on sup.article_no = dim.article_no
left join art on dim.article_no = art.article_no
left join mix on mix.barcode = dim.barcode
left join cj on cj.barcode = dim.barcode
where created_d = current_date()-1
  and product_type = 'INVENTORY'
  and barcode_status = 'ACTIVE'
  and delivery_method = 'TD'
