with picking as(
  SELECT distinct
    article_no
    ,td_picking_unit
    ,product_status
    ,product_name
    ,brand
    ,segment
    ,family
    ,class
    ,sub_class
    ,case when vat = true then 1.07 else 1 end as vat
  FROM `tdshop-prod.dimension.product` 
  WHERE created_d = current_date()-1
    and product_type = 'INVENTORY'
    and fresh_lite_category = false
    and delivery_method = 'TD'
),

td_bar as(
  select
    barcode
    ,unit
    ,unit_factor
  from `tdshop-prod.dimension.product`
  WHERE created_d = current_date()-1
    and product_type = 'INVENTORY'
    and barcode_status = 'ACTIVE'
),

cjx as(
  select
    article_no
    ,product_name
    ,product_scm_status
    ,barcode
    ,unit_code
    ,barcode_factor
    ,supplier_code
    ,brand_name
    ,family_name
    ,category
    ,sub_category
    ,case when product_is_cal_vat = true then 1.07 else 1 end as vat
  from `tdshop-prod.cjx_gold.product_master`
  where dt = current_date()-1
),
term as(
  select distinct
    regexp_replace(vendor_code,r'^0{1,4}','') as sup_code
    ,terms_of_payment
  from `tdshop-prod.cjx_gold.vendor_master`
  where dt = current_date()-1
),
cj_sup as(
  SELECT distinct
    source_supplier_code
    ,source_supplier_name
    ,term.terms_of_payment as credit_term
  FROM `tdshop-prod.publish_assortment.td_nest_product_supplier_price_by_vendor` 
  left join term on term.sup_code = source_supplier_code
  where dt = current_date()-1
    and location_level_type = 'ALL_DCS'
),

dc as(
  SELECT distinct
    article_no
    ,barcode as order_bar
    ,unit as order_unit
    ,base_quantity as order_factor
    ,order_from_code sup_code
    ,order_from_name sup_name
    ,date(effective_date) eff_date
    ,date(expire_date) exp_date
  FROM `tdshop-prod.publish_assortment.td_nest_product_supplier_price_by_dc` 
  where dt = current_date()-1
),
sup as(
  SELECT distinct
    article_no
    ,barcode as order_bar
    ,unit as order_unit
    ,base_quantity as order_factor
    ,order_form_code sup_code
    ,order_from_name sup_name
    ,date(effective_date) eff_date
    ,date(expire_date) exp_date
  FROM `tdshop-prod.publish_assortment.td_nest_product_supplier_price_by_store`
  where dt = current_date()-1
),

td_sup as(
  select distinct
    *
  from(
    select
      *
      ,row_number() over (partition by article_no order by sup_code desc) as rn
    from(
      select * from dc
      union all
      select * from sup
      where eff_date <= current_date()-1
        and exp_date > current_date()-1
    )
  )
  where rn = 1
),
td_dim as(
  select
    article_no
    ,split(size_s,',')[safe_offset(0)] as bar_s1
    ,split(size_s_un,',')[safe_offset(0)] as bar_s1_un
    ,cast(split(size_s_uf,',')[safe_offset(0)] as int64) as bar_s1_uf
    ,split(size_s,',')[safe_offset(1)] as bar_s2
    ,split(size_s_un,',')[safe_offset(1)] as bar_s2_un
    ,cast(split(size_s_uf,',')[safe_offset(1)] as int64) as bar_s2_uf
    ,split(size_m,',')[safe_offset(0)] as bar_m1
    ,split(size_m_un,',')[safe_offset(0)] as bar_m1_un
    ,cast(split(size_m_uf,',')[safe_offset(0)] as int64) as bar_m1_uf
    ,split(size_m,',')[safe_offset(1)] as bar_m2
    ,split(size_m_un,',')[safe_offset(1)] as bar_m2_un
    ,cast(split(size_m_uf,',')[safe_offset(1)] as int64) as bar_m2_uf
    ,split(size_l,',')[safe_offset(0)] as bar_l1
    ,split(size_l_un,',')[safe_offset(0)] as bar_l1_un
    ,cast(split(size_l_uf,',')[safe_offset(0)] as int64) as bar_l1_uf
    ,split(size_l,',')[safe_offset(1)] as bar_l2
    ,split(size_l_un,',')[safe_offset(1)] as bar_l2_un
    ,cast(split(size_l_uf,',')[safe_offset(1)] as int64) as bar_l2_uf
  from(
    select
      article_no
      ,string_agg(if(barcode_size = 'S',barcode,null) order by unit_factor) as size_s
      ,string_agg(if(barcode_size = 'S',unit,null) order by unit_factor) as size_s_un
      ,string_agg(if(barcode_size = 'S',cast(unit_factor as string),null) order by unit_factor) as size_s_uf
      ,string_agg(if(barcode_size = 'M',barcode,null) order by unit_factor) as size_m
      ,string_agg(if(barcode_size = 'M',unit,null) order by unit_factor) as size_m_un
      ,string_agg(if(barcode_size = 'M',cast(unit_factor as string),null) order by unit_factor) as size_m_uf
      ,string_agg(if(barcode_size = 'L',barcode,null) order by unit_factor) as size_l
      ,string_agg(if(barcode_size = 'L',unit,null) order by unit_factor) as size_l_un
      ,string_agg(if(barcode_size = 'L',cast(unit_factor as string),null) order by unit_factor) as size_l_uf
    from `tdshop-prod.dimension.product`
    where created_d = current_date()-1
      and barcode_status = 'ACTIVE'
      and product_type = 'INVENTORY'
      --and article_no in ('20005983','20038741')
    group by 1
  )
)


select distinct
  td.article_no as td_article
  ,td.product_name as td_product_name
  ,td.product_status as td_product_status
  ,td.td_picking_unit as td_picking
  ,td_bar.unit as td_pick_unit
  ,td_bar.unit_factor as td_pick_factor
  ,td.brand as td_brand
  ,td.segment as td_segment
  ,td.family as td_family
  ,td.class as td_class
  ,td.sub_class as td_sub_class
  ,td.vat as td_vat
  ,td_dim.bar_s1
  ,td_dim.bar_s1_un
  ,td_dim.bar_s1_uf
  ,td_dim.bar_s2
  ,td_dim.bar_s2_un
  ,td_dim.bar_s2_uf
  ,td_dim.bar_m1
  ,td_dim.bar_m1_un
  ,td_dim.bar_m1_uf
  ,td_dim.bar_m2
  ,td_dim.bar_m2_un
  ,td_dim.bar_m2_uf
  ,td_dim.bar_L1
  ,td_dim.bar_L1_un
  ,td_dim.bar_L1_uf
  ,td_dim.bar_L2
  ,td_dim.bar_L2_un
  ,td_dim.bar_L2_uf
  ,td_sup.sup_code as td_sup_code
  ,td_sup.sup_name as td_sup_name
  ,td_sup.order_bar as td_order_bar
  ,td_sup.order_unit as td_order_unit
  ,td_sup.order_factor as td_order_factor
  ,regexp_replace(cjx.article_no,r'^0+','') as cj_article
  ,cjx.product_name as cj_product_name
  ,cjx.product_scm_status as cj_product_status
  ,cjx.unit_code as cj_unit
  ,cjx.barcode_factor as cj_unit_factor
  ,regexp_replace(cjx.supplier_code,r'^0+','') as cj_sup_code
  ,cj_sup.source_supplier_name as cj_sup_name
  ,cj_sup.credit_term
  ,cjx.brand_name as cj_brand
  ,initcap(cjx.family_name) as cj_family
  ,initcap(cjx.category) as cj_class
  ,initcap(cjx.sub_category) as cj_sub_class
from picking as td
left join td_bar on td_bar.barcode = td.td_picking_unit
left join cjx on cjx.barcode = td.td_picking_unit
left join cj_sup on cj_sup.source_supplier_code = regexp_replace(cjx.supplier_code,r'^0+','')
left join td_sup on td_sup.article_no = td.article_no
left join td_dim on td_dim.article_no = td.article_no
--where td.article_no = '20005983'
