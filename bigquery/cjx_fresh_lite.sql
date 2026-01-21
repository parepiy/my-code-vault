#cost by sup by article
-- 1) ดึงราคาจาก fre เฉพาะคอลัมน์ที่ใช้ และกรองให้แคบตั้งแต่ต้น
WITH fre_raw AS (
  SELECT
    article_no,
    order_barcode,
    order_unit,
    base_qty,
    order_from_code AS sup_code,
    order_from_name AS sup_name,
    unit_price_amount,
    CAST(valid_from AS DATE) AS eff_date,
    CAST(valid_to   AS DATE) AS exp_date
  FROM `cjx-data-core.cjx_ods_prod.nest__article_store_price_config`
  WHERE article_no LIKE '2%'
    -- ถ้าต้องการเฉพาะราคาที่มีผล "วันนี้" จะช่วยลดแถวได้มาก
    -- AND DATE(valid_from) <= CURRENT_DATE()-1
    AND DATE(valid_to) > CURRENT_DATE()-1
),

-- 2) สร้างกุญแจเฉพาะ article_no ที่มีใน fre (ช่วยให้ฝั่ง dim เล็กลง)
keys AS (
  SELECT DISTINCT article_no FROM fre_raw
),

-- 3) สรุปราคาใน fre ให้เหลือ 1 แถวต่อคอมโบที่ต้องการโชว์
--    (ถ้าเอา "ราคา max" ต่อคอมโบ ให้ aggregate ตรงนี้)
fre AS (
  SELECT
    article_no,
    order_barcode,
    order_unit,
    base_qty,
    sup_code,
    sup_name,
    MAX(unit_price_amount) AS sup_price,   -- 👈 รวมที่นี่
    eff_date,
    exp_date
  FROM fre_raw
  GROUP BY
    article_no, order_barcode, order_unit, base_qty,
    sup_code, sup_name, eff_date, exp_date
),

-- 4) dim: เลือกคอลัมน์เท่าที่ใช้ + บีบเหลือ 1 แถว/ article_no
dim AS (
  SELECT
    d.article_no,
    ANY_VALUE(d.product_name)   AS product_name,
    ANY_VALUE(d.product_status) AS product_status,
    ANY_VALUE(d.brand)          AS brand,
    ANY_VALUE(d.family)         AS family,
    ANY_VALUE(d.class)          AS class
  FROM `cjx-data-core.cjx_data_mart_prod.mart_console_dim_product` d
  JOIN keys k USING (article_no)                  -- 👈 กรองด้วยกุญแจก่อน
  WHERE d.dt = CURRENT_DATE()-1
    AND d.barcode_status = 'ACTIVE'
    AND d.unit_factor = 1
    AND d.fresh_lite_category IS TRUE
  GROUP BY d.article_no
)

-- 5) join จริง: ไม่ต้อง GROUP BY ซ้ำ
SELECT
  d.article_no,
  d.product_name,
  d.product_status,
  d.brand,
  d.family,
  d.class,
  f.order_barcode,
  f.order_unit,
  f.base_qty,
  f.sup_code,
  f.sup_name,
  f.sup_price,       -- ได้ราคาที่ MAX มาแล้ว
  f.eff_date,
  f.exp_date
FROM dim d
LEFT JOIN fre f USING (article_no);
-- ถ้าจะดูตัวอย่างค่อยใส่ LIMIT 10 ที่ท้ายสุด


#store count per article
-- 1) ดึงราคาจาก fre เฉพาะคอลัมน์ที่ใช้ และกรองให้แคบตั้งแต่ต้น
WITH fre_raw AS (
  SELECT
    article_no,
    ship_to_code
  FROM `cjx-data-core.cjx_ods_prod.nest__article_store_price_config`
  WHERE article_no LIKE '2%'
    -- ถ้าต้องการเฉพาะราคาที่มีผล "วันนี้" จะช่วยลดแถวได้มาก
    -- AND DATE(valid_from) <= CURRENT_DATE()-1
    AND DATE(valid_to) > CURRENT_DATE()-1
),

-- 2) สร้างกุญแจเฉพาะ article_no ที่มีใน fre (ช่วยให้ฝั่ง dim เล็กลง)
keys AS (
  SELECT DISTINCT article_no FROM fre_raw
),

-- 3) สรุปราคาใน fre ให้เหลือ 1 แถวต่อคอมโบที่ต้องการโชว์
--    (ถ้าเอา "ราคา max" ต่อคอมโบ ให้ aggregate ตรงนี้)
fre AS (
  SELECT
    article_no,
    count(distinct ship_to_code) as store
  FROM fre_raw
  GROUP BY
    article_no
),

-- 4) dim: เลือกคอลัมน์เท่าที่ใช้ + บีบเหลือ 1 แถว/ article_no
dim AS (
  SELECT
    d.article_no,
    ANY_VALUE(d.product_name)   AS product_name,
    ANY_VALUE(d.product_status) AS product_status,
    ANY_VALUE(d.brand)          AS brand,
    ANY_VALUE(d.family)         AS family,
    ANY_VALUE(d.class)          AS class
  FROM `cjx-data-core.cjx_data_mart_prod.mart_console_dim_product` d
  JOIN keys k USING (article_no)                  -- 👈 กรองด้วยกุญแจก่อน
  WHERE d.dt = CURRENT_DATE()-1
    AND d.barcode_status = 'ACTIVE'
    AND d.unit_factor = 1
    AND d.fresh_lite_category IS TRUE
  GROUP BY d.article_no
)

-- 5) join จริง: ไม่ต้อง GROUP BY ซ้ำ
SELECT
  d.article_no,
  d.product_name,
  d.product_status,
  d.brand,
  d.family,
  d.class,
  f.store
FROM dim d
LEFT JOIN fre f USING (article_no);
-- ถ้าจะดูตัวอย่างค่อยใส่ LIMIT 10 ที่ท้ายสุด

