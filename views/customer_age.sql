SELECT
    c.customer_id,
    DATE_DIFF(current_date, c.birth, year) AS age
  FROM
    shopper-teste-01.shopper.customers c
  WHERE
    c.birth IS NOT NULL