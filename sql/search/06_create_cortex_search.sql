-- ============================================================================
-- Kratos Defense Intelligence Agent - Cortex Search Service Setup
-- ============================================================================
-- Purpose: Create unstructured data tables and Cortex Search services for
--          technical documents, test reports, and program reviews
-- Syntax verified against: https://docs.snowflake.com/en/sql-reference/sql/create-cortex-search
-- ============================================================================

USE DATABASE KRATOS_INTELLIGENCE;
USE SCHEMA RAW;
USE WAREHOUSE KRATOS_WH;

-- ============================================================================
-- Step 1: Create table for technical documents (unstructured text data)
-- ============================================================================
CREATE OR REPLACE TABLE TECHNICAL_DOCUMENTS (
    document_id VARCHAR(30) PRIMARY KEY,
    program_id VARCHAR(30),
    document_title VARCHAR(500) NOT NULL,
    document_content VARCHAR(16777216) NOT NULL,
    document_type VARCHAR(50) NOT NULL,
    document_category VARCHAR(50),
    division_code VARCHAR(20),
    classification_level VARCHAR(30) DEFAULT 'UNCLASSIFIED',
    author VARCHAR(200),
    version VARCHAR(20),
    effective_date DATE,
    last_updated TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    keywords VARCHAR(1000),
    is_published BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (program_id) REFERENCES PROGRAMS(program_id)
);

-- ============================================================================
-- Step 2: Create table for test reports
-- ============================================================================
CREATE OR REPLACE TABLE TEST_REPORTS (
    report_id VARCHAR(30) PRIMARY KEY,
    program_id VARCHAR(30),
    test_id VARCHAR(30),
    report_title VARCHAR(500) NOT NULL,
    report_content VARCHAR(16777216) NOT NULL,
    test_type VARCHAR(50),
    result_status VARCHAR(30),
    test_date DATE,
    test_engineer VARCHAR(200),
    summary VARCHAR(3000),
    findings VARCHAR(5000),
    recommendations VARCHAR(3000),
    attachments_count NUMBER(3,0) DEFAULT 0,
    approval_status VARCHAR(30) DEFAULT 'DRAFT',
    approved_by VARCHAR(200),
    approval_date DATE,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (program_id) REFERENCES PROGRAMS(program_id),
    FOREIGN KEY (test_id) REFERENCES ENGINEERING_TESTS(test_id)
);

-- ============================================================================
-- Step 3: Create table for program review documents
-- ============================================================================
CREATE OR REPLACE TABLE PROGRAM_REVIEWS (
    review_id VARCHAR(30) PRIMARY KEY,
    program_id VARCHAR(30),
    review_title VARCHAR(500) NOT NULL,
    review_content VARCHAR(16777216) NOT NULL,
    review_type VARCHAR(50) NOT NULL,
    review_date DATE NOT NULL,
    review_status VARCHAR(30) DEFAULT 'COMPLETED',
    presenter VARCHAR(200),
    attendees VARCHAR(2000),
    action_items VARCHAR(5000),
    risk_summary VARCHAR(3000),
    schedule_summary VARCHAR(3000),
    cost_summary VARCHAR(3000),
    customer_feedback VARCHAR(3000),
    next_steps VARCHAR(3000),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (program_id) REFERENCES PROGRAMS(program_id)
);

-- ============================================================================
-- Step 4: Enable change tracking (required for Cortex Search)
-- ============================================================================
ALTER TABLE TECHNICAL_DOCUMENTS SET CHANGE_TRACKING = TRUE;
ALTER TABLE TEST_REPORTS SET CHANGE_TRACKING = TRUE;
ALTER TABLE PROGRAM_REVIEWS SET CHANGE_TRACKING = TRUE;

-- ============================================================================
-- Step 5: Generate sample technical documents
-- ============================================================================
INSERT INTO TECHNICAL_DOCUMENTS (document_id, program_id, document_title, document_content, document_type, document_category, division_code, classification_level, author, version, effective_date, keywords)
SELECT
    'DOC' || LPAD(ROW_NUMBER() OVER (ORDER BY seq4), 7, '0') AS document_id,
    'PRG' || LPAD(MOD(seq4, 500) + 1, 6, '0') AS program_id,
    doc_type || ' - ' || product_name AS document_title,
    doc_content AS document_content,
    doc_type,
    ARRAY_CONSTRUCT('DESIGN', 'REQUIREMENTS', 'TEST', 'MANUFACTURING', 'OPERATIONS', 'MAINTENANCE')[MOD(ABS(RANDOM()), 6)]::VARCHAR AS document_category,
    ARRAY_CONSTRUCT('HYPER', 'PROP', 'UAS', 'WPN', 'SPACE', 'MDS')[MOD(ABS(RANDOM()), 6)]::VARCHAR AS division_code,
    CASE 
        WHEN MOD(ABS(RANDOM()), 100) < 60 THEN 'UNCLASSIFIED'
        WHEN MOD(ABS(RANDOM()), 100) < 90 THEN 'CUI'
        ELSE 'ITAR'
    END AS classification_level,
    ARRAY_CONSTRUCT('Dr. James Wilson', 'Emily Chen', 'Robert Kim', 'Sarah Davis', 'Michael Johnson', 'Jennifer Lee')[MOD(ABS(RANDOM()), 6)]::VARCHAR AS author,
    'Rev ' || ARRAY_CONSTRUCT('A', 'B', 'C', 'D', 'NC')[MOD(ABS(RANDOM()), 5)]::VARCHAR AS version,
    DATEADD('day', -1 * (MOD(ABS(RANDOM()), 730)), CURRENT_DATE()) AS effective_date,
    keywords
FROM (
    SELECT 
        seq4,
        CASE MOD(seq4, 10)
            WHEN 0 THEN 'System Specification'
            WHEN 1 THEN 'Interface Control Document'
            WHEN 2 THEN 'Design Document'
            WHEN 3 THEN 'Test Procedure'
            WHEN 4 THEN 'User Manual'
            WHEN 5 THEN 'Maintenance Guide'
            WHEN 6 THEN 'Requirements Document'
            WHEN 7 THEN 'Safety Analysis'
            WHEN 8 THEN 'Performance Specification'
            ELSE 'Technical Report'
        END AS doc_type,
        CASE MOD(seq4, 12)
            WHEN 0 THEN 'XQ-58A Valkyrie'
            WHEN 1 THEN 'Mako Tactical Drone'
            WHEN 2 THEN 'BQM-167 Aerial Target'
            WHEN 3 THEN 'Erinyes Hypersonic System'
            WHEN 4 THEN 'Dark Fury Strike System'
            WHEN 5 THEN 'Spartan Engine'
            WHEN 6 THEN 'GEK Turbine'
            WHEN 7 THEN 'Firejet Target'
            WHEN 8 THEN 'Oriole Rocket Motor'
            WHEN 9 THEN 'Zeus Propulsion'
            WHEN 10 THEN 'Satellite Ground Terminal'
            ELSE 'Electronic Warfare Module'
        END AS product_name,
        CASE MOD(seq4, 10)
            WHEN 0 THEN 'SYSTEM SPECIFICATION DOCUMENT

1. SCOPE
This specification establishes the requirements for the ' || product_name || ' system. It defines the functional, performance, and interface requirements necessary for system development and integration.

2. APPLICABLE DOCUMENTS
- MIL-STD-882E System Safety
- MIL-STD-810H Environmental Testing
- MIL-STD-461G EMI/EMC Requirements
- AS9100D Quality Management System

3. SYSTEM OVERVIEW
The ' || product_name || ' is an advanced defense system designed to provide superior capability in tactical operations. Key features include autonomous operation, modular architecture, and enhanced survivability.

4. PERFORMANCE REQUIREMENTS
4.1 Speed: Operational range from subsonic to supersonic regimes
4.2 Range: Extended operational range meeting customer requirements
4.3 Payload: Configurable payload capacity for mission flexibility
4.4 Endurance: Mission duration exceeds program requirements

5. INTERFACE REQUIREMENTS
5.1 Mechanical interfaces per ICD-001
5.2 Electrical interfaces per ICD-002
5.3 Software interfaces per ICD-003
5.4 Data link interfaces per ICD-004

6. ENVIRONMENTAL REQUIREMENTS
6.1 Operating temperature: -40°F to +140°F
6.2 Storage temperature: -65°F to +160°F
6.3 Humidity: 0-100% RH
6.4 Altitude: Sea level to 60,000 feet

7. RELIABILITY REQUIREMENTS
7.1 MTBF: Minimum 500 hours
7.2 Mission success probability: 95%
7.3 Design life: 10 years or 5000 cycles'
            WHEN 1 THEN 'INTERFACE CONTROL DOCUMENT

1. PURPOSE
This ICD defines the interfaces between the ' || product_name || ' and associated ground support equipment, launch systems, and command/control systems.

2. MECHANICAL INTERFACES
2.1 Mounting Configuration
- Primary mounting points per drawing DWG-001
- Secondary attachment locations per DWG-002
- Structural load paths defined in stress analysis SA-001

2.2 Connector Locations
- Power connectors: J1, J2 per MIL-DTL-38999
- Signal connectors: J3-J8 per MIL-DTL-38999
- RF connectors: SMA per MIL-PRF-39012

3. ELECTRICAL INTERFACES
3.1 Power Requirements
- Primary power: 28VDC +/- 4V at 50A max
- Secondary power: 270VDC for actuators
- Ground power interface: 400Hz AC available

3.2 Signal Interfaces
- MIL-STD-1553B dual redundant data bus
- Ethernet 10/100 for ground checkout
- RS-422 for telemetry backup
- Discrete I/O for safety critical functions

4. SOFTWARE INTERFACES
4.1 Command and control protocol per SRS-001
4.2 Telemetry format per TLM-001
4.3 Mission data loading interface per MDL-001

5. RF INTERFACES
5.1 GPS antenna interface: L1/L2 capable
5.2 Data link: UHF/SHF frequency bands
5.3 Radar altimeter: C-band operation'
            WHEN 2 THEN 'DESIGN DOCUMENT

1. INTRODUCTION
This document describes the detailed design of the ' || product_name || ' system, including architecture, component selection, and design analysis.

2. SYSTEM ARCHITECTURE
2.1 Overview
The system employs a modular architecture enabling rapid configuration for multiple mission types. Key subsystems include:
- Airframe structure
- Propulsion system
- Avionics suite
- Payload bay
- Ground control segment

2.2 Airframe Design
- Composite construction for weight optimization
- Low observable features integrated into design
- Modular wing configuration for transport
- Conformal antenna integration

3. PROPULSION DESIGN
3.1 Engine Integration
- Turbine engine with digital control
- Fuel system with 500 lb capacity
- Inlet designed for optimal pressure recovery
- Exhaust system with IR signature reduction

4. AVIONICS DESIGN
4.1 Flight Control System
- Triple redundant flight computers
- Inertial navigation with GPS aiding
- Automatic flight management
- Emergency recovery capabilities

4.2 Mission Systems
- Multi-mode sensor suite
- Data link for real-time control
- Weapons interface (optional)
- Recording systems for mission data

5. DESIGN ANALYSIS
5.1 Structural analysis per FEA-001
5.2 Thermal analysis per THA-001
5.3 Aerodynamic analysis per CFD-001
5.4 Weight and CG analysis per WCG-001'
            WHEN 3 THEN 'TEST PROCEDURE

1. PURPOSE
This procedure defines the test methods for verifying ' || product_name || ' system requirements per the System Specification.

2. TEST REQUIREMENTS
2.1 Pre-Test Conditions
- System fully assembled per drawing package
- All GSE calibrated and certified
- Test facility configured per facility requirements
- Personnel trained and certified

3. FUNCTIONAL TESTS
3.1 Power Application Test
- Apply primary power per sequence
- Verify all subsystem BIT passes
- Monitor current consumption
- Record all telemetry parameters

3.2 Communications Test
- Verify all data link modes
- Test RF coverage patterns
- Measure bit error rates
- Validate encryption

4. PERFORMANCE TESTS
4.1 Navigation Performance
- GPS acquisition time < 60 seconds
- Navigation accuracy within specification
- INS alignment time < 5 minutes

4.2 Flight Control Performance
- Control surface range and rate
- Autopilot mode transitions
- Stability margins verification

5. ENVIRONMENTAL TESTS
5.1 Temperature Test
- High temperature soak at +140°F
- Low temperature soak at -40°F
- Temperature cycling per MIL-STD-810H

5.2 Vibration Test
- Random vibration per MIL-STD-810H
- Sine sweep for resonance search
- Functional during and after vibe

6. TEST COMPLETION CRITERIA
- All requirements verified
- No open critical anomalies
- Customer witness as required'
            ELSE 'TECHNICAL DOCUMENTATION

1. OVERVIEW
This document provides technical information for the ' || product_name || ' system developed by Kratos Defense & Security Solutions.

2. SYSTEM DESCRIPTION
The ' || product_name || ' represents state-of-the-art technology in defense systems. This system has been designed and manufactured to meet the most stringent military requirements.

3. KEY FEATURES
- Advanced materials and manufacturing
- Modular and scalable architecture
- Proven reliability and performance
- Cost-effective acquisition and sustainment

4. OPERATIONAL CAPABILITIES
The system provides enhanced operational capabilities for military applications, including autonomous operation, precision engagement, and survivability features.

5. MAINTENANCE AND SUPPORT
Comprehensive logistics support package available including technical manuals, training, spares provisioning, and depot-level repair capability.

6. QUALITY ASSURANCE
All products manufactured under AS9100D certified quality management system. Components traceable to original materials with full documentation.

7. EXPORT CONTROL
This product may be subject to export control regulations including ITAR and EAR. Contact Kratos for export licensing requirements.'
        END AS doc_content,
        'hypersonic, unmanned, propulsion, defense, tactical, system, specification, requirements, interface, test' AS keywords
    FROM TABLE(GENERATOR(ROWCOUNT => 1000))
);

-- ============================================================================
-- Step 6: Generate test reports
-- ============================================================================
INSERT INTO TEST_REPORTS (report_id, program_id, test_id, report_title, report_content, test_type, result_status, test_date, test_engineer, summary, findings, recommendations, approval_status)
SELECT
    'RPT' || LPAD(ROW_NUMBER() OVER (ORDER BY seq4), 7, '0') AS report_id,
    'PRG' || LPAD(MOD(seq4, 500) + 1, 6, '0') AS program_id,
    'TEST' || LPAD(MOD(seq4, 3000) + 1, 7, '0') AS test_id,
    test_type || ' Test Report - ' || ARRAY_CONSTRUCT('Unit', 'Integration', 'System', 'Qualification', 'Acceptance')[MOD(ABS(RANDOM()), 5)]::VARCHAR AS report_title,
    report_content,
    test_type,
    CASE 
        WHEN MOD(ABS(RANDOM()), 100) < 75 THEN 'PASS'
        WHEN MOD(ABS(RANDOM()), 100) < 90 THEN 'PASS_WITH_DEVIATION'
        ELSE 'FAIL'
    END AS result_status,
    DATEADD('day', -1 * (MOD(ABS(RANDOM()), 365)), CURRENT_DATE()) AS test_date,
    ARRAY_CONSTRUCT('Dr. James Wilson', 'Emily Chen', 'Robert Kim', 'Sarah Davis', 'Michael Johnson')[MOD(ABS(RANDOM()), 5)]::VARCHAR AS test_engineer,
    'Test completed per approved test procedure. System performance met requirements.' AS summary,
    CASE WHEN MOD(ABS(RANDOM()), 100) < 20 
         THEN 'Minor deviation noted during test execution. Anomaly documented in test log.'
         ELSE 'No significant findings. All test parameters within specification.'
    END AS findings,
    'Continue with program schedule. Address any anomalies per standard process.' AS recommendations,
    ARRAY_CONSTRUCT('APPROVED', 'DRAFT', 'IN_REVIEW')[MOD(ABS(RANDOM()), 3)]::VARCHAR AS approval_status
FROM (
    SELECT seq4,
        ARRAY_CONSTRUCT('Vibration', 'Thermal', 'EMI/EMC', 'Pressure', 'Shock', 'Altitude', 'Humidity', 'Functional', 'Performance', 'Endurance')[MOD(seq4, 10)]::VARCHAR AS test_type,
        'TEST REPORT

1. TEST IDENTIFICATION
Test Article: System Under Test
Test Type: ' || test_type || '
Test Date: ' || TO_CHAR(DATEADD('day', -1 * MOD(seq4, 365), CURRENT_DATE()), 'YYYY-MM-DD') || '
Test Location: Kratos Test Facility

2. TEST OBJECTIVE
Verify system performance under specified test conditions per approved test procedure.

3. TEST CONFIGURATION
- System configured per test procedure requirements
- All instrumentation calibrated and certified
- Environmental conditions monitored and recorded
- Data acquisition systems operational

4. TEST EXECUTION
Test executed per approved procedure with all required personnel present. Test sequence completed without interruption. All data recorded for post-test analysis.

5. TEST RESULTS
All test parameters measured and compared to specification requirements. System demonstrated acceptable performance across all test conditions.

6. DATA ANALYSIS
Detailed analysis of test data performed. Statistical evaluation confirms system meets requirements with adequate margin.

7. ANOMALIES
Any anomalies observed during test execution have been documented. Investigation and disposition completed per quality procedures.

8. CONCLUSIONS
Based on test results, the system is recommended for continued program progression.

9. RECOMMENDATIONS
- Continue with next phase of testing
- Implement any corrective actions identified
- Update test procedures as needed

10. APPROVAL
Submitted for engineering review and customer approval as required.' AS report_content
    FROM TABLE(GENERATOR(ROWCOUNT => 2500))
);

-- ============================================================================
-- Step 7: Generate program review documents
-- ============================================================================
INSERT INTO PROGRAM_REVIEWS (review_id, program_id, review_title, review_content, review_type, review_date, review_status, presenter, attendees, action_items, risk_summary, schedule_summary, cost_summary)
SELECT
    'REV' || LPAD(ROW_NUMBER() OVER (ORDER BY seq4), 7, '0') AS review_id,
    'PRG' || LPAD(MOD(seq4, 500) + 1, 6, '0') AS program_id,
    review_type || ' - ' || ARRAY_CONSTRUCT('Phase 1', 'Phase 2', 'Phase 3', 'Block A', 'Block B', 'Increment 1')[MOD(ABS(RANDOM()), 6)]::VARCHAR AS review_title,
    review_content,
    review_type,
    DATEADD('day', -1 * (MOD(ABS(RANDOM()), 365)), CURRENT_DATE()) AS review_date,
    ARRAY_CONSTRUCT('COMPLETED', 'ACTION_ITEMS_OPEN', 'FOLLOW_UP_REQUIRED')[MOD(ABS(RANDOM()), 3)]::VARCHAR AS review_status,
    ARRAY_CONSTRUCT('Program Manager', 'Chief Engineer', 'Director of Programs', 'VP Engineering')[MOD(ABS(RANDOM()), 4)]::VARCHAR AS presenter,
    'Customer Representatives, Program Office, Engineering Team, Quality Team, Contracts' AS attendees,
    'Review action items and close per program schedule. Track all open items in action item database.' AS action_items,
    'Program risks actively managed. Mitigation plans in place for top risks. No new critical risks identified.' AS risk_summary,
    'Program on track to meet major milestones. Minor schedule pressure on some activities being actively managed.' AS schedule_summary,
    'Program within budget. Cost performance meets expectations. Estimate at completion reviewed and approved.' AS cost_summary
FROM (
    SELECT seq4,
        CASE MOD(seq4, 8)
            WHEN 0 THEN 'Program Management Review'
            WHEN 1 THEN 'Preliminary Design Review'
            WHEN 2 THEN 'Critical Design Review'
            WHEN 3 THEN 'Test Readiness Review'
            WHEN 4 THEN 'Production Readiness Review'
            WHEN 5 THEN 'Flight Readiness Review'
            WHEN 6 THEN 'Monthly Status Review'
            ELSE 'Customer Review'
        END AS review_type,
        'PROGRAM REVIEW DOCUMENT

1. REVIEW OVERVIEW
Review Type: ' || review_type || '
Program: Defense Program
Date: Review Date
Location: Kratos Corporate

2. EXECUTIVE SUMMARY
Program status reviewed with all stakeholders. Key accomplishments, challenges, and path forward discussed. Program remains on track to meet customer requirements.

3. TECHNICAL STATUS
Engineering development progressing per plan. Design maturity appropriate for current phase. No critical technical issues open.

4. SCHEDULE STATUS
- Major milestones tracking to plan
- Critical path activities monitored
- Schedule margin maintained
- Recovery plans in place where needed

5. COST STATUS
- Program within budget
- Actuals tracking to plan
- EAC reviewed and approved
- No significant cost risks

6. RISK STATUS
Program risks actively managed per risk management plan:
- Top 5 risks reviewed
- Mitigation actions on track
- No new critical risks
- Risk retirement progressing

7. QUALITY STATUS
Quality metrics within targets. No significant quality escapes. Corrective actions tracked to closure.

8. ACTION ITEMS
Previous action items reviewed. New actions assigned with due dates and owners.

9. CUSTOMER FEEDBACK
Customer expressed satisfaction with program progress. Key concerns addressed during review.

10. PATH FORWARD
Continue execution per program plan. Address action items. Prepare for next major milestone.' AS review_content
    FROM TABLE(GENERATOR(ROWCOUNT => 500))
);

-- ============================================================================
-- Step 8: Create Cortex Search Service for Technical Documents
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE TECHNICAL_DOCS_SEARCH
  ON document_content
  ATTRIBUTES document_type, division_code, classification_level, program_id
  WAREHOUSE = KRATOS_WH
  TARGET_LAG = '1 hour'
  COMMENT = 'Cortex Search for technical documents - specifications, ICDs, design docs'
AS
  SELECT
    document_id,
    document_content,
    document_title,
    document_type,
    document_category,
    division_code,
    classification_level,
    program_id,
    author,
    version,
    effective_date,
    keywords
  FROM TECHNICAL_DOCUMENTS;

-- ============================================================================
-- Step 9: Create Cortex Search Service for Test Reports
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE TEST_REPORTS_SEARCH
  ON report_content
  ATTRIBUTES test_type, result_status, program_id
  WAREHOUSE = KRATOS_WH
  TARGET_LAG = '1 hour'
  COMMENT = 'Cortex Search for test reports - vibration, thermal, EMI, functional tests'
AS
  SELECT
    report_id,
    report_content,
    report_title,
    test_type,
    result_status,
    program_id,
    test_id,
    test_engineer,
    test_date,
    summary,
    findings,
    recommendations,
    approval_status
  FROM TEST_REPORTS;

-- ============================================================================
-- Step 10: Create Cortex Search Service for Program Reviews
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE PROGRAM_REVIEWS_SEARCH
  ON review_content
  ATTRIBUTES review_type, review_status, program_id
  WAREHOUSE = KRATOS_WH
  TARGET_LAG = '1 hour'
  COMMENT = 'Cortex Search for program reviews - PMR, PDR, CDR, TRR, status reviews'
AS
  SELECT
    review_id,
    review_content,
    review_title,
    review_type,
    review_date,
    review_status,
    program_id,
    presenter,
    attendees,
    action_items,
    risk_summary,
    schedule_summary,
    cost_summary
  FROM PROGRAM_REVIEWS;

-- ============================================================================
-- Display data generation and search service completion summary
-- ============================================================================
SELECT 'Cortex Search services created successfully' AS status,
       (SELECT COUNT(*) FROM TECHNICAL_DOCUMENTS) AS technical_docs,
       (SELECT COUNT(*) FROM TEST_REPORTS) AS test_reports,
       (SELECT COUNT(*) FROM PROGRAM_REVIEWS) AS program_reviews;

