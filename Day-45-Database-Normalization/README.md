# Day 45 - Database Normalization

# Introduction

Normalization is the process of organizing data into multiple related tables to reduce redundancy and improve data consistency.

It helps eliminate duplicate data and prevents update anomalies.

---

# Why Normalization?

Without normalization:

- Duplicate data
- Wasted storage
- Update anomalies
- Insert anomalies
- Delete anomalies

With normalization:

- Better organization
- Less redundancy
- Improved consistency
- Easier maintenance

---

# First Normal Form (1NF)

Rules:

- Each column contains atomic (single) values.
- No repeating groups.
- Each row is unique.

Example:

❌

| Student | Courses |
|----------|----------|
| John | DBMS, Python |

✅

| Student | Course |
|----------|---------|
| John | DBMS |
| John | Python |

---

# Second Normal Form (2NF)

Requirements:

- Must already be in 1NF.
- Remove partial dependencies.
- Non-key attributes should depend on the entire primary key.

---

# Third Normal Form (3NF)

Requirements:

- Must already be in 2NF.
- Remove transitive dependencies.
- Non-key columns should depend only on the primary key.

---

# Boyce-Codd Normal Form (BCNF)

BCNF is a stricter version of 3NF.

Rule:

Every determinant must be a candidate key.

BCNF removes some anomalies that may still exist in 3NF.

---

# Advantages

- Reduces duplicate data.
- Improves consistency.
- Easier updates.
- Better data integrity.
- Saves storage space.

---

# Disadvantages

- More tables.
- More JOIN operations.
- Complex queries.
- Slight performance overhead for reads.

---

# Real-World Applications

## Banking

Separate customer, account, and transaction tables.

---

## College

Separate students, courses, and enrollments.

---

## E-Commerce

Separate customers, orders, products, and payments.

---

## Hospital

Separate patients, doctors, appointments, and prescriptions.

---

# Common Mistakes

## Skipping 1NF

Always convert data into 1NF before moving to higher normal forms.

---

## Over-Normalization

Too much normalization can increase JOIN operations and reduce query performance.

---

# Practice Queries

```sql
SELECT *
FROM students;

SELECT *
FROM courses;

SELECT *
FROM enrollments;
```

---

# Interview Questions

## What is Normalization?

A process of organizing data to reduce redundancy and improve integrity.

---

## What is 1NF?

Every column contains atomic values with no repeating groups.

---

## What is 2NF?

Removes partial dependency.

---

## What is 3NF?

Removes transitive dependency.

---

## What is BCNF?

A stronger version of 3NF where every determinant is a candidate key.

---

# Summary

Today I learned:

- Database Normalization
- 1NF
- 2NF
- 3NF
- BCNF
- Advantages and Disadvantages

Normalization helps design efficient, consistent, and scalable relational databases by reducing redundancy and maintaining data integrity.