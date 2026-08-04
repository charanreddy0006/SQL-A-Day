# Day 53 - Window Aggregate Functions

# Introduction

Window Aggregate Functions perform aggregate calculations while preserving every row in the result set.

Unlike GROUP BY, they do not combine rows into a single output.

---

# Why Use Window Aggregate Functions?

- Running totals
- Department statistics
- Moving averages
- Financial reports
- Business dashboards
- Data analytics

---

# Syntax

```sql
FUNCTION_NAME(column)
OVER(
PARTITION BY column
ORDER BY column
)
```

---

# SUM() OVER()

Calculates the total while keeping every row.

Example

```sql
SELECT
emp_name,
salary,
SUM(salary) OVER()
FROM employees;
```

---

# AVG() OVER()

Displays the average salary beside every employee.

```sql
AVG(salary) OVER()
```

---

# COUNT() OVER()

Counts rows without using GROUP BY.

```sql
COUNT(*) OVER()
```

---

# PARTITION BY

Calculates results separately for each group.

Example

```sql
AVG(salary)
OVER(PARTITION BY department)
```

Each department gets its own average.

---

# Running Total

```sql
SUM(salary)
OVER(
ORDER BY emp_id
)
```

Creates a cumulative total.

---

# Moving Average

```sql
AVG(salary)
OVER(
ORDER BY emp_id
ROWS BETWEEN 2 PRECEDING
AND CURRENT ROW
)
```

Calculates the average of the current row and the previous two rows.

---

# Window Aggregate Functions

| Function | Purpose |
|----------|---------|
| SUM() | Total |
| AVG() | Average |
| COUNT() | Count |
| MIN() | Minimum |
| MAX() | Maximum |

---

# GROUP BY vs Window Functions

| GROUP BY | Window Function |
|----------|-----------------|
|Combines rows|Keeps all rows|
|One row per group|One row per original row|
|Summary output|Detailed output|

---

# Advantages

- Cleaner SQL
- Advanced analytics
- Running calculations
- Department statistics
- Dashboard reporting

---

# Real-World Applications

## HR

Department salary analysis.

---

## Banking

Running account balances.

---

## Sales

Monthly revenue reports.

---

## Data Engineering

Business intelligence pipelines.

---

# Common Mistakes

## Forgetting OVER()

Every window aggregate function requires an OVER() clause.

---

## Confusing GROUP BY with OVER()

GROUP BY reduces rows.

OVER() keeps every row.

---

# Practice Queries

```sql
SELECT
emp_name,
SUM(salary) OVER()
FROM employees;

SELECT
department,
AVG(salary)
OVER(PARTITION BY department)
FROM employees;
```

---

# Interview Questions

## What is a Window Aggregate Function?

An aggregate function that performs calculations across related rows while preserving every row.

---

## Difference Between GROUP BY and Window Functions?

GROUP BY combines rows.

Window Functions keep all rows.

---

## What is a Running Total?

A cumulative sum calculated using:

```sql
SUM(column)
OVER(ORDER BY column)
```

---

## What is PARTITION BY?

It divides rows into groups before applying a window function.

---

# Summary

Today I learned:

- SUM() OVER()
- AVG() OVER()
- COUNT() OVER()
- MIN() OVER()
- MAX() OVER()
- PARTITION BY
- Running Totals
- Moving Averages

Window Aggregate Functions are essential for analytics, reporting, business intelligence, and modern SQL development.