# Day 46 - Database Denormalization

# Introduction

Denormalization is the process of combining data from multiple tables into fewer tables to improve query performance.

Unlike Normalization, Denormalization intentionally introduces redundancy.

---

# Why Denormalization?

Denormalization is mainly used to reduce JOIN operations and improve read performance.

It is useful when applications perform many SELECT queries but relatively few INSERT, UPDATE, or DELETE operations.

---

# Normalization vs Denormalization

| Normalization | Denormalization |
|--------------|-----------------|
| Reduces redundancy | Introduces redundancy |
| More tables | Fewer tables |
| More JOIN operations | Fewer JOIN operations |
| Better data consistency | Better read performance |
| Best for OLTP systems | Best for reporting and analytics |

---

# Example

## Normalized Design

Tables:

- Customers
- Products
- Orders

To retrieve complete order details, JOIN operations are required.

```sql
SELECT
o.order_id,
c.customer_name,
p.product_name
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id
JOIN products p
ON o.product_id = p.product_id;
```

---

## Denormalized Design

Single table:

```text
Order Summary
--------------
Order ID
Customer Name
Product Name
Price
```

Now data can be retrieved without JOINs.

```sql
SELECT *
FROM order_summary;
```

---

# Advantages

- Faster SELECT queries.
- Fewer JOIN operations.
- Better reporting performance.
- Simpler queries.

---

# Disadvantages

- Duplicate data.
- Higher storage requirements.
- More difficult updates.
- Risk of inconsistent data.

---

# When to Use Denormalization?

- Data Warehouses
- Reporting Systems
- Business Intelligence
- Dashboards
- Read-heavy applications

---

# Real-World Applications

## E-Commerce

Product catalog pages.

---

## Banking

Monthly transaction reports.

---

## Hospital

Patient history reports.

---

## Analytics

Business dashboards.

---

# Best Practices

- Normalize first.
- Denormalize only when performance becomes an issue.
- Keep duplicated data synchronized.

---

# Common Mistakes

## Denormalizing Too Early

Always design a normalized database first.

---

## Ignoring Data Consistency

Ensure duplicate data is updated everywhere.

---

# Practice Queries

```sql
SELECT * FROM customers;

SELECT * FROM products;

SELECT * FROM orders;

SELECT * FROM order_summary;
```

---

# Interview Questions

## What is Denormalization?

A process of combining tables to reduce JOIN operations and improve read performance.

---

## Why is Denormalization used?

To improve query speed for read-heavy applications.

---

## What is the difference between Normalization and Denormalization?

Normalization reduces redundancy, while Denormalization increases redundancy for better performance.

---

## Where is Denormalization commonly used?

Data warehouses, reporting systems, analytics, and dashboards.

---

# Summary

Today I learned:

- Database Denormalization
- Normalization vs Denormalization
- Advantages
- Disadvantages
- Performance considerations
- Real-world applications

Denormalization improves read performance by reducing JOIN operations but introduces controlled data redundancy.