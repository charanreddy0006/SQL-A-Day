# Day 41 - Stored Procedures

# Introduction

A Stored Procedure is a collection of SQL statements stored inside the database.

Once created, it can be executed multiple times without rewriting the SQL code.

Stored Procedures improve code reusability, security, and performance.

---

# Why Use Stored Procedures?

- Reuse SQL code.
- Improve performance through precompilation.
- Reduce network traffic.
- Improve security by restricting direct table access.
- Simplify complex database operations.

---

# Syntax

## Create Procedure

```sql
DELIMITER //

CREATE PROCEDURE procedure_name()
BEGIN
    SQL Statements;
END //

DELIMITER ;
```

---

## Execute Procedure

```sql
CALL procedure_name();
```

---

## Drop Procedure

```sql
DROP PROCEDURE procedure_name;
```

---

# Example 1 - Simple Procedure

```sql
CREATE PROCEDURE ShowEmployees()
BEGIN
    SELECT * FROM employees;
END;
```

Execute:

```sql
CALL ShowEmployees();
```

---

# Example 2 - IN Parameter

An **IN parameter** allows values to be passed into a procedure.

```sql
CALL GetDepartmentEmployees('IT');
```

This displays only IT employees.

---

# Example 3 - OUT Parameter

An **OUT parameter** returns a value from the procedure.

```sql
CALL GetEmployeeCount(@count);

SELECT @count;
```

Returns the total number of employees.

---

# Parameter Types

| Parameter | Purpose |
|-----------|---------|
| IN | Accepts input |
| OUT | Returns output |
| INOUT | Acts as both input and output |

---

# Advantages

- Code reuse
- Better security
- Faster execution
- Easier maintenance
- Centralized business logic

---

# Limitations

- Harder to debug.
- Database-specific syntax.
- Complex procedures may become difficult to maintain.

---

# Real-World Applications

## Banking

Money transfer procedures.

---

## Hospital

Patient registration procedures.

---

## College

Student admission procedures.

---

## E-Commerce

Order processing procedures.

---

# Common Mistakes

## Forgetting DELIMITER

Without changing the delimiter, MySQL ends the procedure definition at the first semicolon.

---

## Forgetting CALL

Incorrect

```sql
ShowEmployees();
```

Correct

```sql
CALL ShowEmployees();
```

---

# Practice Queries

```sql
CALL ShowEmployees();

CALL GetDepartmentEmployees('Finance');

CALL GetEmployeeCount(@total);

SELECT @total;
```

---

# Interview Questions

## What is a Stored Procedure?

A precompiled collection of SQL statements stored in the database.

---

## How do you execute a Stored Procedure?

Using the `CALL` statement.

---

## What is the difference between IN and OUT parameters?

- **IN** receives input values.
- **OUT** returns values from the procedure.

---

## Why are Stored Procedures used?

To improve performance, security, and code reuse.

---

# Summary

Today I learned:

- Stored Procedures
- CREATE PROCEDURE
- CALL
- IN Parameters
- OUT Parameters
- DROP PROCEDURE

Stored Procedures help automate repetitive database tasks and are widely used in enterprise applications.