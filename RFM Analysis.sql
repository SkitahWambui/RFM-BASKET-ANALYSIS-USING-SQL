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

 -- selecting orders with more than one product
SELECT 
	order_id,
    COUNT(subcategory) As num_products
FROM orderdetails
GROUP BY order_id
HAVING COUNT(subcategory) >=2;

-- generate product pairs
WITH orderproducts AS (
SELECT 
	order_id,
    subcategory
FROM orderdetails
)
SELECT 
	od1.subcategory AS product1,
    od2.subcategory AS product2,
    COUNT(*) AS pair_count
FROM orderdetails od1
JOIN orderdetails od2
	ON od1.order_id = od2.order_id
	AND od1.subcategory < od2.subcategory
GROUP BY od1.subcategory, od2.subcategory
ORDER BY pair_count DESC;

-- calculate support, confidence and lift
WITH productsupport AS (
SELECT
	subcategory,
    COUNT(DISTINCT order_id) as transaction_count,
    COUNT(DISTINCT order_id) *1.0 / (SELECT
    COUNT(DISTINCT order_id) FROM orderdetails) AS support
FROM orderdetails
GROUP BY subcategory
ORDER BY support DESC
),
pairsupport AS (
SELECT 
	od1.subcategory AS product1,
    od2.subcategory AS product2,
    COUNT(DISTINCT od1.order_id) AS pairtransactioncount,
    COUNT(DISTINCT od1.order_id) *1.0 / (SELECT 
    COUNT(DISTINCT order_id) FROM orderdetails) AS pairsupport
FROM orderdetails od1
JOIN orderdetails od2
	ON od1.order_id = od2.order_id 
    AND od1.subcategory < od2.subcategory
GROUP BY od1.subcategory, od2.subcategory
)
SELECT 
	ps.product1,
    ps.product2,
    ps.pairsupport AS support12,
    ROUND(ps.pairsupport / p1.support, 2) AS confidence1to2,
    ROUND(ps.pairsupport / p2.support, 2) AS confidence2to1,
    ROUND(ps.pairsupport / (p1.support * p2.support), 2) AS lift
FROM pairsupport ps
JOIN productsupport p1 ON ps.product1 = p1.subcategory
JOIN productsupport p2 ON ps.product2 = p2.subcategory
ORDER BY lift
;