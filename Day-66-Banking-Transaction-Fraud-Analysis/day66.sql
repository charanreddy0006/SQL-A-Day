DROP DATABASE IF EXISTS banking_fraud_analysis;
CREATE DATABASE banking_fraud_analysis;
USE banking_fraud_analysis;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_code VARCHAR(20) UNIQUE NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(120) UNIQUE,
    phone VARCHAR(20),
    city VARCHAR(60),
    customer_status ENUM('Active','Inactive','Blocked') DEFAULT 'Active',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE accounts (
    account_id INT PRIMARY KEY AUTO_INCREMENT,
    account_number VARCHAR(30) UNIQUE NOT NULL,
    customer_id INT NOT NULL,
    account_type ENUM('Savings','Current','Salary') NOT NULL,
    balance DECIMAL(15,2) DEFAULT 0,
    account_status ENUM('Active','Inactive','Frozen') DEFAULT 'Active',
    opened_at DATE NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE transaction_categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(50) UNIQUE NOT NULL,
    description VARCHAR(255)
);

CREATE TABLE transactions (
    transaction_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    transaction_reference VARCHAR(40) UNIQUE NOT NULL,
    account_id INT NOT NULL,
    category_id INT NOT NULL,
    transaction_type ENUM('Credit','Debit') NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    transaction_datetime DATETIME NOT NULL,
    merchant_name VARCHAR(120),
    location VARCHAR(100),
    channel ENUM('ATM','POS','Online','Mobile','Branch') NOT NULL,
    transaction_status ENUM('Success','Failed','Pending','Reversed') DEFAULT 'Success',
    FOREIGN KEY (account_id) REFERENCES accounts(account_id),
    FOREIGN KEY (category_id) REFERENCES transaction_categories(category_id),
    CHECK (amount > 0)
);

CREATE TABLE fraud_alerts (
    alert_id INT PRIMARY KEY AUTO_INCREMENT,
    transaction_id BIGINT NOT NULL,
    alert_type VARCHAR(100) NOT NULL,
    risk_score DECIMAL(5,2) NOT NULL,
    alert_status ENUM('Open','Investigating','Confirmed','Dismissed') DEFAULT 'Open',
    detected_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id),
    CHECK (risk_score BETWEEN 0 AND 100)
);

INSERT INTO customers (customer_code,customer_name,email,phone,city,customer_status) VALUES
('CUS001','Arjun Mehta','arjun@example.com','9876500001','Mumbai','Active'),
('CUS002','Priya Sharma','priya@example.com','9876500002','Delhi','Active'),
('CUS003','Rahul Verma','rahul@example.com','9876500003','Bengaluru','Active'),
('CUS004','Sneha Reddy','sneha@example.com','9876500004','Hyderabad','Active'),
('CUS005','Kiran Patel','kiran@example.com','9876500005','Ahmedabad','Active'),
('CUS006','Ananya Rao','ananya@example.com','9876500006','Chennai','Active'),
('CUS007','Vikram Singh','vikram@example.com','9876500007','Pune','Active'),
('CUS008','Neha Kapoor','neha@example.com','9876500008','Jaipur','Blocked');

INSERT INTO accounts (account_number,customer_id,account_type,balance,account_status,opened_at) VALUES
('ACC10001',1,'Savings',125000,'Active','2024-01-15'),
('ACC10002',2,'Savings',85000,'Active','2024-02-10'),
('ACC10003',3,'Current',210000,'Active','2023-11-05'),
('ACC10004',4,'Salary',72000,'Active','2024-03-20'),
('ACC10005',5,'Savings',156000,'Active','2023-08-12'),
('ACC10006',6,'Savings',93000,'Active','2024-04-18'),
('ACC10007',7,'Current',310000,'Active','2023-06-25'),
('ACC10008',8,'Savings',42000,'Frozen','2024-05-11');

INSERT INTO transaction_categories (category_name,description) VALUES
('Salary','Salary or regular income'),('Shopping','Retail and online shopping'),
('Food','Restaurants and food services'),('Utility','Utility payments'),
('Transfer','Account-to-account transfer'),('ATM Withdrawal','Cash withdrawal'),
('Bill Payment','General bill payments'),('Investment','Investment transactions');

INSERT INTO transactions
(transaction_reference,account_id,category_id,transaction_type,amount,transaction_datetime,merchant_name,location,channel,transaction_status) VALUES
('TXN000001',1,1,'Credit',75000,'2026-08-01 09:15:00','ABC Technologies','Mumbai','Online','Success'),
('TXN000002',1,2,'Debit',8500,'2026-08-02 18:30:00','Amazon','Mumbai','Online','Success'),
('TXN000003',1,3,'Debit',1250,'2026-08-03 20:10:00','Food Corner','Mumbai','POS','Success'),
('TXN000004',1,6,'Debit',10000,'2026-08-04 11:20:00','ATM Mumbai Central','Mumbai','ATM','Success'),
('TXN000005',2,1,'Credit',62000,'2026-08-01 10:00:00','XYZ Services','Delhi','Online','Success'),
('TXN000006',2,4,'Debit',4200,'2026-08-02 09:45:00','Power Department','Delhi','Online','Success'),
('TXN000007',2,2,'Debit',15500,'2026-08-05 19:30:00','Electro World','Delhi','POS','Success'),
('TXN000008',3,5,'Credit',95000,'2026-08-01 12:00:00','Business Transfer','Bengaluru','Online','Success'),
('TXN000009',3,5,'Debit',45000,'2026-08-02 14:15:00','Vendor Payment','Bengaluru','Online','Success'),
('TXN000010',3,8,'Debit',30000,'2026-08-04 15:20:00','Investment Platform','Bengaluru','Online','Success'),
('TXN000011',4,1,'Credit',68000,'2026-08-01 09:30:00','Tech Solutions Ltd','Hyderabad','Online','Success'),
('TXN000012',4,3,'Debit',1800,'2026-08-02 21:00:00','Dinner House','Hyderabad','POS','Success'),
('TXN000013',4,2,'Debit',12500,'2026-08-06 17:45:00','Fashion Store','Hyderabad','POS','Success'),
('TXN000014',5,1,'Credit',90000,'2026-08-01 08:45:00','Patel Industries','Ahmedabad','Online','Success'),
('TXN000015',5,2,'Debit',7200,'2026-08-03 16:30:00','Online Market','Ahmedabad','Online','Success'),
('TXN000016',5,7,'Debit',5600,'2026-08-04 13:10:00','Insurance Company','Ahmedabad','Online','Success'),
('TXN000017',6,1,'Credit',55000,'2026-08-01 10:30:00','Global Systems','Chennai','Online','Success'),
('TXN000018',6,3,'Debit',2200,'2026-08-02 20:00:00','Cafe Chennai','Chennai','POS','Success'),
('TXN000019',7,5,'Credit',150000,'2026-08-02 11:00:00','Corporate Transfer','Pune','Online','Success'),
('TXN000020',7,2,'Debit',18500,'2026-08-03 12:20:00','Luxury Store','Pune','POS','Success'),
('TXN000021',7,6,'Debit',25000,'2026-08-03 23:40:00','ATM Pune East','Pune','ATM','Success'),
('TXN000022',8,2,'Debit',45000,'2026-08-05 02:15:00','Unknown Merchant','Kolkata','Online','Success'),
('TXN000023',1,2,'Debit',95000,'2026-08-07 02:30:00','Unknown Merchant','Kolkata','Online','Success'),
('TXN000024',2,2,'Debit',78000,'2026-08-07 02:35:00','Unknown Merchant','Kolkata','Online','Success'),
('TXN000025',3,2,'Debit',110000,'2026-08-07 02:40:00','Unknown Merchant','Kolkata','Online','Success'),
('TXN000026',1,4,'Debit',2300,'2026-08-08 08:00:00','Water Department','Mumbai','Online','Success'),
('TXN000027',2,7,'Debit',4800,'2026-08-08 10:30:00','Insurance Company','Delhi','Online','Pending'),
('TXN000028',3,5,'Debit',35000,'2026-08-08 11:45:00','Vendor Payment','Bengaluru','Online','Success'),
('TXN000029',4,2,'Debit',9000,'2026-08-09 16:00:00','Online Market','Hyderabad','Mobile','Success'),
('TXN000030',7,5,'Debit',120000,'2026-08-09 16:20:00','Large Vendor','Pune','Online','Success');

-- BASIC ANALYSIS
SELECT * FROM customers;
SELECT * FROM accounts WHERE account_status='Active';
SELECT transaction_reference,account_id,amount,transaction_datetime
FROM transactions WHERE amount>50000 ORDER BY amount DESC;

-- CUSTOMER + ACCOUNT ANALYSIS
SELECT c.customer_name,c.city,a.account_number,a.account_type,a.balance
FROM customers c JOIN accounts a ON c.customer_id=a.customer_id
ORDER BY a.balance DESC;

-- TRANSACTION TOTALS
SELECT COUNT(*) total_transactions,SUM(amount) total_value
FROM transactions WHERE transaction_status='Success';

SELECT transaction_type,COUNT(*) transaction_count,SUM(amount) total_amount
FROM transactions WHERE transaction_status='Success'
GROUP BY transaction_type;

SELECT tc.category_name,COUNT(t.transaction_id) transaction_count,
       COALESCE(SUM(t.amount),0) total_amount
FROM transaction_categories tc
LEFT JOIN transactions t ON tc.category_id=t.category_id
AND t.transaction_status='Success'
GROUP BY tc.category_id,tc.category_name ORDER BY total_amount DESC;

-- CUSTOMER SPENDING
SELECT c.customer_name,
       COALESCE(SUM(CASE WHEN t.transaction_type='Debit'
                         AND t.transaction_status='Success' THEN t.amount ELSE 0 END),0) total_spending
FROM customers c JOIN accounts a ON c.customer_id=a.customer_id
LEFT JOIN transactions t ON a.account_id=t.account_id
GROUP BY c.customer_id,c.customer_name ORDER BY total_spending DESC;

-- MONTHLY ANALYSIS
SELECT DATE_FORMAT(transaction_datetime,'%Y-%m') transaction_month,
       COUNT(*) transaction_count,SUM(amount) total_amount
FROM transactions WHERE transaction_status='Success'
GROUP BY DATE_FORMAT(transaction_datetime,'%Y-%m');

-- CASE-BASED RISK CLASSIFICATION
SELECT transaction_reference,amount,transaction_datetime,
CASE WHEN amount>=100000 THEN 'Critical'
     WHEN amount>=50000 THEN 'High'
     WHEN amount>=20000 THEN 'Medium'
     ELSE 'Low' END risk_level
FROM transactions WHERE transaction_status='Success'
ORDER BY amount DESC;

-- NIGHT-TIME TRANSACTIONS
SELECT transaction_reference,account_id,amount,transaction_datetime,location
FROM transactions WHERE transaction_status='Success'
AND (TIME(transaction_datetime)>='23:00:00' OR TIME(transaction_datetime)<'05:00:00');

-- UNUSUAL LOCATION
SELECT t.transaction_reference,c.customer_name,c.city customer_city,
       t.location,t.amount
FROM transactions t JOIN accounts a ON t.account_id=a.account_id
JOIN customers c ON a.customer_id=c.customer_id
WHERE t.transaction_status='Success' AND t.location<>c.city;

-- CTE: CUSTOMER RISK SUMMARY
WITH customer_risk AS (
    SELECT c.customer_id,c.customer_name,
           COUNT(t.transaction_id) transaction_count,
           COALESCE(SUM(CASE WHEN t.transaction_type='Debit'
                             THEN t.amount ELSE 0 END),0) debit_amount
    FROM customers c JOIN accounts a ON c.customer_id=a.customer_id
    LEFT JOIN transactions t ON a.account_id=t.account_id
    AND t.transaction_status='Success'
    GROUP BY c.customer_id,c.customer_name
)
SELECT customer_name,transaction_count,debit_amount,
CASE WHEN debit_amount>=150000 THEN 'High Risk'
     WHEN debit_amount>=75000 THEN 'Medium Risk'
     ELSE 'Low Risk' END customer_risk_level
FROM customer_risk ORDER BY debit_amount DESC;

-- LAG: PREVIOUS TRANSACTION
SELECT transaction_id,account_id,transaction_datetime,amount,
LAG(amount) OVER(PARTITION BY account_id ORDER BY transaction_datetime) previous_amount
FROM transactions WHERE transaction_status='Success'
ORDER BY account_id,transaction_datetime;

-- RUNNING DEBIT TOTAL
SELECT account_id,transaction_datetime,amount,
SUM(CASE WHEN transaction_type='Debit' THEN amount ELSE 0 END)
OVER(PARTITION BY account_id ORDER BY transaction_datetime
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) running_debit_total
FROM transactions WHERE transaction_status='Success';

-- RANK CUSTOMERS BY SPENDING
WITH spending AS (
    SELECT c.customer_id,c.customer_name,
    COALESCE(SUM(CASE WHEN t.transaction_type='Debit'
                      AND t.transaction_status='Success' THEN t.amount ELSE 0 END),0) total_spending
    FROM customers c JOIN accounts a ON c.customer_id=a.customer_id
    LEFT JOIN transactions t ON a.account_id=t.account_id
    GROUP BY c.customer_id,c.customer_name
)
SELECT customer_name,total_spending,
RANK() OVER(ORDER BY total_spending DESC) spending_rank
FROM spending ORDER BY spending_rank;

-- FRAUD RULE 1: HIGH-VALUE NIGHT TRANSACTIONS
INSERT INTO fraud_alerts(transaction_id,alert_type,risk_score,alert_status)
SELECT transaction_id,'High Value Night Transaction',
       LEAST(100,60+(amount/10000)),'Open'
FROM transactions
WHERE transaction_status='Success' AND amount>=50000
AND (TIME(transaction_datetime)>='23:00:00' OR TIME(transaction_datetime)<'05:00:00');

-- FRAUD RULE 2: LARGE DEBITS
INSERT INTO fraud_alerts(transaction_id,alert_type,risk_score,alert_status)
SELECT transaction_id,'Large Debit Transaction',90,'Open'
FROM transactions
WHERE transaction_type='Debit' AND amount>=100000
AND transaction_status='Success';

-- FRAUD ALERT REPORT
SELECT fa.alert_id,t.transaction_reference,c.customer_name,
       fa.alert_type,fa.risk_score,fa.alert_status,fa.detected_at
FROM fraud_alerts fa JOIN transactions t ON fa.transaction_id=t.transaction_id
JOIN accounts a ON t.account_id=a.account_id
JOIN customers c ON a.customer_id=c.customer_id
ORDER BY fa.risk_score DESC;

-- ACCOUNT TRANSACTION SUMMARY
SELECT a.account_number,c.customer_name,COUNT(t.transaction_id) transaction_count,
COALESCE(SUM(CASE WHEN t.transaction_type='Credit' THEN t.amount ELSE 0 END),0) total_credits,
COALESCE(SUM(CASE WHEN t.transaction_type='Debit' THEN t.amount ELSE 0 END),0) total_debits
FROM accounts a JOIN customers c ON a.customer_id=c.customer_id
LEFT JOIN transactions t ON a.account_id=t.account_id AND t.transaction_status='Success'
GROUP BY a.account_id,a.account_number,c.customer_name ORDER BY total_debits DESC;

-- VIEW
CREATE OR REPLACE VIEW transaction_details AS
SELECT t.transaction_id,t.transaction_reference,c.customer_name,c.city customer_city,
       a.account_number,a.account_type,tc.category_name,t.transaction_type,t.amount,
       t.transaction_datetime,t.merchant_name,t.location,t.channel,t.transaction_status
FROM transactions t JOIN accounts a ON t.account_id=a.account_id
JOIN customers c ON a.customer_id=c.customer_id
JOIN transaction_categories tc ON t.category_id=tc.category_id;

SELECT * FROM transaction_details ORDER BY transaction_datetime;

-- INDEXES
CREATE INDEX idx_transactions_account_date ON transactions(account_id,transaction_datetime);
CREATE INDEX idx_transactions_amount ON transactions(amount);
CREATE INDEX idx_transactions_status ON transactions(transaction_status);
CREATE INDEX idx_transactions_location ON transactions(location);
CREATE INDEX idx_fraud_alerts_score ON fraud_alerts(risk_score);

-- FINAL DASHBOARD
SELECT
(SELECT COUNT(*) FROM customers) total_customers,
(SELECT COUNT(*) FROM accounts) total_accounts,
(SELECT COUNT(*) FROM transactions) total_transactions,
(SELECT COUNT(*) FROM transactions WHERE transaction_status='Success') successful_transactions,
(SELECT COALESCE(SUM(amount),0) FROM transactions WHERE transaction_status='Success' AND transaction_type='Credit') total_credits,
(SELECT COALESCE(SUM(amount),0) FROM transactions WHERE transaction_status='Success' AND transaction_type='Debit') total_debits,
(SELECT COUNT(*) FROM fraud_alerts) total_fraud_alerts,
(SELECT COALESCE(MAX(risk_score),0) FROM fraud_alerts) highest_risk_score;