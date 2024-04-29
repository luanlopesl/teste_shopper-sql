SELECT
  si.product_name,
  COUNT(si.product_id) AS sales_qty
FROM
  `shopper-teste-01.shopper.sales_items` si
GROUP BY
  si.product_name
ORDER BY
  2 DESC
LIMIT
  5