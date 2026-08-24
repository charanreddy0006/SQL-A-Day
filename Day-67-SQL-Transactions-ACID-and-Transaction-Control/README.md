# Day 67 — SQL Transactions, ACID Properties & Transaction Control

## 📌 Overview

Day 67 focuses on SQL transactions and the concepts that make database operations reliable and safe.

The practical database used in this lesson is a small banking system because money transfers clearly demonstrate why transaction control is required.

The main idea is simple:

> Multiple related SQL operations should be treated as one logical unit of work.

The SQL file demonstrates `START TRANSACTION`, `COMMIT`, `ROLLBACK`, `SAVEPOINT`, autocommit, transaction logging, stored procedures, exception handling, and row locking with `FOR UPDATE`.

---

## 🎯 Learning Objectives

After completing Day 67, the following concepts should be understood:

- What a transaction is
- Why transactions are required
- ACID properties
- Atomicity
- Consistency
- Isolation
- Durability
- `START TRANSACTION`
- `BEGIN`
- `COMMIT`
- `ROLLBACK`
- `SAVEPOINT`
- `ROLLBACK TO SAVEPOINT`
- Autocommit
- Manual transaction control
- Multi-step transactions
- Failed transaction handling
- Transaction audit logging
- Stored procedures
- Exception handlers
- `SIGNAL`
- `FOR UPDATE`
- Safe banking transfers
- Transaction lifecycle

---

## 📁 Folder Structure

```text
Day-67-SQL-Transactions-ACID-and-Transaction-Control/
│
├── day67.sql
└── README.txt
```

---

## 📄 Files

### `day67.sql`

Complete MySQL script containing the database, tables, sample data, transaction examples, rollback examples, savepoints, autocommit demonstrations, audit logging, stored procedure, and final reports.

### `README.txt`

Detailed Markdown documentation for the complete Day 67 topic.

---

# 1. What Is a Transaction?

A transaction is a logical unit of database work containing one or more SQL operations.

For example, a bank transfer of ₹5,000 requires:

```text
Account A
    ↓
Debit ₹5,000

Account B
    ↓
Credit ₹5,000
```

Both operations belong to the same logical operation.

If the debit succeeds but the credit fails, the database should not remain partially updated.

A transaction provides the mechanism to handle this safely.

---

# 2. Why Transactions Are Important

Consider:

```text
Account A = ₹20,000
Account B = ₹10,000
```

Transfer:

```text
₹5,000
```

Expected result:

```text
Account A = ₹15,000
Account B = ₹15,000
```

The total remains:

```text
₹30,000
```

Without proper transaction control, a failure after the first update could produce:

```text
Account A = ₹15,000
Account B = ₹10,000
```

The database has become inconsistent.

Transactions allow the application to commit the complete operation or roll it back.

---

# 3. ACID Properties

ACID stands for:

```text
A → Atomicity
C → Consistency
I → Isolation
D → Durability
```

These properties describe important reliability characteristics of database transactions.

---

# 4. Atomicity

Atomicity means:

> A transaction behaves as one unit of work: either the required operations succeed together or the transaction is rolled back.

The easiest way to remember it is:

**All or Nothing**

Example:

```text
Debit sender
     +
Credit receiver
```

If the receiver cannot be credited, the sender's debit should not remain as a completed transfer.

---

# 5. Consistency

Consistency means a successful transaction should leave the database in a valid state according to its rules, constraints, and application requirements.

For example:

```text
Before transfer:
A = ₹20,000
B = ₹10,000
Total = ₹30,000

After transfer:
A = ₹15,000
B = ₹15,000
Total = ₹30,000
```

The required balance relationship is preserved.

Database constraints such as:

```text
PRIMARY KEY
FOREIGN KEY
UNIQUE
CHECK
```

also help enforce valid data.

---

# 6. Isolation

Isolation concerns how concurrent transactions interact.

A database can have many users executing transactions simultaneously.

For example:

```text
Transaction A
Transaction B
Transaction C
```

If multiple transactions access the same account at the same time, the database must control their interaction so that invalid intermediate states are not incorrectly observed or used.

Isolation is particularly important for:

- Banking
- Payments
- Inventory
- Ticket booking
- Reservations
- E-commerce

---

# 7. Durability

Durability means that after a successful commit, the database is expected to preserve the committed changes even if the system subsequently experiences a failure, subject to the database engine's durability guarantees.

Example:

```sql
COMMIT;
```

After a successful commit, the transaction is considered completed.

---

# 8. START TRANSACTION

A transaction can be explicitly started using:

```sql
START TRANSACTION;
```

Example:

```sql
START TRANSACTION;

UPDATE accounts
SET balance = balance - 5000
WHERE account_id = 1;

UPDATE accounts
SET balance = balance + 5000
WHERE account_id = 2;

COMMIT;
```

Both updates belong to the same transaction.

---

# 9. BEGIN

`BEGIN` can also be used to start a transaction in MySQL.

Example:

```sql
BEGIN;

UPDATE accounts
SET balance = balance - 1000
WHERE account_id = 1;

UPDATE accounts
SET balance = balance + 1000
WHERE account_id = 2;

COMMIT;
```

The project uses `START TRANSACTION` because it makes the purpose explicit.

---

# 10. COMMIT

`COMMIT` successfully completes the current transaction.

Example:

```sql
START TRANSACTION;

UPDATE accounts
SET balance = balance - 2000
WHERE account_id = 1;

UPDATE accounts
SET balance = balance + 2000
WHERE account_id = 2;

COMMIT;
```

After a successful commit, the changes are permanently recorded according to the database's transaction guarantees.

---

# 11. ROLLBACK

`ROLLBACK` cancels changes made by the current transaction.

Example:

```sql
START TRANSACTION;

UPDATE accounts
SET balance = balance - 5000
WHERE account_id = 1;

ROLLBACK;
```

The balance change is undone.

Rollback is useful when:

- A validation fails
- A business rule fails
- An operation cannot continue
- A dependent operation fails
- An application cancels the operation
- An SQL error occurs

---

# 12. COMMIT vs ROLLBACK

| COMMIT | ROLLBACK |
|---|---|
| Completes the transaction | Aborts the transaction |
| Saves transactional changes | Undoes transactional changes |
| Used after successful work | Used after failure/cancellation |
| Ends the successful transaction | Ends the transaction by reverting its changes |

---

# 13. SAVEPOINT

A `SAVEPOINT` creates a named point inside a transaction.

Example:

```sql
START TRANSACTION;

UPDATE accounts
SET balance = balance - 3000
WHERE account_id = 1;

SAVEPOINT after_debit;

UPDATE accounts
SET balance = balance + 3000
WHERE account_id = 2;

SAVEPOINT after_credit;
```

The transaction now has named points that can be used for partial rollback.

---

# 14. ROLLBACK TO SAVEPOINT

Instead of cancelling the complete transaction, you can roll back to a savepoint.

Example:

```sql
ROLLBACK TO after_credit;
```

This removes changes made after that savepoint while retaining earlier transactional work.

The remaining transaction can then be committed:

```sql
COMMIT;
```

---

# 15. SAVEPOINT Flow

```text
START TRANSACTION
       ↓
Operation 1
       ↓
SAVEPOINT A
       ↓
Operation 2
       ↓
SAVEPOINT B
       ↓
Operation 3
       ↓
ROLLBACK TO B
       ↓
COMMIT
```

Savepoints are useful for complex transactions containing several stages.

---

# 16. Autocommit

MySQL commonly has autocommit enabled by default.

Check the setting:

```sql
SELECT @@autocommit;
```

A value of:

```text
1
```

means autocommit is enabled.

When autocommit is enabled, successful individual statements are generally committed automatically unless they are being executed within an explicit transaction.

---

# 17. Disable Autocommit

Autocommit can be disabled:

```sql
SET autocommit = 0;
```

Then changes can be controlled manually.

Example:

```sql
SET autocommit = 0;

UPDATE accounts
SET balance = balance + 1000
WHERE account_id = 1;

ROLLBACK;
```

The update is rolled back.

---

# 18. Enable Autocommit

Autocommit can be restored with:

```sql
SET autocommit = 1;
```

It is useful to restore the setting after experimenting with manual transaction control.

---

# 19. Multi-Step Bank Transfer

A realistic transfer can contain several steps:

```text
1. Validate sender
2. Validate receiver
3. Check balance
4. Debit sender
5. Credit receiver
6. Record transfer
7. Commit
```

These operations should be coordinated as one transaction.

Example:

```sql
START TRANSACTION;

UPDATE accounts
SET balance = balance - 7500
WHERE account_id = 3
  AND account_status = 'Active'
  AND balance >= 7500;

UPDATE accounts
SET balance = balance + 7500
WHERE account_id = 4
  AND account_status = 'Active';

INSERT INTO transfer_log
(from_account_id, to_account_id, transfer_amount, transfer_status)
VALUES
(3, 4, 7500, 'Completed');

COMMIT;
```

---

# 20. Failed Transfer

The project deliberately contains a frozen account:

```text
Account 6 → Frozen
```

A transfer to a frozen account should not be completed.

The example demonstrates how a transaction can be rolled back rather than leaving a partial debit.

```sql
START TRANSACTION;

UPDATE accounts
SET balance = balance - 4000
WHERE account_id = 1
  AND account_status = 'Active';

UPDATE accounts
SET balance = balance + 4000
WHERE account_id = 6
  AND account_status = 'Active';

ROLLBACK;
```

The rollback prevents the sender's debit from remaining as a partial operation.

---

# 21. Transaction Audit Log

The project contains:

```text
transaction_audit
```

This table records important account operations.

Columns include:

```text
audit_id
account_id
operation_type
amount
description
created_at
```

For a transfer, separate debit and credit operations can be recorded.

---

# 22. Transfer Log

The project also contains:

```text
transfer_log
```

Important fields include:

```text
transfer_id
from_account_id
to_account_id
transfer_amount
transfer_status
transfer_time
remarks
```

This gives the database a history of transfer operations.

---

# 23. Stored Procedure

The SQL file creates a procedure called:

```text
transfer_money
```

It accepts:

```text
from account
to account
amount
```

Example:

```sql
CALL transfer_money(1, 2, 1500.00);
```

The procedure performs validation before changing balances.

---

# 24. Validations in the Procedure

The procedure checks:

```text
Transfer amount > 0
Sender and receiver are different
Sender account is active
Receiver account is active
Sender has sufficient balance
```

If any validation fails, the procedure raises an error.

---

# 25. Exception Handling

The stored procedure includes an exception handler.

Conceptually:

```text
START TRANSACTION
       ↓
Perform operations
       ↓
      Error?
     /        YES      NO
   ↓         ↓
ROLLBACK   COMMIT
```

This is useful for preventing partial database updates.

---

# 26. SIGNAL

The procedure uses:

```sql
SIGNAL SQLSTATE '45000'
```

This allows a custom application-level error to be raised.

Examples:

```text
Transfer amount must be greater than zero
Sender and receiver cannot be the same account
Sender account is not active
Receiver account is not active
Insufficient balance
```

---

# 27. FOR UPDATE

The procedure uses:

```sql
SELECT ...
FOR UPDATE;
```

`FOR UPDATE` is used within a transaction to request locking of the selected rows for modification.

This is useful when multiple concurrent transactions may attempt to update the same account.

---

# 28. Why FOR UPDATE Matters

Imagine:

```text
Balance = ₹10,000
```

Two transactions simultaneously attempt:

```text
Transaction A → Withdraw ₹8,000
Transaction B → Withdraw ₹8,000
```

Both should not independently assume that the original ₹10,000 is still available.

Appropriate locking and transaction isolation can coordinate access to the row.

`FOR UPDATE` is one mechanism used for this type of transactional control in MySQL.

---

# 29. Transaction Lifecycle

A simplified transaction lifecycle is:

```text
ACTIVE
  ↓
Execute operations
  ↓
 ┌───────────────┐
 ↓               ↓
SUCCESS        FAILURE
 ↓               ↓
COMMIT        ROLLBACK
 ↓               ↓
COMMITTED       ABORTED
```

---

# 30. Transaction States

### Active

The transaction is executing.

### Partially Committed

The transaction has completed its final operation but is still completing its commit process.

### Committed

The transaction has successfully completed.

### Failed

The transaction cannot continue normally because an error occurred.

### Aborted

The transaction has been rolled back.

---

# 31. Transaction vs Query

A query is generally a single SQL statement.

A transaction can contain multiple SQL statements.

### Query

```sql
UPDATE accounts
SET balance = balance - 1000
WHERE account_id = 1;
```

### Transaction

```sql
START TRANSACTION;

UPDATE accounts
SET balance = balance - 1000
WHERE account_id = 1;

UPDATE accounts
SET balance = balance + 1000
WHERE account_id = 2;

INSERT INTO transfer_log (...);

COMMIT;
```

Therefore:

```text
Query
  ↓
SQL operation

Transaction
  ↓
One logical unit containing one or more operations
```

---

# 32. Transaction vs ACID

These concepts should not be confused.

### Transaction

A logical unit of database work.

### ACID

Properties describing important reliability requirements for transactions.

```text
Transaction
     ↓
ACID properties
     ↓
Atomicity
Consistency
Isolation
Durability
```

---

# 33. Real-World Applications

Transactions are used extensively in:

### Banking

```text
Debit account
+
Credit account
```

### E-Commerce

```text
Create order
+
Reduce inventory
+
Record payment
```

### Ticket Booking

```text
Reserve seat
+
Create booking
+
Process payment
```

### Inventory

```text
Reduce stock
+
Create shipment
+
Record inventory movement
```

### Payroll

```text
Calculate payment
+
Create payroll record
+
Update payment status
```

---

# 34. Database Schema

The project uses three tables:

```text
accounts
    │
    ├──────────────┐
    ↓              ↓
transfer_log   transaction_audit
```

### Accounts

Stores account and balance information.

### Transfer Log

Stores transfer history.

### Transaction Audit

Stores debit/credit audit operations.

---

# 35. Accounts Table

Important columns:

```text
account_id
account_number
account_holder
account_type
balance
account_status
created_at
```

The balance has:

```sql
CHECK (balance >= 0)
```

This prevents values below zero when the database engine enforces the constraint.

---

# 36. Transfer Status

Transfers can have:

```text
Pending
Completed
Failed
Reversed
```

This supports basic transaction tracking.

---

# 37. Account Status

Accounts can be:

```text
Active
Frozen
Closed
```

The transfer procedure only permits active accounts.

---

# 38. Important SQL Commands

### Start

```sql
START TRANSACTION;
```

### Commit

```sql
COMMIT;
```

### Rollback

```sql
ROLLBACK;
```

### Savepoint

```sql
SAVEPOINT savepoint_name;
```

### Partial rollback

```sql
ROLLBACK TO savepoint_name;
```

### Check autocommit

```sql
SELECT @@autocommit;
```

### Disable autocommit

```sql
SET autocommit = 0;
```

### Enable autocommit

```sql
SET autocommit = 1;
```

---

# 39. Key Questions

### What is a transaction?

A logical unit of database operations that should be handled together.

### What does ACID mean?

```text
Atomicity
Consistency
Isolation
Durability
```

### What does COMMIT do?

It successfully completes the current transaction and records its changes.

### What does ROLLBACK do?

It undoes changes made by the current transaction.

### What is SAVEPOINT?

A named point inside a transaction that allows partial rollback.

### Why are transactions important in banking?

Because related operations such as debit and credit must not leave the database partially updated.

### What is autocommit?

A database mode where successful individual statements are generally committed automatically unless controlled by an explicit transaction.

### What does FOR UPDATE do?

It requests locking of selected rows for transactional modification, helping coordinate concurrent updates.

---

# 40. How to Run the Project

## Step 1

Open MySQL Workbench or another MySQL 8+ client.

## Step 2

Open:

```text
day67.sql
```

## Step 3

Execute the script.

The script performs:

```text
1. Database creation
2. Table creation
3. Sample data insertion
4. COMMIT demonstration
5. ROLLBACK demonstration
6. SAVEPOINT demonstration
7. Successful bank transfer
8. Failed transfer
9. Audit logging
10. Autocommit demonstration
11. Stored procedure creation
12. Successful procedure call
13. Failed procedure call
14. Final reports
```

---

# 41. Important Testing Note

The SQL file intentionally includes a failed procedure call:

```sql
CALL transfer_money(1, 6, 1000.00);
```

Account 6 is frozen.

Therefore the procedure is expected to reject the transfer.

The exception handler performs a rollback.

This is intentional and is included to demonstrate transaction failure handling.

---

# 42. Recommended Learning Order

Study the SQL file in this order:

```text
1. Database and table creation
        ↓
2. Sample data
        ↓
3. COMMIT
        ↓
4. ROLLBACK
        ↓
5. SAVEPOINT
        ↓
6. Successful transfer
        ↓
7. Failed transfer
        ↓
8. Audit logging
        ↓
9. Autocommit
        ↓
10. Stored procedure
        ↓
11. Exception handling
        ↓
12. FOR UPDATE
```

---

# 43. Main Learning Outcomes

After completing Day 67, you should be able to:

- Explain what a transaction is.
- Explain ACID properties.
- Start a transaction.
- Commit a transaction.
- Roll back a transaction.
- Create and use savepoints.
- Explain autocommit.
- Implement a multi-step transaction.
- Handle transaction failure.
- Record transaction activity.
- Use a stored procedure for transactional logic.
- Understand basic transactional row locking.
- Explain why transactions are important in real-world systems.

---

# 44. Most Important Takeaways

```text
Transaction
    =
Logical unit of database work
```

```text
Atomicity
    =
All or nothing
```

```text
Consistency
    =
Valid state before and after
```

```text
Isolation
    =
Concurrent transactions should not improperly interfere
```

```text
Durability
    =
Committed changes are preserved according to DB guarantees
```

```text
COMMIT
    =
Complete transaction
```

```text
ROLLBACK
    =
Undo transaction
```

```text
SAVEPOINT
    =
Create a partial rollback point
```

```text
FOR UPDATE
    =
Lock selected rows for transactional modification
```

---

# 45. Day 67 Summary

**Topic:**

```text
SQL Transactions, ACID Properties & Transaction Control
```

**Main SQL concepts:**

```text
START TRANSACTION
COMMIT
ROLLBACK
SAVEPOINT
ROLLBACK TO SAVEPOINT
AUTOCOMMIT
STORED PROCEDURE
SIGNAL
FOR UPDATE
```

**Main theory:**

```text
Atomicity
Consistency
Isolation
Durability
```

**Practical example:**

```text
Bank Transfer
    ↓
Validate
    ↓
Debit Sender
    ↓
Credit Receiver
    ↓
Record Transfer
    ↓
COMMIT
```

If something fails:

```text
Failure
    ↓
ROLLBACK
```

---

# 🚀 Next Natural Topics

After transactions, the next advanced DBMS/SQL topics can build on this foundation:

```text
Concurrency Control
        ↓
Transaction Isolation Levels
        ↓
READ UNCOMMITTED
READ COMMITTED
REPEATABLE READ
SERIALIZABLE
        ↓
Dirty Reads
Non-Repeatable Reads
Phantom Reads
        ↓
Locks
Shared Locks
Exclusive Locks
        ↓
Two-Phase Locking
        ↓
Deadlocks
        ↓
Deadlock Detection and Prevention
```

---

# 📅 SQL-A-Day

## Day 67 Completed ✅

```text
Day 67
SQL Transactions, ACID Properties & Transaction Control
```

The focus of this day is understanding how SQL databases safely handle multiple related operations as a single logical unit of work.