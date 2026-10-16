# Day 91 — SQL Change Data Capture (CDC) & Incremental Loading

---

## 🎯 Overview

Operational databases change constantly. Data warehouses, search indexes, and downstream applications often need those changes without reloading every row. **Change Data Capture (CDC)** captures inserts, updates, and deletes so another system can process only changed records.

This project demonstrates trigger-based CDC in MySQL, a change-log table, incremental extraction, checkpoints, and delete events.

**Database:** MySQL 8.0+  
**Project:** `sql_cdc_lab`  
**Main file:** `day91.sql`

> This is a learning implementation. Production CDC may use transaction logs or managed connectors and needs careful operational design.

---

## 📚 Learning Objectives

- Capture `INSERT`, `UPDATE`, and `DELETE` changes.
- Store old and new values in a change log.
- Understand delete events (tombstones).
- Extract only changes after a saved checkpoint.
- Use a high-water mark to bound a batch.
- Understand retries, idempotency, and safe checkpoint advancement.
- Connect SQL CDC to real data-engineering pipelines.

---

## 🧠 Key Concepts

### What is CDC?

CDC identifies changes made to source data so downstream systems can synchronize incrementally. Common uses include warehouse loading, database synchronization, search-index updates, and streaming analytics.

### Change log

The `customer_changes` table stores a unique `change_id`, affected customer, operation type, timestamp, old/new values, and a demonstration `processed` flag.

### Delete events and tombstones

When a source row is deleted, downstream systems need a signal to remove or deactivate their copy. Otherwise, stale records may remain downstream. The delete trigger records the old values before the source row disappears.

### Checkpoint and high-water mark

A checkpoint records the last change successfully consumed. A high-water mark defines the upper boundary of one batch.

A robust process is:
1. Read the saved checkpoint.
2. Establish a batch upper bound.
3. Extract changes within that range.
4. Apply them downstream.
5. Confirm the downstream operation succeeded.
6. Advance the checkpoint.

Never advance the checkpoint before successful processing, or a failed batch could be skipped.

---

## 🗂️ Project Structure

```text
Day-91-SQL-Change-Data-Capture/
├── day91.sql
└── README.md
```

---

## 🛠️ Run the Project

1. Start MySQL 8.0 or later.
2. Open `day91.sql` in MySQL Workbench or VS Code.
3. Execute the script from top to bottom.
4. Inspect `customer_changes` after the example insert, updates, and delete.

The script creates synthetic customers, three triggers, a change log, a checkpoint table, and a pending-changes view.

---

## 1. Capture Inserts

The `AFTER INSERT` trigger writes a new event with the inserted row's values. A downstream consumer can identify new customers from the log rather than scanning the entire customer table.

## 2. Capture Updates

The `AFTER UPDATE` trigger records both `OLD` and `NEW` values. These help identify what changed, support audits, and update downstream records.

## 3. Capture Deletes

The `AFTER DELETE` trigger records the deleted row's previous values. This event allows a downstream system to remove its corresponding copy.

## 4. Read Pending Changes

`vw_pending_changes` filters events whose `processed` flag is false. This is useful for learning. In systems with multiple consumers, progress is often tracked separately for each consumer rather than with one shared flag.

## 5. Incremental Extraction

The script retrieves the saved checkpoint and an upper bound, then reads events within that range:

```sql
SELECT *
FROM customer_changes
WHERE change_id > last_change_id
  AND change_id <= batch_high_watermark
ORDER BY change_id;
```

The runnable SQL demonstrates this with MySQL session variables. The checkpoint update is commented out deliberately: only advance it after successful downstream processing.

## 6. Latest State and Summaries

Window functions find the latest event per customer and identify customers with multiple changes. The current-state example excludes customers whose latest event is a `DELETE`.

This is a simplified reconstruction. Production pipelines must also account for event ordering, schema evolution, retries, and partial updates.

## 7. Retry Safety and Idempotency

A consumer may apply a batch and fail before updating its checkpoint. It may see the same events again on retry.

To make retries safe:
- Use a stable event identifier such as `change_id`.
- Track which events have been applied.
- Use unique constraints or safe upserts.
- Make downstream writes and checkpoint advancement atomic where possible.
- Design processing so applying an event twice does not corrupt results.

At-least-once delivery can repeat events; idempotent processing makes those repeats safe.

---

## 🔁 Trigger-Based CDC vs Log-Based CDC

**Trigger-based CDC (this lab):**
- Uses SQL triggers and a change table.
- Is approachable for learning and small workflows.
- Adds work to source transactions.
- Requires care around permissions, bulk operations, and trigger maintenance.

**Log-based CDC:**
- Reads changes from database transaction logs or change streams.
- Is commonly used in higher-throughput streaming architectures.
- Requires connector setup, infrastructure, and monitoring.

Choose based on volume, latency, database capabilities, and operational requirements.

---

## 🌍 Typical Data Engineering Flow

```text
Operational database
        ↓
CDC capture
        ↓
Change log / stream
        ↓
Incremental consumer + checkpoint
        ↓
Warehouse / lakehouse / search index
        ↓
Monitoring and reconciliation
```

---

## ⚠️ Common Mistakes

1. Advancing the checkpoint before downstream processing succeeds.
2. Ignoring deletes and leaving stale downstream rows.
3. Assuming each event will be delivered exactly once.
4. Using one processed flag for multiple independent consumers.
5. Capturing unnecessary updates and creating excessive log volume.
6. Assuming an auto-increment ID alone guarantees commit ordering in every concurrent design.
7. Ignoring retries, schema changes, and recovery.
8. Failing to monitor lag and source-to-target consistency.

---

## 🧪 Practice Questions

1. Add a phone field and capture old/new values.
2. Report only changes where the city changed.
3. Explain why delete events are important.
4. Design a retry-safe consumer using `change_id`.
5. Explain why checkpoints must advance only after success.
6. Compare trigger-based and log-based CDC.
7. Explain how separate consumers should track progress.
8. Suggest monitoring metrics for a CDC pipeline.

---

## 🎤 Interview Questions

**1. What is CDC?**  
A technique for identifying and delivering source-data changes to downstream systems incrementally.

**2. What are the basic change operations?**  
Insert, update, and delete.

**3. What is a tombstone?**  
An event indicating that a record was deleted.

**4. What is a checkpoint?**  
A saved position showing how far a consumer has successfully processed a change stream.

**5. Why is idempotency important?**  
It makes repeated processing safe when an event is delivered or retried more than once.

**6. Trigger-based vs log-based CDC?**  
Trigger-based CDC writes changes through database triggers; log-based CDC reads changes from transaction logs or a change stream.

**7. How can a checkpoint cause data loss?**  
If it advances before the downstream write succeeds, the failed batch may be skipped later.

---

## ✅ Key Takeaways

- CDC supports incremental data movement.
- Capture inserts, updates, and deletes explicitly.
- Delete events prevent stale downstream copies.
- Checkpoints track processing progress.
- Design for retries and idempotent processing.
- Trigger-based CDC is useful for learning; production systems may prefer log-based solutions.
- Monitor lag, failures, and source-to-target consistency.

---

## 📁 GitHub Commit

```bash
git add .
git commit -m "Day 91 - SQL Change Data Capture"
git push
```

**Repository folder:** `Day-91-SQL-Change-Data-Capture`

Day 91 completed — a practical data-engineering concept added to your SQL-A-Day portfolio! 🚀
