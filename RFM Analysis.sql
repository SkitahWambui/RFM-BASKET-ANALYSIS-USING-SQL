-- select the database
USE test_sales_data;
-- DATA CLEANING
-- Rename the columns
ALTER TABLE orderdetails
	RENAME COLUMN `Order ID` TO order_id,
    RENAME COLUMN `Amount` TO `amount`,
    RENAME COLUMN `Profit` TO `profit`,
    RENAME COLUMN `Quantity` TO `quantity`,
    RENAME COLUMN `Category` TO `category`,
    RENAME COLUMN `Sub-Category` TO `subcategory`,
    RENAME COLUMN `PaymentMode` TO `paymentmode`;
-- disable safe update mode
SET SQL_SAFE_UPDATES = 0;
-- change the format type of the order_date column
UPDATE orders
SET order_date = STR_TO_DATE(order_date, '%d-%m-%Y')
WHERE order_date LIKE '%-%-%';
-- change the datatype of the column 
ALTER TABLE orders
	MODIFY COLUMN order_date DATE;    

-- Customers' table
CREATE OR REPLACE VIEW rfm
AS
WITH rfm_cte AS (
SELECT 
	DISTINCT o.customer_name AS customer_name,
    MAX(o.order_date) AS last_order_date,
    (SELECT MAX(order_date) FROM orders) AS max_order_date, -- last order date for all customers
    DATEDIFF((SELECT MAX(order_date) FROM orders), MAX(order_date)) AS last_order, -- recency
    COUNT(DISTINCT o.order_id) AS total_orders, -- frequency
    SUM(od.amount) AS order_value				-- monetary
FROM orders o
LEFT JOIN orderdetails od
ON o.order_id = od.order_id
GROUP BY o.customer_name
),
rfm_calc AS (
SELECT 
	*,
    NTILE(5) OVER(ORDER BY last_order DESC) AS recency, 
    NTILE(5) OVER(ORDER BY total_orders) AS frequency,
    NTILE(5) OVER(ORDER BY order_value) AS monetary
FROM rfm_cte
) -- Create a weighted average
SELECT *,
	(0.3*recency) + (0.3*frequency) + (0.4*monetary) AS rfm_weights,
    PERCENT_RANK() OVER (ORDER BY (0.3*recency) + (0.3*frequency) + (0.4*monetary)) AS norm_rfm_score
FROM rfm_calc;
-- view our table  
SELECT * FROM rfm;

-- segmenting customers based on the RFM scores
WITH segments AS (
SELECT
	customer_name,
    last_order_date,
    order_value,
    recency,
    frequency,
    monetary, 
    rfm_weights,
    norm_rfm_score,
    CASE WHEN norm_rfm_score = 0 THEN "lost_customers"
    WHEN norm_rfm_score >= 0.8 THEN "top customers"
    WHEN norm_rfm_score >= 0.5 THEN "loyal customers"
    WHEN norm_rfm_score >= 0.2 THEN "At risk/Need attention"
    ELSE "immediate attention"
    END AS segment
FROM rfm
ORDER BY norm_rfm_score DESC
)
-- find which regions have the most at risk customers
SELECT
	r.customer_name,
    o.state,
    o.city,
    r.segment
FROM segments r
LEFT JOIN orders o
ON r.customer_name = o.customer_name;