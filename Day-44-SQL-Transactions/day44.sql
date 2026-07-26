-- Day 44 : SQL Transactions

CREATE DATABASE banking_db;

USE banking_db;

--------------------------------------------------
-- Accounts Table
--------------------------------------------------

CREATE TABLE accounts(
    account_id INT PRIMARY KEY,
    account_holder VARCHAR(50),
    balance DECIMAL(10,2)
);

INSERT INTO accounts VALUES
(101,'John',1000.00),
(102,'David',2000.00);

--------------------------------------------------
-- Display Initial Data
--------------------------------------------------

SELECT * FROM accounts;

--------------------------------------------------
-- Example 1 : START TRANSACTION
--------------------------------------------------

START TRANSACTION;

UPDATE accounts
SET balance = balance - 500
WHERE account_id = 101;

UPDATE accounts
SET balance = balance + 500
WHERE account_id = 102;

COMMIT;

--------------------------------------------------
-- Verify Changes
--------------------------------------------------

SELECT * FROM accounts;

--------------------------------------------------
-- Example 2 : ROLLBACK
--------------------------------------------------

START TRANSACTION;

UPDATE accounts
SET balance = balance - 200
WHERE account_id = 101;

ROLLBACK;

--------------------------------------------------
-- Verify Rollback
--------------------------------------------------

SELECT * FROM accounts;

--------------------------------------------------
-- Example 3 : SAVEPOINT
--------------------------------------------------

START TRANSACTION;

UPDATE accounts
SET balance = balance - 100
WHERE account_id = 101;

SAVEPOINT sp1;

UPDATE accounts
SET balance = balance + 100
WHERE account_id = 102;

ROLLBACK TO sp1;

COMMIT;

--------------------------------------------------
-- Final Data
--------------------------------------------------

SELECT * FROM accounts;