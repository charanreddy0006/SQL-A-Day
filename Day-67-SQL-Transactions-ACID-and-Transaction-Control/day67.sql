-- SQL-A-Day Day 67
-- Topic: SQL Transactions, ACID Properties & Transaction Control
-- MySQL 8+

DROP DATABASE IF EXISTS transaction_lab;
CREATE DATABASE transaction_lab;
USE transaction_lab;

CREATE TABLE accounts (
    account_id INT PRIMARY KEY,
    account_number VARCHAR(20) NOT NULL UNIQUE,
    account_holder VARCHAR(100) NOT NULL,
    account_type ENUM('Savings','Current') NOT NULL,
    balance DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    account_status ENUM('Active','Frozen','Closed') DEFAULT 'Active',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CHECK (balance >= 0)
);

CREATE TABLE transfer_log (
    transfer_id INT PRIMARY KEY AUTO_INCREMENT,
    from_account_id INT NOT NULL,
    to_account_id INT NOT NULL,
    transfer_amount DECIMAL(12,2) NOT NULL,
    transfer_status ENUM('Pending','Completed','Failed','Reversed') DEFAULT 'Pending',
    transfer_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    remarks VARCHAR(255),
    FOREIGN KEY (from_account_id) REFERENCES accounts(account_id),
    FOREIGN KEY (to_account_id) REFERENCES accounts(account_id),
    CHECK (transfer_amount > 0),
    CHECK (from_account_id <> to_account_id)
);

CREATE TABLE transaction_audit (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    account_id INT NOT NULL,
    operation_type VARCHAR(50) NOT NULL,
    amount DECIMAL(12,2),
    description VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

INSERT INTO accounts
(account_id, account_number, account_holder, account_type, balance, account_status)
VALUES
(1,'ACC10001','Arjun Mehta','Savings',50000.00,'Active'),
(2,'ACC10002','Priya Sharma','Savings',30000.00,'Active'),
(3,'ACC10003','Rahul Verma','Current',75000.00,'Active'),
(4,'ACC10004','Sneha Reddy','Savings',45000.00,'Active'),
(5,'ACC10005','Kiran Patel','Current',90000.00,'Active'),
(6,'ACC10006','Ananya Rao','Savings',25000.00,'Frozen');

INSERT INTO transfer_log
(from_account_id,to_account_id,transfer_amount,transfer_status,remarks)
VALUES
(1,2,5000.00,'Completed','Initial sample transfer'),
(3,4,7500.00,'Completed','Utility settlement'),
(5,1,10000.00,'Completed','Business payment');

SELECT * FROM accounts;
SELECT * FROM transfer_log;

-- 1. COMMIT: successful transfer
START TRANSACTION;

UPDATE accounts
SET balance = balance - 2000.00
WHERE account_id = 1 AND account_status = 'Active' AND balance >= 2000.00;

UPDATE accounts
SET balance = balance + 2000.00
WHERE account_id = 2 AND account_status = 'Active';

COMMIT;

SELECT * FROM accounts WHERE account_id IN (1,2);

-- 2. ROLLBACK: undo a transaction
START TRANSACTION;

UPDATE accounts
SET balance = balance - 5000.00
WHERE account_id = 3 AND account_status = 'Active' AND balance >= 5000.00;

SELECT * FROM accounts WHERE account_id = 3;

ROLLBACK;

SELECT * FROM accounts WHERE account_id = 3;

-- 3. SAVEPOINT
START TRANSACTION;

UPDATE accounts
SET balance = balance - 3000.00
WHERE account_id = 1 AND account_status = 'Active' AND balance >= 3000.00;

SAVEPOINT after_debit;

UPDATE accounts
SET balance = balance + 3000.00
WHERE account_id = 2 AND account_status = 'Active';

SAVEPOINT after_credit;

UPDATE accounts
SET balance = balance - 1000.00
WHERE account_id = 4 AND account_status = 'Active' AND balance >= 1000.00;

ROLLBACK TO after_credit;
COMMIT;

SELECT * FROM accounts WHERE account_id IN (1,2,4);

-- 4. Successful multi-step bank transfer
START TRANSACTION;

UPDATE accounts
SET balance = balance - 7500.00
WHERE account_id = 3 AND account_status = 'Active' AND balance >= 7500.00;

UPDATE accounts
SET balance = balance + 7500.00
WHERE account_id = 4 AND account_status = 'Active';

INSERT INTO transfer_log
(from_account_id,to_account_id,transfer_amount,transfer_status,remarks)
VALUES
(3,4,7500.00,'Completed','Successful transactional transfer');

COMMIT;

SELECT * FROM accounts WHERE account_id IN (3,4);

-- 5. Failed transfer: frozen receiver
START TRANSACTION;

UPDATE accounts
SET balance = balance - 4000.00
WHERE account_id = 1 AND account_status = 'Active' AND balance >= 4000.00;

UPDATE accounts
SET balance = balance + 4000.00
WHERE account_id = 6 AND account_status = 'Active';

ROLLBACK;

SELECT * FROM accounts WHERE account_id IN (1,6);

-- 6. Audit logging
START TRANSACTION;

UPDATE accounts
SET balance = balance - 2500.00
WHERE account_id = 2 AND account_status = 'Active' AND balance >= 2500.00;

UPDATE accounts
SET balance = balance + 2500.00
WHERE account_id = 5 AND account_status = 'Active';

INSERT INTO transaction_audit
(account_id,operation_type,amount,description)
VALUES
(2,'DEBIT',2500.00,'Transfer to account 5'),
(5,'CREDIT',2500.00,'Transfer received from account 2');

COMMIT;

SELECT * FROM transaction_audit ORDER BY audit_id DESC;

-- 7. AUTOCOMMIT
SELECT @@autocommit AS autocommit_status;

SET autocommit = 0;

UPDATE accounts
SET balance = balance + 1000.00
WHERE account_id = 1;

SELECT * FROM accounts WHERE account_id = 1;

ROLLBACK;

SELECT * FROM accounts WHERE account_id = 1;

SET autocommit = 1;

-- 8. Manual commit with autocommit disabled
SET autocommit = 0;

UPDATE accounts
SET balance = balance + 500.00
WHERE account_id = 2;

COMMIT;

SELECT * FROM accounts WHERE account_id = 2;

SET autocommit = 1;

-- 9. Balance consistency report
SELECT COUNT(*) AS total_accounts, SUM(balance) AS total_balance
FROM accounts
WHERE account_status <> 'Closed';

-- 10. Stored procedure with transaction control
DELIMITER $$

CREATE PROCEDURE transfer_money(
    IN p_from_account INT,
    IN p_to_account INT,
    IN p_amount DECIMAL(12,2)
)
BEGIN
    DECLARE v_sender_balance DECIMAL(12,2);
    DECLARE v_sender_status VARCHAR(20);
    DECLARE v_receiver_status VARCHAR(20);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    SELECT balance, account_status
    INTO v_sender_balance, v_sender_status
    FROM accounts
    WHERE account_id = p_from_account
    FOR UPDATE;

    SELECT account_status
    INTO v_receiver_status
    FROM accounts
    WHERE account_id = p_to_account
    FOR UPDATE;

    IF p_amount <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Transfer amount must be greater than zero';
    END IF;

    IF p_from_account = p_to_account THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Sender and receiver cannot be the same account';
    END IF;

    IF v_sender_status <> 'Active' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Sender account is not active';
    END IF;

    IF v_receiver_status <> 'Active' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Receiver account is not active';
    END IF;

    IF v_sender_balance < p_amount THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient balance';
    END IF;

    UPDATE accounts
    SET balance = balance - p_amount
    WHERE account_id = p_from_account;

    UPDATE accounts
    SET balance = balance + p_amount
    WHERE account_id = p_to_account;

    INSERT INTO transfer_log
    (from_account_id,to_account_id,transfer_amount,transfer_status,remarks)
    VALUES
    (p_from_account,p_to_account,p_amount,'Completed','Procedure-based transfer');

    COMMIT;
END$$

DELIMITER ;

-- Successful procedure call
CALL transfer_money(1,2,1500.00);

SELECT * FROM accounts WHERE account_id IN (1,2);
SELECT * FROM transfer_log ORDER BY transfer_id DESC LIMIT 1;

-- This call intentionally fails because account 6 is Frozen.
-- The procedure rolls back the transaction.
CALL transfer_money(1,6,1000.00);

-- Final account report
SELECT account_id,account_number,account_holder,account_type,balance,account_status
FROM accounts
ORDER BY account_id;

-- Final transfer report
SELECT
    tl.transfer_id,
    sender.account_number AS sender_account,
    sender.account_holder AS sender_name,
    receiver.account_number AS receiver_account,
    receiver.account_holder AS receiver_name,
    tl.transfer_amount,
    tl.transfer_status,
    tl.transfer_time,
    tl.remarks
FROM transfer_log tl
JOIN accounts sender ON tl.from_account_id = sender.account_id
JOIN accounts receiver ON tl.to_account_id = receiver.account_id
ORDER BY tl.transfer_id;

-- Final audit report
SELECT
    ta.audit_id,
    a.account_number,
    a.account_holder,
    ta.operation_type,
    ta.amount,
    ta.description,
    ta.created_at
FROM transaction_audit ta
JOIN accounts a ON ta.account_id = a.account_id
ORDER BY ta.audit_id;