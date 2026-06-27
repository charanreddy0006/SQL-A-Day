# Day 17 - PRIMARY KEY and FOREIGN KEY

# Introduction

Relational databases are designed to store related information across multiple tables.

Instead of storing all information in one large table, SQL allows us to divide data into smaller tables and connect them using keys.

The two most important keys are:

* PRIMARY KEY
* FOREIGN KEY

These keys help maintain relationships between tables while ensuring data consistency.

---

# Why Do We Need Relationships?

Imagine storing student and department information.

Without relationships:

| Student | Department              |
| ------- | ----------------------- |
| Chakri  | Artificial Intelligence |
| Ram     | Computer Science        |
| Ravi    | Electronics             |

If the department name changes, we must update every student record.

Instead, we create a Department table and store only the department ID in the Student table.

This reduces data duplication and improves database efficiency.

---

# What is a PRIMARY KEY?

A PRIMARY KEY uniquely identifies every row in a table.

Properties:

* Unique
* Cannot contain NULL values
* Only one PRIMARY KEY per table

Example:

```sql
CREATE TABLE departments(
    department_id INT PRIMARY KEY,
    department_name VARCHAR(50)
);
```

Example Data:

| department_id | department_name         |
| ------------- | ----------------------- |
| 1             | Computer Science        |
| 2             | Artificial Intelligence |
| 3             | Electronics             |

Every department has a unique ID.

---

# What is a FOREIGN KEY?

A FOREIGN KEY is a column that refers to the PRIMARY KEY of another table.

It creates a relationship between two tables.

Example:

```sql
department_id INT,
FOREIGN KEY (department_id)
REFERENCES departments(department_id)
```

Here:

* department_id in **students** is the FOREIGN KEY.
* department_id in **departments** is the PRIMARY KEY.

---

# Parent Table and Child Table

### Parent Table

```text
departments
```

Contains the PRIMARY KEY.

### Child Table

```text
students
```

Contains the FOREIGN KEY.

---

# Relationship Example

Departments Table

| department_id | department_name         |
| ------------- | ----------------------- |
| 1             | Computer Science        |
| 2             | Artificial Intelligence |
| 3             | Electronics             |

Students Table

| student_id | student_name | department_id |
| ---------- | ------------ | ------------- |
| 101        | Chakri       | 2             |
| 102        | Ram          | 1             |
| 103        | Ravi         | 3             |

Notice that the students table stores only the department ID instead of repeating the department name.

---

# Referential Integrity

A FOREIGN KEY ensures that the value exists in the parent table.

Example:

```sql
INSERT INTO students
VALUES(104,'John',20,10);
```

This will fail because department ID 10 does not exist.

This prevents invalid data from entering the database.

---

# Advantages

* Reduces duplicate data
* Maintains consistency
* Improves data integrity
* Connects multiple tables
* Makes databases easier to maintain

---

# Real-World Applications

## College Management

Departments ← Students

---

## Banking

Customers ← Accounts

---

## E-Commerce

Categories ← Products

---

## Hospital Management

Doctors ← Patients

---

# Common Mistakes

## Using a FOREIGN KEY value that does not exist

Incorrect:

```sql
department_id = 10
```

if only IDs 1, 2, and 3 exist.

---

## Forgetting to create the Parent Table first

Always create the parent table before the child table.

---

# Practice Queries

```sql
SELECT * FROM departments;

SELECT * FROM students;
```

Try inserting:

```sql
INSERT INTO students
VALUES(104,'Anita',20,2);
```

This will work because department 2 exists.

Now try:

```sql
INSERT INTO students
VALUES(105,'Rohan',19,10);
```

This will generate an error because department 10 does not exist.

---

# Interview Questions

## What is a PRIMARY KEY?

A PRIMARY KEY uniquely identifies every row in a table.

---

## What is a FOREIGN KEY?

A FOREIGN KEY creates a relationship between two tables by referring to the PRIMARY KEY of another table.

---

## Can a table have multiple FOREIGN KEY constraints?

Yes.

---

## Why are FOREIGN KEY constraints important?

They maintain referential integrity and prevent invalid relationships.

---

# Summary

Today I learned:

* PRIMARY KEY
* FOREIGN KEY
* Parent Table
* Child Table
* Referential Integrity
* Relationships between Tables

PRIMARY KEY and FOREIGN KEY are the foundation of relational database design. They help organize data efficiently and ensure consistency across related tables.
