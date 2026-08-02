# Day 51 - Common Table Expressions (CTEs)

# Introduction

A Common Table Expression (CTE) is a temporary named result set created using the `WITH` clause.

A CTE exists only for the duration of a single SQL statement.

CTEs make complex queries easier to read, write, and maintain.

---

# Why Use CTEs?

- Improve query readability.
- Break complex queries into smaller parts.
- Reuse intermediate query results.
- Support recursive queries.
- Easier debugging.

---

# Syntax

## Simple CTE

```sql
WITH cte_name AS
(
    SELECT ...
)

SELECT *
FROM cte_name;
```

---

# Example 1

```sql
WITH AverageSalary AS
(
SELECT AVG(salary) AS avg_salary
FROM employees
)

SELECT *
FROM employees
WHERE salary >
(
SELECT avg_salary
FROM AverageSalary
);
```

This displays employees earning above the average salary.

---

# Example 2 - Multiple CTEs

```sql
WITH
HighestSalary AS
(
SELECT MAX(salary) AS highest_salary
FROM employees
),

LowestSalary AS
(
SELECT MIN(salary) AS lowest_salary
FROM employees
)

SELECT *
FROM HighestSalary,
LowestSalary;
```

Multiple CTEs can be declared in one query.

---

# Recursive CTE

Recursive CTEs reference themselves.

They are useful for:

- Organizational hierarchies
- Family trees
- Folder structures
- Number generation

Example:

```sql
WITH RECURSIVE Numbers AS
(
SELECT 1 AS num

UNION ALL

SELECT num+1
FROM Numbers
WHERE num<5
)

SELECT *
FROM Numbers;
```

Output:

1

2

3

4

5

---

# CTE vs Subquery

| CTE | Subquery |
|------|----------|
| Better readability | Can become complex |
| Can be reused | Usually repeated |
| Supports recursion | No recursion |
| Easier debugging | Harder debugging |

---

# Advantages

- Cleaner SQL code.
- Better organization.
- Supports recursion.
- Easier maintenance.
- Reusable query blocks.

---

# Limitations

- Exists only during query execution.
- Cannot be referenced outside the query.
- Very large recursive CTEs may impact performance.

---

# Real-World Applications

## HR

Calculate department statistics.

---

## Banking

Generate transaction summaries.

---

## E-Commerce

Analyze product sales.

---

## Organization

Display employee hierarchy.

---

# Common Mistakes

## Forgetting the WITH keyword

Every CTE begins with:

```sql
WITH
```

---

## Thinking CTEs are permanent

CTEs exist only for one SQL statement.

---

# Practice Queries

```sql
WITH EmployeeCount AS
(
SELECT COUNT(*) AS total
FROM employees
)

SELECT *
FROM EmployeeCount;
```

---

# Interview Questions

## What is a CTE?

A temporary named result set created using the WITH clause.

---

## What is the advantage of CTEs?

They improve readability and simplify complex SQL queries.

---

## Can multiple CTEs be created?

Yes.

---

## What is a Recursive CTE?

A CTE that references itself to process hierarchical or sequential data.

---

# Summary

Today I learned:

- Common Table Expressions
- WITH Clause
- Multiple CTEs
- Recursive CTEs
- CTE vs Subquery

CTEs make SQL queries more readable, reusable, and maintainable while supporting advanced recursive operations.