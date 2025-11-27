-- ============================================================================
-- Kratos Defense Intelligence Agent - Cortex Search Service Setup
-- ============================================================================
-- Purpose: Create unstructured data tables and Cortex Search services for
--          technical documentation, procedures, and incident reports
-- Syntax verified against: https://docs.snowflake.com/en/sql-reference/sql/create-cortex-search
-- ============================================================================

USE DATABASE KRATOS_INTELLIGENCE;
USE SCHEMA RAW;
USE WAREHOUSE KRATOS_WH;

-- ============================================================================
-- Step 1: Create table for technical documentation (unstructured text data)
-- ============================================================================
CREATE OR REPLACE TABLE TECHNICAL_DOCUMENTATION (
    doc_id VARCHAR(30) PRIMARY KEY,
    program_id VARCHAR(30),
    asset_id VARCHAR(30),
    doc_content VARCHAR(16777216) NOT NULL,
    doc_title VARCHAR(500),
    doc_type VARCHAR(50),
    doc_category VARCHAR(100),
    classification_level VARCHAR(30),
    version VARCHAR(20),
    author VARCHAR(100),
    publish_date DATE NOT NULL,
    keywords VARCHAR(500),
    is_current BOOLEAN DEFAULT TRUE,
    view_count NUMBER(10,0) DEFAULT 0,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (program_id) REFERENCES PROGRAMS(program_id),
    FOREIGN KEY (asset_id) REFERENCES ASSETS(asset_id)
);

-- ============================================================================
-- Step 2: Create table for maintenance procedures
-- ============================================================================
CREATE OR REPLACE TABLE MAINTENANCE_PROCEDURES (
    procedure_id VARCHAR(30) PRIMARY KEY,
    asset_type VARCHAR(50),
    procedure_content VARCHAR(16777216) NOT NULL,
    procedure_title VARCHAR(500) NOT NULL,
    procedure_type VARCHAR(50),
    task_code VARCHAR(30),
    estimated_hours NUMBER(6,2),
    skill_level VARCHAR(30),
    tools_required VARCHAR(1000),
    safety_warnings VARCHAR(2000),
    last_updated TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    is_published BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- Step 3: Create table for incident reports
-- ============================================================================
CREATE OR REPLACE TABLE INCIDENT_REPORTS (
    incident_id VARCHAR(30) PRIMARY KEY,
    incident_content VARCHAR(16777216) NOT NULL,
    incident_title VARCHAR(500) NOT NULL,
    incident_type VARCHAR(50),
    severity VARCHAR(20),
    asset_id VARCHAR(30),
    program_id VARCHAR(30),
    incident_date DATE NOT NULL,
    reported_by VARCHAR(100),
    root_cause VARCHAR(2000),
    corrective_actions VARCHAR(3000),
    lessons_learned VARCHAR(3000),
    status VARCHAR(30) DEFAULT 'OPEN',
    closed_date DATE,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (asset_id) REFERENCES ASSETS(asset_id),
    FOREIGN KEY (program_id) REFERENCES PROGRAMS(program_id)
);

-- ============================================================================
-- Step 4: Enable change tracking (required for Cortex Search)
-- ============================================================================
ALTER TABLE TECHNICAL_DOCUMENTATION SET CHANGE_TRACKING = TRUE;
ALTER TABLE MAINTENANCE_PROCEDURES SET CHANGE_TRACKING = TRUE;
ALTER TABLE INCIDENT_REPORTS SET CHANGE_TRACKING = TRUE;

-- ============================================================================
-- Step 5: Generate sample technical documentation
-- ============================================================================
INSERT INTO TECHNICAL_DOCUMENTATION VALUES
('DOC001', 'PRG000001', 'AST000001', 
$$TACTICAL UNMANNED AERIAL VEHICLE (UAV) OPERATIONS MANUAL
Version 2.1 - Kratos Defense Technical Publication

CHAPTER 1: INTRODUCTION

1.1 PURPOSE AND SCOPE
This manual provides comprehensive operational guidance for the Tactical UAV System. It covers all aspects of mission planning, flight operations, payload management, and post-mission procedures.

1.2 SYSTEM OVERVIEW
The Tactical UAV is a medium-altitude, long-endurance unmanned aircraft designed for intelligence, surveillance, and reconnaissance (ISR) missions. Key specifications:
- Maximum endurance: 24 hours
- Operational ceiling: 25,000 feet
- Payload capacity: 200 lbs
- Communication range: 150+ nautical miles

1.3 SAFETY REQUIREMENTS
All personnel must complete UAV operator certification before conducting flight operations. Emergency procedures must be reviewed before each mission.

CHAPTER 2: PRE-FLIGHT PROCEDURES

2.1 MISSION PLANNING
Mission planning shall include:
- Route planning and airspace coordination
- Weather assessment and contingency planning
- Payload configuration based on mission requirements
- Communication link verification

2.2 SYSTEM CHECKS
Pre-flight inspections must verify:
- Structural integrity of airframe
- Control surface operation
- Engine and propulsion system status
- Avionics and communication systems
- Payload integration and operation$$,
'Tactical UAV Operations Manual', 'OPERATIONS_MANUAL', 'Flight Operations', 'SECRET', '2.1', 'Systems Engineering Team', '2024-01-15', 'UAV, operations, flight procedures, mission planning', TRUE, 1250, CURRENT_TIMESTAMP()),

('DOC002', 'PRG000002', NULL,
$$SATELLITE COMMUNICATION SYSTEM INTEGRATION GUIDE
Kratos Space & Satellite Systems Division

SECTION 1: SYSTEM ARCHITECTURE

1.1 OVERVIEW
This guide describes the integration procedures for the advanced satellite communication terminal with existing ground infrastructure. The system provides secure voice, data, and video communications.

1.2 COMPONENTS
- Antenna Assembly (2.4m dish)
- High-Power Amplifier (HPA) - 200W
- Block Upconverter (BUC)
- Low-Noise Block Downconverter (LNB)
- Modem and Encryption Unit
- Control and Monitoring System

SECTION 2: INSTALLATION REQUIREMENTS

2.1 SITE PREPARATION
- Concrete pad minimum 10x10 feet
- Clear line of sight to satellite arc
- Grounding system per MIL-STD-188-124
- AC power: 208V, 3-phase, 60Hz, 30A

2.2 ENVIRONMENTAL SPECIFICATIONS
Operating temperature: -40°C to +55°C
Humidity: 0-100% condensing
Wind survival: 125 mph
Rain fade margin: 6 dB

SECTION 3: INTEGRATION PROCEDURES

3.1 ANTENNA ALIGNMENT
Use integrated GPS receiver and inclinometer for initial pointing. Fine alignment uses beacon tracking for optimal signal acquisition.$$,
'Satellite Communication Integration Guide', 'INTEGRATION_GUIDE', 'Communications', 'CONFIDENTIAL', '1.5', 'Space Systems Team', '2024-03-01', 'satellite, SATCOM, integration, ground terminal', TRUE, 890, CURRENT_TIMESTAMP()),

('DOC003', 'PRG000003', 'AST000050',
$$ELECTRONIC WARFARE SYSTEM TECHNICAL REFERENCE
Microwave Electronics Division - Kratos Defense

PART 1: SYSTEM DESCRIPTION

1.1 PURPOSE
The Electronic Warfare (EW) pod provides comprehensive electronic attack and protection capabilities for tactical aircraft and ground platforms.

1.2 CAPABILITIES
- Radar warning receiver (RWR): 2-18 GHz
- Electronic countermeasures (ECM): Multi-threat jamming
- Expendable countermeasures interface
- Threat library: 500+ emitters

1.3 PERFORMANCE SPECIFICATIONS
Frequency coverage: 2-40 GHz
Sensitivity: -65 dBm
ERP: 1000W peak
Response time: <1 second

PART 2: OPERATIONAL MODES

2.1 AUTOMATIC MODE
System automatically detects, identifies, and responds to threats based on preprogrammed mission data files.

2.2 MANUAL MODE
Operator selects jamming techniques and parameters. Recommended for complex threat environments.

PART 3: MAINTENANCE REQUIREMENTS

3.1 SCHEDULED MAINTENANCE
- 50-hour inspection: BIT checks, connector inspection
- 200-hour inspection: Full calibration, VSWR checks
- 500-hour inspection: Complete system overhaul$$,
'Electronic Warfare System Technical Reference', 'TECHNICAL_REFERENCE', 'Electronic Warfare', 'SECRET', '3.2', 'EW Engineering Team', '2024-02-28', 'electronic warfare, EW, jamming, radar warning', TRUE, 2100, CURRENT_TIMESTAMP()),

('DOC004', NULL, NULL,
$$CYBERSECURITY REQUIREMENTS FOR DEFENSE SYSTEMS
Kratos C5ISR Division - Security Compliance Documentation

SECTION 1: OVERVIEW

1.1 PURPOSE
This document establishes mandatory cybersecurity requirements for all Kratos defense systems and products. Compliance with these requirements is essential for DoD certification.

1.2 APPLICABLE STANDARDS
- NIST SP 800-171: Protecting CUI
- NIST SP 800-53: Security Controls
- RMF (Risk Management Framework)
- CMMC 2.0 Level 2

SECTION 2: ACCESS CONTROL

2.1 IDENTIFICATION AND AUTHENTICATION
- Multi-factor authentication required
- CAC/PIV card integration
- Password complexity: 15+ characters
- Session timeout: 15 minutes

2.2 ACCOUNT MANAGEMENT
- Quarterly access reviews
- Separation of duties enforcement
- Privileged access monitoring
- Audit logging retention: 1 year

SECTION 3: SYSTEM HARDENING

3.1 CONFIGURATION MANAGEMENT
All systems must be configured per DISA STIGs. Automated scanning required monthly.

3.2 VULNERABILITY MANAGEMENT
- Critical vulnerabilities: 15-day remediation
- High vulnerabilities: 30-day remediation
- Medium/Low: 90-day remediation$$,
'Cybersecurity Requirements Documentation', 'COMPLIANCE_GUIDE', 'Cybersecurity', 'UNCLASSIFIED', '1.0', 'Information Security Team', '2024-04-01', 'cybersecurity, CMMC, compliance, RMF, NIST', TRUE, 3500, CURRENT_TIMESTAMP()),

('DOC005', 'PRG000005', NULL,
$$MISSILE DEFENSE RADAR SYSTEM OPERATOR HANDBOOK
Defense & Rocket Support Division

CHAPTER 1: SYSTEM FUNDAMENTALS

1.1 MISSION
The Missile Defense Radar (MDR) provides long-range detection, tracking, and discrimination of ballistic missile threats. It is a critical component of the layered missile defense architecture.

1.2 RADAR CHARACTERISTICS
- Type: Active Electronically Scanned Array (AESA)
- Frequency: S-band
- Range: 3000+ km (detection)
- Track capacity: 1000+ simultaneous targets
- Power: 10 MW peak

CHAPTER 2: OPERATOR PROCEDURES

2.1 SYSTEM STARTUP
Power-on sequence requires 15 minutes for full warm-up. BIT tests automatically execute during startup.

2.2 SEARCH MODES
- Volume search: 360° azimuth, 0-80° elevation
- Sector search: Concentrated coverage in threat corridor
- Track mode: Precision tracking of designated objects

2.3 DATA FUSION
Radar tracks are correlated with external sensor data and forwarded to the Command and Control system for engagement decisions.

CHAPTER 3: MAINTENANCE

3.1 OPERATOR-LEVEL MAINTENANCE
- Daily: System BIT, cooling system checks
- Weekly: Antenna inspection, calibration verification
- Monthly: Full system diagnostic$$,
'Missile Defense Radar Operator Handbook', 'OPERATOR_HANDBOOK', 'Radar Systems', 'TOP SECRET', '4.0', 'MDR Program Office', '2024-01-01', 'missile defense, radar, AESA, BMD, tracking', TRUE, 1800, CURRENT_TIMESTAMP());

-- ============================================================================
-- Step 6: Generate maintenance procedures
-- ============================================================================
INSERT INTO MAINTENANCE_PROCEDURES VALUES
('PROC001', 'AIRCRAFT',
$$UAV ENGINE INSPECTION AND MAINTENANCE PROCEDURE
Task Code: 72-00-00-01 | Skill Level: Advanced

1. PURPOSE
This procedure covers the 100-hour engine inspection for tactical UAV propulsion systems.

2. SAFETY PRECAUTIONS
⚠️ WARNING: Ensure all power sources are disconnected
⚠️ WARNING: Allow engine to cool for minimum 2 hours
⚠️ CAUTION: Use proper PPE including eye protection and gloves

3. REQUIRED TOOLS
- Digital borescope with 4mm probe
- Torque wrench (ft-lbs and in-lbs)
- Compression tester kit
- Oil analysis sampling kit
- Multimeter for electrical checks

4. INSPECTION STEPS

4.1 External Inspection
□ Check engine mounts for cracks or looseness
□ Inspect exhaust system for leaks or damage
□ Verify oil lines and fittings are secure
□ Check fuel system for leaks

4.2 Internal Inspection (Borescope)
□ Inspect combustion chamber for deposits
□ Check turbine blades for erosion/damage
□ Verify compressor blade condition
□ Document any findings with photos

4.3 Oil System
□ Drain and collect oil sample for analysis
□ Replace oil filter
□ Refill with MIL-PRF-23699 oil
□ Verify oil pressure after startup

5. POST-MAINTENANCE CHECKS
□ Engine ground run minimum 15 minutes
□ Verify all parameters within limits
□ Complete maintenance log entry$$,
'UAV Engine 100-Hour Inspection', 'SCHEDULED', '72-00-00-01', 8.0, 'ADVANCED', 'Borescope, Torque wrench, Compression tester, Oil analysis kit', 'Ensure power disconnected. Allow cooling time. Use proper PPE.', CURRENT_TIMESTAMP(), TRUE, CURRENT_TIMESTAMP()),

('PROC002', 'ELECTRONICS',
$$RADAR ANTENNA CALIBRATION PROCEDURE
Task Code: 34-50-00-01 | Skill Level: Expert

1. PURPOSE
Annual calibration procedure for phased array radar antenna elements to maintain tracking accuracy.

2. REQUIRED EQUIPMENT
- Network analyzer (calibrated)
- Signal generator
- Spectrum analyzer
- Antenna range or anechoic chamber
- Calibration standard targets

3. PREPARATION
□ Ensure system is in calibration mode
□ Verify environmental conditions (temp 20-25°C)
□ Connect test equipment per diagram
□ Allow 30-minute warm-up period

4. CALIBRATION SEQUENCE

4.1 Transmit Path Calibration
□ Measure transmit power for each element
□ Record phase measurements
□ Apply correction factors as needed
□ Verify VSWR < 1.5:1

4.2 Receive Path Calibration
□ Inject known signal levels
□ Measure gain uniformity
□ Check noise figure
□ Calibrate phase shifters

4.3 Beam Steering Verification
□ Test beam positions at multiple angles
□ Verify sidelobe levels meet spec
□ Document monopulse accuracy

5. ACCEPTANCE CRITERIA
- Pointing accuracy: < 0.1 degree
- Gain variation: < 0.5 dB across aperture
- Phase error: < 5 degrees RMS$$,
'Radar Antenna Annual Calibration', 'CALIBRATION', '34-50-00-01', 16.0, 'EXPERT', 'Network analyzer, Signal generator, Spectrum analyzer, Cal targets', 'High voltage present during calibration. Observe radiation hazards.', CURRENT_TIMESTAMP(), TRUE, CURRENT_TIMESTAMP()),

('PROC003', 'EQUIPMENT',
$$GROUND CONTROL STATION SOFTWARE UPDATE PROCEDURE
Task Code: 42-10-00-01 | Skill Level: Intermediate

1. PURPOSE
Procedure for deploying software updates to Ground Control Station (GCS) systems.

2. PRE-REQUISITES
- Approved software release package
- Backup of current configuration
- Maintenance window approved
- Network connectivity verified

3. BACKUP PROCEDURE
□ Export current configuration
□ Backup mission database
□ Save operator preferences
□ Verify backup integrity

4. UPDATE INSTALLATION

4.1 Preparation
□ Copy update package to GCS
□ Verify checksum matches manifest
□ Review release notes
□ Notify operations of maintenance

4.2 Installation Steps
□ Stop all GCS services
□ Run pre-update script
□ Execute installer package
□ Run post-update script
□ Restart services

4.3 Verification
□ Login and verify version number
□ Test communication links
□ Verify display functionality
□ Test mission planning features

5. ROLLBACK PROCEDURE
If issues occur:
□ Stop services
□ Restore from backup
□ Restart services
□ Notify program office$$,
'GCS Software Update Procedure', 'SOFTWARE_UPDATE', '42-10-00-01', 4.0, 'INTERMEDIATE', 'Laptop, Update media, Backup storage', 'Ensure backup is verified before update. Have rollback plan ready.', CURRENT_TIMESTAMP(), TRUE, CURRENT_TIMESTAMP());

-- ============================================================================
-- Step 7: Generate incident reports
-- ============================================================================
INSERT INTO INCIDENT_REPORTS VALUES
('INC001',
$$INCIDENT REPORT: UAV COMMUNICATION LOSS EVENT
Date: 2024-03-15 | Classification: SECRET

EXECUTIVE SUMMARY
During a routine training mission, communication with tactical UAV was lost for approximately 12 minutes. The aircraft entered autonomous recovery mode and safely returned to base.

INCIDENT DETAILS
- Mission: Training flight, ISR pattern
- Duration of comm loss: 12 minutes 34 seconds
- Altitude at loss: 15,000 feet AGL
- Distance from GCS: 45 nautical miles

TIMELINE OF EVENTS
1423Z - Normal operations, link quality good
1425Z - Link degradation observed, -3dB
1427Z - Link lost, autonomous mode activated
1435Z - Aircraft reaches recovery point
1439Z - Link reestablished, manual control resumed
1445Z - Aircraft landed safely

ROOT CAUSE ANALYSIS
Investigation determined that electromagnetic interference from nearby commercial communications tower caused the link degradation. The tower had recently increased power output without coordinating with range operations.

CORRECTIVE ACTIONS TAKEN
1. Contacted FCC regarding interference source
2. Updated mission planning to avoid affected area
3. Installed additional spectrum monitoring equipment
4. Revised pre-mission coordination checklist

LESSONS LEARNED
- Pre-mission RF surveys should include recent infrastructure changes
- Autonomous recovery procedures performed as designed
- Communication redundancy recommendations being evaluated$$,
'UAV Communication Loss During Training Mission', 'OPERATIONAL', 'MEDIUM', 'AST000010', 'PRG000001', '2024-03-15', 'Flight Operations Team', 'EMI from commercial tower upgrade', 'Updated mission planning, installed spectrum monitoring', 'Pre-mission RF surveys critical, autonomous recovery worked as designed', 'CLOSED', '2024-03-28', CURRENT_TIMESTAMP()),

('INC002',
$$INCIDENT REPORT: MANUFACTURING DEFECT DISCOVERY
Date: 2024-02-20 | Classification: UNCLASSIFIED

EXECUTIVE SUMMARY
During receiving inspection, a lot of 50 turbine blade assemblies was found to have improper heat treatment, potentially affecting structural integrity.

INCIDENT DETAILS
- Part Number: TB-2847-001
- Lot Number: 2024-A-0472
- Quantity Affected: 50 units
- Supplier: Advanced Materials Group
- Discovery: Receiving inspection hardness testing

NONCONFORMANCE DESCRIPTION
Rockwell hardness testing revealed values 15-20% below specification on 47 of 50 units. This indicates improper heat treatment during manufacturing.

CONTAINMENT ACTIONS
1. Quarantined entire lot immediately
2. Traced serial numbers - none installed in production
3. Reviewed previous lots - no similar issues
4. Issued supplier quality notification

ROOT CAUSE (SUPPLIER INVESTIGATION)
Furnace thermocouple malfunction during heat treat cycle resulted in lower than required temperature. Supplier's process monitoring failed to detect the deviation.

CORRECTIVE ACTIONS
1. Supplier replaced defective thermocouple
2. Added redundant temperature monitoring
3. Implemented 100% hardness testing for next 5 lots
4. Updated receiving inspection sampling plan

COST IMPACT
- Scrap: 50 units x $2,400 = $120,000
- Investigation: 80 labor hours
- Schedule impact: 2-week delay$$,
'Turbine Blade Heat Treatment Defect', 'QUALITY', 'HIGH', NULL, 'PRG000004', '2024-02-20', 'Quality Assurance Team', 'Furnace thermocouple malfunction at supplier', 'Replaced thermocouple, added monitoring, enhanced inspection', 'Verify supplier process controls, increase receiving inspection', 'CLOSED', '2024-03-05', CURRENT_TIMESTAMP()),

('INC003',
$$INCIDENT REPORT: CYBERSECURITY EVENT
Date: 2024-04-10 | Classification: SECRET

EXECUTIVE SUMMARY
Unauthorized access attempt detected on engineering workstation. Intrusion detection system identified and blocked the attempt. No data exfiltration occurred.

INCIDENT DETAILS
- System Affected: Engineering CAD workstation
- Detection Method: IDS alert
- Duration: 3 minutes (detection to containment)
- Data Impact: None - blocked before access

TIMELINE
0847: Anomalous login attempt detected
0848: IDS triggered, automated quarantine initiated
0850: Security team notified, investigation began
0852: Workstation isolated from network
0900: Forensic imaging initiated
1400: Initial analysis complete

ATTACK VECTOR ANALYSIS
Attacker used compromised credentials obtained through phishing email. The credentials belonged to a contractor who clicked a malicious link.

CONTAINMENT MEASURES
1. Isolated affected workstation
2. Forced password reset for user
3. Blocked source IP addresses
4. Enhanced monitoring on similar systems

CORRECTIVE ACTIONS
1. Additional phishing awareness training
2. Implemented behavioral analytics
3. Enhanced email filtering rules
4. Accelerated MFA deployment

LESSONS LEARNED
- IDS/IPS systems worked as designed
- Response time met SLA requirements
- Phishing remains primary attack vector
- Contractor security training needs enhancement$$,
'Unauthorized Access Attempt on Engineering Workstation', 'CYBERSECURITY', 'CRITICAL', NULL, NULL, '2024-04-10', 'Information Security Team', 'Phishing attack compromised contractor credentials', 'Isolated system, reset credentials, enhanced monitoring', 'IDS effective, need enhanced phishing training', 'CLOSED', '2024-04-15', CURRENT_TIMESTAMP());

-- ============================================================================
-- Step 8: Create Cortex Search Service for Technical Documentation
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE TECHNICAL_DOCS_SEARCH
  ON doc_content
  ATTRIBUTES program_id, doc_type, doc_category, classification_level
  WAREHOUSE = KRATOS_WH
  TARGET_LAG = '1 hour'
  COMMENT = 'Cortex Search service for technical documentation - enables semantic search across technical manuals and guides'
AS
  SELECT
    doc_id,
    doc_content,
    doc_title,
    program_id,
    doc_type,
    doc_category,
    classification_level,
    version,
    publish_date,
    keywords
  FROM TECHNICAL_DOCUMENTATION;

-- ============================================================================
-- Step 9: Create Cortex Search Service for Maintenance Procedures
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE MAINTENANCE_PROCEDURES_SEARCH
  ON procedure_content
  ATTRIBUTES asset_type, procedure_type, skill_level
  WAREHOUSE = KRATOS_WH
  TARGET_LAG = '1 hour'
  COMMENT = 'Cortex Search service for maintenance procedures - enables semantic search across maintenance and repair documentation'
AS
  SELECT
    procedure_id,
    procedure_content,
    procedure_title,
    asset_type,
    procedure_type,
    task_code,
    skill_level,
    estimated_hours,
    tools_required
  FROM MAINTENANCE_PROCEDURES;

-- ============================================================================
-- Step 10: Create Cortex Search Service for Incident Reports
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE INCIDENT_REPORTS_SEARCH
  ON incident_content
  ATTRIBUTES incident_type, severity, status
  WAREHOUSE = KRATOS_WH
  TARGET_LAG = '1 hour'
  COMMENT = 'Cortex Search service for incident reports - enables semantic search across safety and security incidents'
AS
  SELECT
    incident_id,
    incident_content,
    incident_title,
    incident_type,
    severity,
    asset_id,
    program_id,
    incident_date,
    root_cause,
    lessons_learned,
    status
  FROM INCIDENT_REPORTS;

-- ============================================================================
-- Display completion summary
-- ============================================================================
SELECT 'Cortex Search services created successfully' AS status,
       (SELECT COUNT(*) FROM TECHNICAL_DOCUMENTATION) AS technical_docs,
       (SELECT COUNT(*) FROM MAINTENANCE_PROCEDURES) AS maintenance_procedures,
       (SELECT COUNT(*) FROM INCIDENT_REPORTS) AS incident_reports;

