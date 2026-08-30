Day 73 — SQL Query Optimization & Execution Plans

Project

SQL-A-Day — Day 73

Topic: SQL Query Optimization and Execution Plans

Database: sql_optimization_lab

SQL Dialect: MySQL 8+

1. Overview

Day 73 focuses on understanding how a database executes SQL queries and how SQL performance can be improved.

A SQL query can be logically correct and still be inefficient.

Production SQL should be designed with attention to:

Execution time
Rows examined
Indexes
Joins
Sorting
Aggregation
Filtering
Memory
CPU
Disk I/O
Scalability

This project introduces:

EXPLAIN

and:

EXPLAIN ANALYZE

The project uses a small e-commerce sales database so that different execution strategies can be studied using realistic relationships.

2. Main Learning Objectives

By completing this project, you should understand:

1. Query optimization
2. Execution plans
3. EXPLAIN
4. EXPLAIN ANALYZE
5. Full table scans
6. Index lookups
7. Access types
8. Estimated rows
9. Cardinality
10. Selectivity
11. Composite indexes
12. Covering indexes
13. Sargable predicates
14. Non-sargable predicates
15. WHERE optimization
16. JOIN optimization
17. GROUP BY optimization
18. ORDER BY optimization
19. LIMIT
20. EXISTS vs IN
21. UNION vs UNION ALL
22. Correlated subqueries
23. Query rewriting
24. Index inspection
25. Table-size inspection
26. Production SQL performance

3. Project Structure

Day-73-SQL-Query-Optimization/
│
├── day73.sql
└── README.md

4. Database Architecture

The project contains four main tables:

customers
    |
    | 1
    |
    | N
orders
    |
    | 1
    |
    | N
order_items
    |
    | N
    |
    | 1
products

The relationships are:

Customer
   |
   +---- Orders
             |
             +---- Order Items
                        |
                        +---- Product

This represents a simplified e-commerce sales system.

5. Customers

The customers table contains:

customer_id
customer_name
email
city
state
customer_type
signup_date

Indexes include:

city
customer_type

These allow filtering and index analysis.

6. Products

The products table contains:

product_id
product_name
category
brand
price
stock_quantity

Indexes include:

category
brand
(category, price)

The composite index is used to study multi-column filtering.

7. Orders

The orders table contains:

order_id
customer_id
order_date
status
total_amount
shipping_city

Indexes include:

customer_id
order_date
status
(customer_id, order_date)

Additional indexes are created during optimization exercises.

8. Order Items

The order_items table contains:

order_item_id
order_id
product_id
quantity
unit_price

Indexes include:

order_id
product_id
(product_id, order_id)

This table connects orders and products.

9. What Is Query Optimization?

Query optimization means improving a query so that the database performs the required work efficiently.

The objective is generally to reduce:

Execution time
CPU usage
Disk I/O
Memory consumption
Rows examined
Unnecessary sorting
Unnecessary scanning
Network transfer

The best optimization depends on the actual workload.

10. Why Query Performance Matters

A query operating on:

100 rows

may execute quickly even without an index.

The same query on:

100 million rows

can become extremely expensive.

Therefore, SQL performance must be considered in relation to:

Data volume
Data distribution
Query frequency
Concurrency
Indexes
Hardware

11. What Is an Execution Plan?

An execution plan describes how the database intends to execute a query.

It can provide information about:

Tables accessed
Access order
Indexes considered
Index selected
Join strategy
Estimated rows
Filtering
Sorting
Temporary operations

Execution plans are one of the most important tools for SQL performance analysis.

12. EXPLAIN

The basic syntax is:

EXPLAIN
SELECT ...

Example:

EXPLAIN
SELECT *
FROM customers
WHERE city = 'Hyderabad';

This allows you to inspect the optimizer's planned execution strategy.

13. EXPLAIN ANALYZE

MySQL 8.0.18+ supports:

EXPLAIN ANALYZE

It executes the query and reports actual execution information.

This allows you to compare:

Estimated behavior

with:

Actual behavior

This is extremely useful when diagnosing performance problems.

14. Important EXPLAIN Information

Depending on the MySQL version and output format, important information can include:

table
type
possible_keys
key
key_len
ref
rows
filtered
Extra

These fields help explain how MySQL plans to access data.

15. Access Type

The type information describes the access strategy.

Common values include:

const
eq_ref
ref
range
index
ALL

The ideal access method depends on the query.

A full scan is not automatically bad.

For a tiny table, scanning the entire table can be cheaper than using an index.

16. Full Table Scan

A full table scan means the database examines a broad portion of the table rather than narrowing the result through an efficient index access path.

A plan showing:

ALL

can indicate a full table scan.

The important question is:

How many rows must be examined?

17. Index Lookup

An index lookup allows the database to locate matching records through an index.

Example:

SELECT *
FROM customers
WHERE city = 'Hyderabad';

The project contains:

idx_customers_city

so the optimizer can consider the index.

18. possible_keys

possible_keys indicates indexes that may be useful for the query.

A query may have multiple possible indexes.

For example:

idx_orders_customer
idx_orders_customer_date

may both be candidates.

19. key

The key field identifies the index selected by the optimizer.

The optimizer does not simply choose an index because it exists.

It estimates the cost of different strategies.

20. Estimated Rows

The rows value represents an estimate of the number of rows the database expects to examine.

For very large tables, reducing unnecessary rows can have a major performance impact.

21. Cardinality

Cardinality refers to the number of distinct values in a column or index.

Example:

customer_id

usually has high cardinality.

A column such as:

status

usually has much lower cardinality.

Cardinality influences how useful an index may be for a particular query.

22. Selectivity

Selectivity describes how effectively a condition reduces the number of rows.

For example:

WHERE customer_id = 1001

may return one row.

That is highly selective.

A condition such as:

WHERE status = 'DELIVERED'

may return a large percentage of the table.

That is less selective.

23. Indexes

An index is a data structure that helps the database locate rows efficiently.

Indexes can improve:

Filtering
Joins
Sorting
Range lookups

But indexes also have costs.

24. Cost of Indexes

Indexes consume:

Storage
Memory
Write overhead
Maintenance time

For operations such as:

INSERT
UPDATE
DELETE

the database may need to maintain affected indexes.

Therefore:

More indexes
≠
Always better performance

25. Composite Indexes

A composite index contains multiple columns.

Example:

CREATE INDEX idx_orders_customer_date
ON orders(customer_id, order_date);

The index order is:

customer_id
    ↓
order_date

Column order matters.

26. Leftmost Prefix Concept

For:

(customer_id, order_date)

a query using:

customer_id

can generally benefit from the index.

A query using:

customer_id + order_date

can also benefit.

A query using only:

order_date

does not automatically get the same benefit.

This is an important composite-index principle.

27. Composite Index Example

The project creates:

CREATE INDEX idx_orders_status_date
ON orders(status, order_date);

This supports query patterns such as:

WHERE status = 'DELIVERED'
AND order_date >= '2025-01-01'

The actual execution plan should be used to verify whether the index is selected.

28. Covering Index

A covering index contains enough indexed information to satisfy the columns required by a query without needing additional table-row access for those columns.

The project demonstrates:

(customer_id, order_date, status, total_amount)

as a covering-style index.

Whether a query is fully covered depends on every required column and the actual plan.

29. Sargable Predicates

A sargable predicate allows the optimizer to efficiently use an index access path.

Good example:

WHERE order_date >= '2025-04-01'
AND order_date < '2025-05-01'

The indexed column is directly compared with values.

30. Non-Sargable Predicates

A common problematic pattern is:

WHERE DATE(order_date) = '2025-04-01'

A function is applied to the indexed column.

This can make ordinary index usage less effective for that predicate.

The project compares this query with a range-based version.

31. Better Date Filtering

Instead of:

WHERE DATE(order_date) = '2025-04-01'

use:

WHERE order_date >= '2025-04-01'
AND order_date < '2025-04-02'

For a month:

WHERE order_date >= '2025-04-01'
AND order_date < '2025-05-01'

This keeps the column directly searchable.

32. SELECT *

The project intentionally compares:

SELECT *

with selecting only required columns.

SELECT * is not automatically slow.

However, it can retrieve more data than the application actually needs.

Prefer:

SELECT
    order_id,
    order_date,
    total_amount

when those are the only required values.

33. Why Fewer Columns Can Help

Selecting only required columns can reduce:

Result size
Network traffic
Memory
Application processing
I/O

It can also make covering indexes more practical.

34. JOIN Optimization

Joins are common areas for SQL performance problems.

This project uses:

customers
orders
order_items
products

to demonstrate multi-table execution plans.

Important join columns should have suitable indexes.

35. Join Keys

Examples include:

orders.customer_id
    ↓
customers.customer_id

order_items.order_id
    ↓
orders.order_id

order_items.product_id
    ↓
products.product_id

These relationships are indexed appropriately in the project.

36. Filtering

Filtering can reduce the amount of data that later operations need to process.

For example:

WHERE status = 'DELIVERED'

can reduce rows before aggregation.

However, remember that the optimizer may internally reorder operations.

The SQL text does not necessarily represent the physical execution order.

37. GROUP BY

The project includes:

GROUP BY customer_id

with:

COUNT()
SUM()

Aggregation can become expensive when a large number of rows must be processed.

Indexes and selective filters may help reduce the amount of work.

38. ORDER BY

Sorting can be expensive for large result sets.

Example:

ORDER BY order_date DESC

If the filtering and ordering pattern is compatible with an index, the database may be able to reduce sorting work.

Always verify using the execution plan.

39. LIMIT

Consider:

ORDER BY order_date DESC
LIMIT 5;

When only a few rows are needed, LIMIT can reduce result processing.

This is useful for:

Latest orders
Top products
Recent transactions
Dashboards
Leaderboards
Pagination

40. EXISTS vs IN

The project compares:

IN

and:

EXISTS

Both can be valid.

Neither should be considered universally faster.

Performance depends on:

Optimizer
Indexes
Data distribution
Query structure
Table sizes

Use execution plans to compare them.

41. EXISTS

Example:

WHERE EXISTS (
    SELECT 1
    FROM orders AS o
    WHERE o.customer_id = c.customer_id
)

This asks whether at least one matching row exists.

It is useful when the actual values from the subquery are not required.

42. IN

Example:

WHERE customer_id IN (
    SELECT customer_id
    FROM orders
)

This compares an outer value against the subquery result.

Modern optimizers can transform many IN and EXISTS queries.

Measure actual performance instead of relying on blanket rules.

43. UNION vs UNION ALL

UNION removes duplicate rows.

UNION ALL preserves duplicates.

Therefore:

UNION

may require duplicate-elimination work.

If duplicates are intentionally allowed:

UNION ALL

is generally the appropriate operation.

44. Correlated Subqueries

A correlated subquery references a column from the outer query.

Example:

SELECT c.customer_id
FROM customers AS c
WHERE (
    SELECT COUNT(*)
    FROM orders AS o
    WHERE o.customer_id = c.customer_id
) >= 2;

The project compares this with:

JOIN + GROUP BY

The correct choice should be based on actual execution behavior and readability.

45. Query Rewriting

Optimization can involve rewriting a query.

Examples:

Replace unnecessary functions
Use sargable date ranges
Select only required columns
Avoid unnecessary subqueries
Use UNION ALL when appropriate
Reduce unnecessary processing
Use suitable joins

Query rewriting should always preserve correctness.

46. EXPLAIN ANALYZE Workflow

A useful workflow is:

Run Query
    ↓
Measure Baseline
    ↓
EXPLAIN
    ↓
Inspect Plan
    ↓
Identify Bottleneck
    ↓
Change Query / Index
    ↓
EXPLAIN Again
    ↓
EXPLAIN ANALYZE
    ↓
Compare Results

This is much better than optimizing based on assumptions.

47. Estimated vs Actual Rows

EXPLAIN ANALYZE allows you to compare estimated behavior with actual behavior.

For example:

Estimated rows: 10
Actual rows:    10,000

A large difference can indicate that the optimizer's estimates do not match reality.

This can be important when diagnosing unexpected query plans.

48. Query Optimization Is Measurement-Driven

A good optimization process starts with evidence.

Ask:

What is slow?
How slow is it?
How many rows are involved?
Which index is being used?
How many rows are examined?
Where is the bottleneck?

Then make a targeted change.

49. Index Inspection

The project uses:

INFORMATION_SCHEMA.STATISTICS

to inspect indexes.

This helps determine:

Which indexes exist
Which columns they contain
Column order
Index definitions

This is especially useful when investigating an existing database.

50. Table Size Inspection

The project uses:

INFORMATION_SCHEMA.TABLES

to inspect:

TABLE_ROWS
DATA_LENGTH
INDEX_LENGTH

This provides a basic view of table and index storage.

51. Statistics

The optimizer relies on statistics to estimate costs.

If statistics do not accurately represent current data distribution, estimated row counts may differ substantially from actual values.

This is one reason realistic data and current statistics matter during performance testing.

52. Small Dataset Limitation

The sample dataset in this project is intentionally small.

Therefore:

Performance differences may be tiny.

That is expected.

To study meaningful performance differences, generate larger datasets such as:

100,000 rows
1,000,000 rows
10,000,000 rows

and compare execution plans.

53. Production Benchmarking

A production performance test should consider:

Realistic row counts
Realistic data distribution
Concurrent users
Caching
CPU
Memory
Disk I/O
Database configuration
Network
Query frequency

A query that performs well on a development dataset may not perform well in production.

54. Full Scan Is Not Always Bad

Do not automatically assume:

Full table scan = bad

For a small table, scanning all rows can be faster than using an index.

The important factors are:

Table size
Rows required
Selectivity
Index cost
Query shape

The execution plan provides evidence.

55. Index Is Not Always Better

Do not assume:

Index = faster

If a query needs most of the table, using an index can sometimes result in unnecessary work.

The optimizer chooses between:

Index access

and:

Table scan

based on estimated cost.

56. Too Many Indexes

Excessive indexing can cause:

More storage
Slower inserts
Slower updates
Slower deletes
More maintenance
More optimizer choices

Indexes should be based on actual workload requirements.

57. Data Engineering Connection

Query optimization is essential in data engineering.

Data pipelines commonly process:

Millions of rows
Billions of rows
ETL workloads
ELT workloads
Warehouse queries
Incremental loads
Reporting queries
Aggregation jobs

An inefficient query can slow an entire pipeline.

58. Backend Development Connection

Backend applications frequently execute SQL for:

API requests
Search
Filtering
Pagination
Dashboards
Reports
Transactions
User-specific data

A slow database query can result in:

Slow API
    ↓
Higher latency
    ↓
Poor user experience

59. Before and After Optimization

A typical improvement might look conceptually like:

BEFORE

Query
  ↓
Large scan
  ↓
Many rows examined
  ↓
Expensive operation
  ↓
Slow response

After optimization:

Query
  ↓
Suitable index
  ↓
Fewer rows examined
  ↓
Less work
  ↓
Faster response

The exact improvement must be measured.

60. Production Optimization Workflow

A mature process looks like:

Monitor
   ↓
Identify slow query
   ↓
Measure
   ↓
EXPLAIN
   ↓
Diagnose
   ↓
Optimize
   ↓
Benchmark
   ↓
Validate correctness
   ↓
Deploy
   ↓
Monitor again

Optimization should be evidence-based.

61. Practical Exercise 1

Run:

EXPLAIN
SELECT *
FROM orders
WHERE customer_id = 1;

Then compare:

EXPLAIN
SELECT
    order_id,
    order_date,
    total_amount
FROM orders
WHERE customer_id = 1;

Study the execution plans.

62. Practical Exercise 2

Compare:

WHERE DATE(order_date) = '2025-04-01'

with:

WHERE order_date >= '2025-04-01'
AND order_date < '2025-04-02'

Use:

EXPLAIN

and:

EXPLAIN ANALYZE

where appropriate.

63. Practical Exercise 3

Temporarily remove a non-essential test index and compare the execution plan.

For example:

DROP INDEX idx_orders_customer_date
ON orders;

Then recreate it:

CREATE INDEX idx_orders_customer_date
ON orders(customer_id, order_date);

Compare the plans before and after.

64. Practical Exercise 4

Generate a larger orders dataset.

Start with:

100,000 orders

Then test:

1,000,000 orders

Compare:

Execution time
Rows examined
Chosen indexes
Execution plans

65. Practical Exercise 5

Compare:

UNION

and:

UNION ALL

using a larger dataset with duplicate values.

Observe the execution plan.

66. Practical Exercise 6

Compare:

Correlated subquery

with:

JOIN + GROUP BY

using a larger orders table.

Use:

EXPLAIN ANALYZE

to compare actual execution behavior.

67. Interview Questions

What is EXPLAIN?

EXPLAIN shows the optimizer's planned execution strategy.

What is EXPLAIN ANALYZE?

It executes the query and provides actual execution information.

What is a full table scan?

An access strategy that examines a broad portion of the table instead of locating a smaller subset through an appropriate index.

What is an index?

A data structure that helps the database locate rows efficiently.

What is a composite index?

An index containing multiple columns.

Why does composite-index column order matter?

Because the index is ordered by its leading columns, which affects which predicates can efficiently use it.

What is a covering index?

An index that contains enough information for a query to avoid additional table-row lookups for the required columns.

What is a sargable predicate?

A predicate that can be efficiently used with an index access path.

Why can functions on indexed columns be problematic?

Because applying a function to the indexed column can prevent efficient use of its original index ordering for that predicate.

Is EXISTS always faster than IN?

No. Actual performance depends on the query, optimizer, indexes, and data.

Is UNION ALL always better than UNION?

No. UNION ALL avoids duplicate elimination, but UNION is necessary when duplicate removal is required.

68. Common Mistakes

Mistake 1 — Adding indexes blindly

Indexes have storage and write-maintenance costs.

Mistake 2 — Assuming every full scan is bad

Small tables can be efficiently scanned.

Mistake 3 — Assuming every index is used

The optimizer may choose another strategy.

Mistake 4 — Optimizing without measuring

Always establish a baseline.

Mistake 5 — Changing a query without checking correctness

Performance improvements must preserve the intended result.

Mistake 6 — Ignoring data volume

Performance characteristics can change dramatically as tables grow.

Mistake 7 — Using non-sargable predicates unnecessarily

Prefer index-friendly predicates where appropriate.

Mistake 8 — Selecting unnecessary columns

Large result sets increase data transfer and processing.

69. Production-Level Checklist

Before optimization:

[ ] Identify the slow query
[ ] Capture baseline execution time
[ ] Run EXPLAIN
[ ] Check access type
[ ] Check possible keys
[ ] Check chosen key
[ ] Check estimated rows
[ ] Check joins
[ ] Check filtering
[ ] Check sorting
[ ] Check aggregation

After optimization:

[ ] Run EXPLAIN again
[ ] Run EXPLAIN ANALYZE
[ ] Compare execution behavior
[ ] Compare rows examined
[ ] Compare execution time
[ ] Verify result correctness
[ ] Test realistic data
[ ] Check write-side impact
[ ] Monitor after deployment

70. Key Takeaways

1. Correct SQL is not necessarily efficient SQL.
2. EXPLAIN shows the planned execution strategy.
3. EXPLAIN ANALYZE shows actual execution behavior.
4. Indexes can reduce unnecessary row scanning.
5. Composite-index column order matters.
6. Covering indexes can reduce table lookups.
7. Selectivity influences index usefulness.
8. Cardinality influences optimizer decisions.
9. Full table scans are not automatically bad.
10. Functions on indexed columns can reduce index efficiency.
11. Sargable predicates are generally preferable.
12. Selecting only required columns can reduce work.
13. Join columns should have suitable indexes.
14. GROUP BY can become expensive on large datasets.
15. ORDER BY can require significant sorting.
16. LIMIT can reduce result processing.
17. EXISTS and IN should be evaluated using actual plans.
18. UNION removes duplicates.
19. UNION ALL preserves duplicates.
20. Correlated subqueries can sometimes be rewritten.
21. More indexes are not always better.
22. Query optimization should be evidence-based.
23. Realistic data is important for benchmarking.
24. SQL performance is important in data engineering.
25. SQL performance is important in backend development.

71. Completion Checklist

[ ] Created optimization database
[ ] Created customers table
[ ] Created products table
[ ] Created orders table
[ ] Created order_items table
[ ] Added primary keys
[ ] Added foreign keys
[ ] Added indexes
[ ] Inserted sample data
[ ] Ran baseline queries
[ ] Used EXPLAIN
[ ] Used EXPLAIN ANALYZE
[ ] Studied access types
[ ] Studied possible indexes
[ ] Studied selected indexes
[ ] Studied estimated rows
[ ] Practiced composite indexes
[ ] Practiced covering indexes
[ ] Compared sargable predicates
[ ] Compared non-sargable predicates
[ ] Compared EXISTS and IN
[ ] Compared UNION and UNION ALL
[ ] Compared correlated subquery and JOIN
[ ] Studied GROUP BY
[ ] Studied ORDER BY
[ ] Inspected indexes
[ ] Inspected table sizes
[ ] Reviewed production optimization practices

72. Final Lesson

The central idea of Day 73 is:

Do not only write SQL.

Understand how the database executes SQL.

The optimization cycle is:

SQL Query
   ↓
EXPLAIN
   ↓
Execution Plan
   ↓
Find Bottleneck
   ↓
Rewrite Query / Modify Index
   ↓
EXPLAIN ANALYZE
   ↓
Measure
   ↓
Validate

The goal is not to make SQL unnecessarily complicated.

The goal is to make the database perform the minimum necessary work while producing the correct result.

73. Final Day 73 Summary

SQL Query Optimization
        ↓
Execution Plans
        ↓
EXPLAIN
        ↓
EXPLAIN ANALYZE
        ↓
Indexes
        ↓
Composite Indexes
        ↓
Covering Indexes
        ↓
Sargable Queries
        ↓
Efficient Joins
        ↓
Efficient Aggregation
        ↓
Efficient Sorting
        ↓
Measured Performance

Day 73 adds an important production-level SQL skill:

Understanding not only WHAT query to write,
but also HOW the database executes that query.

This is valuable for:

Data Engineers
Backend Developers
Database Engineers
Analytics Engineers
Data Analysts
Software Engineers

74. Day 73 Completion

After completing this project, you should be comfortable opening an unfamiliar SQL query and asking:

How many rows will this touch?

Is an index being used?

Which index is being used?

Is the filter selective?

Is the join efficient?

Is sorting required?

Is aggregation expensive?

Can the predicate be made sargable?

Can the query be simplified?

What does EXPLAIN ANALYZE actually show?

That mindset is the foundation of production SQL performance engineering.