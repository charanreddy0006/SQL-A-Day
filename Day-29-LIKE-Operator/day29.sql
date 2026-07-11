-- Day 29 : LIKE Operator

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
(104,'Robert','IT',80000,35),
(105,'Sophia','Finance',65000,29),
(106,'James','Finance',60000,24),
(107,'Jack','IT',72000,27),
(108,'Jennifer','HR',58000,26);

-- Display all employees
SELECT * FROM employees;

--------------------------------------------------
-- Example 1 : Names starting with 'J'
--------------------------------------------------

SELECT *
FROM employees
WHERE emp_name LIKE 'J%';

--------------------------------------------------
-- Example 2 : Names ending with 'a'
--------------------------------------------------

SELECT *
FROM employees
WHERE emp_name LIKE '%a';

--------------------------------------------------
-- Example 3 : Names containing 'av'
--------------------------------------------------

SELECT *
FROM employees
WHERE emp_name LIKE '%av%';

--------------------------------------------------
-- Example 4 : Names having exactly 4 letters
--------------------------------------------------

SELECT *
FROM employees
WHERE emp_name LIKE '____';

--------------------------------------------------
-- Example 5 : Names starting with 'Ja'
--------------------------------------------------

SELECT *
FROM employees
WHERE emp_name LIKE 'Ja%';