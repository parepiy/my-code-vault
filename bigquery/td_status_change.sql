with dim as (
  select distinct
    article_key
    ,product_name
    ,segment, family, class, sub_class
  from `tdshop-prod.dimension.product`
  where created_d = current_date()-1
)

SELECT
  DISTINCT sta.created_d,
  dim.segment
  ,dim.family
  ,dim.class
  ,dim.sub_class
  ,sta.article_key,
  dim.product_name,
  LAG(sta.product_status, 1) OVER(PARTITION BY sta.article_key ORDER BY sta.created_d) AS status_from,
  sta.product_status AS status_to,
FROM
  `tdshop-prod.dimension.product` sta
left join dim
  on dim.article_key = sta.article_key
WHERE
  created_d BETWEEN '2024-01-01' AND CURRENT_DATE()-1
  AND sta.article_key = '20006219'
  and sta.product_type = 'INVENTORY'
QUALIFY
  status_to != status_from
order by sta.created_d desc
