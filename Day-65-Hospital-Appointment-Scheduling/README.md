# Day 65 — Hospital Appointment & Doctor Scheduling System

## 📌 Project Overview

This project is a real-world SQL database system designed to manage hospital appointments, doctors, patients, doctor availability, medical visits, and payments.

The main objective of this project is to practice advanced SQL concepts by building a complete hospital appointment scheduling system.

The database manages relationships between patients, doctors, departments, appointments, medical visits, and payments.

It also focuses on detecting appointment scheduling conflicts, analyzing doctor workloads, tracking patient histories, and generating hospital-level reports.

---

## 🎯 Objectives

- Design a relational hospital database.
- Store department information.
- Manage doctors and their specializations.
- Manage patient records.
- Store doctor availability schedules.
- Schedule patient appointments.
- Track appointment status.
- Store medical visit information.
- Manage appointment payments.
- Detect overlapping appointments.
- Analyze doctor workloads.
- Analyze patient appointment history.
- Calculate appointment duration.
- Analyze hospital revenue.
- Generate scheduling reports.
- Practice advanced SQL queries.

---

## 🗂️ Database

**Database Name:**

`hospital_scheduling`

---

## 📁 Project Structure

```text
Day-65-Hospital-Appointment-Scheduling/
│
├── README.md
└── day65.sql
```

---

## 🏥 Database Tables

The project contains seven main tables.

### 1. Departments

The `departments` table stores hospital department information.

```text
department_id
department_name
floor_number
contact_number
```

### 2. Doctors

The `doctors` table stores information about hospital doctors.

```text
doctor_id
doctor_code
doctor_name
department_id
specialization
consultation_fee
experience_years
doctor_status
```

Doctors are connected to departments using a foreign key.

### 3. Patients

The `patients` table stores patient information.

```text
patient_id
patient_code
patient_name
date_of_birth
gender
phone
email
blood_group
registered_at
```

### 4. Doctor Availability

The `doctor_availability` table stores the working schedule of doctors.

```text
availability_id
doctor_id
available_day
start_time
end_time
```

This table allows the system to determine when a doctor is available.

### 5. Appointments

The `appointments` table stores patient appointments.

```text
appointment_id
appointment_code
patient_id
doctor_id
appointment_start
appointment_end
appointment_type
appointment_status
reason
created_at
```

Appointment status can be:

```text
Scheduled
Completed
Cancelled
No Show
```

### 6. Medical Visits

The `medical_visits` table stores medical information after a completed appointment.

```text
visit_id
appointment_id
diagnosis
prescription
notes
follow_up_date
```

### 7. Payments

The `payments` table stores appointment payment information.

```text
payment_id
appointment_id
amount
payment_method
payment_status
payment_date
```

Payment methods include:

```text
Cash
Card
UPI
Insurance
```

---

## 🔗 Table Relationships

```text
Departments
     │
     └── Doctors
             │
             ├── Doctor Availability
             │
             └── Appointments
                       │
             ┌─────────┴─────────┐
             │                   │
         Patients          Medical Visits

Appointments
     │
     └── Payments
```

---

## 🔑 Primary Keys

```text
departments.department_id
doctors.doctor_id
patients.patient_id
doctor_availability.availability_id
appointments.appointment_id
medical_visits.visit_id
payments.payment_id
```

Primary keys uniquely identify each record.

---

## 🔗 Foreign Keys

```text
doctors.department_id
        ↓
departments.department_id
```

```text
doctor_availability.doctor_id
        ↓
doctors.doctor_id
```

```text
appointments.patient_id
        ↓
patients.patient_id
```

```text
appointments.doctor_id
        ↓
doctors.doctor_id
```

```text
medical_visits.appointment_id
        ↓
appointments.appointment_id
```

```text
payments.appointment_id
        ↓
appointments.appointment_id
```

---

## 🧠 SQL Concepts Practiced

### Basic SQL

- SELECT
- WHERE
- ORDER BY
- GROUP BY
- HAVING
- DISTINCT
- COUNT
- SUM
- COALESCE
- ROUND

### JOIN Operations

- INNER JOIN
- LEFT JOIN
- Multiple-table JOINs
- SELF JOIN

### Advanced SQL

- EXISTS
- NOT EXISTS
- Common Table Expressions
- Window Functions
- LAG()
- LEAD()
- RANK()
- DENSE_RANK()
- CASE
- Date and Time Functions
- Views
- Indexes

---

## 🔄 SELF JOIN

A major concept introduced in Day 65 is `SELF JOIN`.

The appointments table is joined with itself to detect appointments belonging to the same doctor that overlap.

```sql
FROM appointments a1
JOIN appointments a2
    ON a1.doctor_id = a2.doctor_id
```

This is useful for detecting scheduling conflicts.

---

## ⚠️ Appointment Conflict Detection

The project checks whether two appointments for the same doctor overlap.

The main condition is:

```sql
a1.appointment_start < a2.appointment_end
AND
a1.appointment_end > a2.appointment_start
```

This helps identify double-booked doctors.

---

## 📅 Date and Time Functions

The project uses:

```text
DATE()
TIME()
DAYNAME()
TIMESTAMPDIFF()
```

These functions are used to analyze appointment dates, times, days, and durations.

---

## ⏱️ Appointment Duration

Appointment duration is calculated using:

```sql
TIMESTAMPDIFF(
    MINUTE,
    appointment_start,
    appointment_end
)
```

This gives the appointment duration in minutes.

---

## 🔎 EXISTS

The project uses `EXISTS` to find patients who have completed medical visits.

```sql
WHERE EXISTS (
    SELECT 1
    FROM appointments a
    JOIN medical_visits mv
        ON a.appointment_id = mv.appointment_id
    WHERE a.patient_id = p.patient_id
)
```

---

## 🚫 NOT EXISTS

`NOT EXISTS` is used to find patients who do not have completed medical visits.

It is also used to find doctors without appointments.

---

## 📊 Aggregate Functions

The project uses:

```text
COUNT()
SUM()
COALESCE()
ROUND()
```

These functions are used for workload and revenue analysis.

---

## 👨‍⚕️ Doctor Workload Analysis

The system calculates how many appointments each doctor has.

```sql
SELECT
    d.doctor_name,
    COUNT(a.appointment_id) AS total_appointments
FROM doctors d
LEFT JOIN appointments a
    ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.doctor_name;
```

This helps identify doctors with higher workloads.

---

## 💰 Revenue Analysis

The system calculates revenue generated by each doctor.

The payment table is connected with appointments and doctors.

Paid appointments are included in revenue calculations.

---

## 💳 Payment Analysis

Payments are grouped according to their status.

Possible statuses are:

```text
Pending
Paid
Refunded
```

The project calculates the total amount associated with each status.

---

## 👤 Patient History

The system can retrieve the appointment history of individual patients.

Patient history includes:

```text
Patient
Doctor
Specialization
Appointment Date
Appointment Status
```

---

## 🩺 Medical Visit Tracking

Completed appointments can have corresponding medical visit records.

Medical visits contain:

```text
Diagnosis
Prescription
Notes
Follow-up Date
```

---

## 📈 Window Functions

Day 65 introduces SQL window functions.

The project uses:

```text
LAG()
LEAD()
RANK()
DENSE_RANK()
```

### LAG()

`LAG()` retrieves information from the previous row.

```sql
LAG(appointment_start)
OVER (
    PARTITION BY doctor_id
    ORDER BY appointment_start
)
```

### LEAD()

`LEAD()` retrieves information from the next row.

```sql
LEAD(appointment_start)
OVER (
    PARTITION BY doctor_id
    ORDER BY appointment_start
)
```

### RANK()

`RANK()` is used to rank doctors based on appointment count.

### DENSE_RANK()

`DENSE_RANK()` is used to rank departments based on appointment counts.

---

## ⏳ Appointment Gaps

Using `LEAD()`, the project calculates the gap between appointments.

This helps analyze:

```text
Free time
Appointment gaps
Doctor schedules
Potential scheduling optimization
```

---

## 🧩 Common Table Expressions

The project uses CTEs using the `WITH` keyword.

Example:

```sql
WITH doctor_workload AS
(
    SELECT
        doctor_id,
        doctor_name,
        COUNT(*) AS appointment_count
    FROM appointments
    GROUP BY doctor_id, doctor_name
)
SELECT *
FROM doctor_workload;
```

CTEs make complex queries easier to understand and organize.

---

## 🔍 Doctor Availability Validation

The system compares appointments against doctor availability.

It can identify appointments that fall outside the doctor's configured availability.

This introduces practical scheduling validation.

---

## 📊 Appointment Status Analysis

The project analyzes:

```text
Scheduled
Completed
Cancelled
No Show
```

It also calculates the percentage of appointments belonging to each status.

---

## 🚫 No-Show Analysis

The project identifies patients who did not attend their appointments.

This can help hospitals analyze patient attendance patterns.

---

## ❌ Cancellation Analysis

The system calculates cancelled appointments for doctors.

This can help identify scheduling and appointment-management patterns.

---

## 📋 Daily Doctor Schedule

The system generates a daily schedule containing:

```text
Doctor
Appointment Date
Number of Appointments
First Appointment
Last Appointment
```

---

## 📊 Patient Appointment Frequency

The system calculates:

```text
Total Visits
Completed Visits
Cancelled Visits
No-Show Visits
```

for each patient.

---

## 🏥 Hospital Dashboard

A dashboard query provides overall statistics.

The dashboard includes:

```text
Total Departments
Total Doctors
Total Patients
Total Appointments
Completed Appointments
Scheduled Appointments
Total Revenue
```

---

## 👁️ SQL VIEW

The project creates an `appointment_details` view.

The view combines information from:

```text
Appointments
Patients
Doctors
Departments
```

The view provides a convenient way to access appointment information without repeatedly writing complex JOIN queries.

---

## ⚡ Indexes

Indexes are created for frequently searched columns.

Examples:

```text
department_id
phone
doctor_id + appointment_start
patient_id
appointment_status
payment_status
```

Indexes can improve query performance for common search operations.

---

## 🧪 Example Questions Answered

1. Which doctors have the most appointments?
2. Which patients have multiple appointments?
3. Which doctors have no appointments?
4. Which appointments overlap?
5. Which patients have completed medical visits?
6. Which patients have no completed medical visits?
7. How long is each appointment?
8. What is the gap between two doctor appointments?
9. Which doctors generate the most revenue?
10. How many appointments are scheduled?
11. How many appointments are completed?
12. How many appointments are cancelled?
13. How many patients are no-shows?
14. Which departments have the highest appointment volume?
15. Which appointments occur outside doctor availability?
16. What is the hospital's total revenue?
17. What is each doctor's workload?
18. What is each patient's appointment history?
19. What is the daily schedule of each doctor?
20. What percentage of appointments belong to each status?

---

## 🛠️ Technologies Used

```text
MySQL
SQL
Relational Database
```

---

## 📚 Concepts Learned in Day 65

```text
Database Design
Primary Keys
Foreign Keys
Constraints
Relationships
INNER JOIN
LEFT JOIN
SELF JOIN
EXISTS
NOT EXISTS
GROUP BY
HAVING
Aggregate Functions
Date Functions
Time Functions
TIMESTAMPDIFF()
CTE
LAG()
LEAD()
RANK()
DENSE_RANK()
CASE
COALESCE()
Views
Indexes
Scheduling Conflict Detection
Revenue Analysis
Workload Analysis
```

---

## ▶️ How to Run

Open MySQL Workbench or MySQL command line.

Run:

```sql
SOURCE day65.sql;
```

Or open `day65.sql` in MySQL Workbench and execute the complete script.

The script will:

```text
1. Create the database
2. Create all tables
3. Add constraints
4. Insert sample data
5. Execute analytical queries
6. Create indexes
7. Create the appointment view
```

---

## 📌 Project Highlights

This project moves beyond basic CRUD operations and focuses on real-world SQL analysis.

The main practical feature is appointment scheduling.

The database can detect overlapping appointments, analyze doctor availability, calculate appointment gaps, track patient visits, and analyze hospital revenue.

The project also introduces window functions and Common Table Expressions for more advanced analytical queries.

---

## 🎓 Learning Outcome

After completing Day 65, I practiced how SQL can be used to build and analyze a real-world hospital scheduling system.

I learned how multiple related tables can work together to represent a practical business system.

I also practiced advanced SQL features such as:

```text
SELF JOIN
EXISTS
NOT EXISTS
CTE
LAG()
LEAD()
RANK()
DENSE_RANK()
```

These concepts are useful for real-world database development, analytics, reporting, and data engineering.

---

## 🚀 Future Improvements

Possible future improvements include:

- Automatic appointment slot generation
- Stored procedures
- Triggers
- Patient authentication
- Doctor login system
- Online appointment booking
- SMS appointment reminders
- Email notifications
- Prescription management
- Hospital billing system
- Insurance claim management
- Appointment rescheduling
- Advanced reporting dashboards
- Database backup and recovery
- Role-based access control

---

## 📝 Day 65 Summary

**Project:** Hospital Appointment & Doctor Scheduling System

**Database:** `hospital_scheduling`

**Main Focus:** Appointment scheduling and advanced SQL analytics

**Major New Concepts:**

```text
SELF JOIN
EXISTS
NOT EXISTS
CTE
LAG()
LEAD()
RANK()
DENSE_RANK()
Date/Time Functions
Scheduling Conflict Detection
Views
Indexes
```

---

## 📅 SQL-A-Day

**Day 65 completed ✅**

```text
Day 65
Hospital Appointment & Doctor Scheduling System
```

Continuing the SQL-A-Day journey with practical, real-world SQL projects.