WITH
  sales_by_month AS (
  SELECT
    EXTRACT(year
    FROM
      s.sales_datetime) AS year,
    EXTRACT(month
    FROM
      s.sales_datetime) AS month,
    COUNT(*) AS sales_qty
  FROM
    `shopper-teste-01.shopper.sales` s
  GROUP BY
    1,
    2
  ORDER BY
    1,
    2),
  customers_by_month AS (
  SELECT
    EXTRACT(year
    FROM
      c.created) AS year,
    EXTRACT(month
    FROM
      c.created) AS month,
    COUNT(DISTINCT(c.customer_id)) AS customer_qty
  FROM
    `shopper-teste-01.shopper.customers` c
  GROUP BY
    1,
    2
  ORDER BY
    1,
    2)
SELECT
  sbm.year,
  sbm.month,
  sbm.sales_qty,
  ROUND((sbm.sales_qty / cbm.customer_qty) * 100, 2) AS conversion_rate,
  ROUND((sbm.sales_qty / (
      SELECT
        total_customers_qty
      FROM
        shopper-teste-01.shopper.customer_numbers)) * 100, 2) AS conversion_rate_total_customers
FROM
  sales_by_month sbm
LEFT JOIN
  customers_by_month cbm
ON
  sbm.year = cbm.year
  AND sbm.month = cbm.month