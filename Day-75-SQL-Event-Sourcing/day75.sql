-- ================================================================
-- SQL-A-Day - DAY 75
-- Topic: SQL Event Sourcing & Temporal Data
-- Database: event_sourcing_lab
-- SQL Dialect: MySQL 8+
-- ================================================================

DROP DATABASE IF EXISTS event_sourcing_lab;
CREATE DATABASE event_sourcing_lab;
USE event_sourcing_lab;

-- ================================================================
-- 1. ACCOUNTS
-- Identity/current metadata. Transaction history is stored in
-- account_events and can be replayed to reconstruct state.
-- ================================================================

CREATE TABLE accounts (
    account_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    account_number VARCHAR(30) NOT NULL UNIQUE,
    customer_name VARCHAR(100) NOT NULL,
    account_type ENUM('SAVINGS', 'CURRENT') NOT NULL,
    currency CHAR(3) NOT NULL DEFAULT 'INR',
    status ENUM('ACTIVE', 'FROZEN', 'CLOSED') NOT NULL DEFAULT 'ACTIVE',
    created_at DATETIME NOT NULL
) ENGINE=InnoDB;

-- ================================================================
-- 2. EVENT TYPES
-- ================================================================

CREATE TABLE event_types (
    event_type_code VARCHAR(40) PRIMARY KEY,
    description VARCHAR(255) NOT NULL
) ENGINE=InnoDB;

INSERT INTO event_types (event_type_code, description) VALUES
('ACCOUNT_OPENED', 'Account was opened'),
('DEPOSITED', 'Money was deposited'),
('WITHDRAWN', 'Money was withdrawn'),
('TRANSFER_IN', 'Money was received from another account'),
('TRANSFER_OUT', 'Money was sent to another account'),
('ACCOUNT_FROZEN', 'Account was frozen'),
('ACCOUNT_UNFROZEN', 'Account was unfrozen'),
('ACCOUNT_CLOSED', 'Account was closed');

-- ================================================================
-- 3. ACCOUNT EVENTS
--
-- Event-sourcing principle:
-- Treat historical events as append-only business facts.
--
-- balance_delta:
--   positive -> money added
--   negative -> money removed
--   zero     -> no direct balance change
--
-- sequence_no:
--   event order within one account stream.
-- ================================================================

CREATE TABLE account_events (
    event_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    account_id BIGINT NOT NULL,
    sequence_no INT NOT NULL,
    event_type_code VARCHAR(40) NOT NULL,
    balance_delta DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    event_amount DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    reference_id VARCHAR(100) NULL,
    idempotency_key VARCHAR(100) NULL,
    event_time DATETIME NOT NULL,
    metadata JSON NULL,

    FOREIGN KEY (account_id) REFERENCES accounts(account_id),
    FOREIGN KEY (event_type_code) REFERENCES event_types(event_type_code),

    UNIQUE KEY uq_account_sequence (account_id, sequence_no),
    UNIQUE KEY uq_idempotency_key (idempotency_key),

    INDEX idx_events_account_time (account_id, event_time),
    INDEX idx_events_account_type (account_id, event_type_code),
    INDEX idx_events_reference (reference_id)
) ENGINE=InnoDB;

-- ================================================================
-- 4. ACCOUNTS
-- ================================================================

INSERT INTO accounts
(account_number, customer_name, account_type, currency, status, created_at)
VALUES
('ACC10001', 'Arjun Reddy', 'SAVINGS', 'INR', 'ACTIVE', '2026-01-01 09:00:00'),
('ACC10002', 'Priya Nair', 'SAVINGS', 'INR', 'ACTIVE', '2026-01-03 10:00:00'),
('ACC10003', 'Rahul Sharma', 'CURRENT', 'INR', 'ACTIVE', '2026-01-05 11:00:00'),
('ACC10004', 'Sneha Rao', 'SAVINGS', 'INR', 'ACTIVE', '2026-01-07 12:00:00');

-- ================================================================
-- 5. ACCOUNT 1 EVENT STREAM
-- ================================================================

INSERT INTO account_events
(account_id, sequence_no, event_type_code, balance_delta, event_amount,
 reference_id, idempotency_key, event_time, metadata)
VALUES
(1, 1, 'ACCOUNT_OPENED', 0.00, 0.00,
 NULL, 'ACC1-EVT-001', '2026-01-01 09:00:00',
 JSON_OBJECT('source', 'branch', 'channel', 'WEB')),

(1, 2, 'DEPOSITED', 10000.00, 10000.00,
 'DEP-1001', 'ACC1-EVT-002', '2026-01-02 10:00:00',
 JSON_OBJECT('source', 'bank_transfer')),

(1, 3, 'DEPOSITED', 5000.00, 5000.00,
 'DEP-1002', 'ACC1-EVT-003', '2026-01-05 11:00:00',
 JSON_OBJECT('source', 'UPI')),

(1, 4, 'WITHDRAWN', -2000.00, 2000.00,
 'WD-1001', 'ACC1-EVT-004', '2026-01-08 14:00:00',
 JSON_OBJECT('source', 'ATM', 'location', 'Hyderabad')),

(1, 5, 'TRANSFER_OUT', -3000.00, 3000.00,
 'TX-1001', 'ACC1-EVT-005', '2026-01-12 15:00:00',
 JSON_OBJECT('to_account', 'ACC10002')),

(1, 6, 'DEPOSITED', 8000.00, 8000.00,
 'DEP-1003', 'ACC1-EVT-006', '2026-01-15 10:30:00',
 JSON_OBJECT('source', 'UPI')),

(1, 7, 'WITHDRAWN', -1500.00, 1500.00,
 'WD-1002', 'ACC1-EVT-007', '2026-01-20 16:00:00',
 JSON_OBJECT('source', 'ATM', 'location', 'Secunderabad'));

-- ================================================================
-- 6. ACCOUNT 2 EVENT STREAM
-- ================================================================

INSERT INTO account_events
(account_id, sequence_no, event_type_code, balance_delta, event_amount,
 reference_id, idempotency_key, event_time, metadata)
VALUES
(2, 1, 'ACCOUNT_OPENED', 0.00, 0.00,
 NULL, 'ACC2-EVT-001', '2026-01-03 10:00:00',
 JSON_OBJECT('source', 'branch')),

(2, 2, 'DEPOSITED', 7000.00, 7000.00,
 'DEP-2001', 'ACC2-EVT-002', '2026-01-04 09:30:00',
 JSON_OBJECT('source', 'UPI')),

(2, 3, 'TRANSFER_IN', 3000.00, 3000.00,
 'TX-1001', 'ACC2-EVT-003', '2026-01-12 15:00:00',
 JSON_OBJECT('from_account', 'ACC10001')),

(2, 4, 'WITHDRAWN', -1000.00, 1000.00,
 'WD-2001', 'ACC2-EVT-004', '2026-01-18 13:00:00',
 JSON_OBJECT('source', 'ATM'));

-- ================================================================
-- 7. ACCOUNT 3 EVENT STREAM
-- ================================================================

INSERT INTO account_events
(account_id, sequence_no, event_type_code, balance_delta, event_amount,
 reference_id, idempotency_key, event_time, metadata)
VALUES
(3, 1, 'ACCOUNT_OPENED', 0.00, 0.00,
 NULL, 'ACC3-EVT-001', '2026-01-05 11:00:00',
 JSON_OBJECT('source', 'WEB')),

(3, 2, 'DEPOSITED', 50000.00, 50000.00,
 'DEP-3001', 'ACC3-EVT-002', '2026-01-06 12:00:00',
 JSON_OBJECT('source', 'bank_transfer')),

(3, 3, 'WITHDRAWN', -10000.00, 10000.00,
 'WD-3001', 'ACC3-EVT-003', '2026-01-10 17:00:00',
 JSON_OBJECT('source', 'ATM')),

(3, 4, 'TRANSFER_OUT', -15000.00, 15000.00,
 'TX-3001', 'ACC3-EVT-004', '2026-01-20 10:00:00',
 JSON_OBJECT('to_account', 'ACC10004'));

-- ================================================================
-- 8. ACCOUNT 4 EVENT STREAM
-- ================================================================

INSERT INTO account_events
(account_id, sequence_no, event_type_code, balance_delta, event_amount,
 reference_id, idempotency_key, event_time, metadata)
VALUES
(4, 1, 'ACCOUNT_OPENED', 0.00, 0.00,
 NULL, 'ACC4-EVT-001', '2026-01-07 12:00:00',
 JSON_OBJECT('source', 'WEB')),

(4, 2, 'DEPOSITED', 20000.00, 20000.00,
 'DEP-4001', 'ACC4-EVT-002', '2026-01-08 10:00:00',
 JSON_OBJECT('source', 'bank_transfer')),

(4, 3, 'TRANSFER_IN', 15000.00, 15000.00,
 'TX-3001', 'ACC4-EVT-003', '2026-01-20 10:00:00',
 JSON_OBJECT('from_account', 'ACC10003'));

-- ================================================================
-- 9. EVENT STREAM VIEW
-- ================================================================

CREATE VIEW v_account_event_stream AS
SELECT
    e.event_id,
    e.account_id,
    a.account_number,
    a.customer_name,
    e.sequence_no,
    e.event_type_code,
    et.description AS event_description,
    e.event_amount,
    e.balance_delta,
    e.reference_id,
    e.event_time,
    e.metadata
FROM account_events e
JOIN accounts a
    ON a.account_id = e.account_id
JOIN event_types et
    ON et.event_type_code = e.event_type_code;

-- ================================================================
-- 10. VIEW ALL EVENTS
-- ================================================================

SELECT *
FROM v_account_event_stream
ORDER BY account_id, sequence_no;

-- ================================================================
-- 11. CURRENT BALANCE RECONSTRUCTION
-- ================================================================

SELECT
    a.account_id,
    a.account_number,
    a.customer_name,
    COALESCE(SUM(e.balance_delta), 0.00) AS reconstructed_balance
FROM accounts a
LEFT JOIN account_events e
    ON e.account_id = a.account_id
GROUP BY
    a.account_id,
    a.account_number,
    a.customer_name
ORDER BY a.account_id;

-- ================================================================
-- 12. RUNNING BALANCE AFTER EVERY EVENT
-- ================================================================

SELECT
    account_id,
    sequence_no,
    event_type_code,
    event_time,
    balance_delta,
    SUM(balance_delta) OVER (
        PARTITION BY account_id
        ORDER BY sequence_no
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS balance_after_event
FROM account_events
ORDER BY account_id, sequence_no;

-- ================================================================
-- 13. COMPLETE REPLAY OF ACCOUNT 1
-- ================================================================

SELECT
    sequence_no,
    event_type_code,
    event_time,
    balance_delta,
    SUM(balance_delta) OVER (
        PARTITION BY account_id
        ORDER BY sequence_no
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS balance_after_event
FROM account_events
WHERE account_id = 1
ORDER BY sequence_no;

-- ================================================================
-- 14. POINT-IN-TIME BALANCE
-- Account 1 at 2026-01-12 16:00:00
-- ================================================================

SELECT
    account_id,
    COALESCE(SUM(balance_delta), 0.00) AS balance_at_time
FROM account_events
WHERE account_id = 1
  AND event_time <= '2026-01-12 16:00:00'
GROUP BY account_id;

-- ================================================================
-- 15. POINT-IN-TIME BALANCE FOR ALL ACCOUNTS
-- ================================================================

SELECT
    a.account_id,
    a.account_number,
    a.customer_name,
    COALESCE(SUM(
        CASE
            WHEN e.event_time <= '2026-01-15 23:59:59'
            THEN e.balance_delta
            ELSE 0
        END
    ), 0.00) AS balance_at_cutoff
FROM accounts a
LEFT JOIN account_events e
    ON e.account_id = a.account_id
GROUP BY
    a.account_id,
    a.account_number,
    a.customer_name
ORDER BY a.account_id;

-- ================================================================
-- 16. FIRST EVENT PER ACCOUNT
-- ================================================================

SELECT
    account_id,
    event_id,
    sequence_no,
    event_type_code,
    event_time
FROM account_events
WHERE sequence_no = 1
ORDER BY account_id;

-- ================================================================
-- 17. LATEST EVENT PER ACCOUNT
-- ================================================================

SELECT
    e.account_id,
    e.event_id,
    e.sequence_no,
    e.event_type_code,
    e.event_time
FROM account_events e
WHERE e.sequence_no = (
    SELECT MAX(e2.sequence_no)
    FROM account_events e2
    WHERE e2.account_id = e.account_id
)
ORDER BY e.account_id;

-- ================================================================
-- 18. EVENT COUNT PER ACCOUNT
-- ================================================================

SELECT
    a.account_number,
    a.customer_name,
    COUNT(e.event_id) AS event_count
FROM accounts a
LEFT JOIN account_events e
    ON e.account_id = a.account_id
GROUP BY
    a.account_id,
    a.account_number,
    a.customer_name
ORDER BY event_count DESC;

-- ================================================================
-- 19. INFLOW / OUTFLOW SUMMARY
-- ================================================================

SELECT
    account_id,
    SUM(CASE WHEN balance_delta > 0 THEN balance_delta ELSE 0 END)
        AS total_inflow,
    SUM(CASE WHEN balance_delta < 0 THEN ABS(balance_delta) ELSE 0 END)
        AS total_outflow,
    SUM(balance_delta) AS net_change
FROM account_events
GROUP BY account_id
ORDER BY account_id;

-- ================================================================
-- 20. PREVIOUS EVENT USING LAG()
-- ================================================================

SELECT
    account_id,
    sequence_no,
    event_type_code,
    event_time,
    balance_delta,
    LAG(event_type_code) OVER (
        PARTITION BY account_id
        ORDER BY sequence_no
    ) AS previous_event_type
FROM account_events
ORDER BY account_id, sequence_no;

-- ================================================================
-- 21. TIME GAP BETWEEN EVENTS
-- ================================================================

SELECT
    account_id,
    sequence_no,
    event_type_code,
    event_time,
    LAG(event_time) OVER (
        PARTITION BY account_id
        ORDER BY sequence_no
    ) AS previous_event_time,
    TIMESTAMPDIFF(
        HOUR,
        LAG(event_time) OVER (
            PARTITION BY account_id
            ORDER BY sequence_no
        ),
        event_time
    ) AS hours_since_previous_event
FROM account_events
ORDER BY account_id, sequence_no;

-- ================================================================
-- 22. FIRST TIME BALANCE EXCEEDED 20,000
-- ================================================================

WITH replay AS (
    SELECT
        account_id,
        sequence_no,
        event_time,
        SUM(balance_delta) OVER (
            PARTITION BY account_id
            ORDER BY sequence_no
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS running_balance
    FROM account_events
),
first_crossing AS (
    SELECT
        account_id,
        MIN(sequence_no) AS first_sequence
    FROM replay
    WHERE running_balance > 20000
    GROUP BY account_id
)
SELECT
    r.account_id,
    r.sequence_no,
    r.event_time,
    r.running_balance
FROM replay r
JOIN first_crossing f
    ON f.account_id = r.account_id
   AND f.first_sequence = r.sequence_no
ORDER BY r.account_id;

-- ================================================================
-- 23. EVENTS THAT CHANGED BALANCE
-- ================================================================

SELECT
    event_id,
    account_id,
    sequence_no,
    event_type_code,
    balance_delta,
    event_time
FROM account_events
WHERE balance_delta <> 0
ORDER BY account_id, sequence_no;

-- ================================================================
-- 24. MATCH TRANSFER_OUT WITH TRANSFER_IN
-- ================================================================

SELECT
    e1.reference_id AS transfer_reference,
    e1.account_id AS sender_account_id,
    e1.event_amount AS transfer_amount,
    e2.account_id AS receiver_account_id,
    e1.event_time
FROM account_events e1
JOIN account_events e2
    ON e2.reference_id = e1.reference_id
   AND e2.event_type_code = 'TRANSFER_IN'
WHERE e1.event_type_code = 'TRANSFER_OUT'
ORDER BY e1.event_time;

-- ================================================================
-- 25. READ JSON METADATA
-- ================================================================

SELECT
    event_id,
    account_id,
    event_type_code,
    metadata,
    JSON_UNQUOTE(JSON_EXTRACT(metadata, '$.source')) AS event_source
FROM account_events
ORDER BY event_id;

-- ================================================================
-- 26. FIND ATM EVENTS FROM JSON
-- ================================================================

SELECT
    event_id,
    account_id,
    event_type_code,
    event_amount,
    JSON_UNQUOTE(JSON_EXTRACT(metadata, '$.location')) AS atm_location
FROM account_events
WHERE JSON_UNQUOTE(JSON_EXTRACT(metadata, '$.source')) = 'ATM';

-- ================================================================
-- 27. IDEMPOTENCY CHECK
-- ================================================================

SELECT
    idempotency_key,
    COUNT(*) AS occurrences
FROM account_events
GROUP BY idempotency_key
HAVING COUNT(*) > 1;

-- ================================================================
-- 28. EVENT SEQUENCE VALIDATION
-- Detect sequence gaps inside an account stream.
-- ================================================================

WITH numbered AS (
    SELECT
        account_id,
        sequence_no,
        LAG(sequence_no) OVER (
            PARTITION BY account_id
            ORDER BY sequence_no
        ) AS previous_sequence
    FROM account_events
)
SELECT
    account_id,
    previous_sequence,
    sequence_no,
    sequence_no - previous_sequence AS sequence_gap
FROM numbered
WHERE previous_sequence IS NOT NULL
  AND sequence_no <> previous_sequence + 1;

-- ================================================================
-- 29. REPLAY ACCOUNT 1 UP TO EVENT 5
-- ================================================================

SELECT
    account_id,
    MAX(sequence_no) AS replay_until_sequence,
    SUM(balance_delta) AS reconstructed_balance
FROM account_events
WHERE account_id = 1
  AND sequence_no <= 5
GROUP BY account_id;

-- ================================================================
-- 30. REPLAY EVERY ACCOUNT TO CURRENT STATE
-- ================================================================

SELECT
    account_id,
    MAX(sequence_no) AS last_sequence,
    SUM(balance_delta) AS current_reconstructed_balance
FROM account_events
GROUP BY account_id
ORDER BY account_id;

-- ================================================================
-- 31. ACCOUNT AUDIT TRAIL
-- ================================================================

SELECT
    a.account_number,
    a.customer_name,
    e.sequence_no,
    e.event_type_code,
    e.event_amount,
    e.balance_delta,
    e.reference_id,
    e.event_time
FROM accounts a
JOIN account_events e
    ON e.account_id = a.account_id
WHERE a.account_id = 1
ORDER BY e.sequence_no;

-- ================================================================
-- 32. LARGE TRANSACTIONS
-- ================================================================

SELECT
    account_id,
    event_id,
    event_type_code,
    event_amount,
    event_time
FROM account_events
WHERE event_amount >= 10000
ORDER BY event_amount DESC;

-- ================================================================
-- 33. DAILY EVENT ACTIVITY
-- ================================================================

SELECT
    DATE(event_time) AS event_date,
    COUNT(*) AS events,
    SUM(balance_delta) AS net_balance_change
FROM account_events
GROUP BY DATE(event_time)
ORDER BY event_date;

-- ================================================================
-- 34. ACCOUNT ACTIVITY SUMMARY
-- ================================================================

SELECT
    a.account_id,
    a.account_number,
    a.customer_name,
    COUNT(e.event_id) AS total_events,
    MIN(e.event_time) AS first_event_time,
    MAX(e.event_time) AS last_event_time,
    COALESCE(SUM(e.balance_delta), 0.00) AS reconstructed_balance
FROM accounts a
LEFT JOIN account_events e
    ON e.account_id = a.account_id
GROUP BY
    a.account_id,
    a.account_number,
    a.customer_name
ORDER BY a.account_id;

-- ================================================================
-- 35. FINAL EVENT-SOURCING REPORT
-- ================================================================

WITH replay AS (
    SELECT
        e.account_id,
        e.sequence_no,
        e.event_type_code,
        e.event_amount,
        e.balance_delta,
        e.event_time,
        SUM(e.balance_delta) OVER (
            PARTITION BY e.account_id
            ORDER BY e.sequence_no
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS balance_after_event
    FROM account_events e
)
SELECT
    a.account_number,
    a.customer_name,
    r.sequence_no,
    r.event_type_code,
    r.event_amount,
    r.balance_delta,
    r.balance_after_event,
    r.event_time
FROM replay r
JOIN accounts a
    ON a.account_id = r.account_id
ORDER BY r.account_id, r.sequence_no;

-- ================================================================
-- END OF DAY 75
-- ================================================================
