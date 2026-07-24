# Day 42 - SQL Functions

# Introduction

A User-Defined Function (UDF) is a reusable database object that accepts input values, performs operations, and returns a single value.

Unlike Stored Procedures, Functions must return a value.

---

# Built-in Functions

Examples

- COUNT()
- SUM()
- AVG()
- MAX()
- MIN()
- NOW()

These are already provided by MySQL.

---

# User-Defined Functions

You create these functions according to your own requirements.

Example

```sql
CalculateBonus()
```

---

# Syntax

## Create Function

```sql
DELIMITER //

CREATE FUNCTION function_name(parameter datatype)
RETURNS datatype
DETERMINISTIC
BEGIN
    RETURN expression;
END //

DELIMITER ;
```

---

## Call Function

```sql
SELECT function_name(value);
```

---

## Drop Function

```sql
DROP FUNCTION function_name;
```

---

# Example 1

```sql
CREATE FUNCTION CalculateBonus(emp_salary DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN emp_salary * 0.10;
END;
```

Returns a 10% bonus.

---

# Example 2

```sql
SELECT
emp_name,
salary,
CalculateBonus(salary)
FROM employees;
```

Calculates the bonus for every employee.

---

# Built-in Function vs User-Defined Function

| Built-in Function | User-Defined Function |
|-------------------|-----------------------|
|Already available|Created by the user|
|Examples: COUNT(), AVG()|Example: CalculateBonus()|
|Cannot modify|Can be customized|

---

# Advantages

- Reusable code
- Simplifies SQL queries
- Reduces duplicate calculations
- Easier maintenance
- Centralized business logic

---

# Limitations

- Must return only one value.
- Cannot return multiple result sets.
- Complex logic may affect performance.

---

# Real-World Applications

## Banking

Calculate loan interest.

---

## Payroll

Calculate employee bonuses and taxes.

---

## E-Commerce

Calculate product discounts.

---

## College

Calculate student grades based on marks.

---

# Common Mistakes

## Forgetting RETURNS

Incorrect

```sql
CREATE FUNCTION Bonus(...)
BEGIN
...
END;
```

Correct

```sql
RETURNS DECIMAL(10,2)
```

---

## Forgetting RETURN

Every function must return a value.

---

# Practice Queries

```sql
SELECT CalculateBonus(60000);

SELECT
emp_name,
CalculateBonus(salary)
FROM employees;
```

---

# Interview Questions

## What is a User-Defined Function?

A reusable database object that returns a single value.

---

## What is the difference between a Function and a Stored Procedure?

Function:
- Must return one value.
- Can be used inside SQL statements.

Stored Procedure:
- May or may not return values.
- Executed using CALL.

---

## Can a Function modify database tables?

Generally, MySQL functions are intended for calculations and should not perform data-modifying operations.

---

# Summary

Today I learned:

- SQL Functions
- User-Defined Functions
- CREATE FUNCTION
- RETURNS
- RETURN
- DROP FUNCTION

Functions help encapsulate reusable calculations and make SQL queries cleaner and easier to maintain.