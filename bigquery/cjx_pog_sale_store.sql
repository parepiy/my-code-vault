with pog as(
  select
    article_no
    ,max(num_store_active_assortment) as no_of_store
  from `cjx-data-core.cjx_data_mart_prod.mart_store_assortment_product`
  where as_of_date = current_date()-1
  group by 1
)

select
  sa.article_no
  ,pog.no_of_store
  ,count(distinct store_code) as sale_store
from `cjx-data-core.cjx_data_mart_prod.mart_console_sales` as sa
left join pog on pog.article_no = sa.article_no
where receipt_date between '2025-06-01' and '2025-08-31'
  and after_refund_net_sale_amount_exc_vat > 0
  --and pog.no_of_store > 0
group by 1,2
