with sup as(
  SELECT
    article_no
    ,barcode
    ,unit
    ,base_quantity
    ,order_form_code
    ,order_from_name
    ,ship_to_code
    ,ship_to_name
    ,unit_price
    ,effective_date
    ,expire_date
  FROM `tdshop-prod.publish_assortment.td_nest_product_supplier_price_by_store`
  where dt = current_date()-1
),
dim as (
  select
    distinct article_key
    ,product_name
    ,family
    ,class
    ,sub_class
    ,brand
    ,product_status
  from `tdshop-prod.dimension.product`
  where created_d = current_date()-1
)

select
  dim.brand
  ,dim.family
  ,dim.class
  ,dim.product_status
  ,dim.product_name
  ,sup.*
from sup
left join dim
  on dim.article_key = sup.article_no
--where lower(dim.class) = 'pre packed rice'




