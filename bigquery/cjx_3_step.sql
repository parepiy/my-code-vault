WITH dim AS (
  SELECT DISTINCT
    article_no,
    barcode,
    product_name,
    segment,
    family,
    class,
    sub_class
  FROM `cjx-data-core.cjx_data_mart_prod.mart_console_dim_product`
  WHERE dt = CURRENT_DATE() - 1
),
st as(
  select
    store_code
    ,store_name
  from `cjx-data-core.cjx_data_mart_prod.mart_console_dim_store`
  where dt = current_date()-1
),
tar as(
  SELECT * FROM `tdshop-data-business-units-com.commercial_sandbox.cjx_3_step`
),
tar_range AS (
  SELECT
    MIN(start_date) AS min_start_date,
    MAX(end_date)   AS max_end_date
  FROM tar
),
sma AS (
  SELECT
    store_code,
    DATE(start_date) AS start_date,
    DATE(end_date)   AS end_date
  FROM `tdshop-data-business-units-com.commercial_sandbox.SMA_Fair_Date`
),
cjx_sa AS (
  SELECT
    s.receipt_date AS receipt_date,
    s.receipt_no,
    s.barcode,
    s.store_code,
    CASE
      WHEN EXISTS (
        SELECT 1
        FROM sma m
        WHERE m.store_code = s.store_code
          AND DATE(s.receipt_date) BETWEEN m.start_date AND m.end_date
      )
      THEN 'sma'
      ELSE 'oper'
    END AS sale_type,
    SUM(s.after_refund_net_sale_amount_exc_vat) AS sale_ex
  FROM `cjx-data-core.cjx_data_mart_prod.mart_console_sales` s
  CROSS JOIN tar_range r
  WHERE s.receipt_date <= CURRENT_DATE() - 1
    -- ถ้า receipt_date เป็น DATE อยู่แล้ว ให้ตัด DATE() ออก (จะเร็วขึ้น)
    AND s.receipt_date BETWEEN r.min_start_date AND r.max_end_date
    AND s.barcode IN (SELECT barcode FROM tar)      -- ไม่ต้อง DISTINCT
  GROUP BY
    s.receipt_date,
    s.receipt_no,
    s.barcode,
    s.store_code,
    sale_type
)

select
  t.start_date
  ,t.end_date
  ,t.article_no
  ,t.barcode
  ,t.pro_group
  ,d.product_name
  ,c.receipt_date
  ,c.receipt_no
  ,c.store_code
  ,s.store_name
  ,sum(c.sale_ex) as sale_ex
from tar t
left join dim d on d.barcode = t.barcode
left join cjx_sa c on c.barcode = t.barcode
  and c.receipt_date between t.start_date and t.end_date
left join st s on s.store_code = c.store_code
WHERE t.start_date <= current_date()-1
  and c.sale_type = 'oper'
group by
  t.start_date
  ,t.end_date
  ,t.article_no
  ,t.barcode
  ,t.pro_group
  ,d.product_name
  ,c.receipt_date
  ,c.receipt_no
  ,c.store_code
  ,s.store_name




