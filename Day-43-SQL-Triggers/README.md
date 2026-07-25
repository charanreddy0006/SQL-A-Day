# Day 43 - SQL Triggers

# Introduction

A Trigger is a special stored program that automatically executes when an INSERT, UPDATE, or DELETE event occurs on a table.

Unlike Stored Procedures, Triggers are executed automatically by the database.

---

# Why Use Triggers?

- Automate repetitive tasks.
- Maintain audit logs.
- Enforce business rules.
- Validate data automatically.
- Improve data integrity.

---

# Syntax

## Create Trigger

```sql
DELIMITER //

CREATE TRIGGER trigger_name
AFTER INSERT
ON table_name
FOR EACH ROW
BEGIN
    SQL Statements;
END //

DELIMITER ;
```

---

## Drop Trigger

```sql
DROP TRIGGER trigger_name;
```

---

# Types of Triggers

## BEFORE Trigger

Runs before the event occurs.

Example:

- Validate salary before inserting an employee.

---

## AFTER Trigger

Runs after the event completes successfully.

Example:

- Record an audit log after an employee is added.

---

# NEW and OLD Keywords

| Keyword | Used For |
|----------|----------|
| NEW | Accesses new values during INSERT or UPDATE |
| OLD | Accesses old values during UPDATE or DELETE |

Example:

```sql
NEW.emp_id
OLD.emp_id
```

---

# Example

```sql
CREATE TRIGGER trg_after_insert
AFTER INSERT
ON employees
FOR EACH ROW
BEGIN
    INSERT INTO employee_audit(emp_id, action_type)
    VALUES(NEW.emp_id,'INSERT');
END;
```

Whenever a new employee is inserted, an audit record is automatically created.

---

# Advantages

- Automatic execution
- Improves data integrity
- Maintains audit history
- Reduces repetitive code

---

# Limitations

- Difficult to debug.
- Too many triggers may reduce performance.
- Hidden execution can make maintenance harder.

---

# Real-World Applications

## Banking

Automatically record every transaction.

---

## E-Commerce

Log order creation and updates.

---

## Hospital

Track patient record modifications.

---

## College

Maintain admission and attendance logs.

---

# Common Mistakes

## Forgetting FOR EACH ROW

A trigger must specify:

```sql
FOR EACH ROW
```

---

## Using OLD During INSERT

Incorrect:

```sql
OLD.emp_id
```

Correct:

```sql
NEW.emp_id
```

---

# Practice Queries

```sql
INSERT INTO employees
VALUES(105,'James',48000);

UPDATE employees
SET salary=80000
WHERE emp_id=101;

DELETE FROM employees
WHERE emp_id=104;

SELECT * FROM employee_audit;
```

---

# Interview Questions

## What is a Trigger?

A database object that automatically executes when INSERT, UPDATE, or DELETE events occur.

---

## Difference Between Trigger and Stored Procedure?

Trigger:
- Executes automatically.

Stored Procedure:
- Executed manually using CALL.

---

## What are NEW and OLD?

- NEW refers to new values.
- OLD refers to existing values before modification.

---

## Can multiple triggers exist on one table?

Yes, different triggers can exist for different events (INSERT, UPDATE, DELETE).

---

# Summary

Today I learned:

- Triggers
- BEFORE Trigger
- AFTER Trigger
- INSERT Trigger
- UPDATE Trigger
- DELETE Trigger
- NEW and OLD
- DROP TRIGGER

Triggers automate database operations and are widely used for auditing, validation, and maintaining data consistency.