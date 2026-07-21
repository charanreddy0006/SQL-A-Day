# Day 39 - SQL Views

# Introduction

A View is a virtual table created from one or more SQL queries.

Unlike a normal table, a View does not store data physically.

Whenever a View is queried, SQL retrieves the latest data from the underlying table(s).

---

# What is a View?

A View is a stored SQL query that behaves like a table.

Example:

Employees Table

| ID | Name | Department | Salary |
|----|------|------------|---------|
|101|John|HR|50000|
|102|David|IT|70000|

View

| ID | Name | Salary |
|----|------|---------|
|101|John|50000|
|102|David|70000|

The original table remains unchanged.

---

# Syntax

## Create View

```sql
CREATE VIEW view_name AS
SELECT column1, column2
FROM table_name;
```

---

## Display View

```sql
SELECT *
FROM view_name;
```

---

## Delete View

```sql
DROP VIEW view_name;
```

---

# Example 1 - Create View

```sql
CREATE VIEW employee_details AS
SELECT emp_id,
       emp_name,
       department,
       salary
FROM employees;
```

This creates a reusable virtual table.

---

# Example 2 - View with WHERE

```sql
CREATE VIEW it_employees AS
SELECT emp_id,
       emp_name,
       salary
FROM employees
WHERE department='IT';
```

Now only IT employees are displayed.

---

# Example 3 - Update Through View

Some simple Views are updatable.

```sql
UPDATE employee_details
SET salary=72000
WHERE emp_id=102;
```

The Employees table is also updated because the View references it.

---

# Advantages of Views

- Simplifies complex SQL queries.
- Improves security by hiding sensitive columns.
- Makes reports easier to build.
- Reuses frequently used queries.

---

# Limitations of Views

- Does not store data separately.
- Some complex Views cannot be updated.
- Performance depends on the underlying query.

---

# Real-World Applications

## Banking

Show customer account details without exposing passwords.

---

## HR Management

Provide managers with employee names and salaries only.

---

## E-Commerce

Create product views for customers without supplier information.

---

## Hospital

Show patient records while hiding confidential medical notes.

---

# Common Mistakes

## Trying to Update Complex Views

Views created using GROUP BY, DISTINCT, or multiple JOINs may not be updatable.

---

## Dropping the Wrong Object

```sql
DROP VIEW employee_details;
```

Only the View is deleted.

The original table remains safe.

---

# Practice Queries

```sql
CREATE VIEW finance_employees AS
SELECT emp_name,
       salary
FROM employees
WHERE department='Finance';

SELECT *
FROM finance_employees;

DROP VIEW finance_employees;
```

---

# Interview Questions

## What is a View?

A virtual table created from a SQL query.

---

## Does a View store data?

No. It retrieves data from the original table.

---

## Can a View be updated?

Simple Views can usually be updated.

Complex Views often cannot.

---

## Why are Views used?

To simplify queries, improve security, and provide reusable query results.

---

# Summary

Today I learned:

- Views
- CREATE VIEW
- SELECT from View
- UPDATE through View
- DROP VIEW
- Advantages and Limitations

Views are powerful tools for simplifying database access, improving security, and organizing frequently used queries.