-- Day 54 : LEAD() and LAG()

CREATE DATABASE company_db;

USE company_db;

--------------------------------------------------
-- Monthly Sales Table
--------------------------------------------------

CREATE TABLE monthly_sales(
    month_no INT PRIMARY KEY,
    month_name VARCHAR(20),
    sales DECIMAL(10,2)
);

INSERT INTO monthly_sales VALUES
(1,'January',12000),
(2,'February',15000),
(3,'March',17000),
(4,'April',16000),
(5,'May',20000),
(6,'June',19000);

--------------------------------------------------
-- Display Data
--------------------------------------------------

SELECT * FROM monthly_sales;

--------------------------------------------------
-- Example 1 : LAG()
--------------------------------------------------

SELECT
month_name,
sales,
LAG(sales) OVER(
ORDER BY month_no
) AS Previous_Month_Sales
FROM monthly_sales;

--------------------------------------------------
-- Example 2 : LEAD()
--------------------------------------------------

SELECT
month_name,
sales,
LEAD(sales) OVER(
ORDER BY month_no
) AS Next_Month_Sales
FROM monthly_sales;

--------------------------------------------------
-- Example 3 : Sales Difference
--------------------------------------------------

SELECT
month_name,
sales,
sales -
LAG(sales) OVER(
ORDER BY month_no
) AS Sales_Difference
FROM monthly_sales;

--------------------------------------------------
-- Example 4 : Sales Growth
--------------------------------------------------

SELECT
month_name,
sales,
LEAD(sales) OVER(
ORDER BY month_no
) - sales AS Next_Month_Growth
FROM monthly_sales;

--------------------------------------------------
-- Example 5 : LEAD() with Default Value
--------------------------------------------------

SELECT
month_name,
sales,
LEAD(sales,1,0)
OVER(ORDER BY month_no)
AS Next_Sales
FROM monthly_sales;

--------------------------------------------------
-- Example 6 : LAG() with Default Value
--------------------------------------------------

SELECT
month_name,
sales,
LAG(sales,1,0)
OVER(ORDER BY month_no)
AS Previous_Sales
FROM monthly_sales;