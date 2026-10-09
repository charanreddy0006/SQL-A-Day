# Day 88 — SQL PII Data Masking & Privacy Protection

---

## 🎯 Overview

This project demonstrates practical ways to reduce exposure of personally identifiable information (PII) in MySQL query results. You will mask emails, phone numbers, and identifiers; create a safer reporting view; aggregate data; reduce precision with bands; and inspect access logs.

**Database:** MySQL 8.0+  
**Project:** `sql_pii_privacy_lab`  
**Main SQL file:** `day88.sql`

> All data is fictional. These examples are educational and do not by themselves guarantee security or legal compliance.

---

## 📚 Learning Objectives

- Recognize fields that may contain personal information.
- Mask sensitive values in report outputs.
- Create a view for routine reporting.
- Prefer aggregated results when individual-level data is unnecessary.
- Use age and balance bands instead of exact values.
- Understand data minimization and access auditing.
- Distinguish masking from encryption, anonymization, and authorization.

---

## 🧠 Key Concepts

### Personally Identifiable Information (PII)

Depending on context, fields such as full name, email, phone number, national identifier, and birth date may identify a person or contribute to identification.

### Data masking

Masking changes how a value is displayed. For example:

- `aarav.shah@example.com` → `a***@example.com`
- `+91-9876543210` → `******3210`
- `ABCDE1234F` → `*****234F`

### Masking is not encryption

- **Masking:** hides parts of a value in a result.
- **Encryption:** uses cryptographic techniques and keys to protect data.
- **Anonymization:** aims to prevent linking data back to a person.
- **Authorization:** controls who is allowed to access the data.

The original value remains in the source table. A view does not protect raw columns if a user can query the underlying table directly. Permissions, secure storage, and monitoring remain essential.

---

## 🗂️ Project Structure

```text
Day-88-SQL-PII-Data-Masking/
├── day88.sql
└── README.md
```

---

## 🛠️ Run the Project

1. Start MySQL 8.0 or later.
2. Open `day88.sql` in MySQL Workbench or VS Code with your MySQL connection configured.
3. Execute the script from top to bottom.
4. Inspect the result sets and query `vw_customer_safe`.

The script creates the `sql_pii_privacy_lab` database, synthetic customers, an access log, and a privacy-safer view.

---

## 1. Inspect Potentially Sensitive Columns

The `information_schema.columns` query lists columns and data types for the customer table. Reviewing the data model is a useful first step before preparing a report or export.

---

## 2. Mask Email Addresses

The query retains the first character of the email's local part and the domain, while hiding the rest. It also handles missing values and values without a usable local part.

```sql
SELECT customer_id,
       CONCAT(LEFT(email,1),'***',SUBSTRING(email,LOCATE('@',email)))
         AS masked_email
FROM customers;
```

The project SQL uses a `CASE` expression to handle null, empty, and malformed values more carefully.

---

## 3. Mask Phone Numbers and Identifiers

The phone example keeps only the last four characters. The national identifier example applies a similar approach.

These are display rules, not universal formats. Production policies should consider country codes, identifier length, and the risk of revealing too much.

---

## 4. Build a Privacy-Safer View

`vw_customer_safe` exposes masked name/contact fields and reporting-friendly attributes such as age, city, balance band, marketing consent, and signup date.

```sql
SELECT *
FROM vw_customer_safe;
```

A view centralizes reusable query logic. However, database privileges must be configured so users who should not see raw data cannot bypass the view.

---

## 5. Use Aggregation and Reduced Precision

If a report only needs city-level totals, return counts and averages rather than individual contact information. Age bands and balance bands can also satisfy many reporting needs without exposing exact birth dates or balances.

Aggregation is not automatically anonymous: very small groups and combinations of attributes can still expose identities.

---

## 6. Access Auditing

The `customer_access_log` table records the customer ID, accessor, stated purpose, and timestamp. The SQL demonstrates listing events and reviewing repeated access.

A table alone does not guarantee complete auditing. Production systems need trustworthy logging, protection against tampering, appropriate retention, and careful handling of sensitive details.

---

## 7. Data Minimization

The marketing eligibility query returns only `customer_id`, `city`, and `consent_marketing`. It avoids retrieving names and contact details when those fields are not needed for the decision.

Before writing a query, ask: **What is the minimum data this task needs?**

---

## 🌍 Real-World Applications

- Support dashboards that display partially masked contact details.
- Analytics reports that use aggregate metrics.
- Test environments using synthetic data.
- Exports that need consent status but not full identity.
- Access reviews for customer databases.

Avoid copying real production PII into practice environments without an approved, secure process.

---

## ⚠️ Common Mistakes

1. Treating masking as encryption.
2. Assuming a view automatically blocks access to raw data.
3. Using `SELECT *` on sensitive tables in production.
4. Ignoring null and malformed values.
5. Storing unnecessary sensitive values in logs.
6. Assuming small-group aggregates always protect identity.
7. Using real customer data for learning projects.

---

## 🧪 Practice Questions

1. Show only the domain part of each email.
2. Count customers by city and marketing consent.
3. Create a report using age bands without showing `birth_date`.
4. Find records with missing national IDs without selecting the IDs.
5. Query access events from the last 30 days.
6. Explain why masking does not replace authorization.
7. Compare masking, encryption, anonymization, and authorization.
8. Suggest safe columns for a customer-support dashboard.

---

## 🎤 Interview Questions

**1. What is data masking?**  
Hiding or transforming sensitive values in a displayed result according to a defined rule.

**2. Does masking protect stored data?**  
Not by itself; the original value can remain in the source table.

**3. How does masking differ from encryption?**  
Masking changes presentation, while encryption uses cryptographic methods and keys.

**4. Why use a view?**  
A view offers a reusable projection of safer fields and masked values, but permissions are still necessary.

**5. What is data minimization?**  
Using only the data needed for a specific purpose.

**6. Why keep access logs?**  
They support review and investigation by recording access metadata.

**7. Can aggregated data reveal identities?**  
Yes, particularly for small groups or when several attributes can be combined.

---

## ✅ Key Takeaways

- Identify sensitive columns before building reports.
- Mask contact details when full values are unnecessary.
- Prefer aggregation and reduced precision for analytics.
- Select only the columns a task requires.
- Protect audit logs and configure database permissions.
- Combine SQL techniques with broader security and privacy controls.

---

## 📁 GitHub Commit

```bash
git add .
git commit -m "Day 88 - SQL PII Data Masking"
git push
```

**Repository folder:** `Day-88-SQL-PII-Data-Masking`

Keep building your SQL-A-Day streak! 🚀
