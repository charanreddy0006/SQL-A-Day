# Day 69 — SQL Indexes & Query Performance

## Overview

Day 69 focuses on SQL performance, indexing, and execution plans.

The project uses an e-commerce database to demonstrate how indexes can help the database locate and process data efficiently.

**Database:** `index_performance_lab`

**SQL Dialect:** MySQL 8+

**Storage Engine:** InnoDB

## Folder Structure

```text
Day-69-SQL-Indexes-and-Query-Performance/
├── day69.sql
└── README.txt
```

## Tables

```text
customers
products
orders
order_items
```

Relationships:

```text
customers
   |
   | customer_id
   v
orders
   |
   | order_id
   v
order_items
   |
   | product_id
   v
products
```

## Learning Objectives

By completing Day 69, you should understand:

- What SQL indexes are
- Why indexes improve suitable queries
- Single-column indexes
- Unique indexes
- Composite indexes
- Index column order
- Leftmost prefix principle
- Covering indexes
- Selectivity
- Cardinality
- Full table scans
- Index access
- `EXPLAIN`
- `EXPLAIN FORMAT=TREE`
- `EXPLAIN ANALYZE`
- Indexes for `WHERE`
- Indexes for `JOIN`
- Indexes for `ORDER BY`
- Indexes for date filtering
- Indexes and `LIKE`
- Index maintenance cost
- Query optimization workflow

## 1. What Is an Index?

An index is a database structure that helps the database find rows efficiently for suitable query patterns.

A simple analogy is a book.

Without an index:

```text
Search page by page
```

With an index:

```text
Find topic in index
        ↓
Find page
        ↓
Read required content
```

A database index provides a similar idea for locating data.

## 2. Why Use Indexes?

Suppose a table contains millions of rows.

A query such as:

```sql
SELECT *
FROM products
WHERE category = 'Laptop';
```

may require a large amount of work if the database cannot find an efficient access path.

An appropriate index can allow the optimizer to locate matching values more efficiently.

However, an index is not automatically useful for every query.

## 3. Index Trade-Off

Indexes improve many read operations, but they have costs.

```text
More indexes
     ↓
More storage
     ↓
More maintenance
     ↓
Potentially slower INSERT/UPDATE/DELETE
```

Therefore:

> Create indexes for real query patterns instead of indexing every column.

## 4. Primary Key Indexes

Primary keys normally have associated indexes.

The project uses:

```text
customers.customer_id
products.product_id
orders.order_id
order_items.order_item_id
```

as primary keys.

## 5. Single-Column Index

A single-column index contains one column.

Example:

```sql
CREATE INDEX idx_customers_city
ON customers(city);
```

Useful query:

```sql
SELECT *
FROM customers
WHERE city = 'Hyderabad';
```

## 6. Unique Index

A unique index prevents duplicate key values.

Example:

```sql
CREATE UNIQUE INDEX ux_customers_email
ON customers(email);
```

This is useful when every customer must have a unique email.

A unique index provides:

```text
Uniqueness
+
Indexed lookup
```

## 7. Composite Index

A composite index contains multiple columns.

Example:

```sql
CREATE INDEX idx_products_category_price
ON products(category, price);
```

The order is:

```text
category
price
```

Column order matters.

## 8. Leftmost Prefix Principle

For:

```text
INDEX(category, price)
```

the leading column is `category`.

The index is naturally suited to queries using:

```text
category
```

or:

```text
category + price
```

For example:

```sql
SELECT *
FROM products
WHERE category = 'Laptop'
AND price > 70000;
```

A query using only:

```sql
WHERE price > 70000
```

does not start with the leading column.

Always verify the optimizer's actual choice with `EXPLAIN`.

## 9. Indexes for WHERE

Common filtering columns may be good index candidates.

Examples:

```text
city
category
price
order_status
order_date
customer_id
```

But frequency, selectivity, table size, and workload should be considered.

## 10. Indexes for JOIN

Consider:

```sql
SELECT
    o.order_id,
    c.customer_name
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id;
```

The project creates an index on:

```text
orders.customer_id
```

and indexes important `order_items` foreign-key columns.

## 11. Indexes for ORDER BY

Consider:

```sql
SELECT
    order_id,
    order_date,
    total_amount
FROM orders
WHERE customer_id = 1
ORDER BY order_date DESC;
```

The project creates:

```sql
CREATE INDEX idx_orders_customer_date
ON orders(customer_id, order_date);
```

The first column supports the filtering pattern and the second can support the ordering pattern depending on the optimizer and query.

## 12. Indexes for Date Queries

The project creates:

```sql
CREATE INDEX idx_orders_order_date
ON orders(order_date);
```

This can support queries such as:

```sql
SELECT *
FROM orders
WHERE order_date >= '2026-03-01';
```

## 13. EXPLAIN

`EXPLAIN` shows how MySQL plans to execute a query.

Example:

```sql
EXPLAIN
SELECT *
FROM products
WHERE category = 'Laptop';
```

Important fields include:

```text
id
select_type
table
type
possible_keys
key
key_len
ref
rows
filtered
Extra
```

## 14. possible_keys

`possible_keys` shows indexes the optimizer considers potentially usable.

It does not mean that MySQL will definitely use one.

## 15. key

`key` shows the index selected by the optimizer for that table access, when an index is used.

## 16. rows

`rows` provides an estimate of how many rows MySQL expects to examine.

It is an estimate and should not be treated as an exact runtime count.

## 17. Full Table Scan

A full table scan means the database examines table rows to find matching records.

Conceptually:

```text
Row 1 → check
Row 2 → check
Row 3 → check
...
Row N → check
```

A full scan is not automatically bad.

For a very small table, scanning the table may be cheaper than using an index.

## 18. Selectivity

Selectivity describes how strongly a condition reduces the result set.

Example:

```text
customer_id = 10001
```

may identify one row.

A condition such as:

```text
customer_status = 'Active'
```

may match most rows.

Higher selectivity can make an index more attractive, although the optimizer considers many factors.

## 19. Cardinality

Cardinality relates to the number of distinct values.

Examples:

```text
Email → usually high cardinality
Customer ID → high cardinality
Status → usually low cardinality
```

The SQL file demonstrates `COUNT(DISTINCT ...)` to make this concept concrete.

## 20. Covering Index

A covering index contains enough information for a query to be satisfied from the index itself.

Example:

```sql
SELECT
    product_name,
    price
FROM products
WHERE category = 'Laptop';
```

A possible covering index is:

```text
(category, product_name, price)
```

Covering indexes can reduce base-table lookups, but they also make indexes larger.

## 21. EXPLAIN FORMAT=TREE

The project demonstrates:

```sql
EXPLAIN FORMAT=TREE
SELECT ...;
```

This provides a tree-style representation of the execution plan.

It can make complex plans easier to understand.

## 22. EXPLAIN ANALYZE

The project also demonstrates:

```sql
EXPLAIN ANALYZE
SELECT ...;
```

Unlike a purely estimated plan, `EXPLAIN ANALYZE` executes the query and reports actual execution information.

Use it carefully because the statement is executed.

## 23. Functions on Indexed Columns

Consider:

```sql
WHERE DATE(created_at) = '2026-01-01'
```

Applying a function to an indexed column can affect how effectively a normal index is used.

A range condition is often more index-friendly:

```sql
WHERE created_at >= '2026-01-01 00:00:00'
AND created_at < '2026-01-02 00:00:00'
```

The project compares both forms with `EXPLAIN`.

## 24. LIKE and Indexes

A prefix search:

```sql
WHERE product_name LIKE 'Laptop%'
```

may be able to use a B-tree index.

A leading wildcard:

```sql
WHERE product_name LIKE '%Laptop%'
```

is generally less suitable for a normal B-tree index.

The project demonstrates both cases.

## 25. Indexing GROUP BY

Indexes can sometimes help grouping operations, depending on the query and optimizer.

Example:

```sql
SELECT
    order_status,
    COUNT(*)
FROM orders
GROUP BY order_status;
```

Always use `EXPLAIN` instead of assuming an index will be used.

## 26. Query Optimization Workflow

A practical workflow is:

```text
1. Identify a slow query
        ↓
2. Reproduce it
        ↓
3. Run EXPLAIN
        ↓
4. Understand the execution plan
        ↓
5. Identify the bottleneck
        ↓
6. Rewrite the query if necessary
        ↓
7. Consider an appropriate index
        ↓
8. Run EXPLAIN again
        ↓
9. Compare results
        ↓
10. Test with realistic data
```

## 27. Do Not Optimize by Guessing

Avoid:

```text
"This column sounds important, so I will index it."
```

Prefer:

```text
Measure
   ↓
Analyze
   ↓
Optimize
   ↓
Measure again
```

Performance tuning should be based on actual workload and execution plans.

## 28. Index Costs

### INSERT

New index entries may need to be created.

### UPDATE

If indexed values change, index structures may need maintenance.

### DELETE

Corresponding index entries must be removed.

Therefore:

```text
Indexes improve reads
but
indexes add write overhead
```

## 29. Redundant Indexes

Suppose you have:

```text
INDEX(category)
INDEX(category, price)
```

The composite index may already support many queries that begin with `category`.

However, never remove an index simply because another one looks similar.

Check:

```text
Query workload
Execution plans
Constraints
Index sizes
Production behavior
```

first.

## 30. Important Commands

### Create an index

```sql
CREATE INDEX index_name
ON table_name(column_name);
```

### Unique index

```sql
CREATE UNIQUE INDEX index_name
ON table_name(column_name);
```

### Composite index

```sql
CREATE INDEX index_name
ON table_name(column1, column2);
```

### Inspect indexes

```sql
SHOW INDEX FROM table_name;
```

### Drop an index

```sql
DROP INDEX index_name
ON table_name;
```

### Execution plan

```sql
EXPLAIN
SELECT ...;
```

### Actual execution analysis

```sql
EXPLAIN ANALYZE
SELECT ...;
```

## 31. Practical Exercises

### Exercise 1 — State Index

Create:

```sql
CREATE INDEX idx_customers_state
ON customers(state);
```

Test:

```sql
EXPLAIN
SELECT *
FROM customers
WHERE state = 'Telangana';
```

### Exercise 2 — Brand and Price

Create:

```sql
CREATE INDEX idx_products_brand_price
ON products(brand, price);
```

Test:

```sql
EXPLAIN
SELECT *
FROM products
WHERE brand = 'TechPro'
AND price > 30000;
```

### Exercise 3 — Leftmost Prefix

Compare:

```sql
EXPLAIN
SELECT *
FROM products
WHERE price > 30000;
```

with:

```sql
EXPLAIN
SELECT *
FROM products
WHERE brand = 'TechPro'
AND price > 30000;
```

### Exercise 4 — Order Status and Date

Test:

```sql
EXPLAIN
SELECT *
FROM orders
WHERE order_status = 'Delivered'
AND order_date >= '2026-01-01'
ORDER BY order_date;
```

### Exercise 5 — Inspect Indexes

Run:

```sql
SHOW INDEX FROM customers;
SHOW INDEX FROM products;
SHOW INDEX FROM orders;
SHOW INDEX FROM order_items;
```

## 32. Common Mistakes

### Mistake 1

Creating indexes on every column.

**Better:** index important query patterns.

### Mistake 2

Ignoring composite index order.

**Better:** design the order based on real filters and sorting.

### Mistake 3

Never using `EXPLAIN`.

**Better:** inspect the execution plan.

### Mistake 4

Ignoring write cost.

**Better:** consider INSERT, UPDATE, and DELETE workload.

### Mistake 5

Assuming every full scan is bad.

**Better:** consider table size and how much data the query needs.

### Mistake 6

Creating duplicate indexes.

**Better:** inspect existing indexes before adding new ones.

## 33. Interview Questions

### What is an index?

A database structure that can help locate rows efficiently for suitable queries.

### Why are indexes useful?

They can reduce the amount of data the database needs to examine for suitable access patterns.

### Can indexes slow down writes?

Yes. Indexes require maintenance during INSERT, UPDATE, and DELETE.

### What is a composite index?

An index containing multiple columns.

### Does composite index order matter?

Yes.

### What is the leftmost prefix principle?

A composite B-tree index is generally most useful when queries use its leading indexed columns.

### What is a covering index?

An index containing enough information to satisfy a query without requiring a base-table lookup.

### What is EXPLAIN?

A command used to inspect a query's execution plan.

### What is EXPLAIN ANALYZE?

A command that executes the query and provides actual execution information.

### Should every column have an index?

No.

### What is selectivity?

How effectively a condition narrows the number of matching rows.

### What is cardinality?

The number of distinct values in a column or index key, as represented by database statistics.

## 34. Real-World Applications

Indexes are important in:

```text
Banking
E-commerce
Travel booking
Ticket booking
Healthcare
Education platforms
Payment systems
Inventory systems
Logistics
Social media
```

Typical indexed fields include:

```text
Customer ID
Order ID
Product ID
Email
Order date
Order status
Product category
Product price
Foreign keys
```

## 35. Day 68 vs Day 69

### Day 68

```text
Transactions
     ↓
Concurrency
     ↓
Isolation
     ↓
Locks
     ↓
Deadlocks
```

### Day 69

```text
Indexes
     ↓
Execution Plans
     ↓
EXPLAIN
     ↓
Query Optimization
     ↓
Performance
```

The learning progression is:

```text
Correctness
    ↓
Concurrency
    ↓
Performance
```

## 36. Key Takeaways

```text
1. Indexes can improve suitable queries.
2. Indexes consume storage.
3. Indexes add write-maintenance cost.
4. Composite index order matters.
5. The leftmost prefix principle is important.
6. EXPLAIN helps inspect query plans.
7. EXPLAIN ANALYZE provides actual execution information.
8. Selectivity matters.
9. Covering indexes can reduce table-row lookups.
10. Do not create indexes blindly.
11. Query workload should drive index design.
12. Full table scans are not automatically bad.
```

## 37. Final Checklist

```text
[ ] What is an SQL index?
[ ] Why are indexes useful?
[ ] What are index trade-offs?
[ ] What is a single-column index?
[ ] What is a unique index?
[ ] What is a composite index?
[ ] Why does composite index order matter?
[ ] What is the leftmost prefix principle?
[ ] What is a covering index?
[ ] What is selectivity?
[ ] What is cardinality?
[ ] What is a full table scan?
[ ] What does EXPLAIN do?
[ ] What does EXPLAIN ANALYZE do?
[ ] What is an execution plan?
[ ] Why index JOIN columns?
[ ] Why consider ORDER BY patterns?
[ ] Why not create indexes blindly?
[ ] How do indexes affect INSERT?
[ ] How do indexes affect UPDATE?
[ ] How do indexes affect DELETE?
[ ] How do you inspect indexes?
[ ] How do you drop an index?
```

## 38. Day 69 Summary

```text
Topic:
SQL Indexes & Query Performance

Database:
index_performance_lab

SQL:
MySQL 8+

Storage Engine:
InnoDB

Files:
day69.sql
README.txt
```

The central lesson:

> Good SQL is not only about getting the correct result. Good SQL also considers how efficiently the database can find and process that result.

## Next Natural Topic

A good next step after Day 69 is:

```text
Day 70
Advanced SQL Query Optimization
        ↓
EXPLAIN Deep Dive
        ↓
JOIN Optimization
        ↓
Subquery Optimization
        ↓
CTE Performance
        ↓
Window Function Performance
        ↓
Query Rewriting
```
