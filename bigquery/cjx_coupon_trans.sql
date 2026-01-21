with dim as(
  select distinct
    article_no
    ,product_name
    ,brand
    ,segment
    ,family
    ,class
    ,sub_class
  from `cjx-data-core.cjx_data_mart_prod.mart_console_dim_product`
  where dt = current_date()-1
),
sma AS (
  SELECT
    store_code,
    DATE(start_date) AS start_date,
    DATE(end_date)   AS end_date
  FROM `tdshop-data-business-units-com.commercial_sandbox.SMA_Fair_Date`
),
st as(
  select
    barcode
    ,count(distinct store_code) as store_apply
  from `cjx-data-core.cjx_data_mart_prod.mart_console_dim_store_assortment`
  where status = 'ACTIVE'
    and store_status = 'ACTIVE'
  group by 1
),
-- ขยาย r แล้ว join กับ sma (เฉพาะช่วงที่ sales_d อยู่ใน sma) เพื่อจะได้ sma_start/sma_end ต่อแถว
r as(
  select
    c.store_code
    ,receipt_no
    ,d.segment,d.family,d.class,d.sub_class
    ,d.brand
    ,c.article_no
    ,d.product_name
    ,barcode
    ,date(effective_date) as eff_date
    ,date(expire_date) as exp_date
    ,coupon_voucher_name as coupon_name
    ,sale_qty
    ,rsp_per_unit_inc_vat as rsp
    ,total_amount_inc_vat as total_amt
    ,sales_d
    ,m.start_date  as sma_start   -- NULL ถ้าไม่มี sma
    ,m.end_date    as sma_end
    ,case when exists(
      select 1 from sma mm
      where mm.store_code = c.store_code
        and c.sales_d between mm.start_date and mm.end_date
    ) then "sma" else "other" end as sale_type
  from `cjx-data-core.cjx_dwh_sales_prod.fact_coupon_voucher_transaction_v1` as c
  left join dim d on d.article_no = c.article_no
  left join sma m
    on m.store_code = c.store_code
   and c.sales_d between m.start_date and m.end_date
  where sales_d between date_sub(date_trunc(current_date(),month),interval 3 month) and current_date()-1
    and coupon_voucher_name like 'ซื้อครบ%'
    and coupon_voucher_name like '%150%'
    and coupon_voucher_name like '%แลกซื้อ%'
),

-- 1) คำนวณ overlap_start/end และ overlap_days ต่อแถว
r_with_overlap as (
  select
    *,
    -- ถ้ามี sma_start/sma_end และมีทับซ้อนจริง จะได้ค่า start/end ของ overlap
    CASE
      WHEN sma_start IS NOT NULL
       AND sma_end IS NOT NULL
       AND least(exp_date, sma_end) >= greatest(eff_date, sma_start)
      THEN greatest(eff_date, sma_start)
      ELSE NULL
    END as overlap_start,

    CASE
      WHEN sma_start IS NOT NULL
       AND sma_end IS NOT NULL
       AND least(exp_date, sma_end) >= greatest(eff_date, sma_start)
      THEN least(exp_date, sma_end)
      ELSE NULL
    END as overlap_end,

    CASE
      WHEN sma_start IS NOT NULL
       AND sma_end IS NOT NULL
       AND least(exp_date, sma_end) >= greatest(eff_date, sma_start)
      THEN DATE_DIFF(least(exp_date, sma_end), greatest(eff_date, sma_start), DAY) + 1
      ELSE 0
    END as overlap_days
  from r
),

-- 2) Deduplicate: นับแค่ครั้งแรกสำหรับ (store_code + overlap_start + overlap_end + article_no + barcode + coupon_name)
--    ถ้าแถวซ้ำกัน (เกิดจากหลาย sales rows ที่ map ไป period เดียวกัน) จะถูกตัดเหลือ 1
unique_sma_rows as (
  select *
  from (
    select
      *,
      row_number() over (
        partition by store_code, overlap_start, overlap_end
        order by sales_d -- เลือกแถวแรก (ตาม sales_d) เป็นตัวแทน
      ) rn
    from r_with_overlap
    where overlap_start is not null -- เฉพาะกรณีมี overlap (คือเป็น sma จริงๆ)
  )
  where rn = 1
),

-- 3) Aggregate ข้อมูล unique ของ sma: รวม overlap_days ต่อระดับ article/barcode/coupon (หรือระดับอื่นตามต้องการ)
uniq_sma_agg as (
  select
    coupon_name,
    sum(overlap_days) as sma_promo_days_unique_sum,
    count(distinct store_code) as sma_unique_store_count
  from unique_sma_rows
  group by coupon_name
)

-- สุดท้าย ทำ aggregation หลักเหมือนเดิม แล้ว join เอา sma_promo_days_unique_sum เข้ามา (per article/barcode/coupon_name)
select
  eff_date,
  exp_date,
  segment,
  family,
  brand,
  r.article_no,
  product_name,
  r.barcode,
  s.store_apply,
  r.coupon_name,
  sales_d as sale_date,

  sum(case when sale_type = 'other' then r.total_amt else 0 end) as other_sale,
  sum(case when sale_type = 'sma' then total_amt else 0 end) as sma_sale,
  sum(case when sale_type = 'other' then sale_qty else 0 end) as other_qty,
  sum(case when sale_type = 'sma' then sale_qty else 0 end) as sma_qty,
  count(distinct case when sale_type = 'sma' then store_code end) as sma_store,

  -- เอาค่า sma_promo_days (ที่รวมเฉพาะ unique store+period) มาจาก agg table
  coalesce(u.sma_promo_days_unique_sum, 0) as sma_promo_days_unique

from r
left join st s on s.barcode = r.barcode
left join uniq_sma_agg u
  on u.coupon_name = r.coupon_name
--where r.eff_date = '2025-11-26'
group by eff_date, exp_date
  ,segment,family,brand
  ,article_no,product_name,r.barcode
  ,s.store_apply
  ,r.coupon_name
  ,sales_d,u.sma_promo_days_unique_sum
order by article_no, sales_d
