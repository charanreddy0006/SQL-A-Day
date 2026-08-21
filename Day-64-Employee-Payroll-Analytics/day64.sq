-- ============================================================
-- SQL-A-Day | Day 64
-- Employee Payroll & Salary Analytics System
-- MySQL
-- ============================================================

DROP DATABASE IF EXISTS employee_payroll;
CREATE DATABASE employee_payroll;
USE employee_payroll;

CREATE TABLE departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    location VARCHAR(100) NOT NULL,
    annual_budget DECIMAL(14,2) NOT NULL,
    CHECK (annual_budget > 0)
);

CREATE TABLE employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_code VARCHAR(20) NOT NULL UNIQUE,
    employee_name VARCHAR(100) NOT NULL,
    department_id INT NOT NULL,
    job_title VARCHAR(100) NOT NULL,
    hire_date DATE NOT NULL,
    employment_status ENUM('Active','On Leave','Resigned') NOT NULL DEFAULT 'Active',
    email VARCHAR(150) NOT NULL UNIQUE,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

CREATE TABLE salary_history (
    salary_history_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT NOT NULL,
    effective_date DATE NOT NULL,
    previous_salary DECIMAL(12,2),
    new_salary DECIMAL(12,2) NOT NULL,
    change_reason VARCHAR(150) NOT NULL,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    CHECK (new_salary > 0),
    CHECK (previous_salary IS NULL OR previous_salary > 0)
);

CREATE TABLE payroll (
    payroll_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT NOT NULL,
    payroll_month DATE NOT NULL,
    basic_salary DECIMAL(12,2) NOT NULL,
    overtime_hours DECIMAL(6,2) NOT NULL DEFAULT 0,
    overtime_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    bonus DECIMAL(12,2) NOT NULL DEFAULT 0,
    tax_deduction DECIMAL(12,2) NOT NULL DEFAULT 0,
    other_deduction DECIMAL(12,2) NOT NULL DEFAULT 0,
    gross_salary DECIMAL(12,2)
        GENERATED ALWAYS AS
        (basic_salary + overtime_amount + bonus) STORED,
    net_salary DECIMAL(12,2)
        GENERATED ALWAYS AS
        (basic_salary + overtime_amount + bonus
         - tax_deduction - other_deduction) STORED,
    payment_status ENUM('Pending','Processed','Paid') NOT NULL DEFAULT 'Pending',
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    UNIQUE (employee_id, payroll_month),
    CHECK (basic_salary > 0),
    CHECK (overtime_hours >= 0),
    CHECK (overtime_amount >= 0),
    CHECK (bonus >= 0),
    CHECK (tax_deduction >= 0),
    CHECK (other_deduction >= 0)
);

CREATE TABLE bonuses (
    bonus_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT NOT NULL,
    bonus_date DATE NOT NULL,
    bonus_type ENUM('Performance','Festival','Joining','Project','Retention') NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    description VARCHAR(255),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    CHECK (amount > 0)
);

CREATE TABLE tax_records (
    tax_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT NOT NULL,
    tax_year YEAR NOT NULL,
    taxable_income DECIMAL(14,2) NOT NULL,
    tax_amount DECIMAL(14,2) NOT NULL,
    tax_status ENUM('Estimated','Filed','Paid') NOT NULL DEFAULT 'Estimated',
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    UNIQUE (employee_id, tax_year),
    CHECK (taxable_income >= 0),
    CHECK (tax_amount >= 0)
);

INSERT INTO departments
(department_name, location, annual_budget)
VALUES
('Engineering','Bengaluru',18000000),
('Human Resources','Hyderabad',6500000),
('Finance','Mumbai',9000000),
('Marketing','Pune',8500000),
('Sales','Delhi',12000000),
('Operations','Chennai',10000000);

INSERT INTO employees
(employee_code,employee_name,department_id,job_title,hire_date,
 employment_status,email)
VALUES
('EMP001','Aarav Sharma',1,'Senior Software Engineer','2021-02-15','Active','aarav@company.com'),
('EMP002','Priya Patel',1,'Software Engineer','2022-06-10','Active','priya@company.com'),
('EMP003','Rahul Reddy',1,'Data Analyst','2023-01-20','Active','rahul@company.com'),
('EMP004','Sneha Rao',1,'Engineering Manager','2020-09-05','Active','sneha@company.com'),
('EMP005','Vikram Singh',2,'HR Manager','2020-03-12','Active','vikram@company.com'),
('EMP006','Ananya Gupta',2,'HR Executive','2023-04-18','Active','ananya@company.com'),
('EMP007','Karan Mehta',3,'Finance Manager','2019-07-01','Active','karan@company.com'),
('EMP008','Neha Verma',3,'Financial Analyst','2022-11-14','Active','neha@company.com'),
('EMP009','Aditya Kumar',4,'Marketing Manager','2021-05-22','Active','aditya@company.com'),
('EMP010','Meera Joshi',4,'Digital Marketing Executive','2024-01-08','Active','meera@company.com'),
('EMP011','Rohan Shah',5,'Sales Manager','2020-10-10','Active','rohan@company.com'),
('EMP012','Isha Kapoor',5,'Sales Executive','2023-03-16','Active','isha@company.com'),
('EMP013','Manish Kumar',5,'Sales Executive','2024-02-12','Active','manish@company.com'),
('EMP014','Divya Nair',6,'Operations Manager','2021-08-30','Active','divya@company.com'),
('EMP015','Arjun Menon',6,'Operations Executive','2023-09-11','On Leave','arjun@company.com');

INSERT INTO salary_history
(employee_id,effective_date,previous_salary,new_salary,change_reason)
VALUES
(1,'2021-02-15',NULL,95000,'Initial Salary'),
(1,'2023-04-01',95000,108000,'Annual Increment'),
(1,'2025-04-01',108000,125000,'Promotion'),
(2,'2022-06-10',NULL,65000,'Initial Salary'),
(2,'2024-04-01',65000,74000,'Annual Increment'),
(2,'2025-04-01',74000,82000,'Annual Increment'),
(3,'2023-01-20',NULL,58000,'Initial Salary'),
(3,'2024-04-01',58000,65000,'Annual Increment'),
(3,'2025-04-01',65000,72000,'Annual Increment'),
(4,'2020-09-05',NULL,120000,'Initial Salary'),
(4,'2023-04-01',120000,145000,'Promotion'),
(4,'2025-04-01',145000,165000,'Promotion'),
(5,'2020-03-12',NULL,105000,'Initial Salary'),
(5,'2023-04-01',105000,120000,'Annual Increment'),
(5,'2025-04-01',120000,135000,'Annual Increment'),
(6,'2023-04-18',NULL,55000,'Initial Salary'),
(6,'2025-04-01',55000,62000,'Annual Increment'),
(7,'2019-07-01',NULL,115000,'Initial Salary'),
(7,'2023-04-01',115000,130000,'Annual Increment'),
(7,'2025-04-01',130000,145000,'Annual Increment'),
(8,'2022-11-14',NULL,70000,'Initial Salary'),
(8,'2024-04-01',70000,78000,'Annual Increment'),
(8,'2025-04-01',78000,85000,'Annual Increment'),
(9,'2021-05-22',NULL,90000,'Initial Salary'),
(9,'2023-04-01',90000,105000,'Annual Increment'),
(9,'2025-04-01',105000,118000,'Promotion'),
(10,'2024-01-08',NULL,52000,'Initial Salary'),
(10,'2025-04-01',52000,58000,'Annual Increment'),
(11,'2020-10-10',NULL,95000,'Initial Salary'),
(11,'2023-04-01',95000,110000,'Annual Increment'),
(11,'2025-04-01',110000,125000,'Promotion'),
(12,'2023-03-16',NULL,50000,'Initial Salary'),
(12,'2025-04-01',50000,57000,'Annual Increment'),
(13,'2024-02-12',NULL,48000,'Initial Salary'),
(13,'2025-04-01',48000,54000,'Annual Increment'),
(14,'2021-08-30',NULL,88000,'Initial Salary'),
(14,'2023-04-01',88000,100000,'Annual Increment'),
(14,'2025-04-01',100000,112000,'Annual Increment'),
(15,'2023-09-11',NULL,45000,'Initial Salary'),
(15,'2025-04-01',45000,50000,'Annual Increment');

INSERT INTO payroll
(employee_id,payroll_month,basic_salary,overtime_hours,overtime_amount,
 bonus,tax_deduction,other_deduction,payment_status)
VALUES
(1,'2025-07-01',125000,8,10000,15000,25000,3000,'Paid'),
(2,'2025-07-01',82000,6,4920,5000,12000,2000,'Paid'),
(3,'2025-07-01',72000,4,2880,3000,9000,1500,'Paid'),
(4,'2025-07-01',165000,5,8250,20000,35000,4000,'Paid'),
(5,'2025-07-01',135000,3,3375,10000,28000,2500,'Paid'),
(6,'2025-07-01',62000,7,4340,2500,7500,1000,'Paid'),
(7,'2025-07-01',145000,2,1933,12000,30000,3500,'Paid'),
(8,'2025-07-01',85000,5,5313,4000,11000,1800,'Paid'),
(9,'2025-07-01',118000,9,8850,10000,24000,2200,'Paid'),
(10,'2025-07-01',58000,6,3480,2500,7000,900,'Processed'),
(11,'2025-07-01',125000,10,12500,18000,26000,3000,'Paid'),
(12,'2025-07-01',57000,8,4560,3500,7000,1000,'Paid'),
(13,'2025-07-01',54000,5,3375,2000,6500,800,'Paid'),
(14,'2025-07-01',112000,4,3733,7000,22000,2500,'Paid'),
(15,'2025-07-01',50000,0,0,0,6000,700,'Pending'),
(1,'2025-08-01',125000,6,7500,5000,25000,3000,'Paid'),
(2,'2025-08-01',82000,8,6560,3500,12000,2000,'Paid'),
(3,'2025-08-01',72000,3,2160,2500,9000,1500,'Paid'),
(4,'2025-08-01',165000,7,11550,10000,35000,4000,'Paid'),
(5,'2025-08-01',135000,4,4500,5000,28000,2500,'Paid'),
(6,'2025-08-01',62000,6,3720,2000,7500,1000,'Paid'),
(7,'2025-08-01',145000,3,2900,8000,30000,3500,'Paid'),
(8,'2025-08-01',85000,4,4250,3000,11000,1800,'Paid'),
(9,'2025-08-01',118000,8,7867,7000,24000,2200,'Paid'),
(10,'2025-08-01',58000,5,2900,2000,7000,900,'Paid'),
(11,'2025-08-01',125000,12,15000,12000,26000,3000,'Paid'),
(12,'2025-08-01',57000,6,3420,2500,7000,1000,'Paid'),
(13,'2025-08-01',54000,4,2700,1500,6500,800,'Paid'),
(14,'2025-08-01',112000,5,4667,6000,22000,2500,'Paid'),
(15,'2025-08-01',50000,2,1667,0,6000,700,'Processed');

INSERT INTO bonuses
(employee_id,bonus_date,bonus_type,amount,description)
VALUES
(1,'2025-03-31','Performance',15000,'Outstanding engineering performance'),
(2,'2025-03-31','Performance',5000,'Successful project delivery'),
(3,'2025-03-31','Project',3000,'Analytics project completion'),
(4,'2025-03-31','Performance',20000,'Engineering leadership'),
(5,'2025-03-31','Retention',10000,'Employee retention bonus'),
(6,'2025-03-31','Performance',2500,'HR process improvement'),
(7,'2025-03-31','Performance',12000,'Financial planning performance'),
(8,'2025-03-31','Project',4000,'Financial reporting project'),
(9,'2025-03-31','Performance',10000,'Marketing campaign performance'),
(10,'2025-03-31','Project',2500,'Digital campaign delivery'),
(11,'2025-03-31','Performance',18000,'Sales target achievement'),
(12,'2025-03-31','Performance',3500,'Sales target contribution'),
(13,'2025-03-31','Performance',2000,'New customer acquisition'),
(14,'2025-03-31','Performance',7000,'Operational efficiency'),
(15,'2025-03-31','Festival',2000,'Festival bonus');

INSERT INTO tax_records
(employee_id,tax_year,taxable_income,tax_amount,tax_status)
VALUES
(1,2025,1500000,180000,'Estimated'),
(2,2025,984000,90000,'Estimated'),
(3,2025,864000,72000,'Estimated'),
(4,2025,1980000,270000,'Estimated'),
(5,2025,1620000,210000,'Estimated'),
(6,2025,744000,54000,'Estimated'),
(7,2025,1740000,225000,'Estimated'),
(8,2025,1020000,108000,'Estimated'),
(9,2025,1416000,160000,'Estimated'),
(10,2025,696000,48000,'Estimated'),
(11,2025,1500000,180000,'Estimated'),
(12,2025,684000,51000,'Estimated'),
(13,2025,648000,45000,'Estimated'),
(14,2025,1344000,140000,'Estimated'),
(15,2025,600000,36000,'Estimated');

-- ============================================================
-- BASIC QUERIES
-- ============================================================

SELECT
    e.employee_id,e.employee_code,e.employee_name,
    d.department_name,e.job_title,e.hire_date,e.employment_status
FROM employees e
JOIN departments d ON e.department_id=d.department_id
ORDER BY e.employee_id;

-- Current salary for each employee
WITH latest_salary AS (
    SELECT
        employee_id,
        new_salary,
        effective_date,
        ROW_NUMBER() OVER (
            PARTITION BY employee_id
            ORDER BY effective_date DESC
        ) AS rn
    FROM salary_history
)
SELECT
    e.employee_name,d.department_name,
    ls.new_salary AS current_salary,ls.effective_date
FROM employees e
JOIN departments d ON e.department_id=d.department_id
JOIN latest_salary ls ON e.employee_id=ls.employee_id
WHERE ls.rn=1
ORDER BY current_salary DESC;

-- ============================================================
-- SALARY ANALYTICS
-- ============================================================

WITH latest_salary AS (
    SELECT employee_id,new_salary,
           ROW_NUMBER() OVER (
               PARTITION BY employee_id
               ORDER BY effective_date DESC
           ) AS rn
    FROM salary_history
)
SELECT
    d.department_name,
    COUNT(e.employee_id) AS employee_count,
    ROUND(AVG(ls.new_salary),2) AS average_salary,
    MIN(ls.new_salary) AS minimum_salary,
    MAX(ls.new_salary) AS maximum_salary
FROM employees e
JOIN departments d ON e.department_id=d.department_id
JOIN latest_salary ls ON e.employee_id=ls.employee_id
WHERE ls.rn=1
GROUP BY d.department_id,d.department_name
ORDER BY average_salary DESC;

-- Employees earning above their department average
WITH latest_salary AS (
    SELECT employee_id,new_salary,
           ROW_NUMBER() OVER (
               PARTITION BY employee_id
               ORDER BY effective_date DESC
           ) AS rn
    FROM salary_history
),
salary_data AS (
    SELECT
        e.employee_id,e.employee_name,e.department_id,ls.new_salary
    FROM employees e
    JOIN latest_salary ls ON e.employee_id=ls.employee_id
    WHERE ls.rn=1
)
SELECT
    sd.employee_name,d.department_name,
    sd.new_salary,
    ROUND(AVG(sd.new_salary) OVER (
        PARTITION BY sd.department_id
    ),2) AS department_average
FROM salary_data sd
JOIN departments d ON sd.department_id=d.department_id
WHERE sd.new_salary >
      AVG(sd.new_salary) OVER (PARTITION BY sd.department_id);

-- ============================================================
-- SALARY RANKING
-- ============================================================

WITH latest_salary AS (
    SELECT employee_id,new_salary,
           ROW_NUMBER() OVER (
               PARTITION BY employee_id
               ORDER BY effective_date DESC
           ) AS rn
    FROM salary_history
)
SELECT
    e.employee_name,d.department_name,
    ls.new_salary,
    RANK() OVER (
        PARTITION BY e.department_id
        ORDER BY ls.new_salary DESC
    ) AS department_salary_rank
FROM employees e
JOIN departments d ON e.department_id=d.department_id
JOIN latest_salary ls ON e.employee_id=ls.employee_id
WHERE ls.rn=1
ORDER BY d.department_name,department_salary_rank;

-- ============================================================
-- SALARY HISTORY WITH LAG
-- ============================================================

SELECT
    e.employee_name,
    sh.effective_date,
    sh.new_salary,
    LAG(sh.new_salary) OVER (
        PARTITION BY sh.employee_id
        ORDER BY sh.effective_date
    ) AS previous_recorded_salary,
    CASE
        WHEN sh.previous_salary IS NULL THEN 0
        ELSE ROUND(
            ((sh.new_salary-sh.previous_salary)
            /sh.previous_salary)*100,2
        )
    END AS salary_growth_percentage
FROM salary_history sh
JOIN employees e ON sh.employee_id=e.employee_id
ORDER BY e.employee_id,sh.effective_date;

-- ============================================================
-- PAYROLL REPORTS
-- ============================================================

SELECT
    payroll_month,
    COUNT(*) AS employees_processed,
    SUM(gross_salary) AS total_gross_salary,
    SUM(tax_deduction) AS total_tax,
    SUM(other_deduction) AS total_other_deduction,
    SUM(net_salary) AS total_net_salary
FROM payroll
GROUP BY payroll_month
ORDER BY payroll_month;

SELECT
    d.department_name,
    COUNT(DISTINCT p.employee_id) AS employees,
    SUM(p.gross_salary) AS gross_payroll,
    SUM(p.net_salary) AS net_payroll
FROM payroll p
JOIN employees e ON p.employee_id=e.employee_id
JOIN departments d ON e.department_id=d.department_id
GROUP BY d.department_id,d.department_name
ORDER BY gross_payroll DESC;

-- Salary classification using CASE
SELECT
    e.employee_name,p.gross_salary,p.net_salary,
    CASE
        WHEN p.net_salary>=150000 THEN 'Very High'
        WHEN p.net_salary>=100000 THEN 'High'
        WHEN p.net_salary>=60000 THEN 'Medium'
        ELSE 'Low'
    END AS salary_level
FROM payroll p
JOIN employees e ON p.employee_id=e.employee_id
WHERE p.payroll_month='2025-08-01'
ORDER BY p.net_salary DESC;

-- ============================================================
-- BONUS ANALYTICS
-- ============================================================

SELECT
    e.employee_name,
    SUM(b.amount) AS total_bonus
FROM bonuses b
JOIN employees e ON b.employee_id=e.employee_id
GROUP BY e.employee_id,e.employee_name
ORDER BY total_bonus DESC;

SELECT
    bonus_type,
    COUNT(*) AS bonus_count,
    SUM(amount) AS total_bonus_amount,
    ROUND(AVG(amount),2) AS average_bonus
FROM bonuses
GROUP BY bonus_type
ORDER BY total_bonus_amount DESC;

-- ============================================================
-- RUNNING TOTAL
-- ============================================================

SELECT
    payroll_month,employee_id,net_salary,
    SUM(net_salary) OVER (
        PARTITION BY payroll_month
        ORDER BY employee_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_monthly_net_payroll
FROM payroll
ORDER BY payroll_month,employee_id;

-- ============================================================
-- VIEWS
-- ============================================================

CREATE VIEW current_employee_salary AS
WITH latest_salary AS (
    SELECT employee_id,new_salary,effective_date,
           ROW_NUMBER() OVER (
               PARTITION BY employee_id
               ORDER BY effective_date DESC
           ) AS rn
    FROM salary_history
)
SELECT
    e.employee_id,e.employee_code,e.employee_name,
    d.department_name,e.job_title,
    ls.new_salary AS current_salary,ls.effective_date
FROM employees e
JOIN departments d ON e.department_id=d.department_id
JOIN latest_salary ls ON e.employee_id=ls.employee_id
WHERE ls.rn=1;

CREATE VIEW monthly_payroll_summary AS
SELECT
    payroll_month,
    COUNT(*) AS employee_count,
    SUM(gross_salary) AS gross_payroll,
    SUM(tax_deduction) AS total_tax,
    SUM(other_deduction) AS total_deductions,
    SUM(net_salary) AS net_payroll
FROM payroll
GROUP BY payroll_month;

CREATE VIEW employee_payroll_details AS
SELECT
    e.employee_name,d.department_name,p.payroll_month,
    p.basic_salary,p.overtime_amount,p.bonus,
    p.gross_salary,p.tax_deduction,p.other_deduction,
    p.net_salary,p.payment_status
FROM payroll p
JOIN employees e ON p.employee_id=e.employee_id
JOIN departments d ON e.department_id=d.department_id;

SELECT * FROM current_employee_salary ORDER BY current_salary DESC;
SELECT * FROM monthly_payroll_summary ORDER BY payroll_month;
SELECT * FROM employee_payroll_details
ORDER BY payroll_month,net_salary DESC;

-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX idx_employee_department
ON employees(department_id);

CREATE INDEX idx_salary_employee_date
ON salary_history(employee_id,effective_date);

CREATE INDEX idx_payroll_month
ON payroll(payroll_month);

CREATE INDEX idx_payroll_employee
ON payroll(employee_id);

CREATE INDEX idx_bonus_employee
ON bonuses(employee_id);

-- ============================================================
-- STORED PROCEDURES
-- ============================================================

DELIMITER //

CREATE PROCEDURE GetEmployeePayroll(IN input_employee_id INT)
BEGIN
    SELECT
        e.employee_name,p.payroll_month,p.basic_salary,
        p.overtime_amount,p.bonus,p.gross_salary,
        p.tax_deduction,p.other_deduction,p.net_salary,
        p.payment_status
    FROM employees e
    JOIN payroll p ON e.employee_id=p.employee_id
    WHERE e.employee_id=input_employee_id
    ORDER BY p.payroll_month DESC;
END //

CREATE PROCEDURE GetDepartmentPayroll(
    IN input_department_id INT,
    IN input_payroll_month DATE
)
BEGIN
    SELECT
        d.department_name,e.employee_name,
        p.gross_salary,p.net_salary,p.payment_status
    FROM departments d
    JOIN employees e ON d.department_id=e.department_id
    JOIN payroll p ON e.employee_id=p.employee_id
    WHERE d.department_id=input_department_id
      AND p.payroll_month=input_payroll_month
    ORDER BY p.net_salary DESC;
END //

DELIMITER ;

CALL GetEmployeePayroll(1);
CALL GetDepartmentPayroll(1,'2025-08-01');

-- ============================================================
-- TRANSACTION
-- ============================================================

START TRANSACTION;

INSERT INTO salary_history
(employee_id,effective_date,previous_salary,new_salary,change_reason)
VALUES
(10,'2025-09-01',58000,62000,'Performance Increment');

COMMIT;

-- ============================================================
-- FINAL DASHBOARD
-- ============================================================

SELECT
    COUNT(*) AS total_employees,
    SUM(CASE WHEN employment_status='Active' THEN 1 ELSE 0 END)
        AS active_employees,
    SUM(CASE WHEN employment_status='On Leave' THEN 1 ELSE 0 END)
        AS employees_on_leave,
    SUM(CASE WHEN employment_status='Resigned' THEN 1 ELSE 0 END)
        AS resigned_employees
FROM employees;

SELECT
    ROUND(AVG(current_salary),2) AS average_current_salary,
    MIN(current_salary) AS minimum_current_salary,
    MAX(current_salary) AS maximum_current_salary,
    SUM(current_salary) AS total_monthly_basic_salary
FROM current_employee_salary;

SELECT
    payroll_month,
    SUM(gross_salary) AS gross_payroll,
    SUM(net_salary) AS net_payroll,
    SUM(tax_deduction) AS tax_collected
FROM payroll
GROUP BY payroll_month
ORDER BY payroll_month;

-- ============================================================
-- END OF DAY 64
-- ============================================================