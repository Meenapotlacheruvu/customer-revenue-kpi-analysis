USE sales_project;

-- KPI Summary
SELECT
  ROUND(SUM(sales),2) AS revenue,
  COUNT(DISTINCT order_id) AS orders,
  COUNT(DISTINCT customer_id) AS customers,
  ROUND(SUM(sales)/COUNT(DISTINCT order_id),2) AS avg_order_value
FROM sales_clean;

-- Repeat customer rate
WITH customer_orders AS (
  SELECT customer_id, COUNT(DISTINCT order_id) AS orders
  FROM sales_clean
  GROUP BY customer_id
)
SELECT
  COUNT(*) AS customers_total,
  SUM(CASE WHEN orders >= 2 THEN 1 ELSE 0 END) AS repeat_customers,
  ROUND(100 * SUM(CASE WHEN orders >= 2 THEN 1 ELSE 0 END)/COUNT(*),2)
  AS repeat_customer_pct
FROM customer_orders;

-- Monthly revenue
SELECT
  DATE_FORMAT(order_date,'%Y-%m') AS month,
  ROUND(SUM(sales),2) AS revenue
FROM sales_clean
GROUP BY month
ORDER BY month;

-- Best category by region
SELECT region, category, total_sales
FROM (
  SELECT
    region,
    category,
    ROUND(SUM(sales),2) AS total_sales,
    DENSE_RANK() OVER (PARTITION BY region ORDER BY SUM(sales) DESC) AS rnk
  FROM sales_clean
  GROUP BY region, category
) t
WHERE rnk = 1;

-- Shipping speed
SELECT
  ship_mode,
  ROUND(AVG(DATEDIFF(ship_date,order_date)),2) AS avg_ship_days
FROM sales_clean
WHERE order_date IS NOT NULL AND ship_date IS NOT NULL
GROUP BY ship_mode;
