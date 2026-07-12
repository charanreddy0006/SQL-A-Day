-- Day 30 : SQL Wildcards

CREATE DATABASE company_db;

USE company_db;

CREATE TABLE employees(
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    department VARCHAR(30),
    salary DECIMAL(10,2)
);

INSERT INTO employees VALUES
(101,'John','HR',50000),
(102,'David','IT',70000),
(103,'Emma','HR',55000),
(104,'Robert','IT',80000),
(105,'Sophia','Finance',65000),
(106,'James','Finance',60000),
(107,'Jack','IT',72000),
(108,'Jennifer','HR',58000),
(109,'Joseph','Finance',62000),
(110,'Daniel','IT',68000);

-- Display all records
SELECT * FROM employees;

----------------------------------------------------
-- 1. Names starting with J
----------------------------------------------------

SELECT *
FROM employees
WHERE emp_name LIKE 'J%';

----------------------------------------------------
-- 2. Names ending with a
----------------------------------------------------

SELECT *
FROM employees
WHERE emp_name LIKE '%a';

----------------------------------------------------
-- 3. Names containing "en"
----------------------------------------------------

SELECT *
FROM employees
WHERE emp_name LIKE '%en%';

----------------------------------------------------
-- 4. Names having exactly 4 letters
----------------------------------------------------

SELECT *
FROM employees
WHERE emp_name LIKE '____';

----------------------------------------------------
-- 5. Names starting with Ja
----------------------------------------------------

SELECT *
FROM employees
WHERE emp_name LIKE 'Ja%';

----------------------------------------------------
-- 6. Second letter is o
----------------------------------------------------

SELECT *
FROM employees
WHERE emp_name LIKE '_o%';

----------------------------------------------------
-- 7. Names ending with er
----------------------------------------------------

SELECT *
FROM employees
WHERE emp_name LIKE '%er';

----------------------------------------------------
-- 8. Names with exactly 5 letters
----------------------------------------------------

SELECT *
FROM employees
WHERE emp_name LIKE '_____';

----------------------------------------------------
-- 9. Names starting with D
----------------------------------------------------

SELECT *
FROM employees
WHERE emp_name LIKE 'D%';

----------------------------------------------------
-- 10. Department starts with F
----------------------------------------------------

SELECT *
FROM employees
WHERE department LIKE 'F%';