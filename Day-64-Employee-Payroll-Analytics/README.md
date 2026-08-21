Day 64 - Employee Payroll & Salary Analytics System

SQL-A-Day

A practical MySQL project for managing employees, departments, salary history, monthly payroll, bonuses, tax records, and salary analytics.

Project Overview

This project simulates a real-world HR and payroll database.

It stores employee information and manages:

Departments

Employees

Job roles

Salary history

Monthly payroll

Overtime

Bonuses

Tax deductions

Other deductions

Gross salary

Net salary

Payment status

The project also focuses on advanced SQL analytics.

Objectives

Design a relational payroll database.

Store department and employee information.

Track salary changes over time.

Manage monthly payroll.

Calculate gross salary automatically.

Calculate net salary automatically.

Analyze salary distribution.

Compare employee salaries.

Rank employees within departments.

Analyze salary growth.

Analyze monthly payroll.

Analyze bonuses.

Calculate running totals.

Create reusable views.

Create indexes.

Create stored procedures.

Practice transactions.

Technologies

MySQL
SQL
CTEs
Window Functions
RANK()
LAG()
CASE
Generated Columns
Views
Indexes
Stored Procedures
Transactions
Aggregate Functions
Subqueries

Project Structure

Day-64-Employee-Payroll-Analytics/
│
├── README.md
└── day64.sql

Database

Database Name: employee_payroll

The SQL file creates the database automatically.

Database Tables

The project contains:

departments
employees
salary_history
payroll
bonuses
tax_records

Departments

The departments table stores organizational departments.

Columns:

department_id
department_name
location
annual_budget

Sample departments:

Engineering
Human Resources
Finance
Marketing
Sales
Operations

Employees

The employees table stores employee information.

Columns:

employee_id
employee_code
employee_name
department_id
job_title
hire_date
employment_status
email

Each employee belongs to a department.

Salary History

The salary_history table records salary changes.

Columns:

salary_history_id
employee_id
effective_date
previous_salary
new_salary
change_reason

This allows salary growth to be tracked over multiple years.

Payroll

The payroll table stores monthly salary information.

Columns:

payroll_id
employee_id
payroll_month
basic_salary
overtime_hours
overtime_amount
bonus
tax_deduction
other_deduction
gross_salary
net_salary
payment_status

Gross Salary

Gross salary is calculated as:

Basic Salary
+ Overtime Amount
+ Bonus

The database calculates it automatically using a generated column.

Net Salary

Net salary is calculated as:

Gross Salary
- Tax Deduction
- Other Deduction

It is also stored as a generated column.

Bonuses

The bonuses table stores employee bonuses.

Bonus types include:

Performance
Festival
Joining
Project
Retention

Columns:

bonus_id
employee_id
bonus_date
bonus_type
amount
description

Tax Records

The tax_records table stores annual tax information.

Columns:

tax_id
employee_id
tax_year
taxable_income
tax_amount
tax_status

Tax statuses:

Estimated
Filed
Paid

Relationships

departments
      |
      | 1
      |
      | N
employees
      |
      +---------- salary_history
      |
      +---------- payroll
      |
      +---------- bonuses
      |
      +---------- tax_records

Constraints

The project uses:

PRIMARY KEY
FOREIGN KEY
UNIQUE
NOT NULL
CHECK
DEFAULT
ENUM

These constraints help maintain data integrity.

Sample Data

The database contains:

6 departments
15 employees
45 salary history records
30 payroll records
15 bonus records
15 tax records

Current Salary Analysis

The latest salary record of an employee is treated as the current salary.

The project uses:

ROW_NUMBER()
PARTITION BY
ORDER BY

to identify the latest salary record.

CTE

A Common Table Expression is used to make complex salary queries easier to read.

Example:

WITH latest_salary AS (
    SELECT
        employee_id,
        new_salary,
        ROW_NUMBER() OVER (
            PARTITION BY employee_id
            ORDER BY effective_date DESC
        ) AS rn
    FROM salary_history
)
SELECT *
FROM latest_salary
WHERE rn = 1;

Average Salary by Department

The project calculates:

Employee Count
Average Salary
Minimum Salary
Maximum Salary

for every department.

This helps management compare salary structures.

Salary Benchmarking

The project identifies employees earning more than their department's average salary.

This is useful for:

Salary benchmarking
Compensation analysis
HR planning
Promotion analysis

Salary Ranking

Employees are ranked within their own department.

RANK() OVER (
    PARTITION BY department_id
    ORDER BY new_salary DESC
)

The ranking restarts for every department.

LAG()

LAG() is used to access the previous salary record.

LAG(new_salary) OVER (
    PARTITION BY employee_id
    ORDER BY effective_date
)

This makes it possible to compare:

Current Salary
Previous Salary

Salary Growth

Salary growth percentage is calculated using:

(New Salary - Previous Salary)
-------------------------------- × 100
Previous Salary

This shows how much an employee's salary increased.

CASE Expression

The project uses CASE to classify net salaries.

150000 or above → Very High
100000 or above → High
60000 or above  → Medium
Below 60000     → Low

This demonstrates conditional SQL logic.

Monthly Payroll

Payroll is summarized by month.

The report provides:

Payroll Month
Employees Processed
Gross Salary
Tax
Other Deductions
Net Salary

Department Payroll

Payroll is also grouped by department.

The report shows:

Department
Employee Count
Gross Payroll
Net Payroll

This can help organizations understand departmental salary expenses.

Bonus Analytics

Bonus data is analyzed using:

COUNT()
SUM()
AVG()
GROUP BY

The project calculates:

Number of bonuses
Total bonus amount
Average bonus
Bonus amount by type

Running Total

A window function calculates a running monthly net payroll.

SUM(net_salary) OVER (
    PARTITION BY payroll_month
    ORDER BY employee_id
    ROWS BETWEEN UNBOUNDED PRECEDING
    AND CURRENT ROW
)

This demonstrates cumulative calculations.

Views

The project creates three views:

current_employee_salary
monthly_payroll_summary
employee_payroll_details

Current Employee Salary View

Provides:

Employee
Employee Code
Department
Job Title
Current Salary
Effective Date

Monthly Payroll Summary View

Provides:

Payroll Month
Employee Count
Gross Payroll
Total Tax
Total Deductions
Net Payroll

Employee Payroll Details View

Combines employee, department, and payroll information.

Provides:

Employee
Department
Payroll Month
Basic Salary
Overtime
Bonus
Gross Salary
Tax
Other Deduction
Net Salary
Payment Status

Indexes

The project creates indexes on frequently queried columns.

Indexes include:

employees.department_id
salary_history.employee_id + effective_date
payroll.payroll_month
payroll.employee_id
bonuses.employee_id

Stored Procedures

Two stored procedures are included:

GetEmployeePayroll
GetDepartmentPayroll

GetEmployeePayroll

Example:

CALL GetEmployeePayroll(1);

This returns payroll history for an employee.

GetDepartmentPayroll

Example:

CALL GetDepartmentPayroll(1,'2025-08-01');

This returns payroll information for a department for a selected month.

Transactions

The project demonstrates transaction processing.

Example:

START TRANSACTION;

INSERT INTO salary_history
(employee_id,effective_date,previous_salary,new_salary,change_reason)
VALUES
(10,'2025-09-01',58000,62000,'Performance Increment');

COMMIT;

A transaction can also be cancelled using:

ROLLBACK;

HR Dashboard

The final queries provide:

Total Employees
Active Employees
Employees on Leave
Resigned Employees
Average Current Salary
Minimum Salary
Maximum Salary
Total Monthly Basic Salary
Gross Payroll
Net Payroll
Tax Collected

Business Questions

The database can answer:

Who is the highest-paid employee?

Who is the lowest-paid employee?

What is the average salary?

What is the average salary for each department?

Which employees earn above their department average?

Who ranks first in salary in each department?

How has an employee's salary changed?

What percentage increase did an employee receive?

What is the total monthly payroll?

Which department has the highest payroll?

Which employees received the highest bonuses?

What is the average bonus?

How much tax was deducted?

What is each employee's net salary?

What is the running payroll total?

Which payroll records are pending?

How many employees are active?

How many employees are on leave?

What is the organization's average salary?

What is the total monthly salary cost?

SQL Concepts Practiced

CREATE DATABASE
CREATE TABLE
INSERT
SELECT
JOIN
WHERE
GROUP BY
ORDER BY
COUNT()
SUM()
AVG()
MIN()
MAX()
Subqueries
Correlated Queries
CTEs
CASE
ROW_NUMBER()
RANK()
LAG()
Window Functions
PARTITION BY
Generated Columns
Views
Indexes
Stored Procedures
Transactions
COMMIT
ROLLBACK
Constraints
ENUM

Main New Concepts in Day 64

Compared with basic SQL CRUD projects, this project focuses on:

Generated Columns
ROW_NUMBER()
RANK()
LAG()
Window Functions
CTEs
Salary Benchmarking
Salary Growth Analysis
Running Totals
Payroll Analytics
Stored Procedures
Transactions

Real-World Application

This database can be used as the database layer of an HR/payroll application.

HR Web Application
        ↓
Backend API
        ↓
MySQL
        ↓
Departments
Employees
Salary History
Payroll
Bonuses
Tax Records

Future Improvements

Possible future features include:

Attendance Management
Leave Management
Employee Performance
Performance Ratings
Promotion Management
Employee Loans
Insurance Deductions
Provident Fund
Professional Tax
Payslip Generation
Bank Account Management
Payroll Approval Workflow
Salary Structures
Recruitment Management
Employee Documents

Learning Outcomes

After completing Day 64, I practiced:

Payroll database design

Employee management

Department relationships

Salary history

Monthly payroll

Salary calculations

Bonus management

Tax records

Generated columns

CTEs

Correlated queries

Window functions

ROW_NUMBER()

RANK()

LAG()

Running totals

CASE

Views

Indexes

Stored procedures

Transactions

HR analytics

Payroll reporting

How to Run

Step 1

Open MySQL Workbench or another MySQL client.

Step 2

Open:

day64.sql

Step 3

Run the complete script.

The script will:

1. Create the database
2. Create all tables
3. Add constraints
4. Insert department data
5. Insert employee data
6. Insert salary history
7. Insert payroll data
8. Insert bonus data
9. Insert tax data
10. Run salary analytics
11. Run payroll analytics
12. Create views
13. Create indexes
14. Create stored procedures
15. Demonstrate a transaction
16. Generate dashboard reports

