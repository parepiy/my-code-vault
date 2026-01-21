select
  *
from(
  select distinct
    row_number() over (partition by td_article_no order by cj_ingested_time desc) as row_num
    ,*
  from `tdshop-prod.publish_inventory.tdsc_dc_stock`
  where created_d = current_date()-1
    and td_article_no is not null
  order by td_article_no, cj_ingested_time desc
  limit 100
)
where row_num = 1
