-- ============================================================================
-- Kratos Defense Intelligence Agent - Table Definitions
-- ============================================================================
-- Purpose: Create all necessary tables for defense contractor business model
-- All columns designed for defense industry operations
-- Syntax: Verified against Snowflake SQL Reference
-- ============================================================================

USE DATABASE KRATOS_INTELLIGENCE;
USE SCHEMA RAW;
USE WAREHOUSE KRATOS_WH;

-- ============================================================================
-- DIVISIONS TABLE - Business Units
-- ============================================================================
CREATE OR REPLACE TABLE DIVISIONS (
    division_id VARCHAR(20) PRIMARY KEY,
    division_code VARCHAR(10) NOT NULL,
    division_name VARCHAR(200) NOT NULL,
    division_category VARCHAR(50) NOT NULL,
    description VARCHAR(2000),
    headquarters_location VARCHAR(200),
    employee_count NUMBER(6,0) DEFAULT 0,
    annual_revenue NUMBER(15,2) DEFAULT 0.00,
    primary_customer VARCHAR(100),
    security_clearance_level VARCHAR(30),
    is_active BOOLEAN DEFAULT TRUE,
    established_date DATE,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- CUSTOMERS TABLE - DoD and Allied Customers
-- ============================================================================
CREATE OR REPLACE TABLE CUSTOMERS (
    customer_id VARCHAR(30) PRIMARY KEY,
    customer_code VARCHAR(20) NOT NULL,
    customer_name VARCHAR(300) NOT NULL,
    customer_type VARCHAR(50) NOT NULL,
    customer_category VARCHAR(50),
    agency_branch VARCHAR(100),
    country VARCHAR(50) DEFAULT 'USA',
    primary_contact_name VARCHAR(200),
    primary_contact_email VARCHAR(200),
    primary_contact_phone VARCHAR(30),
    billing_address VARCHAR(500),
    contract_vehicle VARCHAR(100),
    security_clearance_required VARCHAR(30),
    relationship_status VARCHAR(30) DEFAULT 'ACTIVE',
    first_contract_date DATE,
    total_contract_value NUMBER(18,2) DEFAULT 0.00,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- PROGRAMS TABLE - Defense Programs
-- ============================================================================
CREATE OR REPLACE TABLE PROGRAMS (
    program_id VARCHAR(30) PRIMARY KEY,
    division_id VARCHAR(20) NOT NULL,
    program_code VARCHAR(30) NOT NULL,
    program_name VARCHAR(300) NOT NULL,
    program_type VARCHAR(50) NOT NULL,
    program_category VARCHAR(50),
    description VARCHAR(3000),
    customer_id VARCHAR(30),
    prime_contractor VARCHAR(200),
    contract_type VARCHAR(50),
    program_status VARCHAR(30) DEFAULT 'ACTIVE',
    program_phase VARCHAR(50),
    security_classification VARCHAR(30) DEFAULT 'UNCLASSIFIED',
    start_date DATE NOT NULL,
    planned_end_date DATE,
    actual_end_date DATE,
    total_contract_value NUMBER(18,2) NOT NULL,
    funded_value NUMBER(18,2) DEFAULT 0.00,
    costs_incurred NUMBER(18,2) DEFAULT 0.00,
    revenue_recognized NUMBER(18,2) DEFAULT 0.00,
    margin_percentage NUMBER(5,2),
    program_manager VARCHAR(200),
    technical_lead VARCHAR(200),
    risk_level VARCHAR(20) DEFAULT 'MEDIUM',
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (division_id) REFERENCES DIVISIONS(division_id),
    FOREIGN KEY (customer_id) REFERENCES CUSTOMERS(customer_id)
);

-- ============================================================================
-- CONTRACTS TABLE - Contract Details
-- ============================================================================
CREATE OR REPLACE TABLE CONTRACTS (
    contract_id VARCHAR(30) PRIMARY KEY,
    program_id VARCHAR(30) NOT NULL,
    customer_id VARCHAR(30) NOT NULL,
    contract_number VARCHAR(50) NOT NULL,
    contract_name VARCHAR(300) NOT NULL,
    contract_type VARCHAR(50) NOT NULL,
    contract_vehicle VARCHAR(100),
    award_date DATE NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    period_of_performance_months NUMBER(4,0),
    base_value NUMBER(18,2) NOT NULL,
    option_value NUMBER(18,2) DEFAULT 0.00,
    total_value NUMBER(18,2) NOT NULL,
    funded_amount NUMBER(18,2) DEFAULT 0.00,
    contract_status VARCHAR(30) DEFAULT 'ACTIVE',
    modification_count NUMBER(4,0) DEFAULT 0,
    security_classification VARCHAR(30) DEFAULT 'UNCLASSIFIED',
    contracting_officer VARCHAR(200),
    contracting_officer_email VARCHAR(200),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (program_id) REFERENCES PROGRAMS(program_id),
    FOREIGN KEY (customer_id) REFERENCES CUSTOMERS(customer_id)
);

-- ============================================================================
-- MILESTONES TABLE - Program Milestones
-- ============================================================================
CREATE OR REPLACE TABLE MILESTONES (
    milestone_id VARCHAR(30) PRIMARY KEY,
    program_id VARCHAR(30) NOT NULL,
    contract_id VARCHAR(30),
    milestone_code VARCHAR(30) NOT NULL,
    milestone_name VARCHAR(300) NOT NULL,
    milestone_type VARCHAR(50) NOT NULL,
    description VARCHAR(2000),
    planned_date DATE NOT NULL,
    actual_date DATE,
    milestone_status VARCHAR(30) DEFAULT 'PENDING',
    deliverable_required BOOLEAN DEFAULT FALSE,
    payment_milestone BOOLEAN DEFAULT FALSE,
    payment_amount NUMBER(15,2),
    completion_percentage NUMBER(5,2) DEFAULT 0.00,
    dependencies VARCHAR(500),
    notes VARCHAR(2000),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (program_id) REFERENCES PROGRAMS(program_id),
    FOREIGN KEY (contract_id) REFERENCES CONTRACTS(contract_id)
);

-- ============================================================================
-- ASSETS TABLE - Unmanned Systems, Equipment, Satellites
-- ============================================================================
CREATE OR REPLACE TABLE ASSETS (
    asset_id VARCHAR(30) PRIMARY KEY,
    division_id VARCHAR(20) NOT NULL,
    program_id VARCHAR(30),
    asset_serial_number VARCHAR(50) NOT NULL,
    asset_name VARCHAR(200) NOT NULL,
    asset_type VARCHAR(50) NOT NULL,
    asset_category VARCHAR(50) NOT NULL,
    asset_model VARCHAR(100),
    manufacturer VARCHAR(200),
    manufacture_date DATE,
    acquisition_date DATE,
    acquisition_cost NUMBER(15,2),
    current_value NUMBER(15,2),
    asset_status VARCHAR(30) DEFAULT 'OPERATIONAL',
    operational_status VARCHAR(30) DEFAULT 'AVAILABLE',
    location VARCHAR(200),
    assigned_customer_id VARCHAR(30),
    total_flight_hours NUMBER(10,2) DEFAULT 0.00,
    total_missions NUMBER(8,0) DEFAULT 0,
    last_maintenance_date DATE,
    next_maintenance_due DATE,
    maintenance_interval_hours NUMBER(6,0),
    software_version VARCHAR(50),
    firmware_version VARCHAR(50),
    security_classification VARCHAR(30) DEFAULT 'UNCLASSIFIED',
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (division_id) REFERENCES DIVISIONS(division_id),
    FOREIGN KEY (program_id) REFERENCES PROGRAMS(program_id),
    FOREIGN KEY (assigned_customer_id) REFERENCES CUSTOMERS(customer_id)
);

-- ============================================================================
-- ASSET_OPERATIONS TABLE - Flight Hours, Missions, Usage
-- ============================================================================
CREATE OR REPLACE TABLE ASSET_OPERATIONS (
    operation_id VARCHAR(30) PRIMARY KEY,
    asset_id VARCHAR(30) NOT NULL,
    program_id VARCHAR(30),
    operation_date DATE NOT NULL,
    operation_type VARCHAR(50) NOT NULL,
    mission_type VARCHAR(50),
    mission_name VARCHAR(200),
    location VARCHAR(200),
    flight_hours NUMBER(6,2) DEFAULT 0.00,
    cycles NUMBER(6,0) DEFAULT 0,
    fuel_consumed NUMBER(10,2),
    altitude_max NUMBER(8,0),
    speed_max NUMBER(6,0),
    distance_traveled NUMBER(10,2),
    operation_status VARCHAR(30) DEFAULT 'COMPLETED',
    pilot_operator VARCHAR(200),
    weather_conditions VARCHAR(100),
    mission_success BOOLEAN DEFAULT TRUE,
    anomalies_detected NUMBER(3,0) DEFAULT 0,
    notes VARCHAR(3000),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (asset_id) REFERENCES ASSETS(asset_id),
    FOREIGN KEY (program_id) REFERENCES PROGRAMS(program_id)
);

-- ============================================================================
-- MAINTENANCE_RECORDS TABLE - Service and Repair History
-- ============================================================================
CREATE OR REPLACE TABLE MAINTENANCE_RECORDS (
    maintenance_id VARCHAR(30) PRIMARY KEY,
    asset_id VARCHAR(30) NOT NULL,
    maintenance_date DATE NOT NULL,
    maintenance_type VARCHAR(50) NOT NULL,
    maintenance_category VARCHAR(50),
    work_order_number VARCHAR(30),
    description VARCHAR(3000) NOT NULL,
    parts_replaced VARCHAR(2000),
    labor_hours NUMBER(6,2) DEFAULT 0.00,
    parts_cost NUMBER(12,2) DEFAULT 0.00,
    labor_cost NUMBER(12,2) DEFAULT 0.00,
    total_cost NUMBER(12,2) DEFAULT 0.00,
    technician_name VARCHAR(200),
    technician_certification VARCHAR(100),
    maintenance_status VARCHAR(30) DEFAULT 'COMPLETED',
    flight_hours_at_maintenance NUMBER(10,2),
    next_maintenance_hours NUMBER(10,2),
    quality_inspection_passed BOOLEAN DEFAULT TRUE,
    root_cause VARCHAR(500),
    corrective_action VARCHAR(1000),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (asset_id) REFERENCES ASSETS(asset_id)
);

-- ============================================================================
-- PARTS_INVENTORY TABLE - Spare Parts and Materials
-- ============================================================================
CREATE OR REPLACE TABLE PARTS_INVENTORY (
    part_id VARCHAR(30) PRIMARY KEY,
    division_id VARCHAR(20) NOT NULL,
    part_number VARCHAR(50) NOT NULL,
    part_name VARCHAR(300) NOT NULL,
    part_category VARCHAR(50) NOT NULL,
    part_type VARCHAR(50),
    manufacturer VARCHAR(200),
    unit_cost NUMBER(12,2) NOT NULL,
    quantity_on_hand NUMBER(8,0) DEFAULT 0,
    quantity_reserved NUMBER(8,0) DEFAULT 0,
    quantity_available NUMBER(8,0) DEFAULT 0,
    reorder_point NUMBER(8,0) DEFAULT 0,
    reorder_quantity NUMBER(8,0) DEFAULT 0,
    lead_time_days NUMBER(4,0) DEFAULT 0,
    storage_location VARCHAR(100),
    shelf_life_days NUMBER(5,0),
    is_critical BOOLEAN DEFAULT FALSE,
    is_hazardous BOOLEAN DEFAULT FALSE,
    export_controlled BOOLEAN DEFAULT FALSE,
    last_receipt_date DATE,
    last_issue_date DATE,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (division_id) REFERENCES DIVISIONS(division_id)
);

-- ============================================================================
-- MANUFACTURING_ORDERS TABLE - Production Tracking
-- ============================================================================
CREATE OR REPLACE TABLE MANUFACTURING_ORDERS (
    order_id VARCHAR(30) PRIMARY KEY,
    division_id VARCHAR(20) NOT NULL,
    program_id VARCHAR(30),
    contract_id VARCHAR(30),
    order_number VARCHAR(30) NOT NULL,
    order_type VARCHAR(50) NOT NULL,
    product_name VARCHAR(300) NOT NULL,
    product_type VARCHAR(50) NOT NULL,
    quantity_ordered NUMBER(6,0) NOT NULL,
    quantity_completed NUMBER(6,0) DEFAULT 0,
    quantity_scrapped NUMBER(6,0) DEFAULT 0,
    unit_cost NUMBER(12,2),
    total_cost NUMBER(15,2),
    order_date DATE NOT NULL,
    required_date DATE,
    start_date DATE,
    completion_date DATE,
    order_status VARCHAR(30) DEFAULT 'PENDING',
    priority VARCHAR(20) DEFAULT 'NORMAL',
    production_line VARCHAR(100),
    shift VARCHAR(20),
    notes VARCHAR(2000),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (division_id) REFERENCES DIVISIONS(division_id),
    FOREIGN KEY (program_id) REFERENCES PROGRAMS(program_id),
    FOREIGN KEY (contract_id) REFERENCES CONTRACTS(contract_id)
);

-- ============================================================================
-- QUALITY_INSPECTIONS TABLE - QC Results
-- ============================================================================
CREATE OR REPLACE TABLE QUALITY_INSPECTIONS (
    inspection_id VARCHAR(30) PRIMARY KEY,
    order_id VARCHAR(30),
    asset_id VARCHAR(30),
    inspection_date DATE NOT NULL,
    inspection_type VARCHAR(50) NOT NULL,
    inspection_category VARCHAR(50),
    inspector_name VARCHAR(200) NOT NULL,
    inspector_certification VARCHAR(100),
    inspection_criteria VARCHAR(2000),
    inspection_result VARCHAR(30) NOT NULL,
    defects_found NUMBER(4,0) DEFAULT 0,
    defect_description VARCHAR(2000),
    corrective_action_required BOOLEAN DEFAULT FALSE,
    corrective_action_taken VARCHAR(2000),
    retest_required BOOLEAN DEFAULT FALSE,
    retest_date DATE,
    retest_result VARCHAR(30),
    quality_score NUMBER(5,2),
    notes VARCHAR(2000),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (order_id) REFERENCES MANUFACTURING_ORDERS(order_id),
    FOREIGN KEY (asset_id) REFERENCES ASSETS(asset_id)
);

-- ============================================================================
-- ENGINEERING_PROJECTS TABLE - R&D and Development
-- ============================================================================
CREATE OR REPLACE TABLE ENGINEERING_PROJECTS (
    project_id VARCHAR(30) PRIMARY KEY,
    division_id VARCHAR(20) NOT NULL,
    program_id VARCHAR(30),
    project_code VARCHAR(30) NOT NULL,
    project_name VARCHAR(300) NOT NULL,
    project_type VARCHAR(50) NOT NULL,
    project_category VARCHAR(50),
    description VARCHAR(3000),
    project_status VARCHAR(30) DEFAULT 'ACTIVE',
    project_phase VARCHAR(50),
    technology_readiness_level NUMBER(2,0),
    start_date DATE NOT NULL,
    planned_end_date DATE,
    actual_end_date DATE,
    budget NUMBER(15,2),
    actual_cost NUMBER(15,2) DEFAULT 0.00,
    project_manager VARCHAR(200),
    lead_engineer VARCHAR(200),
    team_size NUMBER(4,0) DEFAULT 0,
    ip_generated BOOLEAN DEFAULT FALSE,
    patents_filed NUMBER(3,0) DEFAULT 0,
    risk_level VARCHAR(20) DEFAULT 'MEDIUM',
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (division_id) REFERENCES DIVISIONS(division_id),
    FOREIGN KEY (program_id) REFERENCES PROGRAMS(program_id)
);

-- ============================================================================
-- TEST_EVENTS TABLE - Test Flights and Evaluations
-- ============================================================================
CREATE OR REPLACE TABLE TEST_EVENTS (
    test_id VARCHAR(30) PRIMARY KEY,
    project_id VARCHAR(30),
    asset_id VARCHAR(30),
    program_id VARCHAR(30),
    test_number VARCHAR(30) NOT NULL,
    test_name VARCHAR(300) NOT NULL,
    test_type VARCHAR(50) NOT NULL,
    test_category VARCHAR(50),
    test_date DATE NOT NULL,
    test_location VARCHAR(200),
    test_duration_hours NUMBER(6,2),
    test_objective VARCHAR(2000),
    test_procedure VARCHAR(3000),
    test_status VARCHAR(30) DEFAULT 'COMPLETED',
    test_result VARCHAR(30),
    success_criteria_met BOOLEAN,
    anomalies_count NUMBER(4,0) DEFAULT 0,
    data_collected_gb NUMBER(8,2),
    test_conductor VARCHAR(200),
    witness VARCHAR(200),
    customer_witnessed BOOLEAN DEFAULT FALSE,
    notes VARCHAR(3000),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (project_id) REFERENCES ENGINEERING_PROJECTS(project_id),
    FOREIGN KEY (asset_id) REFERENCES ASSETS(asset_id),
    FOREIGN KEY (program_id) REFERENCES PROGRAMS(program_id)
);

-- ============================================================================
-- EMPLOYEES TABLE - Cleared Personnel
-- ============================================================================
CREATE OR REPLACE TABLE EMPLOYEES (
    employee_id VARCHAR(30) PRIMARY KEY,
    division_id VARCHAR(20) NOT NULL,
    employee_number VARCHAR(20) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(200),
    phone VARCHAR(30),
    job_title VARCHAR(200) NOT NULL,
    department VARCHAR(100),
    employee_type VARCHAR(30) DEFAULT 'FULL_TIME',
    security_clearance VARCHAR(30),
    clearance_expiry_date DATE,
    hire_date DATE NOT NULL,
    termination_date DATE,
    employee_status VARCHAR(30) DEFAULT 'ACTIVE',
    manager_id VARCHAR(30),
    labor_category VARCHAR(50),
    hourly_rate NUMBER(10,2),
    annual_salary NUMBER(12,2),
    certifications VARCHAR(1000),
    skills VARCHAR(2000),
    location VARCHAR(200),
    remote_eligible BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (division_id) REFERENCES DIVISIONS(division_id)
);

-- ============================================================================
-- INCIDENTS TABLE - Safety and Anomaly Reports
-- ============================================================================
CREATE OR REPLACE TABLE INCIDENTS (
    incident_id VARCHAR(30) PRIMARY KEY,
    asset_id VARCHAR(30),
    program_id VARCHAR(30),
    division_id VARCHAR(20) NOT NULL,
    incident_number VARCHAR(30) NOT NULL,
    incident_date TIMESTAMP_NTZ NOT NULL,
    incident_type VARCHAR(50) NOT NULL,
    incident_category VARCHAR(50),
    severity VARCHAR(20) NOT NULL,
    location VARCHAR(200),
    description VARCHAR(5000) NOT NULL,
    root_cause VARCHAR(2000),
    immediate_action VARCHAR(2000),
    corrective_action VARCHAR(2000),
    preventive_action VARCHAR(2000),
    incident_status VARCHAR(30) DEFAULT 'OPEN',
    investigation_status VARCHAR(30) DEFAULT 'PENDING',
    reported_by VARCHAR(200),
    assigned_to VARCHAR(200),
    resolution_date DATE,
    cost_impact NUMBER(15,2),
    schedule_impact_days NUMBER(4,0),
    customer_notified BOOLEAN DEFAULT FALSE,
    lessons_learned VARCHAR(3000),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (asset_id) REFERENCES ASSETS(asset_id),
    FOREIGN KEY (program_id) REFERENCES PROGRAMS(program_id),
    FOREIGN KEY (division_id) REFERENCES DIVISIONS(division_id)
);

-- ============================================================================
-- SUPPLIERS TABLE - Vendor and Supplier Information
-- ============================================================================
CREATE OR REPLACE TABLE SUPPLIERS (
    supplier_id VARCHAR(30) PRIMARY KEY,
    supplier_code VARCHAR(20) NOT NULL,
    supplier_name VARCHAR(300) NOT NULL,
    supplier_type VARCHAR(50) NOT NULL,
    supplier_category VARCHAR(50),
    address VARCHAR(500),
    city VARCHAR(100),
    state VARCHAR(50),
    country VARCHAR(50) DEFAULT 'USA',
    primary_contact VARCHAR(200),
    contact_email VARCHAR(200),
    contact_phone VARCHAR(30),
    payment_terms VARCHAR(50),
    quality_rating NUMBER(3,2),
    delivery_rating NUMBER(3,2),
    is_approved BOOLEAN DEFAULT TRUE,
    is_small_business BOOLEAN DEFAULT FALSE,
    is_woman_owned BOOLEAN DEFAULT FALSE,
    is_veteran_owned BOOLEAN DEFAULT FALSE,
    cage_code VARCHAR(10),
    duns_number VARCHAR(15),
    supplier_status VARCHAR(30) DEFAULT 'ACTIVE',
    first_order_date DATE,
    total_spend NUMBER(18,2) DEFAULT 0.00,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- PURCHASE_ORDERS TABLE - Procurement
-- ============================================================================
CREATE OR REPLACE TABLE PURCHASE_ORDERS (
    po_id VARCHAR(30) PRIMARY KEY,
    supplier_id VARCHAR(30) NOT NULL,
    program_id VARCHAR(30),
    division_id VARCHAR(20) NOT NULL,
    po_number VARCHAR(30) NOT NULL,
    po_date DATE NOT NULL,
    required_date DATE,
    po_type VARCHAR(50) NOT NULL,
    po_status VARCHAR(30) DEFAULT 'OPEN',
    subtotal NUMBER(15,2) NOT NULL,
    tax_amount NUMBER(12,2) DEFAULT 0.00,
    shipping_amount NUMBER(10,2) DEFAULT 0.00,
    total_amount NUMBER(15,2) NOT NULL,
    payment_terms VARCHAR(50),
    shipping_method VARCHAR(100),
    ship_to_location VARCHAR(200),
    buyer VARCHAR(200),
    approved_by VARCHAR(200),
    approval_date DATE,
    receipt_date DATE,
    invoice_number VARCHAR(50),
    invoice_date DATE,
    notes VARCHAR(2000),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (supplier_id) REFERENCES SUPPLIERS(supplier_id),
    FOREIGN KEY (program_id) REFERENCES PROGRAMS(program_id),
    FOREIGN KEY (division_id) REFERENCES DIVISIONS(division_id)
);

-- ============================================================================
-- Display confirmation
-- ============================================================================
SELECT 'All tables created successfully' AS status;

-- Show all tables
SHOW TABLES IN SCHEMA KRATOS_INTELLIGENCE.RAW;


