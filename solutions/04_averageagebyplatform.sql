WITH
  customer_sales AS (
  SELECT
    s.*,
    ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.sales_datetime) AS sales_number,
    ca.age
  FROM
    `shopper-teste-01.shopper.sales` s
  JOIN
    `shopper-teste-01.shopper.customer_age` ca
  ON
    s.customer_id = ca.customer_id
  ORDER BY
    s.customer_id)
SELECT
  DISTINCT(cs.platform),
  CAST(AVG(cs.age) AS INT64) AS average_customer_age
FROM
  customer_sales cs
WHERE
  sales_number = 1
GROUP BY
  1