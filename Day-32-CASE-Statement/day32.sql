-- Day 32 : CASE Statement

CREATE DATABASE company_db;

USE company_db;

CREATE TABLE employees(
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    department VARCHAR(30),
    salary DECIMAL(10,2),
    age INT
);

INSERT INTO employees VALUES
(101,'John','HR',50000,25),
(102,'David','IT',70000,30),
(103,'Emma','HR',55000,28),
(104,'Robert','IT',85000,35),
(105,'Sophia','Finance',65000,29),
(106,'James','Finance',60000,24);

-- Display all records
SELECT * FROM employees;

--------------------------------------------------
-- Example 1 : Salary Category
--------------------------------------------------

SELECT
emp_name,
salary,
CASE
    WHEN salary >= 80000 THEN 'High Salary'
    WHEN salary >= 60000 THEN 'Medium Salary'
    ELSE 'Low Salary'
END AS Salary_Category
FROM employees;

--------------------------------------------------
-- Example 2 : Age Category
--------------------------------------------------

SELECT
emp_name,
age,
CASE
    WHEN age < 25 THEN 'Young'
    WHEN age BETWEEN 25 AND 30 THEN 'Adult'
    ELSE 'Senior'
END AS Age_Category
FROM employees;

--------------------------------------------------
-- Example 3 : Department Description
--------------------------------------------------

SELECT
emp_name,
department,
CASE
    WHEN department='HR' THEN 'Human Resources'
    WHEN department='IT' THEN 'Information Technology'
    WHEN department='Finance' THEN 'Finance Department'
    ELSE 'Other Department'
END AS Department_Name
FROM employees;

--------------------------------------------------
-- Example 4 : CASE in ORDER BY
--------------------------------------------------

SELECT *
FROM employees
ORDER BY
CASE
    WHEN department='IT' THEN 1
    WHEN department='Finance' THEN 2
    WHEN department='HR' THEN 3
END;