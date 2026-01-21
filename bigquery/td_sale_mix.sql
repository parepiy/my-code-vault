with art as(
  select
    article_no
    ,sum(net_amount_incl_vat) as art_sale
  from `tdshop-bi.bi_mart.bi_sales_receipt`
  where receipt_date between date_trunc(date_sub(current_date(), interval 3 month),month) and current_date()-1
  group by 1
),
bar as(
  select
    barcode
    ,article_no
    ,sum(net_amount_incl_vat) as bar_sale
  from `tdshop-bi.bi_mart.bi_sales_receipt`
  where receipt_date between date_trunc(date_sub(current_date(), interval 3 month),month) and current_date()-1
  group by barcode,article_no
  order by 1
)

select
  barcode
  ,b.article_no
  ,bar_sale
  ,art_sale
  ,(bar_sale/art_sale)*100 as mix
from bar b
left join art a on a.article_no = b.article_no
--where b.article_no = '20000014002'
