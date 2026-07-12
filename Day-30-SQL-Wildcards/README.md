# Day 30 - SQL Wildcards

# Introduction

Wildcards are special characters used with the LIKE operator to search for patterns in text.

Wildcards make searching flexible because we don't always know the exact value stored in a database.

SQL provides two wildcard characters:

- %
- _

These are widely used in search bars, employee management systems, banking applications, hospital systems, and e-commerce websites.

---

# What are Wildcards?

Wildcards are special symbols that represent unknown characters.

They help us search data based on patterns instead of exact values.

---

# Types of Wildcards

| Wildcard | Meaning |
|----------|----------|
| % | Zero, one, or many characters |
| _ | Exactly one character |

---

# 1. % Wildcard

The % wildcard represents any number of characters.

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
- Joseph

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

---

## Contains

```sql
SELECT *
FROM employees
WHERE emp_name LIKE '%en%';
```

Returns:

- Jennifer

The letters "en" appear anywhere in the name.

---

# 2. _ Wildcard

The _ wildcard represents exactly one character.

Example:

```sql
SELECT *
FROM employees
WHERE emp_name LIKE '____';
```

Returns:

- John
- Emma

Because both names contain exactly four letters.

---

## Second Letter is 'o'

```sql
SELECT *
FROM employees
WHERE emp_name LIKE '_o%';
```

Returns:

- John
- Joseph

The first character can be anything, but the second character must be "o".

---

## Exactly Five Characters

```sql
SELECT *
FROM employees
WHERE emp_name LIKE '_____';
```

Returns names having exactly five letters.

---

# Combining Wildcards

Example:

```sql
SELECT *
FROM employees
WHERE emp_name LIKE 'Ja%';
```

Returns:

- Jack
- James

Starts with "Ja" followed by any number of characters.

---

# Difference Between % and _

| % | _ |
|---|---|
|Matches zero or more characters|Matches exactly one character|

Example:

```sql
LIKE 'J%'
```

Matches:

- John
- Jack
- James
- Jennifer

Example:

```sql
LIKE 'J___'
```

Matches only names with four letters starting with J.

Example:

- John

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
WHERE product_name LIKE '%Laptop%';
```

---

## College Management

Search students by name.

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

## Confusing % and _

% matches multiple characters.

_ matches exactly one character.

---

## Forgetting Quotes

Incorrect

```sql
LIKE J%
```

Correct

```sql
LIKE 'J%'
```

---

## Using = Instead of LIKE

Incorrect

```sql
WHERE emp_name = 'J%';
```

Correct

```sql
WHERE emp_name LIKE 'J%';
```

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
WHERE emp_name LIKE '_o%';

SELECT *
FROM employees
WHERE emp_name LIKE '_____';

SELECT *
FROM employees
WHERE department LIKE 'F%';
```

---

# Interview Questions

## What are SQL Wildcards?

Special characters used with the LIKE operator to perform pattern matching.

---

## What does % represent?

Zero, one, or many characters.

---

## What does _ represent?

Exactly one character.

---

## Can Wildcards be used without LIKE?

No.

Wildcards are used together with the LIKE operator.

---

# Summary

Today I learned:

- SQL Wildcards
- % Wildcard
- _ Wildcard
- Pattern Matching
- Combining Wildcards
- Real-World Applications

Wildcards make SQL searches flexible and are essential for building search features in real-world applications.