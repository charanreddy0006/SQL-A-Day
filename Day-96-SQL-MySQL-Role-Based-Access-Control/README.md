# Day 96 — MySQL Role-Based Access Control (RBAC)

> **SQL-A-Day | Advanced MySQL | MySQL 8.0+**

## 🎯 Today's Goal

Learn how to control **who can access which database objects and what actions they can perform**.

In a real application, not every database user should be able to read, insert, update, or delete every table. A reporting analyst may need read-only access, a sales application may need to create orders, and an inventory operator may only need to update stock quantities.

MySQL provides users, privileges, and roles to implement this kind of access control.

Today we will explore:

- Database users and privileges.
- Roles as reusable privilege collections.
- `CREATE ROLE` and `GRANT`.
- Assigning roles to users.
- Default roles.
- `REVOKE` and privilege removal.
- Column-level permissions.
- The principle of least privilege.

---

## 1. What Is Access Control?

Access control determines which identities can perform which operations on database resources.

For example:

| Role | Customers | Orders | Products |
|---|---|---|---|
| Read-only analyst | SELECT | SELECT | Catalog view only |
| Sales operator | SELECT | SELECT, INSERT, UPDATE | Catalog view only |
| Inventory operator | No access | No access | SELECT, UPDATE stock column |

The purpose is to give each role only the permissions required for its work.

### Principle of Least Privilege

The **principle of least privilege** means granting a user or role the minimum permissions needed to perform its task.

Avoid granting broad privileges such as `ALL PRIVILEGES` when a smaller set of permissions is sufficient.

---

## 2. Users, Privileges, and Roles

These three concepts are related but different.

### User

A MySQL account represents an identity that can connect to the server.

An account is identified by both user name and host, such as:

```sql
'analyst_demo'@'localhost'
```

### Privilege

A privilege authorizes an action on a database object.

Examples:
- `SELECT`
- `INSERT`
- `UPDATE`
- `DELETE`
- `CREATE`
- `ALTER`
- `EXECUTE`

### Role

A role is a named collection of privileges. Instead of granting the same privileges individually to many accounts, you can grant permissions to a role and assign that role to users.

---

## 3. Project Schema

The SQL script creates the `sql_rbac_lab` database with:

- `customers` — customer details.
- `products` — product information and stock.
- `orders` — customer orders.
- `vw_public_product_catalog` — a view that exposes selected product information.

The view is useful for demonstrating how an application can be granted access to a limited projection of a table rather than the entire table.

### Run the script

1. Use MySQL 8.0 or later.
2. Open `day96.sql` in MySQL Workbench or your SQL editor.
3. Run the database and table setup.
4. Run the role creation and grant statements.
5. Inspect the role privileges using the `SHOW GRANTS` statements.

**Important:** Role creation and privilege changes require an account with suitable administrative privileges. The script comments out optional `CREATE USER` statements so you do not accidentally create accounts with placeholder passwords.

---

## 4. Inspect Existing Privileges

```sql
SHOW PRIVILEGES;
```

This displays privilege types supported by the MySQL server.

To inspect the grants of the account currently connected:

```sql
SHOW GRANTS;
```

To inspect grants for a specific account, use:

```sql
SHOW GRANTS FOR 'some_user'@'localhost';
```

The account must exist, and you need sufficient permission to inspect it.

---

## 5. Create Roles

A role is a named set of privileges.

```sql
CREATE ROLE IF NOT EXISTS
    'rbac_readonly'@'%',
    'rbac_sales'@'%',
    'rbac_inventory'@'%';
```

The three example roles represent:

- `rbac_readonly` — reporting and read-only access.
- `rbac_sales` — access needed by a sales workflow.
- `rbac_inventory` — access needed to inspect and update stock.

The host part is included because MySQL roles use account-style names.

---

## 6. Grant Privileges to Roles

The `GRANT` statement assigns privileges to a user or role.

### Read-only role

```sql
GRANT SELECT ON sql_rbac_lab.customers
    TO 'rbac_readonly'@'%';

GRANT SELECT ON sql_rbac_lab.orders
    TO 'rbac_readonly'@'%';

GRANT SELECT ON sql_rbac_lab.vw_public_product_catalog
    TO 'rbac_readonly'@'%';
```

This role can read the selected tables and view, but it cannot modify them.

### Sales role

```sql
GRANT SELECT, INSERT, UPDATE ON sql_rbac_lab.orders
    TO 'rbac_sales'@'%';
```

The full script also grants the sales role read access to customers and the product catalog view.

### Inventory role

```sql
GRANT SELECT ON sql_rbac_lab.products
    TO 'rbac_inventory'@'%';

GRANT UPDATE (stock_quantity) ON sql_rbac_lab.products
    TO 'rbac_inventory'@'%';
```

The inventory role can read product records and update only the `stock_quantity` column through the column-level grant.

This is more restrictive than granting `UPDATE` on the entire table.

---

## 7. Inspect Role Privileges

Use `SHOW GRANTS` to inspect what each role has received:

```sql
SHOW GRANTS FOR 'rbac_readonly'@'%';
SHOW GRANTS FOR 'rbac_sales'@'%';
SHOW GRANTS FOR 'rbac_inventory'@'%';
```

This is an important verification step. Do not assume a permission was configured correctly just because the `GRANT` statement was executed.

---

## 8. Assign Roles to Users

After creating a MySQL user, assign a role:

```sql
GRANT 'rbac_readonly'@'%'
TO 'analyst_demo'@'localhost';
```

The user receives the privileges associated with that role when the role is active.

The SQL file includes optional `CREATE USER` statements, but they are commented out. If you want to test real accounts, replace the placeholder password with a strong unique secret and run the statements only in your local development environment.

**Never commit real passwords, tokens, or other secrets to GitHub.**

---

## 9. Default Roles

A role can be assigned to a user without necessarily being activated automatically at every new connection.

Use `SET DEFAULT ROLE` to configure which granted role or roles should be active by default:

```sql
SET DEFAULT ROLE 'rbac_readonly'@'%'
TO 'analyst_demo'@'localhost';
```

This is different from assigning the role:

- `GRANT role TO user` assigns the role.
- `SET DEFAULT ROLE` configures the role activation default for that user.

The full SQL script contains optional examples for the three demo accounts.

---

## 10. Revoke Privileges and Roles

Permissions should be removable when responsibilities change.

### Revoke a privilege from a role

```sql
REVOKE UPDATE ON sql_rbac_lab.orders
FROM 'rbac_sales'@'%';
```

### Revoke a role from a user

```sql
REVOKE 'rbac_inventory'@'%'
FROM 'inventory_demo'@'localhost';
```

Revoking a role assignment and revoking a privilege from a role are different operations:

- Revoking a role from a user removes that user's assignment.
- Revoking a privilege from a role changes the permissions of every user who relies on that role.

---

## 11. Column-Level Privileges

Sometimes a user needs to update one column but must not change other columns.

For example:

```sql
GRANT UPDATE (stock_quantity)
ON sql_rbac_lab.products
TO 'rbac_inventory'@'%';
```

This permits updates to `stock_quantity` through that grant, but does not grant permission to change `unit_price` or `product_name`.

Column-level permissions are useful when different teams own different parts of the same table.

Test this using a separate account assigned only the inventory role. Other grants assigned to that account may affect the result, so inspect all its privileges before drawing conclusions.

---

## 12. Example Role Design

| Role | Required access | Avoid granting |
|---|---|---|
| Analyst | SELECT on approved tables/views | INSERT, UPDATE, DELETE |
| Sales | Read customers/catalog; manage orders | Product price updates |
| Inventory | Read products; update stock column | Customer and order access |
| Application admin | Only the operational privileges required by the service | Unrestricted server administration |

A database administrator may need broader permissions, but those should be assigned to a separate, carefully controlled account.

---

## 13. Common Mistakes

- **Granting permissions directly to every user:** reusable roles are easier to manage.
- **Giving `ALL PRIVILEGES` unnecessarily:** follow least privilege.
- **Confusing role assignment with activation:** `GRANT` and `SET DEFAULT ROLE` have different purposes.
- **Forgetting the host part:** MySQL accounts and roles use user/role plus host.
- **Not checking grants:** use `SHOW GRANTS` to verify configuration.
- **Assuming a role is the only source of permissions:** a user may also have direct grants or other roles.
- **Committing passwords to GitHub:** never place real secrets in SQL scripts.
- **Changing shared database permissions without approval:** test access-control changes in a development environment first.

---

## 14. Practice Challenges

1. Create a role named `rbac_reporting`.
2. Grant it `SELECT` access only to `vw_public_product_catalog`.
3. Create a role that can read customers but cannot modify them.
4. Create an inventory role that can update only `stock_quantity`.
5. Assign two roles to a test user.
6. Configure one role as the user's default role.
7. Use `SHOW GRANTS` to inspect the user's permissions.
8. Revoke one role from the test user.
9. Explain why revoking a privilege from a role can affect multiple users.
10. Design a least-privilege role model for an online shopping application.

---

## 15. Interview Questions

**1. What is Role-Based Access Control (RBAC)?**  
An access-control approach in which permissions are grouped into roles and users receive access through those roles.

**2. What is the difference between a user and a role?**  
A user is an account identity; a role is a reusable collection of privileges.

**3. What does `GRANT` do?**  
It assigns privileges or roles to an account or role.

**4. What does `REVOKE` do?**  
It removes previously granted privileges or role assignments.

**5. What is the principle of least privilege?**  
Give each account only the minimum permissions required for its responsibilities.

**6. What is the purpose of `SET DEFAULT ROLE`?**  
It configures which granted roles are activated by default for a user.

**7. What is a column-level privilege?**  
A permission restricted to a specific column, such as allowing updates to stock quantity but not product price.

**8. Why are roles useful?**  
They simplify permission management, improve consistency, and make access policies easier to review.

---

## 16. Summary

Today you learned:

- The difference between users, privileges, and roles.
- How to create roles with `CREATE ROLE`.
- How to assign permissions using `GRANT`.
- How to assign roles to users.
- How default roles work.
- How to remove privileges with `REVOKE`.
- How column-level privileges support least privilege.
- Why access control should be verified with `SHOW GRANTS`.

**Key takeaway:** Good database security is not about giving everyone access. It is about giving every account exactly the access its job requires.

---

## GitHub Progress

```text
Day-96-SQL-MySQL-Role-Based-Access-Control/
├── day96.sql
└── README.md
```

Suggested commit:

```bash
git add .
git commit -m "Day 96 - MySQL Role-Based Access Control"
git push
```

Keep building secure SQL skills one day at a time! 🔐
