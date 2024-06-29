CREATE DATABASE business_data;
USE business_data;

SELECT * FROM list_of_orders;

SELECT * FROM order_details;

SELECT * FROM sales_target;

-- CHECKING DUPLICATE VALUES IN THE DATA
SELECT `Order ID`,`Order Date`,CustomerName,State,City FROM list_of_orders
GROUP BY `Order ID`,`Order Date`,CustomerName,State,City;

SELECT `Order ID`,Amount,Profit,Quantity,Category,`Sub-Category` FROM order_details
GROUP BY `Order ID`,Amount,Profit,Quantity,Category,`Sub-Category`;

SELECT `Month of Order Date`, Category,Target FROM sales_target
GROUP BY `Month of Order Date`, Category,Target;

-- NO DUPLICATE ROWS FOUND

-- SEARCHING FOR NULL VALUES

SELECT * FROM list_of_orders
WHERE `Order ID` IS NULL OR `Order Date` IS NULL OR 
CustomerName IS NULL OR State IS NULL OR City IS NULL;

SELECT * FROM order_details
WHERE `Order ID` IS NULL OR Amount IS NULL OR Profit IS NULL OR 
Quantity IS NULL OR Category IS NULL OR `Sub-Category` IS NULL;

SELECT * FROM sales_target
WHERE `Month of Order Date` IS NULL OR 
Category IS NULL OR Target IS NULL;

-- ANALYZING DATATYPES OF COLUMNS

DESCRIBE list_of_orders;
DESCRIBE order_details;
DESCRIBE sales_target;

-- list_of_orders Table's 'ORDER DATE' data will not not join directly with sales_target Table

-- Making it easy for joining both the tables

ALTER TABLE list_of_orders
ADD COLUMN ORDER_DATE DATE AFTER `Order Date`;

SET SQL_SAFE_UPDATES = 0;
UPDATE list_of_orders
SET ORDER_DATE =  STR_TO_DATE(`Order Date`, '%d-%m-%Y');

ALTER TABLE list_of_orders
DROP `Order Date`;

ALTER TABLE list_of_orders
ADD COLUMN `Month` VARCHAR(30) AFTER ORDER_DATE;

UPDATE list_of_orders
SET `Month` = DATE_FORMAT(ORDER_DATE, '%b-%y');

SELECT * FROM list_of_orders;
SELECT * FROM order_details;
SELECT * FROM sales_target;

-- CREATING VIEWS SO THAT THE NEXT QUERY REMAINS CLEAN

CREATE VIEW JOINED_1 AS
SELECT T1.`Order ID`,`Month`,CustomerName,
State,City,Amount,Profit,Quantity,
Category,`Sub-Category` FROM list_of_orders T1
INNER JOIN order_details T2
ON T1.`Order ID` = T2.`Order ID`;

CREATE VIEW JOINED_2 AS
SELECT T1.`Order ID`,`Month`,CustomerName,State,
City,Amount,Profit,Quantity,T1.Category,`Sub-Category`,
Target FROM JOINED_1 T1
JOIN sales_target T2
ON T1.`Month` = T2.`Month of Order Date` AND T1.Category = T2.Category;

SELECT * FROM JOINED_1;

SELECT * FROM JOINED_2;

-- Solving scenario based business problems
# Sales Performance Analysis

-- 1. What is the total sales amount by month?
SELECT `Month`,SUM(Amount * Quantity) AS TOTAL_SALES 
FROM JOINED_2
GROUP BY `Month`;

-- 2. Which 5 states has the highest total profit?
SELECT State,SUM(Profit * Quantity) TOTAL_PROFIT
FROM JOINED_2
GROUP BY State ORDER BY TOTAL_PROFIT DESC LIMIT 5;

-- 3. How does the sales amount compare between different product categories?
SELECT Category,SUM(AMOUNT * Quantity) TOTAL_SALES
FROM JOINED_2
GROUP BY Category;

# Customer Analysis

-- 1. Who are the top 5 customers by total sales amount?
SELECT CustomerName,SUM(AMOUNT * Quantity) TOTAL_SALES 
FROM JOINED_2
GROUP BY CustomerName ORDER BY TOTAL_SALES DESC LIMIT 5;

-- 2. Extract top 5 customers by average profit?
SELECT CustomerName,AVG(Profit * Quantity) AVG_PROFIT
FROM JOINED_1
GROUP BY CustomerName
ORDER BY AVG_PROFIT DESC LIMIT 5;

-- 3. Which 5 states has the highest number of unique customers?
SELECT STATE, COUNT(DISTINCT CustomerName) NO_OF_CUSTOMERS 
FROM JOINED_2
GROUP BY STATE ORDER BY NO_OF_CUSTOMERS DESC LIMIT 5;

# Time Series Analysis

-- 1. How has the monthly profit changed over time?
SELECT `Month`,SUM(Profit * Quantity) TOTAL_PROFIT
FROM JOINED_2
GROUP BY `Month`;

-- 2. How do monthly sales amounts vary by product category
SELECT `Month`,Category,SUM(Amount * Quantity) SALES
FROM JOINED_2
GROUP BY `Month`,Category;

# Product Performance

-- 1. What are the top 5 sub-categories by profit?
SELECT Category, `Sub-Category`,SUM(Profit * Quantity) TOTAL_PROFIT 
FROM JOINED_2
GROUP BY Category, `Sub-Category`
ORDER BY TOTAL_PROFIT DESC LIMIT 5;

-- 2. How does the quantity sold vary by product sub-category?
SELECT Category, `Sub-Category`,SUM(Quantity) NO_OF_ITEMS
FROM JOINED_2
GROUP BY Category, `Sub-Category`
ORDER BY Category;

# Quantity Analysis

-- 1. What is the total quantity sold by product category?
SELECT Category,SUM(Quantity) TOTAL_QUANTITY
FROM JOINED_1
GROUP BY Category;

-- 2. Which TOP 3 cities have the highest quantity sold?
SELECT City,SUM(Quantity) TOTAL_QUANTITY
FROM JOINED_2
GROUP BY City ORDER BY TOTAL_QUANTITY DESC LIMIT 3;

## After observing the data i have analyzed that the data given in the target table is 10x highier than the original data
## HENCE I WILL TAKE 1/10 thOF THOSE VALUES

# Target Achievement Analysis

-- 1. What is the total sales amount vs. target by month?
SELECT `Month`,SUM(Amount * Quantity) TOTAL_SALES,
ROUND(SUM(Target)/10) TOTAL_TARGET
FROM JOINED_2
GROUP BY `Month`;

-- 2. Which product categories have the highest target achievement rate?
SELECT Category, TOTAL_SALES,TOTAL_TARGET, 
ROUND((TOTAL_SALES/TOTAL_TARGET) * 100 ,2) `ACHIVEMENT_RATE%` FROM 
	(SELECT Category,SUM(Amount * Quantity) TOTAL_SALES,ROUND(SUM(Target)/10) TOTAL_TARGET
	FROM JOINED_2 GROUP BY Category) T1;
     
select * from list_of_orders;