# Day 48 - Top SQL Interview Questions & Answers

# Introduction

SQL interviews usually test your understanding of queries, database concepts, joins, aggregation, subqueries, and optimization techniques.

Practicing these questions will improve your confidence in technical interviews.

---

# Question 1

## Write a query to display all employees.

```sql
SELECT * FROM employees;
```

---

# Question 2

## Find employees whose salary is greater than 60000.

```sql
SELECT *
FROM employees
WHERE salary > 60000;
```

---

# Question 3

## Display all employees working in the IT department.

```sql
SELECT *
FROM employees
WHERE department='IT';
```

---

# Question 4

## Find the highest salary.

```sql
SELECT MAX(salary)
FROM employees;
```

---

# Question 5

## Find the average salary.

```sql
SELECT AVG(salary)
FROM employees;
```

---

# Question 6

## Count employees in each department.

```sql
SELECT department,
COUNT(*)
FROM employees
GROUP BY department;
```

---

# Question 7

## Display employees sorted by salary in descending order.

```sql
SELECT *
FROM employees
ORDER BY salary DESC;
```

---

# Question 8

## Find the second highest salary.

```sql
SELECT MAX(salary)
FROM employees
WHERE salary <
(
SELECT MAX(salary)
FROM employees
);
```

---

# Question 9

## Find employees with salary between 50000 and 70000.

```sql
SELECT *
FROM employees
WHERE salary BETWEEN 50000 AND 70000;
```

---

# Question 10

## Display employees whose names start with 'J'.

```sql
SELECT *
FROM employees
WHERE emp_name LIKE 'J%';
```

---

# Additional Interview Questions (Theory)

### What is SQL?

SQL (Structured Query Language) is used to create, manage, and manipulate relational databases.

---

### Difference Between DELETE, TRUNCATE, and DROP?

| DELETE | TRUNCATE | DROP |
|---------|----------|------|
| Removes selected rows | Removes all rows | Removes the entire table |
| Can use WHERE | Cannot use WHERE | Deletes table structure |
| Can rollback (transactional engines) | Usually faster | Table no longer exists |

---

### Difference Between WHERE and HAVING?

- **WHERE** filters rows before grouping.
- **HAVING** filters groups after `GROUP BY`.

---

### Difference Between PRIMARY KEY and FOREIGN KEY?

- **PRIMARY KEY** uniquely identifies each row.
- **FOREIGN KEY** creates relationships between tables.

---

### Difference Between UNION and UNION ALL?

- **UNION** removes duplicates.
- **UNION ALL** keeps duplicates.

---

### Difference Between INNER JOIN and LEFT JOIN?

- **INNER JOIN** returns matching rows.
- **LEFT JOIN** returns all rows from the left table and matching rows from the right table.

---

# Interview Tips

- Practice writing queries without autocomplete.
- Understand concepts instead of memorizing answers.
- Explain your thought process while solving.
- Use meaningful aliases.
- Write clean and readable SQL.

---

# Summary

Today I practiced:

- Basic SQL queries
- Aggregate Functions
- GROUP BY
- ORDER BY
- Subqueries
- LIKE
- BETWEEN
- Common SQL interview questions
- SQL theory questions

These questions form a strong foundation for internships, placement drives, and SQL interviews.