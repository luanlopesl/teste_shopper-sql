SELECT
  COUNT(*) AS customers_quantity
FROM
  shopper-teste-01.shopper.customer_age ca
WHERE
  ca.age > 50