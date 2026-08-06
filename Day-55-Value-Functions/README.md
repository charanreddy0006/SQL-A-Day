# Day 55 - FIRST_VALUE(), LAST_VALUE(), and NTH_VALUE()

# Introduction

FIRST_VALUE(), LAST_VALUE(), and NTH_VALUE() are SQL Window Functions that return values from specific positions within a window.

These functions are widely used in business reporting and analytics.

---

# FIRST_VALUE()

Returns the first value in the current window.

Syntax

```sql
FIRST_VALUE(column)
OVER(
ORDER BY column
)
```

Example

```sql
FIRST_VALUE(salary)
OVER(
PARTITION BY department
ORDER BY salary DESC
)
```

Returns the highest salary in each department.

---

# LAST_VALUE()

Returns the last value in the window.

Usually used with

```sql
ROWS BETWEEN UNBOUNDED PRECEDING
AND UNBOUNDED FOLLOWING
```

to evaluate the complete window.

Example

```sql
LAST_VALUE(salary)
OVER(
PARTITION BY department
ORDER BY salary DESC
ROWS BETWEEN UNBOUNDED PRECEDING
AND UNBOUNDED FOLLOWING
)
```

Returns the lowest salary in each department.

---

# NTH_VALUE()

Returns the value from the Nth row in the window.

Example

```sql
NTH_VALUE(salary,2)
OVER(
PARTITION BY department
ORDER BY salary DESC
ROWS BETWEEN UNBOUNDED PRECEDING
AND UNBOUNDED FOLLOWING
)
```

Returns the second highest salary.

---

# Window Frame

Window frame defines which rows are considered.

Example

```sql
ROWS BETWEEN
UNBOUNDED PRECEDING
AND UNBOUNDED FOLLOWING
```

Includes every row in the partition.

---

# PARTITION BY

Creates separate windows.

Example

```sql
PARTITION BY department
```

Each department gets its own analysis.

---

# Value Functions

| Function | Returns |
|-----------|----------|
| FIRST_VALUE() | First row value |
| LAST_VALUE() | Last row value |
| NTH_VALUE() | Nth row value |

---

# Advantages

- Powerful reporting
- Easy department analysis
- Cleaner SQL
- Useful for dashboards
- Enterprise analytics

---

# Real-World Applications

## HR

Highest-paid employee in each department.

---

## Banking

First and latest transactions.

---

## Sales

Top-selling products.

---

## Finance

Best-performing investments.

---

## Common Mistakes

### Forgetting Window Frame

LAST_VALUE() often gives unexpected results without specifying the frame.

Always use:

```sql
ROWS BETWEEN UNBOUNDED PRECEDING
AND UNBOUNDED FOLLOWING
```

when you want the last value from the full partition.

---

# Practice Queries

```sql
SELECT
emp_name,
FIRST_VALUE(salary)
OVER(
ORDER BY salary DESC
)
FROM employees;

SELECT
emp_name,
LAST_VALUE(salary)
OVER(
ORDER BY salary
ROWS BETWEEN UNBOUNDED PRECEDING
AND UNBOUNDED FOLLOWING
)
FROM employees;
```

---

# Interview Questions

## What is FIRST_VALUE()?

Returns the first value within a window.

---

## What is LAST_VALUE()?

Returns the last value within a window.

---

## What is NTH_VALUE()?

Returns the value from the Nth row in a window.

---

## Why is a window frame important for LAST_VALUE()?

Without an appropriate frame, LAST_VALUE() may only consider rows up to the current row instead of the entire partition.

---

# Summary

Today I learned:

- FIRST_VALUE()
- LAST_VALUE()
- NTH_VALUE()
- Window Frames
- PARTITION BY
- Business Reporting

These functions help generate advanced analytical reports by retrieving values from specific positions within a window.