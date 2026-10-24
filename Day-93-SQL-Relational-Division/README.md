# Day 93 — SQL Relational Division & “For All” Queries

> **SQL-A-Day | Advanced SQL | MySQL 8.0+**

## 🎯 Today's Goal

Learn to solve SQL questions containing **all**, **every**, or **each**:

- Which suppliers provide **all** parts required by a project?
- Which students completed **every** mandatory course?
- Which customers purchased **all** products in a bundle?
- Which employees completed **every** required training module?

This pattern is called **relational division**. SQL does not normally provide a dedicated `DIVIDE` keyword, so we express the logic using patterns such as double `NOT EXISTS` or `GROUP BY ... HAVING`.

---

## 1. The Core Idea

The required parts in this lab are:

| Part ID | Part |
|---:|---|
| 101 | Brake Sensor |
| 102 | Control Unit |
| 103 | Power Module |

A supplier qualifies only if it offers all three parts.

| Supplier | 101 | 102 | 103 | Qualifies? |
|---|---:|---:|---:|---|
| Apex Components | Yes | Yes | Yes | Yes |
| BluePeak Supply | Yes | Yes | No | No |
| CoreWorks | Yes | Yes | Yes | Yes |
| Delta Industrial | Yes | No | Yes | No |

Offering *some* required parts is not enough. Every required item must have a matching supplier-offering row.

---

## 2. Project Schema

The script creates `sql_relational_division_lab` with four tables:

- `suppliers` — supplier details.
- `parts` — all known parts.
- `required_parts` — the current requirement set.
- `supplier_parts` — supplier-to-part relationships, with price and lead time.

The composite primary key `(supplier_id, part_id)` prevents duplicate supplier-part pairs.

### Run it

1. Open MySQL Workbench or your SQL editor.
2. Open `day93.sql`.
3. Run it in a development environment.
4. Inspect each result set and compare the query strategies.

**Caution:** This script recreates tables in its dedicated practice database. Do not run it against production tables.

---

## 3. Method One — Double `NOT EXISTS`

```sql
SELECT s.supplier_id, s.supplier_name
FROM suppliers s
WHERE NOT EXISTS (
  SELECT 1
  FROM required_parts rp
  WHERE NOT EXISTS (
    SELECT 1
    FROM supplier_parts sp
    WHERE sp.supplier_id = s.supplier_id
      AND sp.part_id = rp.part_id
  )
);
```

Read it as:

> There does not exist a required part for which there does not exist a matching supplier offering.

For each supplier:
1. Search for a required part that is missing.
2. If a missing required part exists, reject the supplier.
3. If no required part is missing, keep the supplier.

The nested negative condition is a direct expression of **“the supplier offers every required part.”**

### Why it is useful

- Closely reflects the business rule.
- Does not hard-code the number of required items.
- Continues to work when the required set changes.
- Generalizes to many universal conditions across related tables.

---

## 4. Method Two — `GROUP BY` and `HAVING`

```sql
SELECT s.supplier_id, s.supplier_name
FROM suppliers s
LEFT JOIN supplier_parts sp ON sp.supplier_id = s.supplier_id
LEFT JOIN required_parts rp ON rp.part_id = sp.part_id
GROUP BY s.supplier_id, s.supplier_name
HAVING COUNT(DISTINCT rp.part_id) = (
  SELECT COUNT(*) FROM required_parts
);
```

- `COUNT(DISTINCT rp.part_id)` counts distinct required parts offered by each supplier.
- The subquery counts the complete requirement set.
- `HAVING` keeps suppliers whose coverage count equals the total required count.

The composite primary key prevents duplicate supplier-part pairs; `DISTINCT` additionally protects the count if later joins introduce duplicate rows.

Neither strategy is guaranteed to be fastest for every workload. Compare real execution plans and data volumes when performance matters.

---

## 5. Compare the Patterns

| Pattern | Meaning | Typical use |
|---|---|---|
| Double `NOT EXISTS` | No required item is missing | “Every required item” |
| `GROUP BY ... HAVING` | Matched-item count equals total | Coverage counts and reports |
| `EXISTS` | At least one match exists | “Any” / “at least one” |
| `NOT EXISTS` | No match exists | “None” / “no related item” |

A normal join usually finds matching rows; it does not prove that **all** required rows are present. This is one of the most common mistakes with universal conditions.

---

## 6. “All Required Items” vs “Exactly These Items”

A supplier may provide every required part and also offer extra parts. That is normally fine.

The stricter question is:

> Does this supplier offer every required part **and no part outside the required set**?

It needs two checks:
1. No required part is missing.
2. No offered part is outside the required set.

The SQL script includes both conditions. Keep the concepts separate: **contains every required item** is not the same as **contains exactly the required set**.

---

## 7. The Empty-Set Edge Case

If `required_parts` contains zero rows, the double-`NOT EXISTS` query returns every supplier. In classical logic, “all items in an empty set are supplied” is true because there is no required item that is missing. This is known as **vacuous truth**.

That may or may not be the intended business rule. If a supplier should qualify only when at least one requirement exists, add:

```sql
WHERE EXISTS (SELECT 1 FROM required_parts)
  AND NOT EXISTS (
    SELECT 1
    FROM required_parts rp
    WHERE NOT EXISTS (
      SELECT 1
      FROM supplier_parts sp
      WHERE sp.supplier_id = s.supplier_id
        AND sp.part_id = rp.part_id
    )
  )
```

Always decide explicitly how an empty requirement list should behave.

---

## 8. Practice Challenges

Try these yourself before checking the complete script:

1. Find suppliers that provide every required part with `lead_days <= 4`.
2. Find suppliers that provide every required part with `unit_price < 50`.
3. Find suppliers from India that provide every required part.
4. Change the requirement set to parts `101` and `104`. Which suppliers qualify now?
5. Write the “all required parts” query with double `NOT EXISTS`.
6. Rewrite it using `GROUP BY` and `HAVING`.
7. Find suppliers that offer none of the required parts.
8. Explain the difference between “all required parts” and “exactly the required set.”
9. Explain why an empty requirement set can return every supplier.
10. Adapt the pattern to find students who completed every course in a mandatory-course table.

---

## 9. Real-World Applications

- **Procurement:** Suppliers that can deliver every component in a bill of materials.
- **Education:** Students who completed all mandatory courses.
- **Security:** Users who have all permissions required for a role.
- **E-commerce:** Customers who purchased every product in a bundle.
- **Compliance:** Employees who completed all required training.
- **Data engineering:** Entities with records for every expected period or required attribute.

---

## 10. Common Mistakes

- **Using a normal join for an “all” question:** a match for one item does not prove full coverage.
- **Hard-coding the required count:** compare with the actual requirement set.
- **Ignoring duplicate rows:** use proper keys and, where appropriate, `COUNT(DISTINCT ...)`.
- **Confusing “all” with “exactly”:** extra offerings may be allowed by the first rule.
- **Ignoring empty sets:** decide whether vacuous truth matches the application rule.
- **Assuming one query form is always faster:** validate against real data and execution plans.

---

## 11. Interview Questions

**1. What is relational division?**  
A query pattern that returns entities related to every member of a specified set.

**2. Why use two `NOT EXISTS` clauses?**  
The outer condition rejects a candidate if a required item exists for which no matching relationship exists.

**3. How can relational division be expressed with aggregation?**  
Count the distinct required items matched by each candidate and compare the count with the total number of required items.

**4. How does `EXISTS` differ from relational division?**  
`EXISTS` usually proves at least one matching row exists. Relational division proves that no required row is missing.

**5. What is vacuous truth here?**  
When the requirement set is empty, there is no missing required item, so every candidate satisfies the universal condition unless the query explicitly requires a non-empty set.

**6. Is there a dedicated SQL `DIVIDE` keyword?**  
Not in standard everyday SQL usage; relational division is usually expressed through query patterns such as double `NOT EXISTS` or aggregation.

---

## 12. Summary

Today you learned to:
- Recognize SQL questions containing **all**, **every**, and **each**.
- Express universal conditions with double `NOT EXISTS`.
- Use `GROUP BY` and `HAVING` as an alternative.
- Distinguish “at least one,” “all required,” and “exactly the required set.”
- Handle the empty-set edge case deliberately.

**Key takeaway:** For an “all” requirement, think: **find candidates for whom no required item is missing.**

---

## GitHub Progress

```text
Day-93-SQL-Relational-Division/
├── day93.sql
└── README.md
```

Suggested commit:

```bash
git add .
git commit -m "Day 93 - SQL Relational Division"
git push
```

One useful SQL concept at a time — keep the streak going! 🚀
