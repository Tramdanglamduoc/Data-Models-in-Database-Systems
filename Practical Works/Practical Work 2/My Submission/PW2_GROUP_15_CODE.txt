-- CREATE TABLES

--
CREATE TABLE DIMENSION_1_PATIENT (
    id_d1          NUMBER        PRIMARY KEY,       -- Surrogate key for this dimension table (unique row identifier)
    patient_id     VARCHAR2(50),                    -- Business key: patient’s original ID from the hospital source system
    patient_name   VARCHAR2(150),                   -- Full name of the patient
    gender         VARCHAR2(10),                    -- Patient’s gender
    birthdate      DATE,                            -- Patient’s date of birth
    city           VARCHAR2(50),                    -- City where the patient lives
    insurance_type VARCHAR2(50),                    -- Type of health insurance used by the patient

    start_date     DATE,                            -- SCD Type 2: when this version of the patient record becomes valid
    end_date       DATE,                            -- SCD Type 2: when this version stops being valid
    is_current     CHAR(1)                          -- SCD Type 2 flag: 'Y' = current version, 'N' = historical version
        CHECK (is_current IN ('Y','N'))             -- Constraint: must be either 'Y' or 'N'
);


-- 
CREATE TABLE DIMENSION_2_PHYSICIAN (
    id_d2            NUMBER        PRIMARY KEY,      -- Surrogate key for the physician dimension (unique identifier)
    physician_id     VARCHAR2(50),                   -- Business key: physician’s original ID from the hospital system
    physician_name   VARCHAR2(150),                  -- Full name of the physician
    specialty        VARCHAR2(100),                  -- Physician’s medical specialty (e.g., cardiology, oncology)
    years_experience NUMBER                          -- Total number of years the physician has practiced medicine
);


--
CREATE TABLE DIMENSION_3_DEPARTMENT (
    id_d3               NUMBER        PRIMARY KEY,     -- Surrogate key for the department dimension (unique identifier)
    department_name     VARCHAR2(100),                 -- Name of the hospital department (e.g., Cardiology, Radiology)
    department_category VARCHAR2(50),                  -- Category/type of department (e.g., Clinical, Surgical, Emergency)
    department_address  VARCHAR2(200)                  -- Physical address or location within the hospital campus
);


--
CREATE TABLE DIMENSION_4_TIME (
    id_d4     NUMBER       PRIMARY KEY,   -- Surrogate key for the time dimension (unique identifier)
    full_date DATE,                        -- The full calendar date (e.g., 2025-11-28)
    day       NUMBER,                      -- Day of the month (range: 1–31)
    month     NUMBER,                      -- Month of the year (range: 1–12)
    quarter   NUMBER,                      -- Quarter of the year (range: 1–4)
    year      NUMBER                       -- Year value (e.g., 2025)
);


--
CREATE TABLE DIMENSION_5_DIAGNOSIS (
    id_d5                 NUMBER        PRIMARY KEY,     -- Surrogate key for the diagnosis dimension
    diagnosis_code        VARCHAR2(20),                  -- Diagnosis code (e.g., "E11" for diabetes)
    diagnosis_description VARCHAR2(200),                 -- Text description of the diagnosis
    severity_level        VARCHAR2(20)                   -- Severity category (e.g., high, medium, low)
);


--
CREATE TABLE DIMENSION_6_SERVICE_CATALOG (
    id_d6        NUMBER        PRIMARY KEY,      -- Surrogate key for the service catalog dimension
    service_id   VARCHAR2(50),                   -- Business key: service code from the hospital system
    service_name VARCHAR2(200),                  -- Name of the medical service (e.g., MRI Scan, Blood Test Panel)
    category     VARCHAR2(50),                   -- Category/type of service (e.g., Imaging, Laboratory, Rehab)
    base_price   NUMBER(10,2)                    -- Standard base price for the service before any adjustments
);


--
CREATE TABLE FACT_ENCOUNTER (
    id_d1           NUMBER NOT NULL,      -- FK to Patient dimension (identifies the patient who was admitted)
    id_d2           NUMBER NOT NULL,      -- FK to Physician dimension (doctor responsible)
    id_d3           NUMBER NOT NULL,      -- FK to Department dimension (hospital unit where admission occurred)
    id_d4           NUMBER NOT NULL,      -- FK to Time dimension (date of encounter)
    id_d5           NUMBER NOT NULL,      -- FK to Diagnosis dimension (primary diagnosis)
    id_d6           NUMBER NOT NULL,      -- FK to Service dimension (main service provided)

    total_cost          NUMBER(12,2),     -- Total treatment cost for this encounter
    length_of_stay_days NUMBER,           -- Number of days the patient stayed in hospital - Duration of admission (in days)
    num_diagnoses       NUMBER,           -- Total number of diagnoses recorded for this encounter
    num_services        NUMBER,           -- Total number of services provided during encounter

    readmission_flag    CHAR(1)           -- 'Y' if patient was readmitted, else 'N'
        CHECK (readmission_flag IN ('Y','N')),    -- Validates allowed values

    CONSTRAINT pk_fact_encounter
        PRIMARY KEY (id_d1, id_d2, id_d3, id_d4, id_d5, id_d6),  -- Composite key uniquely identifies each encounter

    CONSTRAINT fk_fact_patient
        FOREIGN KEY (id_d1)
        REFERENCES DIMENSION_1_PATIENT (id_d1),     -- Link to Patient dimension table

    CONSTRAINT fk_fact_physician
        FOREIGN KEY (id_d2)
        REFERENCES DIMENSION_2_PHYSICIAN (id_d2),   -- Link to Physician dimension table

    CONSTRAINT fk_fact_department
        FOREIGN KEY (id_d3)
        REFERENCES DIMENSION_3_DEPARTMENT (id_d3),  -- Link to Department dimension table

    CONSTRAINT fk_fact_time
        FOREIGN KEY (id_d4)
        REFERENCES DIMENSION_4_TIME (id_d4),        -- Link to Time dimension table

    CONSTRAINT fk_fact_diagnosis
        FOREIGN KEY (id_d5)
        REFERENCES DIMENSION_5_DIAGNOSIS (id_d5),   -- Link to Diagnosis dimension table

    CONSTRAINT fk_fact_service
        FOREIGN KEY (id_d6)
        REFERENCES DIMENSION_6_SERVICE_CATALOG (id_d6) -- Link to Service dimension table
);


--
--
--

-- INSERT ... SELECT statements to populate dimension tables

INSERT INTO DIMENSION_1_PATIENT
    (id_d1, patient_id, patient_name, gender, birthdate,
     city, insurance_type, start_date, end_date, is_current)

-- Historical version of P001
SELECT 1, 'P001', 'Anna Ozola', 'F', DATE '1985-03-10',
       'Riga', 'Public',
       DATE '2018-01-01', DATE '2019-12-31', 'N' FROM DUAL

UNION ALL
-- Historical version of P002
SELECT 2, 'P002', 'Janis Kalns', 'M', DATE '1970-08-25',
       'Liepaja', 'Private',
       DATE '2015-01-01', DATE '2018-12-31', 'N' FROM DUAL

UNION ALL
-- Current version of P003
SELECT 3, 'P003', 'Liga Berzina', 'F', DATE '1992-11-15',
       'Jelgava', 'Public',
       DATE '2021-02-10', DATE '2099-12-31', 'Y' FROM DUAL

UNION ALL
-- Current version of P004
SELECT 4, 'P004', 'Marta Vilcane', 'F', DATE '1965-06-02',
       'Riga', 'Private',
       DATE '2018-07-01', DATE '2099-12-31', 'Y' FROM DUAL

UNION ALL
-- Current version of P005
SELECT 5, 'P005', 'Edgars Liepa', 'M', DATE '1999-01-20',
       'Ventspils', 'Public',
       DATE '2022-03-01', DATE '2099-12-31', 'Y' FROM DUAL

UNION ALL
-- Current version of P006
SELECT 6, 'P006', 'Sandra Krume', 'F', DATE '1988-09-09',
       'Daugavpils', 'Private',
       DATE '2020-09-01', DATE '2099-12-31', 'Y' FROM DUAL

UNION ALL
-- Current version of P007
SELECT 7, 'P007', 'Arturs Ozols', 'M', DATE '1978-12-30',
       'Riga', 'Public',
       DATE '2017-01-01', DATE '2099-12-31', 'Y' FROM DUAL

UNION ALL
-- Current version of P008
SELECT 8, 'P008', 'Ilze Jansone', 'F', DATE '2001-05-14',
       'Liepaja', 'Private',
       DATE '2023-01-15', DATE '2099-12-31', 'Y' FROM DUAL

UNION ALL
-- Historical version of P009
SELECT 9, 'P009', 'Karlis Romanovs', 'M', DATE '1980-04-22',
       'Riga', 'Public',
       DATE '2015-01-01', DATE '2020-12-31', 'N' FROM DUAL

UNION ALL
-- Historical version of P010
SELECT 10, 'P010', 'Elina Staltere', 'F', DATE '1995-07-19',
       'Jurmala', 'Private',
       DATE '2018-06-01', DATE '2021-07-15', 'N' FROM DUAL

UNION ALL
-- Current version of P001
SELECT 11, 'P001', 'Anna Ozola', 'F', DATE '1985-03-10',
       'Riga', 'Public',
       DATE '2020-01-01', DATE '2099-12-31', 'Y' FROM DUAL

UNION ALL
-- Current version of P002
SELECT 12, 'P002', 'Janis Kalns', 'M', DATE '1970-08-25',
       'Liepaja', 'Private',
       DATE '2019-01-01', DATE '2099-12-31', 'Y' FROM DUAL

UNION ALL
-- Current version of P009
SELECT 13, 'P009', 'Karlis Romanovs', 'M', DATE '1980-04-22',
       'Riga', 'Public',
       DATE '2021-01-01', DATE '2099-12-31', 'Y' FROM DUAL;

COMMIT;  -- Save inserts permanently
/


--
INSERT INTO DIMENSION_2_PHYSICIAN
    (id_d2, physician_id, physician_name, specialty, years_experience)

-- Insert physician records with specialty and years of experience
SELECT 1, 'DR001', 'Dr. Karlis Ozols',   'Cardiology', 12 FROM DUAL
UNION ALL
SELECT 2, 'DR002', 'Dr. Anna Liepina',   'Orthopedics', 8 FROM DUAL
UNION ALL
SELECT 3, 'DR003', 'Dr. Janis Berzins',  'General Surgery', 15 FROM DUAL
UNION ALL
SELECT 4, 'DR004', 'Dr. Liga Krasta',    'Neurology', 10 FROM DUAL
UNION ALL
SELECT 5, 'DR005', 'Dr. Marta Zieda',    'Internal Medicine', 7 FROM DUAL
UNION ALL
SELECT 6, 'DR006', 'Dr. Edgars Kalns',   'Cardiology', 5 FROM DUAL
UNION ALL
SELECT 7, 'DR007', 'Dr. Ilze Lapa',      'Orthopedics', 11 FROM DUAL
UNION ALL
SELECT 8, 'DR008', 'Dr. Andris Sniegs',  'Emergency Medicine', 4 FROM DUAL;

COMMIT;  -- Save inserts permanently
/


--
INSERT INTO DIMENSION_3_DEPARTMENT
    (id_d3, department_name, department_category, department_address)

-- Insert hospital department info
SELECT 1, 'Cardiology',       'Clinical',  'Main Building, Floor 3' FROM DUAL
UNION ALL
SELECT 2, 'Orthopedics',      'Surgical',  'Surgery Wing, Floor 2' FROM DUAL
UNION ALL
SELECT 3, 'General Surgery',  'Surgical',  'Surgery Wing, Floor 1' FROM DUAL
UNION ALL
SELECT 4, 'Neurology',        'Clinical',  'Neuro Center, Floor 4' FROM DUAL
UNION ALL
SELECT 5, 'Internal Medicine','Clinical',  'Main Building, Floor 2' FROM DUAL
UNION ALL
SELECT 6, 'Emergency',        'Emergency', 'ER Building, Ground Floor' FROM DUAL;

COMMIT;
/


--
INSERT INTO DIMENSION_4_TIME
    (id_d4, full_date, day, month, quarter, year)

-- Insert date hierarchy values for time dimension
SELECT 1, DATE '2025-01-05',  5,  1, 1, 2025 FROM DUAL
UNION ALL
SELECT 2, DATE '2025-01-10', 10,  1, 1, 2025 FROM DUAL
UNION ALL
SELECT 3, DATE '2025-01-20', 20,  1, 1, 2025 FROM DUAL
UNION ALL
SELECT 4, DATE '2025-02-05',  5,  2, 1, 2025 FROM DUAL
UNION ALL
SELECT 5, DATE '2025-02-18', 18,  2, 1, 2025 FROM DUAL
UNION ALL
SELECT 6, DATE '2025-03-02',  2,  3, 1, 2025 FROM DUAL
UNION ALL
SELECT 7, DATE '2025-03-15', 15,  3, 1, 2025 FROM DUAL
UNION ALL
SELECT 8, DATE '2025-04-01',  1,  4, 2, 2025 FROM DUAL
UNION ALL
SELECT 9, DATE '2025-04-10', 10,  4, 2, 2025 FROM DUAL
UNION ALL
SELECT 10, DATE '2025-05-05', 5,  5, 2, 2025 FROM DUAL;

COMMIT;
/


--
INSERT INTO DIMENSION_5_DIAGNOSIS
    (id_d5, diagnosis_code, diagnosis_description, severity_level)

-- Insert diagnosis records mapped to severity levels
SELECT 1, 'I21',  'Acute myocardial infarction', 'High'   FROM DUAL
UNION ALL
SELECT 2, 'I10',  'Essential (primary) hypertension', 'Medium' FROM DUAL
UNION ALL
SELECT 3, 'M16',  'Osteoarthritis of hip', 'Medium' FROM DUAL
UNION ALL
SELECT 4, 'M48',  'Other spondylopathies', 'Low'    FROM DUAL
UNION ALL
SELECT 5, 'J18',  'Pneumonia, unspecified organism', 'High' FROM DUAL
UNION ALL
SELECT 6, 'E11',  'Type 2 diabetes mellitus', 'Medium' FROM DUAL
UNION ALL
SELECT 7, 'K35',  'Acute appendicitis', 'High' FROM DUAL
UNION ALL
SELECT 8, 'S72',  'Fracture of femur', 'High' FROM DUAL;

COMMIT;
/


--
INSERT INTO DIMENSION_6_SERVICE_CATALOG
    (id_d6, service_id, service_name, category, base_price)

-- Insert medical service catalog with base cost
SELECT 1, 'SRV001', 'MRI Scan',             'Imaging',   500.00 FROM DUAL
UNION ALL
SELECT 2, 'SRV002', 'CT Scan',              'Imaging',   450.00 FROM DUAL
UNION ALL
SELECT 3, 'SRV003', 'X-Ray',                'Imaging',   120.00 FROM DUAL
UNION ALL
SELECT 4, 'SRV004', 'Blood Test Panel',     'Laboratory', 80.00 FROM DUAL
UNION ALL
SELECT 5, 'SRV005', 'ECG',                  'Cardiology', 90.00 FROM DUAL
UNION ALL
SELECT 6, 'SRV006', 'Hip Replacement Surgery', 'Surgery', 3000.00 FROM DUAL
UNION ALL
SELECT 7, 'SRV007', 'Appendectomy',         'Surgery',   2200.00 FROM DUAL
UNION ALL
SELECT 8, 'SRV008', 'Physiotherapy Session','Rehab',     70.00 FROM DUAL;

COMMIT;
/

--
--
--

-- Create a PL/SQL procedure to automate the data loading process with INSERT ... SELECT statements to populate fact table

CREATE OR REPLACE PROCEDURE load_fact_encounter AS
BEGIN
    -- Insert newly generated fact records
    -- We use INSERT INTO ... SELECT to automatically populate the fact table.
    -- The subquery builds combinations of valid dimension rows and 
    -- generates realistic random measures for analysis.
    
    INSERT INTO FACT_ENCOUNTER (
        id_d1,
        id_d2,
        id_d3,
        id_d4,
        id_d5,
        id_d6,
        total_cost,
        length_of_stay_days,
        num_diagnoses,
        num_services,
        readmission_flag
    )
    SELECT *
    FROM (
        SELECT
            -- Foreign keys from the dimension tables
            p.id_d1,     -- patient (DIMENSION_1_PATIENT)
            ph.id_d2,    -- physician (DIMENSION_2_PHYSICIAN)
            d.id_d3,     -- department (DIMENSION_3_DEPARTMENT)
            t.id_d4,     -- time (DIMENSION_4_TIME)
            dg.id_d5,    -- diagnosis (DIMENSION_5_DIAGNOSIS)
            s.id_d6,     -- service (DIMENSION_6_SERVICE_CATALOG)

            -- Create measures with some randomness
            -- TRUNC() is used to truncate the random number to an integer
            (s.base_price * TRUNC(DBMS_RANDOM.VALUE(1,4))) AS total_cost,
                -- total_cost = base price × random multiplier between 1–3

            TRUNC(DBMS_RANDOM.VALUE(1,15)) AS length_of_stay_days,
                -- random length of stay between 1 and 14 days
            
            TRUNC(DBMS_RANDOM.VALUE(1,4)) AS num_diagnoses,
                -- random number of diagnoses between 1 and 3
            
            TRUNC(DBMS_RANDOM.VALUE(1,5)) AS num_services,
                -- random number of services between 1 and 4

            -- Readmission indicator
            CASE
                WHEN DBMS_RANDOM.VALUE(0,1) > 0.8 THEN 'Y'
                ELSE 'N'
            END AS readmission_flag
                -- ~20% of admissions are marked as readmissions

        -- Join logic 
        FROM DIMENSION_1_PATIENT p
             JOIN DIMENSION_4_TIME t
               ON t.full_date BETWEEN p.start_date AND p.end_date
               -- Only generate encounters during the active SCD period of the patient

             JOIN DIMENSION_2_PHYSICIAN ph
               ON 1 = 1      -- behaves as a CROSS JOIN (all doctors available)

             JOIN DIMENSION_3_DEPARTMENT d
               ON ( (ph.specialty = 'Cardiology'         AND d.department_name = 'Cardiology')
                 OR (ph.specialty = 'Orthopedics'        AND d.department_name = 'Orthopedics')
                 OR (ph.specialty = 'Neurology'          AND d.department_name = 'Neurology')
                 OR (ph.specialty = 'Internal Medicine'  AND d.department_name = 'Internal Medicine')
                 OR (ph.specialty = 'Emergency Medicine' AND d.department_name = 'Emergency')
                  )
               -- Ensures each doctor is assigned only to the matching department

             JOIN DIMENSION_5_DIAGNOSIS dg
               ON ( (d.department_name = 'Cardiology'  AND dg.diagnosis_code IN ('I21','I10'))
                 OR (d.department_name = 'Orthopedics' AND dg.diagnosis_code IN ('M16','S72'))
                 OR (d.department_name = 'General Surgery' AND dg.diagnosis_code IN ('K35','S72'))
                 OR (d.department_name = 'Neurology'  AND dg.diagnosis_code IN ('M48'))
                 OR (d.department_name = 'Internal Medicine' AND dg.diagnosis_code IN ('E11','J18','I10'))
                 OR (d.department_name = 'Emergency'  AND dg.diagnosis_code IN ('I21','J18','K35','S72'))
                  )
               -- Restrict diagnosis to realistic options for each department
            
             JOIN DIMENSION_6_SERVICE_CATALOG s
               ON (
                     -- Cardiology: ECG, imaging, blood tests
                     (d.department_name = 'Cardiology'
                      AND s.service_name IN ('ECG','MRI Scan','CT Scan','Blood Test Panel'))

                  OR -- Orthopedics: imaging, surgery, physio
                     (d.department_name = 'Orthopedics'
                      AND s.service_name IN ('X-Ray','MRI Scan',
                                             'Hip Replacement Surgery','Physiotherapy Session'))

                  OR -- General Surgery: appendectomy, imaging, blood tests
                     (d.department_name = 'General Surgery'
                      AND s.service_name IN ('Appendectomy','CT Scan','X-Ray','Blood Test Panel'))

                  OR -- Neurology: imaging, blood tests
                     (d.department_name = 'Neurology'
                      AND s.service_name IN ('MRI Scan','CT Scan','Blood Test Panel'))

                  OR -- Internal Medicine: imaging + basic tests + ECG
                     (d.department_name = 'Internal Medicine'
                      AND s.service_name IN ('MRI Scan','CT Scan','X-Ray','Blood Test Panel','ECG'))

                  OR -- Emergency: almost everything
                     (d.department_name = 'Emergency'
                      AND s.service_name IN ('MRI Scan','CT Scan','X-Ray',
                                             'Blood Test Panel','ECG',
                                             'Appendectomy','Physiotherapy Session'))
                  )

        WHERE p.is_current = 'Y'
            -- Only use current SCD versions for generating encounters

        ORDER BY DBMS_RANDOM.VALUE
            -- Shuffle rows so the first 60 chosen by ROWNUM are random
    ) src
    WHERE ROWNUM <= 60;
        -- Limit output to 60 fact rows

    COMMIT;
        -- Save changes to the database
END;
/

--
-- Run procedure to populate data in Fact Table FACT_ENCOUNTER
BEGIN 
   load_fact_encounter; 
END; 
/



--
--
--

-- 
-- ROLLUP / CUBE queries (8 points, 2 each)
-- Four meaningful queries using ROLLUP, CUBE, or GROUPING SETS to perform multi-level aggregation

-- CUBE
-- Calculate the average length of stay by department, by diagnosis,
-- by the combination of department + diagnosis, and for all encounters.
SELECT
    d.department_name,                         -- Hospital department (e.g., Cardiology, Orthopedics)
    dg.diagnosis_description AS primary_diagnosis, -- Primary diagnosis description
    AVG(f.length_of_stay_days) AS avg_length_of_stay -- Average number of days per group
FROM FACT_ENCOUNTER f
JOIN DIMENSION_3_DEPARTMENT d 
    ON f.id_d3 = d.id_d3                       -- Link each encounter to its department
JOIN DIMENSION_5_DIAGNOSIS dg
    ON f.id_d5 = dg.id_d5                      -- Link each encounter to its primary diagnosis
-- Use CUBE to generate all combinations of the two dimensions:
-- 1) department + diagnosis
-- 2) department only
-- 3) diagnosis only
-- 4) grand total (all departments and diagnoses)
GROUP BY CUBE (d.department_name, dg.diagnosis_description)
-- Sort output by department name and diagnosis description ascendingly
ORDER BY d.department_name, dg.diagnosis_description;

--
-- ROLLUP
-- Calculate the total and average treatment cost and the number of admissions per physician and diagnosis,
-- compare each physician’s average cost with the overall diagnosis-level average, 
-- label it as above/below/at the diagnosis average, 
-- and include subtotals and the grand total
SELECT
    dg.diagnosis_description,
    ph.physician_name,

    -- Total treatment cost per doctor for each diagnosis
    SUM(f.total_cost) AS total_cost,

    -- Average treatment cost per doctor for each diagnosis
    AVG(f.total_cost) AS average_cost,

    -- Workload: total number of patients' admissions handled by the doctor
    COUNT(*) AS total_admissions,

    -- Diagnosis-level: - 
    -- average treatment cost across all doctors for this diagnosis
    -- 
    AVG(AVG(f.total_cost)) OVER (
        PARTITION BY dg.diagnosis_description
    ) AS diagnosis_average_cost,


    -- Comparison label 'cost_position_within_diagnosis'
    -- indicates whether this doctor's average cost is above,
    -- below, or equal to the diagnosis-level average
    
    -- If this doctor's average treatment cost for the diagnosis
    -- is greater than the overall average cost for that diagnosis
    CASE
        WHEN AVG(f.total_cost) >
             AVG(AVG(f.total_cost)) OVER (PARTITION BY dg.diagnosis_description)
            THEN 'Above diagnosis average'
    -- If this doctor's average treatment cost for the diagnosis
        -- is less than the overall diagnosis-level average cost
        WHEN AVG(f.total_cost) <
             AVG(AVG(f.total_cost)) OVER (PARTITION BY dg.diagnosis_description)
            THEN 'Below diagnosis average'
    -- If neither greater nor less (i.e., equal or very close),
    -- we label it as being at the diagnosis average
        ELSE 'At diagnosis average'
    END AS cost_position_within_diagnosis

FROM FACT_ENCOUNTER f
JOIN DIMENSION_5_DIAGNOSIS dg ON f.id_d5 = dg.id_d5
JOIN DIMENSION_2_PHYSICIAN ph ON f.id_d2 = ph.id_d2

-- Aggregation: detailed rows and subtotals by diagnosis and physician
GROUP BY ROLLUP (dg.diagnosis_description, ph.physician_name)

ORDER BY dg.diagnosis_description, ph.physician_name;
/

--
-- GROUPING SETS
-- Calculate the total admissions, total 30-day readmissions, and readmission rate 
-- by department and quarter, by department and month, by department, by hospital-wide quarter, by hospital-wide month, and for all encounters 
SELECT
    -- Department dimension
    d.department_name,

    -- Time dimension: year is included to avoid mixing months/quarters across years
    t.year,
    t.quarter,
    t.month,

    -- Total number of encounters (admissions)
    COUNT(*) AS total_admissions,

    -- Number of encounters that are readmissions within 30 days
    SUM(CASE WHEN f.readmission_flag = 'Y' THEN 1 ELSE 0 END) AS total_readmissions,

    -- Readmission rate = (#readmissions / #admissions) * 100
    ROUND(100 * SUM(CASE WHEN f.readmission_flag = 'Y' THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0),
        2) AS readmission_rate

FROM FACT_ENCOUNTER f
JOIN DIMENSION_3_DEPARTMENT d
    ON f.id_d3 = d.id_d3
JOIN DIMENSION_4_TIME t
    ON f.id_d4 = t.id_d4

GROUP BY GROUPING SETS (
    -- 1) Department × Quarter trend (main analysis)
    (d.department_name, t.year, t.quarter),

    -- 2) Department × Month trend
    (d.department_name, t.year, t.month),

    -- 3) Department summary across all time
    (d.department_name),

    -- 4) Quarterly hospital-wide trend (all departments)
    (t.year, t.quarter),

    -- 5) Monthly hospital-wide trend (all departments)
    (t.year, t.month),

    -- 6) Grand total
    ()
)

ORDER BY
    d.department_name NULLS LAST, 
    t.year,
    t.quarter,
    t.month;
/

-- 
-- ROLLUP
-- Calculate the total treatment cost, number of admissions, and average cost per admission 
-- by department and quarter, by department and year, by department overall, and for all encounters
-- Department treatment cost trend by quarter using ROLLUP
SELECT
    -- Dimension: Department
    d.department_name,
    -- Dimension: Time (year + quarter to avoid mixing different years)
    t.year,
    t.quarter,

    -- Total treatment cost per group
    SUM(f.total_cost) AS total_treatment_cost,

    -- Total admissions per group 
    COUNT(*) AS total_admissions,

    -- Average treatment cost per admission 
    ROUND(SUM(f.total_cost) / NULLIF(COUNT(*), 0),
        2) AS average_cost_per_admission

FROM FACT_ENCOUNTER f
JOIN DIMENSION_3_DEPARTMENT d
    ON f.id_d3 = d.id_d3
JOIN DIMENSION_4_TIME t
    ON f.id_d4 = t.id_d4

-- Multi-level aggregation with ROLLUP:
-- (department, year, quarter)
-- (department, year)       -- subtotal per department-year
-- (department)             -- subtotal per department (all years)
-- ()                       -- grand total for the hospital
GROUP BY ROLLUP (
    d.department_name,
    t.year,
    t.quarter
)

ORDER BY
    d.department_name NULLS LAST,
    t.year,
    t.quarter;
/


--
--
--

-- PL/SQL Functions (8 points, 4 each) 

-- Write two meaningful queries that answer non-trivial business questions by 
-- combining techniques (e.g., a window function inside a CUBE query, or a PL/SQL 
-- function used in a GROUP BY). 

-- Demonstrate the use of at least one of these functions within one of your main 
-- analytical queries (e.g., in the SELECT list or GROUP BY clause). 

--
-- PL/SQL function to convert a patient's birthdate and encounter date
-- into a categorical age group (Child, Adult, Middle-aged, Senior).
CREATE OR REPLACE FUNCTION get_age_group(
    -- Patient's date of birth
    p_birthdate IN DATE,
    -- Date of the encounter (from the Time dimension)
    p_full_date IN DATE
) RETURN VARCHAR2
IS
    -- Calculated age in full years at the encounter date
    v_age_years  NUMBER;
    -- Resulting age group label to be returned by the function
    v_age_group  VARCHAR2(20);
BEGIN
    -- Calculate age in full years at the encounter date.
    -- MONTHS_BETWEEN which is Built-in Oracle function, returns the number of months between two dates.
    -- Dividing by 12 converts months to years.
    -- FLOOR rounds the value down to the nearest whole number, removes the decimal part to get completed years only. 
    v_age_years := FLOOR(MONTHS_BETWEEN(p_full_date, p_birthdate) / 12);

    -- Map the numeric age to a textual age group.
    -- This allows analyses to work with groups instead of raw ages.
    IF v_age_years < 18 THEN
        v_age_group := 'Child';
    ELSIF v_age_years BETWEEN 18 AND 44 THEN
        v_age_group := 'Adult';
    ELSIF v_age_years BETWEEN 45 AND 64 THEN
        v_age_group := 'Middle-aged';
    ELSE
        -- Age 65 and above is classified as Senior
        v_age_group := 'Senior';
    END IF;

    -- Return the age group label to the caller (SQL query)
    RETURN v_age_group;
END;
/


-- Demonstrate the use of function 
-- Analytical query using get_age_group to analyze average cost and
-- average length of stay by age group and department
SELECT
    -- Use the custom PL/SQL function to derive an age group
    -- from the patient's birthdate and the encounter date.
    get_age_group(p.birthdate, t.full_date) AS age_group,

    -- Name of the department responsible for the encounter
    d.department_name,

    -- Average treatment cost per (age_group, department) combination
    AVG(f.total_cost)          AS average_total_cost,

    -- Average length of stay in days per (age_group, department) combination
    AVG(f.length_of_stay_days) AS average_length_of_stay

FROM FACT_ENCOUNTER f
    -- Join to the Patient dimension to access the birthdate
    JOIN DIMENSION_1_PATIENT     p ON f.id_d1 = p.id_d1
    -- Join to the Department dimension to know which department treated the patient
    JOIN DIMENSION_3_DEPARTMENT  d ON f.id_d3 = d.id_d3
    -- Join to the Time dimension to get the full encounter date
    JOIN DIMENSION_4_TIME        t ON f.id_d4 = t.id_d4

GROUP BY
    get_age_group(p.birthdate, t.full_date),
    d.department_name;
/


--
-- PL/SQL function that assigns a readmission risk label
-- based on three input factors: readmission flag, diagnosis severity, length of stay in days
CREATE OR REPLACE FUNCTION get_readmission_risk(
    p_readmission_flag IN CHAR,       -- input: 'Y' if patient was readmitted ('Y' or 'N')
    p_severity_level   IN VARCHAR2,   -- input: severity classification of diagnosis ('High', 'Medium', 'Low')
    p_los              IN NUMBER      -- input: length of stay (number of days)
) RETURN VARCHAR2
IS
    -- Resulting risk label that will be returned
    v_risk_label VARCHAR2(30);
BEGIN
    -- Case 1:
    -- If the patient was readmitted AND had a High-severity diagnosis,
    -- they are considered the highest risk.
    IF p_readmission_flag = 'Y' AND p_severity_level = 'High' THEN
        v_risk_label := 'High risk';

    -- Case 2:
    -- If readmitted but severity is Medium or Low,
    -- treat as Medium risk.
    ELSIF p_readmission_flag = 'Y'
       AND p_severity_level IN ('Medium', 'Low') THEN
        v_risk_label := 'Medium risk';

    -- Case 3:
    -- If the patient was NOT readmitted, but:
    -- stayed in the hospital for more than 10 days
    -- and had a High severity diagnosis,
    -- then classify as "Medium risk (long stay)".
    ELSIF p_readmission_flag = 'N'
       AND p_los > 10
       AND p_severity_level = 'High' THEN
        v_risk_label := 'Medium risk (long stay)';

    -- All other situations are considered low risk.
    ELSE
        v_risk_label := 'Low risk';
    END IF;

    RETURN v_risk_label;
END;
/

-- Demonstrate the use of function 
-- Analytical query using get_readmission_risk to classify encounters into risk bands
-- and count the number of encounters per department and risk band (with subtotals and grand total)
SELECT
    d.department_name,
    get_readmission_risk(
        f.readmission_flag,
        dg.severity_level,
        f.length_of_stay_days
    ) AS risk_band,

    -- Count how many encounters fall into each (department, risk_band)
    COUNT(*) AS num_encounters

FROM FACT_ENCOUNTER f

-- Join to Department dimension to show department_name
JOIN DIMENSION_3_DEPARTMENT d 
    ON f.id_d3 = d.id_d3

-- Join to Diagnosis dimension to access severity_level
JOIN DIMENSION_5_DIAGNOSIS dg 
    ON f.id_d5 = dg.id_d5

-- Group by department and the function result
    -- Detail rows: (department_name, risk_band)
    -- Subtotals:   (department_name, NULL)
    -- Grand total: (NULL, NULL
GROUP BY ROLLUP (
    d.department_name,
    get_readmission_risk(
        f.readmission_flag,
        dg.severity_level,
        f.length_of_stay_days
    )
);
/


--
-- PL/SQL function to compare actual total_cost with the expected cost
-- based on service base_price and the number of services.
-- It returns the percentage difference between actual and baseline cost.
CREATE OR REPLACE FUNCTION compare_cost_with_baseprice(
    p_total_cost  IN NUMBER,  -- actual total cost from FACT_ENCOUNTER
    p_base_price  IN NUMBER,  -- base price per service from DIMENSION_6_SERVICE_CATALOG
    p_num_services IN NUMBER  -- number of services for this encounter (from FACT_ENCOUNTER)
) RETURN NUMBER
IS
    v_baseline_cost   NUMBER;     
    -- Baseline cost represents the "expected" cost according to the service catalog.
    v_diff_percentage NUMBER;
    -- The percentage difference between actual total cost and the baseline cost.
    -- Positive = actual total cost is more expensive than baseline cost.
    -- Negative = actual total cost is cheaper than baseline cost.

BEGIN
    -- Compute the expected baseline cost:
    -- baseline = base_price * num_services
    v_baseline_cost := p_base_price * p_num_services;

    -- If the baseline cost is zero or NULL, avoid division by zero.
    -- In that case, just return NULL.
    IF v_baseline_cost IS NULL OR v_baseline_cost = 0 THEN
        RETURN NULL;
    END IF;

    -- Calculate percentage difference:
    -- (actual - baseline) / baseline * 100
    v_diff_percentage :=
        (p_total_cost - v_baseline_cost)
        / v_baseline_cost * 100;

    RETURN v_diff_percentage;
END;
/


-- Demonstrate the use of function
-- Analytical query using compare_cost_with_baseprice to evaluate how actual treatment costs
-- deviate (in %) from baseline service catalog prices by department, quarter, and physician
-- (with CUBE subtotals and grand total) 
SELECT
    -- The department responsible for the encounter
    d.department_name,

    -- Quarter of the encounter (Q1, Q2, Q3, Q4)
    t.quarter,

    -- The physician who treated the patient
    ph.physician_name,

    -- Calculate the average percentage difference between
    -- actual total_cost and the baseline service cost.
    -- This uses the custom PL/SQL function compare_cost_with_baseprice.
    AVG(
        compare_cost_with_baseprice(
            f.total_cost,   -- actual treatment cost from the fact table
            s.base_price,   -- service base price from the service catalog
            f.num_services  -- number of services used in this encounter
        )
    ) AS average_cost_difference_percentage
FROM FACT_ENCOUNTER f

-- Join the Department dimension to get department_name
JOIN DIMENSION_3_DEPARTMENT d
    ON f.id_d3 = d.id_d3

-- Join the Physician dimension to show which physician performed the encounter
JOIN DIMENSION_2_PHYSICIAN ph
    ON f.id_d2 = ph.id_d2

-- Join the Time dimension to know which quarter the encounter happened in
JOIN DIMENSION_4_TIME t
    ON f.id_d4 = t.id_d4

-- Join the Service Catalog to get the base price for each service
JOIN DIMENSION_6_SERVICE_CATALOG s
    ON f.id_d6 = s.id_d6

-- Group by all combinations of (department, quarter, physician)
GROUP BY CUBE (
    d.department_name,
    t.quarter,
    ph.physician_name
);
/


--
-- PL/SQL function to classify a physician's workload
-- based on the number of encounters they handled.
CREATE OR REPLACE FUNCTION get_workload_band(
    p_encounter_count IN NUMBER  -- total number of encounters for a physician
) RETURN VARCHAR2
IS
    -- Text label describing the workload band
    v_workload_band VARCHAR2(20);
BEGIN
    -- If the physician handled 10 or fewer encounters → Low workload
    IF p_encounter_count <= 10 THEN
        v_workload_band := 'Low workload';

    -- If the physician handled between 11 and 20 encounters → Medium workload
    ELSIF p_encounter_count BETWEEN 11 AND 20 THEN
        v_workload_band := 'Medium workload';

    -- If the physician handled more than 20 encounters → High workload
    ELSE
        v_workload_band := 'High workload';
    END IF;

    -- Return the workload band label
    RETURN v_workload_band;
END;
/

-- Demonstrate the use of function 
-- Analytical query using get_workload_band to group physicians by workload band
-- and report how many physicians and total encounters fall into each workload category
SELECT
    -- Classify physicians into workload bands using the function
    get_workload_band(encounters.encounters_count) AS workload_band,

    -- Number of physicians in this workload band
    COUNT(*) AS number_of_physicians,

    -- Total encounters handled by all physicians in this band
    SUM(encounters.encounters_count) AS total_encounters
FROM (
    -- Subquery: count encounters per physician
    SELECT
        ph.physician_name,
        COUNT(*) AS encounters_count     -- total encounters for this physician
    FROM FACT_ENCOUNTER f
    JOIN DIMENSION_2_PHYSICIAN ph
        ON f.id_d2 = ph.id_d2
    GROUP BY ph.physician_name
) encounters
GROUP BY
    get_workload_band(encounters.encounters_count);


--
-- Demonstrate the use of the MODEL clause for complex spreadsheet-like calculations. 

-- Simulate a what-if scenario using the Oracle MODEL clause at the department–month–year level: 
-- calculate total admissions, total readmissions, total treatment cost, the current readmission rate, 
-- and then recompute readmissions, admissions, and total cost after a hypothetical 10% reduction in readmissions

-- Readmission reduction scenario using MODEL 
SELECT
    -- Dimensions and measures returned to the user
    department_name,
    month_number,
    year_number,
    total_admissions,
    total_readmissions,
    total_treatment_cost,
    readmission_rate,
    scenario_readmissions,
    scenario_total_admissions,
    scenario_total_cost
FROM (
    -- Aggregate data at the Department–Month–Year level
    SELECT
        d.department_name      AS department_name,   -- department (e.g., Cardiology)
        t.month                AS month_number,      -- month number from time dimension
        t.year                 AS year_number,       -- year from time dimension
        COUNT(*)               AS total_admissions,  -- total number of admissions in this dept-month-year
        SUM(CASE
                WHEN f.readmission_flag = 'Y'        -- if encounter is a readmission
                THEN 1
                ELSE 0
            END) AS total_readmissions,              -- total number of readmissions
        SUM(f.total_cost)      AS total_treatment_cost  -- total treatment cost for this dept-month-year
    FROM FACT_ENCOUNTER f
    JOIN DIMENSION_3_DEPARTMENT d
        ON f.id_d3 = d.id_d3
    JOIN DIMENSION_4_TIME t
        ON f.id_d4 = t.id_d4
    GROUP BY
        d.department_name,
        t.year,
        t.month
)
-- Use MODEL to do spreadsheet-like what-if calculations
MODEL
    -- PARTITION BY: each year is treated as a separate "sheet"
    PARTITION BY (year_number)

    -- DIMENSION BY: rows and columns of the "sheet"
    --   - department_name: row identifier
    --   - month_number:    column identifier (within a year)
    DIMENSION BY (department_name, month_number)

    -- MEASURES: numeric values stored in each cell of the sheet
    MEASURES (
        total_admissions,          -- base measure: total admissions
        total_readmissions,        -- base measure: total readmissions
        total_treatment_cost,      -- base measure: total cost

        -- derived measures (initially NULL; will be filled by RULES)
        CAST(NULL AS NUMBER) AS readmission_rate,          -- current readmission rate
        CAST(NULL AS NUMBER) AS scenario_readmissions,     -- readmissions after a 10% reduction
        CAST(NULL AS NUMBER) AS scenario_total_admissions, -- total admissions in the scenario
        CAST(NULL AS NUMBER) AS scenario_total_cost        -- total cost in the scenario
    )

    -- RULES: formulas that compute the derived measures for each cell
    RULES (
        -- Rule 1: Current readmission rate for each department–month–year
        --   readmission_rate = total_readmissions / total_admissions
        --   NVL(..., 0) avoids NULL when there are no readmissions
        --   NULLIF(..., 0) avoids division by zero when there are no admissions
        readmission_rate[ANY, ANY] =
            NVL(total_readmissions[CV(department_name), CV(month_number)], 0)
            / NULLIF(total_admissions[CV(department_name), CV(month_number)], 0),

        -- Rule 2: Scenario – reduce readmissions by 10%
        --   scenario_readmissions = 90% of current readmissions
        scenario_readmissions[ANY, ANY] = TRUNC(total_readmissions[CV(department_name), CV(month_number)] * 0.9),

        -- Rule 3: New total admissions after reducing readmissions
        --   We assume each avoided readmission removes one admission from the total
        --   reduction = total_readmissions - scenario_readmissions
        --   scenario_total_admissions = total_admissions - reduction
        scenario_total_admissions[ANY, ANY] =
            total_admissions[CV(department_name), CV(month_number)]
            - (total_readmissions[CV(department_name), CV(month_number)]
                - scenario_readmissions[CV(department_name), CV(month_number)]),

        -- Rule 4: New total cost in the scenario
        --   Assume each avoided readmission saves 500 cost units
        --   reduction = total_readmissions - scenario_readmissions
        --   scenario_total_cost = total_treatment_cost - reduction * 500
        scenario_total_cost[ANY, ANY] =
            total_treatment_cost[CV(department_name), CV(month_number)]
            - (total_readmissions[CV(department_name), CV(month_number)]
                - scenario_readmissions[CV(department_name), CV(month_number)]) * 500
    );


--
--
--
-- Write the DDL: Provide the CREATE TABLE statement for this new aggregate table

-- Monthly department performance summary
CREATE TABLE AGG_DEPT_MONTHLY_STATS (
    id_d3               NUMBER NOT NULL,      -- Department surrogate key
    year                NUMBER NOT NULL,      -- Year from DIMENSION_4_TIME
    month               NUMBER NOT NULL,      -- Month from DIMENSION_4_TIME

    total_admissions    NUMBER,              -- Total number of encounters in the month
    total_treatment_cost NUMBER,            -- Sum of total_cost for the month
    avg_cost_per_admission NUMBER,      -- Average cost per admission for the month
  
-- Composite primary key: each (department, year, month) is unique
    CONSTRAINT pk_agg_dept_month PRIMARY KEY (id_d3, year, month)
);

-- It guarantees that id_d3 in the aggregate table always matches a real department.
ALTER TABLE AGG_DEPT_MONTHLY_STATS
ADD CONSTRAINT fk_agg_dept_month_dept
    FOREIGN KEY (id_d3)
    REFERENCES DIMENSION_3_DEPARTMENT(id_d3);

	
--
--
--

-- Write a Sample Query: Write one analytical query 
-- that would run on your new, small aggregate table to get the answer 
-- Fast dashboard query using the aggregate table
SELECT
    d.department_name,         -- department name from dimension table
    a.year,                               -- aggregated year
    a.month,                            -- aggregated month
    a.total_treatment_cost,     -- pre-calculated total cost
    a.total_admissions,           -- pre-calculated admissions
    a.avg_cost_per_admission     -- pre-calculated average cost
FROM AGG_DEPT_MONTHLY_STATS a
JOIN DIMENSION_3_DEPARTMENT d
    ON a.id_d3 = d.id_d3           
ORDER BY d.department_name, a.year, a.month;
/


--
--
--

-- Implement a Population Procedure: Create a simple PL/SQL procedure that 
-- TRUNCATEs (empties) and then INSERT...SELECT...GROUP BYs to populate your 
-- new aggregate table with fresh data from the main fact table
CREATE OR REPLACE PROCEDURE populate_agg_dept_monthly AS
BEGIN
    -- Empty the aggregate table before repopulating
    EXECUTE IMMEDIATE 'TRUNCATE TABLE AGG_DEPT_MONTHLY_STATS';

    -- Insert summarized data from the fact table
    -- Grouping by department + year + month
    INSERT INTO AGG_DEPT_MONTHLY_STATS (
        id_d3,
        year,
        month,
        total_admissions,
        total_treatment_cost,
        avg_cost_per_admission
    )
    SELECT
        f.id_d3,                   -- department surrogate key
        t.year,                    -- year from time dimension
        t.month,                   -- month from time dimension
        COUNT(*) AS total_admissions,     -- number of encounters
        SUM(f.total_cost) AS total_treatment_cost,    -- total cost
        ROUND(AVG(f.total_cost), 2) AS avg_cost_per_admission    -- avg cost
    FROM FACT_ENCOUNTER f
    JOIN DIMENSION_4_TIME t
        ON f.id_d4 = t.id_d4       -- linking encounter to time dimension
    GROUP BY
        f.id_d3,
        t.year,
        t.month;                         -- one row per department, year and month

    COMMIT;
END;
/

EXEC populate_agg_dept_monthly;
/

--
--
--

-- Demonstrate Performance Gain: Use the EXPLAIN PLAN FOR ... command on 
-- both your "slow" query (against the main fact table) and your "fast" query (against the aggregate table)


-- Slow Query (runs on full FACT_ENCOUNTER table) 
--  It scans all encounters, joins 2 dimension and aggregates data at runtime
EXPLAIN PLAN FOR
SELECT
    d.department_name,
    t.year,
    t.month,
    SUM(f.total_cost) AS total_treatment_cost,    -- compute at runtime
    COUNT(*) AS total_admissions                      -- compute at runtime
FROM FACT_ENCOUNTER f
JOIN DIMENSION_3_DEPARTMENT d
    ON f.id_d3 = d.id_d3                                         -- join to department
JOIN DIMENSION_4_TIME t
    ON f.id_d4 = t.id_d4                                        -- join to time
GROUP BY
    d.department_name,
    t.year,
    t.month
ORDER BY
    d.department_name,
    t.year,
    t.month;

-- Display the explain plan
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
/

 -- Fast Query (runs on AGG DEPT MONTHLY table)
EXPLAIN PLAN FOR
SELECT
    d.department_name,
    a.year,
    a.month,
    a.total_treatment_cost,
    a.total_admissions,
    a.avg_cost_per_admission
FROM AGG_DEPT_MONTHLY_STATS a
JOIN DIMENSION_3_DEPARTMENT d
    ON a.id_d3 = d.id_d3
ORDER BY
    d.department_name,
    a.year,
    a.month;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
/