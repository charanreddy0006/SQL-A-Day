-- Day 33 : IFNULL() and COALESCE()

CREATE DATABASE company_db;

USE company_db;

CREATE TABLE employees(
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    department VARCHAR(30),
    email VARCHAR(100),
    phone VARCHAR(15)
);

INSERT INTO employees VALUES
(101,'John','HR','john@gmail.com','9876543210'),
(102,'David','IT',NULL,'9876543211'),
(103,'Emma','HR','emma@gmail.com',NULL),
(104,'Robert','IT',NULL,NULL),
(105,'Sophia','Finance','sophia@gmail.com','9876543212'),
(106,'James','Finance',NULL,'9876543213');

-- Display all records
SELECT * FROM employees;

----------------------------------------------------
-- Example 1 : IFNULL()
----------------------------------------------------

SELECT
emp_name,
IFNULL(email,'Email Not Available') AS Email
FROM employees;

----------------------------------------------------
-- Example 2 : IFNULL() for Phone
----------------------------------------------------

SELECT
emp_name,
IFNULL(phone,'Phone Not Available') AS Phone
FROM employees;

----------------------------------------------------
-- Example 3 : COALESCE()
----------------------------------------------------

SELECT
emp_name,
COALESCE(email,'Email Not Available') AS Email
FROM employees;

----------------------------------------------------
-- Example 4 : COALESCE() with Multiple Values
----------------------------------------------------

SELECT
emp_name,
COALESCE(phone,email,'No Contact Information') AS Contact_Details
FROM employees;

----------------------------------------------------
-- Example 5 : IFNULL() with Department
----------------------------------------------------

SELECT
emp_name,
IFNULL(department,'Not Assigned') AS Department
FROM employees;