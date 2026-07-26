# Day 44 - SQL Transactions

# Introduction

A Transaction is a sequence of one or more SQL statements executed as a single unit of work.

A transaction ensures that either all operations are completed successfully or none of them are applied.

This helps maintain data consistency and integrity.

---

# Why Use Transactions?

- Maintain data consistency.
- Prevent partial updates.
- Handle errors safely.
- Ensure reliable database operations.

---

# Transaction Control Statements

## START TRANSACTION

Begins a new transaction.

```sql
START TRANSACTION;
```

---

## COMMIT

Permanently saves all changes made during the transaction.

```sql
COMMIT;
```

---

## ROLLBACK

Undoes all changes made since the transaction started.

```sql
ROLLBACK;
```

---

## SAVEPOINT

Creates a checkpoint inside a transaction.

```sql
SAVEPOINT sp1;
```

---

## ROLLBACK TO SAVEPOINT

Rolls back only to a specific savepoint.

```sql
ROLLBACK TO sp1;
```

---

# Example 1

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

Transfers money successfully.

---

# Example 2

```sql
START TRANSACTION;

UPDATE accounts
SET balance = balance - 200
WHERE account_id = 101;

ROLLBACK;
```

Cancels the transaction.

---

# Example 3

```sql
SAVEPOINT sp1;

ROLLBACK TO sp1;
```

Returns to the savepoint without canceling the entire transaction.

---

# Advantages

- Maintains consistency.
- Prevents data corruption.
- Handles failures safely.
- Essential for banking and financial systems.

---

# Limitations

- Long transactions can lock database resources.
- Excessive transactions may reduce performance.

---

# Real-World Applications

## Banking

Money transfers between accounts.

---

## E-Commerce

Order placement and payment processing.

---

## Hospital

Patient billing and medical record updates.

---

## Airline Reservation

Booking and seat allocation.

---

# Common Mistakes

## Forgetting COMMIT

Without COMMIT, changes may not be permanently saved.

---

## Rolling Back After COMMIT

Once COMMIT is executed, changes cannot be rolled back.

---

# Practice Queries

```sql
START TRANSACTION;

UPDATE accounts
SET balance = balance - 50
WHERE account_id = 101;

SAVEPOINT sp2;

UPDATE accounts
SET balance = balance + 50
WHERE account_id = 102;

ROLLBACK TO sp2;

COMMIT;
```

---

# Interview Questions

## What is a Transaction?

A group of SQL statements executed as a single unit of work.

---

## What is COMMIT?

It permanently saves all changes made during a transaction.

---

## What is ROLLBACK?

It cancels all uncommitted changes.

---

## What is SAVEPOINT?

A checkpoint within a transaction that allows partial rollback.

---

## Difference Between COMMIT and ROLLBACK?

| COMMIT | ROLLBACK |
|---------|----------|
| Saves changes permanently | Undoes changes |
| Ends the transaction | Cancels the transaction |

---

# Summary

Today I learned:

- Transactions
- START TRANSACTION
- COMMIT
- ROLLBACK
- SAVEPOINT
- ROLLBACK TO SAVEPOINT

Transactions ensure that database operations are completed safely and reliably, making them essential for enterprise applications.