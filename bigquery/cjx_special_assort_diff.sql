select
  store_code, store_name, store_status
  ,article_no, product_name
  ,as_of_date
  ,lag(assortment_type,1) over(partition by store_code,article_no order by as_of_date) as type_from
  ,assortment_type as type_to
from `cjx-data-core.cjx_data_mart_prod.mart_store_assortment_store`
where as_of_date between '2025-10-01' and '2025-11-30'
  and article_no in ('20051515','20051516','20053148')
  and store_code in ('CJX00005'/*,'CJX00009','CJX00014','CJX00020','CJX00035','CJX00054','CJX00060'*/)
qualify type_from != type_to
order by 1,4,6 desc
