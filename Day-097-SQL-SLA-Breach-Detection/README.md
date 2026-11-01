# Day 97 — Detecting SLA Breaches with SQL

> **Project:** SupportPulse — Incident & Support SLA Analytics  
> **SQL dialect:** PostgreSQL 14+  
> **Level:** Intermediate → Advanced  
> **Focus:** CTEs, window functions, conditional aggregation, date/time arithmetic, percentile analysis, and operational metrics.

## The challenge

A SaaS company handles customer support tickets across several priority levels. Each ticket has an SLA target: urgent tickets should be resolved quickly, while low-priority tickets can take longer.

The operations team wants answers to practical questions:

- Which tickets breached their first-response or resolution SLA?
- Which support agents have the highest breach rate?
- Are breaches concentrated in particular priorities or customer plans?
- How long do tickets typically take to receive a first response and reach resolution?
- Which unresolved tickets are closest to breaching their SLA?

This project builds a small, reproducible analytics dataset and answers those questions using SQL—not application code.

## Repository structure

```text
Day-097-SQL-SLA-Breach-Detection/
├── README.md
├── schema.sql
├── sample_data.sql
├── analysis.sql
└── verification.sql
```

## Business rules

All timestamps are stored as `TIMESTAMPTZ`. For this learning project, elapsed time is measured as calendar time (24×7), not business hours.

| Priority | First-response target | Resolution target |
|---|---:|---:|
| Critical | 15 minutes | 4 hours |
| High | 1 hour | 12 hours |
| Medium | 4 hours | 48 hours |
| Low | 8 hours | 120 hours |

A ticket breaches an SLA only when the measured duration is **greater than** its target. A ticket resolved exactly at the target is considered compliant.

- First-response duration = `first_response_at - created_at`
- Resolution duration = `resolved_at - created_at`
- Open tickets have no resolution duration. They are not marked as resolution breaches in historical results; they are monitored separately as at-risk tickets.

## 1. Create the schema

Run `schema.sql` first. It creates three tables:

- `agents` — support team members and their team.
- `customers` — customer account and subscription plan.
- `tickets` — ticket priority, ownership, timestamps, and status.

The schema includes primary keys, foreign keys, `CHECK` constraints, and indexes useful for common analytics filters.

## 2. Load the sample data

Run `sample_data.sql` after creating the schema. The dataset is deliberately small enough to inspect manually, but varied enough to demonstrate:

- compliant and breached tickets;
- tickets without a first response;
- currently open tickets;
- multiple agents, teams, priorities, and customer plans.

The timestamps are fixed examples so that the results remain reproducible.

## 3. Run the analysis

Run `analysis.sql`. It contains six independent analysis sections:

1. **Ticket-level SLA audit** — calculates response and resolution durations and classifies each ticket.
2. **SLA breach summary** — counts breaches and calculates breach percentages by priority.
3. **Agent performance** — compares workload, resolved volume, and breach rate.
4. **Response-time ranking** — uses `DENSE_RANK()` to rank agents within each support team.
5. **Daily operational trend** — tracks ticket volume and resolution breaches by creation date.
6. **Open-ticket risk queue** — estimates time remaining before the first-response and resolution deadlines.

Each section is labelled in the SQL file. Run the entire file or execute sections individually.

## 4. Validate the dataset

Run `verification.sql` to check row counts, foreign-key consistency, timestamp ordering, and the expected presence of both compliant and breached cases.

## Concepts practiced

| SQL concept | Where it appears | Why it matters |
|---|---|---|
| `CASE` | SLA classifications | Convert business rules into categories |
| CTEs | Ticket audit and summaries | Make multi-step analysis readable |
| `LEFT JOIN` | Ticket/customer/agent analysis | Preserve tickets even when optional data is missing |
| Window functions | Agent ranking | Compare rows within a group |
| Conditional aggregation | Breach summaries | Calculate multiple metrics in one pass |
| `FILTER` | PostgreSQL aggregate metrics | Keep conditional counts concise |
| `INTERVAL` arithmetic | SLA deadlines | Work with time-based business rules |
| `NULL` handling | Open tickets | Avoid treating missing timestamps as zero |

## Suggested execution order

```bash
psql -U postgres -d supportpulse -f schema.sql
psql -U postgres -d supportpulse -f sample_data.sql
psql -U postgres -d supportpulse -f analysis.sql
psql -U postgres -d supportpulse -f verification.sql
```

Or paste each file into pgAdmin's Query Tool in the same order.

## Try these extensions

1. Add a `reopened_at` event and calculate the total time a ticket spent in a resolved state.
2. Add a ticket-status history table and calculate time spent in each status.
3. Create a materialized view for the daily SLA dashboard.
4. Compare breach rates across customer plans while guarding against small sample sizes.
5. Rewrite the at-risk queue to use a configurable `as_of_timestamp` instead of `CURRENT_TIMESTAMP`.
6. Extend the model to business-hours SLAs using a calendar table for working days and holidays.

## Important modeling note

This is a compact learning dataset, not a production SLA engine. Real support contracts often pause SLA clocks outside business hours, during customer-waiting states, or on holidays. They may also define separate clocks for acknowledgement, first meaningful response, and final resolution. Those rules require an event-history model and a business calendar.

## Learning outcome

By completing Day 97, you will be able to translate operational service commitments into auditable SQL metrics and build a useful first version of an SLA monitoring report.

---
**Day 97 — SQL-A-Day**  
*Turning support events into measurable service reliability.*
