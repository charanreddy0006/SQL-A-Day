# Day 23 - SELF JOIN

# Introduction

A SELF JOIN is a join where a table is joined with itself.

Unlike other joins that combine two different tables, a SELF JOIN uses the same table twice.

Since the same table appears twice in the query, table aliases are required to distinguish between the two copies.

SELF JOIN is commonly used to represent hierarchical relationships such as:

- Employee → Manager
- Student → Mentor
- Category → Parent Category
- Comment → Parent Comment

---

# What is SELF JOIN?

A SELF JOIN joins a table with itself.

The table is treated as two separate tables by using aliases.

---

# Why Do We Need SELF JOIN?

Consider an employee table:

| emp_id | emp_name | manager_id |
|--------|----------|------------|
|1|John|NULL|
|2|David|1|
|3|Emma|1|
|4|Robert|2|
|5|Sophia|2|
|6|James|3|

Notice:

- John has no manager.
- David's manager is John.
- Robert's manager is David.

Both employee and manager information are stored in the same table.

To display employee names along with their managers, we use SELF JOIN.

---

# Syntax

```sql
SELECT
A.column_name,
B.column_name
FROM table_name A
JOIN table_name B
ON A.column = B.column;
```

Here:

- A represents one copy of the table.
- B represents another copy of the same table.

---

# Example Query

```sql
SELECT
e.emp_name AS Employee,
m.emp_name AS Manager
FROM employees e
LEFT JOIN employees m
ON e.manager_id = m.emp_id;
```

---

# Understanding the Query

### employees AS e

Represents employees.

### employees AS m

Represents managers.

### ON e.manager_id = m.emp_id

Matches each employee with their manager.

---

# Expected Output

| Employee | Manager |
|----------|---------|
|John|NULL|
|David|John|
|Emma|John|
|Robert|David|
|Sophia|David|
|James|Emma|

John has no manager, so Manager is NULL.

---

# Why Use LEFT JOIN?

We use LEFT JOIN because the top-level manager (John) has no manager.

If INNER JOIN were used, John's record would not appear in the result.

---

# Real World Applications

## Company Management

Display employees and their managers.

---

## College Management

Display students and their mentors.

---

## E-Commerce

Display product categories and parent categories.

---

## Social Media

Display comments and parent comments.

---

# Advantages of SELF JOIN

- Retrieves hierarchical data.
- Uses a single table.
- Easy to represent reporting structures.
- Frequently used in business applications.

---

# Common Mistakes

## Forgetting Table Aliases

Incorrect:

```sql
SELECT emp_name
FROM employees
JOIN employees;
```

SQL cannot determine which table instance is being referenced.

Always use aliases.

---

## Wrong Join Condition

Incorrect:

```sql
ON e.emp_id = m.emp_id;
```

Correct:

```sql
ON e.manager_id = m.emp_id;
```

---

# Practice Queries

```sql
SELECT
e.emp_name AS Employee,
m.emp_name AS Manager
FROM employees e
LEFT JOIN employees m
ON e.manager_id = m.emp_id;
```

---

# Interview Questions

## What is SELF JOIN?

A SELF JOIN joins a table with itself using table aliases.

---

## Why are aliases required?

Because the same table appears twice in the query.

---

## Give one real-world use of SELF JOIN.

Displaying employees along with their managers.

---

# Summary

Today I learned:

- SELF JOIN
- Table Aliases
- Employee–Manager Relationship
- Hierarchical Data
- LEFT JOIN with SELF JOIN
- Real-World Applications

SELF JOIN is a powerful SQL technique used to retrieve related information stored within the same table.