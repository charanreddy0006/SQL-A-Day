-- Day 57 : Real-World SQL Analytics with Window Functions

CREATE DATABASE analytics_db;

USE analytics_db;

--------------------------------------------------
-- Employees Table
--------------------------------------------------

CREATE TABLE employees(
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    department VARCHAR(30),
    salary DECIMAL(10,2)
);

INSERT INTO employees VALUES
(101,'John','HR',50000),
(102,'James','HR',45000),
(103,'David','IT',70000),
(104,'Robert','IT',85000),
(105,'Alice','IT',70000),
(106,'Emma','Finance',55000),
(107,'Sophia','Finance',65000),
(108,'Michael','Finance',90000);

--------------------------------------------------
-- Display Employees
--------------------------------------------------

SELECT * FROM employees;

--------------------------------------------------
-- Problem 1 :
-- Rank Employees Within Each Department
--------------------------------------------------

SELECT
    emp_id,
    emp_name,
    department,
    salary,
    RANK() OVER(
        PARTITION BY department
        ORDER BY salary DESC
    ) AS salary_rank
FROM employees;

--------------------------------------------------
-- Problem 2 :
-- Top 2 Employees in Each Department
--------------------------------------------------

WITH RankedEmployees AS
(
    SELECT
        emp_id,
        emp_name,
        department,
        salary,
        ROW_NUMBER() OVER(
            PARTITION BY department
            ORDER BY salary DESC
        ) AS row_num
    FROM employees
)

SELECT *
FROM RankedEmployees
WHERE row_num <= 2;

--------------------------------------------------
-- Problem 3 :
-- Highest-Paid Employee in Each Department
--------------------------------------------------

WITH RankedEmployees AS
(
    SELECT
        emp_id,
        emp_name,
        department,
        salary,
        ROW_NUMBER() OVER(
            PARTITION BY department
            ORDER BY salary DESC
        ) AS row_num
    FROM employees
)

SELECT
    emp_id,
    emp_name,
    department,
    salary
FROM RankedEmployees
WHERE row_num = 1;

--------------------------------------------------
-- Problem 4 :
-- Second Highest Salary in Each Department
--------------------------------------------------

WITH RankedEmployees AS
(
    SELECT
        emp_id,
        emp_name,
        department,
        salary,
        DENSE_RANK() OVER(
            PARTITION BY department
            ORDER BY salary DESC
        ) AS salary_rank
    FROM employees
)

SELECT *
FROM RankedEmployees
WHERE salary_rank = 2;

--------------------------------------------------
-- Problem 5 :
-- Department Average Salary
--------------------------------------------------

SELECT
    emp_name,
    department,
    salary,
    AVG(salary) OVER(
        PARTITION BY department
    ) AS department_average
FROM employees;

--------------------------------------------------
-- Problem 6 :
-- Difference Between Employee Salary
-- and Department Average
--------------------------------------------------

SELECT
    emp_name,
    department,
    salary,
    AVG(salary) OVER(
        PARTITION BY department
    ) AS department_average,
    salary -
    AVG(salary) OVER(
        PARTITION BY department
    ) AS salary_difference
FROM employees;

--------------------------------------------------
-- Sales Table
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
-- Problem 7 :
-- Running Sales Total
--------------------------------------------------

SELECT
    month_name,
    sales,
    SUM(sales) OVER(
        ORDER BY month_no
    ) AS running_total
FROM monthly_sales;

--------------------------------------------------
-- Problem 8 :
-- Previous Month Sales
--------------------------------------------------

SELECT
    month_name,
    sales,
    LAG(sales) OVER(
        ORDER BY month_no
    ) AS previous_month_sales
FROM monthly_sales;

--------------------------------------------------
-- Problem 9 :
-- Month-over-Month Sales Difference
--------------------------------------------------

SELECT
    month_name,
    sales,
    LAG(sales) OVER(
        ORDER BY month_no
    ) AS previous_month_sales,
    sales -
    LAG(sales) OVER(
        ORDER BY month_no
    ) AS sales_difference
FROM monthly_sales;

--------------------------------------------------
-- Problem 10 :
-- Month-over-Month Growth Percentage
--------------------------------------------------

SELECT
    month_name,
    sales,
    LAG(sales) OVER(
        ORDER BY month_no
    ) AS previous_sales,

    ROUND(
        (
            sales -
            LAG(sales) OVER(
                ORDER BY month_no
            )
        )
        /
        LAG(sales) OVER(
            ORDER BY month_no
        ) * 100,
        2
    ) AS growth_percentage

FROM monthly_sales;

--------------------------------------------------
-- Problem 11 :
-- Salary Quartiles
--------------------------------------------------

SELECT
    emp_name,
    department,
    salary,
    NTILE(4) OVER(
        ORDER BY salary DESC
    ) AS salary_quartile
FROM employees;

--------------------------------------------------
-- Problem 12 :
-- Complete Employee Analytics Report
--------------------------------------------------

SELECT
    emp_name,
    department,
    salary,

    RANK() OVER(
        PARTITION BY department
        ORDER BY salary DESC
    ) AS department_rank,

    AVG(salary) OVER(
        PARTITION BY department
    ) AS department_average,

    MAX(salary) OVER(
        PARTITION BY department
    ) AS department_maximum,

    MIN(salary) OVER(
        PARTITION BY department
    ) AS department_minimum

FROM employees;