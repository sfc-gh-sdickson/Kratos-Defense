-- ============================================================================
-- Kratos Defense Intelligence Agent - Synthetic Data Generation
-- ============================================================================
-- Purpose: Generate realistic defense contractor sample data
-- CRITICAL: All Snowflake SQL syntax verified per GENERATION_FAILURES_AND_LESSONS.md
--   - UNIFORM() only with CONSTANT min/max values
--   - SEQ4() only with TABLE(GENERATOR(...))
--   - ROW_NUMBER() for sequences outside GENERATOR
--   - ARRAY_CONSTRUCT with safe indexing using MOD
-- ============================================================================

USE DATABASE KRATOS_INTELLIGENCE;
USE SCHEMA RAW;
USE WAREHOUSE KRATOS_WH;

-- ============================================================================
-- Step 1: Generate DIVISIONS (9 divisions)
-- ============================================================================
INSERT INTO DIVISIONS VALUES
('DIV001', 'UAS', 'Unmanned Systems', 'TACTICAL', 'High-performance unmanned aerial systems including target drones and tactical platforms like the XQ-58 Valkyrie', 'Sacramento, CA', 1500, 850000000.00, 'US Air Force', 'SECRET', TRUE, '2010-03-15', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('DIV002', 'SPACE', 'Space & Satellite Communications', 'SPACE', 'Virtualized ground systems and software-defined space networks for defense and commercial satellite operations', 'Colorado Springs, CO', 2200, 1200000000.00, 'US Space Force', 'TOP SECRET', TRUE, '2008-07-01', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('DIV003', 'HYPER', 'Hypersonic Systems', 'ADVANCED', 'Advanced hypersonic strike and test platforms including Erinyes and Dark Fury systems', 'Huntsville, AL', 800, 450000000.00, 'DARPA', 'TOP SECRET', TRUE, '2018-01-20', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('DIV004', 'PROP', 'Propulsion & Power', 'PROPULSION', 'High-thrust jet engines (GEK series) and solid rocket motors (Zeus) for unmanned and missile systems', 'Orlando, FL', 1100, 680000000.00, 'US Navy', 'SECRET', TRUE, '2012-05-10', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('DIV005', 'MICRO', 'Microwave Electronics', 'ELECTRONICS', 'Advanced microwave and digital solutions for missiles, satellites, and electronic warfare systems', 'San Diego, CA', 950, 520000000.00, 'Missile Defense Agency', 'SECRET', TRUE, '2005-11-30', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('DIV006', 'CYBER', 'Cybersecurity & Warfare', 'CYBER', 'Cybersecurity solutions, information assurance, and critical infrastructure protection', 'Arlington, VA', 650, 380000000.00, 'US Cyber Command', 'TOP SECRET/SCI', TRUE, '2014-09-01', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('DIV007', 'MDA', 'Missile Defense', 'DEFENSE', 'Ballistic missile defense systems and high-performance interceptor technologies', 'Huntsville, AL', 1800, 950000000.00, 'Missile Defense Agency', 'SECRET', TRUE, '2003-04-22', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('DIV008', 'C5ISR', 'C5ISR Systems', 'COMMAND', 'Command, Control, Communications, Computing, Combat Systems, Intelligence, Surveillance, Reconnaissance', 'Washington, DC', 1400, 780000000.00, 'STRATCOM', 'TOP SECRET/SCI', TRUE, '2007-08-15', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('DIV009', 'TRAIN', 'Training Systems', 'TRAINING', 'Virtual and augmented reality training systems for warfighter readiness and simulation', 'Orlando, FL', 550, 290000000.00, 'US Army', 'SECRET', TRUE, '2011-02-28', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP());

-- ============================================================================
-- Step 2: Generate CUSTOMERS (50 DoD customers)
-- ============================================================================
INSERT INTO CUSTOMERS
SELECT
    'CUST' || LPAD(ROW_NUMBER() OVER (ORDER BY seq4()), 5, '0') AS customer_id,
    ARRAY_CONSTRUCT('USAF', 'USN', 'USA', 'USMC', 'USSF', 'DARPA', 'MDA', 'DHS', 'NSA', 'CIA')[MOD(seq4(), 10)]::VARCHAR || '-' || LPAD(seq4()::VARCHAR, 3, '0') AS customer_code,
    CASE MOD(seq4(), 15)
        WHEN 0 THEN 'United States Air Force - Air Combat Command'
        WHEN 1 THEN 'United States Navy - Naval Air Systems Command'
        WHEN 2 THEN 'United States Army - Army Futures Command'
        WHEN 3 THEN 'Defense Advanced Research Projects Agency'
        WHEN 4 THEN 'Missile Defense Agency'
        WHEN 5 THEN 'United States Space Force - Space Systems Command'
        WHEN 6 THEN 'United States Marine Corps - Marine Corps Systems Command'
        WHEN 7 THEN 'Department of Homeland Security'
        WHEN 8 THEN 'National Security Agency'
        WHEN 9 THEN 'United States Special Operations Command'
        WHEN 10 THEN 'Defense Logistics Agency'
        WHEN 11 THEN 'National Reconnaissance Office'
        WHEN 12 THEN 'Defense Intelligence Agency'
        WHEN 13 THEN 'United States Strategic Command'
        ELSE 'Allied Foreign Military Sales Customer'
    END AS customer_name,
    CASE MOD(seq4(), 4)
        WHEN 0 THEN 'MILITARY_SERVICE'
        WHEN 1 THEN 'DEFENSE_AGENCY'
        WHEN 2 THEN 'INTELLIGENCE_COMMUNITY'
        ELSE 'ALLIED_NATION'
    END AS customer_type,
    CASE MOD(seq4(), 5)
        WHEN 0 THEN 'PRIME_CONTRACTOR'
        WHEN 1 THEN 'DIRECT_GOVERNMENT'
        WHEN 2 THEN 'SUBCONTRACT'
        WHEN 3 THEN 'FMS'
        ELSE 'CRADA'
    END AS customer_category,
    CASE MOD(seq4(), 6)
        WHEN 0 THEN 'Air Force'
        WHEN 1 THEN 'Navy'
        WHEN 2 THEN 'Army'
        WHEN 3 THEN 'Space Force'
        WHEN 4 THEN 'Joint'
        ELSE 'Intelligence'
    END AS agency_branch,
    CASE WHEN MOD(seq4(), 10) = 9 THEN 'United Kingdom' ELSE 'USA' END AS country,
    'CAPT ' || ARRAY_CONSTRUCT('Johnson', 'Williams', 'Brown', 'Davis', 'Miller', 'Wilson', 'Moore', 'Taylor', 'Anderson', 'Thomas')[MOD(seq4(), 10)]::VARCHAR AS primary_contact_name,
    LOWER(ARRAY_CONSTRUCT('johnson', 'williams', 'brown', 'davis', 'miller', 'wilson', 'moore', 'taylor', 'anderson', 'thomas')[MOD(seq4(), 10)]::VARCHAR) || '@mail.mil' AS primary_contact_email,
    '703-555-' || LPAD((1000 + seq4())::VARCHAR, 4, '0') AS primary_contact_phone,
    ARRAY_CONSTRUCT('Pentagon, Washington DC', 'Wright-Patterson AFB, OH', 'Huntsville, AL', 'San Diego, CA', 'Colorado Springs, CO')[MOD(seq4(), 5)]::VARCHAR AS billing_address,
    ARRAY_CONSTRUCT('GSA Schedule', 'SEWP', 'CIO-SP3', 'OASIS', 'Alliant 2')[MOD(seq4(), 5)]::VARCHAR AS contract_vehicle,
    ARRAY_CONSTRUCT('SECRET', 'TOP SECRET', 'TOP SECRET/SCI', 'UNCLASSIFIED', 'SECRET')[MOD(seq4(), 5)]::VARCHAR AS security_clearance_required,
    'ACTIVE' AS relationship_status,
    DATEADD('year', -UNIFORM(1, 15, RANDOM()), CURRENT_DATE()) AS first_contract_date,
    UNIFORM(5000000, 500000000, RANDOM())::NUMBER(18,2) AS total_contract_value,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM TABLE(GENERATOR(ROWCOUNT => 50));

-- ============================================================================
-- Step 3: Generate PROGRAMS (200 defense programs)
-- ============================================================================
INSERT INTO PROGRAMS
SELECT
    'PROG' || LPAD(ROW_NUMBER() OVER (ORDER BY seq4()), 6, '0') AS program_id,
    ARRAY_CONSTRUCT('DIV001', 'DIV002', 'DIV003', 'DIV004', 'DIV005', 'DIV006', 'DIV007', 'DIV008', 'DIV009')[MOD(seq4(), 9)]::VARCHAR AS division_id,
    CASE MOD(seq4(), 9)
        WHEN 0 THEN 'XQ-58-' || LPAD(seq4()::VARCHAR, 3, '0')
        WHEN 1 THEN 'SATCOM-' || LPAD(seq4()::VARCHAR, 3, '0')
        WHEN 2 THEN 'HYPER-' || LPAD(seq4()::VARCHAR, 3, '0')
        WHEN 3 THEN 'GEK-' || LPAD(seq4()::VARCHAR, 3, '0')
        WHEN 4 THEN 'MW-' || LPAD(seq4()::VARCHAR, 3, '0')
        WHEN 5 THEN 'CYBER-' || LPAD(seq4()::VARCHAR, 3, '0')
        WHEN 6 THEN 'MDA-' || LPAD(seq4()::VARCHAR, 3, '0')
        WHEN 7 THEN 'C5-' || LPAD(seq4()::VARCHAR, 3, '0')
        ELSE 'TRAIN-' || LPAD(seq4()::VARCHAR, 3, '0')
    END AS program_code,
    CASE MOD(seq4(), 20)
        WHEN 0 THEN 'Valkyrie Block 3 Production'
        WHEN 1 THEN 'Next-Gen Satellite Ground System'
        WHEN 2 THEN 'Erinyes Hypersonic Development'
        WHEN 3 THEN 'GEK-400 Engine Production'
        WHEN 4 THEN 'Advanced EW Microwave System'
        WHEN 5 THEN 'Critical Infrastructure Protection'
        WHEN 6 THEN 'Terminal High Altitude Defense'
        WHEN 7 THEN 'Strategic C2 Modernization'
        WHEN 8 THEN 'F-35 Maintenance Trainer'
        WHEN 9 THEN 'Tactical UAS Target System'
        WHEN 10 THEN 'Space Domain Awareness Platform'
        WHEN 11 THEN 'Dark Fury Test Program'
        WHEN 12 THEN 'Zeus Solid Rocket Motor'
        WHEN 13 THEN 'Satellite Transponder Assembly'
        WHEN 14 THEN 'Cyber Threat Intelligence'
        WHEN 15 THEN 'Interceptor Guidance System'
        WHEN 16 THEN 'Joint All-Domain C2'
        WHEN 17 THEN 'Combat Aircrew Training'
        WHEN 18 THEN 'UTAP-22 Loyal Wingman'
        ELSE 'Ground Control Station Upgrade'
    END || ' - Phase ' || (MOD(seq4(), 3) + 1)::VARCHAR AS program_name,
    ARRAY_CONSTRUCT('DEVELOPMENT', 'PRODUCTION', 'SUSTAINMENT', 'RDT&E', 'SERVICES')[MOD(seq4(), 5)]::VARCHAR AS program_type,
    ARRAY_CONSTRUCT('TACTICAL', 'STRATEGIC', 'SPACE', 'CYBER', 'TRAINING')[MOD(seq4(), 5)]::VARCHAR AS program_category,
    'Defense program for advanced systems development and production. Supports national security objectives through cutting-edge technology solutions.' AS description,
    'CUST' || LPAD((MOD(seq4(), 50) + 1)::VARCHAR, 5, '0') AS customer_id,
    CASE WHEN MOD(seq4(), 3) = 0 THEN 'Kratos Defense' ELSE ARRAY_CONSTRUCT('Lockheed Martin', 'Northrop Grumman', 'Raytheon', 'Boeing', 'General Dynamics')[MOD(seq4(), 5)]::VARCHAR END AS prime_contractor,
    ARRAY_CONSTRUCT('CPFF', 'FFP', 'CPIF', 'T&M', 'IDIQ')[MOD(seq4(), 5)]::VARCHAR AS contract_type,
    ARRAY_CONSTRUCT('ACTIVE', 'ACTIVE', 'ACTIVE', 'COMPLETED', 'ON_HOLD')[MOD(seq4(), 5)]::VARCHAR AS program_status,
    ARRAY_CONSTRUCT('PHASE_1', 'PHASE_2', 'PHASE_3', 'EMD', 'LRIP', 'FRP')[MOD(seq4(), 6)]::VARCHAR AS program_phase,
    ARRAY_CONSTRUCT('UNCLASSIFIED', 'SECRET', 'TOP SECRET', 'SECRET', 'SECRET')[MOD(seq4(), 5)]::VARCHAR AS security_classification,
    DATEADD('year', -UNIFORM(1, 8, RANDOM()), CURRENT_DATE()) AS start_date,
    DATEADD('year', UNIFORM(1, 5, RANDOM()), CURRENT_DATE()) AS planned_end_date,
    NULL AS actual_end_date,
    UNIFORM(5000000, 500000000, RANDOM())::NUMBER(18,2) AS total_contract_value,
    UNIFORM(2000000, 400000000, RANDOM())::NUMBER(18,2) AS funded_value,
    UNIFORM(1000000, 300000000, RANDOM())::NUMBER(18,2) AS costs_incurred,
    UNIFORM(1500000, 350000000, RANDOM())::NUMBER(18,2) AS revenue_recognized,
    UNIFORM(5, 25, RANDOM())::NUMBER(5,2) AS margin_percentage,
    ARRAY_CONSTRUCT('J. Smith', 'M. Johnson', 'R. Williams', 'S. Brown', 'T. Davis')[MOD(seq4(), 5)]::VARCHAR AS program_manager,
    ARRAY_CONSTRUCT('Dr. K. Lee', 'Dr. P. Chen', 'Dr. A. Kumar', 'Dr. L. Garcia', 'Dr. R. Patel')[MOD(seq4(), 5)]::VARCHAR AS technical_lead,
    ARRAY_CONSTRUCT('LOW', 'MEDIUM', 'HIGH', 'MEDIUM', 'LOW')[MOD(seq4(), 5)]::VARCHAR AS risk_level,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM TABLE(GENERATOR(ROWCOUNT => 200));

-- ============================================================================
-- Step 4: Generate CONTRACTS (300 contracts)
-- ============================================================================
INSERT INTO CONTRACTS
SELECT
    'CONT' || LPAD(ROW_NUMBER() OVER (ORDER BY seq4()), 6, '0') AS contract_id,
    'PROG' || LPAD((MOD(seq4(), 200) + 1)::VARCHAR, 6, '0') AS program_id,
    'CUST' || LPAD((MOD(seq4(), 50) + 1)::VARCHAR, 5, '0') AS customer_id,
    'W911QX-' || (20 + MOD(seq4(), 6))::VARCHAR || '-C-' || LPAD(seq4()::VARCHAR, 4, '0') AS contract_number,
    CASE MOD(seq4(), 10)
        WHEN 0 THEN 'Unmanned Systems Development and Production'
        WHEN 1 THEN 'Satellite Ground System Support Services'
        WHEN 2 THEN 'Hypersonic Test Vehicle Fabrication'
        WHEN 3 THEN 'Turbine Engine Manufacturing'
        WHEN 4 THEN 'Microwave Component Supply'
        WHEN 5 THEN 'Cybersecurity Operations Support'
        WHEN 6 THEN 'Missile Defense System Integration'
        WHEN 7 THEN 'C5ISR Platform Modernization'
        WHEN 8 THEN 'Training Simulation Development'
        ELSE 'Engineering and Technical Services'
    END AS contract_name,
    ARRAY_CONSTRUCT('CPFF', 'FFP', 'CPIF', 'T&M', 'IDIQ')[MOD(seq4(), 5)]::VARCHAR AS contract_type,
    ARRAY_CONSTRUCT('GSA Schedule', 'SEWP V', 'CIO-SP3', 'OASIS', 'SeaPort-e')[MOD(seq4(), 5)]::VARCHAR AS contract_vehicle,
    DATEADD('year', -UNIFORM(1, 5, RANDOM()), CURRENT_DATE()) AS award_date,
    DATEADD('day', UNIFORM(30, 90, RANDOM()), DATEADD('year', -UNIFORM(1, 5, RANDOM()), CURRENT_DATE())) AS start_date,
    DATEADD('year', UNIFORM(1, 5, RANDOM()), CURRENT_DATE()) AS end_date,
    UNIFORM(12, 60, RANDOM()) AS period_of_performance_months,
    UNIFORM(1000000, 100000000, RANDOM())::NUMBER(18,2) AS base_value,
    UNIFORM(500000, 50000000, RANDOM())::NUMBER(18,2) AS option_value,
    UNIFORM(2000000, 150000000, RANDOM())::NUMBER(18,2) AS total_value,
    UNIFORM(1000000, 100000000, RANDOM())::NUMBER(18,2) AS funded_amount,
    ARRAY_CONSTRUCT('ACTIVE', 'ACTIVE', 'ACTIVE', 'COMPLETED', 'PENDING')[MOD(seq4(), 5)]::VARCHAR AS contract_status,
    UNIFORM(0, 15, RANDOM()) AS modification_count,
    ARRAY_CONSTRUCT('UNCLASSIFIED', 'SECRET', 'TOP SECRET')[MOD(seq4(), 3)]::VARCHAR AS security_classification,
    ARRAY_CONSTRUCT('LTC Smith', 'COL Johnson', 'MAJ Williams', 'CDR Brown', 'CAPT Davis')[MOD(seq4(), 5)]::VARCHAR AS contracting_officer,
    LOWER(ARRAY_CONSTRUCT('smith', 'johnson', 'williams', 'brown', 'davis')[MOD(seq4(), 5)]::VARCHAR) || '.co@mail.mil' AS contracting_officer_email,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM TABLE(GENERATOR(ROWCOUNT => 300));

-- ============================================================================
-- Step 5: Generate ASSETS (500 unmanned systems and equipment)
-- ============================================================================
INSERT INTO ASSETS
SELECT
    'ASSET' || LPAD(ROW_NUMBER() OVER (ORDER BY seq4()), 6, '0') AS asset_id,
    ARRAY_CONSTRUCT('DIV001', 'DIV002', 'DIV003', 'DIV004', 'DIV005', 'DIV006', 'DIV007', 'DIV008', 'DIV009')[MOD(seq4(), 9)]::VARCHAR AS division_id,
    CASE WHEN MOD(seq4(), 3) = 0 THEN 'PROG' || LPAD((MOD(seq4(), 200) + 1)::VARCHAR, 6, '0') ELSE NULL END AS program_id,
    'SN-' || LPAD(seq4()::VARCHAR, 8, '0') AS asset_serial_number,
    CASE MOD(seq4(), 15)
        WHEN 0 THEN 'XQ-58 Valkyrie'
        WHEN 1 THEN 'BQM-167A Skeeter'
        WHEN 2 THEN 'UTAP-22 Mako'
        WHEN 3 THEN 'Satellite Ground Terminal'
        WHEN 4 THEN 'GEK-400 Turbine Engine'
        WHEN 5 THEN 'Dark Fury Test Vehicle'
        WHEN 6 THEN 'Zeus Solid Rocket Motor'
        WHEN 7 THEN 'Microwave Transmitter Assembly'
        WHEN 8 THEN 'Cyber Operations Console'
        WHEN 9 THEN 'Interceptor Guidance Unit'
        WHEN 10 THEN 'C2 Communications Suite'
        WHEN 11 THEN 'Flight Training Simulator'
        WHEN 12 THEN 'BQM-74 Chukar'
        WHEN 13 THEN 'Antenna Control System'
        ELSE 'Ground Control Station'
    END || ' Unit ' || seq4()::VARCHAR AS asset_name,
    CASE MOD(seq4(), 6)
        WHEN 0 THEN 'UAV'
        WHEN 1 THEN 'GROUND_SYSTEM'
        WHEN 2 THEN 'ENGINE'
        WHEN 3 THEN 'ELECTRONICS'
        WHEN 4 THEN 'SIMULATOR'
        ELSE 'SATELLITE_EQUIPMENT'
    END AS asset_type,
    CASE MOD(seq4(), 5)
        WHEN 0 THEN 'TACTICAL'
        WHEN 1 THEN 'STRATEGIC'
        WHEN 2 THEN 'TRAINING'
        WHEN 3 THEN 'TEST'
        ELSE 'PRODUCTION'
    END AS asset_category,
    CASE MOD(seq4(), 8)
        WHEN 0 THEN 'XQ-58A Block 2'
        WHEN 1 THEN 'BQM-167A'
        WHEN 2 THEN 'UTAP-22'
        WHEN 3 THEN 'SGS-4000'
        WHEN 4 THEN 'GEK-400'
        WHEN 5 THEN 'DF-1'
        WHEN 6 THEN 'ZSM-200'
        ELSE 'GCS-3.0'
    END AS asset_model,
    'Kratos Defense' AS manufacturer,
    DATEADD('year', -UNIFORM(1, 8, RANDOM()), CURRENT_DATE()) AS manufacture_date,
    DATEADD('day', UNIFORM(30, 180, RANDOM()), DATEADD('year', -UNIFORM(1, 8, RANDOM()), CURRENT_DATE())) AS acquisition_date,
    UNIFORM(500000, 25000000, RANDOM())::NUMBER(15,2) AS acquisition_cost,
    UNIFORM(250000, 20000000, RANDOM())::NUMBER(15,2) AS current_value,
    ARRAY_CONSTRUCT('OPERATIONAL', 'OPERATIONAL', 'OPERATIONAL', 'MAINTENANCE', 'STORAGE')[MOD(seq4(), 5)]::VARCHAR AS asset_status,
    ARRAY_CONSTRUCT('AVAILABLE', 'DEPLOYED', 'TESTING', 'MAINTENANCE', 'AVAILABLE')[MOD(seq4(), 5)]::VARCHAR AS operational_status,
    ARRAY_CONSTRUCT('Sacramento, CA', 'Orlando, FL', 'Huntsville, AL', 'San Diego, CA', 'Colorado Springs, CO')[MOD(seq4(), 5)]::VARCHAR AS location,
    CASE WHEN MOD(seq4(), 4) = 0 THEN 'CUST' || LPAD((MOD(seq4(), 50) + 1)::VARCHAR, 5, '0') ELSE NULL END AS assigned_customer_id,
    UNIFORM(0, 5000, RANDOM())::NUMBER(10,2) AS total_flight_hours,
    UNIFORM(0, 500, RANDOM()) AS total_missions,
    DATEADD('day', -UNIFORM(1, 180, RANDOM()), CURRENT_DATE()) AS last_maintenance_date,
    DATEADD('day', UNIFORM(30, 365, RANDOM()), CURRENT_DATE()) AS next_maintenance_due,
    UNIFORM(100, 500, RANDOM()) AS maintenance_interval_hours,
    'v' || UNIFORM(1, 5, RANDOM())::VARCHAR || '.' || UNIFORM(0, 9, RANDOM())::VARCHAR || '.' || UNIFORM(0, 9, RANDOM())::VARCHAR AS software_version,
    'FW-' || UNIFORM(1, 3, RANDOM())::VARCHAR || '.' || UNIFORM(0, 9, RANDOM())::VARCHAR AS firmware_version,
    ARRAY_CONSTRUCT('UNCLASSIFIED', 'SECRET', 'TOP SECRET')[MOD(seq4(), 3)]::VARCHAR AS security_classification,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM TABLE(GENERATOR(ROWCOUNT => 500));

-- ============================================================================
-- Step 6: Generate ASSET_OPERATIONS (50,000 operation records)
-- ============================================================================
INSERT INTO ASSET_OPERATIONS
SELECT
    'OP' || LPAD(ROW_NUMBER() OVER (ORDER BY seq4()), 8, '0') AS operation_id,
    'ASSET' || LPAD((MOD(seq4(), 500) + 1)::VARCHAR, 6, '0') AS asset_id,
    CASE WHEN MOD(seq4(), 3) = 0 THEN 'PROG' || LPAD((MOD(seq4(), 200) + 1)::VARCHAR, 6, '0') ELSE NULL END AS program_id,
    DATEADD('day', -UNIFORM(1, 730, RANDOM()), CURRENT_DATE()) AS operation_date,
    ARRAY_CONSTRUCT('FLIGHT', 'TEST', 'TRAINING', 'MAINTENANCE_RUN', 'DEMONSTRATION')[MOD(seq4(), 5)]::VARCHAR AS operation_type,
    ARRAY_CONSTRUCT('RECONNAISSANCE', 'TARGET', 'LOYAL_WINGMAN', 'GROUND_TEST', 'CUSTOMER_DEMO')[MOD(seq4(), 5)]::VARCHAR AS mission_type,
    'Mission ' || seq4()::VARCHAR AS mission_name,
    ARRAY_CONSTRUCT('Edwards AFB, CA', 'Eglin AFB, FL', 'White Sands, NM', 'Yuma, AZ', 'Point Mugu, CA')[MOD(seq4(), 5)]::VARCHAR AS location,
    UNIFORM(0, 8, RANDOM())::NUMBER(6,2) AS flight_hours,
    UNIFORM(1, 5, RANDOM()) AS cycles,
    UNIFORM(50, 500, RANDOM())::NUMBER(10,2) AS fuel_consumed,
    UNIFORM(0, 45000, RANDOM()) AS altitude_max,
    UNIFORM(0, 600, RANDOM()) AS speed_max,
    UNIFORM(0, 500, RANDOM())::NUMBER(10,2) AS distance_traveled,
    ARRAY_CONSTRUCT('COMPLETED', 'COMPLETED', 'COMPLETED', 'ABORTED', 'COMPLETED')[MOD(seq4(), 5)]::VARCHAR AS operation_status,
    ARRAY_CONSTRUCT('CPT Miller', 'MAJ Thompson', 'LT Garcia', 'SGT Wilson', 'MSGT Lee')[MOD(seq4(), 5)]::VARCHAR AS pilot_operator,
    ARRAY_CONSTRUCT('CLEAR', 'PARTLY_CLOUDY', 'OVERCAST', 'WINDY', 'CLEAR')[MOD(seq4(), 5)]::VARCHAR AS weather_conditions,
    CASE WHEN MOD(seq4(), 20) = 0 THEN FALSE ELSE TRUE END AS mission_success,
    CASE WHEN MOD(seq4(), 15) = 0 THEN UNIFORM(1, 3, RANDOM()) ELSE 0 END AS anomalies_detected,
    'Standard operation completed per SOP. All systems nominal.' AS notes,
    CURRENT_TIMESTAMP() AS created_at
FROM TABLE(GENERATOR(ROWCOUNT => 50000));

-- ============================================================================
-- Step 7: Generate MAINTENANCE_RECORDS (100,000 records)
-- ============================================================================
INSERT INTO MAINTENANCE_RECORDS
SELECT
    'MAINT' || LPAD(ROW_NUMBER() OVER (ORDER BY seq4()), 8, '0') AS maintenance_id,
    'ASSET' || LPAD((MOD(seq4(), 500) + 1)::VARCHAR, 6, '0') AS asset_id,
    DATEADD('day', -UNIFORM(1, 730, RANDOM()), CURRENT_DATE()) AS maintenance_date,
    ARRAY_CONSTRUCT('SCHEDULED', 'UNSCHEDULED', 'INSPECTION', 'OVERHAUL', 'MODIFICATION')[MOD(seq4(), 5)]::VARCHAR AS maintenance_type,
    ARRAY_CONSTRUCT('AIRFRAME', 'ENGINE', 'AVIONICS', 'PAYLOAD', 'GROUND_SUPPORT')[MOD(seq4(), 5)]::VARCHAR AS maintenance_category,
    'WO-' || LPAD(seq4()::VARCHAR, 8, '0') AS work_order_number,
    CASE MOD(seq4(), 10)
        WHEN 0 THEN 'Performed 100-hour inspection per TM. All items satisfactory.'
        WHEN 1 THEN 'Replaced fuel filter assembly. Tested and verified operation.'
        WHEN 2 THEN 'Software update to latest version. Regression testing complete.'
        WHEN 3 THEN 'Repaired hydraulic leak on landing gear actuator.'
        WHEN 4 THEN 'Calibrated navigation sensors per procedure.'
        WHEN 5 THEN 'Replaced worn brake pads. Brake test satisfactory.'
        WHEN 6 THEN 'Engine oil change and filter replacement.'
        WHEN 7 THEN 'Antenna alignment and signal verification.'
        WHEN 8 THEN 'Battery replacement and charging system check.'
        ELSE 'General preventive maintenance per schedule.'
    END AS description,
    CASE WHEN MOD(seq4(), 3) = 0 THEN 'Fuel filter, O-rings, gaskets' ELSE NULL END AS parts_replaced,
    UNIFORM(1, 40, RANDOM())::NUMBER(6,2) AS labor_hours,
    UNIFORM(100, 25000, RANDOM())::NUMBER(12,2) AS parts_cost,
    UNIFORM(50, 5000, RANDOM())::NUMBER(12,2) AS labor_cost,
    UNIFORM(200, 30000, RANDOM())::NUMBER(12,2) AS total_cost,
    ARRAY_CONSTRUCT('J. Rodriguez', 'M. Chen', 'S. Patel', 'R. Thompson', 'K. Williams')[MOD(seq4(), 5)]::VARCHAR AS technician_name,
    ARRAY_CONSTRUCT('A&P', 'IA', 'Avionics', 'Structures', 'Engine')[MOD(seq4(), 5)]::VARCHAR AS technician_certification,
    ARRAY_CONSTRUCT('COMPLETED', 'COMPLETED', 'COMPLETED', 'IN_PROGRESS', 'COMPLETED')[MOD(seq4(), 5)]::VARCHAR AS maintenance_status,
    UNIFORM(100, 5000, RANDOM())::NUMBER(10,2) AS flight_hours_at_maintenance,
    UNIFORM(200, 5500, RANDOM())::NUMBER(10,2) AS next_maintenance_hours,
    CASE WHEN MOD(seq4(), 50) = 0 THEN FALSE ELSE TRUE END AS quality_inspection_passed,
    CASE WHEN MOD(seq4(), 10) = 0 THEN 'Normal wear' ELSE NULL END AS root_cause,
    CASE WHEN MOD(seq4(), 10) = 0 THEN 'Part replacement per schedule' ELSE NULL END AS corrective_action,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM TABLE(GENERATOR(ROWCOUNT => 100000));

-- ============================================================================
-- Step 8: Generate PARTS_INVENTORY (2,000 parts)
-- ============================================================================
INSERT INTO PARTS_INVENTORY
SELECT
    'PART' || LPAD(ROW_NUMBER() OVER (ORDER BY seq4()), 6, '0') AS part_id,
    ARRAY_CONSTRUCT('DIV001', 'DIV002', 'DIV003', 'DIV004', 'DIV005', 'DIV006', 'DIV007', 'DIV008', 'DIV009')[MOD(seq4(), 9)]::VARCHAR AS division_id,
    'PN-' || LPAD(seq4()::VARCHAR, 8, '0') AS part_number,
    CASE MOD(seq4(), 20)
        WHEN 0 THEN 'Fuel Filter Assembly'
        WHEN 1 THEN 'Hydraulic Actuator'
        WHEN 2 THEN 'Navigation Sensor'
        WHEN 3 THEN 'Engine Oil Filter'
        WHEN 4 THEN 'Landing Gear Strut'
        WHEN 5 THEN 'Flight Control Servo'
        WHEN 6 THEN 'Antenna Assembly'
        WHEN 7 THEN 'Battery Pack'
        WHEN 8 THEN 'Brake Assembly'
        WHEN 9 THEN 'Propeller Blade'
        WHEN 10 THEN 'Engine Mount'
        WHEN 11 THEN 'Fuel Pump'
        WHEN 12 THEN 'Avionics Module'
        WHEN 13 THEN 'Wiring Harness'
        WHEN 14 THEN 'Control Surface'
        WHEN 15 THEN 'Exhaust Nozzle'
        WHEN 16 THEN 'Heat Shield'
        WHEN 17 THEN 'Turbine Blade'
        WHEN 18 THEN 'Bearing Assembly'
        ELSE 'Seal Kit'
    END AS part_name,
    ARRAY_CONSTRUCT('AIRFRAME', 'ENGINE', 'AVIONICS', 'HYDRAULIC', 'ELECTRICAL')[MOD(seq4(), 5)]::VARCHAR AS part_category,
    ARRAY_CONSTRUCT('CONSUMABLE', 'REPAIRABLE', 'EXPENDABLE', 'ROTABLE', 'STANDARD')[MOD(seq4(), 5)]::VARCHAR AS part_type,
    ARRAY_CONSTRUCT('Kratos', 'Parker', 'Honeywell', 'Collins', 'Moog')[MOD(seq4(), 5)]::VARCHAR AS manufacturer,
    UNIFORM(50, 50000, RANDOM())::NUMBER(12,2) AS unit_cost,
    UNIFORM(0, 100, RANDOM()) AS quantity_on_hand,
    UNIFORM(0, 20, RANDOM()) AS quantity_reserved,
    UNIFORM(0, 80, RANDOM()) AS quantity_available,
    UNIFORM(5, 25, RANDOM()) AS reorder_point,
    UNIFORM(10, 50, RANDOM()) AS reorder_quantity,
    UNIFORM(14, 180, RANDOM()) AS lead_time_days,
    ARRAY_CONSTRUCT('Warehouse A', 'Warehouse B', 'Hangar 1', 'Shop Floor', 'Bonded Storage')[MOD(seq4(), 5)]::VARCHAR AS storage_location,
    CASE WHEN MOD(seq4(), 10) = 0 THEN UNIFORM(365, 1825, RANDOM()) ELSE NULL END AS shelf_life_days,
    CASE WHEN MOD(seq4(), 5) = 0 THEN TRUE ELSE FALSE END AS is_critical,
    CASE WHEN MOD(seq4(), 20) = 0 THEN TRUE ELSE FALSE END AS is_hazardous,
    CASE WHEN MOD(seq4(), 10) = 0 THEN TRUE ELSE FALSE END AS export_controlled,
    DATEADD('day', -UNIFORM(1, 180, RANDOM()), CURRENT_DATE()) AS last_receipt_date,
    DATEADD('day', -UNIFORM(1, 90, RANDOM()), CURRENT_DATE()) AS last_issue_date,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM TABLE(GENERATOR(ROWCOUNT => 2000));

-- ============================================================================
-- Step 9: Generate MANUFACTURING_ORDERS (25,000 orders)
-- ============================================================================
INSERT INTO MANUFACTURING_ORDERS
SELECT
    'MO' || LPAD(ROW_NUMBER() OVER (ORDER BY seq4()), 8, '0') AS order_id,
    ARRAY_CONSTRUCT('DIV001', 'DIV002', 'DIV003', 'DIV004', 'DIV005', 'DIV006', 'DIV007', 'DIV008', 'DIV009')[MOD(seq4(), 9)]::VARCHAR AS division_id,
    'PROG' || LPAD((MOD(seq4(), 200) + 1)::VARCHAR, 6, '0') AS program_id,
    CASE WHEN MOD(seq4(), 3) = 0 THEN 'CONT' || LPAD((MOD(seq4(), 300) + 1)::VARCHAR, 6, '0') ELSE NULL END AS contract_id,
    'MO-' || LPAD(seq4()::VARCHAR, 8, '0') AS order_number,
    ARRAY_CONSTRUCT('PRODUCTION', 'PROTOTYPE', 'SPARE_PARTS', 'REPAIR', 'MODIFICATION')[MOD(seq4(), 5)]::VARCHAR AS order_type,
    CASE MOD(seq4(), 15)
        WHEN 0 THEN 'XQ-58 Valkyrie Airframe'
        WHEN 1 THEN 'GEK-400 Turbine Engine'
        WHEN 2 THEN 'Ground Control Station'
        WHEN 3 THEN 'Satellite Antenna Assembly'
        WHEN 4 THEN 'Microwave Transmitter'
        WHEN 5 THEN 'Zeus Rocket Motor'
        WHEN 6 THEN 'Flight Computer Module'
        WHEN 7 THEN 'Navigation System'
        WHEN 8 THEN 'Fuel System Assembly'
        WHEN 9 THEN 'Landing Gear Assembly'
        WHEN 10 THEN 'Wing Assembly'
        WHEN 11 THEN 'Tail Section'
        WHEN 12 THEN 'Payload Bay'
        WHEN 13 THEN 'Control Surface Set'
        ELSE 'Wiring Harness Kit'
    END AS product_name,
    ARRAY_CONSTRUCT('AIRFRAME', 'ENGINE', 'AVIONICS', 'STRUCTURES', 'SYSTEMS')[MOD(seq4(), 5)]::VARCHAR AS product_type,
    UNIFORM(1, 50, RANDOM()) AS quantity_ordered,
    UNIFORM(0, 45, RANDOM()) AS quantity_completed,
    UNIFORM(0, 5, RANDOM()) AS quantity_scrapped,
    UNIFORM(10000, 500000, RANDOM())::NUMBER(12,2) AS unit_cost,
    UNIFORM(50000, 5000000, RANDOM())::NUMBER(15,2) AS total_cost,
    DATEADD('day', -UNIFORM(1, 365, RANDOM()), CURRENT_DATE()) AS order_date,
    DATEADD('day', UNIFORM(30, 180, RANDOM()), CURRENT_DATE()) AS required_date,
    DATEADD('day', -UNIFORM(1, 300, RANDOM()), CURRENT_DATE()) AS start_date,
    CASE WHEN MOD(seq4(), 5) = 0 THEN NULL ELSE DATEADD('day', -UNIFORM(1, 60, RANDOM()), CURRENT_DATE()) END AS completion_date,
    ARRAY_CONSTRUCT('COMPLETED', 'IN_PROGRESS', 'PENDING', 'ON_HOLD', 'COMPLETED')[MOD(seq4(), 5)]::VARCHAR AS order_status,
    ARRAY_CONSTRUCT('NORMAL', 'HIGH', 'CRITICAL', 'NORMAL', 'LOW')[MOD(seq4(), 5)]::VARCHAR AS priority,
    ARRAY_CONSTRUCT('Line A', 'Line B', 'Cell 1', 'Cell 2', 'Prototype Shop')[MOD(seq4(), 5)]::VARCHAR AS production_line,
    ARRAY_CONSTRUCT('DAY', 'SWING', 'NIGHT', 'DAY', 'DAY')[MOD(seq4(), 5)]::VARCHAR AS shift,
    'Production order for defense program deliverables.' AS notes,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM TABLE(GENERATOR(ROWCOUNT => 25000));

-- ============================================================================
-- Step 10: Generate QUALITY_INSPECTIONS (10,000 inspections)
-- ============================================================================
INSERT INTO QUALITY_INSPECTIONS
SELECT
    'QI' || LPAD(ROW_NUMBER() OVER (ORDER BY seq4()), 8, '0') AS inspection_id,
    CASE WHEN MOD(seq4(), 2) = 0 THEN 'MO' || LPAD((MOD(seq4(), 25000) + 1)::VARCHAR, 8, '0') ELSE NULL END AS order_id,
    CASE WHEN MOD(seq4(), 2) = 1 THEN 'ASSET' || LPAD((MOD(seq4(), 500) + 1)::VARCHAR, 6, '0') ELSE NULL END AS asset_id,
    DATEADD('day', -UNIFORM(1, 365, RANDOM()), CURRENT_DATE()) AS inspection_date,
    ARRAY_CONSTRUCT('INCOMING', 'IN_PROCESS', 'FINAL', 'RECEIVING', 'FIRST_ARTICLE')[MOD(seq4(), 5)]::VARCHAR AS inspection_type,
    ARRAY_CONSTRUCT('DIMENSIONAL', 'FUNCTIONAL', 'VISUAL', 'NDT', 'DOCUMENTATION')[MOD(seq4(), 5)]::VARCHAR AS inspection_category,
    ARRAY_CONSTRUCT('M. Garcia', 'J. Lee', 'S. Patel', 'R. Johnson', 'K. Williams')[MOD(seq4(), 5)]::VARCHAR AS inspector_name,
    ARRAY_CONSTRUCT('ASQ CQE', 'ASQ CQT', 'A&P IA', 'NDT Level II', 'ISO Auditor')[MOD(seq4(), 5)]::VARCHAR AS inspector_certification,
    'Inspection per QAP-' || LPAD(MOD(seq4(), 100)::VARCHAR, 3, '0') AS inspection_criteria,
    ARRAY_CONSTRUCT('PASS', 'PASS', 'PASS', 'PASS', 'CONDITIONAL', 'FAIL')[MOD(seq4(), 6)]::VARCHAR AS inspection_result,
    CASE WHEN MOD(seq4(), 10) = 0 THEN UNIFORM(1, 5, RANDOM()) ELSE 0 END AS defects_found,
    CASE WHEN MOD(seq4(), 10) = 0 THEN 'Minor surface defect noted' ELSE NULL END AS defect_description,
    CASE WHEN MOD(seq4(), 10) = 0 THEN TRUE ELSE FALSE END AS corrective_action_required,
    CASE WHEN MOD(seq4(), 10) = 0 THEN 'Defect corrected and reinspected' ELSE NULL END AS corrective_action_taken,
    CASE WHEN MOD(seq4(), 20) = 0 THEN TRUE ELSE FALSE END AS retest_required,
    CASE WHEN MOD(seq4(), 20) = 0 THEN DATEADD('day', UNIFORM(1, 7, RANDOM()), CURRENT_DATE()) ELSE NULL END AS retest_date,
    CASE WHEN MOD(seq4(), 20) = 0 THEN 'PASS' ELSE NULL END AS retest_result,
    UNIFORM(85, 100, RANDOM())::NUMBER(5,2) AS quality_score,
    'Inspection completed per procedure.' AS notes,
    CURRENT_TIMESTAMP() AS created_at
FROM TABLE(GENERATOR(ROWCOUNT => 10000));

-- ============================================================================
-- Step 11: Generate ENGINEERING_PROJECTS (500 projects)
-- ============================================================================
INSERT INTO ENGINEERING_PROJECTS
SELECT
    'ENG' || LPAD(ROW_NUMBER() OVER (ORDER BY seq4()), 6, '0') AS project_id,
    ARRAY_CONSTRUCT('DIV001', 'DIV002', 'DIV003', 'DIV004', 'DIV005', 'DIV006', 'DIV007', 'DIV008', 'DIV009')[MOD(seq4(), 9)]::VARCHAR AS division_id,
    CASE WHEN MOD(seq4(), 2) = 0 THEN 'PROG' || LPAD((MOD(seq4(), 200) + 1)::VARCHAR, 6, '0') ELSE NULL END AS program_id,
    'EP-' || LPAD(seq4()::VARCHAR, 5, '0') AS project_code,
    CASE MOD(seq4(), 20)
        WHEN 0 THEN 'Next-Gen Autonomous Flight Control'
        WHEN 1 THEN 'Advanced Propulsion Integration'
        WHEN 2 THEN 'AI-Enabled Target Recognition'
        WHEN 3 THEN 'Hypersonic Thermal Protection'
        WHEN 4 THEN 'Software-Defined Satellite Modem'
        WHEN 5 THEN 'Cyber Resilience Architecture'
        WHEN 6 THEN 'Advanced Materials Research'
        WHEN 7 THEN 'Digital Twin Development'
        WHEN 8 THEN 'Swarm Coordination Algorithms'
        WHEN 9 THEN 'Low Observable Technology'
        WHEN 10 THEN 'Electric Propulsion System'
        WHEN 11 THEN 'Additive Manufacturing Process'
        WHEN 12 THEN 'Sensor Fusion Platform'
        WHEN 13 THEN 'Modular Payload Interface'
        WHEN 14 THEN 'Autonomous Navigation System'
        WHEN 15 THEN 'RF Seeker Development'
        WHEN 16 THEN 'Ground Station Modernization'
        WHEN 17 THEN 'Simulation Framework'
        WHEN 18 THEN 'Reliability Enhancement'
        ELSE 'Cost Reduction Initiative'
    END AS project_name,
    ARRAY_CONSTRUCT('R&D', 'IRAD', 'CRAD', 'PRODUCTION_IMPROVEMENT', 'SUSTAINMENT')[MOD(seq4(), 5)]::VARCHAR AS project_type,
    ARRAY_CONSTRUCT('ADVANCED_TECH', 'MANUFACTURING', 'SOFTWARE', 'SYSTEMS', 'TESTING')[MOD(seq4(), 5)]::VARCHAR AS project_category,
    'Engineering project to advance technology capabilities and improve system performance.' AS description,
    ARRAY_CONSTRUCT('ACTIVE', 'ACTIVE', 'COMPLETED', 'ON_HOLD', 'ACTIVE')[MOD(seq4(), 5)]::VARCHAR AS project_status,
    ARRAY_CONSTRUCT('CONCEPT', 'DESIGN', 'DEVELOPMENT', 'TEST', 'PRODUCTION')[MOD(seq4(), 5)]::VARCHAR AS project_phase,
    UNIFORM(3, 9, RANDOM()) AS technology_readiness_level,
    DATEADD('year', -UNIFORM(1, 5, RANDOM()), CURRENT_DATE()) AS start_date,
    DATEADD('year', UNIFORM(1, 3, RANDOM()), CURRENT_DATE()) AS planned_end_date,
    CASE WHEN MOD(seq4(), 5) = 2 THEN DATEADD('day', -UNIFORM(1, 180, RANDOM()), CURRENT_DATE()) ELSE NULL END AS actual_end_date,
    UNIFORM(100000, 10000000, RANDOM())::NUMBER(15,2) AS budget,
    UNIFORM(50000, 8000000, RANDOM())::NUMBER(15,2) AS actual_cost,
    ARRAY_CONSTRUCT('Dr. A. Kumar', 'Dr. L. Chen', 'J. Martinez', 'R. Thompson', 'S. Wilson')[MOD(seq4(), 5)]::VARCHAR AS project_manager,
    ARRAY_CONSTRUCT('Dr. P. Patel', 'Dr. M. Lee', 'Dr. K. Brown', 'Dr. J. Davis', 'Dr. R. Garcia')[MOD(seq4(), 5)]::VARCHAR AS lead_engineer,
    UNIFORM(3, 25, RANDOM()) AS team_size,
    CASE WHEN MOD(seq4(), 5) = 0 THEN TRUE ELSE FALSE END AS ip_generated,
    CASE WHEN MOD(seq4(), 10) = 0 THEN UNIFORM(1, 3, RANDOM()) ELSE 0 END AS patents_filed,
    ARRAY_CONSTRUCT('LOW', 'MEDIUM', 'HIGH', 'MEDIUM', 'LOW')[MOD(seq4(), 5)]::VARCHAR AS risk_level,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM TABLE(GENERATOR(ROWCOUNT => 500));

-- ============================================================================
-- Step 12: Generate TEST_EVENTS (5,000 tests)
-- ============================================================================
INSERT INTO TEST_EVENTS
SELECT
    'TEST' || LPAD(ROW_NUMBER() OVER (ORDER BY seq4()), 6, '0') AS test_id,
    CASE WHEN MOD(seq4(), 2) = 0 THEN 'ENG' || LPAD((MOD(seq4(), 500) + 1)::VARCHAR, 6, '0') ELSE NULL END AS project_id,
    CASE WHEN MOD(seq4(), 3) = 0 THEN 'ASSET' || LPAD((MOD(seq4(), 500) + 1)::VARCHAR, 6, '0') ELSE NULL END AS asset_id,
    CASE WHEN MOD(seq4(), 4) = 0 THEN 'PROG' || LPAD((MOD(seq4(), 200) + 1)::VARCHAR, 6, '0') ELSE NULL END AS program_id,
    'T-' || LPAD(seq4()::VARCHAR, 6, '0') AS test_number,
    CASE MOD(seq4(), 15)
        WHEN 0 THEN 'Flight Envelope Expansion'
        WHEN 1 THEN 'Engine Performance Test'
        WHEN 2 THEN 'Avionics Integration Check'
        WHEN 3 THEN 'Environmental Qualification'
        WHEN 4 THEN 'Electromagnetic Compatibility'
        WHEN 5 THEN 'Structural Load Test'
        WHEN 6 THEN 'Software Verification'
        WHEN 7 THEN 'Propulsion Hot Fire'
        WHEN 8 THEN 'Guidance Accuracy Test'
        WHEN 9 THEN 'Communication Range Test'
        WHEN 10 THEN 'Endurance Evaluation'
        WHEN 11 THEN 'Reliability Demonstration'
        WHEN 12 THEN 'First Flight'
        WHEN 13 THEN 'Customer Acceptance'
        ELSE 'Production Verification'
    END AS test_name,
    ARRAY_CONSTRUCT('FLIGHT', 'GROUND', 'LAB', 'ENVIRONMENTAL', 'INTEGRATION')[MOD(seq4(), 5)]::VARCHAR AS test_type,
    ARRAY_CONSTRUCT('DEVELOPMENT', 'QUALIFICATION', 'ACCEPTANCE', 'REGRESSION', 'PRODUCTION')[MOD(seq4(), 5)]::VARCHAR AS test_category,
    DATEADD('day', -UNIFORM(1, 730, RANDOM()), CURRENT_DATE()) AS test_date,
    ARRAY_CONSTRUCT('Edwards AFB, CA', 'Eglin AFB, FL', 'White Sands, NM', 'Yuma, AZ', 'Point Mugu, CA')[MOD(seq4(), 5)]::VARCHAR AS test_location,
    UNIFORM(1, 12, RANDOM())::NUMBER(6,2) AS test_duration_hours,
    'Verify system performance meets specification requirements.' AS test_objective,
    'Test conducted per ATP-' || LPAD(MOD(seq4(), 100)::VARCHAR, 3, '0') AS test_procedure,
    ARRAY_CONSTRUCT('COMPLETED', 'COMPLETED', 'COMPLETED', 'ABORTED', 'COMPLETED')[MOD(seq4(), 5)]::VARCHAR AS test_status,
    ARRAY_CONSTRUCT('PASS', 'PASS', 'PASS', 'PASS', 'CONDITIONAL', 'FAIL')[MOD(seq4(), 6)]::VARCHAR AS test_result,
    CASE WHEN MOD(seq4(), 10) = 0 THEN FALSE ELSE TRUE END AS success_criteria_met,
    CASE WHEN MOD(seq4(), 15) = 0 THEN UNIFORM(1, 5, RANDOM()) ELSE 0 END AS anomalies_count,
    UNIFORM(1, 500, RANDOM())::NUMBER(8,2) AS data_collected_gb,
    ARRAY_CONSTRUCT('M. Rodriguez', 'J. Thompson', 'S. Chen', 'R. Patel', 'K. Williams')[MOD(seq4(), 5)]::VARCHAR AS test_conductor,
    ARRAY_CONSTRUCT('A. Kumar', 'L. Garcia', 'P. Lee', 'M. Brown', 'J. Davis')[MOD(seq4(), 5)]::VARCHAR AS witness,
    CASE WHEN MOD(seq4(), 5) = 0 THEN TRUE ELSE FALSE END AS customer_witnessed,
    'Test completed per approved procedure. Data under review.' AS notes,
    CURRENT_TIMESTAMP() AS created_at
FROM TABLE(GENERATOR(ROWCOUNT => 5000));

-- ============================================================================
-- Step 13: Generate EMPLOYEES (5,000 employees)
-- ============================================================================
INSERT INTO EMPLOYEES
SELECT
    'EMP' || LPAD(ROW_NUMBER() OVER (ORDER BY seq4()), 6, '0') AS employee_id,
    ARRAY_CONSTRUCT('DIV001', 'DIV002', 'DIV003', 'DIV004', 'DIV005', 'DIV006', 'DIV007', 'DIV008', 'DIV009')[MOD(seq4(), 9)]::VARCHAR AS division_id,
    'E' || LPAD(seq4()::VARCHAR, 6, '0') AS employee_number,
    ARRAY_CONSTRUCT('James', 'Mary', 'John', 'Patricia', 'Robert', 'Jennifer', 'Michael', 'Linda', 'William', 'Elizabeth')[MOD(seq4(), 10)]::VARCHAR AS first_name,
    ARRAY_CONSTRUCT('Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez')[MOD(seq4(), 10)]::VARCHAR AS last_name,
    LOWER(ARRAY_CONSTRUCT('james', 'mary', 'john', 'patricia', 'robert', 'jennifer', 'michael', 'linda', 'william', 'elizabeth')[MOD(seq4(), 10)]::VARCHAR) || '.' || LOWER(ARRAY_CONSTRUCT('smith', 'johnson', 'williams', 'brown', 'jones', 'garcia', 'miller', 'davis', 'rodriguez', 'martinez')[MOD(seq4(), 10)]::VARCHAR) || '@kratos.com' AS email,
    '858-555-' || LPAD((1000 + MOD(seq4(), 9000))::VARCHAR, 4, '0') AS phone,
    CASE MOD(seq4(), 20)
        WHEN 0 THEN 'Senior Systems Engineer'
        WHEN 1 THEN 'Program Manager'
        WHEN 2 THEN 'Manufacturing Technician'
        WHEN 3 THEN 'Quality Inspector'
        WHEN 4 THEN 'Software Developer'
        WHEN 5 THEN 'Test Engineer'
        WHEN 6 THEN 'Mechanical Engineer'
        WHEN 7 THEN 'Electrical Engineer'
        WHEN 8 THEN 'Project Engineer'
        WHEN 9 THEN 'Production Supervisor'
        WHEN 10 THEN 'Contracts Administrator'
        WHEN 11 THEN 'Supply Chain Analyst'
        WHEN 12 THEN 'Cybersecurity Analyst'
        WHEN 13 THEN 'Data Scientist'
        WHEN 14 THEN 'Flight Test Pilot'
        WHEN 15 THEN 'Propulsion Engineer'
        WHEN 16 THEN 'Avionics Technician'
        WHEN 17 THEN 'Structural Analyst'
        WHEN 18 THEN 'Configuration Manager'
        ELSE 'Engineering Technician'
    END AS job_title,
    ARRAY_CONSTRUCT('Engineering', 'Manufacturing', 'Quality', 'Programs', 'Operations')[MOD(seq4(), 5)]::VARCHAR AS department,
    ARRAY_CONSTRUCT('FULL_TIME', 'FULL_TIME', 'FULL_TIME', 'CONTRACTOR', 'FULL_TIME')[MOD(seq4(), 5)]::VARCHAR AS employee_type,
    ARRAY_CONSTRUCT('SECRET', 'SECRET', 'TOP SECRET', 'TOP SECRET/SCI', 'CONFIDENTIAL')[MOD(seq4(), 5)]::VARCHAR AS security_clearance,
    DATEADD('year', UNIFORM(1, 5, RANDOM()), CURRENT_DATE()) AS clearance_expiry_date,
    DATEADD('year', -UNIFORM(1, 20, RANDOM()), CURRENT_DATE()) AS hire_date,
    NULL AS termination_date,
    'ACTIVE' AS employee_status,
    CASE WHEN MOD(seq4(), 10) > 0 THEN 'EMP' || LPAD((MOD(seq4() - 1, 500) + 1)::VARCHAR, 6, '0') ELSE NULL END AS manager_id,
    ARRAY_CONSTRUCT('ENGINEER', 'TECHNICIAN', 'MANAGER', 'SPECIALIST', 'ANALYST')[MOD(seq4(), 5)]::VARCHAR AS labor_category,
    UNIFORM(35, 150, RANDOM())::NUMBER(10,2) AS hourly_rate,
    UNIFORM(60000, 250000, RANDOM())::NUMBER(12,2) AS annual_salary,
    CASE MOD(seq4(), 5)
        WHEN 0 THEN 'PMP, Six Sigma Green Belt'
        WHEN 1 THEN 'A&P, IA'
        WHEN 2 THEN 'ASQ CQE'
        WHEN 3 THEN 'CISSP, Security+'
        ELSE 'PE, INCOSE CSEP'
    END AS certifications,
    CASE MOD(seq4(), 5)
        WHEN 0 THEN 'Systems Engineering, Program Management'
        WHEN 1 THEN 'Avionics, Electrical Systems'
        WHEN 2 THEN 'Quality Assurance, Process Control'
        WHEN 3 THEN 'Cybersecurity, Network Defense'
        ELSE 'Propulsion, Aerodynamics'
    END AS skills,
    ARRAY_CONSTRUCT('Sacramento, CA', 'Orlando, FL', 'Huntsville, AL', 'San Diego, CA', 'Colorado Springs, CO')[MOD(seq4(), 5)]::VARCHAR AS location,
    CASE WHEN MOD(seq4(), 4) = 0 THEN TRUE ELSE FALSE END AS remote_eligible,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM TABLE(GENERATOR(ROWCOUNT => 5000));

-- ============================================================================
-- Step 14: Generate INCIDENTS (2,000 incidents)
-- ============================================================================
INSERT INTO INCIDENTS
SELECT
    'INC' || LPAD(ROW_NUMBER() OVER (ORDER BY seq4()), 6, '0') AS incident_id,
    CASE WHEN MOD(seq4(), 3) = 0 THEN 'ASSET' || LPAD((MOD(seq4(), 500) + 1)::VARCHAR, 6, '0') ELSE NULL END AS asset_id,
    CASE WHEN MOD(seq4(), 2) = 0 THEN 'PROG' || LPAD((MOD(seq4(), 200) + 1)::VARCHAR, 6, '0') ELSE NULL END AS program_id,
    ARRAY_CONSTRUCT('DIV001', 'DIV002', 'DIV003', 'DIV004', 'DIV005', 'DIV006', 'DIV007', 'DIV008', 'DIV009')[MOD(seq4(), 9)]::VARCHAR AS division_id,
    'INC-' || LPAD(seq4()::VARCHAR, 6, '0') AS incident_number,
    DATEADD('day', -UNIFORM(1, 730, RANDOM()), CURRENT_TIMESTAMP()) AS incident_date,
    ARRAY_CONSTRUCT('SAFETY', 'QUALITY', 'OPERATIONAL', 'SECURITY', 'ENVIRONMENTAL')[MOD(seq4(), 5)]::VARCHAR AS incident_type,
    ARRAY_CONSTRUCT('EQUIPMENT_FAILURE', 'HUMAN_ERROR', 'PROCESS_DEVIATION', 'NEAR_MISS', 'ANOMALY')[MOD(seq4(), 5)]::VARCHAR AS incident_category,
    ARRAY_CONSTRUCT('LOW', 'MEDIUM', 'HIGH', 'CRITICAL', 'LOW')[MOD(seq4(), 5)]::VARCHAR AS severity,
    ARRAY_CONSTRUCT('Sacramento, CA', 'Orlando, FL', 'Huntsville, AL', 'San Diego, CA', 'Edwards AFB, CA')[MOD(seq4(), 5)]::VARCHAR AS location,
    CASE MOD(seq4(), 10)
        WHEN 0 THEN 'During routine flight operations, system experienced unexpected telemetry dropout lasting 30 seconds. Aircraft returned safely using backup systems.'
        WHEN 1 THEN 'Manufacturing quality inspection identified dimensional deviation on critical component. Production halted pending root cause analysis.'
        WHEN 2 THEN 'Engine test cell experienced minor fuel leak during hot fire test. Test terminated early, no injuries or damage.'
        WHEN 3 THEN 'Software anomaly detected during integration testing. Navigation system displayed incorrect heading for 5 seconds before self-correcting.'
        WHEN 4 THEN 'Near miss incident during ground handling. Forklift came within 2 feet of prototype aircraft.'
        WHEN 5 THEN 'Environmental control system exceeded temperature limits during thermal testing. Test specimen within acceptable range.'
        WHEN 6 THEN 'Security badge access anomaly detected. Unauthorized access attempt logged and blocked.'
        WHEN 7 THEN 'Foreign object debris found on production floor. Area cleared and inspected, no damage to hardware.'
        WHEN 8 THEN 'Communication link loss during customer demonstration. Backup link activated within 10 seconds.'
        ELSE 'Minor property damage during maintenance activity. No injuries, hardware impact minimal.'
    END AS description,
    CASE WHEN MOD(seq4(), 3) = 0 THEN 'Root cause under investigation' ELSE NULL END AS root_cause,
    'Immediate area secured and management notified.' AS immediate_action,
    CASE WHEN MOD(seq4(), 2) = 0 THEN 'Corrective action plan developed and in progress' ELSE NULL END AS corrective_action,
    CASE WHEN MOD(seq4(), 4) = 0 THEN 'Additional training and process review scheduled' ELSE NULL END AS preventive_action,
    ARRAY_CONSTRUCT('OPEN', 'INVESTIGATING', 'RESOLVED', 'CLOSED', 'OPEN')[MOD(seq4(), 5)]::VARCHAR AS incident_status,
    ARRAY_CONSTRUCT('PENDING', 'IN_PROGRESS', 'COMPLETED', 'PENDING', 'IN_PROGRESS')[MOD(seq4(), 5)]::VARCHAR AS investigation_status,
    ARRAY_CONSTRUCT('J. Smith', 'M. Johnson', 'R. Williams', 'S. Brown', 'T. Davis')[MOD(seq4(), 5)]::VARCHAR AS reported_by,
    ARRAY_CONSTRUCT('Safety Team', 'Quality Team', 'Engineering', 'Operations', 'Management')[MOD(seq4(), 5)]::VARCHAR AS assigned_to,
    CASE WHEN MOD(seq4(), 3) = 2 THEN DATEADD('day', UNIFORM(1, 30, RANDOM()), DATEADD('day', -UNIFORM(1, 730, RANDOM()), CURRENT_DATE())) ELSE NULL END AS resolution_date,
    CASE WHEN MOD(seq4(), 5) = 0 THEN UNIFORM(1000, 100000, RANDOM())::NUMBER(15,2) ELSE 0 END AS cost_impact,
    CASE WHEN MOD(seq4(), 10) = 0 THEN UNIFORM(1, 30, RANDOM()) ELSE 0 END AS schedule_impact_days,
    CASE WHEN MOD(seq4(), 5) = 0 THEN TRUE ELSE FALSE END AS customer_notified,
    CASE WHEN MOD(seq4(), 3) = 2 THEN 'Lessons learned documented and shared with relevant teams.' ELSE NULL END AS lessons_learned,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM TABLE(GENERATOR(ROWCOUNT => 2000));

-- ============================================================================
-- Step 15: Generate SUPPLIERS (200 suppliers)
-- ============================================================================
INSERT INTO SUPPLIERS
SELECT
    'SUP' || LPAD(ROW_NUMBER() OVER (ORDER BY seq4()), 5, '0') AS supplier_id,
    'V-' || LPAD(seq4()::VARCHAR, 5, '0') AS supplier_code,
    CASE MOD(seq4(), 20)
        WHEN 0 THEN 'Parker Aerospace'
        WHEN 1 THEN 'Honeywell Aerospace'
        WHEN 2 THEN 'Collins Aerospace'
        WHEN 3 THEN 'Moog Inc.'
        WHEN 4 THEN 'Woodward Inc.'
        WHEN 5 THEN 'Spirit AeroSystems'
        WHEN 6 THEN 'Ducommun'
        WHEN 7 THEN 'Triumph Group'
        WHEN 8 THEN 'Astronics Corporation'
        WHEN 9 THEN 'TransDigm Group'
        WHEN 10 THEN 'Heico Corporation'
        WHEN 11 THEN 'Mercury Systems'
        WHEN 12 THEN 'TTM Technologies'
        WHEN 13 THEN 'API Technologies'
        WHEN 14 THEN 'CAES'
        WHEN 15 THEN 'Sierra Nevada Corporation'
        WHEN 16 THEN 'AAR Corp'
        WHEN 17 THEN 'StandardAero'
        WHEN 18 THEN 'Chromalloy'
        ELSE 'Small Business Supplier ' || seq4()::VARCHAR
    END AS supplier_name,
    ARRAY_CONSTRUCT('TIER_1', 'TIER_2', 'TIER_3', 'DISTRIBUTOR', 'OEM')[MOD(seq4(), 5)]::VARCHAR AS supplier_type,
    ARRAY_CONSTRUCT('AEROSPACE', 'ELECTRONICS', 'MATERIALS', 'SERVICES', 'MANUFACTURING')[MOD(seq4(), 5)]::VARCHAR AS supplier_category,
    ARRAY_CONSTRUCT('123 Industrial Blvd', '456 Tech Park Dr', '789 Aerospace Way', '321 Defense Rd', '654 Engineering Ln')[MOD(seq4(), 5)]::VARCHAR AS address,
    ARRAY_CONSTRUCT('Los Angeles', 'Phoenix', 'Dallas', 'Seattle', 'San Diego')[MOD(seq4(), 5)]::VARCHAR AS city,
    ARRAY_CONSTRUCT('CA', 'AZ', 'TX', 'WA', 'CA')[MOD(seq4(), 5)]::VARCHAR AS state,
    'USA' AS country,
    ARRAY_CONSTRUCT('John Smith', 'Jane Doe', 'Bob Johnson', 'Alice Williams', 'Charlie Brown')[MOD(seq4(), 5)]::VARCHAR AS primary_contact,
    LOWER(ARRAY_CONSTRUCT('john.smith', 'jane.doe', 'bob.johnson', 'alice.williams', 'charlie.brown')[MOD(seq4(), 5)]::VARCHAR) || '@' || LOWER(REPLACE(CASE MOD(seq4(), 5) WHEN 0 THEN 'Parker' WHEN 1 THEN 'Honeywell' WHEN 2 THEN 'Collins' WHEN 3 THEN 'Moog' ELSE 'Woodward' END, ' ', '')) || '.com' AS contact_email,
    '800-555-' || LPAD((1000 + MOD(seq4(), 9000))::VARCHAR, 4, '0') AS contact_phone,
    ARRAY_CONSTRUCT('Net 30', 'Net 45', 'Net 60', '2/10 Net 30', 'Net 30')[MOD(seq4(), 5)]::VARCHAR AS payment_terms,
    UNIFORM(3.0, 5.0, RANDOM())::NUMBER(3,2) AS quality_rating,
    UNIFORM(3.0, 5.0, RANDOM())::NUMBER(3,2) AS delivery_rating,
    TRUE AS is_approved,
    CASE WHEN MOD(seq4(), 5) >= 3 THEN TRUE ELSE FALSE END AS is_small_business,
    CASE WHEN MOD(seq4(), 10) = 0 THEN TRUE ELSE FALSE END AS is_woman_owned,
    CASE WHEN MOD(seq4(), 15) = 0 THEN TRUE ELSE FALSE END AS is_veteran_owned,
    LPAD(seq4()::VARCHAR, 5, '0') || 'C' AS cage_code,
    LPAD((seq4() * 1000)::VARCHAR, 9, '0') AS duns_number,
    'ACTIVE' AS supplier_status,
    DATEADD('year', -UNIFORM(1, 15, RANDOM()), CURRENT_DATE()) AS first_order_date,
    UNIFORM(100000, 50000000, RANDOM())::NUMBER(18,2) AS total_spend,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM TABLE(GENERATOR(ROWCOUNT => 200));

-- ============================================================================
-- Step 16: Generate MILESTONES (1,000 milestones)
-- ============================================================================
INSERT INTO MILESTONES
SELECT
    'MS' || LPAD(ROW_NUMBER() OVER (ORDER BY seq4()), 6, '0') AS milestone_id,
    'PROG' || LPAD((MOD(seq4(), 200) + 1)::VARCHAR, 6, '0') AS program_id,
    CASE WHEN MOD(seq4(), 2) = 0 THEN 'CONT' || LPAD((MOD(seq4(), 300) + 1)::VARCHAR, 6, '0') ELSE NULL END AS contract_id,
    'MS-' || LPAD(seq4()::VARCHAR, 5, '0') AS milestone_code,
    CASE MOD(seq4(), 15)
        WHEN 0 THEN 'Preliminary Design Review (PDR)'
        WHEN 1 THEN 'Critical Design Review (CDR)'
        WHEN 2 THEN 'First Article Inspection (FAI)'
        WHEN 3 THEN 'First Flight'
        WHEN 4 THEN 'Qualification Testing Complete'
        WHEN 5 THEN 'Production Readiness Review (PRR)'
        WHEN 6 THEN 'Low Rate Initial Production Start'
        WHEN 7 THEN 'Full Rate Production Decision'
        WHEN 8 THEN 'Customer Acceptance Test'
        WHEN 9 THEN 'Initial Operating Capability (IOC)'
        WHEN 10 THEN 'Full Operating Capability (FOC)'
        WHEN 11 THEN 'Contract Award'
        WHEN 12 THEN 'Prototype Delivery'
        WHEN 13 THEN 'Safety Review Board'
        ELSE 'Technical Readiness Assessment'
    END AS milestone_name,
    ARRAY_CONSTRUCT('REVIEW', 'DELIVERY', 'TEST', 'PRODUCTION', 'CONTRACTUAL')[MOD(seq4(), 5)]::VARCHAR AS milestone_type,
    'Key program milestone for tracking progress and performance.' AS description,
    DATEADD('day', UNIFORM(-365, 365, RANDOM()), CURRENT_DATE()) AS planned_date,
    CASE WHEN MOD(seq4(), 3) = 0 THEN DATEADD('day', UNIFORM(-30, 30, RANDOM()), DATEADD('day', UNIFORM(-365, 365, RANDOM()), CURRENT_DATE())) ELSE NULL END AS actual_date,
    ARRAY_CONSTRUCT('COMPLETED', 'ON_TRACK', 'AT_RISK', 'DELAYED', 'PENDING')[MOD(seq4(), 5)]::VARCHAR AS milestone_status,
    CASE WHEN MOD(seq4(), 3) = 0 THEN TRUE ELSE FALSE END AS deliverable_required,
    CASE WHEN MOD(seq4(), 4) = 0 THEN TRUE ELSE FALSE END AS payment_milestone,
    CASE WHEN MOD(seq4(), 4) = 0 THEN UNIFORM(100000, 5000000, RANDOM())::NUMBER(15,2) ELSE NULL END AS payment_amount,
    CASE WHEN MOD(seq4(), 5) = 0 THEN 100.00 WHEN MOD(seq4(), 5) = 1 THEN 75.00 WHEN MOD(seq4(), 5) = 2 THEN 50.00 ELSE 0.00 END AS completion_percentage,
    CASE WHEN MOD(seq4(), 3) = 0 THEN 'Depends on MS-' || LPAD((seq4() - 1)::VARCHAR, 5, '0') ELSE NULL END AS dependencies,
    'Milestone tracked per program plan.' AS notes,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM TABLE(GENERATOR(ROWCOUNT => 1000));

-- ============================================================================
-- Step 17: Generate PURCHASE_ORDERS (10,000 POs)
-- ============================================================================
INSERT INTO PURCHASE_ORDERS
SELECT
    'PO' || LPAD(ROW_NUMBER() OVER (ORDER BY seq4()), 8, '0') AS po_id,
    'SUP' || LPAD((MOD(seq4(), 200) + 1)::VARCHAR, 5, '0') AS supplier_id,
    CASE WHEN MOD(seq4(), 2) = 0 THEN 'PROG' || LPAD((MOD(seq4(), 200) + 1)::VARCHAR, 6, '0') ELSE NULL END AS program_id,
    ARRAY_CONSTRUCT('DIV001', 'DIV002', 'DIV003', 'DIV004', 'DIV005', 'DIV006', 'DIV007', 'DIV008', 'DIV009')[MOD(seq4(), 9)]::VARCHAR AS division_id,
    'PO-' || LPAD(seq4()::VARCHAR, 8, '0') AS po_number,
    DATEADD('day', -UNIFORM(1, 365, RANDOM()), CURRENT_DATE()) AS po_date,
    DATEADD('day', UNIFORM(14, 90, RANDOM()), CURRENT_DATE()) AS required_date,
    ARRAY_CONSTRUCT('STANDARD', 'BLANKET', 'CONTRACT', 'EMERGENCY', 'SERVICE')[MOD(seq4(), 5)]::VARCHAR AS po_type,
    ARRAY_CONSTRUCT('OPEN', 'RECEIVED', 'PARTIAL', 'CLOSED', 'CANCELLED')[MOD(seq4(), 5)]::VARCHAR AS po_status,
    UNIFORM(1000, 500000, RANDOM())::NUMBER(15,2) AS subtotal,
    UNIFORM(50, 25000, RANDOM())::NUMBER(12,2) AS tax_amount,
    UNIFORM(0, 5000, RANDOM())::NUMBER(10,2) AS shipping_amount,
    UNIFORM(1500, 550000, RANDOM())::NUMBER(15,2) AS total_amount,
    ARRAY_CONSTRUCT('Net 30', 'Net 45', 'Net 60', '2/10 Net 30', 'Net 30')[MOD(seq4(), 5)]::VARCHAR AS payment_terms,
    ARRAY_CONSTRUCT('Ground', 'Air', 'Expedited', 'Will Call', 'Ground')[MOD(seq4(), 5)]::VARCHAR AS shipping_method,
    ARRAY_CONSTRUCT('Sacramento, CA', 'Orlando, FL', 'Huntsville, AL', 'San Diego, CA', 'Colorado Springs, CO')[MOD(seq4(), 5)]::VARCHAR AS ship_to_location,
    ARRAY_CONSTRUCT('J. Buyer', 'M. Procurement', 'S. Supply', 'R. Acquisitions', 'T. Materials')[MOD(seq4(), 5)]::VARCHAR AS buyer,
    CASE WHEN MOD(seq4(), 5) != 4 THEN ARRAY_CONSTRUCT('K. Manager', 'L. Director', 'P. VP', 'M. CFO', 'N. COO')[MOD(seq4(), 5)]::VARCHAR ELSE NULL END AS approved_by,
    CASE WHEN MOD(seq4(), 5) != 4 THEN DATEADD('day', UNIFORM(1, 3, RANDOM()), DATEADD('day', -UNIFORM(1, 365, RANDOM()), CURRENT_DATE())) ELSE NULL END AS approval_date,
    CASE WHEN MOD(seq4(), 5) IN (1, 2, 3) THEN DATEADD('day', UNIFORM(7, 60, RANDOM()), DATEADD('day', -UNIFORM(1, 365, RANDOM()), CURRENT_DATE())) ELSE NULL END AS receipt_date,
    CASE WHEN MOD(seq4(), 5) IN (1, 3) THEN 'INV-' || LPAD(seq4()::VARCHAR, 8, '0') ELSE NULL END AS invoice_number,
    CASE WHEN MOD(seq4(), 5) IN (1, 3) THEN DATEADD('day', UNIFORM(1, 14, RANDOM()), DATEADD('day', UNIFORM(7, 60, RANDOM()), DATEADD('day', -UNIFORM(1, 365, RANDOM()), CURRENT_DATE()))) ELSE NULL END AS invoice_date,
    'Standard procurement order.' AS notes,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM TABLE(GENERATOR(ROWCOUNT => 10000));

-- ============================================================================
-- Display data generation summary
-- ============================================================================
SELECT 'Synthetic data generation complete' AS status;

SELECT 'DIVISIONS' AS table_name, COUNT(*) AS row_count FROM DIVISIONS
UNION ALL SELECT 'CUSTOMERS', COUNT(*) FROM CUSTOMERS
UNION ALL SELECT 'PROGRAMS', COUNT(*) FROM PROGRAMS
UNION ALL SELECT 'CONTRACTS', COUNT(*) FROM CONTRACTS
UNION ALL SELECT 'MILESTONES', COUNT(*) FROM MILESTONES
UNION ALL SELECT 'ASSETS', COUNT(*) FROM ASSETS
UNION ALL SELECT 'ASSET_OPERATIONS', COUNT(*) FROM ASSET_OPERATIONS
UNION ALL SELECT 'MAINTENANCE_RECORDS', COUNT(*) FROM MAINTENANCE_RECORDS
UNION ALL SELECT 'PARTS_INVENTORY', COUNT(*) FROM PARTS_INVENTORY
UNION ALL SELECT 'MANUFACTURING_ORDERS', COUNT(*) FROM MANUFACTURING_ORDERS
UNION ALL SELECT 'QUALITY_INSPECTIONS', COUNT(*) FROM QUALITY_INSPECTIONS
UNION ALL SELECT 'ENGINEERING_PROJECTS', COUNT(*) FROM ENGINEERING_PROJECTS
UNION ALL SELECT 'TEST_EVENTS', COUNT(*) FROM TEST_EVENTS
UNION ALL SELECT 'EMPLOYEES', COUNT(*) FROM EMPLOYEES
UNION ALL SELECT 'INCIDENTS', COUNT(*) FROM INCIDENTS
UNION ALL SELECT 'SUPPLIERS', COUNT(*) FROM SUPPLIERS
UNION ALL SELECT 'PURCHASE_ORDERS', COUNT(*) FROM PURCHASE_ORDERS
ORDER BY table_name;


