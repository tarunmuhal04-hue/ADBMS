-- STEP 1 — Setup
DROP TABLE IF EXISTS StudentEnrollments;

CREATE TABLE StudentEnrollments (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL,
    course_id VARCHAR(10) NOT NULL,
    enrollment_date DATE NOT NULL
);

INSERT INTO StudentEnrollments (student_id, student_name, course_id, enrollment_date)
VALUES
(1, 'Ashish', 'CSE101', '2024-06-01'),
(2, 'Smaran', 'CSE102', '2024-06-01'),
(3, 'Vaibhav', 'CSE103', '2024-06-01');

SELECT 'Initial Data' AS step, student_id, student_name, course_id, enrollment_date
FROM StudentEnrollments;


-- =========================
-- STEP 2 — Part A Deadlock Simulation
-- Run these in two sessions in this order:
-- Session 1 first, then Session 2 while Session 1 is waiting

-- SESSION 1
START TRANSACTION;
SELECT * FROM StudentEnrollments WHERE student_id = 1 FOR UPDATE;
SELECT SLEEP(5);
SELECT * FROM StudentEnrollments WHERE student_id = 2 FOR UPDATE;
COMMIT;

-- SESSION 2
START TRANSACTION;
SELECT * FROM StudentEnrollments WHERE student_id = 2 FOR UPDATE;
SELECT SLEEP(5);
SELECT * FROM StudentEnrollments WHERE student_id = 1 FOR UPDATE;
COMMIT;


-- =========================
-- STEP 3 — Part B MVCC Demonstration
-- Run these in two sessions in this order:
-- Session 1 first, then Session 2 while Session 1 is open

-- SESSION 1
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;
SELECT enrollment_date FROM StudentEnrollments WHERE student_id = 1;
SELECT SLEEP(5);
SELECT enrollment_date FROM StudentEnrollments WHERE student_id = 1;
COMMIT;

-- SESSION 2
START TRANSACTION;
UPDATE StudentEnrollments SET enrollment_date = '2024-07-10' WHERE student_id = 1;
COMMIT;


-- =========================
-- STEP 4 — Part C Locking vs MVCC
-- Scenario 1 — Locking
-- Run these in two sessions in this order:
-- Session 1 first, then Session 2

-- SESSION 1
START TRANSACTION;
SELECT * FROM StudentEnrollments WHERE student_id = 1 FOR UPDATE;
SELECT SLEEP(5);
COMMIT;

-- SESSION 2
START TRANSACTION;
SELECT * FROM StudentEnrollments WHERE student_id = 1 FOR UPDATE;
COMMIT;


-- Scenario 2 — MVCC
-- Run these in two sessions in this order:
-- Session 1 first, then Session 2 while Session 1 is open

-- SESSION 1
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;
SELECT enrollment_date FROM StudentEnrollments WHERE student_id = 1;
SELECT SLEEP(5);
SELECT enrollment_date FROM StudentEnrollments WHERE student_id = 1;
COMMIT;

-- SESSION 2
START TRANSACTION;
UPDATE StudentEnrollments SET enrollment_date = '2024-07-20' WHERE student_id = 1;
COMMIT;