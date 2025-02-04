SELECT  *
FROM test_sales_data.orderdetails;

-- choose the database
USE test_orders;

-- view the tables
SELECT * FROM orders;
SELECT * FROM orderdetails;

-- DATA CLEANING
-- 1. Check the datatypes and columns
SHOW FIElDS FROM orders;
SHOW FIElDS FROM orderdetails;
-- Answer: data is not stored with correct datatype

-- 1. a) Change the data types and rename columns from orders table
ALTER TABLE orders 
    CHANGE `Order ID` `order_id` VARCHAR (250),
    CHANGE `CustomerName` `customer_name` VARCHAR (250),
    CHANGE `State` `state` VARCHAR (250),
    CHANGE `City` `city` VARCHAR (250);

-- 1. b) change the 'order date' data type
ALTER TABLE orders
    ADD COLUMN order_date DATE;

UPDATE orders
    SET order_date = STR_TO_DATE(`Order Date`, '%d-%m-%Y');

ALTER TABLE orders
    DROP COLUMN `Order Date`;

-- 1 c) change the data type of ordersdetails table
ALTER TABLE orderdetails 
    CHANGE `Order ID` `order_id` VARCHAR (250),
    CHANGE `Amount` `amount` DECIMAL(10,2),
    CHANGE `Profit` `profit` DECIMAL(10,2),
    RENAME COLUMN `Quantity` TO `quantity`,
    RENAME COLUMN `Category` TO `category`,
    RENAME COLUMN `Sub-Category` TO `sub_category`,
    RENAME COLUMN `PaymentMode` TO `payment_mode`;

-- 2. a)  Check for duplicates in orders table
SELECT order_id, COUNT(order_id) AS Count FROM orders 
GROUP BY order_id HAVING COUNT(order_id) > 1;
-- Answer: There are no duplicates

-- 2. b) Check for duplicates in orderdetails table
SELECT order_id, COUNT(order_id) AS Count FROM orderdetails
GROUP BY order_id HAVING Count > 1;
-- Answer: There are duplicate order_id because orders are divided according to category and subcategory

-- 3. Check for nulls
SELECT order_id AS column_name, COUNT(*) AS null_count 
FROM orders 
WHERE order_id IS NULL
GROUP BY column_name
UNION ALL 
SELECT customer_name AS column_name, COUNT(*) AS null_count 
FROM orders 
WHERE customer_name IS NULL
GROUP BY column_name
UNION ALL
SELECT state AS column_name, COUNT(*) AS null_count 
FROM orders 
WHERE state IS NULL
GROUP BY column_name
UNION ALL
SELECT city AS column_name, COUNT(*) AS null_count 
FROM orders 
WHERE city IS NULL
GROUP BY column_name
UNION ALL
SELECT amount AS column_name, COUNT(*) AS null_count 
FROM orderdetails 
WHERE amount IS NULL
GROUP BY column_name
UNION ALL
SELECT profit AS column_name, COUNT(*) AS null_count 
FROM orderdetails 
WHERE profit IS NULL
GROUP BY column_name
UNION ALL
SELECT quantity AS column_name, COUNT(*) AS null_count 
FROM orderdetails 
WHERE quantity IS NULL
GROUP BY column_name
UNION ALL
SELECT category AS column_name, COUNT(*) AS null_count 
FROM orderdetails 
WHERE category IS NULL
GROUP BY column_name
UNION ALL
SELECT sub_category AS column_name, COUNT(*) AS null_count 
FROM orderdetails 
WHERE sub_category IS NULL
GROUP BY column_name
UNION ALL
SELECT payment_mode AS column_name, COUNT(*) AS null_count 
FROM orderdetails 
WHERE payment_mode IS NULL
GROUP BY column_name;
-- Answer: There are no nulls

-- DATA EXPLORATION
-- 1. Find the mean items per order
SELECT AVG(total_quantity) AS mean_items
FROM (
    SELECT order_id,
            SUM(quantity) AS total_quantity
    FROM orderdetails
    GROUP BY order_id
) AS order_items;
-- Answer: Each order had an average of 11.23 items

-- 2. The 3 most profitable sub categories
SELECT sub_category,
        SUM(profit) AS total_profit
FROM orderdetails
GROUP BY sub_category
ORDER BY total_profit DESC
LIMIT 3;
-- Answer: Printers, bookcases and saree were the most profitable for each category

-- 3. The 3 most profitable categories
SELECT category,
        SUM(profit) AS total_profit
FROM orderdetails
GROUP BY category
LIMIT 3;
-- Answer: Electronics, Furniture and clothing were the most profitable categories

-- 4. Highest grossing items per category
WITH ranked_categories AS(
    SELECT category,
            sub_category,
            SUM(profit) AS total_profit,
            RANK() OVER(PARTITION BY category 
            ORDER BY SUM(profit) DESC) AS ranking
    FROM orderdetails
    GROUP BY category, sub_category
)

SELECT category,
        sub_category,
        total_profit
FROM ranked_categories
WHERE ranking <= 3;
-- Answer: Each profitable subcategory: saree, printers and bookcases

-- 5. Find the number of items in sub category associated with losses, and the total losses in absolute value
SELECT category,
		COUNT(sub_category) as subcategory_count,
        SUM(profit) as net_profit
FROM orderdetails
WHERE profit < 0
GROUP BY category
ORDER BY net_profit DESC;
-- Answer: The clothing category had the highest number of items with the most losses

-- 7. Calculate the proportionate value of each item
WITH Details AS (
    SELECT 
        d.order_id, 
        d.sub_category, 
        d.amount AS ProductValue,
        SUM(d.amount) OVER (PARTITION BY d.order_id) AS TotalOrderValue
    FROM orderdetails d
)
SELECT 
    sub_category, 
    AVG(ProductValue / TotalOrderValue)  AS AvgProductContribution
FROM Details
GROUP BY sub_category
ORDER BY AvgProductContribution DESC;
-- Answer: Tables had a high proportionate value

-- 8. What is the residual value of each item?
WITH Details AS (
    SELECT 
        d.order_id, 
        d.sub_category, 
        d.amount AS ProductValue,
        SUM(d.amount) OVER (PARTITION BY d.order_id) AS TotalOrderValue
    FROM orderdetails d
),
ProductContribution AS (
    SELECT 
        sub_category, 
        AVG(ProductValue / TotalOrderValue) AS AvgProductContribution
    FROM Details
    GROUP BY sub_category
)
SELECT 
    sub_category, 
    AVG(TotalOrderValue - ProductValue) AS AvgResidualValue
FROM Details
GROUP BY sub_category
ORDER BY AvgResidualValue DESC;
-- Answer:

SELECT AVG(total_amount) as Average
FROM (
		SELECT order_id,
				SUM(amount) AS total_amount
		FROM orderdetails
        GROUP BY order_id
) AS order_items
;


