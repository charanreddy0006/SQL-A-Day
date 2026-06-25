# Day 15 - HAVING Clause

# Introduction

The HAVING clause is used to filter grouped data after the GROUP BY clause has been applied.

While the WHERE clause filters individual rows before grouping, the HAVING clause filters groups after aggregate functions such as COUNT(), SUM(), AVG(), MAX(), and MIN() have been calculated.

The HAVING clause is commonly used in reports, dashboards, and business analytics where grouped results need to be filtered.

---

# What is HAVING?

HAVING filters grouped records.

It works with GROUP BY and aggregate functions.

### Syntax

```sql
SELECT column_name,
aggregate_function(column_name)
FROM table_name
GROUP BY column_name
HAVING condition;
```

---

# Why Do We Need HAVING?

Consider the employee table:

| Employee | Department | Salary |
| -------- | ---------- | ------ |
| John     | HR         | 50000  |
| David    | IT         | 70000  |
| Emma     | HR         | 55000  |
| Robert   | IT         | 80000  |
| Sophia   | Finance    | 65000  |
| James    | Finance    | 60000  |

Suppose we want to display only departments having more than one employee.

Using only GROUP BY gives:

```sql
SELECT department,
COUNT(*)
FROM employees
GROUP BY department;
```

This displays all departments.

To filter grouped results, we use HAVING.

```sql
SELECT department,
COUNT(*)
FROM employees
GROUP BY department
HAVING COUNT(*) > 1;
```

---

# GROUP BY vs HAVING

GROUP BY creates groups.

HAVING filters those groups.

Think of the process like this:

Rows → GROUP BY → Groups → HAVING → Final Result

---

# HAVING with COUNT()

```sql
SELECT department,
COUNT(*) AS Total_Employees
FROM employees
GROUP BY department
HAVING COUNT(*) > 1;
```

This displays only departments that have more than one employee.

---

# HAVING with SUM()

```sql
SELECT department,
SUM(salary) AS Total_Salary
FROM employees
GROUP BY department
HAVING SUM(salary) > 120000;
```

Displays departments whose total salary is greater than 120000.

---

# HAVING with AVG()

```sql
SELECT department,
AVG(salary) AS Average_Salary
FROM employees
GROUP BY department
HAVING AVG(salary) > 60000;
```

Displays departments whose average salary is greater than 60000.

---

# WHERE vs HAVING

| WHERE                                   | HAVING                                 |
| --------------------------------------- | -------------------------------------- |
| Filters individual rows                 | Filters groups                         |
| Executed before GROUP BY                | Executed after GROUP BY                |
| Cannot use aggregate functions directly | Commonly used with aggregate functions |

Example:

```sql
SELECT *
FROM employees
WHERE salary > 60000;
```

Filters employee rows.

Example:

```sql
SELECT department,
AVG(salary)
FROM employees
GROUP BY department
HAVING AVG(salary) > 60000;
```

Filters departments based on average salary.

---

# Real World Applications

## Banking

Display branches having more than 1000 customers.

```sql
SELECT branch_name,
COUNT(*)
FROM accounts
GROUP BY branch_name
HAVING COUNT(*) > 1000;
```

---

## E-Commerce

Display categories with total sales greater than ₹1,00,000.

```sql
SELECT category,
SUM(price)
FROM products
GROUP BY category
HAVING SUM(price) > 100000;
```

---

## College Management

Display branches having more than 50 students.

```sql
SELECT branch,
COUNT(*)
FROM students
GROUP BY branch
HAVING COUNT(*) > 50;
```

---

## Hospital Management

Display departments treating more than 20 patients.

```sql
SELECT department,
COUNT(*)
FROM patients
GROUP BY department
HAVING COUNT(*) > 20;
```

---

# Common Mistakes

## Using HAVING Without GROUP BY

HAVING is primarily designed to filter grouped data. In most learning scenarios, use it together with GROUP BY.

---

## Confusing WHERE and HAVING

Remember:

* WHERE filters rows.
* HAVING filters groups.

---

# Practice Queries

```sql
SELECT department,
COUNT(*)
FROM employees
GROUP BY department
HAVING COUNT(*) > 1;

SELECT department,
SUM(salary)
FROM employees
GROUP BY department
HAVING SUM(salary) > 120000;

SELECT department,
AVG(salary)
FROM employees
GROUP BY department
HAVING AVG(salary) > 60000;
```

---

# Interview Questions

## What is HAVING?

HAVING is used to filter grouped data after the GROUP BY clause.

---

## What is the difference between WHERE and HAVING?

WHERE filters rows before grouping.

HAVING filters groups after grouping.

---

## Can HAVING be used with aggregate functions?

Yes. HAVING is commonly used with COUNT(), SUM(), AVG(), MAX(), and MIN().

---

# Summary

Today I learned:

* HAVING Clause
* GROUP BY + HAVING
* HAVING with COUNT()
* HAVING with SUM()
* HAVING with AVG()
* Difference between WHERE and HAVING
* Real-world Applications

The HAVING clause is an important SQL feature for filtering summarized data and is widely used in reports, dashboards, and interview questions.
