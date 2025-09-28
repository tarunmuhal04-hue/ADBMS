-- STEP 1 — Setup
DROP TABLE IF EXISTS FeePayments;

CREATE TABLE FeePayments (
    payment_id INT PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_date DATE NOT NULL
);

-- STEP 2 — Part A: Insert multiple payments atomically
START TRANSACTION;
    INSERT INTO FeePayments (payment_id, student_name, amount, payment_date)
    VALUES (1, 'Ashish', 5000.00, '2024-06-01');
    INSERT INTO FeePayments (payment_id, student_name, amount, payment_date)
    VALUES (2, 'Smaran', 4500.00, '2024-06-02');
    INSERT INTO FeePayments (payment_id, student_name, amount, payment_date)
    VALUES (3, 'Vaibhav', 5500.00, '2024-06-03');
COMMIT;

SELECT 'After Part A' AS step, payment_id, student_name, amount, payment_date
FROM FeePayments
ORDER BY payment_id;


-- STEP 3 — Part B: Demonstrate rollback on failure
DROP PROCEDURE IF EXISTS sp_part_b;

CREATE PROCEDURE sp_part_b()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;
        INSERT INTO FeePayments (payment_id, student_name, amount, payment_date)
        VALUES (4, 'Kiran', 4000.00, '2024-06-04');
        INSERT INTO FeePayments (payment_id, student_name, amount, payment_date)
        VALUES (1, 'Duplicate', 2000.00, '2024-06-05'); -- This will fail
    COMMIT;
END;

CALL sp_part_b();
DROP PROCEDURE IF EXISTS sp_part_b;



-- STEP 4 — Part C: Partial failure with NULL violation
DROP PROCEDURE IF EXISTS sp_part_c;

CREATE PROCEDURE sp_part_c()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;
        INSERT INTO FeePayments (payment_id, student_name, amount, payment_date)
        VALUES (5, 'Meena', 6000.00, '2024-06-06');
        INSERT INTO FeePayments (payment_id, student_name, amount, payment_date)
        VALUES (6, NULL, 3000.00, '2024-06-07'); -- This will fail
    COMMIT;
END;

CALL sp_part_c();
DROP PROCEDURE IF EXISTS sp_part_c;



-- STEP 5 — Part D: ACID verification
DROP PROCEDURE IF EXISTS sp_part_d;

CREATE PROCEDURE sp_part_d()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;
        INSERT INTO FeePayments (payment_id, student_name, amount, payment_date)
        VALUES (8, 'Anita', 5200.00, '2024-06-09');
        INSERT INTO FeePayments (payment_id, student_name, amount, payment_date)
        VALUES (1, 'DuplicateAgain', 1000.00, '2024-06-10'); -- This will fail
    COMMIT;
END;

CALL sp_part_d();
DROP PROCEDURE IF EXISTS sp_part_d;

SHOW COLUMNS FROM FeePayments;