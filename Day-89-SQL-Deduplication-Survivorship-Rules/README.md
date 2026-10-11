# Day 89 — SQL Deduplication & Survivorship Rules

---

## 🎯 Overview

Customer information can arrive from a CRM, website, mobile app, and spreadsheets. The same person may appear multiple times, with differences in formatting, missing fields, or conflicting values.

This MySQL project demonstrates how to normalize comparison fields, identify duplicate candidates, rank records, select a preferred **survivor**, and prepare merge decisions for review.

**Database:** MySQL 8.0+  
**Project database:** `sql_deduplication_lab`  
**Main file:** `day89.sql`

> All sample records are synthetic. A match is a candidate, not proof that two records represent the same person.

---

## 📚 Learning Objectives

- Normalize email, phone, and name values for comparison.
- Identify exact duplicate candidate groups.
- Rank records with `ROW_NUMBER()`.
- Define survivorship rules using verification, recency, and completeness.
- Detect conflicting attributes.
- Build a survivor-to-duplicate review list.
- Record approved decisions in an audit table.
- Understand why duplicates should not be deleted blindly.

---

## 🧠 Key Concepts

### Deduplication

Deduplication identifies multiple records that may describe the same real-world entity. Duplicate records can inflate customer counts, trigger repeated messages, fragment purchase histories, and produce inconsistent analytics.

### Normalization for matching

The SQL script uses:

- `LOWER(TRIM(email))` to ignore email case and surrounding spaces.
- `REGEXP_REPLACE(phone, '[^0-9]', '')` to remove phone formatting.
- Lowercasing and collapsing repeated spaces in names.

The original values remain unchanged for traceability. Normalization helps matching but cannot prove identity: names can be shared and phone numbers can change or be recycled.

### Survivorship rules

A survivorship rule determines which record or field value is preferred when duplicate candidates disagree.

This project's example ranking uses:
1. Verified records first.
2. Latest source update.
3. Greater completeness.
4. Lowest staging ID as a deterministic tie-breaker.

These are example rules. Real systems should define source priorities and field-level rules based on business needs.

---

## 🗂️ Project Structure

```text
Day-89-SQL-Deduplication-Survivorship-Rules/
├── day89.sql
└── README.md
```

---

## 🛠️ Run the Project

1. Start MySQL 8.0 or later.
2. Open `day89.sql` in MySQL Workbench or VS Code.
3. Execute the script from top to bottom.
4. Inspect duplicate groups, ranked records, conflicts, and review candidates.

The script creates a synthetic staging table and an audit table. It does **not** automatically delete duplicate rows. The sample audit insert is commented out until a decision has been reviewed.

---

## 1. Normalize Before Comparing

```sql
SELECT staging_id,
       LOWER(TRIM(email)) AS normalized_email,
       REGEXP_REPLACE(phone, '[^0-9]', '') AS normalized_phone
FROM customer_staging;
```

This makes formatting differences easier to compare without overwriting source values.

---

## 2. Identify Duplicate Groups

```sql
SELECT LOWER(TRIM(email)) AS normalized_email,
       COUNT(*) AS record_count,
       GROUP_CONCAT(staging_id ORDER BY staging_id) AS staging_ids
FROM customer_staging
WHERE email IS NOT NULL AND TRIM(email) <> ''
GROUP BY LOWER(TRIM(email))
HAVING COUNT(*) > 1;
```

The query returns normalized email groups containing multiple records. Missing emails are excluded because grouping every missing email together could incorrectly treat unrelated people as duplicates.

---

## 3. Rank Candidate Records

The project calculates a completeness score and assigns a rank within each normalized-email group.

```sql
ROW_NUMBER() OVER (
    PARTITION BY LOWER(TRIM(email))
    ORDER BY is_verified DESC,
             last_updated_at DESC,
             staging_id ASC
) AS survivor_rank
```

Rank `1` is the selected survivor under the defined rule. The complete script includes completeness in one ranking example so you can compare policies.

A ranked survivor is not automatically a merged record. Field-level survivorship may choose a verified phone from one row and a more recent address from another.

---

## 4. Find Conflicts and Secondary Matches

The project includes candidate searches by normalized phone and by normalized name plus city. It also checks whether records sharing an email have different phone values.

Treat these as clues for review:
- Two people may share a phone number.
- A name may be common.
- Contact details may be outdated.
- Similar records can still refer to different people.

Fuzzy matching can use edit distance, token similarity, or probabilistic record linkage. Ambiguous or high-impact matches should use suitable confidence thresholds and human review.

---

## 5. Review Before Merging

A safe workflow is:

1. Generate candidate duplicate groups.
2. Apply documented ranking rules.
3. Review conflicting and low-confidence records.
4. Record approved decisions.
5. Update a canonical dataset in a controlled transaction.
6. Preserve source lineage and an audit trail.
7. Validate row counts and business totals after the merge.

The `merge_audit` table records the survivor, candidate duplicate, reason, reviewer, and timestamp. The example insert is commented out intentionally.

---

## 🌍 Real-World Applications

- Master Data Management and customer 360 systems.
- Deduplicating CRM imports and marketing lists.
- Reconciling customer data across web and mobile applications.
- Cleaning supplier, product, and address reference data.
- Preparing trusted dimensions for analytics warehouses.

---

## ⚠️ Common Mistakes

1. Deleting duplicate rows before reviewing candidate groups.
2. Treating a matching name as proof of identity.
3. Grouping all missing email values into one duplicate group.
4. Ignoring conflicting values from different sources.
5. Using recency alone when source reliability matters.
6. Omitting a deterministic tie-breaker.
7. Overwriting raw data and losing lineage.
8. Merging without an audit trail or recovery plan.

---

## 🧪 Practice Questions

1. Add source-system priority to the survivor ranking.
2. Rank by completeness before recency and compare the output.
3. Find duplicate normalized phones where emails differ.
4. Find duplicate-email groups with different cities.
5. Design a canonical customer table with a stable `customer_id`.
6. Explain why missing email values should not be treated as one duplicate group.
7. Describe a safe review-and-merge workflow.
8. Propose field-level survivorship rules for email, phone, and city.

---

## 🎤 Interview Questions

**1. What is deduplication?**  
Identifying multiple records that may represent the same entity and resolving them using documented rules.

**2. What is a survivorship rule?**  
A rule that chooses the preferred record or attribute value when candidate duplicates contain competing values.

**3. Why normalize fields before matching?**  
It removes superficial formatting differences and improves consistency during comparison.

**4. Why use `ROW_NUMBER()`?**  
It ranks records within each group so the preferred candidate can be selected by an explicit ordering.

**5. Is a matching email enough to prove identity?**  
Not always. Addresses can be shared, mistyped, or reassigned.

**6. Why preserve raw records?**  
They support lineage, audit, troubleshooting, and recovery if a match is incorrect.

**7. Record-level vs field-level survivorship?**  
Record-level survivorship chooses a preferred row; field-level survivorship chooses the preferred value for each attribute.

---

## ✅ Key Takeaways

- Normalize comparison fields before matching.
- Use matching rules to generate candidates, not unquestionable identity claims.
- Make survivorship rules explicit and deterministic.
- Review conflicts before merging.
- Preserve source records and audit decisions.
- Never make destructive merges without validation and a recovery plan.

---

## 📁 GitHub Commit

```bash
git add .
git commit -m "Day 89 - SQL Deduplication Survivorship Rules"
git push
```

**Repository folder:** `Day-89-SQL-Deduplication-Survivorship-Rules`

Keep building your SQL-A-Day streak! 🚀
