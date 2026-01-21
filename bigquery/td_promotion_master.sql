with pro as(
  select distinct
    promotion_code
    ,promotion_name
    ,theme_name
    ,effective_date
    ,expire_date
    ,promotion_type_display_name as pro_type
    ,promotion_by
    ,total_price_amount
    ,average_price_amount
  from `tdshop-prod.publish_assortment.td_nest_promotion`
  where dt <= current_date()-1
    and cast(expire_date as date) > current_date()
    and is_cancelled = FALSE
)
select distinct
  sa.promotion_code
  ,pro.promotion_name
  ,pro.theme_name
  ,pro.effective_date
  ,pro.expire_date
  ,pro.pro_type
  ,barcode
  ,article_no
  ,unit
  ,unit_factor
  ,rsp_amount
  ,pro.total_price_amount
  ,pro.average_price_amount
  ,pro.promotion_by
  ,supplier_com_amount
  ,partner_com_amount
from `tdshop-prod.publish_assortment.td_nest_promotion_barcode` as sa
left join pro on pro.promotion_code = sa.promotion_code
where dt between parse_date('%Y%m%d',@DS_START_DATE) and parse_date('%Y%m%d',@DS_END_DATE)
  and pro.effective_date is not null
