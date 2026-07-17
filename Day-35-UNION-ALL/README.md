# Day 35 - UNION ALL

# Introduction

The UNION ALL operator combines the results of two or more SELECT statements.

Unlike UNION, UNION ALL **does not remove duplicate rows**.

Because SQL does not need to compare rows for duplicates, UNION ALL is generally faster than UNION.

It is commonly used in reporting, data migration, and analytics where every record is important.

---

# What is UNION ALL?

UNION ALL combines the results of multiple SELECT statements.

Duplicate rows are **kept**.

---

# Syntax

```sql
SELECT column1, column2
FROM table1

UNION ALL

SELECT column1, column2
FROM table2;
```

---

# Rules for UNION ALL

The same rules as UNION apply.

### Rule 1

Both SELECT statements must return the same number of columns.

### Rule 2

The corresponding columns must have compatible data types.

### Rule 3

ORDER BY should appear only once, at the end of the query.

---

# Example

Current Employees

| ID | Name |
|----|------|
|101|John|
|102|David|
|103|Emma|

Former Employees

| ID | Name |
|----|------|
|103|Emma|
|104|Robert|

Query

```sql
SELECT emp_name
FROM current_employees

UNION ALL

SELECT emp_name
FROM former_employees;
```

Output

| Name |
|------|
|John|
|David|
|Emma|
|Emma|
|Robert|

Emma appears twice because UNION ALL keeps duplicates.

---

# UNION vs UNION ALL

| UNION | UNION ALL |
|--------|-----------|
|Removes duplicate rows|Keeps duplicate rows|
|Slightly slower|Usually faster|
|Used when duplicates are not needed|Used when every record is required|

---

# Why is UNION ALL Faster?

UNION compares all rows and removes duplicates.

UNION ALL simply combines the results without checking for duplicates.

This reduces processing time, especially with large datasets.

---

# ORDER BY with UNION ALL

```sql
SELECT emp_name
FROM current_employees

UNION ALL

SELECT emp_name
FROM former_employees

ORDER BY emp_name;
```

The ORDER BY clause sorts the final combined result.

---

# Real-World Applications

## Banking

Combine all transactions from multiple branches without removing duplicate transactions.

---

## E-Commerce

Combine online and offline orders, even if the same product appears multiple times.

---

## College Management

Combine attendance records from multiple classes.

---

## Sales Reporting

Combine daily sales reports from different stores.

---

# Common Mistakes

## Expecting Duplicate Removal

UNION ALL does not remove duplicate rows.

If duplicates should be removed, use UNION.

---

## Different Number of Columns

Incorrect

```sql
SELECT emp_id
FROM current_employees

UNION ALL

SELECT emp_id, emp_name
FROM former_employees;
```

Both SELECT statements must return the same number of columns.

---

# Practice Queries

```sql
SELECT emp_name
FROM current_employees

UNION ALL

SELECT emp_name
FROM former_employees;

SELECT emp_name
FROM current_employees

UNION

SELECT emp_name
FROM former_employees;
```

Compare the outputs carefully.

---

# Interview Questions

## What is UNION ALL?

UNION ALL combines the results of multiple SELECT statements and keeps duplicate rows.

---

## Does UNION ALL remove duplicates?

No.

---

## Which is faster: UNION or UNION ALL?

UNION ALL is generally faster because it does not remove duplicates.

---

## When should we use UNION ALL?

When every row, including duplicates, is required.

---

# Summary

Today I learned:

- UNION ALL
- Difference Between UNION and UNION ALL
- Keeping Duplicate Rows
- Performance Difference
- ORDER BY with UNION ALL
- Real-World Applications

UNION ALL combines multiple result sets while preserving all rows, making it efficient for large datasets where duplicates are meaningful.