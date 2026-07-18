# Day 36 - Subqueries

# Introduction

A Subquery is a query written inside another SQL query.

The inner query executes first.

Its result is passed to the outer query.

Subqueries help solve complex problems using a single SQL statement.

---

# What is a Subquery?

A subquery is also called:

- Inner Query
- Nested Query

Example

```sql
SELECT emp_name
FROM employees
WHERE salary >
(
    SELECT AVG(salary)
    FROM employees
);
```

The inner query calculates the average salary.

The outer query displays employees earning more than the average.

---

# Syntax

```sql
SELECT column_name
FROM table_name
WHERE column_name operator
(
    SELECT column_name
    FROM table_name
);
```

---

# Types of Subqueries

## 1. Single-row Subquery

Returns only one value.

Example

```sql
SELECT *
FROM employees
WHERE salary =
(
SELECT MAX(salary)
FROM employees
);
```

---

## 2. Multi-row Subquery

Returns multiple rows.

Example

```sql
SELECT *
FROM employees
WHERE department IN
(
SELECT department
FROM employees
WHERE salary>60000
);
```

---

## 3. Subquery in FROM

A subquery can also behave like a temporary table.

Example

```sql
SELECT AVG(salary)
FROM
(
SELECT salary
FROM employees
WHERE department='IT'
) AS IT_Salaries;
```

---

# Execution Order

1. SQL executes the inner query.
2. The result is passed to the outer query.
3. The outer query returns the final result.

---

# Real-World Applications

## Banking

Find customers whose balance is above the average account balance.

---

## E-Commerce

Find products that cost more than the average product price.

---

## College Management

Find students who scored above the class average.

---

## Hospital

Find doctors earning more than the average salary.

---

# Common Mistakes

## Returning Multiple Rows with =

Incorrect

```sql
WHERE department =
(
SELECT department
FROM employees
);
```

If the subquery returns multiple rows, this causes an error.

Use IN instead.

Correct

```sql
WHERE department IN
(
SELECT department
FROM employees
);
```

---

## Forgetting an Alias in FROM

Incorrect

```sql
SELECT *
FROM
(
SELECT salary
FROM employees
);
```

Correct

```sql
SELECT *
FROM
(
SELECT salary
FROM employees
) AS salaries;
```

---

# Practice Queries

```sql
-- Employees with the highest salary
SELECT emp_name
FROM employees
WHERE salary =
(
SELECT MAX(salary)
FROM employees
);

-- Employees earning above average salary
SELECT emp_name
FROM employees
WHERE salary >
(
SELECT AVG(salary)
FROM employees
);
```

---

# Interview Questions

## What is a Subquery?

A query inside another SQL query.

---

## Which query executes first?

The inner query.

---

## What is a Single-row Subquery?

A subquery that returns only one value.

---

## What is a Multi-row Subquery?

A subquery that returns multiple rows.

---

## Can a Subquery be used in the FROM clause?

Yes.

---

# Summary

Today I learned:

- Subqueries
- Single-row Subqueries
- Multi-row Subqueries
- Subqueries in WHERE
- Subqueries in FROM
- Nested Queries
- Real-World Applications

Subqueries make SQL much more powerful by allowing one query to use the result of another query.