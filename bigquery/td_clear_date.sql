with dim as(
  select distinct
    article_no, product_name, product_status, segment
    ,family, class, sub_class, product_type, delivery_method, fresh_lite_category
  from `tdshop-prod.dimension.product`
  where created_d = current_date()-1
),

clear as(
  select
    split(code,";")[ordinal(1)] as article_no
    ,split(code,";")[ordinal(2)] as status
    ,min_clear_date
  from(
    SELECT code,
    MIN(clear_date) AS min_clear_date --b/c collect data everyday, select the minimum to get the first date the data change
    FROM (
      SELECT DISTINCT created_d,
      --article_key,
      concat(article_key,';',product_status) as code,
      CASE WHEN LOWER(product_status) like 'clear%' THEN created_d END AS clear_date
      FROM `tdshop-prod.dimension.product` 
      WHERE created_d <= CURRENT_DATE()-1
      AND article_key IN (SELECT DISTINCT article_key FROM `tdshop-prod.dimension.product`  WHERE created_d = CURRENT_DATE()-1 AND LOWER(product_status) like 'clear%' and 
      product_type = 'INVENTORY') --filter only status clear in the present
    )
    where clear_date is not null
    GROUP BY 1
))

select
  clear.article_no
  ,dim.product_name
  ,dim.product_status
  ,dim.segment
  ,dim.family
  ,dim.class
  ,dim.sub_class
  ,clear.status
  ,clear.min_clear_date
  ,dim.delivery_method
from clear
left join dim on dim.article_no = clear.article_no
