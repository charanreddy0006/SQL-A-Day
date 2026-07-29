# Day 47 - ACID Properties

# Introduction

ACID is a set of four properties that guarantee reliable and secure database transactions.

ACID stands for:

- Atomicity
- Consistency
- Isolation
- Durability

These properties ensure that transactions are completed correctly even when failures occur.

---

# 1. Atomicity

**Definition**

Atomicity means **"All or Nothing."**

Either every operation in a transaction is completed successfully, or the entire transaction is rolled back.

### Example

```sql
START TRANSACTION;

UPDATE accounts
SET balance = balance - 500
WHERE account_id = 101;

UPDATE accounts
SET balance = balance + 500
WHERE account_id = 102;

COMMIT;
```

If one update fails, both updates are cancelled.

---

# 2. Consistency

**Definition**

Consistency ensures that the database always remains in a valid state before and after a transaction.

### Example

Before Transfer:

John → $1000

Emma → $2000

Total → $3000

After Transfer:

John → $500

Emma → $2500

Total → $3000

The total balance remains unchanged.

---

# 3. Isolation

**Definition**

Isolation ensures that multiple transactions do not interfere with each other.

Each transaction behaves as if it is running alone.

### Example

Two users transferring money simultaneously should not affect each other's transactions.

---

# 4. Durability

**Definition**

Once a transaction is committed, the changes become permanent.

Even if the database server crashes immediately after COMMIT, the committed data is preserved.

---

# ACID Summary

| Property | Meaning |
|-----------|---------|
| Atomicity | All or Nothing |
| Consistency | Valid database state |
| Isolation | Independent transactions |
| Durability | Permanent changes |

---

# ACID vs Non-ACID Databases

| ACID Database | Non-ACID Database |
|---------------|-------------------|
| Strong consistency | Eventual consistency |
| Suitable for banking | Suitable for big data |
| Reliable transactions | High scalability |
| Example: MySQL | Example: MongoDB (default behavior) |

---

# Advantages

- Reliable transactions
- Prevents data corruption
- Maintains consistency
- Essential for banking and finance
- Improves database integrity

---

# Real-World Applications

## Banking

Money transfers.

---

## Hospital

Patient billing.

---

## Airline Reservation

Seat booking.

---

## E-Commerce

Payment processing.

---

# Common Mistakes

## Forgetting COMMIT

Without COMMIT, changes are not permanently saved.

---

## Assuming Every Database Is ACID

Some NoSQL databases trade strict ACID guarantees for higher scalability.

---

# Practice Queries

```sql
START TRANSACTION;

UPDATE accounts
SET balance = balance - 100
WHERE account_id = 101;

UPDATE accounts
SET balance = balance + 100
WHERE account_id = 102;

COMMIT;
```

---

# Interview Questions

## What does ACID stand for?

- Atomicity
- Consistency
- Isolation
- Durability

---

## What is Atomicity?

It ensures that all operations in a transaction succeed together or fail together.

---

## What is Durability?

Committed changes remain permanent even after a system crash.

---

## Which databases follow ACID?

MySQL, PostgreSQL, Oracle, SQL Server, and many other relational databases.

---

# Summary

Today I learned:

- ACID Properties
- Atomicity
- Consistency
- Isolation
- Durability
- ACID vs Non-ACID Databases

ACID properties ensure that database transactions are reliable, consistent, and fault-tolerant, making them essential for enterprise applications.