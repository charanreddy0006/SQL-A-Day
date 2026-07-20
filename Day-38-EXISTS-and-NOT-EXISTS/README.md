# Day 38 - EXISTS and NOT EXISTS

# Introduction

EXISTS and NOT EXISTS are used with subqueries.

They check whether a subquery returns any rows.

Unlike IN, EXISTS does not compare values directly. It only checks if at least one matching row exists.

---

# What is EXISTS?

EXISTS returns TRUE if the subquery returns one or more rows.

If no rows are returned, EXISTS returns FALSE.

---

# Syntax

```sql
SELECT columns
FROM table1
WHERE EXISTS
(
    SELECT 1
    FROM table2
    WHERE condition
);
```

---

# Example

```sql
SELECT customer_name
FROM customers c
WHERE EXISTS
(
    SELECT 1
    FROM orders o
    WHERE c.customer_id = o.customer_id
);
```

### Output

| Customer |
|-----------|
|John|
|David|
|Sophia|

These customers have placed at least one order.

---

# What is NOT EXISTS?

NOT EXISTS is the opposite of EXISTS.

It returns TRUE only when the subquery returns no rows.

---

# Example

```sql
SELECT customer_name
FROM customers c
WHERE NOT EXISTS
(
    SELECT 1
    FROM orders o
    WHERE c.customer_id = o.customer_id
);
```

### Output

| Customer |
|-----------|
|Emma|
|James|

These customers have not placed any orders.

---

# Why Use SELECT 1?

You will often see:

```sql
SELECT 1
```

inside EXISTS.

This is because EXISTS only checks whether rows exist.

The actual selected value does not matter.

`SELECT *` also works, but `SELECT 1` is a common convention.

---

# EXISTS vs IN

| EXISTS | IN |
|---------|----|
|Checks if matching rows exist|Compares values|
|Often better for large datasets|Good for smaller lists|
|Stops after first match|May scan more rows|

---

# EXISTS vs JOIN

| EXISTS | JOIN |
|---------|------|
|Checks existence only|Returns matching rows|
|Avoids duplicate results|May return duplicates|
|Useful for filtering|Useful for combining data|

---

# Real-World Applications

## Banking

Find customers who have at least one active account.

---

## E-Commerce

Find customers who have placed orders.

---

## Hospital

Find doctors who have appointments.

---

## College

Find students enrolled in at least one course.

---

# Common Mistakes

## Forgetting Correlation

Incorrect

```sql
WHERE EXISTS
(
SELECT *
FROM orders
);
```

This checks only if the orders table has rows.

Correct

```sql
WHERE EXISTS
(
SELECT 1
FROM orders o
WHERE c.customer_id=o.customer_id
);
```

---

## Confusing EXISTS with IN

Use EXISTS when checking for matching rows.

Use IN when comparing values from a list.

---

# Practice Queries

```sql
-- Customers with orders
SELECT customer_name
FROM customers c
WHERE EXISTS
(
SELECT 1
FROM orders o
WHERE c.customer_id=o.customer_id
);

-- Customers without orders
SELECT customer_name
FROM customers c
WHERE NOT EXISTS
(
SELECT 1
FROM orders o
WHERE c.customer_id=o.customer_id
);
```

---

# Interview Questions

## What is EXISTS?

It checks whether a subquery returns one or more rows.

---

## What is NOT EXISTS?

It returns TRUE if the subquery returns no rows.

---

## Why is SELECT 1 commonly used?

Because EXISTS only checks for the existence of rows, not the returned values.

---

## Which is better for large datasets?

EXISTS is often more efficient than IN for correlated subqueries.

---

# Summary

Today I learned:

- EXISTS
- NOT EXISTS
- EXISTS vs IN
- EXISTS vs JOIN
- SELECT 1
- Real-World Applications

EXISTS and NOT EXISTS are powerful tools for checking whether related records exist and are commonly used in enterprise SQL queries.