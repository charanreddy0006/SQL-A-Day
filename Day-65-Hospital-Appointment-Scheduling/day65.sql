-- ============================================================
-- SQL-A-Day | Day 65
-- Hospital Appointment & Doctor Scheduling System
-- MySQL
-- ============================================================

DROP DATABASE IF EXISTS hospital_scheduling;
CREATE DATABASE hospital_scheduling;
USE hospital_scheduling;

-- ============================================================
-- 1. DEPARTMENTS
-- ============================================================

CREATE TABLE departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    floor_number INT NOT NULL,
    contact_number VARCHAR(20),
    CHECK (floor_number > 0)
);

-- ============================================================
-- 2. DOCTORS
-- ============================================================

CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY AUTO_INCREMENT,
    doctor_code VARCHAR(20) NOT NULL UNIQUE,
    doctor_name VARCHAR(100) NOT NULL,
    department_id INT NOT NULL,
    specialization VARCHAR(100) NOT NULL,
    consultation_fee DECIMAL(10,2) NOT NULL,
    experience_years INT NOT NULL,
    doctor_status ENUM('Available','On Leave','Inactive')
        NOT NULL DEFAULT 'Available',

    FOREIGN KEY (department_id)
        REFERENCES departments(department_id),

    CHECK (consultation_fee > 0),
    CHECK (experience_years >= 0)
);

-- ============================================================
-- 3. PATIENTS
-- ============================================================

CREATE TABLE patients (
    patient_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_code VARCHAR(20) NOT NULL UNIQUE,
    patient_name VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender ENUM('Male','Female','Other') NOT NULL,
    phone VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(150) UNIQUE,
    blood_group VARCHAR(5),
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 4. DOCTOR AVAILABILITY
-- ============================================================

CREATE TABLE doctor_availability (
    availability_id INT PRIMARY KEY AUTO_INCREMENT,
    doctor_id INT NOT NULL,
    available_day ENUM(
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday'
    ) NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,

    FOREIGN KEY (doctor_id)
        REFERENCES doctors(doctor_id),

    CHECK (start_time < end_time),

    UNIQUE (
        doctor_id,
        available_day,
        start_time,
        end_time
    )
);

-- ============================================================
-- 5. APPOINTMENTS
-- ============================================================

CREATE TABLE appointments (
    appointment_id INT PRIMARY KEY AUTO_INCREMENT,
    appointment_code VARCHAR(30) NOT NULL UNIQUE,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,

    appointment_start DATETIME NOT NULL,
    appointment_end DATETIME NOT NULL,

    appointment_type ENUM(
        'Consultation',
        'Follow-up',
        'Emergency',
        'Routine Checkup'
    ) NOT NULL DEFAULT 'Consultation',

    appointment_status ENUM(
        'Scheduled',
        'Completed',
        'Cancelled',
        'No Show'
    ) NOT NULL DEFAULT 'Scheduled',

    reason VARCHAR(255),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id),

    FOREIGN KEY (doctor_id)
        REFERENCES doctors(doctor_id),

    CHECK (appointment_start < appointment_end)
);

-- ============================================================
-- 6. MEDICAL VISITS
-- ============================================================

CREATE TABLE medical_visits (
    visit_id INT PRIMARY KEY AUTO_INCREMENT,
    appointment_id INT NOT NULL UNIQUE,
    diagnosis VARCHAR(255) NOT NULL,
    prescription VARCHAR(500),
    notes TEXT,
    follow_up_date DATE,

    FOREIGN KEY (appointment_id)
        REFERENCES appointments(appointment_id)
);

-- ============================================================
-- 7. PAYMENTS
-- ============================================================

CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    appointment_id INT NOT NULL UNIQUE,
    amount DECIMAL(10,2) NOT NULL,
    payment_method ENUM(
        'Cash',
        'Card',
        'UPI',
        'Insurance'
    ) NOT NULL,
    payment_status ENUM(
        'Pending',
        'Paid',
        'Refunded'
    ) NOT NULL DEFAULT 'Pending',
    payment_date DATETIME,

    FOREIGN KEY (appointment_id)
        REFERENCES appointments(appointment_id),

    CHECK (amount > 0)
);

-- ============================================================
-- INSERT DEPARTMENTS
-- ============================================================

INSERT INTO departments
(department_name, floor_number, contact_number)
VALUES
('Cardiology', 2, '9001001001'),
('Neurology', 3, '9001001002'),
('Orthopedics', 4, '9001001003'),
('Pediatrics', 5, '9001001004'),
('Dermatology', 6, '9001001005'),
('General Medicine', 1, '9001001006');

-- ============================================================
-- INSERT DOCTORS
-- ============================================================

INSERT INTO doctors
(
    doctor_code,
    doctor_name,
    department_id,
    specialization,
    consultation_fee,
    experience_years,
    doctor_status
)
VALUES
('DOC001','Dr. Arjun Rao',1,'Cardiologist',1200,15,'Available'),
('DOC002','Dr. Priya Sharma',1,'Interventional Cardiologist',1500,12,'Available'),
('DOC003','Dr. Rahul Mehta',2,'Neurologist',1300,14,'Available'),
('DOC004','Dr. Sneha Kapoor',2,'Neurosurgeon',1800,18,'Available'),
('DOC005','Dr. Vikram Singh',3,'Orthopedic Surgeon',1100,11,'Available'),
('DOC006','Dr. Ananya Reddy',3,'Sports Medicine',1000,8,'Available'),
('DOC007','Dr. Neha Patel',4,'Pediatrician',900,9,'Available'),
('DOC008','Dr. Karan Gupta',4,'Child Specialist',950,7,'On Leave'),
('DOC009','Dr. Meera Nair',5,'Dermatologist',1000,10,'Available'),
('DOC010','Dr. Rohan Shah',6,'General Physician',700,13,'Available');

-- ============================================================
-- INSERT PATIENTS
-- ============================================================

INSERT INTO patients
(
    patient_code,
    patient_name,
    date_of_birth,
    gender,
    phone,
    email,
    blood_group
)
VALUES
('PAT001','Aarav Kumar','1998-05-12','Male',
 '9876500001','aarav@email.com','B+'),

('PAT002','Priya Reddy','1995-08-21','Female',
 '9876500002','priya@email.com','O+'),

('PAT003','Rahul Sharma','1989-02-14','Male',
 '9876500003','rahul@email.com','A+'),

('PAT004','Sneha Rao','2001-11-09','Female',
 '9876500004','sneha@email.com','AB+'),

('PAT005','Vikram Patel','1978-04-30','Male',
 '9876500005','vikram@email.com','B-'),

('PAT006','Ananya Gupta','2010-07-15','Female',
 '9876500006','ananya@email.com','O+'),

('PAT007','Karan Singh','1992-12-05','Male',
 '9876500007','karan@email.com','A-'),

('PAT008','Meera Joshi','1985-03-22','Female',
 '9876500008','meera@email.com','B+'),

('PAT009','Rohan Kumar','2003-09-18','Male',
 '9876500009','rohan@email.com','O-'),

('PAT010','Isha Nair','1999-06-27','Female',
 '9876500010','isha@email.com','AB+');

-- ============================================================
-- DOCTOR AVAILABILITY
-- ============================================================

INSERT INTO doctor_availability
(
    doctor_id,
    available_day,
    start_time,
    end_time
)
VALUES

(1,'Monday','09:00:00','13:00:00'),
(1,'Wednesday','09:00:00','13:00:00'),
(1,'Friday','09:00:00','13:00:00'),

(2,'Tuesday','10:00:00','14:00:00'),
(2,'Thursday','10:00:00','14:00:00'),

(3,'Monday','14:00:00','18:00:00'),
(3,'Wednesday','14:00:00','18:00:00'),

(4,'Tuesday','09:00:00','13:00:00'),
(4,'Friday','09:00:00','13:00:00'),

(5,'Monday','09:00:00','13:00:00'),
(5,'Thursday','09:00:00','13:00:00'),

(6,'Tuesday','14:00:00','18:00:00'),
(6,'Saturday','09:00:00','13:00:00'),

(7,'Monday','10:00:00','14:00:00'),
(7,'Wednesday','10:00:00','14:00:00'),

(8,'Tuesday','10:00:00','14:00:00'),

(9,'Thursday','09:00:00','13:00:00'),
(9,'Saturday','09:00:00','13:00:00'),

(10,'Monday','09:00:00','17:00:00'),
(10,'Tuesday','09:00:00','17:00:00'),
(10,'Wednesday','09:00:00','17:00:00'),
(10,'Thursday','09:00:00','17:00:00'),
(10,'Friday','09:00:00','17:00:00');

-- ============================================================
-- INSERT APPOINTMENTS
-- ============================================================

INSERT INTO appointments
(
    appointment_code,
    patient_id,
    doctor_id,
    appointment_start,
    appointment_end,
    appointment_type,
    appointment_status,
    reason
)
VALUES

('APT001',1,1,
 '2026-08-24 09:00:00',
 '2026-08-24 09:30:00',
 'Consultation',
 'Scheduled',
 'Chest discomfort'),

('APT002',2,1,
 '2026-08-24 09:30:00',
 '2026-08-24 10:00:00',
 'Follow-up',
 'Scheduled',
 'Follow-up consultation'),

('APT003',3,1,
 '2026-08-24 10:00:00',
 '2026-08-24 10:30:00',
 'Consultation',
 'Completed',
 'Heart checkup'),

('APT004',4,2,
 '2026-08-25 10:00:00',
 '2026-08-25 10:30:00',
 'Consultation',
 'Scheduled',
 'Routine cardiac consultation'),

('APT005',5,3,
 '2026-08-24 14:00:00',
 '2026-08-24 14:45:00',
 'Consultation',
 'Completed',
 'Headache'),

('APT006',6,7,
 '2026-08-24 10:00:00',
 '2026-08-24 10:30:00',
 'Routine Checkup',
 'Scheduled',
 'Child health check'),

('APT007',7,5,
 '2026-08-24 09:00:00',
 '2026-08-24 09:30:00',
 'Consultation',
 'Completed',
 'Knee pain'),

('APT008',8,9,
 '2026-08-27 09:00:00',
 '2026-08-27 09:30:00',
 'Consultation',
 'Scheduled',
 'Skin allergy'),

('APT009',9,10,
 '2026-08-24 11:00:00',
 '2026-08-24 11:30:00',
 'Consultation',
 'Scheduled',
 'Fever'),

('APT010',10,10,
 '2026-08-24 11:30:00',
 '2026-08-24 12:00:00',
 'Follow-up',
 'Scheduled',
 'Follow-up visit'),

('APT011',1,3,
 '2026-08-26 14:00:00',
 '2026-08-26 14:30:00',
 'Consultation',
 'Scheduled',
 'Migraine'),

('APT012',2,6,
 '2026-08-25 14:00:00',
 '2026-08-25 14:30:00',
 'Consultation',
 'Scheduled',
 'Sports injury'),

('APT013',3,5,
 '2026-08-27 09:00:00',
 '2026-08-27 09:30:00',
 'Follow-up',
 'Scheduled',
 'Orthopedic follow-up'),

('APT014',4,9,
 '2026-08-29 09:00:00',
 '2026-08-29 09:30:00',
 'Consultation',
 'Cancelled',
 'Skin examination'),

('APT015',5,10,
 '2026-08-24 12:00:00',
 '2026-08-24 12:30:00',
 'Consultation',
 'No Show',
 'General consultation');

-- ============================================================
-- MEDICAL VISITS
-- ============================================================

INSERT INTO medical_visits
(
    appointment_id,
    diagnosis,
    prescription,
    notes,
    follow_up_date
)
VALUES

(3,
 'Mild hypertension',
 'Prescribed medication',
 'Monitor blood pressure regularly',
 '2026-09-03'),

(5,
 'Migraine',
 'Pain management medication',
 'Avoid known migraine triggers',
 '2026-09-07'),

(7,
 'Minor knee inflammation',
 'Anti-inflammatory medication',
 'Recommended rest and physiotherapy',
 '2026-09-10');

-- ============================================================
-- PAYMENTS
-- ============================================================

INSERT INTO payments
(
    appointment_id,
    amount,
    payment_method,
    payment_status,
    payment_date
)
VALUES

(1,1200,'UPI','Paid','2026-08-24 08:50:00'),
(2,1200,'Card','Paid','2026-08-24 09:20:00'),
(3,1200,'Insurance','Paid','2026-08-24 09:50:00'),
(4,1500,'UPI','Paid','2026-08-25 09:50:00'),
(5,1300,'Cash','Paid','2026-08-24 13:50:00'),
(6,900,'UPI','Paid','2026-08-24 09:50:00'),
(7,1100,'Card','Paid','2026-08-24 08:50:00'),
(8,1000,'UPI','Pending',NULL),
(9,700,'Cash','Paid','2026-08-24 10:50:00'),
(10,700,'UPI','Paid','2026-08-24 11:20:00'),
(11,1300,'Card','Pending',NULL),
(12,1000,'UPI','Paid','2026-08-25 13:50:00'),
(13,1100,'Card','Pending',NULL),
(14,1000,'UPI','Refunded','2026-08-29 08:50:00'),
(15,700,'Cash','Pending',NULL);

-- ============================================================
-- BASIC QUERIES
-- ============================================================

-- 1. Display all doctors

SELECT
    d.doctor_id,
    d.doctor_name,
    d.specialization,
    dep.department_name,
    d.consultation_fee,
    d.experience_years,
    d.doctor_status
FROM doctors d
JOIN departments dep
    ON d.department_id = dep.department_id
ORDER BY d.doctor_name;

-- 2. Display all patients

SELECT *
FROM patients
ORDER BY patient_name;

-- 3. Display all appointments

SELECT
    a.appointment_code,
    p.patient_name,
    d.doctor_name,
    a.appointment_start,
    a.appointment_end,
    a.appointment_type,
    a.appointment_status
FROM appointments a
JOIN patients p
    ON a.patient_id = p.patient_id
JOIN doctors d
    ON a.doctor_id = d.doctor_id
ORDER BY a.appointment_start;

-- ============================================================
-- DOCTOR WORKLOAD
-- ============================================================

SELECT
    d.doctor_name,
    COUNT(a.appointment_id) AS total_appointments
FROM doctors d
LEFT JOIN appointments a
    ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.doctor_name
ORDER BY total_appointments DESC;

-- ============================================================
-- APPOINTMENTS BY DEPARTMENT
-- ============================================================

SELECT
    dep.department_name,
    COUNT(a.appointment_id) AS total_appointments
FROM departments dep
JOIN doctors d
    ON dep.department_id = d.department_id
LEFT JOIN appointments a
    ON d.doctor_id = a.doctor_id
GROUP BY dep.department_id, dep.department_name
ORDER BY total_appointments DESC;

-- ============================================================
-- DATE FUNCTIONS
-- ============================================================

SELECT
    appointment_code,
    appointment_start,
    DAYNAME(appointment_start) AS appointment_day,
    DATE(appointment_start) AS appointment_date,
    TIME(appointment_start) AS appointment_time
FROM appointments
ORDER BY appointment_start;

-- ============================================================
-- APPOINTMENT DURATION
-- ============================================================

SELECT
    appointment_code,
    patient_id,
    doctor_id,
    TIMESTAMPDIFF(
        MINUTE,
        appointment_start,
        appointment_end
    ) AS duration_minutes
FROM appointments
ORDER BY duration_minutes DESC;

-- ============================================================
-- DOCTORS AVAILABLE ON A PARTICULAR DAY
-- ============================================================

SELECT
    d.doctor_name,
    d.specialization,
    da.available_day,
    da.start_time,
    da.end_time
FROM doctors d
JOIN doctor_availability da
    ON d.doctor_id = da.doctor_id
WHERE da.available_day = 'Monday'
ORDER BY da.start_time;

-- ============================================================
-- PATIENT APPOINTMENT HISTORY
-- ============================================================

SELECT
    p.patient_name,
    a.appointment_start,
    d.doctor_name,
    d.specialization,
    a.appointment_status
FROM patients p
JOIN appointments a
    ON p.patient_id = a.patient_id
JOIN doctors d
    ON a.doctor_id = d.doctor_id
WHERE p.patient_id = 1
ORDER BY a.appointment_start DESC;

-- ============================================================
-- COMPLETED VISITS
-- ============================================================

SELECT
    p.patient_name,
    d.doctor_name,
    mv.diagnosis,
    mv.prescription,
    mv.follow_up_date
FROM medical_visits mv
JOIN appointments a
    ON mv.appointment_id = a.appointment_id
JOIN patients p
    ON a.patient_id = p.patient_id
JOIN doctors d
    ON a.doctor_id = d.doctor_id
ORDER BY mv.follow_up_date;

-- ============================================================
-- PAYMENT SUMMARY
-- ============================================================

SELECT
    payment_status,
    COUNT(*) AS payment_count,
    SUM(amount) AS total_amount
FROM payments
GROUP BY payment_status
ORDER BY total_amount DESC;

-- ============================================================
-- DOCTOR REVENUE
-- ============================================================

SELECT
    d.doctor_name,
    COUNT(p.payment_id) AS paid_appointments,
    COALESCE(SUM(p.amount),0) AS total_revenue
FROM doctors d
LEFT JOIN appointments a
    ON d.doctor_id = a.doctor_id
LEFT JOIN payments p
    ON a.appointment_id = p.appointment_id
    AND p.payment_status = 'Paid'
GROUP BY d.doctor_id, d.doctor_name
ORDER BY total_revenue DESC;

-- ============================================================
-- SELF JOIN
-- FIND APPOINTMENTS OF THE SAME DOCTOR
-- THAT OVERLAP
-- ============================================================

SELECT
    a1.appointment_code AS appointment_1,
    a2.appointment_code AS appointment_2,
    d.doctor_name,
    a1.appointment_start AS start_1,
    a1.appointment_end AS end_1,
    a2.appointment_start AS start_2,
    a2.appointment_end AS end_2
FROM appointments a1
JOIN appointments a2
    ON a1.doctor_id = a2.doctor_id
    AND a1.appointment_id < a2.appointment_id
    AND a1.appointment_start < a2.appointment_end
    AND a1.appointment_end > a2.appointment_start
JOIN doctors d
    ON a1.doctor_id = d.doctor_id;

-- ============================================================
-- FIND PATIENTS WITH MULTIPLE APPOINTMENTS
-- ============================================================

SELECT
    p.patient_name,
    COUNT(a.appointment_id) AS appointment_count
FROM patients p
JOIN appointments a
    ON p.patient_id = a.patient_id
GROUP BY p.patient_id, p.patient_name
HAVING COUNT(a.appointment_id) > 1
ORDER BY appointment_count DESC;

-- ============================================================
-- EXISTS
-- PATIENTS WHO HAVE COMPLETED A MEDICAL VISIT
-- ============================================================

SELECT
    p.patient_id,
    p.patient_name
FROM patients p
WHERE EXISTS (
    SELECT 1
    FROM appointments a
    JOIN medical_visits mv
        ON a.appointment_id = mv.appointment_id
    WHERE a.patient_id = p.patient_id
)
ORDER BY p.patient_name;

-- ============================================================
-- NOT EXISTS
-- PATIENTS WITHOUT COMPLETED MEDICAL VISITS
-- ============================================================

SELECT
    p.patient_id,
    p.patient_name
FROM patients p
WHERE NOT EXISTS (
    SELECT 1
    FROM appointments a
    JOIN medical_visits mv
        ON a.appointment_id = mv.appointment_id
    WHERE a.patient_id = p.patient_id
)
ORDER BY p.patient_name;

-- ============================================================
-- LAG()
-- PREVIOUS APPOINTMENT OF EACH DOCTOR
-- ============================================================

SELECT
    d.doctor_name,
    a.appointment_code,
    a.appointment_start,

    LAG(a.appointment_start)
        OVER (
            PARTITION BY a.doctor_id
            ORDER BY a.appointment_start
        ) AS previous_appointment

FROM appointments a
JOIN doctors d
    ON a.doctor_id = d.doctor_id
ORDER BY d.doctor_name, a.appointment_start;

-- ============================================================
-- LEAD()
-- NEXT APPOINTMENT OF EACH DOCTOR
-- ============================================================

SELECT
    d.doctor_name,
    a.appointment_code,
    a.appointment_start,

    LEAD(a.appointment_start)
        OVER (
            PARTITION BY a.doctor_id
            ORDER BY a.appointment_start
        ) AS next_appointment

FROM appointments a
JOIN doctors d
    ON a.doctor_id = d.doctor_id
ORDER BY d.doctor_name, a.appointment_start;

-- ============================================================
-- GAP BETWEEN APPOINTMENTS
-- ============================================================

WITH appointment_sequence AS
(
    SELECT
        doctor_id,
        appointment_code,
        appointment_start,
        appointment_end,

        LEAD(appointment_start)
            OVER (
                PARTITION BY doctor_id
                ORDER BY appointment_start
            ) AS next_start

    FROM appointments
    WHERE appointment_status <> 'Cancelled'
)

SELECT
    d.doctor_name,
    appointment_code,
    appointment_start,
    appointment_end,
    next_start,

    TIMESTAMPDIFF(
        MINUTE,
        appointment_end,
        next_start
    ) AS gap_minutes

FROM appointment_sequence s
JOIN doctors d
    ON s.doctor_id = d.doctor_id

WHERE next_start IS NOT NULL
ORDER BY d.doctor_name, appointment_start;

-- ============================================================
-- DOCTORS WITH HIGH WORKLOAD
-- ============================================================

SELECT
    d.doctor_name,
    COUNT(a.appointment_id) AS appointment_count
FROM doctors d
JOIN appointments a
    ON d.doctor_id = a.doctor_id
WHERE a.appointment_status IN ('Scheduled','Completed')
GROUP BY d.doctor_id, d.doctor_name
HAVING COUNT(a.appointment_id) >= 3
ORDER BY appointment_count DESC;

-- ============================================================
-- PATIENT NO-SHOW ANALYSIS
-- ============================================================

SELECT
    p.patient_name,
    COUNT(a.appointment_id) AS no_show_count
FROM patients p
JOIN appointments a
    ON p.patient_id = a.patient_id
WHERE a.appointment_status = 'No Show'
GROUP BY p.patient_id, p.patient_name
ORDER BY no_show_count DESC;

-- ============================================================
-- CANCELLATION ANALYSIS
-- ============================================================

SELECT
    d.doctor_name,
    COUNT(a.appointment_id) AS cancelled_appointments
FROM doctors d
JOIN appointments a
    ON d.doctor_id = a.doctor_id
WHERE a.appointment_status = 'Cancelled'
GROUP BY d.doctor_id, d.doctor_name
ORDER BY cancelled_appointments DESC;

-- ============================================================
-- APPOINTMENT STATUS SUMMARY
-- ============================================================

SELECT
    appointment_status,
    COUNT(*) AS total_appointments,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM appointments),
        2
    ) AS percentage
FROM appointments
GROUP BY appointment_status
ORDER BY total_appointments DESC;

-- ============================================================
-- DOCTOR RANKING BY APPOINTMENT COUNT
-- ============================================================

WITH doctor_workload AS
(
    SELECT
        d.doctor_id,
        d.doctor_name,
        COUNT(a.appointment_id) AS appointment_count
    FROM doctors d
    LEFT JOIN appointments a
        ON d.doctor_id = a.doctor_id
    GROUP BY d.doctor_id, d.doctor_name
)

SELECT
    doctor_name,
    appointment_count,

    RANK() OVER (
        ORDER BY appointment_count DESC
    ) AS workload_rank

FROM doctor_workload
ORDER BY workload_rank;

-- ============================================================
-- DEPARTMENT APPOINTMENT RANKING
-- ============================================================

WITH department_appointments AS
(
    SELECT
        dep.department_name,
        COUNT(a.appointment_id) AS appointment_count

    FROM departments dep

    JOIN doctors d
        ON dep.department_id = d.department_id

    LEFT JOIN appointments a
        ON d.doctor_id = a.doctor_id

    GROUP BY
        dep.department_id,
        dep.department_name
)

SELECT
    department_name,
    appointment_count,

    DENSE_RANK() OVER (
        ORDER BY appointment_count DESC
    ) AS department_rank

FROM department_appointments
ORDER BY department_rank;

-- ============================================================
-- CTE
-- DOCTOR REVENUE REPORT
-- ============================================================

WITH revenue AS
(
    SELECT
        d.doctor_id,
        d.doctor_name,
        COALESCE(
            SUM(
                CASE
                    WHEN p.payment_status = 'Paid'
                    THEN p.amount
                    ELSE 0
                END
            ),
            0
        ) AS total_revenue

    FROM doctors d

    LEFT JOIN appointments a
        ON d.doctor_id = a.doctor_id

    LEFT JOIN payments p
        ON a.appointment_id = p.appointment_id

    GROUP BY
        d.doctor_id,
        d.doctor_name
)

SELECT
    doctor_name,
    total_revenue,

    ROUND(
        total_revenue /
        NULLIF(
            (SELECT SUM(total_revenue) FROM revenue),
            0
        ) * 100,
        2
    ) AS revenue_percentage

FROM revenue
ORDER BY total_revenue DESC;

-- ============================================================
-- FIND DOCTORS WITH NO APPOINTMENTS
-- ============================================================

SELECT
    d.doctor_id,
    d.doctor_name,
    d.specialization
FROM doctors d
WHERE NOT EXISTS
(
    SELECT 1
    FROM appointments a
    WHERE a.doctor_id = d.doctor_id
)
ORDER BY d.doctor_name;

-- ============================================================
-- APPOINTMENTS OUTSIDE DOCTOR AVAILABILITY
-- ============================================================

SELECT
    a.appointment_code,
    d.doctor_name,
    a.appointment_start,
    DAYNAME(a.appointment_start) AS appointment_day
FROM appointments a
JOIN doctors d
    ON a.doctor_id = d.doctor_id
WHERE NOT EXISTS
(
    SELECT 1
    FROM doctor_availability da
    WHERE da.doctor_id = a.doctor_id
      AND da.available_day = DAYNAME(a.appointment_start)
      AND TIME(a.appointment_start) >= da.start_time
      AND TIME(a.appointment_end) <= da.end_time
)
ORDER BY a.appointment_start;

-- ============================================================
-- PATIENTS WITH UPCOMING APPOINTMENTS
-- ============================================================

SELECT
    p.patient_name,
    d.doctor_name,
    a.appointment_start,
    a.appointment_type
FROM appointments a
JOIN patients p
    ON a.patient_id = p.patient_id
JOIN doctors d
    ON a.doctor_id = d.doctor_id
WHERE a.appointment_start > NOW()
  AND a.appointment_status = 'Scheduled'
ORDER BY a.appointment_start;

-- ============================================================
-- DOCTOR DAILY SCHEDULE
-- ============================================================

SELECT
    d.doctor_name,
    DATE(a.appointment_start) AS appointment_date,
    COUNT(*) AS appointments,
    MIN(a.appointment_start) AS first_appointment,
    MAX(a.appointment_end) AS last_appointment
FROM appointments a
JOIN doctors d
    ON a.doctor_id = d.doctor_id
WHERE a.appointment_status <> 'Cancelled'
GROUP BY
    d.doctor_id,
    d.doctor_name,
    DATE(a.appointment_start)
ORDER BY appointment_date, d.doctor_name;

-- ============================================================
-- PATIENT APPOINTMENT FREQUENCY
-- ============================================================

SELECT
    p.patient_name,
    COUNT(*) AS total_visits,

    COUNT(
        CASE
            WHEN a.appointment_status = 'Completed'
            THEN 1
        END
    ) AS completed_visits,

    COUNT(
        CASE
            WHEN a.appointment_status = 'Cancelled'
            THEN 1
        END
    ) AS cancelled_visits,

    COUNT(
        CASE
            WHEN a.appointment_status = 'No Show'
            THEN 1
        END
    ) AS no_show_visits

FROM patients p
JOIN appointments a
    ON p.patient_id = a.patient_id

GROUP BY
    p.patient_id,
    p.patient_name

ORDER BY total_visits DESC;

-- ============================================================
-- HOSPITAL DASHBOARD
-- ============================================================

SELECT
    (SELECT COUNT(*) FROM departments)
        AS total_departments,

    (SELECT COUNT(*) FROM doctors)
        AS total_doctors,

    (SELECT COUNT(*) FROM patients)
        AS total_patients,

    (SELECT COUNT(*) FROM appointments)
        AS total_appointments,

    (
        SELECT COUNT(*)
        FROM appointments
        WHERE appointment_status = 'Completed'
    ) AS completed_appointments,

    (
        SELECT COUNT(*)
        FROM appointments
        WHERE appointment_status = 'Scheduled'
    ) AS scheduled_appointments,

    (
        SELECT COALESCE(SUM(amount),0)
        FROM payments
        WHERE payment_status = 'Paid'
    ) AS total_revenue;

-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX idx_doctor_department
ON doctors(department_id);

CREATE INDEX idx_patient_phone
ON patients(phone);

CREATE INDEX idx_appointment_doctor_date
ON appointments(doctor_id, appointment_start);

CREATE INDEX idx_appointment_patient
ON appointments(patient_id);

CREATE INDEX idx_appointment_status
ON appointments(appointment_status);

CREATE INDEX idx_payment_status
ON payments(payment_status);

-- ============================================================
-- VIEWS
-- ============================================================

CREATE VIEW appointment_details AS

SELECT
    a.appointment_id,
    a.appointment_code,

    p.patient_name,
    p.phone,

    d.doctor_name,
    d.specialization,

    dep.department_name,

    a.appointment_start,
    a.appointment_end,

    TIMESTAMPDIFF(
        MINUTE,
        a.appointment_start,
        a.appointment_end
    ) AS duration_minutes,

    a.appointment_type,
    a.appointment_status,
    a.reason

FROM appointments a

JOIN patients p
    ON a.patient_id = p.patient_id

JOIN doctors d
    ON a.doctor_id = d.doctor_id

JOIN departments dep
    ON d.department_id = dep.department_id;

-- ============================================================
-- FINAL VIEW QUERY
-- ============================================================

SELECT *
FROM appointment_details
ORDER BY appointment_start;

-- ============================================================
-- END OF DAY 65
-- ============================================================