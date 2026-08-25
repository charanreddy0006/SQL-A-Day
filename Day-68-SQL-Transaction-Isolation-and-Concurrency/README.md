# Day 68 — SQL Transaction Isolation Levels & Concurrency

## 📌 Overview

Day 68 continues from transactions and ACID properties and introduces one of the most important advanced database topics: **transaction isolation and concurrency control**.

A real database serves many users at the same time. Multiple transactions can read, insert, update, and delete data during overlapping periods. Without proper concurrency control, one transaction can interfere with another and produce incorrect or unexpected results.

The practical project uses a banking system and an inventory system to demonstrate these ideas.

The main topics are:

```text
Concurrency
Transaction Isolation
Isolation Levels
Dirty Reads
Non-Repeatable Reads
Phantom Reads
Lost Updates
Row Locks
FOR UPDATE
Lock Waits
Deadlocks
Deadlock Prevention
```

---

## 🎯 Learning Objectives

After completing Day 68, you should be able to:

- Explain database concurrency.
- Explain why isolation is required.
- Define transaction isolation levels.
- Explain READ UNCOMMITTED.
- Explain READ COMMITTED.
- Explain REPEATABLE READ.
- Explain SERIALIZABLE.
- Explain dirty reads.
- Explain non-repeatable reads.
- Explain phantom reads.
- Explain lost updates.
- Understand row-level locking.
- Use `SELECT ... FOR UPDATE`.
- Understand lock waits.
- Understand deadlocks.
- Explain how deadlocks can be reduced.
- Use consistent lock ordering.
- Apply concurrency control to banking.
- Apply concurrency control to inventory management.
- Check the current MySQL isolation level.
- Change the isolation level for a session.

---

# 1. What Is Concurrency?

Concurrency means that multiple transactions execute during overlapping periods of time.

For example:

```text
Transaction A
      ↓
Reads Account 1
      ↓
Updates Account 1

Transaction B
      ↓
Reads Account 1
      ↓
Updates Account 1
```

Both transactions can be active at the same time.

Concurrency is necessary because real applications have many users. A banking application may have thousands of customers performing transactions simultaneously.

---

# 2. Why Concurrency Creates Problems

Suppose an inventory table contains:

```text
Product: Laptop
Stock: 1
```

Two customers purchase the laptop at almost exactly the same time.

```text
Customer A → Buy 1
Customer B → Buy 1
```

If both transactions read:

```text
Stock = 1
```

before either transaction updates it, both applications may believe that the item is available.

The database therefore needs mechanisms for controlling concurrent access.

---

# 3. What Is Transaction Isolation?

Transaction isolation controls how one transaction interacts with other concurrent transactions.

In simple words:

> Isolation determines what a transaction can see while other transactions are working with the same data.

A stronger isolation level generally provides stronger consistency guarantees, but may cause more locking, waiting, or reduced concurrency.

---

# 4. Isolation Levels

The four commonly discussed SQL isolation levels are:

```text
READ UNCOMMITTED
READ COMMITTED
REPEATABLE READ
SERIALIZABLE
```

Conceptually:

```text
READ UNCOMMITTED
        ↓
READ COMMITTED
        ↓
REPEATABLE READ
        ↓
SERIALIZABLE
```

The exact implementation and behavior can vary between database systems. This project uses MySQL 8+ with InnoDB.

---

# 5. READ UNCOMMITTED

`READ UNCOMMITTED` is the weakest of the four commonly discussed isolation levels.

It can allow one transaction to read changes made by another transaction before those changes are committed.

Example:

```text
Initial balance = ₹50,000

Transaction A:
Changes balance to ₹45,000
Does not commit

Transaction B:
Reads ₹45,000

Transaction A:
ROLLBACK

Actual balance = ₹50,000
```

Transaction B saw a value that was later discarded.

---

# 6. Dirty Read

A dirty read occurs when a transaction reads data written by another transaction that has not yet committed.

Flow:

```text
Transaction A
      ↓
Changes data
      ↓
Does not commit
      ↓
Transaction B reads it
      ↓
Transaction A rolls back
```

The value read by B was never permanently committed.

This is why it is called a **dirty read**.

---

# 7. READ COMMITTED

`READ COMMITTED` prevents a transaction from reading uncommitted changes from another transaction.

Therefore:

```text
Dirty read → prevented
```

However, another transaction can change and commit a row between two reads.

Example:

```text
Transaction A:
SELECT balance
→ ₹30,000

Transaction B:
UPDATE balance
→ ₹35,000
COMMIT

Transaction A:
SELECT balance
→ ₹35,000
```

The same transaction obtained different values from two reads.

---

# 8. Non-Repeatable Read

A non-repeatable read occurs when a transaction reads the same row twice and receives different committed values because another transaction changed and committed the row between those reads.

Example:

```text
First read  → ₹30,000

Another transaction updates and commits

Second read → ₹35,000
```

The row itself is the same, but its committed value changed.

---

# 9. REPEATABLE READ

`REPEATABLE READ` provides stronger isolation than `READ COMMITTED` for consistent reads.

MySQL InnoDB commonly uses:

```text
REPEATABLE READ
```

as its default isolation level.

Under normal consistent-read behavior, a transaction can continue to use its transaction snapshot rather than seeing every later committed change.

This is important when a transaction needs a stable view of previously committed data.

---

# 10. SERIALIZABLE

`SERIALIZABLE` is the strongest of the four commonly discussed standard isolation levels.

It makes concurrent transactions behave more like transactions executed one after another.

Conceptually:

```text
Transaction A
      ↓
Complete
      ↓
Transaction B
      ↓
Complete
```

The advantage is stronger isolation.

The disadvantage can include:

```text
More locking
More waiting
More contention
Lower concurrency
Potentially lower throughput
```

---

# 11. Isolation Level Comparison

| Isolation Level | Dirty Read | Non-Repeatable Read | Phantom Read | General Concurrency |
|---|---|---|---|---|
| READ UNCOMMITTED | Possible | Possible | Possible | Highest |
| READ COMMITTED | Prevented | Possible | Possible | High |
| REPEATABLE READ | Prevented | Prevented for consistent reads | Engine/read dependent | Medium |
| SERIALIZABLE | Prevented | Prevented | Prevented by serializable behavior | Lowest |

The table is a conceptual comparison. Exact behavior depends on the database engine and the type of read or locking operation being used.

---

# 12. Phantom Read

A phantom read concerns a **set of rows**, not just one existing row.

Suppose Transaction A executes:

```sql
SELECT *
FROM inventory
WHERE stock_quantity > 10;
```

Then Transaction B inserts a new product with:

```text
stock_quantity = 30
```

If Transaction A runs the same range query again and sees a different set of matching rows, the newly appearing row is a phantom row.

The exact behavior depends on isolation level and database implementation.

---

# 13. Lost Update

A lost update can happen when two transactions read the same old value and then overwrite each other's work.

Example:

```text
Initial stock = 20

Transaction A reads 20
Transaction B reads 20

A calculates 19
B calculates 18

A writes 19
B writes 18
```

The effect of A's update is lost.

For simple counters, an atomic SQL update is often safer:

```sql
UPDATE inventory
SET stock_quantity = stock_quantity - 1
WHERE product_id = 101
  AND stock_quantity >= 1;
```

---

# 14. Atomic Updates

An atomic update lets the database perform the calculation as part of the update statement.

Instead of:

```text
SELECT stock
↓
Calculate in application
↓
UPDATE stock
```

use:

```sql
UPDATE inventory
SET stock_quantity = stock_quantity - 1
WHERE product_id = 101
  AND stock_quantity >= 1;
```

The application should also check the affected-row count before treating the operation as successful.

---

# 15. Row-Level Locking

A database can lock rows to coordinate concurrent modifications.

One important MySQL pattern is:

```sql
SELECT ... FOR UPDATE;
```

Example:

```sql
START TRANSACTION;

SELECT balance
FROM bank_accounts
WHERE account_id = 1
FOR UPDATE;

UPDATE bank_accounts
SET balance = balance - 5000
WHERE account_id = 1
  AND balance >= 5000;

COMMIT;
```

The locking read is used to coordinate modification of the selected row.

---

# 16. Why FOR UPDATE Is Useful

Imagine:

```text
Balance = ₹10,000
```

Two transactions both want to withdraw ₹8,000.

Both transactions need to make their decision based on the same account balance.

A locking read can coordinate access:

```sql
SELECT balance
FROM bank_accounts
WHERE account_id = 1
FOR UPDATE;
```

The transaction can then validate the balance and perform the update.

---

# 17. Lock Wait

Suppose Session A executes:

```sql
START TRANSACTION;

SELECT *
FROM bank_accounts
WHERE account_id = 2
FOR UPDATE;
```

and keeps the transaction open.

Session B then tries:

```sql
UPDATE bank_accounts
SET balance = balance + 1000
WHERE account_id = 2;
```

Session B may have to wait for the relevant lock to be released.

When Session A executes:

```sql
COMMIT;
```

the lock can be released and Session B can continue, subject to the transaction state and lock configuration.

---

# 18. Deadlock

A deadlock occurs when transactions wait for one another in a circular dependency.

Example:

```text
Transaction A
    ↓
Locks Row 1
    ↓
Waits for Row 2

Transaction B
    ↓
Locks Row 2
    ↓
Waits for Row 1
```

Now:

```text
A waits for B
B waits for A
```

Neither can continue without one transaction being interrupted.

---

# 19. Deadlock Detection

InnoDB can detect deadlocks.

When a deadlock is detected, InnoDB normally chooses one transaction as a victim and rolls it back so that another transaction can continue.

Applications should be prepared to handle deadlock errors and retry appropriate transactions when required.

---

# 20. Deadlock Prevention

A useful technique is to acquire locks in a consistent order.

For account transfers, for example:

```text
Always lock the smaller account_id first.
```

For accounts 1 and 4:

```text
Lock Account 1
       ↓
Lock Account 4
```

Even if another transaction transfers in the opposite business direction, it can still lock the same account IDs in ascending order.

This reduces the chance of circular waits.

---

# 21. Banking Concurrency Example

Suppose:

```text
Account 1 = ₹50,000
Account 2 = ₹30,000
```

Transfer:

```text
₹5,000
```

A safe transaction can follow:

```text
1. Lock required rows
2. Validate balance
3. Debit sender
4. Credit receiver
5. Commit
```

Example:

```sql
START TRANSACTION;

SELECT account_id, balance
FROM bank_accounts
WHERE account_id IN (1, 2)
ORDER BY account_id
FOR UPDATE;

UPDATE bank_accounts
SET balance = balance - 5000
WHERE account_id = 1
  AND balance >= 5000;

UPDATE bank_accounts
SET balance = balance + 5000
WHERE account_id = 2;

COMMIT;
```

The consistent ordering of locks helps reduce deadlock risk.

---

# 22. Inventory Concurrency Example

Suppose:

```text
Laptop stock = 1
```

Two customers attempt to purchase it at the same time.

A transaction can lock the inventory row:

```sql
START TRANSACTION;

SELECT stock_quantity
FROM inventory
WHERE product_id = 101
FOR UPDATE;

UPDATE inventory
SET stock_quantity = stock_quantity - 1
WHERE product_id = 101
  AND stock_quantity >= 1;

COMMIT;
```

This coordinates concurrent access to the inventory row.

---

# 23. Inventory Reservation Transaction

The project also demonstrates a transaction that:

```text
Locks inventory
      ↓
Checks stock
      ↓
Decreases stock
      ↓
Creates order
      ↓
Commits
```

This is a common pattern in e-commerce systems.

---

# 24. Isolation Level Syntax

Change the isolation level for the current session:

```sql
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
```

Other examples:

```sql
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
```

```sql
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
```

```sql
SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;
```

---

# 25. Check Current Isolation Level

Use:

```sql
SELECT @@transaction_isolation;
```

The project also checks the global default:

```sql
SELECT @@global.transaction_isolation;
```

For learning experiments, session-level changes are preferred because they affect the current connection rather than changing the default for the entire server.

---

# 26. Session vs Global

### Session

A session-level setting affects the current database connection.

```sql
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
```

### Global

A global setting affects the default used by sessions according to MySQL's configuration and privileges.

For normal learning experiments, use session-level settings.

---

# 27. Consistent Reads

A consistent read uses a transactionally consistent view of data.

For example:

```sql
START TRANSACTION;

SELECT *
FROM bank_accounts;

SELECT *
FROM bank_accounts;

COMMIT;
```

Under appropriate isolation behavior, both reads can use the transaction's consistent view.

This concept is especially important for understanding InnoDB's `REPEATABLE READ` behavior.

---

# 28. Consistent Read vs Locking Read

These should be distinguished.

### Consistent read

Example:

```sql
SELECT *
FROM bank_accounts
WHERE account_id = 1;
```

This is normally a non-locking consistent read.

### Locking read

Example:

```sql
SELECT *
FROM bank_accounts
WHERE account_id = 1
FOR UPDATE;
```

This requests locking behavior for the selected row within the transaction.

---

# 29. Why Isolation Has a Cost

Higher isolation can require more coordination.

This can cause:

```text
More locking
More waiting
More contention
Lower concurrency
Potentially lower throughput
```

Lower isolation can allow:

```text
More concurrency
Less waiting
Higher throughput
```

but may provide weaker consistency guarantees.

Therefore, isolation is a design trade-off.

---

# 30. Isolation as a Trade-Off

Think of the relationship like this:

```text
More Isolation
      ↓
Stronger Consistency
      ↓
Potentially More Waiting
      ↓
Lower Concurrency
```

versus:

```text
Less Isolation
      ↓
More Concurrency
      ↓
Less Waiting
      ↓
Potentially Weaker Guarantees
```

The correct level depends on the application's requirements.

---

# 31. Why InnoDB Is Used

The project explicitly creates tables using:

```sql
ENGINE=InnoDB;
```

InnoDB is used because it supports important transactional features including:

```text
Transactions
Row-level locking
Concurrency control
Foreign keys
```

The examples are intended for MySQL 8+ with InnoDB.

---

# 32. Two-Session Testing

Several concurrency examples cannot be properly demonstrated in one SQL session.

Use two separate connections:

```text
Session A
+
Session B
```

For example, open two MySQL Workbench query windows connected to the same database.

Both sessions should use:

```sql
USE concurrency_lab;
```

---

# 33. Dirty Read Test

### Session A

```sql
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
START TRANSACTION;

UPDATE bank_accounts
SET balance = balance - 5000
WHERE account_id = 1;
```

Do not commit.

### Session B

```sql
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
START TRANSACTION;

SELECT balance
FROM bank_accounts
WHERE account_id = 1;
```

Session B may see the uncommitted value.

### Session A

```sql
ROLLBACK;
```

### Session B

```sql
COMMIT;
```

The important lesson is that Session B may have observed a value that never became permanent.

---

# 34. Non-Repeatable Read Test

### Session A

```sql
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;

SELECT balance
FROM bank_accounts
WHERE account_id = 2;
```

### Session B

```sql
START TRANSACTION;

UPDATE bank_accounts
SET balance = balance + 5000
WHERE account_id = 2;

COMMIT;
```

### Session A

```sql
SELECT balance
FROM bank_accounts
WHERE account_id = 2;

COMMIT;
```

The second read can show the new committed value.

---

# 35. Repeatable Read Test

### Session A

```sql
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;

SELECT balance
FROM bank_accounts
WHERE account_id = 3;
```

### Session B

```sql
UPDATE bank_accounts
SET balance = balance + 2000
WHERE account_id = 3;

COMMIT;
```

### Session A

```sql
SELECT balance
FROM bank_accounts
WHERE account_id = 3;

COMMIT;
```

Compare the two results to understand the consistent-read snapshot behavior.

---

# 36. Lock Wait Test

### Session A

```sql
START TRANSACTION;

SELECT balance
FROM bank_accounts
WHERE account_id = 2
FOR UPDATE;
```
