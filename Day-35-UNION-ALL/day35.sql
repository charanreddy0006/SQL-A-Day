-- Day 35 : UNION ALL

CREATE DATABASE company_db;

USE company_db;

--------------------------------------------------
-- Current Employees Table
--------------------------------------------------

CREATE TABLE current_employees(
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    department VARCHAR(30)
);

INSERT INTO current_employees VALUES
(101,'John','HR'),
(102,'David','IT'),
(103,'Emma','Finance'),
(104,'Robert','IT');

--------------------------------------------------
-- Former Employees Table
--------------------------------------------------

CREATE TABLE former_employees(
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    department VARCHAR(30)
);

INSERT INTO former_employees VALUES
(103,'Emma','Finance'),
(105,'Sophia','Finance'),
(106,'James','HR'),
(107,'Daniel','IT');

--------------------------------------------------
-- Display Tables
--------------------------------------------------

SELECT * FROM current_employees;

SELECT * FROM former_employees;

--------------------------------------------------
-- Example 1 : UNION ALL
--------------------------------------------------

SELECT emp_id, emp_name, department
FROM current_employees

UNION ALL

SELECT emp_id, emp_name, department
FROM former_employees;

--------------------------------------------------
-- Example 2 : UNION ALL with ORDER BY
--------------------------------------------------

SELECT emp_id, emp_name, department
FROM current_employees

UNION ALL

SELECT emp_id, emp_name, department
FROM former_employees

ORDER BY emp_name;

--------------------------------------------------
-- Example 3 : Compare UNION and UNION ALL
--------------------------------------------------

-- UNION
SELECT emp_name
FROM current_employees

UNION

SELECT emp_name
FROM former_employees;

-- UNION ALL
SELECT emp_name
FROM current_employees

UNION ALL

SELECT emp_name
FROM former_employees;