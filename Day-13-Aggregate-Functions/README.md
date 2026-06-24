# Day 13 - Aggregate Functions

# Introduction

Aggregate Functions are special SQL functions used to perform calculations on multiple rows of data and return a single result.

These functions are widely used in business reports, dashboards, analytics systems, banking applications, e-commerce platforms, and data analysis.

Aggregate functions help summarize large amounts of data quickly and efficiently.

---

# What are Aggregate Functions?

Aggregate Functions process a group of rows and return a single value.

For example:

| Employee | Salary |
| -------- | ------ |
| John     | 50000  |
| David    | 60000  |
| Emma     | 55000  |

Questions:

* How many employees exist?
* What is the total salary?
* What is the average salary?
* Which salary is highest?
* Which salary is lowest?

Aggregate functions answer these questions.

---

# COUNT() Function

COUNT() is used to count the number of records.

### Syntax

```sql
SELECT COUNT(*)
FROM table_name;
```

### Example

```sql
SELECT COUNT(*)
FROM employees;
```

### Output

```text
5
```

Meaning:

There are 5 employee records.

---

# SUM() Function

SUM() calculates the total of a numeric column.

### Syntax

```sql
SELECT SUM(column_name)
FROM table_name;
```

### Example

```sql
SELECT SUM(salary)
FROM employees;
```

### Output

```text
300000
```

Meaning:

Total salary of all employees is 300000.

---

# AVG() Function

AVG() calculates the average value.

### Syntax

```sql
SELECT AVG(column_name)
FROM table_name;
```

### Example

```sql
SELECT AVG(salary)
FROM employees;
```

### Output

```text
60000
```

Meaning:

Average employee salary is 60000.

---

# MAX() Function

MAX() returns the highest value.

### Syntax

```sql
SELECT MAX(column_name)
FROM table_name;
```

### Example

```sql
SELECT MAX(salary)
FROM employees;
```

### Output

```text
70000
```

Meaning:

Highest salary is 70000.

---

# MIN() Function

MIN() returns the smallest value.

### Syntax

```sql
SELECT MIN(column_name)
FROM table_name;
```

### Example

```sql
SELECT MIN(salary)
FROM employees;
```

### Output

```text
50000
```

Meaning:

Lowest salary is 50000.

---

# Real World Applications

## Banking

```sql
SELECT SUM(balance)
FROM accounts;
```

Calculate total money in accounts.

---

## E-Commerce

```sql
SELECT AVG(price)
FROM products;
```

Calculate average product price.

---

## College Management

```sql
SELECT COUNT(*)
FROM students;
```

Count total students.

---

## Hospital Management

```sql
SELECT MAX(age)
FROM patients;
```

Find oldest patient.

---

# Common Mistakes

## Using SUM() on Text Columns

Incorrect:

```sql
SELECT SUM(emp_name)
FROM employees;
```

SUM() works only on numeric values.

---

## Confusing COUNT(*) and COUNT(column)

```sql
SELECT COUNT(*)
FROM employees;
```

Counts all rows.

---

# Practice Queries

```sql
SELECT COUNT(*)
FROM employees;

SELECT SUM(salary)
FROM employees;

SELECT AVG(salary)
FROM employees;

SELECT MAX(salary)
FROM employees;

SELECT MIN(salary)
FROM employees;
```

---

# Interview Questions

## What are Aggregate Functions?

Functions that perform calculations on multiple rows and return a single result.

---

## Name five Aggregate Functions.

* COUNT()
* SUM()
* AVG()
* MAX()
* MIN()

---

## Which Aggregate Function counts rows?

COUNT()

---

# Summary

Today I learned:

* Aggregate Functions
* COUNT()
* SUM()
* AVG()
* MAX()
* MIN()

Aggregate functions are essential for reporting, analytics, and business intelligence applications.
