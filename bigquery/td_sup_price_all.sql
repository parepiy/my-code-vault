with dc as(
  SELECT distinct
    article_no
    ,barcode
    ,unit
    ,base_quantity
    ,order_from_code sup_code
    ,order_from_name sup_name
    ,unit_price
    ,average_unit_price
    ,expire_date
  FROM `tdshop-prod.publish_assortment.td_nest_product_supplier_price_by_dc` 
  where dt = current_date()-1
    and cast(expire_date as date) >= current_date()
),
sup as(
  SELECT distinct
    article_no
    ,barcode
    ,unit
    ,base_quantity
    ,order_form_code sup_code
    ,order_from_name sup_name
    ,unit_price
    ,average_unit_price
    ,expire_date
  FROM `tdshop-prod.publish_assortment.td_nest_product_supplier_price_by_store`
  where dt = current_date()-1
    and cast(expire_date as date) >= current_date()
)

select * from dc
union all
select * from sup
