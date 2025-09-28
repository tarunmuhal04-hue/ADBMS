-- STEP 1 — Setup
DROP TABLE IF EXISTS StudentEnrollments;

CREATE TABLE StudentEnrollments (
    enrollment_id INT PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL,
    course_id VARCHAR(10) NOT NULL,
    enrollment_date DATE NOT NULL,
    UNIQUE KEY unique_enrollment (student_name, course_id)
);

INSERT INTO StudentEnrollments (enrollment_id, student_name, course_id, enrollment_date)
VALUES
(1, 'Ashish', 'CSE101', '2024-07-01'),
(2, 'Smaran', 'CSE102', '2024-07-01'),
(3, 'Vaibhav', 'CSE101', '2024-07-01');

SELECT 'Initial Data' AS step, enrollment_id, student_name, course_id, enrollment_date
FROM StudentEnrollments;


-- STEP 2 — Part A Prevent Duplicate Enrollments
DROP PROCEDURE IF EXISTS sp_part_a;

CREATE PROCEDURE sp_part_a()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;
        INSERT INTO StudentEnrollments (enrollment_id, student_name, course_id, enrollment_date)
        VALUES (4, 'Ashish', 'CSE101', '2024-07-02');
    COMMIT;
END;

CALL sp_part_a();
DROP PROCEDURE IF EXISTS sp_part_a;

SELECT 'After Part A' AS step, enrollment_id, student_name, course_id, enrollment_date
FROM StudentEnrollments;


-- STEP 3 — Part B Row-Level Locking
-- SESSION 1
START TRANSACTION;
SELECT enrollment_id, student_name, course_id, enrollment_date
FROM StudentEnrollments
WHERE student_name = 'Ashish' AND course_id = 'CSE101'
FOR UPDATE;

-- SESSION 2 (run before Session 1 commits)
START TRANSACTION;
UPDATE StudentEnrollments
SET enrollment_date = '2024-07-05'
WHERE student_name = 'Ashish' AND course_id = 'CSE101';
COMMIT;

-- SESSION 1 commits last
COMMIT;

SELECT 'After Part B' AS step, enrollment_id, student_name, course_id, enrollment_date
FROM StudentEnrollments;


-- STEP 4 — Part C Locking Preserving Consistency
-- Without locking
START TRANSACTION;
UPDATE StudentEnrollments
SET enrollment_date = '2024-07-10'
WHERE enrollment_id = 1;

START TRANSACTION;
UPDATE StudentEnrollments
SET enrollment_date = '2024-07-20'
WHERE enrollment_id = 1;
COMMIT;

COMMIT;

SELECT 'After Part C (Without Locking)' AS step, enrollment_id, student_name, course_id, enrollment_date
FROM StudentEnrollments;

-- With locking
UPDATE StudentEnrollments SET enrollment_date = '2024-07-01' WHERE enrollment_id = 1;

-- SESSION 1
START TRANSACTION;
SELECT enrollment_id, student_name, course_id, enrollment_date
FROM StudentEnrollments WHERE enrollment_id = 1
FOR UPDATE;
UPDATE StudentEnrollments SET enrollment_date = '2024-07-10' WHERE enrollment_id = 1;
COMMIT;

-- SESSION 2
START TRANSACTION;
SELECT enrollment_id, student_name, course_id, enrollment_date
FROM StudentEnrollments WHERE enrollment_id = 1
FOR UPDATE;
UPDATE StudentEnrollments SET enrollment_date = '2024-07-20' WHERE enrollment_id = 1;
COMMIT;

SELECT 'After Part C (With Locking)' AS step, enrollment_id, student_name, course_id, enrollment_date
FROM StudentEnrollments;