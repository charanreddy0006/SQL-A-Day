# Day 56 - NTILE(), PERCENT_RANK(), and CUME_DIST()

# Introduction

NTILE(), PERCENT_RANK(), and CUME_DIST() are advanced SQL Window Functions used for ranking, percentile calculations, and grouping rows into buckets.

These functions are widely used in analytics, dashboards, reporting, and customer segmentation.

---

# NTILE()

NTILE() divides rows into a specified number of approximately equal groups.

Syntax

```sql
NTILE(number_of_groups)
OVER(
ORDER BY column
)
```

Example

```sql
SELECT
emp_name,
salary,
NTILE(4)
OVER(
ORDER BY salary DESC
)
FROM employees;
```

This divides employees into four salary quartiles.

---

# PERCENT_RANK()

Returns the relative rank of a row as a value between **0** and **1**.

Syntax

```sql
PERCENT_RANK()
OVER(
ORDER BY salary
)
```

Example Output

| Employee | Percent Rank |
|----------|--------------|
| James | 0.00 |
| John | 0.14 |
| Emma | 0.29 |
| ... | ... |

---

# CUME_DIST()

Returns the cumulative distribution of a row.

Syntax

```sql
CUME_DIST()
OVER(
ORDER BY salary
)
```

The value represents the proportion of rows with values less than or equal to the current row.

---

# PARTITION BY

These functions can also operate within groups.

Example

```sql
NTILE(2)
OVER(
PARTITION BY department
ORDER BY salary DESC
)
```

Each department is divided independently.

---

# Function Comparison

| Function | Purpose |
|----------|---------|
| NTILE() | Divide rows into groups |
| PERCENT_RANK() | Relative rank (0–1) |
| CUME_DIST() | Cumulative distribution |

---

# Advantages

- Customer segmentation
- Salary analysis
- Business reporting
- Data analytics
- Dashboard creation

---

# Real-World Applications

## HR

Group employees into salary bands.

---

## Banking

Customer credit score segmentation.

---

## Sales

Classify customers by spending.

---

## Data Engineering

Feature engineering for machine learning.

---

## Finance

Portfolio performance analysis.

---

# Common Mistakes

## Confusing PERCENT_RANK() with CUME_DIST()

- **PERCENT_RANK()** is based on rank.
- **CUME_DIST()** is based on cumulative distribution.

---

## Forgetting ORDER BY

These functions require an ORDER BY clause inside OVER().

---

# Practice Queries

```sql
SELECT
emp_name,
salary,
NTILE(4)
OVER(
ORDER BY salary DESC
)
FROM employees;

SELECT
emp_name,
salary,
PERCENT_RANK()
OVER(
ORDER BY salary
)
FROM employees;
```

---

# Interview Questions

## What is NTILE()?

It divides rows into a specified number of nearly equal groups.

---

## What is PERCENT_RANK()?

It returns the relative rank of each row between 0 and 1.

---

## What is CUME_DIST()?

It returns the cumulative distribution for each row.

---

## Where are these functions used?

Analytics, reporting, customer segmentation, dashboards, and financial analysis.

---

# Summary

Today I learned:

- NTILE()
- PERCENT_RANK()
- CUME_DIST()
- Quartiles
- Percentiles
- Customer Segmentation

These functions are essential for modern analytics, business intelligence, and advanced SQL reporting.