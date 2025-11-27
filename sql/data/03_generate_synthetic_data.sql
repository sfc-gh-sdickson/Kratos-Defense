-- ============================================================================
-- Kratos Defense Intelligence Agent - Synthetic Data Generation
-- ============================================================================
-- Purpose: Generate realistic sample data for defense contractor operations
-- Volume: ~5K employees, 500 programs, 300 contracts, 1K assets, 200 suppliers
-- Syntax: Verified against Snowflake SQL Reference
--
-- CRITICAL RULES FROM LESSONS LEARNED:
-- 1. UNIFORM(min, max, RANDOM()) - min and max MUST be constant literals
-- 2. SEQ4() - ONLY valid with TABLE(GENERATOR(...))
-- 3. Use ROW_NUMBER() OVER (ORDER BY ...) for non-generator contexts
-- 4. GENERATOR(ROWCOUNT => n) - n must be constant integer literal
-- 5. Status fields MUST have varied distributions for useful analytics
-- ============================================================================

USE DATABASE KRATOS_INTELLIGENCE;
USE SCHEMA RAW;
USE WAREHOUSE KRATOS_WH;

-- ============================================================================
-- Step 1: Generate Divisions
-- ============================================================================
INSERT INTO DIVISIONS VALUES
('DIV001', 'UNMANNED', 'Unmanned Systems', 'CORE', 'Development and production of unmanned aerial, ground, and maritime systems for defense applications. Specializes in target drones, tactical UAVs, and autonomous vehicles.', 'San Diego, CA', 2500, 850000000.00, 'U.S. Department of Defense', 'SECRET', TRUE, '1994-01-15', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('DIV002', 'SPACE', 'Space & Satellite Systems', 'CORE', 'Design and manufacture of satellite systems, launch vehicles, and space-related technologies. Focus on communications, surveillance, and weather satellites.', 'Colorado Springs, CO', 1800, 650000000.00, 'U.S. Space Force', 'TOP SECRET', TRUE, '1998-06-01', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('DIV003', 'MICROWAVE', 'Microwave Electronics', 'SPECIALTY', 'High-power microwave systems, electronic warfare solutions, and radar components. Industry leader in directed energy weapons technology.', 'Huntsville, AL', 1200, 420000000.00, 'U.S. Army', 'SECRET', TRUE, '2002-03-10', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('DIV004', 'TURBINE', 'Turbine Technologies', 'SPECIALTY', 'Development and production of jet engines, turbine components, and propulsion systems for military and commercial applications.', 'Phoenix, AZ', 900, 380000000.00, 'U.S. Air Force', 'SECRET', TRUE, '2005-08-22', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('DIV005', 'DEFENSE', 'Defense & Rocket Support', 'SPECIALTY', 'Missile defense systems, rocket motor manufacturing, and ballistic missile targets for testing and evaluation.', 'Sacramento, CA', 1100, 520000000.00, 'Missile Defense Agency', 'TOP SECRET', TRUE, '2000-11-05', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('DIV006', 'TRAINING', 'Training Solutions', 'SUPPORT', 'Live, virtual, and constructive training systems. Simulation technologies and training services for military readiness.', 'Orlando, FL', 650, 180000000.00, 'U.S. Armed Forces', 'UNCLASSIFIED', TRUE, '2010-04-18', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('DIV007', 'C5ISR', 'C5ISR Systems', 'CORE', 'Command, Control, Communications, Computers, Cyber, Intelligence, Surveillance, and Reconnaissance systems integration.', 'Washington, DC', 2100, 720000000.00, 'U.S. Intelligence Community', 'TOP SECRET/SCI', TRUE, '2008-09-01', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('DIV008', 'LOGISTICS', 'Logistics & Sustainment', 'SUPPORT', 'Supply chain management, depot maintenance, and sustainment services for defense platforms and systems.', 'San Antonio, TX', 800, 290000000.00, 'Defense Logistics Agency', 'SECRET', TRUE, '2012-02-28', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP());

-- ============================================================================
-- Step 2: Generate Employees
-- ============================================================================
INSERT INTO EMPLOYEES
SELECT
    'EMP' || LPAD(SEQ4(), 6, '0') AS employee_id,
    ARRAY_CONSTRUCT('James', 'John', 'Robert', 'Michael', 'William', 'David', 'Richard', 'Joseph', 'Thomas', 'Charles',
                    'Mary', 'Patricia', 'Jennifer', 'Linda', 'Barbara', 'Elizabeth', 'Susan', 'Jessica', 'Sarah', 'Karen',
                    'Christopher', 'Daniel', 'Matthew', 'Anthony', 'Mark', 'Donald', 'Steven', 'Paul', 'Andrew', 'Joshua',
                    'Ashley', 'Kimberly', 'Emily', 'Donna', 'Michelle', 'Dorothy', 'Amanda', 'Melissa', 'Stephanie', 'Nicole')[UNIFORM(0, 39, RANDOM())] AS first_name,
    ARRAY_CONSTRUCT('Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez',
                    'Wilson', 'Anderson', 'Taylor', 'Thomas', 'Moore', 'Jackson', 'Martin', 'Lee', 'Thompson', 'White',
                    'Harris', 'Clark', 'Lewis', 'Robinson', 'Walker', 'Young', 'Allen', 'King', 'Wright', 'Lopez')[UNIFORM(0, 29, RANDOM())] AS last_name,
    'employee' || SEQ4() || '@kratos-defense.com' AS email,
    CONCAT('+1-', LPAD(UNIFORM(200, 999, RANDOM()), 3, '0'), '-', LPAD(UNIFORM(100, 999, RANDOM()), 3, '0'), '-', LPAD(UNIFORM(1000, 9999, RANDOM()), 4, '0')) AS phone,
    DATEADD('day', -1 * UNIFORM(365, 7300, RANDOM()), CURRENT_DATE()) AS hire_date,
    CASE UNIFORM(0, 15, RANDOM())
        WHEN 0 THEN 'Systems Engineer'
        WHEN 1 THEN 'Software Engineer'
        WHEN 2 THEN 'Mechanical Engineer'
        WHEN 3 THEN 'Electrical Engineer'
        WHEN 4 THEN 'Program Manager'
        WHEN 5 THEN 'Project Engineer'
        WHEN 6 THEN 'Quality Engineer'
        WHEN 7 THEN 'Manufacturing Engineer'
        WHEN 8 THEN 'Test Engineer'
        WHEN 9 THEN 'Integration Engineer'
        WHEN 10 THEN 'Aerospace Engineer'
        WHEN 11 THEN 'RF Engineer'
        WHEN 12 THEN 'Contracts Manager'
        WHEN 13 THEN 'Financial Analyst'
        WHEN 14 THEN 'Supply Chain Manager'
        ELSE 'Technical Specialist'
    END AS job_title,
    ARRAY_CONSTRUCT('Engineering', 'Operations', 'Manufacturing', 'Quality', 'Finance', 'Contracts', 'IT', 'HR', 'Supply Chain', 'Business Development')[UNIFORM(0, 9, RANDOM())] AS department,
    'DIV00' || UNIFORM(1, 8, RANDOM()) AS division_id,
    NULL AS manager_id,
    CASE UNIFORM(0, 4, RANDOM())
        WHEN 0 THEN 'INDIVIDUAL_CONTRIBUTOR'
        WHEN 1 THEN 'SENIOR'
        WHEN 2 THEN 'LEAD'
        WHEN 3 THEN 'MANAGER'
        ELSE 'DIRECTOR'
    END AS employee_level,
    CASE UNIFORM(0, 5, RANDOM())
        WHEN 0 THEN 'UNCLASSIFIED'
        WHEN 1 THEN 'CONFIDENTIAL'
        WHEN 2 THEN 'SECRET'
        WHEN 3 THEN 'TOP SECRET'
        WHEN 4 THEN 'TOP SECRET/SCI'
        ELSE 'SECRET'
    END AS security_clearance,
    DATEADD('year', UNIFORM(1, 5, RANDOM()), CURRENT_DATE()) AS clearance_expiry_date,
    UNIFORM(1, 35, RANDOM()) AS years_experience,
    ARRAY_CONSTRUCT('High School', 'Associates', 'Bachelors', 'Masters', 'PhD')[UNIFORM(0, 4, RANDOM())] AS education_level,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 40 THEN
        ARRAY_CONSTRUCT('PMP', 'Six Sigma', 'CISSP', 'AWS Certified', 'ITIL', 'CPA', 'PE')[UNIFORM(0, 6, RANDOM())]
    ELSE NULL END AS certifications,
    CASE UNIFORM(0, 20, RANDOM())
        WHEN 0 THEN 'INACTIVE'
        WHEN 1 THEN 'ON_LEAVE'
        WHEN 2 THEN 'TERMINATED'
        ELSE 'ACTIVE'
    END AS employee_status,
    ARRAY_CONSTRUCT('San Diego, CA', 'Colorado Springs, CO', 'Huntsville, AL', 'Phoenix, AZ', 'Sacramento, CA', 'Orlando, FL', 'Washington, DC', 'San Antonio, TX')[UNIFORM(0, 7, RANDOM())] AS location,
    UNIFORM(0, 100, RANDOM()) < 20 AS is_remote,
    (UNIFORM(60000, 250000, RANDOM()) * 1.0)::NUMBER(12,2) AS annual_salary,
    (UNIFORM(75, 300, RANDOM()) * 1.0)::NUMBER(10,2) AS billable_rate,
    (UNIFORM(70, 95, RANDOM()) * 1.0)::NUMBER(5,2) AS utilization_target,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM TABLE(GENERATOR(ROWCOUNT => 5000));

-- ============================================================================
-- Step 3: Generate Programs
-- CRITICAL: Varied status distribution for analytics
-- ============================================================================
INSERT INTO PROGRAMS
SELECT
    'PRG' || LPAD(SEQ4(), 6, '0') AS program_id,
    UPPER(SUBSTR(MD5(RANDOM()), 1, 8)) AS program_code,
    CASE UNIFORM(0, 19, RANDOM())
        WHEN 0 THEN 'Tactical UAV Development Program'
        WHEN 1 THEN 'Advanced Target Drone System'
        WHEN 2 THEN 'Satellite Communications Upgrade'
        WHEN 3 THEN 'Electronic Warfare Suite Enhancement'
        WHEN 4 THEN 'Directed Energy Weapon Prototype'
        WHEN 5 THEN 'Jet Engine Modernization'
        WHEN 6 THEN 'Missile Defense Radar System'
        WHEN 7 THEN 'Training Simulation Platform'
        WHEN 8 THEN 'C5ISR Integration Program'
        WHEN 9 THEN 'Logistics Support System'
        WHEN 10 THEN 'Autonomous Ground Vehicle'
        WHEN 11 THEN 'Space Situational Awareness'
        WHEN 12 THEN 'Hypersonic Vehicle Testing'
        WHEN 13 THEN 'Cyber Defense Platform'
        WHEN 14 THEN 'Maritime Surveillance System'
        WHEN 15 THEN 'Counter-UAS Technology'
        WHEN 16 THEN 'Propulsion System Upgrade'
        WHEN 17 THEN 'Command and Control Network'
        WHEN 18 THEN 'Intelligence Analysis Tool'
        ELSE 'Defense Technology Initiative'
    END || ' ' || UNIFORM(1, 99, RANDOM()) AS program_name,
    ARRAY_CONSTRUCT('DEVELOPMENT', 'PRODUCTION', 'SUSTAINMENT', 'RDT&E', 'INTEGRATION', 'MODERNIZATION')[UNIFORM(0, 5, RANDOM())] AS program_type,
    -- VARIED STATUS DISTRIBUTION: 40% ACTIVE, 25% COMPLETED, 15% ON_HOLD, 10% PLANNING, 10% CANCELLED
    CASE 
        WHEN UNIFORM(0, 100, RANDOM()) < 40 THEN 'ACTIVE'
        WHEN UNIFORM(0, 100, RANDOM()) < 65 THEN 'COMPLETED'
        WHEN UNIFORM(0, 100, RANDOM()) < 80 THEN 'ON_HOLD'
        WHEN UNIFORM(0, 100, RANDOM()) < 90 THEN 'PLANNING'
        ELSE 'CANCELLED'
    END AS program_status,
    'DIV00' || UNIFORM(1, 8, RANDOM()) AS division_id,
    'EMP' || LPAD(UNIFORM(1, 5000, RANDOM()), 6, '0') AS program_manager_id,
    ARRAY_CONSTRUCT('U.S. Army', 'U.S. Navy', 'U.S. Air Force', 'U.S. Marine Corps', 'U.S. Space Force', 'Missile Defense Agency', 'DARPA', 'DHS', 'Foreign Military Sales')[UNIFORM(0, 8, RANDOM())] AS customer,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 30 THEN
        ARRAY_CONSTRUCT('Lockheed Martin', 'Boeing', 'Northrop Grumman', 'Raytheon', 'General Dynamics')[UNIFORM(0, 4, RANDOM())]
    ELSE 'Kratos Defense' END AS prime_contractor,
    DATEADD('day', -1 * UNIFORM(30, 1825, RANDOM()), CURRENT_DATE()) AS start_date,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 70 THEN DATEADD('day', UNIFORM(365, 2555, RANDOM()), CURRENT_DATE()) ELSE NULL END AS end_date,
    (UNIFORM(5000000, 500000000, RANDOM()) * 1.0)::NUMBER(15,2) AS budget_amount,
    (UNIFORM(1000000, 400000000, RANDOM()) * 1.0)::NUMBER(15,2) AS spent_amount,
    (UNIFORM(-5000000, 5000000, RANDOM()) * 1.0)::NUMBER(15,2) AS budget_variance,
    UNIFORM(-90, 90, RANDOM()) AS schedule_variance_days,
    -- VARIED RISK DISTRIBUTION: 20% LOW, 50% MEDIUM, 25% HIGH, 5% CRITICAL
    CASE 
        WHEN UNIFORM(0, 100, RANDOM()) < 20 THEN 'LOW'
        WHEN UNIFORM(0, 100, RANDOM()) < 70 THEN 'MEDIUM'
        WHEN UNIFORM(0, 100, RANDOM()) < 95 THEN 'HIGH'
        ELSE 'CRITICAL'
    END AS risk_level,
    ARRAY_CONSTRUCT('STANDARD', 'HIGH', 'CRITICAL', 'URGENT')[UNIFORM(0, 3, RANDOM())] AS priority_level,
    ARRAY_CONSTRUCT('UNCLASSIFIED', 'CONFIDENTIAL', 'SECRET', 'TOP SECRET')[UNIFORM(0, 3, RANDOM())] AS classification_level,
    ARRAY_CONSTRUCT('FFP', 'CPFF', 'CPIF', 'T&M', 'IDIQ', 'CPAF')[UNIFORM(0, 5, RANDOM())] AS contract_type,
    UNIFORM(5, 50, RANDOM()) AS milestone_count,
    UNIFORM(0, 40, RANDOM()) AS milestones_completed,
    (UNIFORM(0, 100, RANDOM()) * 1.0)::NUMBER(5,2) AS percent_complete,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM TABLE(GENERATOR(ROWCOUNT => 500));

-- ============================================================================
-- Step 4: Generate Contracts
-- CRITICAL: Varied status distribution
-- ============================================================================
INSERT INTO CONTRACTS
SELECT
    'CTR' || LPAD(SEQ4(), 6, '0') AS contract_id,
    'W' || LPAD(UNIFORM(10000, 99999, RANDOM()), 5, '0') || '-' || UNIFORM(10, 99, RANDOM()) || '-C-' || LPAD(UNIFORM(1000, 9999, RANDOM()), 4, '0') AS contract_number,
    CASE UNIFORM(0, 9, RANDOM())
        WHEN 0 THEN 'Unmanned Aerial Systems Support'
        WHEN 1 THEN 'Satellite Integration Services'
        WHEN 2 THEN 'Electronic Warfare Development'
        WHEN 3 THEN 'Propulsion System Maintenance'
        WHEN 4 THEN 'Training System Development'
        WHEN 5 THEN 'Logistics Support Services'
        WHEN 6 THEN 'Engineering Technical Services'
        WHEN 7 THEN 'Research and Development'
        WHEN 8 THEN 'Manufacturing Production'
        ELSE 'Systems Integration'
    END || ' Contract' AS contract_name,
    'PRG' || LPAD(UNIFORM(1, 500, RANDOM()), 6, '0') AS program_id,
    ARRAY_CONSTRUCT('FIRM_FIXED_PRICE', 'COST_PLUS_FIXED_FEE', 'COST_PLUS_INCENTIVE_FEE', 'TIME_AND_MATERIALS', 'IDIQ', 'BPA')[UNIFORM(0, 5, RANDOM())] AS contract_type,
    -- VARIED STATUS DISTRIBUTION: 35% ACTIVE, 30% COMPLETED, 15% AWARDED, 10% NEGOTIATION, 10% CLOSED
    CASE 
        WHEN UNIFORM(0, 100, RANDOM()) < 35 THEN 'ACTIVE'
        WHEN UNIFORM(0, 100, RANDOM()) < 65 THEN 'COMPLETED'
        WHEN UNIFORM(0, 100, RANDOM()) < 80 THEN 'AWARDED'
        WHEN UNIFORM(0, 100, RANDOM()) < 90 THEN 'NEGOTIATION'
        ELSE 'CLOSED'
    END AS contract_status,
    ARRAY_CONSTRUCT('U.S. Army', 'U.S. Navy', 'U.S. Air Force', 'U.S. Space Force', 'Missile Defense Agency', 'DARPA', 'DHS')[UNIFORM(0, 6, RANDOM())] AS customer,
    'CO-' || UNIFORM(1000, 9999, RANDOM()) AS contracting_officer,
    DATEADD('day', -1 * UNIFORM(30, 1095, RANDOM()), CURRENT_DATE()) AS award_date,
    DATEADD('day', -1 * UNIFORM(1, 1000, RANDOM()), CURRENT_DATE()) AS start_date,
    DATEADD('day', UNIFORM(180, 1825, RANDOM()), CURRENT_DATE()) AS end_date,
    (UNIFORM(500000, 100000000, RANDOM()) * 1.0)::NUMBER(15,2) AS base_value,
    (UNIFORM(750000, 150000000, RANDOM()) * 1.0)::NUMBER(15,2) AS ceiling_value,
    (UNIFORM(100000, 50000000, RANDOM()) * 1.0)::NUMBER(15,2) AS funded_value,
    (UNIFORM(50000, 40000000, RANDOM()) * 1.0)::NUMBER(15,2) AS billed_amount,
    ARRAY_CONSTRUCT('NET_30', 'NET_45', 'NET_60', 'MILESTONE')[UNIFORM(0, 3, RANDOM())] AS payment_terms,
    ARRAY_CONSTRUCT('336411', '336414', '336415', '541330', '541712', '541715')[UNIFORM(0, 5, RANDOM())] AS naics_code,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 20 THEN
        ARRAY_CONSTRUCT('SMALL_BUSINESS', 'SDVOSB', 'WOSB', '8A')[UNIFORM(0, 3, RANDOM())]
    ELSE NULL END AS set_aside_type,
    ARRAY_CONSTRUCT('FULL_AND_OPEN', 'SOLE_SOURCE', 'LIMITED', 'FOLLOW_ON')[UNIFORM(0, 3, RANDOM())] AS competition_type,
    UNIFORM(0, 100, RANDOM()) < 40 AS is_classified,
    ARRAY_CONSTRUCT('UNCLASSIFIED', 'CONFIDENTIAL', 'SECRET', 'TOP SECRET')[UNIFORM(0, 3, RANDOM())] AS security_level,
    (UNIFORM(70, 100, RANDOM()) / 10.0)::NUMBER(3,2) AS performance_rating,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM TABLE(GENERATOR(ROWCOUNT => 300));

-- ============================================================================
-- Step 5: Generate Assets
-- CRITICAL: Varied status distribution
-- ============================================================================
INSERT INTO ASSETS
SELECT
    'AST' || LPAD(SEQ4(), 6, '0') AS asset_id,
    'KD-' || UPPER(SUBSTR(MD5(RANDOM()), 1, 8)) AS asset_tag,
    CASE UNIFORM(0, 14, RANDOM())
        WHEN 0 THEN 'BQM-167 Target Drone'
        WHEN 1 THEN 'MQM-178 Firejet'
        WHEN 2 THEN 'Tactical UAV System'
        WHEN 3 THEN 'Ground Control Station'
        WHEN 4 THEN 'Satellite Transponder'
        WHEN 5 THEN 'Radar Antenna System'
        WHEN 6 THEN 'Microwave Transmitter'
        WHEN 7 THEN 'Jet Engine Test Stand'
        WHEN 8 THEN 'Rocket Motor Assembly'
        WHEN 9 THEN 'Training Simulator'
        WHEN 10 THEN 'Communication Terminal'
        WHEN 11 THEN 'Electronic Warfare Pod'
        WHEN 12 THEN 'Power Generator Unit'
        WHEN 13 THEN 'Mobile Command Post'
        ELSE 'Support Equipment'
    END || ' #' || UNIFORM(1, 999, RANDOM()) AS asset_name,
    ARRAY_CONSTRUCT('AIRCRAFT', 'VEHICLE', 'EQUIPMENT', 'ELECTRONICS', 'WEAPON_SYSTEM', 'SIMULATOR', 'TOOLING')[UNIFORM(0, 6, RANDOM())] AS asset_type,
    ARRAY_CONSTRUCT('PRODUCTION', 'TEST', 'TRAINING', 'PROTOTYPE', 'SUPPORT', 'SPARE')[UNIFORM(0, 5, RANDOM())] AS asset_category,
    -- VARIED STATUS DISTRIBUTION: 60% OPERATIONAL, 15% MAINTENANCE, 10% STANDBY, 8% REPAIR, 5% RETIRED, 2% DECOMMISSIONED
    CASE 
        WHEN UNIFORM(0, 100, RANDOM()) < 60 THEN 'OPERATIONAL'
        WHEN UNIFORM(0, 100, RANDOM()) < 75 THEN 'MAINTENANCE'
        WHEN UNIFORM(0, 100, RANDOM()) < 85 THEN 'STANDBY'
        WHEN UNIFORM(0, 100, RANDOM()) < 93 THEN 'REPAIR'
        WHEN UNIFORM(0, 100, RANDOM()) < 98 THEN 'RETIRED'
        ELSE 'DECOMMISSIONED'
    END AS asset_status,
    'SN-' || UPPER(SUBSTR(MD5(RANDOM()), 1, 12)) AS serial_number,
    ARRAY_CONSTRUCT('Kratos Defense', 'Lockheed Martin', 'Boeing', 'Northrop Grumman', 'Raytheon', 'General Electric', 'Pratt & Whitney')[UNIFORM(0, 6, RANDOM())] AS manufacturer,
    'Model-' || UNIFORM(100, 999, RANDOM()) AS model,
    DATEADD('day', -1 * UNIFORM(365, 3650, RANDOM()), CURRENT_DATE()) AS acquisition_date,
    (UNIFORM(50000, 50000000, RANDOM()) * 1.0)::NUMBER(15,2) AS acquisition_cost,
    (UNIFORM(25000, 40000000, RANDOM()) * 1.0)::NUMBER(15,2) AS current_value,
    (UNIFORM(5, 25, RANDOM()) * 1.0)::NUMBER(5,2) AS depreciation_rate,
    'PRG' || LPAD(UNIFORM(1, 500, RANDOM()), 6, '0') AS program_id,
    ARRAY_CONSTRUCT('San Diego, CA', 'Colorado Springs, CO', 'Huntsville, AL', 'Phoenix, AZ', 'Sacramento, CA', 'Edwards AFB, CA', 'White Sands, NM', 'Eglin AFB, FL')[UNIFORM(0, 7, RANDOM())] AS assigned_location,
    'EMP' || LPAD(UNIFORM(1, 5000, RANDOM()), 6, '0') AS responsible_employee_id,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 70 THEN DATEADD('day', UNIFORM(30, 730, RANDOM()), CURRENT_DATE()) ELSE NULL END AS warranty_expiry_date,
    DATEADD('day', -1 * UNIFORM(1, 180, RANDOM()), CURRENT_DATE()) AS last_maintenance_date,
    DATEADD('day', UNIFORM(1, 180, RANDOM()), CURRENT_DATE()) AS next_maintenance_due,
    UNIFORM(100, 500, RANDOM()) AS maintenance_interval_hours,
    (UNIFORM(0, 5000, RANDOM()) * 1.0)::NUMBER(10,2) AS total_flight_hours,
    UNIFORM(0, 100, RANDOM()) < 85 AS mission_ready,
    CASE UNIFORM(0, 4, RANDOM())
        WHEN 0 THEN 'EXCELLENT'
        WHEN 1 THEN 'GOOD'
        WHEN 2 THEN 'FAIR'
        WHEN 3 THEN 'POOR'
        ELSE 'GOOD'
    END AS condition_rating,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM TABLE(GENERATOR(ROWCOUNT => 1000));

-- ============================================================================
-- Step 6: Generate Suppliers
-- CRITICAL: Varied status distribution
-- ============================================================================
INSERT INTO SUPPLIERS
SELECT
    'SUP' || LPAD(SEQ4(), 6, '0') AS supplier_id,
    'SUP-' || UPPER(SUBSTR(MD5(RANDOM()), 1, 6)) AS supplier_code,
    CASE UNIFORM(0, 19, RANDOM())
        WHEN 0 THEN 'Aerospace Components Inc.'
        WHEN 1 THEN 'Defense Electronics Corp.'
        WHEN 2 THEN 'Precision Manufacturing Ltd.'
        WHEN 3 THEN 'Advanced Materials Group'
        WHEN 4 THEN 'Tactical Systems LLC'
        WHEN 5 THEN 'Propulsion Technologies'
        WHEN 6 THEN 'Composite Solutions'
        WHEN 7 THEN 'Microelectronics Partners'
        WHEN 8 THEN 'Avionics International'
        WHEN 9 THEN 'Defense Logistics Corp.'
        WHEN 10 THEN 'Engineering Services Inc.'
        WHEN 11 THEN 'Subsystem Integrators'
        WHEN 12 THEN 'Quality Machining Co.'
        WHEN 13 THEN 'Electronics Assembly LLC'
        WHEN 14 THEN 'Thermal Management Corp.'
        WHEN 15 THEN 'Hydraulic Systems Inc.'
        WHEN 16 THEN 'Radar Components Ltd.'
        WHEN 17 THEN 'Navigation Solutions'
        WHEN 18 THEN 'Communication Systems'
        ELSE 'General Defense Supply'
    END AS supplier_name,
    ARRAY_CONSTRUCT('TIER_1', 'TIER_2', 'TIER_3', 'DISTRIBUTOR', 'SERVICE_PROVIDER')[UNIFORM(0, 4, RANDOM())] AS supplier_type,
    -- VARIED STATUS DISTRIBUTION: 70% ACTIVE, 15% PREFERRED, 8% PROBATION, 5% INACTIVE, 2% SUSPENDED
    CASE 
        WHEN UNIFORM(0, 100, RANDOM()) < 70 THEN 'ACTIVE'
        WHEN UNIFORM(0, 100, RANDOM()) < 85 THEN 'PREFERRED'
        WHEN UNIFORM(0, 100, RANDOM()) < 93 THEN 'PROBATION'
        WHEN UNIFORM(0, 100, RANDOM()) < 98 THEN 'INACTIVE'
        ELSE 'SUSPENDED'
    END AS supplier_status,
    LPAD(UNIFORM(10000, 99999, RANDOM()), 5, '0') AS cage_code,
    LPAD(UNIFORM(100000000, 999999999, RANDOM()), 9, '0') AS duns_number,
    UNIFORM(100, 9999, RANDOM()) || ' Industrial Blvd' AS address_line1,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 30 THEN 'Suite ' || UNIFORM(100, 999, RANDOM()) ELSE NULL END AS address_line2,
    ARRAY_CONSTRUCT('Los Angeles', 'Phoenix', 'Dallas', 'Seattle', 'Boston', 'Denver', 'Atlanta', 'Chicago', 'Houston', 'San Jose')[UNIFORM(0, 9, RANDOM())] AS city,
    ARRAY_CONSTRUCT('CA', 'AZ', 'TX', 'WA', 'MA', 'CO', 'GA', 'IL', 'OH', 'FL')[UNIFORM(0, 9, RANDOM())] AS state,
    LPAD(UNIFORM(10001, 99999, RANDOM()), 5, '0') AS postal_code,
    'USA' AS country,
    ARRAY_CONSTRUCT('John', 'Jane', 'Michael', 'Sarah', 'David', 'Lisa', 'Robert', 'Emily')[UNIFORM(0, 7, RANDOM())] || ' ' ||
    ARRAY_CONSTRUCT('Smith', 'Johnson', 'Williams', 'Brown', 'Davis', 'Miller', 'Wilson', 'Moore')[UNIFORM(0, 7, RANDOM())] AS primary_contact,
    'contact' || SEQ4() || '@supplier.com' AS contact_email,
    CONCAT('+1-', LPAD(UNIFORM(200, 999, RANDOM()), 3, '0'), '-', LPAD(UNIFORM(100, 999, RANDOM()), 3, '0'), '-', LPAD(UNIFORM(1000, 9999, RANDOM()), 4, '0')) AS contact_phone,
    ARRAY_CONSTRUCT(15, 30, 45, 60)[UNIFORM(0, 3, RANDOM())] AS payment_terms,
    (UNIFORM(50000, 5000000, RANDOM()) * 1.0)::NUMBER(15,2) AS credit_limit,
    -- VARIED RISK DISTRIBUTION: 40% LOW, 35% MEDIUM, 20% HIGH, 5% CRITICAL
    CASE 
        WHEN UNIFORM(0, 100, RANDOM()) < 40 THEN 'LOW'
        WHEN UNIFORM(0, 100, RANDOM()) < 75 THEN 'MEDIUM'
        WHEN UNIFORM(0, 100, RANDOM()) < 95 THEN 'HIGH'
        ELSE 'CRITICAL'
    END AS risk_rating,
    (UNIFORM(70, 100, RANDOM()) / 10.0)::NUMBER(3,2) AS quality_rating,
    (UNIFORM(70, 100, RANDOM()) / 10.0)::NUMBER(3,2) AS delivery_rating,
    UNIFORM(0, 100, RANDOM()) < 30 AS is_small_business,
    UNIFORM(0, 100, RANDOM()) < 15 AS is_woman_owned,
    UNIFORM(0, 100, RANDOM()) < 10 AS is_veteran_owned,
    UNIFORM(0, 100, RANDOM()) < 12 AS is_minority_owned,
    UNIFORM(10, 500, RANDOM()) AS total_orders,
    (UNIFORM(100000, 50000000, RANDOM()) * 1.0)::NUMBER(15,2) AS total_spend,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM TABLE(GENERATOR(ROWCOUNT => 200));

-- ============================================================================
-- Step 7: Generate Purchase Orders
-- ============================================================================
INSERT INTO PURCHASE_ORDERS
SELECT
    'PO' || LPAD(ROW_NUMBER() OVER (ORDER BY s.supplier_id), 8, '0') AS po_id,
    'PO-' || UNIFORM(100000, 999999, RANDOM()) AS po_number,
    s.supplier_id,
    'PRG' || LPAD(UNIFORM(1, 500, RANDOM()), 6, '0') AS program_id,
    'CTR' || LPAD(UNIFORM(1, 300, RANDOM()), 6, '0') AS contract_id,
    DATEADD('day', -1 * UNIFORM(1, 730, RANDOM()), CURRENT_DATE()) AS po_date,
    -- VARIED STATUS: 30% OPEN, 40% RECEIVED, 20% CLOSED, 10% CANCELLED
    CASE 
        WHEN UNIFORM(0, 100, RANDOM()) < 30 THEN 'OPEN'
        WHEN UNIFORM(0, 100, RANDOM()) < 70 THEN 'RECEIVED'
        WHEN UNIFORM(0, 100, RANDOM()) < 90 THEN 'CLOSED'
        ELSE 'CANCELLED'
    END AS po_status,
    (UNIFORM(5000, 500000, RANDOM()) * 1.0)::NUMBER(15,2) AS subtotal,
    (UNIFORM(0, 25000, RANDOM()) * 1.0)::NUMBER(12,2) AS tax_amount,
    (UNIFORM(0, 5000, RANDOM()) * 1.0)::NUMBER(10,2) AS shipping_amount,
    0.00 AS total_amount,
    0.00 AS paid_amount,
    CASE UNIFORM(0, 3, RANDOM())
        WHEN 0 THEN 'PAID'
        WHEN 1 THEN 'PARTIAL'
        WHEN 2 THEN 'UNPAID'
        ELSE 'PAID'
    END AS payment_status,
    DATEADD('day', UNIFORM(30, 90, RANDOM()), DATEADD('day', -1 * UNIFORM(1, 730, RANDOM()), CURRENT_DATE())) AS due_date,
    ARRAY_CONSTRUCT('San Diego, CA', 'Colorado Springs, CO', 'Huntsville, AL', 'Phoenix, AZ')[UNIFORM(0, 3, RANDOM())] AS ship_to_location,
    'EMP' || LPAD(UNIFORM(1, 5000, RANDOM()), 6, '0') AS requested_by,
    'EMP' || LPAD(UNIFORM(1, 5000, RANDOM()), 6, '0') AS approved_by,
    DATEADD('day', -1 * UNIFORM(1, 730, RANDOM()), CURRENT_DATE()) AS approval_date,
    NULL AS notes,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM SUPPLIERS s
CROSS JOIN TABLE(GENERATOR(ROWCOUNT => 10))
WHERE UNIFORM(0, 100, RANDOM()) < 50
LIMIT 5000;

-- Update PO totals
UPDATE PURCHASE_ORDERS
SET total_amount = subtotal + tax_amount + shipping_amount,
    paid_amount = CASE WHEN payment_status = 'PAID' THEN subtotal + tax_amount + shipping_amount
                       WHEN payment_status = 'PARTIAL' THEN (subtotal + tax_amount + shipping_amount) * 0.5
                       ELSE 0 END;

-- ============================================================================
-- Step 8: Generate Maintenance Records
-- ============================================================================
INSERT INTO MAINTENANCE_RECORDS
SELECT
    'MNT' || LPAD(ROW_NUMBER() OVER (ORDER BY a.asset_id), 8, '0') AS maintenance_id,
    a.asset_id,
    ARRAY_CONSTRUCT('SCHEDULED', 'UNSCHEDULED', 'PREVENTIVE', 'CORRECTIVE', 'OVERHAUL')[UNIFORM(0, 4, RANDOM())] AS maintenance_type,
    ARRAY_CONSTRUCT('INSPECTION', 'REPAIR', 'REPLACEMENT', 'CALIBRATION', 'SOFTWARE_UPDATE', 'STRUCTURAL')[UNIFORM(0, 5, RANDOM())] AS maintenance_category,
    -- VARIED STATUS: 60% COMPLETED, 20% IN_PROGRESS, 15% SCHEDULED, 5% CANCELLED
    CASE 
        WHEN UNIFORM(0, 100, RANDOM()) < 60 THEN 'COMPLETED'
        WHEN UNIFORM(0, 100, RANDOM()) < 80 THEN 'IN_PROGRESS'
        WHEN UNIFORM(0, 100, RANDOM()) < 95 THEN 'SCHEDULED'
        ELSE 'CANCELLED'
    END AS maintenance_status,
    DATEADD('day', -1 * UNIFORM(1, 365, RANDOM()), CURRENT_DATE()) AS scheduled_date,
    DATEADD('day', -1 * UNIFORM(1, 360, RANDOM()), CURRENT_DATE()) AS start_date,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 75 THEN DATEADD('day', -1 * UNIFORM(1, 350, RANDOM()), CURRENT_DATE()) ELSE NULL END AS completion_date,
    ARRAY_CONSTRUCT('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')[UNIFORM(0, 3, RANDOM())] AS priority,
    'Routine maintenance and inspection of system components.' AS description,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 60 THEN 'All systems within operational parameters. No issues found.' 
         ELSE 'Minor wear observed. Recommended follow-up inspection.' END AS findings,
    'Completed all scheduled maintenance tasks per technical manual.' AS actions_taken,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 30 THEN 'Filter, O-ring, Gasket' ELSE NULL END AS parts_replaced,
    (UNIFORM(2, 80, RANDOM()) * 1.0)::NUMBER(8,2) AS labor_hours,
    (UNIFORM(0, 10000, RANDOM()) * 1.0)::NUMBER(12,2) AS parts_cost,
    (UNIFORM(100, 8000, RANDOM()) * 1.0)::NUMBER(12,2) AS labor_cost,
    0.00 AS total_cost,
    'EMP' || LPAD(UNIFORM(1, 5000, RANDOM()), 6, '0') AS technician_id,
    'WO-' || UNIFORM(100000, 999999, RANDOM()) AS work_order_number,
    UNIFORM(0, 100, RANDOM()) < 25 AS is_unscheduled,
    (UNIFORM(0, 48, RANDOM()) * 1.0)::NUMBER(8,2) AS downtime_hours,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM ASSETS a
CROSS JOIN TABLE(GENERATOR(ROWCOUNT => 5))
WHERE UNIFORM(0, 100, RANDOM()) < 80
LIMIT 10000;

-- Update maintenance total costs
UPDATE MAINTENANCE_RECORDS
SET total_cost = parts_cost + labor_cost;

-- ============================================================================
-- Step 9: Generate Engineers
-- ============================================================================
INSERT INTO ENGINEERS
SELECT
    'ENG' || LPAD(SEQ4(), 5, '0') AS engineer_id,
    ARRAY_CONSTRUCT('Dr. Michael', 'Sarah', 'Brian', 'Lisa', 'Kevin', 'Jennifer', 'Ryan', 'Amanda', 'Marcus', 'Rachel',
                    'Dr. James', 'Nicole', 'Chris', 'Megan', 'Derek', 'Samantha', 'Tony', 'Lauren', 'Brandon', 'Ashley')[UNIFORM(0, 19, RANDOM())] AS first_name,
    ARRAY_CONSTRUCT('Thompson', 'Anderson', 'Martinez', 'Clark', 'Turner', 'Rodriguez', 'Foster', 'Phillips', 'Campbell', 'Mitchell',
                    'Roberts', 'Jackson', 'White', 'Harris', 'Lewis', 'Young', 'King', 'Scott', 'Green', 'Adams')[UNIFORM(0, 19, RANDOM())] AS last_name,
    'engineer' || SEQ4() || '@kratos-defense.com' AS email,
    ARRAY_CONSTRUCT('Systems Engineering', 'Software Development', 'Electrical Engineering', 'Mechanical Engineering', 'Aerospace Engineering', 
                    'RF Engineering', 'Integration & Test', 'Quality Assurance', 'Manufacturing Engineering')[UNIFORM(0, 8, RANDOM())] AS specialty,
    'PE, ' || ARRAY_CONSTRUCT('INCOSE CSEP', 'PMP', 'Six Sigma Black Belt', 'AWS Solutions Architect', 'CISSP', 'DAWIA Level III')[UNIFORM(0, 5, RANDOM())] AS credentials,
    ARRAY_CONSTRUCT('SECRET', 'TOP SECRET', 'TOP SECRET/SCI')[UNIFORM(0, 2, RANDOM())] AS security_clearance,
    UNIFORM(5, 35, RANDOM()) AS years_experience,
    'DIV00' || UNIFORM(1, 8, RANDOM()) AS division_id,
    CASE UNIFORM(0, 4, RANDOM())
        WHEN 0 THEN 'ENGINEER'
        WHEN 1 THEN 'SENIOR_ENGINEER'
        WHEN 2 THEN 'STAFF_ENGINEER'
        WHEN 3 THEN 'PRINCIPAL_ENGINEER'
        ELSE 'FELLOW'
    END AS engineer_level,
    (UNIFORM(100, 350, RANDOM()) * 1.0)::NUMBER(10,2) AS billable_rate,
    (UNIFORM(60, 100, RANDOM()) * 1.0)::NUMBER(5,2) AS utilization_rate,
    UNIFORM(1, 5, RANDOM()) AS active_projects,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 95 THEN 'ACTIVE' ELSE 'ON_LEAVE' END AS engineer_status,
    DATEADD('day', -1 * UNIFORM(365, 7300, RANDOM()), CURRENT_DATE()) AS hire_date,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM TABLE(GENERATOR(ROWCOUNT => 100));

-- ============================================================================
-- Step 10: Generate Quality Inspections
-- ============================================================================
INSERT INTO QUALITY_INSPECTIONS
SELECT
    'QI' || LPAD(ROW_NUMBER() OVER (ORDER BY a.asset_id), 8, '0') AS inspection_id,
    a.asset_id,
    'PRG' || LPAD(UNIFORM(1, 500, RANDOM()), 6, '0') AS program_id,
    'CTR' || LPAD(UNIFORM(1, 300, RANDOM()), 6, '0') AS contract_id,
    ARRAY_CONSTRUCT('RECEIVING', 'IN_PROCESS', 'FINAL', 'SOURCE', 'FIRST_ARTICLE', 'PERIODIC')[UNIFORM(0, 5, RANDOM())] AS inspection_type,
    DATEADD('day', -1 * UNIFORM(1, 365, RANDOM()), CURRENT_DATE()) AS inspection_date,
    'EMP' || LPAD(UNIFORM(1, 5000, RANDOM()), 6, '0') AS inspector_id,
    CASE UNIFORM(0, 10, RANDOM())
        WHEN 0 THEN 'PENDING'
        WHEN 1 THEN 'IN_PROGRESS'
        ELSE 'COMPLETED'
    END AS inspection_status,
    (UNIFORM(70, 100, RANDOM()) / 10.0)::NUMBER(3,2) AS overall_rating,
    (UNIFORM(75, 100, RANDOM()) * 1.0)::NUMBER(5,2) AS compliance_score,
    (UNIFORM(80, 100, RANDOM()) * 1.0)::NUMBER(5,2) AS quality_score,
    (UNIFORM(85, 100, RANDOM()) * 1.0)::NUMBER(5,2) AS safety_score,
    UNIFORM(0, 10, RANDOM()) AS findings_count,
    UNIFORM(0, 2, RANDOM()) AS critical_findings,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 30 THEN 'Minor discrepancies noted in documentation. Surface finish within tolerance.' ELSE NULL END AS findings_description,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 25 THEN 'Recommend enhanced incoming inspection procedures.' ELSE NULL END AS recommendations,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 20 THEN 'Corrective action implemented and verified.' ELSE NULL END AS corrective_actions,
    DATEADD('day', UNIFORM(90, 365, RANDOM()), CURRENT_DATE()) AS next_inspection_date,
    UNIFORM(0, 100, RANDOM()) < 92 AS passed,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM ASSETS a
WHERE UNIFORM(0, 100, RANDOM()) < 50
LIMIT 2000;

-- ============================================================================
-- Step 11: Generate Proposals
-- ============================================================================
INSERT INTO PROPOSALS
SELECT
    'PROP' || LPAD(SEQ4(), 6, '0') AS proposal_id,
    'PROP-' || UNIFORM(2024, 2025, RANDOM()) || '-' || LPAD(UNIFORM(1, 999, RANDOM()), 3, '0') AS proposal_number,
    CASE UNIFORM(0, 9, RANDOM())
        WHEN 0 THEN 'Next Generation UAV System'
        WHEN 1 THEN 'Advanced Electronic Warfare Suite'
        WHEN 2 THEN 'Satellite Communications Modernization'
        WHEN 3 THEN 'Directed Energy Weapons Development'
        WHEN 4 THEN 'Hypersonic Vehicle Program'
        WHEN 5 THEN 'Autonomous Systems Integration'
        WHEN 6 THEN 'Cyber Defense Platform'
        WHEN 7 THEN 'Space Domain Awareness'
        WHEN 8 THEN 'Training Systems Upgrade'
        ELSE 'Defense Technology Initiative'
    END || ' Proposal' AS proposal_name,
    'SOL-' || UNIFORM(2024, 2025, RANDOM()) || '-' || LPAD(UNIFORM(10000, 99999, RANDOM()), 5, '0') AS solicitation_number,
    ARRAY_CONSTRUCT('COMPETITIVE', 'SOLE_SOURCE', 'UNSOLICITED', 'RECOMPETE', 'TASK_ORDER')[UNIFORM(0, 4, RANDOM())] AS proposal_type,
    -- VARIED STATUS: 25% SUBMITTED, 20% WON, 15% LOST, 20% IN_PROGRESS, 10% PENDING_DECISION, 10% CANCELLED
    CASE 
        WHEN UNIFORM(0, 100, RANDOM()) < 25 THEN 'SUBMITTED'
        WHEN UNIFORM(0, 100, RANDOM()) < 45 THEN 'WON'
        WHEN UNIFORM(0, 100, RANDOM()) < 60 THEN 'LOST'
        WHEN UNIFORM(0, 100, RANDOM()) < 80 THEN 'IN_PROGRESS'
        WHEN UNIFORM(0, 100, RANDOM()) < 90 THEN 'PENDING_DECISION'
        ELSE 'CANCELLED'
    END AS proposal_status,
    'DIV00' || UNIFORM(1, 8, RANDOM()) AS division_id,
    'EMP' || LPAD(UNIFORM(1, 5000, RANDOM()), 6, '0') AS proposal_manager_id,
    ARRAY_CONSTRUCT('U.S. Army', 'U.S. Navy', 'U.S. Air Force', 'U.S. Space Force', 'Missile Defense Agency', 'DARPA', 'DHS')[UNIFORM(0, 6, RANDOM())] AS customer,
    (UNIFORM(10000000, 500000000, RANDOM()) * 1.0)::NUMBER(15,2) AS opportunity_value,
    (UNIFORM(8000000, 450000000, RANDOM()) * 1.0)::NUMBER(15,2) AS proposed_value,
    (UNIFORM(20, 85, RANDOM()) * 1.0)::NUMBER(5,2) AS win_probability,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 60 THEN DATEADD('day', -1 * UNIFORM(1, 365, RANDOM()), CURRENT_DATE()) ELSE NULL END AS submission_date,
    DATEADD('day', UNIFORM(-30, 90, RANDOM()), CURRENT_DATE()) AS due_date,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 35 THEN DATEADD('day', UNIFORM(30, 180, RANDOM()), CURRENT_DATE()) ELSE NULL END AS decision_date,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 35 THEN ARRAY_CONSTRUCT('WIN', 'LOSS', 'NO_BID')[UNIFORM(0, 2, RANDOM())] ELSE NULL END AS result,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 20 THEN 'CTR' || LPAD(UNIFORM(1, 300, RANDOM()), 6, '0') ELSE NULL END AS contract_id,
    'Lockheed Martin, Boeing, Northrop Grumman' AS competitors,
    'Technical innovation, cost efficiency, proven past performance' AS key_discriminators,
    'Schedule constraints, resource availability, technology maturity' AS risk_factors,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM TABLE(GENERATOR(ROWCOUNT => 150));

-- ============================================================================
-- Step 12: Generate Service Agreements
-- ============================================================================
INSERT INTO SERVICE_AGREEMENTS
SELECT
    'SA' || LPAD(SEQ4(), 6, '0') AS agreement_id,
    'SA-' || UNIFORM(2020, 2025, RANDOM()) || '-' || LPAD(UNIFORM(1, 999, RANDOM()), 3, '0') AS agreement_number,
    CASE UNIFORM(0, 4, RANDOM())
        WHEN 0 THEN 'Depot Maintenance Support'
        WHEN 1 THEN 'Field Service Support'
        WHEN 2 THEN 'Engineering Technical Assistance'
        WHEN 3 THEN 'Logistics Management'
        ELSE 'Training Services'
    END || ' Agreement' AS agreement_name,
    ARRAY_CONSTRUCT('MAINTENANCE', 'SUPPORT', 'TRAINING', 'LOGISTICS', 'ENGINEERING')[UNIFORM(0, 4, RANDOM())] AS agreement_type,
    ARRAY_CONSTRUCT('U.S. Army', 'U.S. Navy', 'U.S. Air Force', 'Missile Defense Agency')[UNIFORM(0, 3, RANDOM())] AS customer,
    'PRG' || LPAD(UNIFORM(1, 500, RANDOM()), 6, '0') AS program_id,
    DATEADD('day', -1 * UNIFORM(30, 730, RANDOM()), CURRENT_DATE()) AS start_date,
    DATEADD('day', UNIFORM(365, 1825, RANDOM()), CURRENT_DATE()) AS end_date,
    DATEADD('day', UNIFORM(300, 1600, RANDOM()), CURRENT_DATE()) AS renewal_date,
    CASE UNIFORM(0, 10, RANDOM())
        WHEN 0 THEN 'EXPIRED'
        WHEN 1 THEN 'PENDING_RENEWAL'
        ELSE 'ACTIVE'
    END AS agreement_status,
    (UNIFORM(500000, 10000000, RANDOM()) * 1.0)::NUMBER(15,2) AS annual_value,
    (UNIFORM(1000000, 30000000, RANDOM()) * 1.0)::NUMBER(15,2) AS total_value,
    ARRAY_CONSTRUCT('MONTHLY', 'QUARTERLY', 'ANNUAL', 'MILESTONE')[UNIFORM(0, 3, RANDOM())] AS billing_frequency,
    ARRAY_CONSTRUCT(15, 30, 45, 60)[UNIFORM(0, 3, RANDOM())] AS payment_terms,
    UNIFORM(0, 100, RANDOM()) < 60 AS auto_renew,
    (UNIFORM(95, 100, RANDOM()) * 1.0)::NUMBER(5,2) AS sla_target,
    (UNIFORM(92, 100, RANDOM()) * 1.0)::NUMBER(5,2) AS actual_sla,
    ARRAY_CONSTRUCT(30, 60, 90, 180)[UNIFORM(0, 3, RANDOM())] AS cancellation_notice_days,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM TABLE(GENERATOR(ROWCOUNT => 100));

-- ============================================================================
-- Step 13: Generate Milestones
-- ============================================================================
INSERT INTO MILESTONES
SELECT
    'MS' || LPAD(ROW_NUMBER() OVER (ORDER BY p.program_id), 8, '0') AS milestone_id,
    p.program_id,
    'CTR' || LPAD(UNIFORM(1, 300, RANDOM()), 6, '0') AS contract_id,
    CASE UNIFORM(0, 9, RANDOM())
        WHEN 0 THEN 'Preliminary Design Review (PDR)'
        WHEN 1 THEN 'Critical Design Review (CDR)'
        WHEN 2 THEN 'First Article Test'
        WHEN 3 THEN 'System Integration Review'
        WHEN 4 THEN 'Production Readiness Review'
        WHEN 5 THEN 'Delivery of First Unit'
        WHEN 6 THEN 'Operational Test & Evaluation'
        WHEN 7 THEN 'Full Rate Production Decision'
        WHEN 8 THEN 'Initial Operating Capability'
        ELSE 'Program Review'
    END AS milestone_name,
    ARRAY_CONSTRUCT('TECHNICAL', 'PROGRAMMATIC', 'CONTRACTUAL', 'DELIVERY')[UNIFORM(0, 3, RANDOM())] AS milestone_type,
    -- VARIED STATUS: 40% COMPLETED, 30% PENDING, 20% IN_PROGRESS, 10% AT_RISK
    CASE 
        WHEN UNIFORM(0, 100, RANDOM()) < 40 THEN 'COMPLETED'
        WHEN UNIFORM(0, 100, RANDOM()) < 70 THEN 'PENDING'
        WHEN UNIFORM(0, 100, RANDOM()) < 90 THEN 'IN_PROGRESS'
        ELSE 'AT_RISK'
    END AS milestone_status,
    DATEADD('day', UNIFORM(-180, 365, RANDOM()), CURRENT_DATE()) AS planned_date,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 40 THEN DATEADD('day', UNIFORM(-180, 30, RANDOM()), CURRENT_DATE()) ELSE NULL END AS actual_date,
    DATEADD('day', UNIFORM(-200, 300, RANDOM()), CURRENT_DATE()) AS baseline_date,
    UNIFORM(-30, 30, RANDOM()) AS schedule_variance_days,
    'Technical documentation and demonstration package' AS deliverable,
    'All technical requirements verified and validated per contract specifications' AS acceptance_criteria,
    (UNIFORM(100000, 5000000, RANDOM()) * 1.0)::NUMBER(15,2) AS payment_amount,
    UNIFORM(0, 100, RANDOM()) < 25 AS is_critical,
    NULL AS predecessor_id,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM PROGRAMS p
CROSS JOIN TABLE(GENERATOR(ROWCOUNT => 5))
WHERE UNIFORM(0, 100, RANDOM()) < 80
LIMIT 3000;

-- ============================================================================
-- Display data generation completion summary
-- ============================================================================
SELECT 'Data generation completed successfully' AS status,
       (SELECT COUNT(*) FROM DIVISIONS) AS divisions,
       (SELECT COUNT(*) FROM EMPLOYEES) AS employees,
       (SELECT COUNT(*) FROM PROGRAMS) AS programs,
       (SELECT COUNT(*) FROM CONTRACTS) AS contracts,
       (SELECT COUNT(*) FROM ASSETS) AS assets,
       (SELECT COUNT(*) FROM SUPPLIERS) AS suppliers,
       (SELECT COUNT(*) FROM PURCHASE_ORDERS) AS purchase_orders,
       (SELECT COUNT(*) FROM MAINTENANCE_RECORDS) AS maintenance_records,
       (SELECT COUNT(*) FROM ENGINEERS) AS engineers,
       (SELECT COUNT(*) FROM QUALITY_INSPECTIONS) AS quality_inspections,
       (SELECT COUNT(*) FROM PROPOSALS) AS proposals,
       (SELECT COUNT(*) FROM SERVICE_AGREEMENTS) AS service_agreements,
       (SELECT COUNT(*) FROM MILESTONES) AS milestones;

-- ============================================================================
-- DATA VERIFICATION QUERIES (Run after data generation)
-- These verify status distributions are varied as expected
-- ============================================================================
/*
SELECT program_status, COUNT(*) AS cnt FROM PROGRAMS GROUP BY 1 ORDER BY 2 DESC;
SELECT contract_status, COUNT(*) AS cnt FROM CONTRACTS GROUP BY 1 ORDER BY 2 DESC;
SELECT asset_status, COUNT(*) AS cnt FROM ASSETS GROUP BY 1 ORDER BY 2 DESC;
SELECT supplier_status, COUNT(*) AS cnt FROM SUPPLIERS GROUP BY 1 ORDER BY 2 DESC;
SELECT risk_level, COUNT(*) AS cnt FROM PROGRAMS GROUP BY 1 ORDER BY 2 DESC;
SELECT risk_rating, COUNT(*) AS cnt FROM SUPPLIERS GROUP BY 1 ORDER BY 2 DESC;
*/

