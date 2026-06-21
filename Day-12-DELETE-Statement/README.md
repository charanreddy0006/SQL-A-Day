# Day 12 - DELETE Statement

# Introduction

The DELETE statement is used to remove records from a table.

In real-world applications, data sometimes becomes unnecessary or outdated. Instead of keeping unwanted records, SQL provides the DELETE statement to remove them.

DELETE is a Data Manipulation Language (DML) command.

---

# What is DELETE?

DELETE removes one or more rows from a table.

### Syntax

```sql
DELETE FROM table_name
WHERE condition;
```

---

# Understanding the Syntax

## DELETE FROM

Specifies the table from which records should be removed.

Example:

```sql
DELETE FROM employees
```

---

## WHERE

Specifies which rows should be deleted.

Example:

```sql
WHERE emp_id = 102;
```

Without WHERE, all rows may be deleted.

---

# Example Table Before DELETE

| emp_id | emp_name | salary |
| ------ | -------- | ------ |
| 101    | John     | 50000  |
| 102    | David    | 60000  |
| 103    | Emma     | 55000  |
| 104    | Robert   | 70000  |

---

# Deleting a Single Record

```sql
DELETE FROM employees
WHERE emp_id = 102;
```

### Result

| emp_id | emp_name | salary |
| ------ | -------- | ------ |
| 101    | John     | 50000  |
| 103    | Emma     | 55000  |
| 104    | Robert   | 70000  |

Only David's record is removed.

---

# Deleting Using Text Values

```sql
DELETE FROM employees
WHERE emp_name = 'Emma';
```

Deletes the employee named Emma.

---

# DELETE All Records

```sql
DELETE FROM employees;
```

⚠️ Warning:

This removes all rows from the table but keeps the table structure.

---

# DELETE vs DROP

## DELETE

```sql
DELETE FROM employees;
```

Removes data only.

Table remains.

---

## DROP

```sql
DROP TABLE employees;
```

Removes both:

* Table structure
* Data

The table no longer exists.

---

# Real World Applications

## Banking

Remove inactive accounts.

```sql
DELETE FROM accounts
WHERE account_status = 'Closed';
```

---

## E-Commerce

Remove discontinued products.

```sql
DELETE FROM products
WHERE product_status = 'Discontinued';
```

---

## College Management

Remove student records.

```sql
DELETE FROM students
WHERE student_id = 10;
```

---

## Hospital Management

Remove duplicate patient records.

```sql
DELETE FROM patients
WHERE patient_id = 100;
```

---

# Best Practices

Always check records before deleting:

```sql
SELECT *
FROM employees
WHERE emp_id = 102;
```

Then delete:

```sql
DELETE FROM employees
WHERE emp_id = 102;
```

---

# Common Mistakes

## Forgetting WHERE

Incorrect:

```sql
DELETE FROM employees;
```

This deletes every record.

---

## Wrong Condition

Incorrect:

```sql
DELETE FROM employees
WHERE emp_id = 999;
```

No records may be deleted if the ID does not exist.

---

# Practice Queries

```sql
DELETE FROM employees
WHERE emp_id = 102;

DELETE FROM employees
WHERE emp_name = 'Emma';

SELECT * FROM employees;
```

---

# Interview Questions

## What is DELETE used for?

DELETE removes records from a table.

---

## What happens if WHERE is omitted?

All rows are deleted.

---

## What is the difference between DELETE and DROP?

DELETE removes data only.

DROP removes both data and table structure.

---

# Summary

Today I learned:

* DELETE Statement
* DELETE with WHERE
* DELETE All Records
* DELETE vs DROP
* Best Practices for Deleting Data

DELETE is an essential SQL command used to safely remove unwanted records from a database.
