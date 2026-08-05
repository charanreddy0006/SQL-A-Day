# Day 54 - LEAD() and LAG()

# Introduction

LEAD() and LAG() are Window Functions used to access values from other rows without using self-joins.

They are extremely useful for trend analysis, comparisons, and time-series reporting.

---

# What is LAG()?

LAG() returns the value from a previous row.

Syntax

```sql
LAG(column)
OVER(ORDER BY column)
```

Example

```sql
SELECT
month_name,
sales,
LAG(sales)
OVER(ORDER BY month_no)
FROM monthly_sales;
```

---

# What is LEAD()?

LEAD() returns the value from the next row.

Syntax

```sql
LEAD(column)
OVER(ORDER BY column)
```

Example

```sql
SELECT
month_name,
sales,
LEAD(sales)
OVER(ORDER BY month_no)
FROM monthly_sales;
```

---

# Default Value

You can specify a default value if no previous or next row exists.

Example

```sql
LAG(sales,1,0)
```

The first row returns 0 instead of NULL.

---

# Comparing Sales

```sql
sales -
LAG(sales)
```

Calculates the difference between current and previous month.

---

# Growth Analysis

```sql
LEAD(sales)-sales
```

Shows expected growth into the next month.

---

# PARTITION BY

LEAD() and LAG() can also work separately within groups.

Example

```sql
LAG(salary)
OVER(
PARTITION BY department
ORDER BY salary
)
```

Each department has its own comparison.

---

# LEAD() vs LAG()

| LEAD() | LAG() |
|----------|--------|
| Next row | Previous row |
| Future comparison | Past comparison |
| Forecasting | Historical analysis |

---

# Advantages

- No self-joins required.
- Easy trend analysis.
- Cleaner SQL.
- Faster analytical queries.
- Useful in dashboards.

---

# Real-World Applications

## Banking

Compare daily account balances.

---

## Sales

Compare monthly sales.

---

## HR

Compare employee salaries.

---

## Stock Market

Track daily price movement.

---

## Data Engineering

Build analytical reports.

---

# Common Mistakes

## Forgetting ORDER BY

Without ORDER BY, previous and next rows are undefined.

---

## Expecting First LAG Value

The first row has no previous row, so it returns NULL unless a default value is specified.

---

# Practice Queries

```sql
SELECT
month_name,
sales,
LAG(sales)
OVER(ORDER BY month_no)
FROM monthly_sales;

SELECT
month_name,
sales,
LEAD(sales)
OVER(ORDER BY month_no)
FROM monthly_sales;
```

---

# Interview Questions

## What is LAG()?

Returns the value from a previous row.

---

## What is LEAD()?

Returns the value from the next row.

---

## Why use LEAD() and LAG()?

To compare adjacent rows without writing self-joins.

---

## Can LEAD() and LAG() use PARTITION BY?

Yes. They can compare rows within each partition.

---

# Summary

Today I learned:

- LEAD()
- LAG()
- Previous Row Comparison
- Next Row Comparison
- Sales Difference
- Growth Analysis
- PARTITION BY

LEAD() and LAG() simplify row-to-row comparisons and are essential for reporting, analytics, and trend analysis.