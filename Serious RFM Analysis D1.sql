SELECT * FROM test_sales_data.orderdetails;
USE test_sales_data;
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
SELECT 
	DISTINCT o.customer_name,
    MAX(o.order_date) AS last_order_date,
    (SELECT MAX(order_date) FROM orders) AS max_order_date, -- last order date for all customers
    DATEDIFF((SELECT MAX(order_date) FROM orders), MAX(order_date)) AS recency, -- recency
    COUNT(DISTINCT o.order_id) AS total_orders, -- frequency
    SUM(od.amount) AS order_value				-- monetary
FROM orders o
LEFT JOIN orderdetails od
ON o.order_id = od.order_id
GROUP BY o.customer_name;
-- 
