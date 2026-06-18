# Day 11 - UPDATE Statement

# Introduction

The UPDATE statement is used to modify existing records in a table.

After data is inserted into a database, there may be situations where information changes. Instead of deleting and re-inserting data, SQL provides the UPDATE statement to make changes efficiently.

The UPDATE statement is one of the most commonly used Data Manipulation Language (DML) commands.

---

# What is UPDATE?

The UPDATE statement modifies existing records in a table.

### Syntax

```sql
UPDATE table_name
SET column_name = value
WHERE condition;
```

---

# Understanding the Syntax

## UPDATE

Specifies the table that needs modification.

Example:

```sql
UPDATE employees
```

---

## SET

Used to assign a new value.

Example:

```sql
SET salary = 65000
```

---

## WHERE

Specifies which rows should be updated.

Example:

```sql
WHERE emp_id = 101;
```

Without WHERE, all rows may be updated.

---

# Example Table Before Update

| emp_id | emp_name | salary |
| ------ | -------- | ------ |
| 101    | John     | 50000  |
| 102    | David    | 60000  |
| 103    | Emma     | 55000  |

---

# Updating a Single Record

```sql
UPDATE employees
SET salary = 65000
WHERE emp_id = 101;
```

### Output

| emp_id | emp_name | salary |
| ------ | -------- | ------ |
| 101    | John     | 65000  |
| 102    | David    | 60000  |
| 103    | Emma     | 55000  |

Only employee 101 is updated.

---

# Updating Text Values

```sql
UPDATE employees
SET emp_name = 'Michael'
WHERE emp_id = 102;
```

### Output

| emp_id | emp_name | salary |
| ------ | -------- | ------ |
| 101    | John     | 65000  |
| 102    | Michael  | 60000  |
| 103    | Emma     | 55000  |

---

# Updating Multiple Columns

```sql
UPDATE employees
SET emp_name = 'Robert',
    salary = 70000
WHERE emp_id = 103;
```

This updates more than one column in a single query.

---

# Why WHERE is Important

### Dangerous Query

```sql
UPDATE employees
SET salary = 100000;
```

Without WHERE, every employee salary becomes 100000.

Always be careful when using UPDATE.

---

# Real World Applications

## Banking

```sql
UPDATE accounts
SET balance = 50000
WHERE account_id = 101;
```

Update account balance.

---

## E-Commerce

```sql
UPDATE products
SET price = 999
WHERE product_id = 1;
```

Update product price.

---

## College Management

```sql
UPDATE students
SET branch = 'AIML'
WHERE student_id = 10;
```

Update student information.

---

## Hospital Management

```sql
UPDATE patients
SET phone_number = '9876543210'
WHERE patient_id = 5;
```

Update patient details.

---

# Common Mistakes

## Forgetting WHERE Clause

Incorrect:

```sql
UPDATE employees
SET salary = 50000;
```

Updates all rows.

---

## Wrong Column Name

Incorrect:

```sql
UPDATE employees
SET name = 'John';
```

If the column is emp_name, SQL generates an error.

---

# Practice Queries

```sql
UPDATE employees
SET salary = 65000
WHERE emp_id = 101;

UPDATE employees
SET emp_name = 'Michael'
WHERE emp_id = 102;

UPDATE employees
SET salary = 70000
WHERE emp_id = 103;
```

---

# Interview Questions

## What is UPDATE used for?

UPDATE is used to modify existing records in a table.

---

## Which clause is important while using UPDATE?

WHERE clause.

---

## What happens if WHERE is omitted?

All rows in the table may be updated.

---

# Summary

Today I learned:

* UPDATE Statement
* SET Clause
* WHERE Clause with UPDATE
* Updating Single Records
* Updating Multiple Columns
* Risks of Missing WHERE Clause

The UPDATE statement is essential for maintaining and modifying data in real-world database applications.
