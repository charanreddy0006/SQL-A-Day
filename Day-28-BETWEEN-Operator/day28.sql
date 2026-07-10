-- Day 28 : BETWEEN Operator

CREATE DATABASE company_db;

USE company_db;

CREATE TABLE employees(
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    department VARCHAR(30),
    salary DECIMAL(10,2),
    age INT,
    joining_date DATE
);

INSERT INTO employees VALUES
(101,'John','HR',50000,25,'2022-01-15'),
(102,'David','IT',70000,30,'2021-06-20'),
(103,'Emma','HR',55000,28,'2023-03-10'),
(104,'Robert','IT',80000,35,'2020-09-05'),
(105,'Sophia','Finance',65000,29,'2022-11-18'),
(106,'James','Finance',60000,24,'2023-07-25');

-- Display all employees
SELECT * FROM employees;

--------------------------------------------------
-- Example 1 : Salary between 55000 and 75000
--------------------------------------------------

SELECT *
FROM employees
WHERE salary BETWEEN 55000 AND 75000;

--------------------------------------------------
-- Example 2 : Age between 25 and 30
--------------------------------------------------

SELECT *
FROM employees
WHERE age BETWEEN 25 AND 30;

--------------------------------------------------
-- Example 3 : Employees joined between 2022 and 2023
--------------------------------------------------

SELECT *
FROM employees
WHERE joining_date BETWEEN '2022-01-01' AND '2023-12-31';

--------------------------------------------------
-- Example 4 : Employee names between D and S
--------------------------------------------------

SELECT *
FROM employees
WHERE emp_name BETWEEN 'D' AND 'S';

--------------------------------------------------
-- Example 5 : Salary NOT BETWEEN 55000 and 75000
--------------------------------------------------

SELECT *
FROM employees
WHERE salary NOT BETWEEN 55000 AND 75000;