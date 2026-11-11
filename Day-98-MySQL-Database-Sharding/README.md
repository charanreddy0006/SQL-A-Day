# Day 98 — MySQL Database Sharding & Distributed Data Architecture

**Database:** MySQL 8.0+  
**Script:** `day98.sql`

---

## 1. What is database sharding?

Database **sharding** is a technique for horizontally distributing rows of a dataset across multiple independent database instances, called *shards*. Each shard stores only part of the complete logical dataset.

For example, a large customer platform can distribute customers across multiple database servers instead of storing every customer on one server.

## 2. Why use sharding?

Sharding may help when one database server becomes a bottleneck due to:
- Very large tables or storage requirements.
- High read and write traffic.
- CPU, memory, or I/O pressure.
- The need to scale data groups independently.

Sharding adds complexity. Query tuning, indexing, caching, or vertical scaling may be simpler first steps. Sharding is not automatically required just because a table is large.

## 3. Horizontal vs. vertical partitioning

| Technique | Meaning | Example |
|---|---|---|
| Horizontal partitioning | Divides rows into groups | Customers 1–1,000,000 and 1,000,001–2,000,000 |
| Vertical partitioning | Separates columns or groups of columns | Customer profile separated from large document data |
| Sharding | Distributes horizontal data groups across independent database nodes | Customer groups on different MySQL servers |

**Important:** MySQL table partitioning and database sharding are different. Table partitioning divides a table within a MySQL server; sharding distributes data across separate database instances or nodes.

## 4. What is a shard key?

A **shard key** is the column or combination of columns used to determine where a record is stored.

Examples include `customer_id`, `tenant_id`, and `region_id`.

A useful shard key should:
1. Distribute records and traffic reasonably evenly.
2. Appear in common query filters.
3. Avoid concentrating activity on one shard.
4. Remain stable, because changing it can require data migration.

A shard receiving disproportionately high traffic is often called a **hot shard**.

## 5. Common sharding strategies

### A. Range-based sharding

Records are assigned using ranges of the shard key.

| Shard | Example range |
|---|---|
| Shard 0 | IDs 1–1,000,000 |
| Shard 1 | IDs 1,000,001–2,000,000 |
| Shard 2 | IDs 2,000,001–3,000,000 |

Benefit: range queries can target relevant shards.  
Risk: newer or more active ranges can become hotspots.

### B. Hash-based sharding

A deterministic hash or mapping function selects the shard. This lab uses a simple modulo example:

```sql
MOD(customer_id, 2)
```

- Result 0 → shard 0
- Result 1 → shard 1

Benefit: can distribute keys evenly when the key and function are suitable.  
Risk: changing the number of shards with simple modulo routing can remap many records.

### C. Directory-based sharding

A lookup service or mapping table stores the relationship between a key or tenant and its assigned shard.

Benefit: placement can be changed without relying only on a fixed formula.  
Risk: the directory must itself be reliable, scalable, and consistent.

## 6. What the SQL lab demonstrates

The script creates four tables in one MySQL database:

- `customers_shard_0`
- `customers_shard_1`
- `orders_shard_0`
- `orders_shard_1`

It routes even customer IDs to shard 0 and odd IDs to shard 1. Each customer's orders are stored in the same simulated shard.

The script demonstrates:
- Creating shard tables.
- Applying a deterministic shard-key rule.
- Inserting rows into the assigned shard.
- Performing a point lookup.
- Combining records using `UNION ALL`.
- Joining customer and order data within each shard.
- Producing global aggregates.
- Validating shard placement and checking duplicate IDs.

**Scope note:** This is a single-server learning simulation using multiple tables. It is not a real distributed deployment. In production, shards are commonly separate database instances or nodes, and an application, proxy, or routing layer directs requests.

## 7. Cross-shard queries

A **cross-shard query** needs data from more than one shard. For example, a global revenue report must combine orders from all shards.

The lab simulates this with:

```sql
SELECT order_id, order_total FROM orders_shard_0
UNION ALL
SELECT order_id, order_total FROM orders_shard_1;
```

In a real multi-server deployment, a routing or query layer may need to:
1. Send requests to relevant shards.
2. Collect partial results.
3. Merge, sort, or aggregate the results.
4. Handle slow or unavailable shards.

Cross-shard joins and transactions are more complex than operations contained within one shard.

## 8. Sharding challenges

| Challenge | Why it matters |
|---|---|
| Hotspots | Some shards receive much more traffic |
| Cross-shard joins | Related rows may live on different servers |
| Rebalancing | Data must move as capacity or placement changes |
| Transactions | Atomic updates across shards are difficult |
| Global uniqueness | IDs must remain unique across shards |
| Operations | Backups, monitoring, failover, and schema changes affect multiple nodes |

## 9. Rebalancing and shard-count changes

With two shards, the example uses:

```sql
MOD(customer_id, 2)
```

Changing the formula to `MOD(customer_id, 3)` for three shards can remap many IDs. Data migration and routing coordination are required.

Production architectures may use consistent hashing, virtual shards, or directory-based placement to make rebalancing more controlled.

## 10. Best practices

1. Measure a real scaling bottleneck before introducing sharding.
2. Choose a stable shard key based on access patterns.
3. Avoid keys that create hot shards.
4. Keep frequently joined records colocated where practical.
5. Plan global ID generation and uniqueness.
6. Design cross-shard reporting explicitly.
7. Monitor per-shard latency, throughput, storage, and errors.
8. Plan backups, recovery, failover, and schema changes across all shards.
9. Prepare a migration and rebalancing strategy.

## 11. Practice tasks

1. Add a third customer shard.
2. Route IDs using `MOD(customer_id, 3)`.
3. Write a global report of customers grouped by city.
4. Find customers who have no orders across either shard.
5. Explain why changing from two to three modulo-based shards moves many records.
6. Propose a shard key for a multi-tenant SaaS platform.
7. Explain how to build a global revenue report from separate database servers.

## 12. Interview questions

**Q1. What is database sharding?**  
Horizontal distribution of a dataset across multiple independent database instances.

**Q2. What is a shard key?**  
The key used to decide which shard stores a record.

**Q3. What is hash-based sharding?**  
A strategy that applies a hash or deterministic mapping function to a shard key to select a shard.

**Q4. How is sharding different from MySQL partitioning?**  
Partitioning divides a table within a database server; sharding distributes data across independent database instances or nodes.

**Q5. What is a hot shard?**  
A shard that receives a disproportionate amount of traffic or data.

**Q6. Why are cross-shard joins difficult?**  
Required rows may reside on different servers, requiring distributed coordination and result merging.

**Q7. What is rebalancing?**  
Redistributing records as shard count, capacity, or workload placement changes.

**Q8. Does sharding always improve performance?**  
No. It can improve scalability for suitable workloads but adds routing, consistency, query, and operational complexity.

## 13. Summary

Today you learned:
- The purpose of database sharding.
- Horizontal vs. vertical partitioning.
- Shard keys and routing.
- Range, hash, and directory-based strategies.
- Cross-shard reporting.
- Hotspots, rebalancing, and operational trade-offs.

**Key takeaway:** Sharding is a scaling architecture, not merely splitting a table. The shard key, routing strategy, and cross-shard query design determine how manageable the system will be.

---

## GitHub commit

```bash
git add .
git commit -m "Day 98 - MySQL Database Sharding"
git push
```

One more day of consistent learning — see you on Day 99! 🚀
