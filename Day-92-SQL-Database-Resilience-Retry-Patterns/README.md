# Day 92 — SQL Database Resilience & Retry Patterns

---

## 🎯 Overview

A client can send a database-backed request, the database can successfully commit it, and the network response can still be lost. The client may retry because it cannot tell whether the first request succeeded. Without protection, a payment or order might be processed twice.

This project demonstrates **idempotent request handling** in MySQL using an idempotency key, a unique constraint, a request log, a transaction, and row locking.

**Database:** MySQL 8.0+  
**Project database:** `sql_resilience_lab`  
**Main file:** `day92.sql`

> This is a learning example, not a complete production payment platform. Real systems require concurrency testing, authorization, monitoring, and application-level retry logic.

---

## 📚 Learning Objectives

- Understand why retries happen in distributed applications.
- Explain idempotency and idempotency keys.
- Prevent duplicate payment records with unique constraints.
- Store and replay a request's result.
- Reject reuse of a key with different parameters.
- Use transactions and row locks to protect balances.
- Handle insufficient funds consistently.
- Distinguish retrying one request from creating a new request.

---

## 🧠 Key Concepts

### Why retries can be dangerous

A client submits a payment. The database commits the transfer, but the response is lost. The client retries. Without protection, the transfer could happen twice.

### Idempotency

An operation is idempotent when repeating the same logical request has the same effect as applying it once. In this project, a repeated request with the same key and parameters returns the saved outcome instead of transferring funds again.

### Idempotency key

A stable key identifies one logical request, such as `PAY-REQ-1001`. A unique constraint allows only one request-log entry and one payment record per key.

The procedure calculates a SHA-256 fingerprint from the source account, destination account, and amount. Reusing a key with different parameters is rejected.

### Transactions and row locks

The transfer updates two account balances, inserts a payment, and stores the request result in one transaction. A lock on the source account helps coordinate competing requests so the same available balance is not spent concurrently.

---

## 🗂️ Project Structure

```text
Day-92-SQL-Database-Resilience-Retry-Patterns/
├── day92.sql
└── README.md
```

---

## 🛠️ Run the Project

1. Start MySQL 8.0 or later.
2. Open `day92.sql` in MySQL Workbench or VS Code.
3. Execute the script from top to bottom.
4. Observe the result from the first payment call and the repeated call.
5. Inspect the balances, `payments`, and `payment_request_log` tables.

The script creates sample accounts and a stored procedure called `process_payment_request`.

---

## 1. Submit a Payment

```sql
CALL process_payment_request('PAY-REQ-1001', 1, 2, 100.00);
```

The procedure validates the request, starts a transaction, locks the request key, checks the source balance, transfers the amount, inserts a payment row, saves the response, and commits.

---

## 2. Simulate a Retry

Run the same call again:

```sql
CALL process_payment_request('PAY-REQ-1001', 1, 2, 100.00);
```

The stored outcome is returned instead of performing a second transfer. Verify that account 1 was debited only once and only one payment exists for the key.

---

## 3. Reject Key Reuse with Different Parameters

An idempotency key identifies one logical request. Reusing `PAY-REQ-1001` for a different destination or amount should fail rather than silently treating it as the original request.

The request fingerprint detects this mismatch.

---

## 4. Handle Insufficient Funds

A request that exceeds the available balance receives a stored `FAILED` outcome. Repeating the same key and parameters returns the same outcome. If the customer later adds funds and wants to try again as a new request, application policy may require a new key.

---

## 5. Why Use a Unique Key and a Transaction?

- **Unique key:** prevents duplicate request records.
- **Transaction:** commits related database changes together.
- **Row lock:** coordinates competing operations on account balances.
- **Stored result:** lets retries return a consistent response.

These controls solve different problems. A unique key alone does not make a multi-table transfer atomic.

---

## 🔄 Retry-Safe Request Flow

```text
Client sends request + idempotency key
                 |
                 v
          Validate parameters
                 |
                 v
         Lock / check request key
                 |
          +------+------+
          |             |
     Existing result  New request
          |             |
          v             v
    Return saved     Lock account
       result             |
                          v
                  Check available funds
                          |
                          v
               Update balances + payment
                          |
                          v
                 Save result and COMMIT
```

---

## ⚠️ Production Considerations

1. **Concurrent requests:** test simultaneous calls using the same key.
2. **Lock ordering:** transfers involving multiple accounts should lock rows in a consistent order to reduce deadlocks.
3. **Deadlocks and timeouts:** use bounded retries with backoff and reuse the same idempotency key.
4. **External side effects:** a database transaction cannot undo an email or external API call already sent. Consider an outbox pattern for reliable integrations.
5. **Key retention:** retain idempotency records long enough to cover delayed retries.
6. **Validation and authorization:** validate account access, amount precision, currency, and limits.
7. **Testing:** simulate crashes, response timeouts, concurrent requests, and recovery.

---

## 🧪 Practice Questions

1. Add a maximum transfer amount.
2. Add request timestamp and source application fields.
3. Explain why an idempotency key differs from a payment ID.
4. Test missing source and destination accounts.
5. Explain what should happen if the database commits but the API response times out.
6. Explain why retries should reuse the original key.
7. Describe how deadlocks and lock timeouts should be handled.
8. Explain why external API calls should not happen in the middle of a database transaction.

---

## 🎤 Interview Questions

**1. What is idempotency?**  
Repeating the same logical operation has the same effect as performing it once.

**2. Why use idempotency keys?**  
They allow a system to recognize retries of the same request and avoid duplicate effects.

**3. Why store the response for a request key?**  
A retry can return the original outcome rather than executing the operation again.

**4. Does a unique constraint replace a transaction?**  
No. A unique constraint prevents duplicate values; a transaction coordinates multiple database changes atomically.

**5. Why use row locks for balances?**  
To coordinate concurrent updates and prevent competing operations from spending the same balance.

**6. What if the client times out after commit?**  
The client retries with the same key and receives the stored outcome.

**7. Why use backoff?**  
It spaces retries during transient failures and reduces pressure on an overloaded service.

---

## ✅ Key Takeaways

- Retries are normal in distributed systems, but can cause duplicate side effects.
- Use a stable idempotency key for each logical request.
- Reject a key reused with different parameters.
- Combine unique constraints, transactions, and appropriate locks.
- Store outcomes so retries can return a consistent response.
- Design bounded retries and test concurrency and recovery.
- Treat this lab as a foundation, not a production-ready payment implementation.

---

## 📁 GitHub Commit

```bash
git add .
git commit -m "Day 92 - SQL Database Resilience"
git push
```

**Repository folder:** `Day-92-SQL-Database-Resilience-Retry-Patterns`

Day 92 completed — one more real-world distributed-systems concept added to your SQL-A-Day portfolio! 🚀
