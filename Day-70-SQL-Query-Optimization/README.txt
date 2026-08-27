# Day 70 — Advanced SQL Query Optimization

## Project

**SQL-A-Day — Day 70**

**Topic:** Advanced SQL Query Optimization

**Database:** `sql_query_optimization_lab`

**SQL Dialect:** MySQL 8+

**Files:**

```text
Day-70-SQL-Query-Optimization/
│
├── day70.sql
└── README.txt
```

---

## 1. Overview

Day 70 continues the SQL performance journey from Day 69.

Day 69 focused mainly on indexes and execution plans.

Day 70 moves deeper into the actual design and structure of SQL queries.

The project demonstrates how to analyze and improve:

- Query structure
- Filtering
- JOINs
- Subqueries
- CTEs
- `IN`
- `EXISTS`
- Aggregation
- Sorting
- `LIMIT`
- `DISTINCT`
- `UNION`
- `UNION ALL`
- Date filtering
- Sargable predicates
- Composite indexes
- Window functions
- Execution plans
- `EXPLAIN`
- `EXPLAIN FORMAT=TREE`
- `EXPLAIN ANALYZE`

The central idea is simple:

```text
Correct Query
      ↓
Measure
      ↓
EXPLAIN
      ↓
Find Bottleneck
      ↓
Optimize
      ↓
Measure Again
      ↓
Verify Correctness
```

---

# 2. Learning Objectives

After completing Day 70, you should be able to:

1. Explain what SQL query optimization means.
2. Understand why query structure affects performance.
3. Use `EXPLAIN`.
4. Use `EXPLAIN FORMAT=TREE`.
5. Use `EXPLAIN ANALYZE`.
6. Identify indexes selected by the optimizer.
7. Understand estimated rows.
8. Optimize filtering.
9. Optimize JOIN patterns.
10. Compare subqueries and JOINs.
11. Compare `IN` and `EXISTS`.
12. Use CTEs for complex queries.
13. Understand sargable predicates.
14. Optimize date-range queries.
15. Understand prefix versus leading-wildcard `LIKE`.
16. Compare `UNION` and `UNION ALL`.
17. Optimize aggregation patterns.
18. Understand the effect of `ORDER BY`.
19. Use `LIMIT` for top-N queries.
20. Understand when `DISTINCT` is necessary.
21. Design composite indexes around query patterns.
22. Use window functions for analytical queries.
23. Inspect database indexes using `information_schema`.
24. Develop a practical SQL optimization workflow.

---

# 3. Database Structure

The project creates five tables:

```text
customers
categories
products
orders
order_items
```

Relationship:

```text
customers
    │
    │ customer_id
    ▼
orders
    │
    │ order_id
    ▼
order_items
    │
    │ product_id
    ▼
products
    │
    │ category_id
    ▼
categories
```

This represents a simple e-commerce database.

---

# 4. Why Use an E-Commerce Database?

E-commerce systems produce many common SQL workloads.

Examples:

```text
Customer lookup
Order history
Product search
Revenue calculation
Top customers
Top products
Category reports
Latest orders
Sales rankings
Inventory filtering
```

These workloads provide realistic examples for studying query optimization.

---

# 5. Query Optimization

Query optimization means improving the way a SQL statement is executed while preserving its correct result.

The goal is not to make SQL complicated.

The goal is to make SQL:

```text
Correct
Readable
Maintainable
Efficient
Measurable
```

A useful optimization process is:

```text
SQL Query
   ↓
Execution Plan
   ↓
Identify Expensive Operations
   ↓
Rewrite or Improve Access Path
   ↓
New Execution Plan
   ↓
Measure
```

---

# 6. Correctness Comes First

Never optimize a query by changing its meaning.

The correct workflow is:

```text
Correct Result
      ↓
Performance Measurement
      ↓
Execution Plan Analysis
      ↓
Optimization
      ↓
Result Verification
```

A query that is fast but produces incorrect results is not optimized.

---

# 7. SELECT Only Required Columns

A common query is:

```sql
SELECT *
FROM products;
```

`SELECT *` requests every selected column.

When only a few columns are needed, explicitly select them:

```sql
SELECT
    product_id,
    product_name,
    price
FROM products;
```

Advantages may include:

```text
Less unnecessary data
Smaller result sets
Clearer intent
Potentially better index-only access
```

This does not mean `SELECT *` is always slow.

The correct decision depends on the workload.

---

# 8. WHERE Clause

`WHERE` filters rows.

Example:

```sql
SELECT
    customer_id,
    SUM(total_amount)
FROM orders
WHERE order_status = 'Delivered'
GROUP BY customer_id;
```

The database can use the condition to reduce rows that participate in later processing.

---

# 9. HAVING Clause

`HAVING` filters groups after grouping.

Example:

```sql
SELECT
    customer_id,
    SUM(total_amount) AS total_spent
FROM orders
GROUP BY customer_id
HAVING SUM(total_amount) > 50000;
```

The important distinction is:

```text
WHERE
→ filters rows

HAVING
→ filters groups
```

---

# 10. Logical Query Processing

A simplified logical order is:

```text
FROM
 ↓
JOIN
 ↓
WHERE
 ↓
GROUP BY
 ↓
HAVING
 ↓
SELECT
 ↓
ORDER BY
 ↓
LIMIT
```

This is a logical processing model.

The physical execution plan chosen by the optimizer can use different operations and orders.

---

# 11. JOIN Optimization

JOINs are one of the most important parts of relational SQL.

Example:

```sql
SELECT
    o.order_id,
    c.customer_name,
    o.total_amount
FROM orders AS o
JOIN customers AS c
    ON o.customer_id = c.customer_id;
```

Important considerations include:

```text
Join condition
Join cardinality
Indexes
Filtering
Estimated rows
Chosen access method
Execution plan
```

---

# 12. Filtering Before Processing

If only delivered orders are needed:

```sql
SELECT
    o.order_id,
    c.customer_name,
    o.total_amount
FROM orders AS o
JOIN customers AS c
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'Delivered';
```

This expresses the required filter directly in SQL.

The optimizer can also push predicates internally when appropriate.

Therefore, do not assume the textual order alone determines physical execution.

Always inspect the plan.

---

# 13. JOIN Indexes

The project includes indexes on foreign-key columns.

Examples:

```text
orders.customer_id
products.category_id
order_items.order_id
order_items.product_id
```

These indexes can support common JOIN access patterns.

However:

```text
Index exists
```

does not guarantee:

```text
Index will be used
```

The optimizer chooses the access path based on statistics, selectivity, costs, and query structure.

---

# 14. Subqueries

A subquery is a query nested inside another query.

Example:

```sql
SELECT
    customer_id,
    customer_name
FROM customers
WHERE customer_id IN (
    SELECT customer_id
    FROM orders
    WHERE total_amount > 50000
);
```

Subqueries can be readable and useful.

They are not automatically inefficient.

---

# 15. Subquery vs JOIN

The project compares equivalent logic using a subquery and a JOIN.

Subquery:

```sql
SELECT
    customer_id,
    customer_name
FROM customers
WHERE customer_id IN (
    SELECT customer_id
    FROM orders
    WHERE total_amount > 50000
);
```

JOIN:

```sql
SELECT DISTINCT
    c.customer_id,
    c.customer_name
FROM customers AS c
JOIN orders AS o
    ON o.customer_id = c.customer_id
WHERE o.total_amount > 50000;
```

Do not assume one form is universally faster.

Use:

```text
Correctness
+
Readability
+
EXPLAIN
+
Actual measurements
```

---

# 16. IN

`IN` checks membership in a set.

Example:

```sql
WHERE customer_id IN (
    SELECT customer_id
    FROM orders
);
```

Modern optimizers can transform many `IN` expressions.

Therefore:

```text
IN = always slow
```

is an incorrect rule.

---

# 17. EXISTS

`EXISTS` checks whether at least one matching row exists.

Example:

```sql
SELECT
    c.customer_id,
    c.customer_name
FROM customers AS c
WHERE EXISTS (
    SELECT 1
    FROM orders AS o
    WHERE o.customer_id = c.customer_id
    AND o.order_status = 'Delivered'
);
```

It is especially natural when the requirement is:

> Find customers for whom at least one matching order exists.

---

# 18. EXISTS vs IN

Do not memorize:

```text
EXISTS is always faster.
```

That is not universally true.

Do not memorize:

```text
IN is always faster.
```

That is also not universally true.

Use:

```sql
EXPLAIN
```

and, where useful:

```sql
EXPLAIN ANALYZE
```

to compare actual behavior.

---

# 19. Correlated Subqueries

A correlated subquery references a value from the outer query.

Conceptually:

```text
Outer customer
      ↓
Inner order query
      ↓
Calculate customer result
```

Example:

```sql
SELECT
    c.customer_id,
    c.customer_name
FROM customers AS c
WHERE (
    SELECT COALESCE(SUM(o.total_amount), 0)
    FROM orders AS o
    WHERE o.customer_id = c.customer_id
) > 50000;
```

Correlated subqueries can be useful but should be analyzed carefully on large datasets.

---

# 20. Common Table Expressions

A CTE uses:

```sql
WITH
```

Example:

```sql
WITH customer_totals AS (
    SELECT
        customer_id,
        SUM(total_amount) AS total_spent
    FROM orders
    GROUP BY customer_id
)
SELECT *
FROM customer_totals;
```

CTEs can improve:

```text
Readability
Organization
Maintainability
Complex query structure
```

A CTE should not automatically be considered faster.

Its actual execution depends on the optimizer and MySQL version.

---

# 21. CTE Query Pattern

The project uses multiple CTE stages:

```text
orders
   ↓
delivered_orders
   ↓
customer_revenue
   ↓
customers
   ↓
final report
```

This separates logical stages of the query.

---

# 22. Sargability

A predicate is commonly called sargable when it can be efficiently used by an index search.

Example:

```sql
WHERE order_date >= '2025-08-20'
AND order_date < '2025-08-21'
```

This range can work well with an index on `order_date`.

---

# 23. Non-Sargable Date Predicate

Consider:

```sql
WHERE DATE(order_date) = '2025-08-20'
```

A function is applied to the column.

This can make normal index range access harder.

A range predicate is usually preferable:

```sql
WHERE order_date >= '2025-08-20 00:00:00'
AND order_date < '2025-08-21 00:00:00'
```

The project uses `EXPLAIN` to compare these forms.

---

# 24. Why Half-Open Date Ranges Are Useful

The pattern:

```sql
>= start
AND < next_start
```

is useful because it covers the entire requested interval without needing to calculate the final possible timestamp.

Example:

```sql
WHERE order_date >= '2025-08-20 00:00:00'
AND order_date < '2025-08-21 00:00:00'
```

This includes all times on August 20.

---

# 25. LIKE Optimization

A prefix search:

```sql
WHERE product_name LIKE 'Laptop%'
```

can often make use of a normal B-tree index because the beginning of the string is known.

A leading wildcard:

```sql
WHERE product_name LIKE '%Laptop%'
```

is generally harder for a normal B-tree index to optimize.

The key difference is:

```text
Laptop%
```

versus:

```text
%Laptop%
```

---

# 26. UNION

`UNION` combines result sets and removes duplicates.

Example:

```sql
SELECT city
FROM customers
WHERE state = 'Telangana'

UNION

SELECT city
FROM customers
WHERE state = 'Karnataka';
```

Duplicate elimination may require additional processing.

---

# 27. UNION ALL

`UNION ALL` combines results without removing duplicates.

Example:

```sql
SELECT city
FROM customers
WHERE state = 'Telangana'

UNION ALL

SELECT city
FROM customers
WHERE state = 'Karnataka';
```

If duplicate elimination is not required, `UNION ALL` is often preferable.

---

# 28. ORDER BY

Sorting can require additional work.

Example:

```sql
SELECT
    product_id,
    product_name,
    price
FROM products
ORDER BY price DESC;
```

The optimizer may use an appropriate index or perform a sort.

Use:

```sql
EXPLAIN
```

to understand the selected strategy.

---

# 29. LIMIT

`LIMIT` is commonly used for top-N queries.

Example:

```sql
SELECT
    product_id,
    product_name,
    price
FROM products
ORDER BY price DESC
LIMIT 5;
```

Typical uses:

```text
Top products
Latest orders
Top customers
Leaderboards
Search result pages
```

---

# 30. Aggregation

Common aggregate functions include:

```text
COUNT()
SUM()
AVG()
MIN()
MAX()
```

Example:

```sql
SELECT
    category_id,
    COUNT(*) AS product_count
FROM products
GROUP BY category_id;
```

Aggregation can involve:

```text
Scanning
Grouping
Calculating
Sorting or temporary processing
```

The actual physical strategy is determined by the optimizer.

---

# 31. Filtering Before Aggregation

Example:

```sql
SELECT
    customer_id,
    SUM(total_amount) AS delivered_revenue
FROM orders
WHERE order_status = 'Delivered'
GROUP BY customer_id;
```

This expresses that cancelled and other statuses are not part of the calculation.

Filtering can reduce the rows participating in aggregation.

---

# 32. DISTINCT

`DISTINCT` removes duplicate rows.

Example:

```sql
SELECT DISTINCT city
FROM customers;
```

Duplicate elimination can require additional processing.

Therefore, do not use `DISTINCT` merely to hide unexpected duplicates.

First understand why the duplicates exist.

---

# 33. Correct JOIN Instead of Unnecessary DISTINCT

A common mistake is:

```sql
SELECT DISTINCT ...
FROM ...
JOIN ...
```

when the actual issue is an incorrect JOIN condition.

Better process:

```text
Understand relationship
      ↓
Check JOIN condition
      ↓
Check expected cardinality
      ↓
Use DISTINCT only if logically required
```

---

# 34. Composite Indexes

The project includes indexes such as:

```text
(category_id, price)
(customer_id, order_date)
(order_status, order_date)
```

These indexes are based on query patterns.

Example:

```sql
WHERE customer_id = 1
ORDER BY order_date DESC
```

can potentially benefit from:

```text
(customer_id, order_date)
```

---

# 35. Composite Index Order

These are different:

```text
(customer_id, order_date)
```

and:

```text
(order_date, customer_id)
```

The order of columns matters.

The leading column is particularly important for determining which search patterns can efficiently use the index.

Index design should come from actual workloads.

---

# 36. EXPLAIN

Basic syntax:

```sql
EXPLAIN
SELECT ...
```

It provides information about the execution plan.

Important fields include:

```text
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

---

# 37. possible_keys

`possible_keys` indicates indexes that may be considered for the table access.

It does not mean an index will definitely be used.

---

# 38. key

`key` shows the index selected by the optimizer.

If it is:

```text
NULL
```

the optimizer chose not to use an index for that table access.

This is not automatically bad.

For a small table or a query that returns most rows, a table scan can be the better choice.

---

# 39. rows

`rows` is an estimate of rows MySQL expects to examine.

It is useful for comparing alternative plans.

It is an estimate rather than a guaranteed exact runtime count.

---

# 40. EXPLAIN FORMAT=TREE

The project uses:

```sql
EXPLAIN FORMAT=TREE
SELECT ...
```

A tree representation can make a complex plan easier to understand.

It helps visualize operations such as:

```text
Table access
      ↓
Filter
      ↓
Join
      ↓
Aggregation
      ↓
Sort
```

---

# 41. EXPLAIN ANALYZE

The project also uses:

```sql
EXPLAIN ANALYZE
SELECT ...
```

Unlike ordinary `EXPLAIN`, this executes the statement and reports actual execution information.

Conceptually:

```text
EXPLAIN
→ planned execution

EXPLAIN ANALYZE
→ observed execution
```

Use it carefully because the query is actually executed.

---

# 42. Information Schema

The project examines:

```text
information_schema.STATISTICS
```

This can show index information such as:

```text
TABLE_NAME
INDEX_NAME
COLUMN_NAME
SEQ_IN_INDEX
NON_UNIQUE
CARDINALITY
```

The project also examines:

```text
information_schema.TABLES
```

for table and index size information.

---

# 43. Practical Optimization Workflow

Use this workflow:

```text
1. Find a slow query.
2. Confirm its correct result.
3. Run EXPLAIN.
4. Inspect estimated rows.
5. Inspect possible indexes.
6. Inspect the selected index.
7. Inspect JOINs.
8. Inspect filtering.
9. Inspect sorting.
10. Rewrite only when there is a reason.
11. Run EXPLAIN again.
12. Use EXPLAIN ANALYZE when appropriate.
13. Measure the difference.
14. Verify the result again.
```

---

# 44. Do Not Optimize Blindly

Bad approach:

```text
Query is slow
      ↓
Add many indexes
      ↓
Hope it becomes faster
```

Better:

```text
Query is slow
      ↓
Measure
      ↓
EXPLAIN
      ↓
Understand
      ↓
Make one targeted change
      ↓
Measure again
```

---

# 45. Common Optimization Mistakes

## Mistake 1 — Using SELECT *

If only three columns are required:

```sql
SELECT *
```

is usually unnecessary.

Prefer:

```sql
SELECT product_id, product_name, price
```

---

## Mistake 2 — Functions on Indexed Columns

Avoid patterns such as:

```sql
WHERE DATE(order_date) = ...
```

when a range condition can express the same requirement.

---

## Mistake 3 — Unnecessary DISTINCT

Do not use `DISTINCT` just to hide duplicate rows created by a bad JOIN.

---

## Mistake 4 — UNION Instead of UNION ALL

If duplicates are acceptable or impossible, `UNION ALL` can avoid duplicate-removal work.

---

## Mistake 5 — Assuming EXISTS Is Always Faster

There is no universal rule.

---

## Mistake 6 — Assuming JOIN Is Always Faster

Different query forms can be transformed by the optimizer.

---

## Mistake 7 — Creating Too Many Indexes

Indexes consume storage and add write-maintenance overhead.

---

## Mistake 8 — Ignoring Query Shape

Index design should reflect actual query patterns.

---

# 46. Query Shape

Suppose the workload frequently uses:

```sql
WHERE customer_id = ?
ORDER BY order_date DESC
```

An index such as:

```text
(customer_id, order_date)
```

may be appropriate.

But if the workload instead frequently uses:

```sql
WHERE order_date >= ?
ORDER BY customer_id
```

the ideal index may be different.

The query pattern matters.

---

# 47. N+1 Query Pattern

Application code can create a database performance problem.

Example:

```text
1 query → fetch 100 customers

Then:
1 query → orders for customer 1
1 query → orders for customer 2
1 query → orders for customer 3
...
```

This creates many database round trips.

A JOIN or batch query can sometimes reduce this overhead.

---

# 48. Pagination

Basic pagination:

```sql
SELECT
    product_id,
    product_name,
    price
FROM products
ORDER BY product_id
LIMIT 20 OFFSET 0;
```

Large offsets can become inefficient on large datasets.

Keyset-style pagination can be useful:

```sql
SELECT
    product_id,
    product_name,
    price
FROM products
WHERE product_id > 100
ORDER BY product_id
LIMIT 20;
```

This works well when the ordering column is suitable and indexed.

---

# 49. Window Functions

Window functions are useful for:

```text
Ranking
Running totals
Partitioned calculations
Latest-row selection
Analytical comparisons
```

Example:

```sql
RANK() OVER (
    ORDER BY total_revenue DESC
)
```

They can still require significant processing on large datasets.

Use execution plans and measurements.

---

# 50. Latest Order Per Customer

The project uses:

```sql
ROW_NUMBER() OVER (
    PARTITION BY customer_id
    ORDER BY order_date DESC
)
```

This creates a row number for every customer's orders.

Then:

```sql
WHERE rn = 1
```

returns the latest order for each customer.

This is a common real-world SQL pattern.

---

# 51. Query Optimization Principles

Remember:

```text
1. Return only required data.
2. Filter appropriately.
3. Use indexes that match real query patterns.
4. Keep JOIN conditions correct.
5. Avoid unnecessary DISTINCT.
6. Use sargable predicates when possible.
7. Use EXPLAIN.
8. Measure before and after changes.
9. Preserve result correctness.
10. Consider application/database interaction.
```

---

# 52. Before and After Example

Less desirable pattern:

```sql
SELECT *
FROM orders
WHERE DATE(order_date) = '2025-08-25';
```

Potentially better pattern:

```sql
SELECT
    order_id,
    customer_id,
    order_date,
    total_amount
FROM orders
WHERE order_date >= '2025-08-25 00:00:00'
AND order_date < '2025-08-26 00:00:00';
```

The second query:

```text
Selects required columns
Uses a range predicate
Can better support an index on order_date
```

Always verify with the execution plan.

---

# 53. Practical Exercise 1

Compare:

```sql
SELECT *
FROM orders
WHERE DATE(order_date) = '2025-08-25';
```

with:

```sql
SELECT
    order_id,
    customer_id,
    order_date,
    total_amount
FROM orders
WHERE order_date >= '2025-08-25 00:00:00'
AND order_date < '2025-08-26 00:00:00';
```

Run:

```sql
EXPLAIN
```

for both.

Compare:

```text
possible_keys
key
rows
Extra
```

---

# 54. Practical Exercise 2

Compare:

```sql
SELECT city
FROM customers
WHERE state = 'Telangana'
UNION
SELECT city
FROM customers
WHERE state = 'Karnataka';
```

with:

```sql
SELECT city
FROM customers
WHERE state = 'Telangana'
UNION ALL
SELECT city
FROM customers
WHERE state = 'Karnataka';
```

Determine whether duplicate removal is required.

---

# 55. Practical Exercise 3

Compare:

```sql
SELECT *
FROM products
WHERE category_id = 1;
```

with:

```sql
SELECT
    product_id,
    product_name,
    price
FROM products
WHERE category_id = 1;
```

Consider:

```text
Returned columns
Result size
Execution plan
Index access
```

---

# 56. Practical Exercise 4

Compare `IN` and `EXISTS`.

Run `EXPLAIN` for both.

Do not decide based only on theoretical rules.

---

# 57. Practical Exercise 5

Create a query for:

```text
Top 3 customers by delivered-order revenue.
```

Requirements:

```text
Exclude cancelled orders
Group by customer
Calculate revenue
Sort descending
Return 3 customers
```

---

# 58. Practical Exercise 6

Create a query for:

```text
Highest-priced available product in each category.
```

Try solving it using:

```text
GROUP BY
Window functions
CTE
```

Then compare readability and execution plans.

---

# 59. Practical Exercise 7

Create a query for:

```text
Customers who have at least one delivered order.
```

Implement using:

```text
EXISTS
IN
JOIN
```

Compare the approaches.

---

# 60. Practical Exercise 8

Create a query for:

```text
Products priced above the average product price.
```

Start with:

```sql
SELECT ...
WHERE price > (
    SELECT AVG(price)
    FROM products
);
```

Then inspect the execution plan.

---

# 61. Interview Questions

### What is query optimization?

It is the process of improving query execution efficiency while preserving the correct result.

### Is an index always beneficial?

No. Indexes consume storage and add maintenance overhead during writes.

### Is SELECT * always slow?

No. But it can return unnecessary columns and can reduce opportunities for efficient index-only access.

### Is EXISTS always faster than IN?

No. The optimizer can transform these expressions, and performance depends on the workload.

### Is JOIN always faster than a subquery?

No. The actual execution plan determines performance.

### What is sargability?

It refers to predicates that can be efficiently supported by index search operations.

### Why can functions on indexed columns hurt?

They can prevent direct use of the indexed value for a normal range lookup.

### What is UNION ALL?

It combines result sets without removing duplicates.

### Why can UNION be more expensive?

It may need duplicate elimination.

### What does EXPLAIN do?

It provides information about the optimizer's execution plan.

### What does EXPLAIN ANALYZE do?

It executes the query and reports actual execution information.

---

# 62. Real-World Applications

Query optimization matters in:

```text
E-commerce
Banking
Payment systems
Healthcare systems
Education platforms
Social networks
Travel platforms
Inventory systems
Logistics
Telecommunications
Analytics
Reporting
Data platforms
```

Typical workloads include:

```text
Customer search
Order history
Product search
Revenue reports
Transaction lookup
Inventory queries
Dashboard queries
Ranking queries
Recommendation queries
```

---

# 63. Performance Mindset

A beginner often asks:

```text
Does this query work?
```

A performance-minded SQL developer also asks:

```text
How is the database executing it?
```

Then:

```text
Can the same result be produced more efficiently?
```

Finally:

```text
Did the change actually improve performance?
```

That mindset is essential for database engineering.

---

# 64. Optimization Checklist

```text
[ ] Is the query correct?
[ ] Are all returned columns necessary?
[ ] Are filters appropriate?
[ ] Are JOIN conditions correct?
[ ] Are JOIN columns indexed where appropriate?
[ ] Is SELECT * necessary?
[ ] Is DISTINCT required?
[ ] Is UNION required?
[ ] Can UNION ALL be used?
[ ] Are date predicates sargable?
[ ] Are functions being applied to indexed columns?
[ ] Is ORDER BY necessary?
[ ] Is LIMIT useful?
[ ] Is aggregation necessary?
[ ] Can filtering reduce rows?
[ ] Have I checked EXPLAIN?
[ ] Have I checked possible_keys?
[ ] Have I checked key?
[ ] Have I checked rows?
[ ] Have I checked Extra?
[ ] Have I compared alternative query forms?
[ ] Have I measured actual behavior?
[ ] Is the final result still correct?
```

---

# 65. Day 69 vs Day 70

## Day 69

```text
Indexes
   ↓
Single-Column Indexes
   ↓
Composite Indexes
   ↓
Covering Concepts
   ↓
EXPLAIN
   ↓
Index Selection
```

## Day 70

```text
Query Structure
   ↓
Filtering
   ↓
JOIN Optimization
   ↓
Subqueries
   ↓
EXISTS / IN
   ↓
CTEs
   ↓
Sargability
   ↓
Aggregation
   ↓
Sorting
   ↓
Execution Plans
   ↓
Query Optimization
```

The progression is:

```text
Day 69:
How can indexes help?

Day 70:
How can the query and access path be designed efficiently?
```

---

# 66. Key Takeaways

```text
1. Query optimization improves execution efficiency.
2. Correctness must always be preserved.
3. Select only required columns when practical.
4. WHERE filters rows.
5. HAVING filters grouped results.
6. JOIN conditions should represent actual relationships.
7. IN and EXISTS are not universally faster or slower.
8. Correlated subqueries require careful analysis.
9. CTEs improve organization but are not automatically faster.
10. Sargable predicates can improve index usability.
11. Date ranges are often better than functions on indexed dates.
12. UNION removes duplicates.
13. UNION ALL does not remove duplicates.
14. ORDER BY can require sorting.
15. LIMIT is useful for top-N queries.
16. DISTINCT should be intentional.
17. Composite index order matters.
18. EXPLAIN is essential for plan analysis.
19. EXPLAIN ANALYZE provides observed execution details.
20. Performance should be measured rather than guessed.
```

---

# 67. Final Project Summary

```text
Project:
Day 70 — Advanced SQL Query Optimization

Database:
sql_query_optimization_lab

SQL:
MySQL 8+

Tables:
customers
categories
products
orders
order_items

Main Concepts:
Query optimization
EXPLAIN
EXPLAIN FORMAT=TREE
EXPLAIN ANALYZE
JOIN optimization
Subqueries
EXISTS
IN
CTEs
Sargability
Date ranges
LIKE
UNION
UNION ALL
Aggregation
ORDER BY
LIMIT
DISTINCT
Window functions
Composite indexes
Execution plans
```

---

# 68. Completion Checklist

```text
[ ] Created database
[ ] Created customers table
[ ] Created categories table
[ ] Created products table
[ ] Created orders table
[ ] Created order_items table
[ ] Inserted sample data
[ ] Tested EXPLAIN
[ ] Tested EXPLAIN FORMAT=TREE
[ ] Tested EXPLAIN ANALYZE
[ ] Practiced SELECT *
[ ] Practiced required-column selection
[ ] Practiced WHERE
[ ] Practiced HAVING
[ ] Practiced JOIN optimization
[ ] Compared subquery and JOIN
[ ] Compared IN and EXISTS
[ ] Practiced CTE
[ ] Practiced date-range filtering
[ ] Practiced sargable predicates
[ ] Compared LIKE patterns
[ ] Compared UNION and UNION ALL
[ ] Practiced aggregation
[ ] Practiced ORDER BY and LIMIT
[ ] Practiced window functions
[ ] Inspected indexes
[ ] Inspected table statistics
```

---

# 69. Final Lesson

The central lesson of Day 70 is:

```text
Good SQL
    =
Correct Result
+
Good Query Structure
+
Appropriate Indexes
+
Efficient Filtering
+
Correct JOIN Strategy
+
Execution-Plan Analysis
+
Measured Performance
```

Do not optimize SQL based on assumptions.

Use:

```text
EXPLAIN
+
EXPLAIN ANALYZE
+
Realistic Data
+
Actual Measurements
```

to understand what the database is really doing.

The goal is not to make SQL complicated.

The goal is to make SQL:

```text
Correct
Readable
Maintainable
Efficient
Measurable
```

---

# 70. Next Learning Direction

A natural continuation after Day 70 is:

```text
Day 71
Advanced Window Functions

        ↓

Day 72
Recursive CTEs

        ↓

Day 73
Stored Procedures

        ↓

Day 74
Triggers and Events

        ↓

Day 75
Transactions and Locking

        ↓

Day 76
SQL Performance Tuning Project
```

Day 70 connects index knowledge with practical query-performance engineering.
