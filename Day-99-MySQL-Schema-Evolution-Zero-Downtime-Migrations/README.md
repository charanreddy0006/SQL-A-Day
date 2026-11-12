# Day 99 — MySQL Schema Evolution & Zero-Downtime Migrations

**Database:** MySQL 8.0+  
**Main script:** `day99.sql`

---

## 1. What is schema evolution?

Database schema evolution is the process of changing a database structure as application requirements change. Examples include adding or removing columns, changing data types, creating relationships, and replacing an old data model with a new one.

A schema change must be coordinated with application code. An application can fail if it expects a column that does not exist, or if a migration removes a column still used by an older application version.

## 2. What is a database migration?

A database migration is a controlled, versioned schema or data change. Examples include:
- Adding a `phone_number` column.
- Splitting `full_name` into `first_name` and `last_name`.
- Replacing `order_amount` with `total_amount`.
- Adding indexes, constraints, or tables.
- Backfilling new fields from existing data.

Migrations should be tested, observable, documented, and repeatable where possible.

## 3. What is zero-downtime migration?

A zero-downtime migration aims to change a database structure without making the application unavailable to users.

It is not achieved simply by writing an `ALTER TABLE`. It depends on application compatibility, MySQL version, table size, DDL algorithm, metadata locks, workload, deployment sequence, and operational safeguards.

The SQL file demonstrates a migration pattern; it does not guarantee zero downtime in production.

## 4. Expand-and-contract strategy

<list connector="solid" marker="number" gap={2}>
  <list-item>**Expand:** Add new columns or tables while keeping the old structure available.</list-item>
  <list-item>**Backfill:** Populate the new structure from existing data, preferably in bounded batches for large tables.</list-item>
  <list-item>**Validate:** Compare old and new values, check NULLs, and verify application behavior.</list-item>
  <list-item>**Switch:** Deploy application code that reads the new structure. Maintain compatibility during rolling deployment.</list-item>
  <list-item>**Contract:** Remove legacy columns only after old code and dependent jobs are retired.</list-item>
</list>

## 5. Practical scenario in this lab

The legacy customer table has a single `full_name` column. The target design stores `first_name` and `last_name` separately. The orders table uses `order_amount`, while the target design introduces `total_amount`.

### Step A — Expand

```sql
ALTER TABLE customers
  ADD COLUMN first_name VARCHAR(60) NULL,
  ADD COLUMN last_name VARCHAR(60) NULL;

ALTER TABLE orders
  ADD COLUMN total_amount DECIMAL(10,2) NULL;
```

The old columns remain so older application versions can continue using them.

### Step B — Backfill

```sql
UPDATE customers
SET first_name = SUBSTRING_INDEX(full_name, ' ', 1),
    last_name = CASE WHEN LOCATE(' ', full_name) > 0
      THEN SUBSTRING(full_name, LOCATE(' ', full_name) + 1)
      ELSE '' END
WHERE first_name IS NULL OR last_name IS NULL;

UPDATE orders
SET total_amount = order_amount
WHERE total_amount IS NULL;
```

This is a one-shot update for a tiny sample dataset. For a large production table, process bounded primary-key ranges, track progress, make the job restartable, and monitor database load and replication lag.

### Step C — Validate

```sql
SELECT COUNT(*) FROM customers
WHERE first_name IS NULL OR last_name IS NULL;

SELECT COUNT(*) FROM orders
WHERE total_amount IS NULL;

SELECT COUNT(*) FROM orders
WHERE total_amount <> order_amount;
```

Expected result in this sample lab: all three counts are zero.

### Step D — Compatibility and dual writes

During a rolling deployment, old instances may still use legacy columns while new instances use the new columns. Keep both representations synchronized until all old versions are retired.

```sql
INSERT INTO customers
  (customer_id, full_name, email, first_name, last_name)
VALUES (4, 'Mira Rao', 'mira@example.com', 'Mira', 'Rao');
```

The application must define which representation is authoritative and how it handles partial write failures. Dual writes are a migration technique, not something to leave in place indefinitely.

### Step E — Switch reads

After validation, new application code can read the new fields:

```sql
SELECT customer_id,
       CONCAT(first_name, ' ', last_name) AS customer_name,
       email
FROM customers;
```

Do not remove old columns while any application version, report, ETL job, or integration still depends on them.

### Step F — Contract

The final destructive statements are commented out in `day99.sql`:

```sql
-- ALTER TABLE customers DROP COLUMN full_name;
-- ALTER TABLE orders DROP COLUMN order_amount;
```

Only execute them after all dependencies are migrated, validation is complete, and the rollback window has closed.

## 6. MySQL DDL and implicit commits

MySQL DDL statements such as `CREATE TABLE`, `ALTER TABLE`, and `DROP TABLE` generally cause implicit commits. Do not assume a sequence of DDL statements can be rolled back like ordinary DML using `ROLLBACK`.

Treat schema changes as separate migration steps. Back up important data and test recovery.

## 7. Metadata locks and online DDL

MySQL uses **metadata locks** to coordinate access to table definitions. A long-running transaction that uses a table can delay DDL requiring a metadata lock. A waiting DDL operation can also affect subsequent queued statements.

DDL algorithm and lock behavior depend on the exact operation, MySQL release, table definition, and storage engine.

Common terms:

| Option | Meaning |
|---|---|
| `ALGORITHM=INSTANT` | Metadata-only change for supported operations |
| `ALGORITHM=INPLACE` | Avoids the traditional table-copy algorithm for supported operations; may still rebuild data or require locks |
| `ALGORITHM=COPY` | Builds a table copy and copies rows; can be expensive |
| `LOCK=NONE` | Requests concurrent reads and writes when supported |

Do not assume every `ALTER TABLE` supports `INSTANT` or `LOCK=NONE`. Check documentation for the exact MySQL version and test on a production-like copy. An explicit algorithm request can fail if unsupported; this may be preferable to unexpectedly accepting a more disruptive algorithm.

Useful commands:

```sql
SHOW CREATE TABLE customers;
SHOW FULL PROCESSLIST;
```

## 8. Backfill strategy for large tables

A large one-shot `UPDATE` can generate substantial undo/redo and binary log volume, hold locks longer, increase replication lag, and affect application latency.

For production:
1. Process bounded batches using an indexed, stable key.
2. Record the last completed key or migration progress.
3. Make the update safe to retry.
4. Monitor latency, lock waits, disk usage, and replication lag.
5. Validate each batch.

## 9. Rollback considerations

Rollback is not always a reverse `ALTER TABLE`.

- Adding a nullable column is often safe to leave in place if application deployment is rolled back.
- Backfilled data may need to be preserved or reconciled.
- Dual-written columns can diverge if one write path fails.
- Dropping a legacy column can destroy data needed by old application code.

Prefer forward-compatible changes, keep a rollback window, and test backups and restoration. Do not rely on an untested reverse migration.

## 10. Migration history

The script creates a small `schema_migrations` table to record example versions. Production migration tools may track applied versions, ordering, checksums, and execution state. Examples include Flyway, Liquibase, and framework-specific migration systems.

## 11. Practice tasks

1. Add a nullable `phone_number` column to customers.
2. Backfill sample values.
3. Write validation queries for missing phone numbers.
4. Demonstrate a compatibility insert writing old and new fields.
5. Design the sequence for safely removing a legacy column.
6. Explain why a one-shot update is risky for a huge table.
7. Investigate which DDL algorithm your MySQL version supports for adding a column.

## 12. Interview questions

**Q1. What is schema evolution?**  
Changing a database structure as application requirements change.

**Q2. What is a database migration?**  
A versioned, controlled schema or data change.

**Q3. What is expand-and-contract?**  
Add the new structure, backfill and validate it, switch application usage, then remove the old structure later.

**Q4. Why retain old columns during a rolling deployment?**  
Older application instances may still depend on them.

**Q5. What is a backfill?**  
Populating newly introduced fields or tables from existing data.

**Q6. What is a metadata lock?**  
A MySQL lock used to coordinate access to table metadata and schema changes.

**Q7. Can every MySQL DDL statement be rolled back?**  
No. Many DDL statements cause implicit commits.

**Q8. Does `ALGORITHM=INPLACE` guarantee no blocking?**  
No. Locking and online behavior depend on the operation and MySQL version.

**Q9. Why delay dropping legacy columns?**  
Old application versions, reports, and integrations may still use them.

**Q10. Does expand-and-contract guarantee zero downtime?**  
No. It is a compatibility strategy; actual availability depends on DDL behavior, deployment, workload, and safeguards.

## 13. Summary

Today you learned:
- Schema evolution and versioned migrations.
- Expand-and-contract migration steps.
- Adding new columns and backfilling data.
- Validation, compatibility, and dual writes.
- MySQL implicit commits and metadata locks.
- Online DDL caveats and rollback planning.

**Key takeaway:** Safe schema evolution is coordinated between database changes and application deployments: add first, backfill and validate, switch usage, and remove old structures only when they are no longer needed.

---

## GitHub commit

```bash
git add .
git commit -m "Day 99 - MySQL Schema Evolution and Zero-Downtime Migrations"
git push
```

Tomorrow is Day 100 — a major milestone in your SQL learning journey! 🎯
