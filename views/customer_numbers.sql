WITH
  customers_birth AS (
  SELECT
    COUNT(*) AS total_customers_qty,
    COUNTIF(c.birth IS NULL) AS null_birth_qty,
    COUNTIF(c.birth IS NOT NULL) AS with_birth_qty
  FROM
    shopper-teste-01.shopper.customers c)
SELECT
  cb.total_customers_qty,
  cb.null_birth_qty,
  ROUND((cb.null_birth_qty / cb.total_customers_qty) * 100, 2) AS null_birth_percent,
  cb.with_birth_qty,
  ROUND((cb.with_birth_qty / cb.total_customers_qty) * 100, 2) AS with_birth_percent,
FROM
  customers_birth cb