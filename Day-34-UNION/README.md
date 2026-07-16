# Day 34 - UNION

# Introduction

The UNION operator is used to combine the results of two or more SELECT statements into a single result set.

If duplicate rows exist, UNION automatically removes them.

UNION is commonly used when similar data is stored in different tables.

---

# What is UNION?

UNION combines the output of multiple SELECT statements.

Duplicate rows are removed automatically.

---

# Syntax

```sql
SELECT column1, column2
FROM table1

UNION

SELECT column1, column2
FROM table2;
```

---

# Rules for UNION

Before using UNION, remember these rules:

### Rule 1

Both SELECT statements must return the same number of columns.

Correct

```sql
SELECT emp_id, emp_name
FROM employees

UNION

SELECT emp_id, emp_name
FROM managers;
```

---

### Rule 2

The corresponding columns must have compatible data types.

Example

Employee ID → INT

Manager ID → INT

Employee Name → VARCHAR

Manager Name → VARCHAR

---

### Rule 3

The column names do not need to be the same.

Only the number of columns and their data types must match.

---

# Example 1

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
SELECT emp_id, emp_name
FROM current_employees

UNION

SELECT emp_id, emp_name
FROM former_employees;
```

Output

| ID | Name |
|----|------|
|101|John|
|102|David|
|103|Emma|
|104|Robert|

Emma appears only once because UNION removes duplicate rows.

---

# UNION vs UNION ALL

| UNION | UNION ALL |
|--------|-----------|
|Removes duplicate rows|Keeps duplicate rows|
|Slightly slower|Faster|
|Used when duplicates are not needed|Used when duplicates should be preserved|

---

# ORDER BY with UNION

You can sort the final combined result.

Example

```sql
SELECT emp_id, emp_name
FROM current_employees

UNION

SELECT emp_id, emp_name
FROM former_employees

ORDER BY emp_name;
```

The ORDER BY clause is written only once, after the last SELECT statement.

---

# Real-World Applications

## Company Management

Combine current and former employees into one report.

---

## Banking

Combine savings account customers and current account customers.

---

## E-Commerce

Combine online and offline orders.

---

## College Management

Combine students from different departments.

---

# Common Mistakes

## Different Number of Columns

Incorrect

```sql
SELECT emp_id
FROM current_employees

UNION

SELECT emp_id, emp_name
FROM former_employees;
```

Both SELECT statements must return the same number of columns.

---

## Using ORDER BY in the First SELECT

Incorrect

```sql
SELECT *
FROM table1
ORDER BY name

UNION

SELECT *
FROM table2;
```

ORDER BY should appear only once at the end of the UNION query.

---

# Practice Queries

```sql
SELECT emp_id, emp_name, department
FROM current_employees

UNION

SELECT emp_id, emp_name, department
FROM former_employees;

SELECT emp_id, emp_name, department
FROM current_employees

UNION

SELECT emp_id, emp_name, department
FROM former_employees

ORDER BY emp_name;
```

---

# Interview Questions

## What is UNION?

UNION combines the results of two or more SELECT statements and removes duplicate rows.

---

## Does UNION remove duplicate rows?

Yes.

---

## What conditions must be satisfied before using UNION?

- Same number of columns.
- Compatible data types.

---

## Can ORDER BY be used with UNION?

Yes. It should be written only once at the end of the query.

---

# Summary

Today I learned:

- UNION
- Combining Multiple SELECT Statements
- Rules of UNION
- Removing Duplicate Rows
- ORDER BY with UNION
- Real-World Applications

The UNION operator combines data from multiple queries into a single result while automatically removing duplicate rows.