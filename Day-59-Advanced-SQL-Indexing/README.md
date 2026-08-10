# Day 59 - Advanced SQL Indexing

##  Overview

SQL Indexing is one of the most important concepts for improving database query performance.

An **index** is a data structure maintained by the database to help locate rows more efficiently without having to examine every row in the table.

Indexes become especially important when working with large databases containing thousands, millions, or even billions of records.

In this lesson, we learn how different types of indexes work, how to create and remove indexes, how composite indexes work, how `EXPLAIN` can be used to analyze index usage, and when indexes should or should not be created.

---

#  Learning Objectives

By the end of this lesson, you will understand:

- What SQL indexes are
- Why indexes are required
- How indexes improve query performance
- Primary key indexes
- Unique indexes
- Single-column indexes
- Composite indexes
- Clustered indexes
- Secondary indexes
- Covering indexes
- Leftmost-prefix principle
- Index selectivity
- Index advantages and disadvantages
- How to analyze indexes using `EXPLAIN`
- How to create and remove indexes
- When indexes should be used
- When indexes may hurt performance

---

# 🗄️ Database Used

```sql
CREATE DATABASE indexing_db;

USE indexing_db;
```

---

# 📋 Employee Table

The examples in this lesson use an `employees` table.

```sql
CREATE TABLE employees(
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    department VARCHAR(30),
    salary DECIMAL(10,2),
    city VARCHAR(50),
    email VARCHAR(100) UNIQUE
);
```

The table contains:

| Column | Description |
|--------|-------------|
| `emp_id` | Unique employee identifier |
| `emp_name` | Employee name |
| `department` | Employee department |
| `salary` | Employee salary |
| `city` | Employee city |
| `email` | Unique employee email |

---

# 1. What is an Index?

An index is a database data structure that helps the database find rows more efficiently.

Without an appropriate index, the database may need to examine many rows to find the required records.

For example:

```sql
SELECT *
FROM employees
WHERE salary > 70000;
```

If there is no suitable index, the database may need to inspect many rows.

We can create an index on `salary`:

```sql
CREATE INDEX idx_salary
ON employees(salary);
```

Then analyze the query:

```sql
EXPLAIN
SELECT *
FROM employees
WHERE salary > 70000;
```

---

# 2. Why Do We Need Indexes?

Consider a table containing:

```text
100 rows
1,000 rows
100,000 rows
1,000,000 rows
10,000,000 rows
```

Searching through a large table can become expensive.

An appropriate index can allow the database to locate matching rows more efficiently.

Indexes are especially useful for:

- `WHERE` conditions
- `JOIN` conditions
- `ORDER BY`
- Unique lookups
- Frequently searched columns

---

# 3. Primary Key Index

A primary key uniquely identifies every row.

Example:

```sql
CREATE TABLE employees(
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50)
);
```

In MySQL's InnoDB storage engine, the primary key normally serves as the table's **clustered index**.

Therefore, a query such as:

```sql
SELECT *
FROM employees
WHERE emp_id = 104;
```

can efficiently locate a specific employee.

---

# 4. Unique Index

A `UNIQUE` constraint prevents duplicate values.

Example:

```sql
email VARCHAR(100) UNIQUE
```

MySQL creates a unique index to enforce the uniqueness requirement.

Example:

```sql
SELECT *
FROM employees
WHERE email = 'robert@gmail.com';
```

Because email values are unique, this is an efficient lookup pattern.

---

# 5. Single-Column Index

A single-column index contains one indexed column.

Example:

```sql
CREATE INDEX idx_salary
ON employees(salary);
```

This can help queries such as:

```sql
SELECT *
FROM employees
WHERE salary > 70000;
```

The database optimizer decides whether using the index is actually beneficial.

---

# 6. Composite Index

A composite index contains multiple columns.

Example:

```sql
CREATE INDEX idx_department_salary
ON employees(department, salary);
```

The index contains the columns in this order:

```text
department
     ↓
salary
```

This can be useful for queries such as:

```sql
SELECT *
FROM employees
WHERE department = 'IT'
AND salary > 70000;
```

---

# 7. Column Order in Composite Indexes

Column order is extremely important.

Consider:

```sql
INDEX(department, salary)
```

The first column is:

```text
department
```

and the second column is:

```text
salary
```

The database organizes the index according to this order.

Therefore, the following query can generally make good use of the index:

```sql
WHERE department = 'IT'
```

and:

```sql
WHERE department = 'IT'
AND salary > 70000
```

---

# 8. Leftmost-Prefix Principle

The **leftmost-prefix principle** describes how composite indexes can be used.

Suppose we have:

```sql
CREATE INDEX idx_department_salary
ON employees(department, salary);
```

The index can generally support:

```sql
WHERE department = 'IT'
```

and:

```sql
WHERE department = 'IT'
AND salary > 70000
```

However, a query using only:

```sql
WHERE salary > 70000
```

cannot generally use this composite index as effectively because `department` is the first indexed column.

Therefore:

```text
INDEX(department, salary)

       ↓
Leading Column
       ↓
department
       ↓
salary
```

The leading column matters.

---

# 9. Clustered Index

In MySQL's **InnoDB** storage engine, table data is organized around a clustered index.

The primary key is normally the clustered index.

Example:

```sql
CREATE TABLE employees(
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50)
);
```

Here:

```text
emp_id
  ↓
Primary Key
  ↓
Clustered Index
```

A table has one clustered index organization.

---

# 10. Secondary Index

Indexes other than the clustered index are called **secondary indexes** in InnoDB terminology.

Example:

```sql
CREATE INDEX idx_salary
ON employees(salary);
```

This is a secondary index.

A secondary index stores the indexed values along with information that allows InnoDB to locate the corresponding table record.

---

# 11. Clustered vs Secondary Index

| Clustered Index | Secondary Index |
|----------------|-----------------|
| Organizes the InnoDB table data | Separate index structure |
| Usually based on the primary key | Created for additional access patterns |
| One clustered organization per table | Multiple secondary indexes possible |
| Important for primary-key access | Useful for filtering, joins, sorting, etc. |

---

# 12. Covering Index

A **covering index** contains all the columns needed by a particular query.

Example:

```sql
CREATE INDEX idx_department_salary_name
ON employees(department, salary, emp_name);
```

Consider:

```sql
SELECT
    department,
    salary,
    emp_name
FROM employees
WHERE department = 'IT';
```

The index contains:

```text
department
salary
emp_name
```

which are all the columns required by the query.

Therefore, MySQL may be able to obtain the required data directly from the index instead of performing additional table-row lookups.

Always use `EXPLAIN` to verify the actual execution plan.

---

# 13. Normal Index vs Covering Index

### Normal Index

```text
Query
  ↓
Index
  ↓
Table Row
  ↓
Result
```

### Covering Index

```text
Query
  ↓
Index
  ↓
Result
```

A covering index can reduce additional table access for suitable queries.

---

# 14. Index Selectivity

**Selectivity** describes how effectively an index can narrow down the rows.

For example:

```text
emp_id
```

usually has high selectivity because each value is unique.

A column such as:

```text
department
```

may have lower selectivity because many employees can belong to the same department.

In general, highly selective columns can be good index candidates, but actual query workload and data distribution must be considered.

---

# 15. Indexes and WHERE

Indexes are commonly used for filtering.

Example:

```sql
CREATE INDEX idx_department
ON employees(department);
```

Query:

```sql
SELECT *
FROM employees
WHERE department = 'IT';
```

Analyze it:

```sql
EXPLAIN
SELECT *
FROM employees
WHERE department = 'IT';
```

---

# 16. Indexes and JOINs

Indexes can also improve queries involving joins.

Example:

```sql
SELECT
    e.emp_name,
    d.department_name
FROM employees e
JOIN departments d
ON e.department_id = d.department_id;
```

Columns frequently used in join conditions are possible candidates for indexing.

However, the optimizer decides whether an index should actually be used.

---

# 17. Indexes and ORDER BY

Indexes can sometimes help with sorting.

Example:

```sql
SELECT
    emp_name,
    salary
FROM employees
ORDER BY salary;
```

Analyze it with:

```sql
EXPLAIN
SELECT
    emp_name,
    salary
FROM employees
ORDER BY salary;
```

Do not assume that creating an index will always eliminate sorting.

The optimizer considers the complete query and available indexes.

---

# 18. EXPLAIN

`EXPLAIN` is one of the most important tools for understanding query performance.

Example:

```sql
EXPLAIN
SELECT *
FROM employees
WHERE salary > 70000;
```

Important columns include:

| Column | Meaning |
|--------|---------|
| `id` | Query identifier |
| `select_type` | Type of SELECT |
| `table` | Table being accessed |
| `type` | Access method |
| `possible_keys` | Possible indexes |
| `key` | Index actually selected |
| `rows` | Estimated rows examined |
| `Extra` | Additional execution information |

---

# 19. Important EXPLAIN Field: `key`

The `key` column tells us which index MySQL selected for the table access.

For example:

```text
key = idx_salary
```

means MySQL selected the `idx_salary` index for that access.

If:

```text
key = NULL
```

then no index was selected for that table access.

This does not automatically mean the query is bad. The optimizer may determine that an index would not be beneficial.

---

# 20. Important EXPLAIN Field: `rows`

The `rows` column provides an estimate of how many rows MySQL expects to examine.

Generally:

```text
Fewer rows examined
        ↓
Less work
        ↓
Potentially better performance
```

It is an estimate, not necessarily the exact number of rows processed.

---

# 21. Important EXPLAIN Field: `type`

The `type` column describes the access method.

Common values include:

```text
const
eq_ref
ref
range
index
ALL
```

In general, `ALL` indicates a full table scan.

But access type alone should not be used to judge performance. The complete execution plan and actual workload matter.

---

# 22. Full Table Scan

A full table scan occurs when MySQL examines rows across the table to find matching records.

For example, if there is no suitable index:

```sql
SELECT *
FROM employees
WHERE salary > 70000;
```

MySQL may need to inspect a large portion of the table.

On a very large table, this can become expensive.

---

# 23. When Indexes Help

Indexes are often useful when:

- The table is large.
- A column is frequently used in `WHERE`.
- A column is used for joins.
- Queries frequently perform selective searches.
- A column is frequently used for sorting.
- Unique lookups are common.

---

# 24. When Indexes May Not Help

Indexes are not automatically beneficial.

They may provide limited benefit when:

- The table is very small.
- A query returns a large percentage of the table.
- The indexed column has low selectivity.
- The index is never used.
- The query pattern does not match the index.
- The optimizer determines a table scan is cheaper.

---

# 25. Too Many Indexes

Creating many indexes can hurt database performance.

Every index requires:

- Disk space
- Memory/cache resources
- Maintenance during `INSERT`
- Maintenance during `UPDATE`
- Maintenance during `DELETE`

For example:

```text
INSERT
   ↓
Table updated
   ↓
Indexes also updated
```

Therefore, indexes improve some read operations but add write overhead.

---

# 26. Creating an Index

Syntax:

```sql
CREATE INDEX index_name
ON table_name(column_name);
```

Example:

```sql
CREATE INDEX idx_city
ON employees(city);
```

---

# 27. Creating a Composite Index

Syntax:

```sql
CREATE INDEX index_name
ON table_name(column1, column2);
```

Example:

```sql
CREATE INDEX idx_department_salary
ON employees(department, salary);
```

---

# 28. Viewing Indexes

Use:

```sql
SHOW INDEX FROM employees;
```

This displays information about the indexes defined on the table.

---

# 29. Dropping an Index

An index can be removed when it is unnecessary.

Syntax:

```sql
DROP INDEX index_name
ON table_name;
```

Example:

```sql
DROP INDEX idx_salary
ON employees;
```

---

# 30. Indexing Best Practices

### 1. Understand the Query

First understand which columns are frequently searched.

### 2. Use EXPLAIN

Analyze the execution plan.

### 3. Avoid Excessive Indexes

Do not index every column.

### 4. Consider Column Order

Column order matters in composite indexes.

### 5. Consider Selectivity

Highly selective columns can often be useful index candidates.

### 6. Measure Performance

Compare performance before and after adding an index.

### 7. Consider Write Performance

Remember that indexes also increase write maintenance.

---

# 31. Practical Optimization Workflow

A good indexing workflow is:

```text
Identify Slow Query
        ↓
Run EXPLAIN
        ↓
Analyze Execution Plan
        ↓
Check Existing Indexes
        ↓
Create Appropriate Index
        ↓
Run EXPLAIN Again
        ↓
Measure Performance
```

---

# 32. Real-World Applications

## E-Commerce

Indexes can improve:

- Product searches
- Customer lookups
- Order searches

---

## Banking

Indexes can improve:

- Account lookups
- Transaction searches
- Customer queries

---

## Healthcare

Indexes can improve:

- Patient searches
- Appointment queries
- Medical record lookups

---

## Data Engineering

Indexes can improve:

- ETL queries
- Large-table filtering
- Reporting queries
- Data warehouse access patterns

---

# 🧠 Important Concepts to Remember

```text
Primary Key
     ↓
Clustered Index in InnoDB
```

```text
CREATE INDEX
     ↓
Secondary Index
```

```text
INDEX(column1, column2)
     ↓
Column Order Matters
     ↓
Leftmost-Prefix Principle
```

```text
EXPLAIN
     ↓
Execution Plan
     ↓
Check Index Usage
```

```text
Good Index
     ↓
Potentially Faster Reads
```

```text
Too Many Indexes
     ↓
More Storage + Write Overhead
```

---

# 🎤 Interview Questions

## 1. What is an index?

An index is a database data structure that helps the database locate rows more efficiently.

---

## 2. Why are indexes used?

Indexes are primarily used to improve the performance of suitable read queries.

---

## 3. What is a composite index?

A composite index is an index created using multiple columns.

```sql
CREATE INDEX idx_department_salary
ON employees(department, salary);
```

---

## 4. What is the leftmost-prefix principle?

For a composite index such as:

```sql
(department, salary)
```

the leading column `department` is important for efficiently using the index.

---

## 5. What is a clustered index?

In InnoDB, the clustered index determines how the table data is organized. The primary key is normally the clustered index.

---

## 6. What is a secondary index?

A secondary index is an index other than the clustered index.

---

## 7. What is a covering index?

A covering index contains all the columns needed by a query, allowing the database to potentially satisfy the query directly from the index.

---

## 8. Can indexes slow down a database?

Yes.

Indexes can improve read performance but increase storage requirements and write overhead.

---

## 9. Should every column be indexed?

No.

Indexes should be created according to actual query patterns and performance requirements.

---

## 10. How do you check whether an index is being used?

Use:

```sql
EXPLAIN
```

and inspect fields such as:

```text
possible_keys
key
rows
type
Extra
```

---

# 📝 Practice Problems

Try these yourself before checking the solution.

### Problem 1

Create an index on `city`.

```sql
CREATE INDEX idx_city
ON employees(city);
```

Then analyze:

```sql
EXPLAIN
SELECT *
FROM employees
WHERE city = 'Mumbai';
```

---

### Problem 2

Create a composite index suitable for:

```sql
WHERE department = 'IT'
AND city = 'Mumbai'
```

---

### Problem 3

Display all indexes:

```sql
SHOW INDEX FROM employees;
```

---

### Problem 4

Create an index on `emp_name` and analyze:

```sql
EXPLAIN
SELECT *
FROM employees
WHERE emp_name = 'David';
```

---

### Problem 5

Create a covering index suitable for:

```sql
SELECT
    department,
    salary,
    emp_name
FROM employees
WHERE department = 'Finance';
```

Think about which columns the index needs to contain.

---

# 🔑 Key Takeaway

The most important idea from today's lesson is:

```text
SQL Query
    ↓
EXPLAIN
    ↓
Execution Plan
    ↓
Understand Access Pattern
    ↓
Choose Appropriate Index
    ↓
EXPLAIN Again
    ↓
Measure Performance
```

An index is **not automatically beneficial just because it exists**.

Good database optimization means creating the **right indexes for the actual workload**.

---

# 🚀 GitHub

After completing today's SQL practice:

```bash
git add .
git commit -m "Day 59 - Advanced SQL Indexing"
git push
```

---

# 🏆 SQL-A-Day Progress

```text
✅ Day 50 - Employee Management System
✅ Day 51 - Common Table Expressions
✅ Day 52 - SQL Window Functions
✅ Day 53 - Window Aggregate Functions
✅ Day 54 - LEAD() and LAG()
✅ Day 55 - FIRST_VALUE(), LAST_VALUE(), NTH_VALUE()
✅ Day 56 - NTILE(), PERCENT_RANK(), CUME_DIST()
✅ Day 57 - Real-World SQL Analytics
✅ Day 58 - SQL Query Optimization & EXPLAIN
🔥 Day 59 - Advanced SQL Indexing
```

## 🎯 Next: Day 60

**Day 60 will be a major SQL Analytics Project**, combining the advanced concepts you've learned from Days 51–59:

- CTEs
- Window Functions
- Ranking
- Aggregations
- `LAG()` / `LEAD()`
- Advanced filtering
- Indexing
- `EXPLAIN`
- Business analytics
- Real-world SQL problems

 **50+ days completed. Keep the streak going!** 