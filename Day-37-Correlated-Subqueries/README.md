# Day 37 - Correlated Subqueries

# Introduction

A Correlated Subquery is a subquery that depends on values from the outer query.

Unlike a normal subquery, it cannot run independently.

The inner query executes once for every row processed by the outer query.

---

# Normal Subquery

A normal subquery executes only once.

Example

```sql
SELECT *
FROM employees
WHERE salary >
(
SELECT AVG(salary)
FROM employees
);
```

The average salary is calculated once.

---

# Correlated Subquery

A correlated subquery executes repeatedly.

Example

```sql
SELECT e1.emp_name
FROM employees e1
WHERE salary >
(
SELECT AVG(e2.salary)
FROM employees e2
WHERE e1.department = e2.department
);
```

Here, the average salary is calculated separately for each department.

---

# How It Works

For each employee:

1. SQL identifies the employee's department.
2. Calculates the average salary for that department.
3. Compares the employee's salary with that average.
4. Returns employees earning above their department's average.

---

# EXISTS

The EXISTS operator checks whether the subquery returns at least one row.

If it does, EXISTS returns TRUE.

Example

```sql
SELECT department
FROM employees e1
WHERE EXISTS
(
SELECT *
FROM employees e2
WHERE e1.department=e2.department
AND salary>80000
);
```

---

# NOT EXISTS

NOT EXISTS returns TRUE only if the subquery returns no rows.

Example

```sql
SELECT department
FROM employees e1
WHERE NOT EXISTS
(
SELECT *
FROM employees e2
WHERE e1.department=e2.department
AND salary>90000
);
```

---

# Difference Between Subquery and Correlated Subquery

| Normal Subquery | Correlated Subquery |
|-----------------|---------------------|
|Runs once|Runs for every row|
|Independent|Depends on outer query|
|Usually faster|Can be slower on large tables|

---

# Real-World Applications

## Banking

Find customers whose balance is above the average balance in their branch.

---

## E-Commerce

Find products priced above the average in their category.

---

## College Management

Find students scoring above the average marks in their department.

---

## HR

Find employees earning the highest salary in each department.

---

# Common Mistakes

## Forgetting Table Aliases

Incorrect

```sql
WHERE department = department
```

Correct

```sql
WHERE e1.department = e2.department
```

---

## Using Correlated Subqueries Unnecessarily

If a normal subquery or JOIN solves the problem, use them because they are often more efficient.

---

# Practice Queries

```sql
-- Employees earning above department average
SELECT e1.emp_name
FROM employees e1
WHERE salary >
(
SELECT AVG(e2.salary)
FROM employees e2
WHERE e1.department=e2.department
);

-- Highest salary in each department
SELECT e1.*
FROM employees e1
WHERE salary =
(
SELECT MAX(e2.salary)
FROM employees e2
WHERE e1.department=e2.department
);
```

---

# Interview Questions

## What is a Correlated Subquery?

A subquery that depends on the outer query and executes once for each row.

---

## Which query executes first?

The outer query begins processing, and the inner query executes for each row.

---

## What is EXISTS?

EXISTS returns TRUE if the subquery returns one or more rows.

---

## What is NOT EXISTS?

NOT EXISTS returns TRUE if the subquery returns no rows.

---

# Summary

Today I learned:

- Correlated Subqueries
- EXISTS
- NOT EXISTS
- Department-wise comparisons
- Highest salary in each department
- Difference between Normal and Correlated Subqueries

Correlated subqueries are powerful for solving row-by-row comparison problems but should be used carefully because they may impact performance on large datasets.