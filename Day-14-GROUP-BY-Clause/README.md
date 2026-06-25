# Day 14 - GROUP BY Clause

# Introduction

The GROUP BY clause is used to group rows that have the same values in one or more columns.

It is commonly used with Aggregate Functions such as COUNT(), SUM(), AVG(), MAX(), and MIN() to generate meaningful summaries of data.

GROUP BY is one of the most important SQL clauses used in business reports, dashboards, analytics, and interview questions.

---

# What is GROUP BY?

GROUP BY groups rows that contain the same value in a specified column.

Instead of calculating values for the entire table, GROUP BY calculates values separately for each group.

---

# Why Do We Need GROUP BY?

Suppose we have the following employee table:

| Employee | Department | Salary |
| -------- | ---------- | ------ |
| John     | HR         | 50000  |
| David    | IT         | 70000  |
| Emma     | HR         | 55000  |
| Robert   | IT         | 80000  |
| Sophia   | Finance    | 65000  |
| James    | Finance    | 60000  |

If we execute:

```sql
SELECT COUNT(*)
FROM employees;
```

Output:

```text
6
```

This counts all employees.

But if we want to know:

* How many employees work in HR?
* How many employees work in IT?
* How many employees work in Finance?

We use GROUP BY.

---

# Syntax

```sql
SELECT column_name,
aggregate_function(column_name)
FROM table_name
GROUP BY column_name;
```

---

# GROUP BY with COUNT()

```sql
SELECT department,
COUNT(*) AS Total_Employees
FROM employees
GROUP BY department;
```

### Output

| Department | Total Employees |
| ---------- | --------------- |
| HR         | 2               |
| IT         | 2               |
| Finance    | 2               |

---

# GROUP BY with SUM()

```sql
SELECT department,
SUM(salary) AS Total_Salary
FROM employees
GROUP BY department;
```

### Output

| Department | Total Salary |
| ---------- | ------------ |
| HR         | 105000       |
| IT         | 150000       |
| Finance    | 125000       |

---

# GROUP BY with AVG()

```sql
SELECT department,
AVG(salary) AS Average_Salary
FROM employees
GROUP BY department;
```

This calculates the average salary for each department.

---

# GROUP BY with MAX()

```sql
SELECT department,
MAX(salary) AS Highest_Salary
FROM employees
GROUP BY department;
```

Displays the highest salary in every department.

---

# GROUP BY with MIN()

```sql
SELECT department,
MIN(salary) AS Lowest_Salary
FROM employees
GROUP BY department;
```

Displays the lowest salary in every department.

---

# Real World Applications

## Banking

Calculate the total balance for each branch.

```sql
SELECT branch_name,
SUM(balance)
FROM accounts
GROUP BY branch_name;
```

---

## E-Commerce

Find the number of products in each category.

```sql
SELECT category,
COUNT(*)
FROM products
GROUP BY category;
```

---

## College Management

Count students in each department.

```sql
SELECT branch,
COUNT(*)
FROM students
GROUP BY branch;
```

---

## Hospital Management

Count patients admitted to each department.

```sql
SELECT department,
COUNT(*)
FROM patients
GROUP BY department;
```

---

# Common Mistakes

## Using Aggregate Functions Without GROUP BY

Incorrect:

```sql
SELECT department,
COUNT(*)
FROM employees;
```

This does not produce grouped results.

---

## Selecting Non-Grouped Columns

When using GROUP BY, every selected column should either:

* Be included in the GROUP BY clause, or
* Be used inside an aggregate function.

---

# Practice Queries

```sql
SELECT department,
COUNT(*)
FROM employees
GROUP BY department;

SELECT department,
SUM(salary)
FROM employees
GROUP BY department;

SELECT department,
AVG(salary)
FROM employees
GROUP BY department;

SELECT department,
MAX(salary)
FROM employees
GROUP BY department;

SELECT department,
MIN(salary)
FROM employees
GROUP BY department;
```

---

# Interview Questions

## What is GROUP BY?

GROUP BY groups rows with the same values into a single summary group.

---

## Which SQL functions are commonly used with GROUP BY?

* COUNT()
* SUM()
* AVG()
* MAX()
* MIN()

---

## Can GROUP BY be used without Aggregate Functions?

Yes, but its primary purpose is to group rows. It is most useful when combined with aggregate functions.

---

# Summary

Today I learned:

* GROUP BY Clause
* Grouping Records
* GROUP BY with COUNT()
* GROUP BY with SUM()
* GROUP BY with AVG()
* GROUP BY with MAX()
* GROUP BY with MIN()
* Real World Applications

The GROUP BY clause is one of the most powerful SQL features for creating summaries and reports from large datasets.
