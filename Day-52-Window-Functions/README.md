# Day 52 - SQL Window Functions

# Introduction

Window Functions perform calculations across a set of rows related to the current row without grouping them into a single result.

Unlike GROUP BY, they preserve every row while adding calculated values.

---

# Why Use Window Functions?

- Ranking
- Running totals
- Analytics
- Dashboards
- Reports
- Performance analysis

---

# Syntax

```sql
FUNCTION_NAME() OVER(
PARTITION BY column
ORDER BY column
)
```

---

# OVER() Clause

The OVER() clause defines the window on which the function operates.

Example

```sql
ROW_NUMBER() OVER(ORDER BY salary DESC)
```

---

# ROW_NUMBER()

Assigns a unique sequential number to each row.

Example

```sql
SELECT
emp_name,
ROW_NUMBER() OVER(ORDER BY salary DESC)
FROM employees;
```

Output

|Employee|Row Number|
|---------|----------|
|Robert|1|
|David|2|
|Alice|3|

---

# RANK()

Assigns the same rank to equal values.

Ranks are skipped after ties.

Example

|Salary|Rank|
|------|----|
|85000|1|
|70000|2|
|70000|2|
|65000|4|

---

# DENSE_RANK()

Similar to RANK(), but does not skip rank numbers.

Example

|Salary|Dense Rank|
|------|-----------|
|85000|1|
|70000|2|
|70000|2|
|65000|3|

---

# PARTITION BY

Creates separate windows for each group.

Example

```sql
ROW_NUMBER() OVER(
PARTITION BY department
ORDER BY salary DESC
)
```

Each department starts ranking from 1.

---

# Running Total

```sql
SUM(salary)
OVER(ORDER BY emp_id)
```

Calculates cumulative salary totals.

---

# ROW_NUMBER vs RANK vs DENSE_RANK

| Function | Duplicate Values | Skips Rank |
|-----------|------------------|------------|
| ROW_NUMBER | No | No |
| RANK | Yes | Yes |
| DENSE_RANK | Yes | No |

---

# Advantages

- Powerful analytics
- Cleaner queries
- No complex subqueries
- Preserves rows
- Supports advanced reporting

---

# Real-World Applications

## HR

Rank employees by salary.

---

## Banking

Running account balance.

---

## E-Commerce

Top-selling products.

---

## Sports

Player rankings.

---

# Common Mistakes

## Forgetting OVER()

Every window function must include the OVER() clause.

---

## Confusing RANK and DENSE_RANK

RANK skips numbers after ties.

DENSE_RANK does not.

---

# Practice Queries

```sql
SELECT
emp_name,
ROW_NUMBER() OVER(ORDER BY salary DESC)
FROM employees;

SELECT
emp_name,
RANK() OVER(ORDER BY salary DESC)
FROM employees;
```

---

# Interview Questions

## What is a Window Function?

A function that performs calculations across related rows while keeping all rows in the result.

---

## What is OVER()?

It defines the window for the calculation.

---

## Difference between ROW_NUMBER and RANK?

ROW_NUMBER always generates unique numbers.

RANK gives the same rank to ties and skips the next rank.

---

## What is PARTITION BY?

It divides rows into groups before applying the window function.

---

# Summary

Today I learned:

- Window Functions
- OVER()
- ROW_NUMBER()
- RANK()
- DENSE_RANK()
- PARTITION BY
- Running Totals

Window Functions are widely used for ranking, analytics, dashboards, and reporting in enterprise SQL applications.