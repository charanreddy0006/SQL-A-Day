-- Day 92: SQL Database Resilience & Retry Patterns
-- MySQL 8.0+ | Synthetic educational example
CREATE DATABASE IF NOT EXISTS sql_resilience_lab;
USE sql_resilience_lab;

DROP PROCEDURE IF EXISTS process_payment_request;
DROP TABLE IF EXISTS payment_request_log;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS accounts;

CREATE TABLE accounts (
 account_id INT PRIMARY KEY,
 account_name VARCHAR(100) NOT NULL,
 balance DECIMAL(12,2) NOT NULL,
 CHECK (balance >= 0)
);
CREATE TABLE payments (
 payment_id BIGINT AUTO_INCREMENT PRIMARY KEY,
 idempotency_key VARCHAR(100) NOT NULL UNIQUE,
 from_account INT NOT NULL,
 to_account INT NOT NULL,
 amount DECIMAL(12,2) NOT NULL CHECK(amount > 0),
 payment_status ENUM('COMPLETED','FAILED') NOT NULL,
 created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
 FOREIGN KEY(from_account) REFERENCES accounts(account_id),
 FOREIGN KEY(to_account) REFERENCES accounts(account_id)
);
CREATE TABLE payment_request_log (
 idempotency_key VARCHAR(100) PRIMARY KEY,
 request_fingerprint CHAR(64) NOT NULL,
 response_status VARCHAR(30) NOT NULL,
 payment_id BIGINT NULL,
 response_message VARCHAR(255) NOT NULL,
 created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
 FOREIGN KEY(payment_id) REFERENCES payments(payment_id)
);
INSERT INTO accounts VALUES
(1,'Aarav',1000.00),(2,'Diya',500.00),(3,'Kabir',250.00);

DELIMITER //
CREATE PROCEDURE process_payment_request(
 IN p_key VARCHAR(100), IN p_from INT, IN p_to INT, IN p_amount DECIMAL(12,2)
)
proc: BEGIN
 DECLARE v_fingerprint CHAR(64);
 DECLARE v_existing_fingerprint CHAR(64);
 DECLARE v_status VARCHAR(30);
 DECLARE v_payment_id BIGINT;
 DECLARE v_message VARCHAR(255);
 DECLARE v_balance DECIMAL(12,2);
 DECLARE v_destination_count INT;

 DECLARE EXIT HANDLER FOR SQLEXCEPTION
 BEGIN
   ROLLBACK;
   RESIGNAL;
 END;

 IF p_key IS NULL OR TRIM(p_key)='' THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Idempotency key is required';
 END IF;
 IF p_from=p_to THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Source and destination must differ';
 END IF;
 IF p_amount IS NULL OR p_amount<=0 THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Amount must be positive';
 END IF;

 SET v_fingerprint=SHA2(CONCAT(p_from,'|',p_to,'|',CAST(p_amount AS CHAR)),256);
 START TRANSACTION;

 INSERT INTO payment_request_log
   (idempotency_key,request_fingerprint,response_status,payment_id,response_message)
 VALUES(p_key,v_fingerprint,'PROCESSING',NULL,'Request is being processed')
 ON DUPLICATE KEY UPDATE idempotency_key=VALUES(idempotency_key);

 SELECT request_fingerprint,response_status,payment_id,response_message
 INTO v_existing_fingerprint,v_status,v_payment_id,v_message
 FROM payment_request_log WHERE idempotency_key=p_key FOR UPDATE;

 IF v_existing_fingerprint<>v_fingerprint THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Idempotency key reused with different request';
 END IF;

 IF v_status<>'PROCESSING' THEN
   COMMIT;
   SELECT v_status AS response_status,v_payment_id AS payment_id,
          v_message AS response_message,'REPLAYED_EXISTING_RESULT' AS handling;
   LEAVE proc;
 END IF;

 SELECT balance INTO v_balance FROM accounts WHERE account_id=p_from FOR UPDATE;
 IF v_balance IS NULL THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Source account not found';
 END IF;
 SELECT COUNT(*) INTO v_destination_count FROM accounts WHERE account_id=p_to;
 IF v_destination_count=0 THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Destination account not found';
 END IF;

 IF v_balance<p_amount THEN
   UPDATE payment_request_log SET response_status='FAILED',
     response_message='Insufficient funds' WHERE idempotency_key=p_key;
   COMMIT;
   SELECT 'FAILED' AS response_status,NULL AS payment_id,
          'Insufficient funds' AS response_message,'NEW_REQUEST' AS handling;
   LEAVE proc;
 END IF;

 UPDATE accounts SET balance=balance-p_amount WHERE account_id=p_from;
 UPDATE accounts SET balance=balance+p_amount WHERE account_id=p_to;
 INSERT INTO payments(idempotency_key,from_account,to_account,amount,payment_status)
 VALUES(p_key,p_from,p_to,p_amount,'COMPLETED');
 SET v_payment_id=LAST_INSERT_ID();

 UPDATE payment_request_log SET response_status='COMPLETED',
   payment_id=v_payment_id,response_message='Payment completed successfully'
 WHERE idempotency_key=p_key;
 COMMIT;
 SELECT 'COMPLETED' AS response_status,v_payment_id AS payment_id,
        'Payment completed successfully' AS response_message,'NEW_REQUEST' AS handling;
END//
DELIMITER ;

-- 1. Starting balances.
SELECT * FROM accounts ORDER BY account_id;

-- 2. First request: transfers 100 from account 1 to account 2.
CALL process_payment_request('PAY-REQ-1001',1,2,100.00);

-- 3. Simulate client retry after a timeout: should replay result, not transfer again.
CALL process_payment_request('PAY-REQ-1001',1,2,100.00);

-- 4. Reusing the same key with different parameters should be rejected.
-- CALL process_payment_request('PAY-REQ-1001',1,3,200.00);

-- 5. Verify balances and one payment row for the request key.
SELECT * FROM accounts ORDER BY account_id;
SELECT * FROM payments ORDER BY payment_id;
SELECT * FROM payment_request_log ORDER BY created_at;

-- 6. New request with insufficient funds stores a failed outcome.
CALL process_payment_request('PAY-REQ-1002',3,1,9999.00);
SELECT idempotency_key,response_status,payment_id,response_message
FROM payment_request_log ORDER BY created_at;

-- Practice:
-- A. Add a maximum transfer amount.
-- B. Add request timestamp and source application fields.
-- C. Explain why an idempotency key differs from a generated payment_id.
-- D. Test a missing source/destination account.
-- E. Explain what the client should do if the response times out after commit.

-- Optional cleanup:
-- DROP PROCEDURE IF EXISTS process_payment_request;
-- DROP TABLE IF EXISTS payment_request_log;
-- DROP TABLE IF EXISTS payments;
-- DROP TABLE IF EXISTS accounts;
-- DROP DATABASE IF EXISTS sql_resilience_lab;
