with nest as(
  select
    promotion_code
    ,barcode,article_no
    ,theme_name,campaign_code
    ,promotion_type,retail_price_amount,total_retail_price_amount
    ,total_current_retail_price_amount,total_promotion_price_amount,total_current_promotion_price_amount
    ,compensate_per_unit_amount,is_member_only
    ,promotion_effective_date_bkk as cjx_pro_start
    ,promotion_expire_date_bkk as cjx_pro_end
    ,is_cancelled as cjx_cancel
  from `cjx-data-core.cjx_data_mart_prod.mart_console_dim_promotion`
  where dt = current_date()-1
    and source_system = 'CJX_NEST'
    and campaign_code is not null
    and promotion_expire_date_bkk >= current_date()
),
ad as(
  select
    pro_start
    ,pro_end
    ,cjx_pro_theme
    ,barcode_promotion
    ,cj_pro_code
    ,advertisment as ad
  from `tdshop-data-business-units-com.commercial_sandbox.advertisement`
  where advertisment = 'Yes'
),
dim as(
  select
    barcode
    ,product_name
    ,unit,unit_factor
    ,segment,family,class,sub_class
  from `cjx-data-core.cjx_data_mart_prod.mart_console_dim_product`
  where dt = current_date()-1
    and barcode_status = 'ACTIVE'
)
select
  m.promotion_code as cj_pro_code
  ,m.barcode as cj_barcode
  ,is_cancelled
  ,d.product_name
  ,d.unit,d.unit_factor
  ,d.segment,d.family,d.class,d.sub_class
  ,n.*
  ,coalesce(a.ad,'No') as ad
from `cjx-data-core.cjx_data_mart_prod.mart_console_dim_promotion` as m
left join nest n on n.barcode = m.barcode and n.campaign_code = m.promotion_code
left join ad a on a.barcode_promotion = m.barcode
  and a.cj_pro_code = m.promotion_code
left join dim d on d.barcode = m.barcode
where dt = current_date()-1
  and source_system <> 'CJX_NEST'
  and promotion_expire_date_bkk >= current_date()
  and n.article_no is not null
