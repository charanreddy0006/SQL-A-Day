-- Day 51 : Common Table Expressions (CTEs)

CREATE DATABASE company_db;

USE company_db;

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
(102,'David','IT',70000),
(103,'Emma','Finance',55000),
(104,'Robert','IT',85000),
(105,'Sophia','Finance',65000),
(106,'James','HR',45000);

--------------------------------------------------
-- Display Employees
--------------------------------------------------

SELECT * FROM employees;

--------------------------------------------------
-- Example 1 : Simple CTE
--------------------------------------------------

WITH AverageSalary AS
(
    SELECT AVG(salary) AS avg_salary
    FROM employees
)

SELECT
emp_name,
salary
FROM employees
WHERE salary >
(
    SELECT avg_salary
    FROM AverageSalary
);

--------------------------------------------------
-- Example 2 : Department Employee Count
--------------------------------------------------

WITH DepartmentSummary AS
(
    SELECT
    department,
    COUNT(*) AS total_employees,
    AVG(salary) AS average_salary
    FROM employees
    GROUP BY department
)

SELECT *
FROM DepartmentSummary;

--------------------------------------------------
-- Example 3 : Multiple CTEs
--------------------------------------------------

WITH
HighestSalary AS
(
    SELECT MAX(salary) AS highest_salary
    FROM employees
),

LowestSalary AS
(
    SELECT MIN(salary) AS lowest_salary
    FROM employees
)

SELECT
highest_salary,
lowest_salary
FROM HighestSalary,
LowestSalary;

--------------------------------------------------
-- Example 4 : Recursive CTE
--------------------------------------------------

WITH RECURSIVE Numbers AS
(
    SELECT 1 AS num

    UNION ALL

    SELECT num + 1
    FROM Numbers
    WHERE num < 5
)

SELECT *
FROM Numbers;