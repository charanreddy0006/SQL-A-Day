# Day 60 - Advanced SQL Analytics Project

# Introduction

SQL Analytics is the process of using SQL queries to analyze data and extract meaningful information.

In this project, the SQL concepts learned throughout the SQL-A-Day journey are combined into a practical employee analytics project.

The project focuses on employee salary analysis, department analysis, ranking, window functions, CTEs, subqueries, conditional analysis, and business questions.

---

# Project Objective

The objective of this project is to analyze employee data and answer real-world business questions using SQL.

The project covers:

* Employee analysis
* Department analysis
* Salary analysis
* Aggregate functions
* GROUP BY
* HAVING
* Subqueries
* CTEs
* CASE expressions
* Window functions
* RANK()
* DENSE_RANK()
* ROW_NUMBER()
* LAG()
* LEAD()
* Business analytics

---

# Database Setup

```sql
CREATE DATABASE sql_analytics;

USE sql_analytics;
```

---

# Employee Table

```sql
CREATE TABLE employees(
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    department VARCHAR(30),
    salary DECIMAL(10,2),
    city VARCHAR(50),
    experience INT,
    joining_year INT
);
```

---

# Sample Data

```sql
INSERT INTO employees VALUES
(101,'John','IT',70000,'Ahmedabad',3,2023),
(102,'David','IT',85000,'Mumbai',5,2021),
(103,'Emma','HR',55000,'Surat',2,2024),
(104,'Robert','Finance',90000,'Mumbai',6,2020),
(105,'Sophia','Finance',75000,'Delhi',4,2022),
(106,'James','HR',60000,'Rajkot',3,2023),
(107,'Alice','IT',95000,'Pune',7,2019),
(108,'Michael','Finance',80000,'Mumbai',5,2021),
(109,'Daniel','IT',65000,'Ahmedabad',2,2024),
(110,'Olivia','HR',70000,'Surat',4,2022);
```

---

# View Employee Data

```sql
SELECT *
FROM employees;
```

---

# Total Number of Employees

```sql
SELECT COUNT(*) AS total_employees
FROM employees;
```

---

# Average Salary

```sql
SELECT AVG(salary) AS average_salary
FROM employees;
```

---

# Highest Salary

```sql
SELECT MAX(salary) AS highest_salary
FROM employees;
```

---

# Lowest Salary

```sql
SELECT MIN(salary) AS lowest_salary
FROM employees;
```

---

# Total Salary

```sql
SELECT SUM(salary) AS total_salary
FROM employees;
```

---

# Department-wise Employee Count

```sql
SELECT
    department,
    COUNT(*) AS employee_count
FROM employees
GROUP BY department;
```

---

# Department-wise Average Salary

```sql
SELECT
    department,
    AVG(salary) AS average_salary
FROM employees
GROUP BY department;
```

---

# Department-wise Maximum Salary

```sql
SELECT
    department,
    MAX(salary) AS highest_salary
FROM employees
GROUP BY department;
```

---

# Department-wise Minimum Salary

```sql
SELECT
    department,
    MIN(salary) AS lowest_salary
FROM employees
GROUP BY department;
```

---

# Departments with Average Salary Greater Than 70000

```sql
SELECT
    department,
    AVG(salary) AS average_salary
FROM employees
GROUP BY department
HAVING AVG(salary) > 70000;
```

---

# Employees Earning Above Average Salary

```sql
SELECT *
FROM employees
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
);
```

---

# Highest Paid Employee

```sql
SELECT *
FROM employees
WHERE salary = (
    SELECT MAX(salary)
    FROM employees
);
```

---

# Second Highest Salary

```sql
SELECT MAX(salary) AS second_highest_salary
FROM employees
WHERE salary < (
    SELECT MAX(salary)
    FROM employees
);
```

---

# Employees Ordered by Salary

```sql
SELECT
    emp_id,
    emp_name,
    department,
    salary
FROM employees
ORDER BY salary DESC;
```

---

# Ranking Employees

```sql
SELECT
    emp_name,
    department,
    salary,
    RANK() OVER (
        ORDER BY salary DESC
    ) AS salary_rank
FROM employees;
```

---

# Department-wise Ranking

```sql
SELECT
    emp_name,
    department,
    salary,
    RANK() OVER (
        PARTITION BY department
        ORDER BY salary DESC
    ) AS department_rank
FROM employees;
```

---

# ROW_NUMBER()

```sql
SELECT
    emp_name,
    department,
    salary,
    ROW_NUMBER() OVER (
        ORDER BY salary DESC
    ) AS row_number
FROM employees;
```

---

# DENSE_RANK()

```sql
SELECT
    emp_name,
    department,
    salary,
    DENSE_RANK() OVER (
        ORDER BY salary DESC
    ) AS salary_rank
FROM employees;
```

---

# Top Three Employees

```sql
SELECT *
FROM (
    SELECT
        emp_name,
        department,
        salary,
        RANK() OVER (
            ORDER BY salary DESC
        ) AS salary_rank
    FROM employees
) AS ranked_employees
WHERE salary_rank <= 3;
```

---

# Top Employee from Each Department

```sql
WITH ranked_employees AS (
    SELECT
        emp_name,
        department,
        salary,
        RANK() OVER (
            PARTITION BY department
            ORDER BY salary DESC
        ) AS department_rank
    FROM employees
)
SELECT *
FROM ranked_employees
WHERE department_rank = 1;
```

---

# Salary Difference from Department Average

```sql
SELECT
    emp_name,
    department,
    salary,
    AVG(salary) OVER (
        PARTITION BY department
    ) AS department_average,
    salary - AVG(salary) OVER (
        PARTITION BY department
    ) AS salary_difference
FROM employees;
```

---

# LAG()

```sql
SELECT
    emp_name,
    salary,
    LAG(salary) OVER (
        ORDER BY salary
    ) AS previous_salary
FROM employees;
```

---

# LEAD()

```sql
SELECT
    emp_name,
    salary,
    LEAD(salary) OVER (
        ORDER BY salary
    ) AS next_salary
FROM employees;
```

---

# Salary Difference Using LAG()

```sql
SELECT
    emp_name,
    salary,
    salary - LAG(salary) OVER (
        ORDER BY salary
    ) AS salary_difference
FROM employees;
```

---

# Department Salary Summary Using CTE

```sql
WITH department_summary AS (
    SELECT
        department,
        COUNT(*) AS employee_count,
        AVG(salary) AS average_salary,
        MAX(salary) AS highest_salary,
        MIN(salary) AS lowest_salary
    FROM employees
    GROUP BY department
)
SELECT *
FROM department_summary;
```

---

# High Salary Employees Using CTE

```sql
WITH salary_data AS (
    SELECT
        AVG(salary) AS average_salary
    FROM employees
)
SELECT
    e.emp_name,
    e.department,
    e.salary
FROM employees e
CROSS JOIN salary_data s
WHERE e.salary > s.average_salary;
```

---

# Employees by Experience

```sql
SELECT
    emp_name,
    department,
    experience,
    salary
FROM employees
ORDER BY experience DESC;
```

---

# Experienced Employees

```sql
SELECT *
FROM employees
WHERE experience >= 5;
```

---

# City-wise Employee Count

```sql
SELECT
    city,
    COUNT(*) AS employee_count
FROM employees
GROUP BY city
ORDER BY employee_count DESC;
```

---

# City-wise Average Salary

```sql
SELECT
    city,
    AVG(salary) AS average_salary
FROM employees
GROUP BY city
ORDER BY average_salary DESC;
```

---

# Conditional Salary Classification

```sql
SELECT
    emp_name,
    salary,
    CASE
        WHEN salary >= 90000 THEN 'High'
        WHEN salary >= 70000 THEN 'Medium'
        ELSE 'Low'
    END AS salary_category
FROM employees;
```

---

# Department Performance Analysis

```sql
SELECT
    department,
    COUNT(*) AS employees,
    SUM(salary) AS total_salary,
    AVG(salary) AS average_salary,
    MAX(salary) AS maximum_salary,
    MIN(salary) AS minimum_salary
FROM employees
GROUP BY department
ORDER BY average_salary DESC;
```

---

# Business Questions

## Which Department Has the Highest Average Salary?

```sql
SELECT
    department,
    AVG(salary) AS average_salary
FROM employees
GROUP BY department
ORDER BY average_salary DESC
LIMIT 1;
```

## Who Is the Highest-Paid Employee?

```sql
SELECT
    emp_name,
    department,
    salary
FROM employees
ORDER BY salary DESC
LIMIT 1;
```

## Which Employees Earn Above the Company Average?

```sql
SELECT
    emp_name,
    department,
    salary
FROM employees
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
);
```

## Which Department Has the Most Employees?

```sql
SELECT
    department,
    COUNT(*) AS employee_count
FROM employees
GROUP BY department
ORDER BY employee_count DESC
LIMIT 1;
```

---

# Project Workflow

```text
Create Database
      ↓
Create Table
      ↓
Insert Data
      ↓
Explore Data
      ↓
Perform Aggregations
      ↓
Analyze Departments
      ↓
Apply Window Functions
      ↓
Use CTEs and Subqueries
      ↓
Answer Business Questions
      ↓
Analyze Results
```

---

# Key Concepts Used

* SELECT
* WHERE
* ORDER BY
* GROUP BY
* HAVING
* Aggregate Functions
* Subqueries
* CTEs
* CASE
* RANK()
* DENSE_RANK()
* ROW_NUMBER()
* LAG()
* LEAD()
* PARTITION BY
* Window Functions
* Data Analysis

---

# Real World Applications

## E-Commerce

SQL analytics can be used to analyze:

* Product sales
* Customer purchases
* Revenue
* Top products
* Customer behavior

## Banking

SQL analytics can be used to analyze:

* Transactions
* Account balances
* Customer activity
* Loan information
* Financial performance

## Human Resources

SQL analytics can be used to analyze:

* Employee salaries
* Department performance
* Employee experience
* Hiring trends
* Employee distribution

## Healthcare

SQL analytics can be used to analyze:

* Patient records
* Appointments
* Hospital departments
* Treatment information
* Medical statistics

---

# Common Mistakes

## Using WHERE Instead of HAVING

WHERE filters rows before grouping.

HAVING filters grouped results.

## Incorrect GROUP BY

Every non-aggregated selected column should be handled correctly when using GROUP BY.

## Ignoring NULL Values

Aggregate functions can treat NULL values differently.

Always understand how NULL values affect the result.

## Overusing Subqueries

CTEs and joins can sometimes make complex queries easier to understand and maintain.

## Not Testing Queries

Always test analytical queries with realistic data.

---

# Practice Questions

1. Find the total number of employees.
2. Find the average company salary.
3. Find the highest salary.
4. Find the lowest salary.
5. Find the average salary of each department.
6. Find the department with the highest average salary.
7. Find employees earning above average salary.
8. Find the second highest salary.
9. Rank employees by salary.
10. Rank employees within each department.
11. Find the highest-paid employee from each department.
12. Find the top three employees by salary.
13. Calculate the salary difference from the department average.
14. Use LAG() to compare salaries.
15. Use LEAD() to compare salaries.
16. Create a department summary using a CTE.
17. Classify employees into salary categories.
18. Find the city with the highest employee count.
19. Find the average salary by city.
20. Analyze department performance.

---

# Interview Questions

## What is SQL Analytics?

SQL Analytics is the process of using SQL to analyze data and generate meaningful information.

## What is a Window Function?

A window function performs calculations across related rows without grouping them into a single result row.

## What is PARTITION BY?

PARTITION BY divides rows into groups for a window function.

## What is RANK()?

RANK assigns a ranking to rows and leaves gaps when values are tied.

## What is DENSE_RANK()?

DENSE_RANK assigns rankings without gaps after tied values.

## What is ROW_NUMBER()?

ROW_NUMBER assigns a unique sequential number to each row.

## What is LAG()?

LAG accesses a value from a previous row.

## What is LEAD()?

LEAD accesses a value from a following row.

## What is a CTE?

A Common Table Expression is a temporary named result set that can be referenced by a query.

## Why Use SQL Analytics?

SQL analytics helps convert raw database records into useful business information and supports data-driven decision making.

---

# Summary

Today I worked on an Advanced SQL Analytics Project.

I combined multiple SQL concepts into practical analytical queries.

The project covered:

* Data exploration
* Aggregate functions
* GROUP BY
* HAVING
* Subqueries
* CTEs
* CASE expressions
* Window functions
* RANK()
* DENSE_RANK()
* ROW_NUMBER()
* LAG()
* LEAD()
* Department analysis
* Salary analysis
* Business questions

This project helped connect individual SQL concepts with real-world data analysis.

---


