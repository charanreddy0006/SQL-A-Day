# Day 97 — MySQL UUIDs & Binary UUID Storage

**Database:** MySQL 8.0+  
**Script:** `day97.sql`

---

## 1. What is a UUID?

A UUID (Universally Unique Identifier) is a 128-bit identifier designed to identify records across systems without requiring a single central sequence generator.

Example format:

```text
6ccd780c-baba-1026-9564-5b8c656024db
```

UUIDs are useful when multiple services create records independently, when data is synchronized across systems, or when identifiers must be generated outside the database.

A UUID is an identifier, not a password or authorization token.

## 2. UUID vs AUTO_INCREMENT

| Feature | AUTO_INCREMENT | UUID |
|---|---|---|
| Shape | 1, 2, 3, ... | 128-bit identifier |
| Generation | Database sequence | Database or application |
| Multi-system generation | Needs coordination | Designed for decentralized generation |
| Storage | Commonly 4 or 8 bytes | 16 bytes binary; 36 characters as text |
| Index behavior | Usually sequential | Depends on UUID version and ordering |

Neither approach is always best. Choose based on application architecture and workload.

## 3. CHAR(36) storage

```sql
CREATE TABLE customers_char (
    customer_id CHAR(36) PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL
);

INSERT INTO customers_char
VALUES (UUID(), 'Aarav Shah');
```

**Advantages**
- Human-readable in query results.
- Easy to copy, debug, and exchange.

**Disadvantages**
- Stores 36 characters instead of 16 raw bytes.
- Larger UUID columns can increase index storage.

## 4. BINARY(16) storage

```sql
CREATE TABLE customers_binary (
    customer_id BINARY(16) PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL
);

INSERT INTO customers_binary
VALUES (UUID_TO_BIN(UUID(), 1), 'Aarav Shah');
```

`BINARY(16)` stores the 16 UUID bytes directly. It is more compact, but values are not convenient to read without conversion.

## 5. Important MySQL functions

### `UUID()`

Generates a UUID. MySQL's `UUID()` generates a time-based UUID (version 1).

```sql
SELECT UUID();
```

### `UUID_TO_BIN()`

Converts UUID text into a 16-byte binary value.

```sql
SELECT HEX(UUID_TO_BIN('6ccd780c-baba-1026-9564-5b8c656024db'));
```

The optional second argument is a swap flag:

```sql
UUID_TO_BIN(uuid_text, 1)
```

A flag of `1` rearranges time-related fields to improve index locality for UUIDv1 values.

### `BIN_TO_UUID()`

Converts binary UUID data back to readable text.

```sql
SELECT BIN_TO_UUID(binary_uuid, 1);
```

**Always use the same swap flag for encoding and decoding.**

## 6. UUID version and swap flag

- MySQL `UUID()` generates UUIDv1 values; the time-field swap option can be useful for these.
- UUIDv4 values are random. Do not automatically apply the UUIDv1-oriented swap option to UUIDv4.
- For UUIDv4, use the default conversion form consistently: `UUID_TO_BIN(uuid_text)` and `BIN_TO_UUID(binary_uuid)`.

If UUIDs come from an application or another service, agree on the UUID version and byte representation across all components.

## 7. UUIDs as primary and foreign keys

UUIDs can be used in relationships. Both sides of a foreign key should use compatible column types and the same binary representation convention.

```sql
CREATE TABLE app_users (
    user_id BINARY(16) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL
);

CREATE TABLE orders (
    order_id BINARY(16) PRIMARY KEY,
    user_id BINARY(16) NOT NULL,
    order_total DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES app_users(user_id)
);
```

Compare binary IDs directly in joins. Convert only when displaying them:

```sql
SELECT BIN_TO_UUID(o.order_id, 1) AS order_uuid,
       u.full_name, o.order_total
FROM orders o
JOIN app_users u ON u.user_id = o.user_id;
```

## 8. Storage comparison

| Representation | UUID column storage |
|---|---:|
| `CHAR(36)` | 36 characters |
| `BINARY(16)` | 16 bytes |

Actual table and index sizes depend on character set, row format, indexes, and other columns. `BINARY(16)` avoids storing the printable hyphens and text representation.

## 9. Best practices

1. Decide whether the database or application generates UUIDs.
2. Standardize the UUID version and byte-order convention.
3. Use `BINARY(16)` when compact storage is beneficial.
4. Keep primary-key and foreign-key types compatible.
5. Match swap flags on every encode/decode operation.
6. Convert binary UUIDs to text at application or reporting boundaries.
7. Never treat a UUID as a replacement for authorization.

## 10. Common mistakes

- Decoding with a different swap flag than was used during insertion.
- Mixing UUID storage conventions between services.
- Using incompatible types for primary and foreign keys.
- Assuming all UUID versions are time ordered.
- Assuming UUIDs are secret credentials.

## 11. Practice tasks

1. Create a `products` table with a `BINARY(16)` primary key.
2. Insert three products using `UUID_TO_BIN(UUID(), 1)`.
3. Display product IDs using `BIN_TO_UUID(product_id, 1)`.
4. Create a `product_reviews` table with a binary UUID foreign key.
5. Join reviews with product details.
6. Create a second table with `CHAR(36)` and compare `OCTET_LENGTH()`.
7. Explain why the UUIDv1 swap flag should not be blindly applied to UUIDv4.

## 12. Interview questions

**Q1. What is a UUID?**  
A 128-bit identifier designed for unique identification across systems.

**Q2. How many bytes does a UUID contain?**  
16 bytes.

**Q3. Difference between CHAR(36) and BINARY(16)?**  
`CHAR(36)` stores printable UUID text; `BINARY(16)` stores the 16 raw bytes.

**Q4. What does UUID_TO_BIN() do?**  
Converts a UUID string into its binary representation.

**Q5. What does BIN_TO_UUID() do?**  
Converts a binary UUID into readable UUID text.

**Q6. Why does UUID_TO_BIN() have a swap flag?**  
It can reorder time-related UUIDv1 fields to improve index locality.

**Q7. Should swap_flag always be 1?**  
No. Use it only when appropriate for the UUID version and agreed storage convention.

**Q8. Can UUIDs be foreign keys?**  
Yes. The columns must have compatible types and matching binary representation.

## 13. Summary

Today you learned:
- UUID generation with MySQL.
- UUID storage using `CHAR(36)` and `BINARY(16)`.
- `UUID_TO_BIN()` and `BIN_TO_UUID()`.
- UUID primary and foreign keys.
- Why byte-order consistency and UUID version matter.

**Key takeaway:** `BINARY(16)` provides compact UUID storage, but consistent generation and conversion rules are essential.

---

## GitHub commit

```bash
git add .
git commit -m "Day 97 - MySQL UUID and Binary Storage"
git push
```

Keep the streak going — see you on Day 98! 🚀
