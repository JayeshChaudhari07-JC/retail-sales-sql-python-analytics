-- Retail Sales Analytics | SQL business questions
-- Dataset: data/retail_sales_data.csv
-- Load into a table named retail_sales (adapt CSV import to your SQL dialect).

-- 1) Revenue, profit and margin by region/category
SELECT Region, Category, SUM(Sales) AS total_revenue, SUM(Profit) AS total_profit,
       ROUND(100.0 * SUM(Profit) / NULLIF(SUM(Sales), 0), 2) AS profit_margin_pct
FROM retail_sales GROUP BY Region, Category ORDER BY total_revenue DESC;

-- 2) Monthly revenue and month-over-month growth (CTE + LAG window)
WITH monthly AS (
  SELECT DATE_TRUNC('month', Order_Date) AS sales_month, SUM(Sales) AS revenue
  FROM retail_sales GROUP BY DATE_TRUNC('month', Order_Date)
), prior_month AS (
  SELECT sales_month, revenue, LAG(revenue) OVER (ORDER BY sales_month) AS previous_revenue
  FROM monthly
)
SELECT sales_month, revenue, previous_revenue,
       ROUND(100.0 * (revenue - previous_revenue) / NULLIF(previous_revenue, 0), 2) AS mom_growth_pct
FROM prior_month ORDER BY sales_month;

-- 3) Top five profitable sub-categories (ranking window)
WITH product_profit AS (
  SELECT Sub_Category, SUM(Sales) AS revenue, SUM(Profit) AS profit,
         RANK() OVER (ORDER BY SUM(Profit) DESC) AS profit_rank
  FROM retail_sales GROUP BY Sub_Category
)
SELECT Sub_Category, revenue, profit, profit_rank FROM product_profit
WHERE profit_rank <= 5 ORDER BY profit_rank;

-- 4) Loss-making sub-categories associated with high discounts
SELECT Sub_Category, AVG(Discount) AS avg_discount, SUM(Sales) AS revenue, SUM(Profit) AS total_profit,
       COUNT(*) AS orders
FROM retail_sales GROUP BY Sub_Category
HAVING SUM(Profit) < 0 AND AVG(Discount) >= 0.15
ORDER BY total_profit ASC;

-- 5) Customer value segmentation (CTE, repeat orders, profit contribution)
WITH customer_metrics AS (
  SELECT Customer_ID, COUNT(DISTINCT Order_ID) AS order_count, SUM(Sales) AS lifetime_sales,
         SUM(Profit) AS lifetime_profit, MAX(Order_Date) AS last_order_date
  FROM retail_sales GROUP BY Customer_ID
), customer_segment AS (
  SELECT *, CASE WHEN lifetime_sales >= (SELECT AVG(lifetime_sales) FROM customer_metrics)
                    AND order_count >= 3 THEN 'High-value'
                WHEN last_order_date < (SELECT MAX(Order_Date) FROM retail_sales) - INTERVAL '90 days'
                    OR lifetime_profit < 0 THEN 'At-risk'
                ELSE 'Develop' END AS segment
  FROM customer_metrics
)
SELECT segment, COUNT(*) AS customers, SUM(lifetime_sales) AS segment_sales,
       SUM(lifetime_profit) AS segment_profit
FROM customer_segment GROUP BY segment ORDER BY segment_sales DESC;

-- 6) Discount vs profitability by sub-category; supports discount policy review
SELECT Sub_Category, ROUND(AVG(Discount),3) AS avg_discount,
       ROUND(AVG(Profit),2) AS avg_order_profit, SUM(Profit) AS total_profit,
       COUNT(*) AS order_count
FROM retail_sales GROUP BY Sub_Category ORDER BY avg_discount DESC;

-- 7) Region sales contribution and rank (window)
WITH region_sales AS (SELECT Region, SUM(Sales) AS revenue FROM retail_sales GROUP BY Region)
SELECT Region, revenue, ROUND(100.0 * revenue / SUM(revenue) OVER (), 2) AS revenue_share_pct,
       RANK() OVER (ORDER BY revenue DESC) AS region_rank
FROM region_sales ORDER BY region_rank;

-- 8) Category trend compared with total monthly sales (JOIN + LAG window)
WITH category_month AS (
 SELECT DATE_TRUNC('month', Order_Date) AS sales_month, Category, SUM(Sales) AS category_revenue
 FROM retail_sales GROUP BY DATE_TRUNC('month', Order_Date), Category
), monthly_total AS (
 SELECT DATE_TRUNC('month', Order_Date) AS sales_month, SUM(Sales) AS total_revenue
 FROM retail_sales GROUP BY DATE_TRUNC('month', Order_Date)
)
SELECT cm.sales_month, cm.Category, cm.category_revenue, mt.total_revenue,
       ROUND(100.0 * cm.category_revenue / NULLIF(mt.total_revenue, 0), 2) AS category_share_pct,
       LAG(cm.category_revenue) OVER (PARTITION BY cm.Category ORDER BY cm.sales_month) AS prior_month_category_revenue
FROM category_month cm JOIN monthly_total mt ON cm.sales_month = mt.sales_month
ORDER BY cm.Category, cm.sales_month;
