# Day 04 - INSERT Statement

## Introduction

After creating databases and tables, the next step is storing data inside them.

SQL provides the INSERT statement to add new records into a table.

The INSERT statement is one of the most important SQL commands because databases are useful only when they contain data.

---

# What is INSERT?

The INSERT statement is used to add new rows (records) into a table.

Every row represents one record.

For example:

| Employee ID | Employee Name | Salary |
| ----------- | ------------- | ------ |
| 101         | John          | 50000  |
| 102         | David         | 60000  |

Each row is inserted using the INSERT command.

---

# Syntax of INSERT

```sql
INSERT INTO table_name
VALUES(value1, value2, value3);
```

Example:

```sql
INSERT INTO employees
VALUES(101,'John',50000);
```

This inserts one employee record into the employees table.

---

# Creating a Table

Before inserting data, a table must exist.

```sql
CREATE TABLE employees(
    emp_id INT,
    emp_name VARCHAR(50),
    salary DECIMAL(10,2)
);
```

---

# Inserting a Single Record

```sql
INSERT INTO employees
VALUES(101,'John',50000);
```

Output:

| Employee ID | Employee Name | Salary |
| ----------- | ------------- | ------ |
| 101         | John          | 50000  |

---

# Inserting Multiple Records

Instead of inserting rows one by one, SQL allows multiple rows in a single query.

```sql
INSERT INTO employees
VALUES
(101,'John',50000),
(102,'David',60000),
(103,'Emma',55000);
```

Benefits:

* Faster execution
* Less code
* Better performance

---

# Inserting Data into Specific Columns

```sql
INSERT INTO employees(emp_id, emp_name)
VALUES(104,'Chris');
```

This inserts values only into selected columns.

---

# Viewing Inserted Data

To see stored records:

```sql
SELECT * FROM employees;
```

Example Output:

| emp_id | emp_name | salary |
| ------ | -------- | ------ |
| 101    | John     | 50000  |
| 102    | David    | 60000  |
| 103    | Emma     | 55000  |

---

# Common Errors

## Mismatch in Number of Values

Incorrect:

```sql
INSERT INTO employees
VALUES(101,'John');
```

Reason:

The table expects three values but only two are provided.

---

## Wrong Data Type

Incorrect:

```sql
INSERT INTO employees
VALUES('ABC','John',50000);
```

Reason:

emp_id is defined as INT but text is inserted.

---

# Real-World Applications

INSERT is used in:

### Banking Systems

* Creating new accounts
* Recording transactions

### E-Commerce

* Adding customers
* Creating orders

### Schools

* Student registration
* Attendance records

### Hospitals

* Patient registration
* Appointment booking

---

# Summary

Today I learned:

* What DML is
* INSERT INTO Statement
* Inserting Single Records
* Inserting Multiple Records
* Inserting Specific Columns
* Viewing Data with SELECT
* Common INSERT Errors

The INSERT statement is the foundation of data entry in relational databases and is used in almost every database application.
