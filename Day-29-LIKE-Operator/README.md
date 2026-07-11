# Day 29 - LIKE Operator

# Introduction

The LIKE operator is used to search for values that match a specific pattern.

Unlike the = operator, which searches for an exact value, LIKE allows us to search for partial matches.

The LIKE operator is commonly used in search boxes, employee management systems, e-commerce websites, banking applications, and many other real-world systems.

---

# What is the LIKE Operator?

The LIKE operator compares a value with a pattern.

It is mainly used with text (VARCHAR, CHAR) columns.

---

# Syntax

```sql
SELECT column_name
FROM table_name
WHERE column_name LIKE 'pattern';
```

---

# Why Do We Need LIKE?

Suppose we want to find all employees whose names start with the letter **J**.

Without LIKE, we would have to compare each name individually.

Using LIKE makes this much easier.

---

# Wildcards Used with LIKE

SQL provides two wildcard characters.

| Wildcard | Meaning |
|----------|----------|
| % | Represents zero, one, or many characters |
| _ | Represents exactly one character |

---

# The % Wildcard

The `%` wildcard matches any number of characters.

## Starts With

```sql
SELECT *
FROM employees
WHERE emp_name LIKE 'J%';
```

Returns:

- John
- James
- Jack
- Jennifer

All names starting with **J**.

---

## Ends With

```sql
SELECT *
FROM employees
WHERE emp_name LIKE '%a';
```

Returns:

- Emma
- Sophia

All names ending with **a**.

---

## Contains

```sql
SELECT *
FROM employees
WHERE emp_name LIKE '%av%';
```

Returns:

- David

The letters **av** appear anywhere in the name.

---

# The _ Wildcard

The `_` wildcard represents exactly one character.

Example:

```sql
SELECT *
FROM employees
WHERE emp_name LIKE '____';
```

Returns names with exactly **4 characters**.

Example:

- John
- Emma

---

# Starts With Specific Letters

```sql
SELECT *
FROM employees
WHERE emp_name LIKE 'Ja%';
```

Returns:

- James
- Jack

---

# Difference Between = and LIKE

Using =

```sql
WHERE emp_name = 'John';
```

Returns only John.

Using LIKE

```sql
WHERE emp_name LIKE 'Jo%';
```

Returns every name starting with "Jo".

LIKE is more flexible.

---

# Real-World Applications

## Banking

Search customers by name.

```sql
WHERE customer_name LIKE 'A%';
```

---

## E-Commerce

Search products.

```sql
WHERE product_name LIKE '%Phone%';
```

---

## College Management

Search students.

```sql
WHERE student_name LIKE 'R%';
```

---

## Hospital Management

Search doctors.

```sql
WHERE doctor_name LIKE '%Kumar';
```

---

# Common Mistakes

## Forgetting Quotes

Incorrect

```sql
WHERE emp_name LIKE J%;
```

Correct

```sql
WHERE emp_name LIKE 'J%';
```

---

## Confusing % and _

`%`

Matches any number of characters.

`_`

Matches exactly one character.

---

# Practice Queries

```sql
SELECT *
FROM employees
WHERE emp_name LIKE 'J%';

SELECT *
FROM employees
WHERE emp_name LIKE '%a';

SELECT *
FROM employees
WHERE emp_name LIKE '%av%';

SELECT *
FROM employees
WHERE emp_name LIKE '____';

SELECT *
FROM employees
WHERE emp_name LIKE 'Ja%';
```

---

# Interview Questions

## What is the LIKE operator?

The LIKE operator is used to search for data using patterns.

---

## What does % represent?

It represents zero, one, or many characters.

---

## What does _ represent?

It represents exactly one character.

---

## Difference between = and LIKE?

`=`

Searches for an exact value.

`LIKE`

Searches using patterns.

---

# Summary

Today I learned:

- LIKE Operator
- Pattern Matching
- % Wildcard
- _ Wildcard
- Searching Text
- Difference Between = and LIKE
- Real-World Applications

The LIKE operator is one of the most commonly used SQL operators for searching text based on patterns.