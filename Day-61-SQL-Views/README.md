# Day 61 - SQL Views

# Introduction

A View in SQL is a virtual table based on the result of a SQL query.

A view does not normally store the actual table data separately.

Instead, it stores the query definition and displays the result when the view is accessed.

Views are useful for simplifying complex queries, improving data security, and creating reusable database queries.

---

# What is a View?

A View is a virtual table created from one or more existing tables.

For example:

```sql
CREATE VIEW employee_view AS
SELECT
    emp_id,
    emp_name,
    department,
    salary
FROM employees;
```

The view can then be queried like a normal table.

```sql
SELECT *
FROM employee_view;
```

---

# Why Do We Use Views?

Views are useful for:

- Simplifying complex SQL queries
- Reusing SQL queries
- Improving data security
- Hiding unnecessary columns
- Creating reports
- Providing customized data access
- Making queries easier to understand

---

# Basic View Syntax

```sql
CREATE VIEW view_name AS
SELECT
    column1,
    column2
FROM table_name;
```

### Example

```sql
CREATE VIEW employee_view AS
SELECT
    emp_id,
    emp_name,
    department,
    salary
FROM employees;
```

---

# Querying a View

A view can be queried using SELECT.

```sql
SELECT *
FROM employee_view;
```

A view can be used similarly to a table for many read operations.

---

# Creating a Simple View

```sql
CREATE VIEW employee_basic_view AS
SELECT
    emp_id,
    emp_name,
    department,
    city
FROM employees;
```

### Display the View

```sql
SELECT *
FROM employee_basic_view;
```

This view contains only selected employee information.

---

# View with WHERE Condition

A view can contain filtering conditions.

```sql
CREATE VIEW it_employee_view AS
SELECT
    emp_id,
    emp_name,
    salary,
    experience
FROM employees
WHERE department = 'IT';
```

### Example

```sql
SELECT *
FROM it_employee_view;
```

This view displays only IT employees.

---

# High Salary Employee View

```sql
CREATE VIEW high_salary_view AS
SELECT
    emp_id,
    emp_name,
    department,
    salary
FROM employees
WHERE salary >= 80000;
```

### Example

```sql
SELECT *
FROM high_salary_view;
```

This view displays employees earning 80000 or more.

---

# View with ORDER BY

A view can contain an ORDER BY clause depending on the database and query requirements.

```sql
CREATE VIEW salary_view AS
SELECT
    emp_name,
    department,
    salary
FROM employees
ORDER BY salary DESC;
```

### Example

```sql
SELECT *
FROM salary_view;
```

---

# Department Summary View

Views can also contain aggregate functions.

```sql
CREATE VIEW department_summary_view AS
SELECT
    department,
    COUNT(*) AS employee_count,
    AVG(salary) AS average_salary,
    MAX(salary) AS highest_salary,
    MIN(salary) AS lowest_salary
FROM employees
GROUP BY department;
```

### Example

```sql
SELECT *
FROM department_summary_view;
```

This view provides a summary of every department.

---

# City Summary View

```sql
CREATE VIEW city_summary_view AS
SELECT
    city,
    COUNT(*) AS employee_count,
    AVG(salary) AS average_salary
FROM employees
GROUP BY city;
```

### Example

```sql
SELECT *
FROM city_summary_view;
```

This view provides employee statistics by city.

---

# View with CASE

A view can contain conditional logic.

```sql
CREATE VIEW salary_category_view AS
SELECT
    emp_id,
    emp_name,
    department,
    salary,
    CASE
        WHEN salary >= 90000 THEN 'High'
        WHEN salary >= 70000 THEN 'Medium'
        ELSE 'Low'
    END AS salary_category
FROM employees;
```

### Example

```sql
SELECT *
FROM salary_category_view;
```

---

# View with Experience

```sql
CREATE VIEW experienced_employee_view AS
SELECT
    emp_id,
    emp_name,
    department,
    experience,
    salary
FROM employees
WHERE experience >= 5;
```

### Example

```sql
SELECT *
FROM experienced_employee_view;
```

This view displays employees with at least five years of experience.

---

# View with Calculated Column

A view can contain calculated values.

```sql
CREATE VIEW employee_analysis_view AS
SELECT
    emp_id,
    emp_name,
    department,
    salary,
    experience,
    salary / 12 AS monthly_salary
FROM employees;
```

### Example

```sql
SELECT *
FROM employee_analysis_view;
```

The view calculates the approximate monthly salary.

---

# Filtering a View

A view can be filtered using WHERE.

```sql
SELECT *
FROM employee_view
WHERE department = 'IT';
```

The view behaves like a virtual table for the query.

---

# Sorting a View

A view can also be queried with ORDER BY.

```sql
SELECT *
FROM employee_view
ORDER BY salary DESC;
```

This displays employees from highest salary to lowest salary.

---

# Aggregate Functions with Views

Aggregate functions can be applied to a view.

```sql
SELECT
    AVG(salary) AS average_salary
FROM employee_view;
```

The query calculates the average salary from the view result.

---

# GROUP BY with Views

```sql
SELECT
    department,
    COUNT(*) AS employee_count
FROM employee_view
GROUP BY department;
```

This calculates the number of employees in every department.

---

# Updating Data Through a View

Some simple views can be updatable.

Example:

```sql
UPDATE employee_view
SET salary = 72000
WHERE emp_id = 101;
```

Whether a view can be updated depends on how the view was created.

Views containing complex operations such as aggregation, grouping, or certain joins may not be directly updatable.

---

# CREATE OR REPLACE VIEW

An existing view can be modified using CREATE OR REPLACE VIEW.

```sql
CREATE OR REPLACE VIEW employee_view AS
SELECT
    emp_id,
    emp_name,
    department,
    salary,
    city
FROM employees;
```

This replaces the existing view definition.

---

# ALTER VIEW

A view can also be modified using ALTER VIEW.

```sql
ALTER VIEW employee_basic_view AS
SELECT
    emp_id,
    emp_name,
    department,
    city,
    salary
FROM employees;
```

---

# Viewing Available Views

MySQL can be used to display views in the current database.

```sql
SHOW FULL TABLES
WHERE TABLE_TYPE = 'VIEW';
```

This displays the available views.

---

# SHOW CREATE VIEW

To see the SQL definition of a view:

```sql
SHOW CREATE VIEW employee_view;
```

This displays the statement used to create the view.

---

# Dropping a View

A view can be removed using DROP VIEW.

```sql
DROP VIEW temporary_employee_view;
```

The underlying table is not deleted.

Only the view definition is removed.

---

# DROP VIEW IF EXISTS

To safely remove a view:

```sql
DROP VIEW IF EXISTS temporary_employee_view;
```

This avoids an error if the view does not exist.

---

# Multiple Views

Multiple views can be created for different requirements.

For example:

```text
employees
    |
    +---- employee_view
    |
    +---- it_employee_view
    |
    +---- high_salary_view
    |
    +---- department_summary_view
    |
    +---- city_summary_view
```

Each view can provide a different representation of the same underlying data.

---

# Advantages of Views

Views provide several benefits:

- Simplify complex SQL queries
- Improve query reusability
- Hide unnecessary columns
- Provide controlled data access
- Improve readability
- Create reusable reports
- Separate users from table complexity

---

# Views and Security

Views can be used to expose only required columns.

Suppose the employees table contains:

```text
emp_id
emp_name
department
salary
city
experience
joining_year
```

A view can expose only:

```text
emp_id
emp_name
department
city
```

Example:

```sql
CREATE VIEW employee_public_view AS
SELECT
    emp_id,
    emp_name,
    department,
    city
FROM employees;
```

This can help restrict direct access to unnecessary columns.

---

# Views vs Tables

| View | Table |
| --- | --- |
| Virtual table | Physical database object |
| Based on a query | Stores table data |
| Usually does not store separate data | Stores actual records |
| Can simplify complex queries | Main data storage structure |
| Depends on underlying tables | Independent data structure |

---

# Views vs Subqueries

A subquery is written directly inside another query.

Example:

```sql
SELECT *
FROM employees
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
);
```

A view stores a reusable query definition.

Example:

```sql
CREATE VIEW employee_view AS
SELECT
    emp_id,
    emp_name,
    department,
    salary
FROM employees;
```

Views are useful when the same query logic needs to be reused.

---

# Views with Aggregation

Views can be used to create reusable reports.

```sql
CREATE VIEW department_summary_view AS
SELECT
    department,
    COUNT(*) AS employee_count,
    AVG(salary) AS average_salary,
    MAX(salary) AS highest_salary,
    MIN(salary) AS lowest_salary
FROM employees
GROUP BY department;
```

Then:

```sql
SELECT *
FROM department_summary_view
ORDER BY average_salary DESC;
```

This makes the reporting query easier to reuse.

---

# Real World Applications

## E-Commerce

Views can be used for:

- Product reports
- Sales summaries
- Customer information
- Inventory reports
- Revenue analysis

## Banking

Views can be used for:

- Customer reports
- Account summaries
- Transaction reports
- Controlled access to sensitive data

## Human Resources

Views can be used for:

- Employee reports
- Department summaries
- Salary reports
- Employee performance analysis

## Healthcare

Views can be used for:

- Patient reports
- Appointment summaries
- Department statistics
- Controlled access to patient information

---

# Common Mistakes

## Creating Too Many Views

Views should be created when they provide a real benefit.

Too many unnecessary views can make database management difficult.

## Forgetting Underlying Dependencies

A view depends on the tables and columns used in its definition.

Changes to underlying tables can affect the view.

## Assuming Every View Is Updatable

Not every view can be updated directly.

Complex views containing aggregation, grouping, or certain other operations may not be updatable.

## Using Views Without Understanding Performance

A view does not automatically make a query faster.

The underlying query still needs to be efficient.

---

# Practice Questions

1. Create a view containing basic employee information.
2. Create a view containing only IT employees.
3. Create a view for employees earning more than 80000.
4. Create a department salary summary view.
5. Create a city-wise employee summary view.
6. Create a view that classifies employees by salary.
7. Create a view for experienced employees.
8. Create a view with a calculated monthly salary.
9. Query a view using WHERE.
10. Query a view using ORDER BY.
11. Use GROUP BY with a view.
12. Use an aggregate function with a view.
13. Modify an existing view.
14. Display all views in the database.
15. Display the definition of a view.
16. Drop an existing view.
17. Create a view for a reusable business report.
18. Create a view that hides unnecessary employee columns.
19. Compare a view with a subquery.
20. Analyze the advantages and limitations of views.

---

# Interview Questions

## What is a View?

A view is a virtual table based on the result of a SQL query.

## Does a View Store Data?

A normal view stores the query definition rather than storing a separate copy of the underlying data.

## Why Are Views Used?

Views are used to simplify queries, improve reusability, provide controlled access, and create reports.

## Can We Update a View?

Some simple views are updatable, but complex views may not be directly updatable.

## How Do You Create a View?

Use:

```sql
CREATE VIEW view_name AS
SELECT ...
```

## How Do You Modify a View?

Use:

```sql
CREATE OR REPLACE VIEW
```

or:

```sql
ALTER VIEW
```

## How Do You Delete a View?

Use:

```sql
DROP VIEW view_name;
```

## How Do You See the Definition of a View?

Use:

```sql
SHOW CREATE VIEW view_name;
```

## Can a View Contain Aggregate Functions?

Yes. Views can contain aggregate functions and GROUP BY clauses.

## Do Views Improve Performance?

Views primarily provide abstraction and reusability. A normal view does not automatically make the underlying query faster.

---

# Summary

Today I learned about SQL Views.

The main concepts covered were:

- What is a View
- Creating Views
- Querying Views
- Filtering Views
- Sorting Views
- Views with WHERE
- Views with GROUP BY
- Views with Aggregate Functions
- Views with CASE
- Calculated columns
- Updating simple Views
- CREATE OR REPLACE VIEW
- ALTER VIEW
- SHOW CREATE VIEW
- DROP VIEW
- Security using Views
- Views vs Tables
- Views vs Subqueries
- Real-world applications
- View best practices

Views provide a useful way to create reusable and simplified representations of database data.

---



