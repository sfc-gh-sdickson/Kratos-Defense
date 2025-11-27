-- ============================================================================
-- Kratos Defense Intelligence Agent - Synthetic Data Generation
-- ============================================================================
-- CRITICAL RULES (from GENERATION_FAILURES_AND_LESSONS.md):
--   1. UNIFORM(min, max, gen) - min and max MUST be constant literals
--   2. SEQ4() - ONLY valid in GENERATOR context, use ROW_NUMBER() otherwise
--   3. GENERATOR(ROWCOUNT => n) - n MUST be constant integer
--   4. Handle NOT NULL columns - filter out NULLs before insert
-- ============================================================================

USE DATABASE KRATOS_INTELLIGENCE;
USE SCHEMA RAW;
USE WAREHOUSE KRATOS_WH;

-- ============================================================================
-- Step 1: Generate DIVISIONS (9 divisions)
-- ============================================================================
INSERT INTO DIVISIONS (
    division_id, division_code, division_name, division_category, description,
    headquarters_location, employee_count, annual_revenue, primary_customer,
    security_clearance_level, is_active, established_date
) VALUES
    ('DIV001', 'UAS', 'Unmanned Systems Division', 'AEROSPACE', 'High-performance unmanned aerial systems including tactical drones and target systems', 'Oklahoma City, OK', 2500, 850000000.00, 'US Air Force', 'SECRET', TRUE, '2000-03-15'),
    ('DIV002', 'SATCOM', 'Space & Satellite Communications', 'SPACE', 'Virtualized ground systems, software-defined space networks, satellite communications', 'Colorado Springs, CO', 1800, 620000000.00, 'US Space Force', 'TOP SECRET', TRUE, '1995-07-01'),
    ('DIV003', 'HYPER', 'Hypersonic Systems', 'AEROSPACE', 'Advanced hypersonic strike platforms and test systems', 'Huntsville, AL', 1200, 480000000.00, 'DARPA', 'TOP SECRET', TRUE, '2015-01-10'),
    ('DIV004', 'PROP', 'Propulsion & Power Systems', 'PROPULSION', 'Jet engines, solid rocket motors, next-generation propulsion systems', 'Sacramento, CA', 950, 320000000.00, 'US Navy', 'SECRET', TRUE, '1998-11-20'),
    ('DIV005', 'MWE', 'Microwave Electronics', 'ELECTRONICS', 'Advanced microwave and digital solutions for missiles, satellites, electronic warfare', 'San Diego, CA', 1100, 380000000.00, 'US Army', 'SECRET', TRUE, '2002-04-05'),
    ('DIV006', 'CYBER', 'Cybersecurity Division', 'CYBER', 'Information assurance, critical infrastructure security, cyber warfare capabilities', 'Washington, DC', 650, 180000000.00, 'DHS', 'TOP SECRET/SCI', TRUE, '2010-06-15'),
    ('DIV007', 'MDS', 'Missile Defense Systems', 'DEFENSE', 'Ballistic missile defense systems and interceptors', 'Tucson, AZ', 1400, 520000000.00, 'MDA', 'TOP SECRET', TRUE, '2005-09-01'),
    ('DIV008', 'C5ISR', 'Command & Control Systems', 'C5ISR', 'C5ISR systems, tactical networks, battlefield management', 'Fort Worth, TX', 800, 290000000.00, 'US Army', 'SECRET', TRUE, '2008-02-28'),
    ('DIV009', 'TRAIN', 'Training Systems', 'TRAINING', 'VR/AR simulation and training systems for warfighters', 'Orlando, FL', 550, 150000000.00, 'US Marines', 'UNCLASSIFIED', TRUE, '2012-08-10');

-- ============================================================================
-- Step 2: Generate CUSTOMERS (50 customers)
-- ============================================================================
INSERT INTO CUSTOMERS (
    customer_id, customer_code, customer_name, customer_type, customer_category,
    agency_branch, country, security_clearance_required, relationship_status,
    first_contract_date, total_contract_value
)
SELECT
    'CUST' || LPAD(ROW_NUMBER() OVER (ORDER BY seq)::VARCHAR, 5, '0') AS customer_id,
    'C' || LPAD(ROW_NUMBER() OVER (ORDER BY seq)::VARCHAR, 4, '0') AS customer_code,
    CASE MOD(seq, 10)
        WHEN 0 THEN 'US Air Force - ' || ARRAY_CONSTRUCT('ACC', 'AMC', 'AETC', 'AFMC', 'AFGSC')[MOD(seq, 5)::INT]
        WHEN 1 THEN 'US Navy - ' || ARRAY_CONSTRUCT('NAVAIR', 'NAVSEA', 'SPAWAR', 'ONR', 'NAVFAC')[MOD(seq, 5)::INT]
        WHEN 2 THEN 'US Army - ' || ARRAY_CONSTRUCT('PEO Aviation', 'PEO Missiles', 'PEO Soldier', 'PEO C3T', 'CECOM')[MOD(seq, 5)::INT]
        WHEN 3 THEN 'US Space Force - ' || ARRAY_CONSTRUCT('SMC', 'SSC', 'STARCOM', 'SpOC', 'USSF HQ')[MOD(seq, 5)::INT]
        WHEN 4 THEN 'Defense Agency - ' || ARRAY_CONSTRUCT('DARPA', 'MDA', 'DIA', 'NGA', 'NSA')[MOD(seq, 5)::INT]
        WHEN 5 THEN 'Prime Contractor - ' || ARRAY_CONSTRUCT('Lockheed Martin', 'Northrop Grumman', 'Boeing', 'Raytheon', 'General Dynamics')[MOD(seq, 5)::INT]
        WHEN 6 THEN 'Allied Nation - ' || ARRAY_CONSTRUCT('UK MOD', 'Australian DoD', 'Japan MOD', 'Israel MOD', 'NATO')[MOD(seq, 5)::INT]
        WHEN 7 THEN 'US Marines - ' || ARRAY_CONSTRUCT('MARCORSYSCOM', 'MCCDC', 'MCSC', 'TECOM', 'MARFORPAC')[MOD(seq, 5)::INT]
        WHEN 8 THEN 'Intelligence Community - ' || ARRAY_CONSTRUCT('CIA', 'NRO', 'NSA-CSS', 'DIA', 'ODNI')[MOD(seq, 5)::INT]
        ELSE 'DHS - ' || ARRAY_CONSTRUCT('CBP', 'TSA', 'USCG', 'CISA', 'Secret Service')[MOD(seq, 5)::INT]
    END AS customer_name,
    CASE MOD(seq, 5)
        WHEN 0 THEN 'MILITARY_SERVICE'
        WHEN 1 THEN 'DEFENSE_AGENCY'
        WHEN 2 THEN 'PRIME_CONTRACTOR'
        WHEN 3 THEN 'ALLIED_NATION'
        ELSE 'INTELLIGENCE_COMMUNITY'
    END AS customer_type,
    CASE MOD(seq, 4)
        WHEN 0 THEN 'DIRECT_GOVERNMENT'
        WHEN 1 THEN 'PRIME_CONTRACT'
        WHEN 2 THEN 'SUBCONTRACT'
        ELSE 'FMS'
    END AS customer_category,
    CASE MOD(seq, 6)
        WHEN 0 THEN 'Air Force'
        WHEN 1 THEN 'Navy'
        WHEN 2 THEN 'Army'
        WHEN 3 THEN 'Space Force'
        WHEN 4 THEN 'Marines'
        ELSE 'Joint'
    END AS agency_branch,
    CASE WHEN MOD(seq, 10) = 6 THEN 
        ARRAY_CONSTRUCT('UK', 'Australia', 'Japan', 'Israel', 'Germany')[MOD(seq, 5)::INT]
    ELSE 'USA' END AS country,
    CASE MOD(seq, 4)
        WHEN 0 THEN 'SECRET'
        WHEN 1 THEN 'TOP SECRET'
        WHEN 2 THEN 'TOP SECRET/SCI'
        ELSE 'CONFIDENTIAL'
    END AS security_clearance_required,
    'ACTIVE' AS relationship_status,
    DATEADD('day', -UNIFORM(365, 3650, RANDOM()), CURRENT_DATE()) AS first_contract_date,
    UNIFORM(10000000, 500000000, RANDOM())::NUMBER(18,2) AS total_contract_value
FROM TABLE(GENERATOR(ROWCOUNT => 50)) g,
     LATERAL (SELECT SEQ4() AS seq) s;

-- ============================================================================
-- Step 3: Generate PROGRAMS (200 programs)
-- ============================================================================
INSERT INTO PROGRAMS (
    program_id, division_id, program_code, program_name, program_type,
    program_category, customer_id, prime_contractor, contract_type, program_status,
    program_phase, security_classification, start_date, planned_end_date,
    total_contract_value, funded_value, costs_incurred, revenue_recognized,
    margin_percentage, program_manager, technical_lead, risk_level
)
SELECT
    'PRG' || LPAD(ROW_NUMBER() OVER (ORDER BY seq)::VARCHAR, 6, '0') AS program_id,
    'DIV00' || (MOD(seq, 9) + 1)::VARCHAR AS division_id,
    'PRG-' || LPAD(ROW_NUMBER() OVER (ORDER BY seq)::VARCHAR, 4, '0') AS program_code,
    CASE MOD(seq, 9)
        WHEN 0 THEN ARRAY_CONSTRUCT('XQ-58A Valkyrie', 'BQM-167 Skeeter', 'MQM-178 Firejet', 'UTAP-22 Mako', 'Gremlins')[MOD(seq, 5)::INT] || ' Program'
        WHEN 1 THEN ARRAY_CONSTRUCT('GPS OCX', 'AEHF', 'WGS', 'SBIRS', 'OPIR')[MOD(seq, 5)::INT] || ' Ground System'
        WHEN 2 THEN ARRAY_CONSTRUCT('Erinyes', 'Dark Fury', 'Mako', 'Valkyrie Strike', 'Hypersonic Glide')[MOD(seq, 5)::INT] || ' Hypersonic'
        WHEN 3 THEN ARRAY_CONSTRUCT('TJ150', 'TJ50', 'Zeus SRM', 'GEK-38', 'RP-3000')[MOD(seq, 5)::INT] || ' Propulsion'
        WHEN 4 THEN ARRAY_CONSTRUCT('AESA Radar', 'EW Suite', 'SATCOM Terminal', 'Seeker Head', 'Power Amplifier')[MOD(seq, 5)::INT] || ' Electronics'
        WHEN 5 THEN ARRAY_CONSTRUCT('Zero Trust', 'JADC2 Cyber', 'Critical Infrastructure', 'Offensive Cyber', 'Defense Cyber')[MOD(seq, 5)::INT] || ' Security'
        WHEN 6 THEN ARRAY_CONSTRUCT('GMD', 'THAAD Support', 'PAC-3 Integration', 'SM-3 Components', 'Aegis Support')[MOD(seq, 5)::INT] || ' Defense'
        WHEN 7 THEN ARRAY_CONSTRUCT('IBCS', 'ABMS', 'CJADC2', 'Tactical Network', 'Battle Management')[MOD(seq, 5)::INT] || ' C5ISR'
        ELSE ARRAY_CONSTRUCT('F-35 Trainer', 'MQ-9 Sim', 'Ground Vehicle Sim', 'Helo Trainer', 'Combined Arms')[MOD(seq, 5)::INT] || ' Training'
    END AS program_name,
    CASE MOD(seq, 5)
        WHEN 0 THEN 'DEVELOPMENT'
        WHEN 1 THEN 'PRODUCTION'
        WHEN 2 THEN 'SUSTAINMENT'
        WHEN 3 THEN 'RDT_E'
        ELSE 'SERVICES'
    END AS program_type,
    CASE MOD(seq, 4)
        WHEN 0 THEN 'ACAT_I'
        WHEN 1 THEN 'ACAT_II'
        WHEN 2 THEN 'ACAT_III'
        ELSE 'OTHER'
    END AS program_category,
    'CUST' || LPAD((MOD(seq, 50) + 1)::VARCHAR, 5, '0') AS customer_id,
    CASE WHEN MOD(seq, 3) = 0 THEN 'Kratos Defense' ELSE NULL END AS prime_contractor,
    CASE MOD(seq, 5)
        WHEN 0 THEN 'CPFF'
        WHEN 1 THEN 'FFP'
        WHEN 2 THEN 'CPIF'
        WHEN 3 THEN 'T_M'
        ELSE 'IDIQ'
    END AS contract_type,
    CASE MOD(seq, 10)
        WHEN 0 THEN 'COMPLETED'
        WHEN 1 THEN 'ON_HOLD'
        ELSE 'ACTIVE'
    END AS program_status,
    CASE MOD(seq, 5)
        WHEN 0 THEN 'PHASE_1'
        WHEN 1 THEN 'PHASE_2'
        WHEN 2 THEN 'EMD'
        WHEN 3 THEN 'LRIP'
        ELSE 'FRP'
    END AS program_phase,
    CASE MOD(seq, 4)
        WHEN 0 THEN 'UNCLASSIFIED'
        WHEN 1 THEN 'CONFIDENTIAL'
        WHEN 2 THEN 'SECRET'
        ELSE 'TOP SECRET'
    END AS security_classification,
    DATEADD('day', -UNIFORM(365, 2555, RANDOM()), CURRENT_DATE()) AS start_date,
    DATEADD('day', UNIFORM(180, 1825, RANDOM()), CURRENT_DATE()) AS planned_end_date,
    UNIFORM(5000000, 250000000, RANDOM())::NUMBER(18,2) AS total_contract_value,
    UNIFORM(2000000, 200000000, RANDOM())::NUMBER(18,2) AS funded_value,
    UNIFORM(1000000, 150000000, RANDOM())::NUMBER(18,2) AS costs_incurred,
    UNIFORM(1000000, 140000000, RANDOM())::NUMBER(18,2) AS revenue_recognized,
    UNIFORM(5, 25, RANDOM())::NUMBER(5,2) AS margin_percentage,
    ARRAY_CONSTRUCT('John Smith', 'Mary Johnson', 'Robert Williams', 'Patricia Brown', 'Michael Davis', 'Jennifer Wilson', 'David Anderson', 'Linda Martinez')[MOD(seq, 8)::INT] AS program_manager,
    ARRAY_CONSTRUCT('Dr. James Taylor', 'Dr. Sarah Thomas', 'Dr. William Jackson', 'Dr. Elizabeth White', 'Dr. Charles Harris')[MOD(seq, 5)::INT] AS technical_lead,
    CASE MOD(seq, 5)
        WHEN 0 THEN 'LOW'
        WHEN 1 THEN 'MEDIUM'
        WHEN 2 THEN 'MEDIUM'
        WHEN 3 THEN 'HIGH'
        ELSE 'MEDIUM'
    END AS risk_level
FROM TABLE(GENERATOR(ROWCOUNT => 200)) g,
     LATERAL (SELECT SEQ4() AS seq) s;

-- ============================================================================
-- Step 4: Generate CONTRACTS (300 contracts)
-- ============================================================================
INSERT INTO CONTRACTS (
    contract_id, program_id, customer_id, contract_number, contract_name,
    contract_type, contract_vehicle, award_date, start_date, end_date,
    period_of_performance_months, base_value, option_value, total_value,
    funded_amount, contract_status, modification_count, security_classification,
    contracting_officer
)
SELECT
    'CON' || LPAD(ROW_NUMBER() OVER (ORDER BY seq)::VARCHAR, 6, '0') AS contract_id,
    'PRG' || LPAD((MOD(seq, 200) + 1)::VARCHAR, 6, '0') AS program_id,
    'CUST' || LPAD((MOD(seq, 50) + 1)::VARCHAR, 5, '0') AS customer_id,
    'FA8650-' || (2020 + MOD(seq, 5))::VARCHAR || '-C-' || LPAD(ROW_NUMBER() OVER (ORDER BY seq)::VARCHAR, 4, '0') AS contract_number,
    'Contract for ' || CASE MOD(seq, 5)
        WHEN 0 THEN 'Development Services'
        WHEN 1 THEN 'Production Support'
        WHEN 2 THEN 'Engineering Services'
        WHEN 3 THEN 'Sustainment Operations'
        ELSE 'Technical Support'
    END AS contract_name,
    CASE MOD(seq, 5)
        WHEN 0 THEN 'CPFF'
        WHEN 1 THEN 'FFP'
        WHEN 2 THEN 'CPIF'
        WHEN 3 THEN 'T_M'
        ELSE 'IDIQ'
    END AS contract_type,
    CASE MOD(seq, 4)
        WHEN 0 THEN 'GSA Schedule'
        WHEN 1 THEN 'SEWP V'
        WHEN 2 THEN 'OASIS'
        ELSE 'Direct Award'
    END AS contract_vehicle,
    DATEADD('day', -UNIFORM(180, 1825, RANDOM()), CURRENT_DATE()) AS award_date,
    DATEADD('day', -UNIFORM(90, 1460, RANDOM()), CURRENT_DATE()) AS start_date,
    DATEADD('day', UNIFORM(180, 1825, RANDOM()), CURRENT_DATE()) AS end_date,
    UNIFORM(12, 60, RANDOM()) AS period_of_performance_months,
    UNIFORM(1000000, 50000000, RANDOM())::NUMBER(18,2) AS base_value,
    UNIFORM(500000, 25000000, RANDOM())::NUMBER(18,2) AS option_value,
    UNIFORM(2000000, 75000000, RANDOM())::NUMBER(18,2) AS total_value,
    UNIFORM(1000000, 50000000, RANDOM())::NUMBER(18,2) AS funded_amount,
    CASE MOD(seq, 10)
        WHEN 0 THEN 'COMPLETED'
        WHEN 1 THEN 'PENDING'
        ELSE 'ACTIVE'
    END AS contract_status,
    UNIFORM(0, 15, RANDOM()) AS modification_count,
    CASE MOD(seq, 3)
        WHEN 0 THEN 'UNCLASSIFIED'
        WHEN 1 THEN 'SECRET'
        ELSE 'TOP SECRET'
    END AS security_classification,
    ARRAY_CONSTRUCT('Maj. Johnson', 'Lt. Col. Smith', 'Col. Williams', 'Capt. Brown', 'Maj. Davis')[MOD(seq, 5)::INT] AS contracting_officer
FROM TABLE(GENERATOR(ROWCOUNT => 300)) g,
     LATERAL (SELECT SEQ4() AS seq) s;

-- ============================================================================
-- Step 5: Generate MILESTONES (1000 milestones)
-- ============================================================================
INSERT INTO MILESTONES (
    milestone_id, program_id, milestone_code, milestone_name, milestone_type,
    planned_date, actual_date, milestone_status, deliverable_required,
    payment_milestone, payment_amount, completion_percentage
)
SELECT
    'MS' || LPAD(ROW_NUMBER() OVER (ORDER BY seq)::VARCHAR, 7, '0') AS milestone_id,
    'PRG' || LPAD((MOD(seq, 200) + 1)::VARCHAR, 6, '0') AS program_id,
    'MS-' || LPAD(ROW_NUMBER() OVER (ORDER BY seq)::VARCHAR, 5, '0') AS milestone_code,
    CASE MOD(seq, 10)
        WHEN 0 THEN 'System Requirements Review'
        WHEN 1 THEN 'Preliminary Design Review'
        WHEN 2 THEN 'Critical Design Review'
        WHEN 3 THEN 'Test Readiness Review'
        WHEN 4 THEN 'First Article Delivery'
        WHEN 5 THEN 'Qualification Testing Complete'
        WHEN 6 THEN 'Production Readiness Review'
        WHEN 7 THEN 'Lot Acceptance Test'
        WHEN 8 THEN 'Final Delivery'
        ELSE 'Program Closeout'
    END AS milestone_name,
    CASE MOD(seq, 5)
        WHEN 0 THEN 'REVIEW'
        WHEN 1 THEN 'DELIVERY'
        WHEN 2 THEN 'TEST'
        WHEN 3 THEN 'PRODUCTION'
        ELSE 'CONTRACTUAL'
    END AS milestone_type,
    DATEADD('day', UNIFORM(-365, 730, RANDOM()), CURRENT_DATE()) AS planned_date,
    CASE WHEN MOD(seq, 3) < 2 THEN DATEADD('day', UNIFORM(-400, 30, RANDOM()), CURRENT_DATE()) ELSE NULL END AS actual_date,
    CASE MOD(seq, 5)
        WHEN 0 THEN 'COMPLETED'
        WHEN 1 THEN 'COMPLETED'
        WHEN 2 THEN 'ON_TRACK'
        WHEN 3 THEN 'AT_RISK'
        ELSE 'PENDING'
    END AS milestone_status,
    CASE WHEN MOD(seq, 3) = 0 THEN TRUE ELSE FALSE END AS deliverable_required,
    CASE WHEN MOD(seq, 4) = 0 THEN TRUE ELSE FALSE END AS payment_milestone,
    CASE WHEN MOD(seq, 4) = 0 THEN UNIFORM(100000, 5000000, RANDOM())::NUMBER(15,2) ELSE NULL END AS payment_amount,
    CASE MOD(seq, 5)
        WHEN 0 THEN 100.00
        WHEN 1 THEN 100.00
        WHEN 2 THEN UNIFORM(50, 90, RANDOM())::NUMBER(5,2)
        WHEN 3 THEN UNIFORM(20, 60, RANDOM())::NUMBER(5,2)
        ELSE 0.00
    END AS completion_percentage
FROM TABLE(GENERATOR(ROWCOUNT => 1000)) g,
     LATERAL (SELECT SEQ4() AS seq) s;

-- ============================================================================
-- Step 6: Generate ASSETS (500 assets)
-- ============================================================================
INSERT INTO ASSETS (
    asset_id, division_id, program_id, asset_serial_number, asset_name,
    asset_type, asset_category, asset_model, manufacturer, manufacture_date,
    acquisition_date, acquisition_cost, current_value, asset_status,
    operational_status, location, total_flight_hours, total_missions,
    last_maintenance_date, next_maintenance_due, maintenance_interval_hours,
    software_version, firmware_version, security_classification
)
SELECT
    'AST' || LPAD(ROW_NUMBER() OVER (ORDER BY seq)::VARCHAR, 6, '0') AS asset_id,
    'DIV00' || (MOD(seq, 9) + 1)::VARCHAR AS division_id,
    'PRG' || LPAD((MOD(seq, 200) + 1)::VARCHAR, 6, '0') AS program_id,
    'SN-' || LPAD(ROW_NUMBER() OVER (ORDER BY seq)::VARCHAR, 8, '0') AS asset_serial_number,
    CASE MOD(seq, 9)
        WHEN 0 THEN ARRAY_CONSTRUCT('XQ-58A-', 'BQM-167-', 'MQM-178-', 'UTAP-22-', 'Drone-')[MOD(seq, 5)::INT]
        WHEN 1 THEN ARRAY_CONSTRUCT('Ground Station-', 'Terminal-', 'Antenna-', 'Modem-', 'Processor-')[MOD(seq, 5)::INT]
        WHEN 2 THEN ARRAY_CONSTRUCT('Hypersonic Test-', 'Glide Vehicle-', 'Booster-', 'Payload-', 'Test Article-')[MOD(seq, 5)::INT]
        WHEN 3 THEN ARRAY_CONSTRUCT('TJ150-', 'TJ50-', 'Zeus-', 'GEK38-', 'Engine-')[MOD(seq, 5)::INT]
        WHEN 4 THEN ARRAY_CONSTRUCT('Radar Unit-', 'EW Pod-', 'Amplifier-', 'Seeker-', 'Electronics-')[MOD(seq, 5)::INT]
        WHEN 5 THEN ARRAY_CONSTRUCT('Server-', 'Workstation-', 'Network Device-', 'Sensor-', 'Crypto-')[MOD(seq, 5)::INT]
        WHEN 6 THEN ARRAY_CONSTRUCT('Interceptor-', 'Kill Vehicle-', 'Sensor Suite-', 'Radar-', 'Defense Unit-')[MOD(seq, 5)::INT]
        WHEN 7 THEN ARRAY_CONSTRUCT('C2 Node-', 'Radio-', 'Gateway-', 'Display-', 'Processor-')[MOD(seq, 5)::INT]
        ELSE ARRAY_CONSTRUCT('Simulator-', 'Trainer-', 'Mock-up-', 'Display System-', 'Training Aid-')[MOD(seq, 5)::INT]
    END || LPAD(ROW_NUMBER() OVER (ORDER BY seq)::VARCHAR, 4, '0') AS asset_name,
    CASE MOD(seq, 5)
        WHEN 0 THEN 'UAV'
        WHEN 1 THEN 'GROUND_SYSTEM'
        WHEN 2 THEN 'ENGINE'
        WHEN 3 THEN 'ELECTRONICS'
        ELSE 'SIMULATOR'
    END AS asset_type,
    CASE MOD(seq, 4)
        WHEN 0 THEN 'TACTICAL'
        WHEN 1 THEN 'STRATEGIC'
        WHEN 2 THEN 'TRAINING'
        ELSE 'TEST'
    END AS asset_category,
    CASE MOD(seq, 5)
        WHEN 0 THEN 'Block 1'
        WHEN 1 THEN 'Block 2'
        WHEN 2 THEN 'Block 3'
        WHEN 3 THEN 'Mod A'
        ELSE 'Mod B'
    END AS asset_model,
    'Kratos Defense' AS manufacturer,
    DATEADD('day', -UNIFORM(365, 2555, RANDOM()), CURRENT_DATE()) AS manufacture_date,
    DATEADD('day', -UNIFORM(180, 2190, RANDOM()), CURRENT_DATE()) AS acquisition_date,
    UNIFORM(100000, 5000000, RANDOM())::NUMBER(15,2) AS acquisition_cost,
    UNIFORM(50000, 4000000, RANDOM())::NUMBER(15,2) AS current_value,
    CASE MOD(seq, 10)
        WHEN 0 THEN 'MAINTENANCE'
        WHEN 1 THEN 'STORAGE'
        ELSE 'OPERATIONAL'
    END AS asset_status,
    CASE MOD(seq, 5)
        WHEN 0 THEN 'AVAILABLE'
        WHEN 1 THEN 'DEPLOYED'
        WHEN 2 THEN 'TESTING'
        WHEN 3 THEN 'MAINTENANCE'
        ELSE 'AVAILABLE'
    END AS operational_status,
    ARRAY_CONSTRUCT('Oklahoma City, OK', 'Colorado Springs, CO', 'Huntsville, AL', 'San Diego, CA', 'Orlando, FL', 'Fort Worth, TX', 'Tucson, AZ', 'Sacramento, CA')[MOD(seq, 8)::INT] AS location,
    UNIFORM(0, 5000, RANDOM())::NUMBER(10,2) AS total_flight_hours,
    UNIFORM(0, 500, RANDOM()) AS total_missions,
    DATEADD('day', -UNIFORM(30, 180, RANDOM()), CURRENT_DATE()) AS last_maintenance_date,
    DATEADD('day', UNIFORM(30, 180, RANDOM()), CURRENT_DATE()) AS next_maintenance_due,
    UNIFORM(100, 500, RANDOM()) AS maintenance_interval_hours,
    'v' || UNIFORM(1, 5, RANDOM())::VARCHAR || '.' || UNIFORM(0, 9, RANDOM())::VARCHAR || '.' || UNIFORM(0, 9, RANDOM())::VARCHAR AS software_version,
    'fw' || UNIFORM(1, 3, RANDOM())::VARCHAR || '.' || UNIFORM(0, 9, RANDOM())::VARCHAR AS firmware_version,
    CASE MOD(seq, 3)
        WHEN 0 THEN 'UNCLASSIFIED'
        WHEN 1 THEN 'SECRET'
        ELSE 'TOP SECRET'
    END AS security_classification
FROM TABLE(GENERATOR(ROWCOUNT => 500)) g,
     LATERAL (SELECT SEQ4() AS seq) s;

-- ============================================================================
-- Step 7: Generate ASSET_OPERATIONS (10000 operations)
-- ============================================================================
INSERT INTO ASSET_OPERATIONS (
    operation_id, asset_id, program_id, operation_date, operation_type,
    mission_type, mission_name, location, flight_hours, cycles,
    fuel_consumed, altitude_max, speed_max, distance_traveled,
    operation_status, pilot_operator, weather_conditions, mission_success,
    anomalies_detected
)
SELECT
    'OPS' || LPAD(ROW_NUMBER() OVER (ORDER BY seq)::VARCHAR, 8, '0') AS operation_id,
    'AST' || LPAD((MOD(seq, 500) + 1)::VARCHAR, 6, '0') AS asset_id,
    'PRG' || LPAD((MOD(seq, 200) + 1)::VARCHAR, 6, '0') AS program_id,
    DATEADD('day', -UNIFORM(1, 730, RANDOM()), CURRENT_DATE()) AS operation_date,
    CASE MOD(seq, 5)
        WHEN 0 THEN 'FLIGHT'
        WHEN 1 THEN 'TEST'
        WHEN 2 THEN 'TRAINING'
        WHEN 3 THEN 'MAINTENANCE_RUN'
        ELSE 'DEMONSTRATION'
    END AS operation_type,
    CASE MOD(seq, 5)
        WHEN 0 THEN 'RECONNAISSANCE'
        WHEN 1 THEN 'TARGET'
        WHEN 2 THEN 'LOYAL_WINGMAN'
        WHEN 3 THEN 'GROUND_TEST'
        ELSE 'FERRY'
    END AS mission_type,
    'Mission-' || LPAD(ROW_NUMBER() OVER (ORDER BY seq)::VARCHAR, 6, '0') AS mission_name,
    ARRAY_CONSTRUCT('White Sands, NM', 'Edwards AFB, CA', 'Eglin AFB, FL', 'China Lake, CA', 'Point Mugu, CA', 'Dugway, UT')[MOD(seq, 6)::INT] AS location,
    UNIFORM(1, 8, RANDOM())::NUMBER(6,2) AS flight_hours,
    UNIFORM(1, 5, RANDOM()) AS cycles,
    UNIFORM(100, 2000, RANDOM())::NUMBER(10,2) AS fuel_consumed,
    UNIFORM(5000, 50000, RANDOM()) AS altitude_max,
    UNIFORM(100, 700, RANDOM()) AS speed_max,
    UNIFORM(50, 500, RANDOM())::NUMBER(10,2) AS distance_traveled,
    CASE WHEN MOD(seq, 20) = 0 THEN 'ABORTED' ELSE 'COMPLETED' END AS operation_status,
    ARRAY_CONSTRUCT('Operator Smith', 'Operator Johnson', 'Operator Williams', 'Operator Brown', 'Operator Davis')[MOD(seq, 5)::INT] AS pilot_operator,
    CASE MOD(seq, 4)
        WHEN 0 THEN 'CLEAR'
        WHEN 1 THEN 'PARTLY_CLOUDY'
        WHEN 2 THEN 'OVERCAST'
        ELSE 'MARGINAL'
    END AS weather_conditions,
    CASE WHEN MOD(seq, 25) = 0 THEN FALSE ELSE TRUE END AS mission_success,
    CASE WHEN MOD(seq, 10) = 0 THEN UNIFORM(1, 3, RANDOM()) ELSE 0 END AS anomalies_detected
FROM TABLE(GENERATOR(ROWCOUNT => 10000)) g,
     LATERAL (SELECT SEQ4() AS seq) s;

-- ============================================================================
-- Step 8: Generate MAINTENANCE_RECORDS (5000 records)
-- ============================================================================
INSERT INTO MAINTENANCE_RECORDS (
    maintenance_id, asset_id, maintenance_date, maintenance_type,
    maintenance_category, work_order_number, description, parts_replaced,
    labor_hours, parts_cost, labor_cost, total_cost, technician_name,
    technician_certification, maintenance_status, flight_hours_at_maintenance,
    next_maintenance_hours, quality_inspection_passed
)
SELECT
    'MNT' || LPAD(ROW_NUMBER() OVER (ORDER BY seq)::VARCHAR, 7, '0') AS maintenance_id,
    'AST' || LPAD((MOD(seq, 500) + 1)::VARCHAR, 6, '0') AS asset_id,
    DATEADD('day', -UNIFORM(1, 730, RANDOM()), CURRENT_DATE()) AS maintenance_date,
    CASE MOD(seq, 5)
        WHEN 0 THEN 'SCHEDULED'
        WHEN 1 THEN 'UNSCHEDULED'
        WHEN 2 THEN 'INSPECTION'
        WHEN 3 THEN 'OVERHAUL'
        ELSE 'MODIFICATION'
    END AS maintenance_type,
    CASE MOD(seq, 5)
        WHEN 0 THEN 'AIRFRAME'
        WHEN 1 THEN 'ENGINE'
        WHEN 2 THEN 'AVIONICS'
        WHEN 3 THEN 'PAYLOAD'
        ELSE 'GROUND_SUPPORT'
    END AS maintenance_category,
    'WO-' || LPAD(ROW_NUMBER() OVER (ORDER BY seq)::VARCHAR, 8, '0') AS work_order_number,
    CASE MOD(seq, 5)
        WHEN 0 THEN 'Routine scheduled maintenance per technical manual'
        WHEN 1 THEN 'Corrective maintenance for reported discrepancy'
        WHEN 2 THEN 'Phase inspection completed'
        WHEN 3 THEN 'Major overhaul of propulsion system'
        ELSE 'Engineering change order implementation'
    END AS description,
    CASE WHEN MOD(seq, 3) = 0 THEN 'Various consumables and seals' ELSE NULL END AS parts_replaced,
    UNIFORM(2, 40, RANDOM())::NUMBER(6,2) AS labor_hours,
    UNIFORM(100, 25000, RANDOM())::NUMBER(12,2) AS parts_cost,
    UNIFORM(200, 8000, RANDOM())::NUMBER(12,2) AS labor_cost,
    UNIFORM(500, 30000, RANDOM())::NUMBER(12,2) AS total_cost,
    ARRAY_CONSTRUCT('Tech. Anderson', 'Tech. Martinez', 'Tech. Thompson', 'Tech. Garcia', 'Tech. Rodriguez')[MOD(seq, 5)::INT] AS technician_name,
    CASE MOD(seq, 3)
        WHEN 0 THEN 'A&P Licensed'
        WHEN 1 THEN 'IA Certified'
        ELSE 'Factory Trained'
    END AS technician_certification,
    CASE WHEN MOD(seq, 20) = 0 THEN 'IN_PROGRESS' ELSE 'COMPLETED' END AS maintenance_status,
    UNIFORM(100, 3000, RANDOM())::NUMBER(10,2) AS flight_hours_at_maintenance,
    UNIFORM(200, 500, RANDOM())::NUMBER(10,2) AS next_maintenance_hours,
    CASE WHEN MOD(seq, 50) = 0 THEN FALSE ELSE TRUE END AS quality_inspection_passed
FROM TABLE(GENERATOR(ROWCOUNT => 5000)) g,
     LATERAL (SELECT SEQ4() AS seq) s;

-- ============================================================================
-- Step 9: Generate MANUFACTURING_ORDERS (2000 orders)
-- ============================================================================
INSERT INTO MANUFACTURING_ORDERS (
    order_id, division_id, program_id, order_number, order_type,
    product_name, product_type, quantity_ordered, quantity_completed,
    quantity_scrapped, unit_cost, total_cost, order_date, required_date,
    start_date, completion_date, order_status, priority, production_line
)
SELECT
    'MFG' || LPAD(ROW_NUMBER() OVER (ORDER BY seq)::VARCHAR, 6, '0') AS order_id,
    'DIV00' || (MOD(seq, 9) + 1)::VARCHAR AS division_id,
    'PRG' || LPAD((MOD(seq, 200) + 1)::VARCHAR, 6, '0') AS program_id,
    'MO-' || LPAD(ROW_NUMBER() OVER (ORDER BY seq)::VARCHAR, 6, '0') AS order_number,
    CASE MOD(seq, 5)
        WHEN 0 THEN 'PRODUCTION'
        WHEN 1 THEN 'PROTOTYPE'
        WHEN 2 THEN 'SPARE_PARTS'
        WHEN 3 THEN 'REPAIR'
        ELSE 'MODIFICATION'
    END AS order_type,
    CASE MOD(seq, 5)
        WHEN 0 THEN 'Airframe Assembly'
        WHEN 1 THEN 'Engine Module'
        WHEN 2 THEN 'Avionics Package'
        WHEN 3 THEN 'Structural Component'
        ELSE 'Integration Kit'
    END AS product_name,
    CASE MOD(seq, 5)
        WHEN 0 THEN 'AIRFRAME'
        WHEN 1 THEN 'ENGINE'
        WHEN 2 THEN 'AVIONICS'
        WHEN 3 THEN 'STRUCTURES'
        ELSE 'SYSTEMS'
    END AS product_type,
    UNIFORM(1, 50, RANDOM()) AS quantity_ordered,
    UNIFORM(0, 45, RANDOM()) AS quantity_completed,
    UNIFORM(0, 3, RANDOM()) AS quantity_scrapped,
    UNIFORM(5000, 500000, RANDOM())::NUMBER(12,2) AS unit_cost,
    UNIFORM(10000, 2500000, RANDOM())::NUMBER(15,2) AS total_cost,
    DATEADD('day', -UNIFORM(30, 365, RANDOM()), CURRENT_DATE()) AS order_date,
    DATEADD('day', UNIFORM(30, 180, RANDOM()), CURRENT_DATE()) AS required_date,
    DATEADD('day', -UNIFORM(1, 60, RANDOM()), CURRENT_DATE()) AS start_date,
    CASE WHEN MOD(seq, 3) < 2 THEN DATEADD('day', UNIFORM(1, 90, RANDOM()), CURRENT_DATE()) ELSE NULL END AS completion_date,
    CASE MOD(seq, 5)
        WHEN 0 THEN 'COMPLETED'
        WHEN 1 THEN 'IN_PROGRESS'
        WHEN 2 THEN 'IN_PROGRESS'
        WHEN 3 THEN 'PENDING'
        ELSE 'ON_HOLD'
    END AS order_status,
    CASE MOD(seq, 4)
        WHEN 0 THEN 'NORMAL'
        WHEN 1 THEN 'HIGH'
        WHEN 2 THEN 'CRITICAL'
        ELSE 'LOW'
    END AS priority,
    'Line-' || (MOD(seq, 10) + 1)::VARCHAR AS production_line
FROM TABLE(GENERATOR(ROWCOUNT => 2000)) g,
     LATERAL (SELECT SEQ4() AS seq) s;

-- ============================================================================
-- Step 10: Generate QUALITY_INSPECTIONS (3000 inspections)
-- ============================================================================
INSERT INTO QUALITY_INSPECTIONS (
    inspection_id, order_id, inspection_date, inspection_type,
    inspection_category, inspector_name, inspector_certification,
    inspection_result, defects_found, quality_score, corrective_action_required
)
SELECT
    'QI' || LPAD(ROW_NUMBER() OVER (ORDER BY seq)::VARCHAR, 7, '0') AS inspection_id,
    'MFG' || LPAD((MOD(seq, 2000) + 1)::VARCHAR, 6, '0') AS order_id,
    DATEADD('day', -UNIFORM(1, 365, RANDOM()), CURRENT_DATE()) AS inspection_date,
    CASE MOD(seq, 5)
        WHEN 0 THEN 'INCOMING'
        WHEN 1 THEN 'IN_PROCESS'
        WHEN 2 THEN 'FINAL'
        WHEN 3 THEN 'RECEIVING'
        ELSE 'FIRST_ARTICLE'
    END AS inspection_type,
    CASE MOD(seq, 4)
        WHEN 0 THEN 'DIMENSIONAL'
        WHEN 1 THEN 'FUNCTIONAL'
        WHEN 2 THEN 'VISUAL'
        ELSE 'NDT'
    END AS inspection_category,
    ARRAY_CONSTRUCT('QC Smith', 'QC Johnson', 'QC Williams', 'QC Brown', 'QC Davis')[MOD(seq, 5)::INT] AS inspector_name,
    CASE MOD(seq, 3)
        WHEN 0 THEN 'ASQ CQI'
        WHEN 1 THEN 'AS9100 Auditor'
        ELSE 'NADCAP Certified'
    END AS inspector_certification,
    CASE MOD(seq, 20)
        WHEN 0 THEN 'FAIL'
        WHEN 1 THEN 'CONDITIONAL'
        ELSE 'PASS'
    END AS inspection_result,
    CASE WHEN MOD(seq, 10) = 0 THEN UNIFORM(1, 5, RANDOM()) ELSE 0 END AS defects_found,
    UNIFORM(75, 100, RANDOM())::NUMBER(5,2) AS quality_score,
    CASE WHEN MOD(seq, 15) = 0 THEN TRUE ELSE FALSE END AS corrective_action_required
FROM TABLE(GENERATOR(ROWCOUNT => 3000)) g,
     LATERAL (SELECT SEQ4() AS seq) s;

-- ============================================================================
-- Step 11: Generate ENGINEERING_PROJECTS (300 projects)
-- ============================================================================
INSERT INTO ENGINEERING_PROJECTS (
    project_id, division_id, program_id, project_code, project_name,
    project_type, project_category, project_status, project_phase,
    technology_readiness_level, start_date, planned_end_date, budget,
    actual_cost, team_size, ip_generated, patents_filed, risk_level
)
SELECT
    'ENG' || LPAD(ROW_NUMBER() OVER (ORDER BY seq)::VARCHAR, 6, '0') AS project_id,
    'DIV00' || (MOD(seq, 9) + 1)::VARCHAR AS division_id,
    'PRG' || LPAD((MOD(seq, 200) + 1)::VARCHAR, 6, '0') AS program_id,
    'ENG-' || LPAD(ROW_NUMBER() OVER (ORDER BY seq)::VARCHAR, 4, '0') AS project_code,
    CASE MOD(seq, 5)
        WHEN 0 THEN 'Advanced Propulsion Study'
        WHEN 1 THEN 'Autonomous Systems Development'
        WHEN 2 THEN 'Materials Research Initiative'
        WHEN 3 THEN 'Software Modernization'
        ELSE 'Sensor Integration Project'
    END || ' ' || LPAD(ROW_NUMBER() OVER (ORDER BY seq)::VARCHAR, 3, '0') AS project_name,
    CASE MOD(seq, 5)
        WHEN 0 THEN 'R_D'
        WHEN 1 THEN 'IRAD'
        WHEN 2 THEN 'CRAD'
        WHEN 3 THEN 'PRODUCTION_IMPROVEMENT'
        ELSE 'SUSTAINMENT'
    END AS project_type,
    CASE MOD(seq, 5)
        WHEN 0 THEN 'ADVANCED_TECH'
        WHEN 1 THEN 'MANUFACTURING'
        WHEN 2 THEN 'SOFTWARE'
        WHEN 3 THEN 'SYSTEMS'
        ELSE 'TESTING'
    END AS project_category,
    CASE MOD(seq, 5)
        WHEN 0 THEN 'ACTIVE'
        WHEN 1 THEN 'ACTIVE'
        WHEN 2 THEN 'ACTIVE'
        WHEN 3 THEN 'COMPLETED'
        ELSE 'ON_HOLD'
    END AS project_status,
    CASE MOD(seq, 5)
        WHEN 0 THEN 'CONCEPT'
        WHEN 1 THEN 'DESIGN'
        WHEN 2 THEN 'DEVELOPMENT'
        WHEN 3 THEN 'TEST'
        ELSE 'PRODUCTION'
    END AS project_phase,
    UNIFORM(1, 9, RANDOM()) AS technology_readiness_level,
    DATEADD('day', -UNIFORM(90, 730, RANDOM()), CURRENT_DATE()) AS start_date,
    DATEADD('day', UNIFORM(90, 730, RANDOM()), CURRENT_DATE()) AS planned_end_date,
    UNIFORM(100000, 5000000, RANDOM())::NUMBER(15,2) AS budget,
    UNIFORM(50000, 4000000, RANDOM())::NUMBER(15,2) AS actual_cost,
    UNIFORM(3, 25, RANDOM()) AS team_size,
    CASE WHEN MOD(seq, 5) = 0 THEN TRUE ELSE FALSE END AS ip_generated,
    CASE WHEN MOD(seq, 10) = 0 THEN UNIFORM(1, 3, RANDOM()) ELSE 0 END AS patents_filed,
    CASE MOD(seq, 5)
        WHEN 0 THEN 'LOW'
        WHEN 1 THEN 'MEDIUM'
        WHEN 2 THEN 'MEDIUM'
        WHEN 3 THEN 'HIGH'
        ELSE 'MEDIUM'
    END AS risk_level
FROM TABLE(GENERATOR(ROWCOUNT => 300)) g,
     LATERAL (SELECT SEQ4() AS seq) s;

-- ============================================================================
-- Step 12: Generate TEST_EVENTS (2000 tests)
-- ============================================================================
INSERT INTO TEST_EVENTS (
    test_id, project_id, asset_id, program_id, test_number, test_name,
    test_type, test_category, test_date, test_location, test_duration_hours,
    test_status, test_result, success_criteria_met, anomalies_count, test_conductor
)
SELECT
    'TST' || LPAD(ROW_NUMBER() OVER (ORDER BY seq)::VARCHAR, 7, '0') AS test_id,
    'ENG' || LPAD((MOD(seq, 300) + 1)::VARCHAR, 6, '0') AS project_id,
    'AST' || LPAD((MOD(seq, 500) + 1)::VARCHAR, 6, '0') AS asset_id,
    'PRG' || LPAD((MOD(seq, 200) + 1)::VARCHAR, 6, '0') AS program_id,
    'T-' || LPAD(ROW_NUMBER() OVER (ORDER BY seq)::VARCHAR, 6, '0') AS test_number,
    CASE MOD(seq, 5)
        WHEN 0 THEN 'Flight Envelope Expansion'
        WHEN 1 THEN 'Environmental Qualification'
        WHEN 2 THEN 'Integration Verification'
        WHEN 3 THEN 'Performance Validation'
        ELSE 'Reliability Demonstration'
    END || ' Test ' || LPAD(ROW_NUMBER() OVER (ORDER BY seq)::VARCHAR, 4, '0') AS test_name,
    CASE MOD(seq, 5)
        WHEN 0 THEN 'FLIGHT'
        WHEN 1 THEN 'GROUND'
        WHEN 2 THEN 'LAB'
        WHEN 3 THEN 'ENVIRONMENTAL'
        ELSE 'INTEGRATION'
    END AS test_type,
    CASE MOD(seq, 4)
        WHEN 0 THEN 'DEVELOPMENT'
        WHEN 1 THEN 'QUALIFICATION'
        WHEN 2 THEN 'ACCEPTANCE'
        ELSE 'REGRESSION'
    END AS test_category,
    DATEADD('day', -UNIFORM(1, 365, RANDOM()), CURRENT_DATE()) AS test_date,
    ARRAY_CONSTRUCT('White Sands, NM', 'Edwards AFB, CA', 'Eglin AFB, FL', 'China Lake, CA', 'Point Mugu, CA')[MOD(seq, 5)::INT] AS test_location,
    UNIFORM(1, 24, RANDOM())::NUMBER(6,2) AS test_duration_hours,
    CASE WHEN MOD(seq, 20) = 0 THEN 'ABORTED' ELSE 'COMPLETED' END AS test_status,
    CASE MOD(seq, 10)
        WHEN 0 THEN 'FAIL'
        WHEN 1 THEN 'CONDITIONAL'
        ELSE 'PASS'
    END AS test_result,
    CASE WHEN MOD(seq, 10) > 1 THEN TRUE ELSE FALSE END AS success_criteria_met,
    CASE WHEN MOD(seq, 5) = 0 THEN UNIFORM(1, 5, RANDOM()) ELSE 0 END AS anomalies_count,
    ARRAY_CONSTRUCT('Dr. Smith', 'Dr. Johnson', 'Dr. Williams', 'Dr. Brown', 'Dr. Davis')[MOD(seq, 5)::INT] AS test_conductor
FROM TABLE(GENERATOR(ROWCOUNT => 2000)) g,
     LATERAL (SELECT SEQ4() AS seq) s;

-- ============================================================================
-- Step 13: Generate EMPLOYEES (1000 employees)
-- ============================================================================
INSERT INTO EMPLOYEES (
    employee_id, division_id, employee_number, first_name, last_name,
    email, job_title, department, employee_type, security_clearance,
    clearance_expiry_date, hire_date, employee_status, labor_category,
    hourly_rate, annual_salary, location, remote_eligible
)
SELECT
    'EMP' || LPAD(ROW_NUMBER() OVER (ORDER BY seq)::VARCHAR, 6, '0') AS employee_id,
    'DIV00' || (MOD(seq, 9) + 1)::VARCHAR AS division_id,
    'E' || LPAD(ROW_NUMBER() OVER (ORDER BY seq)::VARCHAR, 6, '0') AS employee_number,
    ARRAY_CONSTRUCT('James', 'John', 'Robert', 'Michael', 'William', 'David', 'Richard', 'Joseph', 'Thomas', 'Mary', 'Patricia', 'Jennifer', 'Linda', 'Elizabeth', 'Barbara', 'Susan', 'Jessica', 'Sarah', 'Karen', 'Nancy')[MOD(seq, 20)::INT] AS first_name,
    ARRAY_CONSTRUCT('Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez', 'Anderson', 'Taylor', 'Thomas', 'Moore', 'Jackson')[MOD(seq, 15)::INT] AS last_name,
    'employee' || ROW_NUMBER() OVER (ORDER BY seq)::VARCHAR || '@kratos.com' AS email,
    CASE MOD(seq, 10)
        WHEN 0 THEN 'Senior Systems Engineer'
        WHEN 1 THEN 'Software Developer'
        WHEN 2 THEN 'Program Manager'
        WHEN 3 THEN 'Manufacturing Engineer'
        WHEN 4 THEN 'Quality Engineer'
        WHEN 5 THEN 'Test Engineer'
        WHEN 6 THEN 'Electrical Engineer'
        WHEN 7 THEN 'Mechanical Engineer'
        WHEN 8 THEN 'Project Manager'
        ELSE 'Technician'
    END AS job_title,
    CASE MOD(seq, 5)
        WHEN 0 THEN 'Engineering'
        WHEN 1 THEN 'Manufacturing'
        WHEN 2 THEN 'Quality'
        WHEN 3 THEN 'Programs'
        ELSE 'Operations'
    END AS department,
    CASE WHEN MOD(seq, 10) = 0 THEN 'CONTRACTOR' ELSE 'FULL_TIME' END AS employee_type,
    CASE MOD(seq, 4)
        WHEN 0 THEN 'SECRET'
        WHEN 1 THEN 'TOP SECRET'
        WHEN 2 THEN 'TOP SECRET/SCI'
        ELSE 'CONFIDENTIAL'
    END AS security_clearance,
    DATEADD('day', UNIFORM(180, 1825, RANDOM()), CURRENT_DATE()) AS clearance_expiry_date,
    DATEADD('day', -UNIFORM(365, 7300, RANDOM()), CURRENT_DATE()) AS hire_date,
    CASE WHEN MOD(seq, 50) = 0 THEN 'INACTIVE' ELSE 'ACTIVE' END AS employee_status,
    CASE MOD(seq, 5)
        WHEN 0 THEN 'ENGINEER'
        WHEN 1 THEN 'TECHNICIAN'
        WHEN 2 THEN 'MANAGER'
        WHEN 3 THEN 'SPECIALIST'
        ELSE 'ANALYST'
    END AS labor_category,
    UNIFORM(35, 150, RANDOM())::NUMBER(10,2) AS hourly_rate,
    UNIFORM(70000, 250000, RANDOM())::NUMBER(12,2) AS annual_salary,
    ARRAY_CONSTRUCT('Oklahoma City, OK', 'Colorado Springs, CO', 'Huntsville, AL', 'San Diego, CA', 'Orlando, FL', 'Fort Worth, TX', 'Tucson, AZ', 'Sacramento, CA')[MOD(seq, 8)::INT] AS location,
    CASE WHEN MOD(seq, 3) = 0 THEN TRUE ELSE FALSE END AS remote_eligible
FROM TABLE(GENERATOR(ROWCOUNT => 1000)) g,
     LATERAL (SELECT SEQ4() AS seq) s;

-- ============================================================================
-- Step 14: Generate INCIDENTS (500 incidents)
-- ============================================================================
INSERT INTO INCIDENTS (
    incident_id, asset_id, program_id, division_id, incident_number,
    incident_date, incident_type, incident_category, severity, location,
    description, incident_status, investigation_status, reported_by,
    assigned_to, cost_impact, schedule_impact_days, customer_notified
)
SELECT
    'INC' || LPAD(ROW_NUMBER() OVER (ORDER BY seq)::VARCHAR, 6, '0') AS incident_id,
    'AST' || LPAD((MOD(seq, 500) + 1)::VARCHAR, 6, '0') AS asset_id,
    'PRG' || LPAD((MOD(seq, 200) + 1)::VARCHAR, 6, '0') AS program_id,
    'DIV00' || (MOD(seq, 9) + 1)::VARCHAR AS division_id,
    'INC-' || LPAD(ROW_NUMBER() OVER (ORDER BY seq)::VARCHAR, 6, '0') AS incident_number,
    DATEADD('second', -UNIFORM(1, 31536000, RANDOM()), CURRENT_TIMESTAMP()) AS incident_date,
    CASE MOD(seq, 5)
        WHEN 0 THEN 'SAFETY'
        WHEN 1 THEN 'QUALITY'
        WHEN 2 THEN 'OPERATIONAL'
        WHEN 3 THEN 'SECURITY'
        ELSE 'ENVIRONMENTAL'
    END AS incident_type,
    CASE MOD(seq, 4)
        WHEN 0 THEN 'EQUIPMENT_FAILURE'
        WHEN 1 THEN 'HUMAN_ERROR'
        WHEN 2 THEN 'PROCESS_DEVIATION'
        ELSE 'NEAR_MISS'
    END AS incident_category,
    CASE MOD(seq, 5)
        WHEN 0 THEN 'LOW'
        WHEN 1 THEN 'MEDIUM'
        WHEN 2 THEN 'MEDIUM'
        WHEN 3 THEN 'HIGH'
        ELSE 'CRITICAL'
    END AS severity,
    ARRAY_CONSTRUCT('Manufacturing Floor', 'Test Range', 'Flight Line', 'Lab', 'Office', 'Warehouse')[MOD(seq, 6)::INT] AS location,
    'Incident involving ' || CASE MOD(seq, 5)
        WHEN 0 THEN 'equipment malfunction during operation'
        WHEN 1 THEN 'deviation from standard procedure'
        WHEN 2 THEN 'component failure during test'
        WHEN 3 THEN 'near miss during handling'
        ELSE 'environmental concern identified'
    END AS description,
    CASE MOD(seq, 4)
        WHEN 0 THEN 'OPEN'
        WHEN 1 THEN 'INVESTIGATING'
        WHEN 2 THEN 'RESOLVED'
        ELSE 'CLOSED'
    END AS incident_status,
    CASE MOD(seq, 3)
        WHEN 0 THEN 'PENDING'
        WHEN 1 THEN 'IN_PROGRESS'
        ELSE 'COMPLETED'
    END AS investigation_status,
    ARRAY_CONSTRUCT('Smith', 'Johnson', 'Williams', 'Brown', 'Davis')[MOD(seq, 5)::INT] AS reported_by,
    ARRAY_CONSTRUCT('Safety Lead', 'Quality Manager', 'Operations Supervisor', 'Engineering Lead', 'Program Manager')[MOD(seq, 5)::INT] AS assigned_to,
    UNIFORM(1000, 500000, RANDOM())::NUMBER(15,2) AS cost_impact,
    UNIFORM(0, 30, RANDOM()) AS schedule_impact_days,
    CASE WHEN MOD(seq, 4) = 0 THEN TRUE ELSE FALSE END AS customer_notified
FROM TABLE(GENERATOR(ROWCOUNT => 500)) g,
     LATERAL (SELECT SEQ4() AS seq) s;

-- ============================================================================
-- Step 15: Generate SUPPLIERS (200 suppliers)
-- ============================================================================
INSERT INTO SUPPLIERS (
    supplier_id, supplier_code, supplier_name, supplier_type, supplier_category,
    address, city, state, country, primary_contact, contact_email,
    payment_terms, quality_rating, delivery_rating, is_approved,
    is_small_business, is_woman_owned, is_veteran_owned, cage_code,
    supplier_status, first_order_date, total_spend
)
SELECT
    'SUP' || LPAD(ROW_NUMBER() OVER (ORDER BY seq)::VARCHAR, 5, '0') AS supplier_id,
    'S' || LPAD(ROW_NUMBER() OVER (ORDER BY seq)::VARCHAR, 4, '0') AS supplier_code,
    CASE MOD(seq, 10)
        WHEN 0 THEN 'Aerospace Components Inc'
        WHEN 1 THEN 'Precision Manufacturing Corp'
        WHEN 2 THEN 'Advanced Materials LLC'
        WHEN 3 THEN 'Electronic Systems Group'
        WHEN 4 THEN 'Propulsion Technologies'
        WHEN 5 THEN 'Defense Avionics Inc'
        WHEN 6 THEN 'Composite Structures Co'
        WHEN 7 THEN 'Thermal Systems LLC'
        WHEN 8 THEN 'Guidance Solutions Inc'
        ELSE 'Integration Services Corp'
    END || ' ' || LPAD(ROW_NUMBER() OVER (ORDER BY seq)::VARCHAR, 3, '0') AS supplier_name,
    CASE MOD(seq, 5)
        WHEN 0 THEN 'TIER_1'
        WHEN 1 THEN 'TIER_2'
        WHEN 2 THEN 'TIER_3'
        WHEN 3 THEN 'DISTRIBUTOR'
        ELSE 'OEM'
    END AS supplier_type,
    CASE MOD(seq, 5)
        WHEN 0 THEN 'AEROSPACE'
        WHEN 1 THEN 'ELECTRONICS'
        WHEN 2 THEN 'MATERIALS'
        WHEN 3 THEN 'SERVICES'
        ELSE 'MANUFACTURING'
    END AS supplier_category,
    (100 + MOD(seq, 900))::VARCHAR || ' Industrial Blvd' AS address,
    ARRAY_CONSTRUCT('Los Angeles', 'Phoenix', 'Dallas', 'Denver', 'Seattle', 'Chicago', 'Atlanta', 'Boston')[MOD(seq, 8)::INT] AS city,
    ARRAY_CONSTRUCT('CA', 'AZ', 'TX', 'CO', 'WA', 'IL', 'GA', 'MA')[MOD(seq, 8)::INT] AS state,
    'USA' AS country,
    ARRAY_CONSTRUCT('John Supplier', 'Mary Vendor', 'Robert Partner', 'Patricia Sales', 'Michael Account')[MOD(seq, 5)::INT] AS primary_contact,
    'contact' || ROW_NUMBER() OVER (ORDER BY seq)::VARCHAR || '@supplier.com' AS contact_email,
    CASE MOD(seq, 3)
        WHEN 0 THEN 'NET 30'
        WHEN 1 THEN 'NET 45'
        ELSE 'NET 60'
    END AS payment_terms,
    (UNIFORM(70, 100, RANDOM()) / 100.0)::NUMBER(3,2) AS quality_rating,
    (UNIFORM(70, 100, RANDOM()) / 100.0)::NUMBER(3,2) AS delivery_rating,
    CASE WHEN MOD(seq, 20) = 0 THEN FALSE ELSE TRUE END AS is_approved,
    CASE WHEN MOD(seq, 4) = 0 THEN TRUE ELSE FALSE END AS is_small_business,
    CASE WHEN MOD(seq, 10) = 0 THEN TRUE ELSE FALSE END AS is_woman_owned,
    CASE WHEN MOD(seq, 8) = 0 THEN TRUE ELSE FALSE END AS is_veteran_owned,
    LPAD(ROW_NUMBER() OVER (ORDER BY seq)::VARCHAR, 5, '0') AS cage_code,
    CASE WHEN MOD(seq, 25) = 0 THEN 'INACTIVE' ELSE 'ACTIVE' END AS supplier_status,
    DATEADD('day', -UNIFORM(365, 3650, RANDOM()), CURRENT_DATE()) AS first_order_date,
    UNIFORM(100000, 50000000, RANDOM())::NUMBER(18,2) AS total_spend
FROM TABLE(GENERATOR(ROWCOUNT => 200)) g,
     LATERAL (SELECT SEQ4() AS seq) s;

-- ============================================================================
-- Step 16: Generate PARTS_INVENTORY (1000 parts)
-- ============================================================================
INSERT INTO PARTS_INVENTORY (
    part_id, division_id, part_number, part_name, part_category, part_type,
    manufacturer, unit_cost, quantity_on_hand, quantity_reserved,
    quantity_available, reorder_point, reorder_quantity, lead_time_days,
    storage_location, is_critical, is_hazardous, export_controlled
)
SELECT
    'PRT' || LPAD(ROW_NUMBER() OVER (ORDER BY seq)::VARCHAR, 6, '0') AS part_id,
    'DIV00' || (MOD(seq, 9) + 1)::VARCHAR AS division_id,
    'PN-' || LPAD(ROW_NUMBER() OVER (ORDER BY seq)::VARCHAR, 8, '0') AS part_number,
    CASE MOD(seq, 10)
        WHEN 0 THEN 'Servo Motor Assembly'
        WHEN 1 THEN 'Control Board'
        WHEN 2 THEN 'Structural Bracket'
        WHEN 3 THEN 'Fuel Pump'
        WHEN 4 THEN 'Sensor Module'
        WHEN 5 THEN 'Actuator'
        WHEN 6 THEN 'Heat Exchanger'
        WHEN 7 THEN 'Wiring Harness'
        WHEN 8 THEN 'Bearing Assembly'
        ELSE 'Filter Element'
    END || ' ' || LPAD(ROW_NUMBER() OVER (ORDER BY seq)::VARCHAR, 4, '0') AS part_name,
    CASE MOD(seq, 5)
        WHEN 0 THEN 'MECHANICAL'
        WHEN 1 THEN 'ELECTRICAL'
        WHEN 2 THEN 'HYDRAULIC'
        WHEN 3 THEN 'AVIONICS'
        ELSE 'STRUCTURAL'
    END AS part_category,
    CASE MOD(seq, 4)
        WHEN 0 THEN 'CONSUMABLE'
        WHEN 1 THEN 'REPAIRABLE'
        WHEN 2 THEN 'ROTABLE'
        ELSE 'EXPENDABLE'
    END AS part_type,
    ARRAY_CONSTRUCT('Kratos', 'Parker', 'Honeywell', 'Moog', 'Collins', 'L3Harris', 'BAE', 'Raytheon')[MOD(seq, 8)::INT] AS manufacturer,
    UNIFORM(50, 50000, RANDOM())::NUMBER(12,2) AS unit_cost,
    UNIFORM(0, 500, RANDOM()) AS quantity_on_hand,
    UNIFORM(0, 50, RANDOM()) AS quantity_reserved,
    UNIFORM(0, 450, RANDOM()) AS quantity_available,
    UNIFORM(5, 50, RANDOM()) AS reorder_point,
    UNIFORM(10, 100, RANDOM()) AS reorder_quantity,
    UNIFORM(7, 120, RANDOM()) AS lead_time_days,
    'Bin-' || LPAD((MOD(seq, 100) + 1)::VARCHAR, 3, '0') AS storage_location,
    CASE WHEN MOD(seq, 5) = 0 THEN TRUE ELSE FALSE END AS is_critical,
    CASE WHEN MOD(seq, 20) = 0 THEN TRUE ELSE FALSE END AS is_hazardous,
    CASE WHEN MOD(seq, 4) = 0 THEN TRUE ELSE FALSE END AS export_controlled
FROM TABLE(GENERATOR(ROWCOUNT => 1000)) g,
     LATERAL (SELECT SEQ4() AS seq) s;

-- ============================================================================
-- Step 17: Generate PURCHASE_ORDERS (1500 POs)
-- ============================================================================
INSERT INTO PURCHASE_ORDERS (
    po_id, supplier_id, program_id, division_id, po_number, po_date,
    required_date, po_type, po_status, subtotal, tax_amount, shipping_amount,
    total_amount, payment_terms, ship_to_location, buyer, approved_by
)
SELECT
    'PO' || LPAD(ROW_NUMBER() OVER (ORDER BY seq)::VARCHAR, 7, '0') AS po_id,
    'SUP' || LPAD((MOD(seq, 200) + 1)::VARCHAR, 5, '0') AS supplier_id,
    'PRG' || LPAD((MOD(seq, 200) + 1)::VARCHAR, 6, '0') AS program_id,
    'DIV00' || (MOD(seq, 9) + 1)::VARCHAR AS division_id,
    'PO-' || LPAD(ROW_NUMBER() OVER (ORDER BY seq)::VARCHAR, 8, '0') AS po_number,
    DATEADD('day', -UNIFORM(1, 365, RANDOM()), CURRENT_DATE()) AS po_date,
    DATEADD('day', UNIFORM(14, 90, RANDOM()), CURRENT_DATE()) AS required_date,
    CASE MOD(seq, 4)
        WHEN 0 THEN 'STANDARD'
        WHEN 1 THEN 'BLANKET'
        WHEN 2 THEN 'EMERGENCY'
        ELSE 'CONTRACT'
    END AS po_type,
    CASE MOD(seq, 5)
        WHEN 0 THEN 'OPEN'
        WHEN 1 THEN 'RECEIVED'
        WHEN 2 THEN 'PARTIAL'
        WHEN 3 THEN 'CLOSED'
        ELSE 'CANCELLED'
    END AS po_status,
    UNIFORM(1000, 500000, RANDOM())::NUMBER(15,2) AS subtotal,
    UNIFORM(0, 25000, RANDOM())::NUMBER(12,2) AS tax_amount,
    UNIFORM(100, 5000, RANDOM())::NUMBER(10,2) AS shipping_amount,
    UNIFORM(1500, 530000, RANDOM())::NUMBER(15,2) AS total_amount,
    CASE MOD(seq, 3)
        WHEN 0 THEN 'NET 30'
        WHEN 1 THEN 'NET 45'
        ELSE 'NET 60'
    END AS payment_terms,
    ARRAY_CONSTRUCT('Oklahoma City, OK', 'Colorado Springs, CO', 'Huntsville, AL', 'San Diego, CA', 'Orlando, FL')[MOD(seq, 5)::INT] AS ship_to_location,
    ARRAY_CONSTRUCT('Buyer Smith', 'Buyer Johnson', 'Buyer Williams', 'Buyer Brown', 'Buyer Davis')[MOD(seq, 5)::INT] AS buyer,
    ARRAY_CONSTRUCT('Manager Anderson', 'Manager Martinez', 'Manager Thompson', 'Manager Garcia', 'Manager Rodriguez')[MOD(seq, 5)::INT] AS approved_by
FROM TABLE(GENERATOR(ROWCOUNT => 1500)) g,
     LATERAL (SELECT SEQ4() AS seq) s;

-- ============================================================================
-- Step 18: Generate TECHNICAL_DOCUMENTS (500 docs for Cortex Search)
-- ============================================================================
INSERT INTO TECHNICAL_DOCUMENTS (
    doc_id, program_id, division_id, doc_number, doc_title, doc_type,
    doc_category, content, author, created_date, revision, doc_status,
    security_classification, keywords
)
SELECT
    'DOC' || LPAD(ROW_NUMBER() OVER (ORDER BY seq)::VARCHAR, 6, '0') AS doc_id,
    'PRG' || LPAD((MOD(seq, 200) + 1)::VARCHAR, 6, '0') AS program_id,
    'DIV00' || (MOD(seq, 9) + 1)::VARCHAR AS division_id,
    'TD-' || LPAD(ROW_NUMBER() OVER (ORDER BY seq)::VARCHAR, 6, '0') AS doc_number,
    CASE MOD(seq, 10)
        WHEN 0 THEN 'System Specification for ' || ARRAY_CONSTRUCT('XQ-58A', 'BQM-167', 'TJ150', 'SATCOM Terminal', 'Radar System')[MOD(seq, 5)::INT]
        WHEN 1 THEN 'Interface Control Document - ' || ARRAY_CONSTRUCT('Avionics', 'Propulsion', 'Structures', 'Software', 'Ground Support')[MOD(seq, 5)::INT]
        WHEN 2 THEN 'Test Procedure for ' || ARRAY_CONSTRUCT('Flight Envelope', 'Environmental', 'EMI/EMC', 'Structural', 'Functional')[MOD(seq, 5)::INT]
        WHEN 3 THEN 'Maintenance Manual - ' || ARRAY_CONSTRUCT('Airframe', 'Engine', 'Avionics', 'Ground Support', 'Payload')[MOD(seq, 5)::INT]
        WHEN 4 THEN 'Engineering Drawing Package - ' || ARRAY_CONSTRUCT('Assembly', 'Detail', 'Installation', 'Wiring', 'Schematic')[MOD(seq, 5)::INT]
        WHEN 5 THEN 'Software Design Document - ' || ARRAY_CONSTRUCT('Flight Control', 'Mission Computer', 'Datalink', 'Sensor Fusion', 'Autonomy')[MOD(seq, 5)::INT]
        WHEN 6 THEN 'Safety Analysis Report - ' || ARRAY_CONSTRUCT('FMEA', 'FTA', 'Hazard Analysis', 'Risk Assessment', 'Safety Case')[MOD(seq, 5)::INT]
        WHEN 7 THEN 'Performance Specification - ' || ARRAY_CONSTRUCT('Speed', 'Range', 'Payload', 'Endurance', 'Altitude')[MOD(seq, 5)::INT]
        WHEN 8 THEN 'Quality Assurance Plan - ' || ARRAY_CONSTRUCT('Production', 'Supplier', 'Inspection', 'Testing', 'Acceptance')[MOD(seq, 5)::INT]
        ELSE 'Technical Data Package - ' || ARRAY_CONSTRUCT('Provisioning', 'Logistics', 'Training', 'Support', 'Spares')[MOD(seq, 5)::INT]
    END AS doc_title,
    CASE MOD(seq, 5)
        WHEN 0 THEN 'SPECIFICATION'
        WHEN 1 THEN 'PROCEDURE'
        WHEN 2 THEN 'MANUAL'
        WHEN 3 THEN 'DRAWING'
        ELSE 'REPORT'
    END AS doc_type,
    CASE MOD(seq, 4)
        WHEN 0 THEN 'ENGINEERING'
        WHEN 1 THEN 'MANUFACTURING'
        WHEN 2 THEN 'QUALITY'
        ELSE 'LOGISTICS'
    END AS doc_category,
    'This document provides detailed technical information for the ' || 
    ARRAY_CONSTRUCT('XQ-58A Valkyrie unmanned combat air vehicle', 'BQM-167 aerial target drone', 'TJ150 turbojet engine', 'satellite communications terminal', 'tactical radar system')[MOD(seq, 5)::INT] ||
    '. The document covers ' ||
    CASE MOD(seq, 5)
        WHEN 0 THEN 'system requirements, interfaces, and performance specifications. Key parameters include maximum speed, operational altitude, and payload capacity.'
        WHEN 1 THEN 'interface definitions, signal characteristics, and protocol specifications. Detailed connector pinouts and timing requirements are provided.'
        WHEN 2 THEN 'test procedures, acceptance criteria, and data collection requirements. Step-by-step instructions ensure consistent and repeatable testing.'
        WHEN 3 THEN 'maintenance procedures, troubleshooting guides, and parts lists. Scheduled and unscheduled maintenance tasks are documented.'
        ELSE 'design rationale, analysis results, and verification approach. Engineering calculations and simulation results support the design.'
    END ||
    ' This revision incorporates lessons learned from recent flight testing and addresses customer feedback on operational performance.' AS content,
    ARRAY_CONSTRUCT('Dr. Smith', 'Dr. Johnson', 'Dr. Williams', 'Dr. Brown', 'Dr. Davis')[MOD(seq, 5)::INT] AS author,
    DATEADD('day', -UNIFORM(30, 730, RANDOM()), CURRENT_DATE()) AS created_date,
    'Rev ' || (UNIFORM(1, 5, RANDOM()))::VARCHAR AS revision,
    CASE WHEN MOD(seq, 10) = 0 THEN 'DRAFT' ELSE 'CURRENT' END AS doc_status,
    CASE MOD(seq, 3)
        WHEN 0 THEN 'UNCLASSIFIED'
        WHEN 1 THEN 'SECRET'
        ELSE 'TOP SECRET'
    END AS security_classification,
    ARRAY_CONSTRUCT('UAV, drone, unmanned', 'propulsion, engine, turbine', 'avionics, electronics, systems', 'structures, airframe, composite', 'software, autonomy, control')[MOD(seq, 5)::INT] AS keywords
FROM TABLE(GENERATOR(ROWCOUNT => 500)) g,
     LATERAL (SELECT SEQ4() AS seq) s;

-- ============================================================================
-- Step 19: Generate TEST_REPORTS (300 reports for Cortex Search)
-- ============================================================================
INSERT INTO TEST_REPORTS (
    report_id, test_id, program_id, report_number, report_title, report_type,
    content, test_date, author, result_summary, anomalies_summary, recommendations
)
SELECT
    'RPT' || LPAD(ROW_NUMBER() OVER (ORDER BY seq)::VARCHAR, 6, '0') AS report_id,
    'TST' || LPAD((MOD(seq, 2000) + 1)::VARCHAR, 7, '0') AS test_id,
    'PRG' || LPAD((MOD(seq, 200) + 1)::VARCHAR, 6, '0') AS program_id,
    'TR-' || LPAD(ROW_NUMBER() OVER (ORDER BY seq)::VARCHAR, 6, '0') AS report_number,
    CASE MOD(seq, 5)
        WHEN 0 THEN 'Flight Test Report - Envelope Expansion'
        WHEN 1 THEN 'Environmental Test Report - Qualification'
        WHEN 2 THEN 'Integration Test Report - System Verification'
        WHEN 3 THEN 'Performance Test Report - Acceptance'
        ELSE 'Reliability Test Report - Demonstration'
    END || ' ' || LPAD(ROW_NUMBER() OVER (ORDER BY seq)::VARCHAR, 4, '0') AS report_title,
    CASE MOD(seq, 4)
        WHEN 0 THEN 'FLIGHT_TEST'
        WHEN 1 THEN 'GROUND_TEST'
        WHEN 2 THEN 'LAB_TEST'
        ELSE 'INTEGRATION_TEST'
    END AS report_type,
    'Test Report Summary: This report documents the results of ' ||
    CASE MOD(seq, 5)
        WHEN 0 THEN 'flight envelope expansion testing conducted at White Sands Missile Range. The test aircraft achieved maximum speed of Mach 0.85 and demonstrated stable flight characteristics throughout the test envelope. All primary test objectives were met.'
        WHEN 1 THEN 'environmental qualification testing including temperature, humidity, vibration, and EMI/EMC. The unit under test successfully completed all test sequences with no degradation in performance. Minor anomalies were noted and dispositioned.'
        WHEN 2 THEN 'system integration verification testing at the contractor facility. Interface compatibility was confirmed between all major subsystems. Data link performance exceeded requirements.'
        WHEN 3 THEN 'performance acceptance testing per the contract specification. All key performance parameters were demonstrated within specification limits. The system is recommended for production release.'
        ELSE 'reliability demonstration testing over a 500-hour test period. Mean time between failures exceeded the specified requirement. No critical failures were observed during the test period.'
    END ||
    ' Detailed test data and analysis are provided in the appendices.' AS content,
    DATEADD('day', -UNIFORM(30, 365, RANDOM()), CURRENT_DATE()) AS test_date,
    ARRAY_CONSTRUCT('Test Engineer Smith', 'Test Engineer Johnson', 'Test Director Williams', 'Chief Engineer Brown', 'Program Manager Davis')[MOD(seq, 5)::INT] AS author,
    CASE MOD(seq, 10)
        WHEN 0 THEN 'FAIL - Did not meet minimum requirements'
        WHEN 1 THEN 'PASS WITH DEVIATION - Minor discrepancies noted'
        ELSE 'PASS - All requirements met or exceeded'
    END AS result_summary,
    CASE WHEN MOD(seq, 5) = 0 THEN 
        'Anomaly ' || LPAD(ROW_NUMBER() OVER (ORDER BY seq)::VARCHAR, 4, '0') || ': Intermittent signal dropout observed during high-G maneuvers. Root cause under investigation. Workaround implemented for continued testing.'
    ELSE NULL END AS anomalies_summary,
    CASE MOD(seq, 4)
        WHEN 0 THEN 'Recommend proceeding to next test phase. No design changes required.'
        WHEN 1 THEN 'Recommend software update to address timing issue before production.'
        WHEN 2 THEN 'Recommend additional testing at temperature extremes.'
        ELSE 'Recommend production release with noted limitations.'
    END AS recommendations
FROM TABLE(GENERATOR(ROWCOUNT => 300)) g,
     LATERAL (SELECT SEQ4() AS seq) s;

-- ============================================================================
-- Step 20: Generate INCIDENT_LOGS (400 logs for Cortex Search)
-- ============================================================================
INSERT INTO INCIDENT_LOGS (
    log_id, incident_id, program_id, division_id, log_date, log_type,
    summary, detailed_description, actions_taken, lessons_learned
)
SELECT
    'LOG' || LPAD(ROW_NUMBER() OVER (ORDER BY seq)::VARCHAR, 6, '0') AS log_id,
    'INC' || LPAD((MOD(seq, 500) + 1)::VARCHAR, 6, '0') AS incident_id,
    'PRG' || LPAD((MOD(seq, 200) + 1)::VARCHAR, 6, '0') AS program_id,
    'DIV00' || (MOD(seq, 9) + 1)::VARCHAR AS division_id,
    DATEADD('day', -UNIFORM(1, 365, RANDOM()), CURRENT_DATE()) AS log_date,
    CASE MOD(seq, 5)
        WHEN 0 THEN 'SAFETY'
        WHEN 1 THEN 'QUALITY'
        WHEN 2 THEN 'OPERATIONAL'
        WHEN 3 THEN 'SECURITY'
        ELSE 'ENVIRONMENTAL'
    END AS log_type,
    CASE MOD(seq, 5)
        WHEN 0 THEN 'Safety incident during flight test operations'
        WHEN 1 THEN 'Quality escape identified in manufacturing'
        WHEN 2 THEN 'Operational anomaly during mission execution'
        WHEN 3 THEN 'Security concern with facility access'
        ELSE 'Environmental issue with hazardous materials'
    END AS summary,
    'Detailed Description: On ' || TO_VARCHAR(DATEADD('day', -UNIFORM(1, 365, RANDOM()), CURRENT_DATE()), 'YYYY-MM-DD') || 
    ', an incident occurred involving ' ||
    CASE MOD(seq, 5)
        WHEN 0 THEN 'the flight test team during pre-flight preparations. A technician reported a near-miss when the aircraft moved unexpectedly during ground operations. The root cause was traced to a software interlock that failed to engage properly. No injuries occurred but the event highlighted gaps in our ground safety procedures.'
        WHEN 1 THEN 'a manufacturing defect that was discovered during final inspection. The non-conformance involved incorrect torque application on critical fasteners. Investigation revealed the torque wrench calibration had drifted out of specification. All affected units were quarantined for re-inspection.'
        WHEN 2 THEN 'an unexpected mission abort during autonomous operations. The aircraft initiated an automatic return-to-base due to anomalous sensor readings. Post-flight analysis determined the cause was electromagnetic interference from nearby radar systems. The mission was replanned for a different time window.'
        WHEN 3 THEN 'unauthorized access attempt to the classified storage area. Security personnel detected and stopped an individual without proper clearance. Investigation confirmed it was a badging error and not a deliberate breach. Access control procedures were reviewed and updated.'
        ELSE 'improper storage of hazardous materials in the paint shop. Environmental inspection identified containers that were not properly sealed. Immediate corrective action was taken to secure the materials. Additional training was provided to all affected personnel.'
    END AS detailed_description,
    'Actions Taken: ' ||
    CASE MOD(seq, 4)
        WHEN 0 THEN 'Immediate containment measures implemented. Investigation team formed. Root cause analysis initiated. Corrective action plan developed and approved. Implementation in progress.'
        WHEN 1 THEN 'Affected units quarantined. Escape analysis performed. Supplier notification sent. Process audit scheduled. Training refresher planned.'
        WHEN 2 THEN 'Operations temporarily suspended. Engineering review completed. Software patch developed and tested. Operations resumed with enhanced monitoring.'
        ELSE 'Incident documented in tracking system. Trend analysis performed. Preventive measures identified. Lessons learned briefing conducted.'
    END AS actions_taken,
    'Lessons Learned: ' ||
    CASE MOD(seq, 3)
        WHEN 0 THEN 'This incident reinforced the importance of adhering to established procedures. Additional verification steps have been added to prevent recurrence. Communication between shifts has been improved.'
        WHEN 1 THEN 'The root cause analysis revealed a systemic issue that affects multiple programs. A working group has been formed to address the underlying process gaps. Best practices will be shared across divisions.'
        ELSE 'Early detection prevented a more serious outcome. The existing controls worked as designed. Continuous improvement opportunities were identified and are being implemented.'
    END AS lessons_learned
FROM TABLE(GENERATOR(ROWCOUNT => 400)) g,
     LATERAL (SELECT SEQ4() AS seq) s;

-- ============================================================================
-- Verification
-- ============================================================================
SELECT 'DIVISIONS' AS table_name, COUNT(*) AS row_count FROM DIVISIONS
UNION ALL SELECT 'CUSTOMERS', COUNT(*) FROM CUSTOMERS
UNION ALL SELECT 'PROGRAMS', COUNT(*) FROM PROGRAMS
UNION ALL SELECT 'CONTRACTS', COUNT(*) FROM CONTRACTS
UNION ALL SELECT 'MILESTONES', COUNT(*) FROM MILESTONES
UNION ALL SELECT 'ASSETS', COUNT(*) FROM ASSETS
UNION ALL SELECT 'ASSET_OPERATIONS', COUNT(*) FROM ASSET_OPERATIONS
UNION ALL SELECT 'MAINTENANCE_RECORDS', COUNT(*) FROM MAINTENANCE_RECORDS
UNION ALL SELECT 'MANUFACTURING_ORDERS', COUNT(*) FROM MANUFACTURING_ORDERS
UNION ALL SELECT 'QUALITY_INSPECTIONS', COUNT(*) FROM QUALITY_INSPECTIONS
UNION ALL SELECT 'ENGINEERING_PROJECTS', COUNT(*) FROM ENGINEERING_PROJECTS
UNION ALL SELECT 'TEST_EVENTS', COUNT(*) FROM TEST_EVENTS
UNION ALL SELECT 'EMPLOYEES', COUNT(*) FROM EMPLOYEES
UNION ALL SELECT 'INCIDENTS', COUNT(*) FROM INCIDENTS
UNION ALL SELECT 'SUPPLIERS', COUNT(*) FROM SUPPLIERS
UNION ALL SELECT 'PARTS_INVENTORY', COUNT(*) FROM PARTS_INVENTORY
UNION ALL SELECT 'PURCHASE_ORDERS', COUNT(*) FROM PURCHASE_ORDERS
UNION ALL SELECT 'TECHNICAL_DOCUMENTS', COUNT(*) FROM TECHNICAL_DOCUMENTS
UNION ALL SELECT 'TEST_REPORTS', COUNT(*) FROM TEST_REPORTS
UNION ALL SELECT 'INCIDENT_LOGS', COUNT(*) FROM INCIDENT_LOGS
ORDER BY table_name;

