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
-- Customers' table
SELECT 
	DISTINCT o.customer_name,
    MAX(o.order_date) AS last_order_date,		-- recency
    COUNT(DISTINCT o.order_id) AS total_orders, -- frequency
    SUM(od.amount) AS order_value				-- monetary
FROM orders o
LEFT JOIN orderdetails od
ON o.order_id = od.order_id
GROUP BY o.customer_name;
-- 
