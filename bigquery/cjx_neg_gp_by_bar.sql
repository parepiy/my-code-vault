with bar as(
  select
    barcode
    ,unit
  from `cjx-data-core.cjx_dwh_assortment_prod.dim_product_barcode_v1`
  where created_d = current_date()-1
    and barcode_status = 'ACTIVE'
)
select
  article_no
  ,product_name
  ,product_status as status
  ,d.barcode
  ,d.unit
  ,unit_factor
  ,case when vat = true then 1.07 else 1 end as vat
  ,family
  ,class
  ,class_key
  ,sub_class
  ,sub_class_key
  ,retail_price_inc_vat as rsp
  ,moving_avg_cost_base_unit as moving_cost
  ,picking_unit_barcode as pick_bar
  ,b.unit as pick_unit
from `cjx-data-core.cjx_dwh_assortment_prod.dim_product_barcode_v1` d
left join bar b on b.barcode = d.picking_unit_barcode
where created_d = current_date()-1
  and product_type = 'INVENTORY'
  and segment <> 'PROMOTION'
  and barcode_status = 'ACTIVE'
  and article_no like '2%'
