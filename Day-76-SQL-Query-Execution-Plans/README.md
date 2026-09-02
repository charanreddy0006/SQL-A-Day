Day 76 — SQL Query Execution Plans & Performance Analysis

Welcome to Day 76 of SQL-A-Day 🚀

Today we move from simply writing SQL queries to understanding how MySQL executes those queries.

A query can return the correct result and still be inefficient.

For example:

SELECT *
FROM orders
WHERE customer_id = 5000;

The important question is not only:

"Does this query return the correct data?"

We should also ask:

"How is MySQL finding that data?"

That is where Query Execution Plans come in.

Topic

SQL Query Execution Plans & Performance Analysis

Today we learn:

EXPLAIN

EXPLAIN ANALYZE

Query execution plans

Table scans

Index scans

Index lookups

possible_keys

key

rows

filtered

Extra

Sargability

Composite indexes

Index column order

LIKE and indexes

ORDER BY ... LIMIT

Covering indexes

Join execution plans

Aggregation execution plans

Optimizer statistics

ANALYZE TABLE

FORCE INDEX

Query optimization workflow

1. What Is a Query Execution Plan?

When we write a SQL query, MySQL has to decide how to execute it.

For example:

EXPLAIN
SELECT *
FROM orders
WHERE customer_id = 5000;

MySQL could potentially:

Scan the entire orders table
        OR
Use an index on customer_id

The database optimizer evaluates possible strategies and chooses a plan.

An execution plan describes the strategy MySQL intends to use to execute a query.

2. Why Are Execution Plans Important?

Consider a table containing:

100 rows

A full table scan may be perfectly fine.

But consider:

100 million rows

A full table scan could become extremely expensive.

Therefore, database performance depends heavily on:

Query design

Index design

Data volume

Data distribution

Join strategy

Filtering

Sorting

Aggregation

Optimizer decisions

Execution plans allow us to inspect these decisions.

3. The Main Tools

MySQL provides two important commands for this topic.

EXPLAIN

EXPLAIN
SELECT *
FROM orders
WHERE customer_id = 5000;

It shows the execution plan that MySQL intends to use.

EXPLAIN ANALYZE

EXPLAIN ANALYZE
SELECT *
FROM orders
WHERE customer_id = 5000;

It executes the query and provides actual execution information.

A simple way to remember the difference:

EXPLAIN
    ↓
Planned execution

EXPLAIN ANALYZE
    ↓
Actual execution + analysis

4. Today's Project

Today we create a practical project:

SQL Query Performance Lab

The database is:

query_performance_lab

It contains:

customers
products
orders
order_items
numbers

The purpose is to create enough data to make execution-plan analysis meaningful.

5. Database Architecture

The main relationship is:

customers
     |
     | 1
     |
     | many
     ↓
  orders
     |
     | 1
     |
     | many
     ↓
order_items
     |
     | many
     |
     | 1
     ↓
 products

6. Customers Table

The customers table stores customer information.

Important columns:

customer_id
customer_name
email
city
signup_date
customer_status

Example:

SELECT *
FROM customers
LIMIT 10;

7. Orders Table

The orders table stores customer orders.

Important columns:

order_id
customer_id
order_date
order_status
total_amount
shipping_city

Example:

SELECT *
FROM orders
LIMIT 10;

8. Generating Test Data

The project generates:

10,000 customers
50,000 orders
50,000 order items
10 products

This gives us a more realistic environment for performance experiments.

The numbers table is used as a helper table to generate predictable test data.

9. Basic EXPLAIN

The first query is:

EXPLAIN
SELECT *
FROM orders
WHERE customer_id = 5000;

The result contains information such as:

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

These columns help us understand the execution plan.

10. Important EXPLAIN Columns

id

Identifies the query block.

For a simple query it is commonly:

1

More complicated queries can contain multiple query blocks.

select_type

Shows the type of query block.

Examples include:

SIMPLE
PRIMARY
SUBQUERY
DERIVED

table

Shows the table MySQL is accessing.

For example:

orders

type

Shows the access method.

Common values include:

const
eq_ref
ref
range
index
ALL

11. Understanding ALL

One important value is:

ALL

This generally indicates a full table scan.

For example:

EXPLAIN
SELECT *
FROM orders
WHERE shipping_city = 'Hyderabad';

Before creating an index on shipping_city, MySQL may need to inspect many rows.

Conceptually:

orders
  ↓
Read many/all rows
  ↓
Check shipping_city
  ↓
Return matching rows

12. possible_keys

possible_keys tells us which indexes MySQL considers potential candidates.

Example:

possible_keys:
idx_orders_customer
idx_orders_date

This means those indexes may be useful for the query.

It does not mean that MySQL will definitely use them.

13. key

The key column tells us which index MySQL actually selected.

For example:

possible_keys = idx_orders_customer
key           = idx_orders_customer

This means the optimizer considered that index and selected it.

14. rows

The rows column provides an estimate of how many rows MySQL may need to examine.

For example:

rows = 50000

could indicate that many rows may be examined.

A much smaller estimate can be a sign that filtering is narrowing the search efficiently.

However, this is an estimate, not necessarily the exact number of rows actually processed.

15. filtered

filtered represents an estimate of how much of the examined data is expected to pass the condition.

For example:

filtered = 10.00

roughly means MySQL expects about 10% of the examined rows to satisfy the remaining filtering condition.

16. Extra

The Extra column provides additional execution information.

Depending on the query, it can show information about:

Filtering

Sorting

Temporary operations

Index usage

Other execution details

When analyzing a slow query, Extra can provide valuable clues.

17. Indexes and Execution Plans

Now we create indexes.

Example:

CREATE INDEX idx_orders_customer
ON orders(customer_id);

Then run:

EXPLAIN
SELECT *
FROM orders
WHERE customer_id = 5000;

Compare the execution plan before and after creating the index.

This is one of the most important exercises of Day 76.

18. What Is Sargability?

Sargability is the idea of writing a search condition in a form that allows the database to efficiently use an index.

Consider:

WHERE DATE(order_date) = '2025-06-15'

versus:

WHERE order_date >= '2025-06-15 00:00:00'
  AND order_date < '2025-06-16 00:00:00'

The second form directly compares the indexed column with a range.

That generally gives the optimizer a better opportunity to use a normal B-tree index efficiently.

19. Functions on Indexed Columns

Consider:

WHERE YEAR(order_date) = 2025

A better range-oriented form is:

WHERE order_date >= '2025-01-01'
  AND order_date < '2026-01-01'

The important idea is:

Function applied to column
        ↓
Potentially harder to use normal index efficiently

versus:

Direct range comparison
        ↓
More index-friendly form

Always verify the actual behavior with EXPLAIN.

20. EXPLAIN ANALYZE

Now we use:

EXPLAIN ANALYZE
SELECT
    order_id,
    customer_id,
    total_amount
FROM orders
WHERE customer_id = 5000;

Unlike ordinary EXPLAIN, this actually executes the query.

It provides information that allows us to compare optimizer estimates with actual execution behavior.

This is especially useful when estimates and reality differ significantly.

21. Why Estimates Can Be Wrong

The optimizer does not magically know every future result.

It relies on information such as:

Table statistics

Index statistics

Data distribution

Cardinality estimates

Cost calculations

If estimates are inaccurate, the optimizer may choose a less-than-ideal strategy.

This is one reason statistics matter.

22. ANALYZE TABLE

We can refresh table statistics using:

ANALYZE TABLE orders;

For multiple tables:

ANALYZE TABLE
    customers,
    orders,
    order_items,
    products;

After major data changes, updated statistics can help the optimizer make better decisions.

23. Composite Indexes

A composite index contains multiple columns.

Example:

CREATE INDEX idx_orders_customer_date_amount
ON orders(
    customer_id,
    order_date,
    total_amount
);

The index has an order:

customer_id
      ↓
order_date
      ↓
total_amount

This order matters.

24. Composite Index Example

Consider:

SELECT
    order_id,
    order_date,
    total_amount
FROM orders
WHERE customer_id = 2500
  AND order_date >= '2025-04-01'
  AND order_date < '2025-05-01';

This query matches the beginning of:

customer_id → order_date

Therefore, the composite index can be useful for this access pattern.

Run:

EXPLAIN
SELECT
    order_id,
    order_date,
    total_amount
FROM orders
WHERE customer_id = 2500
  AND order_date >= '2025-04-01'
  AND order_date < '2025-05-01';

25. Why Column Order Matters

These indexes are different:

(customer_id, order_date)

and:

(order_date, customer_id)

Suppose our query is:

WHERE customer_id = 2500
AND order_date >= ...

The first ordering is naturally aligned with the query.

This does not mean the second index is useless.

It means that index design should reflect actual query patterns.

26. Prefix Searches

We created:

CREATE INDEX idx_customers_name
ON customers(customer_name);

Now:

EXPLAIN
SELECT
    customer_id,
    customer_name
FROM customers
WHERE customer_name LIKE 'Arjun%';

This is a prefix search.

The database knows the beginning of the value:

Arjun...

This can be much more index-friendly than a search with an unknown beginning.

27. Leading Wildcards

Consider:

WHERE customer_name LIKE '%Customer 99%'

The beginning of the value is unknown.

Conceptually:

%Customer 99%
↑
unknown beginning

A normal B-tree index generally cannot efficiently narrow the search based on the unknown beginning.

For large-scale substring search, dedicated search solutions may be more appropriate.

28. ORDER BY ... LIMIT

A very common production query is:

SELECT
    order_id,
    customer_id,
    order_date,
    total_amount
FROM orders
WHERE order_status = 'DELIVERED'
ORDER BY order_date DESC
LIMIT 20;

We created:

CREATE INDEX idx_orders_status_date
ON orders(
    order_status,
    order_date
);

This index matches the filtering and ordering pattern.

But remember:

The optimizer ultimately decides whether the index is beneficial.

Always verify using:

EXPLAIN

29. Covering Index

A covering index contains the columns required by a query.

We created:

CREATE INDEX idx_orders_customer_date_amount
ON orders(
    customer_id,
    order_date,
    total_amount
);

Now:

SELECT
    customer_id,
    order_date,
    total_amount
FROM orders
WHERE customer_id = 7500
  AND order_date >= '2025-08-01'
  AND order_date < '2025-09-01';

The required columns are represented in the index.

Depending on the execution plan, MySQL may be able to obtain the required information directly from the index.

This can reduce additional table access.

30. Join Execution Plans

Execution plans are also important for joins.

Example:

SELECT
    c.customer_id,
    c.customer_name,
    o.order_id,
    o.total_amount
FROM customers AS c
JOIN orders AS o
    ON o.customer_id = c.customer_id
WHERE c.city = 'Hyderabad'
  AND o.order_status = 'DELIVERED';

Use:

EXPLAIN
SELECT ...

We can inspect:

Which table is accessed first

Which indexes are considered

Which index is selected

Estimated rows

Join relationships

Additional operations

31. EXPLAIN ANALYZE for Joins

We can also run:

EXPLAIN ANALYZE
SELECT
    c.customer_id,
    c.customer_name,
    o.order_id,
    o.total_amount
FROM customers AS c
JOIN orders AS o
    ON o.customer_id = c.customer_id
WHERE c.city = 'Hyderabad'
  AND o.order_status = 'DELIVERED';

This helps us compare optimizer estimates with actual execution behavior.

32. Aggregation Plans

Execution plans are also useful for aggregation.

Example:

SELECT
    customer_id,
    COUNT(*) AS order_count,
    SUM(total_amount) AS total_spent
FROM orders
GROUP BY customer_id;

Analyze it:

EXPLAIN
SELECT
    customer_id,
    COUNT(*) AS order_count,
    SUM(total_amount) AS total_spent
FROM orders
GROUP BY customer_id;

And:

EXPLAIN ANALYZE
SELECT
    customer_id,
    COUNT(*) AS order_count,
    SUM(total_amount) AS total_spent
FROM orders
GROUP BY customer_id;

This demonstrates that performance analysis is not limited to WHERE conditions.

33. SHOW INDEX

To inspect indexes:

SHOW INDEX FROM orders;

This helps us understand:

Index names

Indexed columns

Column order

Uniqueness

Cardinality-related information

Index structure

For customers:

SHOW INDEX FROM customers;

34. FORCE INDEX

MySQL allows us to experiment with a specific index:

SELECT
    order_id,
    customer_id,
    order_date
FROM orders FORCE INDEX (
    idx_orders_customer_date_amount
)
WHERE customer_id = 5000
  AND order_date >= '2025-01-01'
  AND order_date < '2026-01-01';

This is useful for learning because we can compare:

Optimizer-selected index
        VS
Forced index

However, forcing an index should not automatically be treated as the solution to a performance problem.

35. Query Optimization Workflow

A useful real-world workflow is:

Slow Query
    ↓
Run EXPLAIN
    ↓
Inspect execution plan
    ↓
Check indexes
    ↓
Check rows examined
    ↓
Check filtering
    ↓
Check joins
    ↓
Check sorting
    ↓
Check sargability
    ↓
Improve query/index
    ↓
Run EXPLAIN again
    ↓
Run EXPLAIN ANALYZE
    ↓
Compare actual behavior

36. Common Performance Warning Signs

When reading an execution plan, investigate things such as:

Large row estimates
Full table scans on large tables
Unexpected index selection
Expensive sorting
Large intermediate results
Poor filtering
Inefficient join access

However, none of these should be judged in isolation.

A full scan on a tiny table can be completely reasonable.

37. Common Mistakes

Mistake 1 — Assuming every query needs an index

Not every query needs an index.

Small tables can often be scanned efficiently.

Mistake 2 — Assuming every index will be used

Creating an index does not guarantee that MySQL will use it.

Mistake 3 — Creating too many indexes

Indexes require:

Storage

Maintenance

Write overhead

Update overhead

More indexes are not automatically better.

Mistake 4 — Ignoring composite-index order

These are different:

(customer_id, order_date)

and:

(order_date, customer_id)

Mistake 5 — Applying functions unnecessarily

For example:

WHERE YEAR(order_date) = 2025

may be less index-friendly than:

WHERE order_date >= '2025-01-01'
  AND order_date < '2026-01-01'

Mistake 6 — Using LIKE '%text%' blindly

A leading wildcard can prevent efficient use of a normal B-tree index for substring matching.

Mistake 7 — Using FORCE INDEX immediately

First understand why the optimizer selected its plan.

Then experiment.

Mistake 8 — Testing only on tiny datasets

A query that looks fast on 10 rows may behave very differently on millions of rows.

That is why performance testing should use representative data volumes.

38. Practice Queries

Practice 1 — City Filter

EXPLAIN
SELECT
    order_id,
    total_amount
FROM orders
WHERE shipping_city = 'Mumbai';

Questions:

Which index is selected?

How many rows are estimated?

What is the access type?

Practice 2 — Customer Status

EXPLAIN
SELECT
    customer_id,
    customer_name
FROM customers
WHERE city = 'Pune'
  AND customer_status = 'ACTIVE';

Study the composite index:

city
customer_status

Practice 3 — Compare Date Queries

First:

EXPLAIN
SELECT COUNT(*)
FROM orders
WHERE DATE(order_date) = '2025-12-10';

Then:

EXPLAIN
SELECT COUNT(*)
FROM orders
WHERE order_date >= '2025-12-10'
  AND order_date < '2025-12-11';

Compare the plans.

Practice 4 — Recent Orders

EXPLAIN ANALYZE
SELECT
    order_id,
    order_date,
    total_amount
FROM orders
WHERE order_status = 'DELIVERED'
ORDER BY order_date DESC
LIMIT 50;

Practice 5 — Customer Orders

EXPLAIN
SELECT
    c.customer_name,
    COUNT(o.order_id) AS orders_count
FROM customers AS c
JOIN orders AS o
    ON o.customer_id = c.customer_id
WHERE c.city = 'Chennai'
GROUP BY
    c.customer_id,
    c.customer_name;

39. What You Should Understand After Day 76

By the end of this day, you should understand:

Query Execution

What an execution plan is

Why MySQL needs an execution plan

How the optimizer chooses a strategy

EXPLAIN

How to use EXPLAIN

Meaning of type

Meaning of possible_keys

Meaning of key

Meaning of rows

Meaning of filtered

Meaning of Extra

Performance

Full table scans

Index access

Sargability

Composite indexes

Index column order

Prefix searches

Leading wildcards

Sorting

Aggregation

Join plans

Advanced Analysis

EXPLAIN ANALYZE

Optimizer statistics

ANALYZE TABLE

Covering-index concepts

FORCE INDEX

40. Interview Questions

1. What is EXPLAIN?

EXPLAIN shows the execution plan MySQL intends to use for a query.

2. What is EXPLAIN ANALYZE?

EXPLAIN ANALYZE executes the query and provides actual execution information in addition to optimizer estimates.

3. What is a full table scan?

A full table scan means MySQL examines the table's rows rather than narrowing access through an appropriate index.

4. Does creating an index guarantee better performance?

No.

The optimizer decides whether using an index is beneficial.

5. What is possible_keys?

It represents indexes that MySQL considers possible candidates for the query.

6. What is key?

It represents the index MySQL selected for the execution plan, when an index is selected.

7. What is a composite index?

An index containing multiple columns.

Example:

CREATE INDEX idx_customer_date
ON orders(
    customer_id,
    order_date
);

8. Why does column order matter?

Because the index is organized according to its column sequence.

The order affects which query predicates can efficiently use the index.

9. What is sargability?

Sargability refers to expressing predicates in a form that allows the database to efficiently use an index.

10. Why can this query be problematic?

WHERE YEAR(order_date) = 2025

Because a function is applied to the indexed column.

A range condition can often be more index-friendly.

11. Why can too many indexes be harmful?

Indexes consume storage and add work to data modification operations such as:

INSERT
UPDATE
DELETE

12. What is a covering index?

A covering index contains all the columns required by a query, allowing the database to potentially satisfy the query directly from the index.

13. What does ANALYZE TABLE do?

It updates table statistics used by the optimizer when estimating execution plans.

14. Why should we use EXPLAIN ANALYZE?

It helps compare optimizer estimates with actual execution behavior.

41. Important Mindset

Do not optimize SQL based only on assumptions.

Instead of saying:

"This query should be fast."

develop the habit of saying:

"Let's inspect the execution plan."

Then:

EXPLAIN
    ↓
Understand
    ↓
Optimize
    ↓
EXPLAIN again
    ↓
EXPLAIN ANALYZE
    ↓
Validate

This is the mindset used when working with production databases.

42. Project Structure

Day-76-SQL-Query-Execution-Plans/
│
├── day76.sql
└── README.md

43. How to Run the Project

Step 1 — Open MySQL

You can use:

MySQL Workbench

MySQL CLI

VS Code SQLTools

MySQL extension

Another MySQL 8+ client

Step 2 — Open the SQL File

Open:

day76.sql

Step 3 — Execute the Script

The script creates:

query_performance_lab

and generates the test data.

Step 4 — Inspect the Results

Pay special attention to:

type
possible_keys
key
rows
filtered
Extra

Step 5 — Compare Plans

The main objective is understanding:

Before Index
      ↓
Execution Plan
      ↓
Create Index
      ↓
Execution Plan
      ↓
Compare

44. Git Commands

From the root of the SQL-A-Day repository:

git add .

Commit:

git commit -m "Day 76 - SQL Query Execution Plans"

Push:

git push

45. Final Takeaway

Day 76 is an important transition from:

Learning SQL syntax

to:

Understanding SQL performance

The most important commands from today are:

EXPLAIN

and:

EXPLAIN ANALYZE

The most important lesson is:

Do not guess how the database executes a query. Inspect the execution plan and verify the behavior.

A strong SQL developer should be able to write a query and understand how the database executes it.

That skill becomes especially important when working with:

Large datasets

Data engineering pipelines

Production databases

ETL workloads

Reporting systems

Analytics systems

APIs backed by SQL

High-volume applications

Day 76 Complete 🚀

SQL-A-Day

Day 76
    ↓
Query Execution Plans
    ↓
EXPLAIN
    ↓
EXPLAIN ANALYZE
    ↓
Indexes
    ↓
Sargability
    ↓
Composite Indexes
    ↓
Performance Analysis

Next step: Day 77 — a new SQL topic.