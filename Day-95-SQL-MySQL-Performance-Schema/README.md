# Day 95 — MySQL Performance Schema: Runtime Diagnostics

> **SQL-A-Day | Advanced MySQL | MySQL 8.0+**

## 🎯 Today's Goal

Learn how to inspect what MySQL is doing while queries and other database operations execute.

So far, performance topics often focus on query structure and execution plans. Today we move to **runtime observability**: collecting evidence about statements, waits, table I/O, file I/O, sessions, and lock waits.

The central tool is MySQL's **Performance Schema**.

It helps answer questions such as:

- Which SQL statement consumed the most total execution time?
- Which normalized query pattern runs most often?
- Which statements examine many rows but return very few?
- Which tables experience the most read or write activity?
- Are sessions waiting on locks?
- What database activity is happening right now?

---

## 1. What Is Performance Schema?

Performance Schema is a MySQL system feature that collects low-level runtime instrumentation about server execution.

It exposes diagnostic information through tables in the `performance_schema` database.

Examples of information it can expose:

- Statement execution events.
- Statement digest summaries.
- Table and index I/O waits.
- File I/O activity.
- Thread and connection details.
- Lock wait information.
- Synchronization waits.

### Performance Schema vs. EXPLAIN

| EXPLAIN | Performance Schema |
|---|---|
| Describes the optimizer's execution plan | Records runtime observations |
| Helps understand how a query is expected to execute | Helps investigate what actually happened |
| Useful before or while tuning a query | Useful for workload diagnosis and monitoring |
| Focuses on plan operators and access paths | Focuses on events, waits, counters and timings |

They complement each other. A plan can look reasonable while runtime measurements reveal an unexpected workload problem.

---

## 2. Project Setup

The SQL file creates a small database named `sql_performance_schema_lab`:

- `customers`
- `orders`
- `order_items`

It then runs sample queries so there is activity to inspect.

**Important:** Performance Schema is a server-level system database. The lab tables are application data; Performance Schema tables contain diagnostic information about the MySQL server.

### Run the script

1. Use MySQL 8.0+.
2. Open `day95.sql` in MySQL Workbench or your SQL editor.
3. Execute the setup and sample workload.
4. Run the diagnostic sections.
5. Compare the output with the explanations below.

Some Performance Schema tables may be empty if the relevant instrumentation or consumers are disabled, if the server has restarted, or if the history has already been overwritten.

---

## 3. Check Whether Performance Schema Is Enabled

```sql
SHOW VARIABLES LIKE 'performance_schema';
```

If the value is `ON`, Performance Schema is available.

If it is `OFF`, enabling it generally requires a server configuration change and restart. It is not simply an ordinary session variable that every user can toggle.

---

## 4. Instruments and Consumers

Performance Schema uses two important concepts.

### Instruments

Instruments define **what activity can be measured**.

Examples include:
- Statement events.
- Wait events.
- Mutex and synchronization activity.
- File I/O operations.

Inspect statement instruments:

```sql
SELECT NAME, ENABLED, TIMED
FROM performance_schema.setup_instruments
WHERE NAME LIKE 'statement/%';
```

### Consumers

Consumers define **where collected events are stored or exposed**.

For example, statement history consumers control whether recent statement events are retained.

```sql
SELECT NAME, ENABLED
FROM performance_schema.setup_consumers;
```

An instrument being enabled does not automatically mean every history table will contain data. The relevant consumer must also be enabled.

### Optional configuration

The SQL file includes commented statements to enable statement history consumers. Changing Performance Schema setup may require privileges and should be done carefully on shared servers.

---

## 5. Statement Event History

When statement instrumentation and history consumers are enabled, MySQL can retain recent statement events.

```sql
SELECT
    EVENT_ID,
    EVENT_NAME,
    SQL_TEXT,
    TIMER_WAIT / 1000000000000 AS elapsed_seconds,
    ROWS_EXAMINED,
    ROWS_SENT,
    MYSQL_ERRNO
FROM performance_schema.events_statements_history
ORDER BY EVENT_ID DESC
LIMIT 20;
```

Useful columns:

| Column | Meaning |
|---|---|
| `EVENT_NAME` | Type of instrumented event |
| `SQL_TEXT` | Captured SQL text, when available |
| `TIMER_WAIT` | Time spent in the event, in picoseconds |
| `ROWS_EXAMINED` | Rows examined by the statement |
| `ROWS_SENT` | Rows returned to the client |
| `MYSQL_ERRNO` | MySQL error number, if applicable |

The script converts picoseconds to seconds by dividing by \(10^{12}\).

### History vs. long history

- `events_statements_history` stores a small per-thread history.
- `events_statements_history_long` stores a larger server-wide history window.

These are bounded histories, not permanent audit logs. Old events can be overwritten.

---

## 6. Statement Digest Summary

A digest groups similar SQL statements into normalized patterns.

For example, statements that differ only in literal values may be grouped under a common digest representation.

```sql
SELECT
    SCHEMA_NAME,
    DIGEST_TEXT,
    COUNT_STAR AS execution_count,
    ROUND(SUM_TIMER_WAIT / 1000000000000, 4) AS total_seconds,
    ROUND(AVG_TIMER_WAIT / 1000000000000, 6) AS average_seconds,
    SUM_ROWS_EXAMINED AS rows_examined,
    SUM_ROWS_SENT AS rows_sent
FROM performance_schema.events_statements_summary_by_digest
WHERE DIGEST_TEXT IS NOT NULL
ORDER BY SUM_TIMER_WAIT DESC
LIMIT 15;
```

This helps find:
- Frequently executed query patterns.
- Patterns with high cumulative execution time.
- Patterns examining many rows.
- Queries with a large gap between rows examined and rows returned.

### Total time vs. average time

- `SUM_TIMER_WAIT` helps identify workload patterns consuming the most cumulative time.
- `AVG_TIMER_WAIT` helps identify patterns that are slow on average.
- `COUNT_STAR` provides execution frequency.

A query that takes 5 ms but runs 100,000 times may matter more than a query that takes 500 ms and runs once.

---

## 7. Find High Row-Examination Workloads

```sql
SELECT
    SCHEMA_NAME,
    DIGEST_TEXT,
    COUNT_STAR,
    SUM_ROWS_EXAMINED,
    SUM_ROWS_SENT
FROM performance_schema.events_statements_summary_by_digest
WHERE DIGEST_TEXT IS NOT NULL
ORDER BY SUM_ROWS_EXAMINED DESC
LIMIT 15;
```

A high `ROWS_EXAMINED` value is a diagnostic clue, not automatic proof of a bad query.

Consider:
- How many rows were expected to match?
- Is the query doing a legitimate broad scan?
- Is the query executed frequently?
- Would a different access path help?
- Does the query need to return so many rows?

Use the query plan and workload context before deciding on a change.

---

## 8. Table I/O Wait Summaries

Performance Schema can summarize I/O activity by table.

```sql
SELECT
    OBJECT_SCHEMA,
    OBJECT_NAME,
    COUNT_READ,
    COUNT_INSERT,
    COUNT_UPDATE,
    COUNT_DELETE
FROM performance_schema.table_io_waits_summary_by_table
WHERE OBJECT_SCHEMA = 'sql_performance_schema_lab';
```

This helps identify tables receiving a large amount of read or write activity.

Remember:
- These are accumulated counters.
- They are not necessarily a measurement of the current query alone.
- They may include activity from multiple connections.
- Summary counters can be reset.

---

## 9. File I/O Summary

The `file_summary_by_instance` table provides file-level I/O statistics.

It can help investigate:
- Files with substantial read activity.
- Files with substantial write activity.
- Byte counts.
- Accumulated wait time.

The SQL file includes a query against this table. It is server-wide diagnostic data, so interpret it in the context of the whole MySQL instance rather than only the lab database.

---

## 10. Session and Thread Monitoring

Performance Schema exposes thread information, including foreground client connections.

```sql
SELECT
    THREAD_ID,
    PROCESSLIST_ID,
    PROCESSLIST_USER,
    PROCESSLIST_HOST,
    PROCESSLIST_DB,
    PROCESSLIST_COMMAND,
    PROCESSLIST_TIME,
    PROCESSLIST_STATE
FROM performance_schema.threads
WHERE TYPE = 'FOREGROUND';
```

This can help investigate:
- Active connections.
- Session state.
- Current database.
- Long-running process-list activity.
- Connections that may need further inspection.

A thread is not necessarily executing a query at every moment; it may be idle or waiting.

---

## 11. Lock Wait Diagnostics

The `data_lock_waits` table exposes relationships between transactions waiting for locks and transactions blocking them.

```sql
SELECT
    REQUESTING_ENGINE_TRANSACTION_ID,
    BLOCKING_ENGINE_TRANSACTION_ID,
    REQUESTING_THREAD_ID,
    BLOCKING_THREAD_ID,
    OBJECT_SCHEMA,
    OBJECT_NAME,
    LOCK_TYPE,
    LOCK_MODE
FROM performance_schema.data_lock_waits;
```

Rows appear when relevant lock waits exist. An empty result means no matching lock waits were present at the time of inspection; it does not mean the server never experiences contention.

Use this information to identify the requesting and blocking transactions, then investigate their sessions and statements.

---

## 12. Resetting Summary Statistics

Some Performance Schema summary tables can be reset with `TRUNCATE TABLE`, subject to privileges.

The SQL file contains commented examples:

```sql
TRUNCATE TABLE performance_schema.events_statements_summary_by_digest;
TRUNCATE TABLE performance_schema.table_io_waits_summary_by_table;
```

This resets selected diagnostic summaries. It does **not** delete application rows from your own tables.

Do not reset shared-server statistics without permission: other developers or monitoring systems may rely on those counters.

---

## 13. Common Mistakes

- **Confusing EXPLAIN with Performance Schema:** one describes a plan; the other records runtime observations.
- **Assuming history is permanent:** history tables retain bounded windows.
- **Ignoring consumers:** instruments and consumers both affect what data is collected and retained.
- **Treating empty results as proof of no activity:** instrumentation may be disabled or history may have been overwritten.
- **Looking only at average time:** execution count and total time matter too.
- **Treating high rows examined as automatic failure:** interpret it against the query's purpose and result size.
- **Resetting shared counters casually:** this affects diagnostics for the whole server.
- **Ignoring privileges:** some diagnostic tables or configuration changes require additional privileges.

---

## 14. Practice Challenges

1. Check whether Performance Schema is enabled on your MySQL server.
2. List all enabled statement instruments.
3. Inspect the enabled consumers.
4. Run a few SELECT statements and inspect recent statement history.
5. Find the digest with the highest total execution time.
6. Find the digest with the highest average execution time.
7. Identify the digest with the highest number of rows examined.
8. Inspect table I/O counters for the lab database.
9. List foreground threads and inspect their states.
10. Explain why `events_statements_history` may return no rows.

---

## 15. Interview Questions

**1. What is MySQL Performance Schema?**  
A MySQL feature that collects runtime instrumentation and exposes diagnostic information through system tables.

**2. What is the difference between an instrument and a consumer?**  
An instrument defines what activity can be measured; a consumer controls where collected event data is stored or exposed.

**3. What is a statement digest?**  
A normalized representation that groups similar SQL statements into a common pattern.

**4. Why inspect both total time and average time?**  
Total time reveals cumulative workload cost, while average time helps identify individually expensive executions.

**5. What is the difference between statement history and digest summary?**  
History contains recent individual statement events; digest summaries aggregate statistics for normalized statement patterns.

**6. Does Performance Schema store a permanent record of every query?**  
No. History is bounded, consumers may be disabled, and some data is aggregated into summaries.

**7. What can `data_lock_waits` help identify?**  
Which transaction is requesting a lock and which transaction is blocking it.

**8. How is Performance Schema different from EXPLAIN?**  
EXPLAIN describes the optimizer's plan; Performance Schema provides runtime observations.

---

## 16. Summary

Today you learned to:
- Understand MySQL Performance Schema and its purpose.
- Distinguish instruments from consumers.
- Inspect statement history and digest summaries.
- Investigate rows examined and rows returned.
- Read table and file I/O summaries.
- Inspect sessions and lock waits.
- Interpret empty results and accumulated counters carefully.

**Key takeaway:** Do not optimize a database based only on assumptions. Use runtime evidence to discover which statements, waits, and resources deserve attention.

---

## GitHub Progress

```text
Day-95-SQL-MySQL-Performance-Schema/
├── day95.sql
└── README.md
```

Suggested commit:

```bash
git add .
git commit -m "Day 95 - MySQL Performance Schema"
git push
```

Keep learning, keep experimenting, and keep building! 🚀
