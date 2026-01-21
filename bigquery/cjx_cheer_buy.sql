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

-- tar = target / ช่วงโปรต่อ Article-Barcode
tar AS (
  SELECT
    Article,
    Barcode,
    DATE(start_date) AS start_date,
    DATE(end_date)   AS end_date,
    `Grouping` AS pro_group,
    COALESCE(Oper_store_day,0) as oper_store_day,
    COALESCE(SMA_store_day,0) as sma_store_day,
    COALESCE(SMA_Fair_Store,0) as sma_fair_store,
    COALESCE(Oper_Total_Sales, 0) 
        / (DATE_DIFF(end_date, start_date, DAY) + 1) AS oper_sale_day,
    COALESCE(SMA_Total_Sales, 0) 
        / (DATE_DIFF(end_date, start_date, DAY) + 1) AS sma_sale_day,

    COALESCE(Oper_ROS_QTY, 0)
        / (DATE_DIFF(end_date, start_date, DAY) + 1) AS oper_ros_day,

    COALESCE(SMA_ROS_QTY, 0)
        / (DATE_DIFF(end_date, start_date, DAY) + 1) AS sma_ros_day
  FROM `tdshop-data-business-units-com.commercial_sandbox.cjx_cheer_buy`
  where Article in ('20051373','20051374')
),

-- สรุปช่วงวันที่ใช้ของ tar ทีเดียว ลด scalar subquery
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
    DATE(s.receipt_date) AS receipt_date,
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
    SUM(s.after_refund_net_sale_amount_exc_vat) AS sale_ex,
    SUM(s.after_refund_total_sale_qty)          AS total_sale_qty
  FROM `cjx-data-core.cjx_data_mart_prod.mart_console_sales` s
  CROSS JOIN tar_range r
  WHERE s.receipt_date <= CURRENT_DATE() - 1
    -- ถ้า receipt_date เป็น DATE อยู่แล้ว ให้ตัด DATE() ออก (จะเร็วขึ้น)
    AND DATE(s.receipt_date) BETWEEN r.min_start_date AND r.max_end_date
    AND s.barcode IN (SELECT Barcode FROM tar)      -- ไม่ต้อง DISTINCT
  GROUP BY
    DATE(s.receipt_date),
    s.barcode,
    s.store_code,
    sale_type
),
st as(
  select
    barcode
    ,count(distinct store_code) as store_apply
  from `cjx-data-core.cjx_data_mart_prod.mart_console_dim_store_assortment`
  where status = 'ACTIVE'
    and store_status = 'ACTIVE'
  group by 1
)

-- ดึงยอดขายจริงมา match กับช่วงโปรของแต่ละแถวใน tar
SELECT
  t.Article,
  t.Barcode,
  d.product_name,
  d.segment,
  d.family,
  d.class,
  d.sub_class,
  t.start_date,
  t.end_date,
  s.store_apply,
  t.oper_sale_day,
  t.sma_sale_day,
  t.oper_ros_day,
  t.sma_ros_day,
  t.oper_store_day,
  t.sma_store_day,
  t.sma_fair_store,
  t.pro_group,
  c.receipt_date,

  -- ยอดขายจริง แยก SMA vs OPER
  SUM(CASE WHEN c.sale_type = 'sma'  THEN c.sale_ex        ELSE 0 END) AS sma_sale_ex_in_range,
  SUM(CASE WHEN c.sale_type = 'oper' THEN c.sale_ex        ELSE 0 END) AS oper_sale_ex_in_range,

  SUM(CASE WHEN c.sale_type = 'sma'  THEN c.total_sale_qty ELSE 0 END) AS sma_qty_in_range,
  SUM(CASE WHEN c.sale_type = 'oper' THEN c.total_sale_qty ELSE 0 END) AS oper_qty_in_range,

  -- จำนวนร้าน แยก SMA vs OPER (นับ distinct store ที่มีขายจริง)
  COUNT(DISTINCT CASE WHEN c.sale_type = 'sma'  THEN c.store_code END) AS sma_store_in_range,
  COUNT(DISTINCT CASE WHEN c.sale_type = 'oper' THEN c.store_code END) AS oper_store_in_range

FROM tar t
LEFT JOIN dim d
  ON d.barcode = t.barcode
LEFT JOIN cjx_sa c
  ON  c.barcode      = t.Barcode
  AND c.receipt_date BETWEEN t.start_date AND t.end_date
left join st s
  on s.barcode = t.Barcode
WHERE t.start_date <= current_date()-1
GROUP BY
  t.Article,
  t.Barcode,
  d.product_name,
  d.segment,
  d.family,
  d.class,
  d.sub_class,
  t.start_date,
  t.end_date,
  s.store_apply,
  t.oper_sale_day,
  t.sma_sale_day,
  t.oper_ros_day,
  t.sma_ros_day,
  t.oper_store_day,
  t.sma_store_day,
  t.sma_fair_store,
  t.pro_group,
  c.receipt_date
;
