# Day 57 - Real-World SQL Analytics with Window Functions

## Introduction

Day 57 focuses on applying advanced SQL Window Functions to real-world analytical problems.

Instead of learning individual functions separately, this lesson combines:

- CTEs
- ROW_NUMBER()
- RANK()
- DENSE_RANK()
- AVG() OVER()
- SUM() OVER()
- LAG()
- NTILE()
- PARTITION BY
- ORDER BY

These techniques are commonly used in Data Engineering, Business Intelligence, reporting, and SQL interviews.

---

# 1. Rank Employees Within Each Department

We can rank employees separately within every department.

```sql
SELECT
    emp_name,
    department,
    salary,
    RANK() OVER(
        PARTITION BY department
        ORDER BY salary DESC
    ) AS salary_rank
FROM employees;
```

`PARTITION BY department` creates a separate ranking for every department.

---

# 2. Find Top 2 Employees in Each Department

This is a very common SQL interview problem.

```sql
WITH RankedEmployees AS
(
    SELECT
        emp_name,
        department,
        salary,
        ROW_NUMBER() OVER(
            PARTITION BY department
            ORDER BY salary DESC
        ) AS row_num
    FROM employees
)

SELECT *
FROM RankedEmployees
WHERE row_num <= 2;
```

The CTE first creates the ranking.

The outer query then selects only the first two employees from each department.

---

# 3. Find Highest-Paid Employee in Each Department

```sql
WITH RankedEmployees AS
(
    SELECT
        emp_name,
        department,
        salary,
        ROW_NUMBER() OVER(
            PARTITION BY department
            ORDER BY salary DESC
        ) AS row_num
    FROM employees
)

SELECT *
FROM RankedEmployees
WHERE row_num = 1;
```

---

# 4. Find Second-Highest Salary in Each Department

```sql
WITH RankedEmployees AS
(
    SELECT
        emp_name,
        department,
        salary,
        DENSE_RANK() OVER(
            PARTITION BY department
            ORDER BY salary DESC
        ) AS salary_rank
    FROM employees
)

SELECT *
FROM RankedEmployees
WHERE salary_rank = 2;
```

`DENSE_RANK()` is useful when employees can have the same salary.

---

# 5. Department Average Salary

```sql
SELECT
    emp_name,
    department,
    salary,
    AVG(salary) OVER(
        PARTITION BY department
    ) AS department_average
FROM employees;
```

Unlike `GROUP BY`, the original employee rows are preserved.

---

# 6. Salary Difference from Department Average

```sql
SELECT
    emp_name,
    department,
    salary,
    salary -
    AVG(salary) OVER(
        PARTITION BY department
    ) AS salary_difference
FROM employees;
```

A positive value means the employee earns above the department average.

A negative value means the employee earns below the department average.

---

# 7. Running Sales Total

```sql
SELECT
    month_name,
    sales,
    SUM(sales) OVER(
        ORDER BY month_no
    ) AS running_total
FROM monthly_sales;
```

A running total keeps adding the current month's sales to all previous sales.

---

# 8. Previous Month Sales

```sql
SELECT
    month_name,
    sales,
    LAG(sales) OVER(
        ORDER BY month_no
    ) AS previous_month_sales
FROM monthly_sales;
```

`LAG()` retrieves the previous row.

---

# 9. Month-over-Month Difference

```sql
SELECT
    month_name,
    sales,
    sales -
    LAG(sales) OVER(
        ORDER BY month_no
    ) AS sales_difference
FROM monthly_sales;
```

This tells us whether sales increased or decreased compared with the previous month.

---

# 10. Month-over-Month Growth Percentage

```sql
(
    current_sales - previous_sales
)
/
previous_sales * 100
```

This is useful for business performance analysis.

---

# 11. Salary Quartiles

```sql
SELECT
    emp_name,
    salary,
    NTILE(4) OVER(
        ORDER BY salary DESC
    ) AS salary_quartile
FROM employees;
```

`NTILE(4)` divides employees into four approximately equal groups.

---

# 12. Complete Employee Analytics Report

We can combine multiple Window Functions into a single report.

```sql
SELECT
    emp_name,
    department,
    salary,

    RANK() OVER(
        PARTITION BY department
        ORDER BY salary DESC
    ) AS department_rank,

    AVG(salary) OVER(
        PARTITION BY department
    ) AS department_average,

    MAX(salary) OVER(
        PARTITION BY department
    ) AS department_maximum,

    MIN(salary) OVER(
        PARTITION BY department
    ) AS department_minimum

FROM employees;
```

This produces a complete department-level salary analysis.

---

# Important SQL Pattern

A very important pattern for advanced SQL is:

```text
WITH CTE
   ↓
Window Function
   ↓
Rank / Calculate
   ↓
Filter Results
```

Example:

```sql
WITH RankedData AS
(
    SELECT
        *,
        ROW_NUMBER() OVER(
            PARTITION BY department
            ORDER BY salary DESC
        ) AS rn
    FROM employees
)

SELECT *
FROM RankedData
WHERE rn <= 3;
```

---

# ROW_NUMBER vs RANK vs DENSE_RANK

| Function | Handles Ties | Skips Rank |
|----------|--------------|------------|
| ROW_NUMBER() | No | No |
| RANK() | Yes | Yes |
| DENSE_RANK() | Yes | No |

---

# Real-World Applications

## HR Analytics

- Top employees
- Salary rankings
- Department comparisons

## Sales Analytics

- Monthly sales growth
- Running revenue
- Top products

## Banking

- Transaction trends
- Customer rankings
- Account balances

## E-Commerce

- Top customers
- Product rankings
- Sales performance

## Data Engineering

- Analytical transformations
- ETL pipelines
- Data warehouse reporting

---

# Interview Questions

## 1. How do you find the top 3 employees in each department?

Use `ROW_NUMBER()` or `RANK()` with `PARTITION BY`.

---

## 2. How do you find the second-highest salary in each department?

Use `DENSE_RANK()` and filter for rank 2.

---

## 3. How do you calculate a running total?

Use:

```sql
SUM(column)
OVER(ORDER BY column)
```

---

## 4. How do you compare the current row with the previous row?

Use:

```sql
LAG()
```

---

## 5. How do you calculate department average without GROUP BY?

Use:

```sql
AVG(salary)
OVER(PARTITION BY department)
```

---

## 6. Why combine CTEs with Window Functions?

CTEs make it easy to calculate rankings first and filter those rankings in an outer query.

---

# Summary

Today I learned how to solve practical SQL analytics problems using:

- CTEs
- ROW_NUMBER()
- RANK()
- DENSE_RANK()
- SUM() OVER()
- AVG() OVER()
- LAG()
- NTILE()
- PARTITION BY
- ORDER BY

The key goal is not just knowing SQL functions, but knowing **when to use each function to solve a real business problem**.

---

# Key Takeaway

```text
Simple SQL
    ↓
JOINs
    ↓
Subqueries
    ↓
CTEs
    ↓
Window Functions
    ↓
Advanced Analytics
    ↓
Real-World Data Engineering
```