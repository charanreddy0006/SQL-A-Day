# Day 40 - SQL Indexes

# Introduction

An Index is a special database object that improves the speed of data retrieval.

Instead of scanning every row in a table, SQL uses the index to quickly locate matching records.

Indexes improve SELECT performance but require additional storage and maintenance.

---

# What is an Index?

An Index is similar to the index of a book.

Instead of reading every page, you jump directly to the required page.

Similarly,

Without Index

Table Scan

```
John
David
Emma
Robert
Sophia
James
```

SQL checks every row.

With Index

```
David
↓
Directly Found
```

---

# Why Do We Need Indexes?

Without an index:

- SQL performs a Full Table Scan.
- Slower for large tables.

With an index:

- Faster searching.
- Faster filtering.
- Faster sorting.

---

# Syntax

## Create Index

```sql
CREATE INDEX index_name
ON table_name(column_name);
```

---

## Create UNIQUE Index

```sql
CREATE UNIQUE INDEX index_name
ON table_name(column_name);
```

---

## Drop Index

```sql
DROP INDEX index_name
ON table_name;
```

---

# Example 1

```sql
CREATE INDEX idx_employee_name
ON employees(emp_name);
```

Searching by employee name becomes faster.

---

# Example 2

```sql
CREATE UNIQUE INDEX idx_employee_email
ON employees(email);
```

Email must now remain unique.

---

# Example 3

```sql
SHOW INDEX
FROM employees;
```

Displays all indexes created on the table.

---

# Clustered vs Non-Clustered Index

| Clustered Index | Non-Clustered Index |
|-----------------|---------------------|
|Data stored in index order|Separate structure pointing to data|
|Only one per table|Multiple allowed|
|Very fast range searches|Good for frequently searched columns|

**Note:** In MySQL (InnoDB), the **PRIMARY KEY** is the clustered index.

---

# Advantages

- Faster SELECT queries.
- Faster WHERE filtering.
- Faster ORDER BY.
- Faster JOIN operations.

---

# Disadvantages

- Uses additional disk space.
- Slows INSERT, UPDATE, and DELETE operations because indexes must also be updated.
- Too many indexes can reduce overall performance.

---

# Real-World Applications

## Banking

Quickly search customer accounts using Account Number.

---

## E-Commerce

Search products using Product ID or Product Name.

---

## College Management

Find students using Roll Number.

---

## Hospital

Search patients using Patient ID.

---

# Common Mistakes

## Creating Indexes on Small Tables

Small tables usually don't benefit much from indexes.

---

## Creating Too Many Indexes

More indexes improve reads but slow down writes.

---

# Practice Queries

```sql
CREATE INDEX idx_department
ON employees(department);

SHOW INDEX
FROM employees;

DROP INDEX idx_department
ON employees;
```

---

# Interview Questions

## What is an Index?

A database object that speeds up data retrieval.

---

## Does an Index store data?

No.

It stores references that help locate rows quickly.

---

## Which SQL operations benefit the most from indexes?

- SELECT
- WHERE
- ORDER BY
- JOIN

---

## What is the disadvantage of indexes?

They consume storage and slow INSERT, UPDATE, and DELETE operations.

---

# Summary

Today I learned:

- Index
- CREATE INDEX
- UNIQUE INDEX
- DROP INDEX
- SHOW INDEX
- Clustered Index
- Non-Clustered Index
- Advantages and Disadvantages

Indexes improve query performance by allowing SQL to locate records efficiently without scanning the entire table.