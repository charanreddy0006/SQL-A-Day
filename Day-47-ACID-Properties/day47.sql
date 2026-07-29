-- Day 47 : ACID Properties

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
(102,'Emma',2000.00);

--------------------------------------------------
-- Display Initial Data
--------------------------------------------------

SELECT * FROM accounts;

--------------------------------------------------
-- Example : Money Transfer Transaction
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
-- Verify Transaction
--------------------------------------------------

SELECT * FROM accounts;

--------------------------------------------------
-- Rollback Example
--------------------------------------------------

START TRANSACTION;

UPDATE accounts
SET balance = balance - 300
WHERE account_id = 101;

ROLLBACK;

--------------------------------------------------
-- Verify Rollback
--------------------------------------------------

SELECT * FROM accounts;
