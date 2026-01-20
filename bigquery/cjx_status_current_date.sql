WITH base AS (
  SELECT distinct
    article_no,
    dt,
    LOWER(product_status) AS status,

    LAST_VALUE(LOWER(product_status)) OVER (
      PARTITION BY article_no
      ORDER BY dt
      ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS current_status --current status together with that day status
  FROM `cjx-data-core.cjx_data_mart_prod.mart_console_dim_product`
  where dt between '2025-12-01' and '2026-01-19'
),
flag as (
  SELECT
    *,
    CASE
        WHEN LAG(status) OVER (
          PARTITION BY article_no
          ORDER BY dt
        ) != status
        OR LAG(status) OVER (
          PARTITION BY article_no
          ORDER BY dt
        ) IS NULL
        THEN 1
        ELSE 0
      END AS break_flag
  FROM base --flag if there is the difference in status
),
grp AS (
  SELECT
    *,
    SUM(break_flag) OVER (
      PARTITION BY article_no
      ORDER BY dt
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS grp_id
  FROM flag
),
current_grp AS (
  SELECT
    article_no,
    MAX(grp_id) AS grp_id
  FROM grp
  GROUP BY article_no
)
SELECT
  g.article_no,
  g.status,
  MIN(g.dt) AS status_start_date,
  DATE_DIFF(MAX(g.dt), MIN(g.dt), DAY) + 1 AS consecutive_days
FROM grp g
JOIN current_grp c
  ON g.article_no = c.article_no
 AND g.grp_id     = c.grp_id
WHERE g.article_no = '20057037'
GROUP BY g.article_no, g.status
ORDER BY g.article_no;
