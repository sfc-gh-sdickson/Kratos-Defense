-- ============================================================================
-- Kratos Defense Intelligence Agent - Table Definitions
-- ============================================================================
-- Purpose: Create all necessary tables for defense contractor business model
-- All columns verified against Kratos Defense business requirements
-- Syntax: Verified against Snowflake SQL Reference
-- ============================================================================

USE DATABASE KRATOS_INTELLIGENCE;
USE SCHEMA RAW;
USE WAREHOUSE KRATOS_WH;

-- ============================================================================
-- DIVISIONS TABLE (Business Divisions)
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
-- EMPLOYEES TABLE
-- ============================================================================
CREATE OR REPLACE TABLE EMPLOYEES (
    employee_id VARCHAR(30) PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(200) NOT NULL,
    phone VARCHAR(30),
    hire_date DATE,
    job_title VARCHAR(100),
    department VARCHAR(100),
    division_id VARCHAR(20),
    manager_id VARCHAR(30),
    employee_level VARCHAR(30) DEFAULT 'INDIVIDUAL_CONTRIBUTOR',
    security_clearance VARCHAR(50),
    clearance_expiry_date DATE,
    years_experience NUMBER(3,0) DEFAULT 0,
    education_level VARCHAR(50),
    certifications VARCHAR(500),
    employee_status VARCHAR(30) DEFAULT 'ACTIVE',
    location VARCHAR(100),
    is_remote BOOLEAN DEFAULT FALSE,
    annual_salary NUMBER(12,2),
    billable_rate NUMBER(10,2),
    utilization_target NUMBER(5,2) DEFAULT 80.00,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (division_id) REFERENCES DIVISIONS(division_id)
);

-- ============================================================================
-- PROGRAMS TABLE (Defense Programs/Projects)
-- ============================================================================
CREATE OR REPLACE TABLE PROGRAMS (
    program_id VARCHAR(30) PRIMARY KEY,
    program_code VARCHAR(20) NOT NULL,
    program_name VARCHAR(300) NOT NULL,
    program_type VARCHAR(50) NOT NULL,
    program_status VARCHAR(30) DEFAULT 'ACTIVE',
    division_id VARCHAR(20),
    program_manager_id VARCHAR(30),
    customer VARCHAR(100),
    prime_contractor VARCHAR(100),
    start_date DATE NOT NULL,
    end_date DATE,
    budget_amount NUMBER(15,2) NOT NULL,
    spent_amount NUMBER(15,2) DEFAULT 0.00,
    budget_variance NUMBER(15,2) DEFAULT 0.00,
    schedule_variance_days NUMBER(6,0) DEFAULT 0,
    risk_level VARCHAR(20) DEFAULT 'MEDIUM',
    priority_level VARCHAR(20) DEFAULT 'STANDARD',
    classification_level VARCHAR(30),
    contract_type VARCHAR(50),
    milestone_count NUMBER(4,0) DEFAULT 0,
    milestones_completed NUMBER(4,0) DEFAULT 0,
    percent_complete NUMBER(5,2) DEFAULT 0.00,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (division_id) REFERENCES DIVISIONS(division_id),
    FOREIGN KEY (program_manager_id) REFERENCES EMPLOYEES(employee_id)
);

-- ============================================================================
-- CONTRACTS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE CONTRACTS (
    contract_id VARCHAR(30) PRIMARY KEY,
    contract_number VARCHAR(50) NOT NULL,
    contract_name VARCHAR(300) NOT NULL,
    program_id VARCHAR(30),
    contract_type VARCHAR(50) NOT NULL,
    contract_status VARCHAR(30) DEFAULT 'ACTIVE',
    customer VARCHAR(100),
    contracting_officer VARCHAR(100),
    award_date DATE NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    base_value NUMBER(15,2) NOT NULL,
    ceiling_value NUMBER(15,2),
    funded_value NUMBER(15,2) DEFAULT 0.00,
    billed_amount NUMBER(15,2) DEFAULT 0.00,
    payment_terms VARCHAR(50),
    naics_code VARCHAR(10),
    set_aside_type VARCHAR(50),
    competition_type VARCHAR(50),
    is_classified BOOLEAN DEFAULT FALSE,
    security_level VARCHAR(30),
    performance_rating NUMBER(3,2),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (program_id) REFERENCES PROGRAMS(program_id)
);

-- ============================================================================
-- ASSETS TABLE (Defense Assets/Equipment)
-- ============================================================================
CREATE OR REPLACE TABLE ASSETS (
    asset_id VARCHAR(30) PRIMARY KEY,
    asset_tag VARCHAR(50) NOT NULL,
    asset_name VARCHAR(300) NOT NULL,
    asset_type VARCHAR(50) NOT NULL,
    asset_category VARCHAR(50),
    asset_status VARCHAR(30) DEFAULT 'OPERATIONAL',
    serial_number VARCHAR(100),
    manufacturer VARCHAR(100),
    model VARCHAR(100),
    acquisition_date DATE,
    acquisition_cost NUMBER(15,2),
    current_value NUMBER(15,2),
    depreciation_rate NUMBER(5,2),
    program_id VARCHAR(30),
    assigned_location VARCHAR(200),
    responsible_employee_id VARCHAR(30),
    warranty_expiry_date DATE,
    last_maintenance_date DATE,
    next_maintenance_due DATE,
    maintenance_interval_hours NUMBER(8,0) DEFAULT 250,
    total_flight_hours NUMBER(10,2) DEFAULT 0.00,
    mission_ready BOOLEAN DEFAULT TRUE,
    condition_rating VARCHAR(20) DEFAULT 'GOOD',
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (program_id) REFERENCES PROGRAMS(program_id),
    FOREIGN KEY (responsible_employee_id) REFERENCES EMPLOYEES(employee_id)
);

-- ============================================================================
-- SUPPLIERS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE SUPPLIERS (
    supplier_id VARCHAR(30) PRIMARY KEY,
    supplier_code VARCHAR(20) NOT NULL,
    supplier_name VARCHAR(300) NOT NULL,
    supplier_type VARCHAR(50) NOT NULL,
    supplier_status VARCHAR(30) DEFAULT 'ACTIVE',
    cage_code VARCHAR(10),
    duns_number VARCHAR(20),
    address_line1 VARCHAR(200),
    address_line2 VARCHAR(200),
    city VARCHAR(100),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    country VARCHAR(50) DEFAULT 'USA',
    primary_contact VARCHAR(100),
    contact_email VARCHAR(200),
    contact_phone VARCHAR(30),
    payment_terms NUMBER(4,0) DEFAULT 30,
    credit_limit NUMBER(15,2),
    risk_rating VARCHAR(20) DEFAULT 'LOW',
    quality_rating NUMBER(3,2),
    delivery_rating NUMBER(3,2),
    is_small_business BOOLEAN DEFAULT FALSE,
    is_woman_owned BOOLEAN DEFAULT FALSE,
    is_veteran_owned BOOLEAN DEFAULT FALSE,
    is_minority_owned BOOLEAN DEFAULT FALSE,
    total_orders NUMBER(8,0) DEFAULT 0,
    total_spend NUMBER(15,2) DEFAULT 0.00,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- PURCHASE_ORDERS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE PURCHASE_ORDERS (
    po_id VARCHAR(30) PRIMARY KEY,
    po_number VARCHAR(50) NOT NULL,
    supplier_id VARCHAR(30) NOT NULL,
    program_id VARCHAR(30),
    contract_id VARCHAR(30),
    po_date DATE NOT NULL,
    po_status VARCHAR(30) DEFAULT 'OPEN',
    subtotal NUMBER(15,2) NOT NULL,
    tax_amount NUMBER(12,2) DEFAULT 0.00,
    shipping_amount NUMBER(10,2) DEFAULT 0.00,
    total_amount NUMBER(15,2) NOT NULL,
    paid_amount NUMBER(15,2) DEFAULT 0.00,
    payment_status VARCHAR(30) DEFAULT 'UNPAID',
    due_date DATE,
    ship_to_location VARCHAR(200),
    requested_by VARCHAR(30),
    approved_by VARCHAR(30),
    approval_date DATE,
    notes VARCHAR(2000),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (supplier_id) REFERENCES SUPPLIERS(supplier_id),
    FOREIGN KEY (program_id) REFERENCES PROGRAMS(program_id),
    FOREIGN KEY (contract_id) REFERENCES CONTRACTS(contract_id)
);

-- ============================================================================
-- PO_LINE_ITEMS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE PO_LINE_ITEMS (
    line_item_id VARCHAR(30) PRIMARY KEY,
    po_id VARCHAR(30) NOT NULL,
    line_number NUMBER(4,0) NOT NULL,
    part_number VARCHAR(100),
    description VARCHAR(500) NOT NULL,
    quantity NUMBER(10,2) NOT NULL,
    unit_of_measure VARCHAR(20),
    unit_price NUMBER(12,2) NOT NULL,
    extended_price NUMBER(15,2) NOT NULL,
    received_quantity NUMBER(10,2) DEFAULT 0.00,
    receive_status VARCHAR(30) DEFAULT 'PENDING',
    delivery_date DATE,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (po_id) REFERENCES PURCHASE_ORDERS(po_id)
);

-- ============================================================================
-- MAINTENANCE_RECORDS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE MAINTENANCE_RECORDS (
    maintenance_id VARCHAR(30) PRIMARY KEY,
    asset_id VARCHAR(30) NOT NULL,
    maintenance_type VARCHAR(50) NOT NULL,
    maintenance_category VARCHAR(50),
    maintenance_status VARCHAR(30) DEFAULT 'OPEN',
    scheduled_date DATE,
    start_date DATE,
    completion_date DATE,
    priority VARCHAR(20) DEFAULT 'MEDIUM',
    description VARCHAR(2000),
    findings VARCHAR(3000),
    actions_taken VARCHAR(3000),
    parts_replaced VARCHAR(1000),
    labor_hours NUMBER(8,2) DEFAULT 0.00,
    parts_cost NUMBER(12,2) DEFAULT 0.00,
    labor_cost NUMBER(12,2) DEFAULT 0.00,
    total_cost NUMBER(12,2) DEFAULT 0.00,
    technician_id VARCHAR(30),
    work_order_number VARCHAR(50),
    is_unscheduled BOOLEAN DEFAULT FALSE,
    downtime_hours NUMBER(8,2) DEFAULT 0.00,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (asset_id) REFERENCES ASSETS(asset_id),
    FOREIGN KEY (technician_id) REFERENCES EMPLOYEES(employee_id)
);

-- ============================================================================
-- ENGINEERS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE ENGINEERS (
    engineer_id VARCHAR(30) PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(200),
    specialty VARCHAR(200),
    credentials VARCHAR(500),
    security_clearance VARCHAR(50),
    years_experience NUMBER(3,0) DEFAULT 0,
    division_id VARCHAR(20),
    engineer_level VARCHAR(30) DEFAULT 'ENGINEER',
    billable_rate NUMBER(10,2),
    utilization_rate NUMBER(5,2),
    active_projects NUMBER(4,0) DEFAULT 0,
    engineer_status VARCHAR(30) DEFAULT 'ACTIVE',
    hire_date DATE,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (division_id) REFERENCES DIVISIONS(division_id)
);

-- ============================================================================
-- WORK_ORDERS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE WORK_ORDERS (
    work_order_id VARCHAR(30) PRIMARY KEY,
    work_order_number VARCHAR(50) NOT NULL,
    program_id VARCHAR(30),
    contract_id VARCHAR(30),
    work_order_type VARCHAR(50) NOT NULL,
    work_order_status VARCHAR(30) DEFAULT 'OPEN',
    priority VARCHAR(20) DEFAULT 'MEDIUM',
    title VARCHAR(300) NOT NULL,
    description VARCHAR(3000),
    requested_by VARCHAR(30),
    assigned_to VARCHAR(30),
    start_date DATE,
    due_date DATE,
    completion_date DATE,
    estimated_hours NUMBER(8,2),
    actual_hours NUMBER(8,2) DEFAULT 0.00,
    estimated_cost NUMBER(12,2),
    actual_cost NUMBER(12,2) DEFAULT 0.00,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (program_id) REFERENCES PROGRAMS(program_id),
    FOREIGN KEY (contract_id) REFERENCES CONTRACTS(contract_id)
);

-- ============================================================================
-- QUALITY_INSPECTIONS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE QUALITY_INSPECTIONS (
    inspection_id VARCHAR(30) PRIMARY KEY,
    asset_id VARCHAR(30),
    program_id VARCHAR(30),
    contract_id VARCHAR(30),
    inspection_type VARCHAR(50) NOT NULL,
    inspection_date DATE NOT NULL,
    inspector_id VARCHAR(30),
    inspection_status VARCHAR(30) DEFAULT 'COMPLETED',
    overall_rating NUMBER(3,2),
    compliance_score NUMBER(5,2),
    quality_score NUMBER(5,2),
    safety_score NUMBER(5,2),
    findings_count NUMBER(4,0) DEFAULT 0,
    critical_findings NUMBER(4,0) DEFAULT 0,
    findings_description VARCHAR(5000),
    recommendations VARCHAR(3000),
    corrective_actions VARCHAR(3000),
    next_inspection_date DATE,
    passed BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (asset_id) REFERENCES ASSETS(asset_id),
    FOREIGN KEY (program_id) REFERENCES PROGRAMS(program_id),
    FOREIGN KEY (contract_id) REFERENCES CONTRACTS(contract_id),
    FOREIGN KEY (inspector_id) REFERENCES EMPLOYEES(employee_id)
);

-- ============================================================================
-- PROPOSALS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE PROPOSALS (
    proposal_id VARCHAR(30) PRIMARY KEY,
    proposal_number VARCHAR(50) NOT NULL,
    proposal_name VARCHAR(300) NOT NULL,
    solicitation_number VARCHAR(50),
    proposal_type VARCHAR(50) NOT NULL,
    proposal_status VARCHAR(30) DEFAULT 'IN_PROGRESS',
    division_id VARCHAR(20),
    proposal_manager_id VARCHAR(30),
    customer VARCHAR(100),
    opportunity_value NUMBER(15,2),
    proposed_value NUMBER(15,2),
    win_probability NUMBER(5,2) DEFAULT 50.00,
    submission_date DATE,
    due_date DATE,
    decision_date DATE,
    result VARCHAR(30),
    contract_id VARCHAR(30),
    competitors VARCHAR(500),
    key_discriminators VARCHAR(2000),
    risk_factors VARCHAR(2000),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (division_id) REFERENCES DIVISIONS(division_id),
    FOREIGN KEY (proposal_manager_id) REFERENCES EMPLOYEES(employee_id)
);

-- ============================================================================
-- PROPOSAL_ACTIVITIES TABLE
-- ============================================================================
CREATE OR REPLACE TABLE PROPOSAL_ACTIVITIES (
    activity_id VARCHAR(30) PRIMARY KEY,
    proposal_id VARCHAR(30) NOT NULL,
    activity_type VARCHAR(50) NOT NULL,
    activity_date TIMESTAMP_NTZ NOT NULL,
    activity_description VARCHAR(1000),
    performed_by VARCHAR(30),
    outcome VARCHAR(100),
    next_steps VARCHAR(500),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (proposal_id) REFERENCES PROPOSALS(proposal_id)
);

-- ============================================================================
-- SERVICE_AGREEMENTS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE SERVICE_AGREEMENTS (
    agreement_id VARCHAR(30) PRIMARY KEY,
    agreement_number VARCHAR(50) NOT NULL,
    agreement_name VARCHAR(300) NOT NULL,
    agreement_type VARCHAR(50) NOT NULL,
    customer VARCHAR(100),
    program_id VARCHAR(30),
    start_date DATE NOT NULL,
    end_date DATE,
    renewal_date DATE,
    agreement_status VARCHAR(30) DEFAULT 'ACTIVE',
    annual_value NUMBER(15,2) NOT NULL,
    total_value NUMBER(15,2),
    billing_frequency VARCHAR(20) DEFAULT 'MONTHLY',
    payment_terms NUMBER(4,0) DEFAULT 30,
    auto_renew BOOLEAN DEFAULT FALSE,
    sla_target NUMBER(5,2) DEFAULT 99.00,
    actual_sla NUMBER(5,2),
    cancellation_notice_days NUMBER(4,0) DEFAULT 90,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (program_id) REFERENCES PROGRAMS(program_id)
);

-- ============================================================================
-- MILESTONES TABLE
-- ============================================================================
CREATE OR REPLACE TABLE MILESTONES (
    milestone_id VARCHAR(30) PRIMARY KEY,
    program_id VARCHAR(30) NOT NULL,
    contract_id VARCHAR(30),
    milestone_name VARCHAR(200) NOT NULL,
    milestone_type VARCHAR(50),
    milestone_status VARCHAR(30) DEFAULT 'PENDING',
    planned_date DATE NOT NULL,
    actual_date DATE,
    baseline_date DATE,
    schedule_variance_days NUMBER(6,0) DEFAULT 0,
    deliverable VARCHAR(500),
    acceptance_criteria VARCHAR(2000),
    payment_amount NUMBER(15,2),
    is_critical BOOLEAN DEFAULT FALSE,
    predecessor_id VARCHAR(30),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (program_id) REFERENCES PROGRAMS(program_id),
    FOREIGN KEY (contract_id) REFERENCES CONTRACTS(contract_id)
);

-- ============================================================================
-- Display confirmation
-- ============================================================================
SELECT 'All tables created successfully' AS status;

