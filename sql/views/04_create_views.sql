-- ============================================================================
-- Kratos Defense Intelligence Agent - Analytical Views
-- ============================================================================
-- VERIFIED: All column references match 02_create_tables.sql exactly
-- ============================================================================

USE DATABASE KRATOS_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE KRATOS_WH;

-- ============================================================================
-- View 1: Program Dashboard
-- VERIFIED COLUMNS FROM TABLES:
--   PROGRAMS: program_id, division_id, program_code, program_name, program_type,
--             program_status, security_classification, customer_id, program_manager,
--             start_date, planned_end_date, total_contract_value, funded_value,
--             costs_incurred, revenue_recognized, margin_percentage, risk_level
--   DIVISIONS: division_id, division_code, division_name
--   CUSTOMERS: customer_id, customer_name, customer_type
-- ============================================================================
CREATE OR REPLACE VIEW V_PROGRAM_DASHBOARD AS
SELECT
    p.program_id,
    p.program_code,
    p.program_name,
    p.program_type,
    p.program_status,
    p.security_classification,
    p.program_manager,
    p.start_date,
    p.planned_end_date,
    p.total_contract_value,
    p.funded_value,
    p.costs_incurred,
    p.revenue_recognized,
    p.margin_percentage,
    p.risk_level,
    d.division_id,
    d.division_code,
    d.division_name,
    c.customer_id,
    c.customer_name,
    c.customer_type,
    DATEDIFF('day', p.start_date, COALESCE(p.planned_end_date, CURRENT_DATE())) AS program_duration_days,
    CASE 
        WHEN p.costs_incurred > p.funded_value THEN 'OVER_BUDGET'
        WHEN p.costs_incurred < p.funded_value * 0.5 THEN 'UNDER_SPEND'
        ELSE 'ON_TRACK'
    END AS budget_status
FROM RAW.PROGRAMS p
JOIN RAW.DIVISIONS d ON p.division_id = d.division_id
LEFT JOIN RAW.CUSTOMERS c ON p.customer_id = c.customer_id;

-- ============================================================================
-- View 2: Contract Performance
-- VERIFIED COLUMNS FROM TABLES:
--   CONTRACTS: contract_id, program_id, contract_number, contract_name, contract_type,
--              contract_status, award_date, start_date, end_date, base_value,
--              option_value, total_value, funded_amount, modification_count
--   PROGRAMS: program_id, program_code, program_name
-- ============================================================================
CREATE OR REPLACE VIEW V_CONTRACT_PERFORMANCE AS
SELECT
    c.contract_id,
    c.contract_number,
    c.contract_name,
    c.contract_type,
    c.contract_status,
    c.award_date,
    c.start_date,
    c.end_date,
    c.base_value,
    c.option_value,
    c.total_value,
    c.funded_amount,
    c.modification_count,
    p.program_id,
    p.program_code,
    p.program_name,
    (c.funded_amount / NULLIF(c.total_value, 0) * 100)::NUMBER(8,2) AS funding_pct,
    DATEDIFF('day', c.start_date, COALESCE(c.end_date, CURRENT_DATE())) AS contract_duration_days,
    DATEDIFF('day', CURRENT_DATE(), c.end_date) AS days_to_end
FROM RAW.CONTRACTS c
JOIN RAW.PROGRAMS p ON c.program_id = p.program_id;

-- ============================================================================
-- View 3: Asset Fleet Status
-- VERIFIED COLUMNS FROM TABLES:
--   ASSETS: asset_id, division_id, asset_serial_number, asset_name, asset_type,
--           asset_category, asset_model, asset_status, operational_status, location,
--           total_flight_hours, total_missions, acquisition_cost, current_value,
--           last_maintenance_date, next_maintenance_due
--   DIVISIONS: division_id, division_code, division_name
-- ============================================================================
CREATE OR REPLACE VIEW V_ASSET_FLEET_STATUS AS
SELECT
    a.asset_id,
    a.asset_serial_number,
    a.asset_name,
    a.asset_type,
    a.asset_category,
    a.asset_model,
    a.asset_status,
    a.operational_status,
    a.location,
    a.total_flight_hours,
    a.total_missions,
    a.acquisition_cost,
    a.current_value,
    a.last_maintenance_date,
    a.next_maintenance_due,
    d.division_id,
    d.division_code,
    d.division_name,
    CASE 
        WHEN a.next_maintenance_due < CURRENT_DATE() THEN 'OVERDUE'
        WHEN a.next_maintenance_due <= DATEADD('day', 30, CURRENT_DATE()) THEN 'DUE_SOON'
        ELSE 'OK'
    END AS maintenance_status
FROM RAW.ASSETS a
JOIN RAW.DIVISIONS d ON a.division_id = d.division_id;

-- ============================================================================
-- View 4: Manufacturing Metrics
-- VERIFIED COLUMNS FROM TABLES:
--   MANUFACTURING_ORDERS: order_id, division_id, program_id, order_number,
--                         order_type, product_name, product_type, order_status,
--                         quantity_ordered, quantity_completed, quantity_scrapped,
--                         unit_cost, total_cost, order_date, required_date,
--                         start_date, completion_date, priority
--   PROGRAMS: program_id, program_code, program_name
-- ============================================================================
CREATE OR REPLACE VIEW V_MANUFACTURING_METRICS AS
SELECT
    m.order_id,
    m.order_number,
    m.order_type,
    m.product_name,
    m.product_type,
    m.order_status,
    m.quantity_ordered,
    m.quantity_completed,
    m.quantity_scrapped,
    m.unit_cost,
    m.total_cost,
    m.order_date,
    m.required_date,
    m.start_date,
    m.completion_date,
    m.priority,
    p.program_id,
    p.program_code,
    p.program_name,
    (m.quantity_completed::FLOAT / NULLIF(m.quantity_ordered, 0) * 100)::NUMBER(8,2) AS completion_pct,
    CASE 
        WHEN m.completion_date IS NOT NULL AND m.completion_date <= m.required_date THEN 'ON_TIME'
        WHEN m.completion_date IS NOT NULL AND m.completion_date > m.required_date THEN 'LATE'
        WHEN m.required_date < CURRENT_DATE() AND m.completion_date IS NULL THEN 'OVERDUE'
        ELSE 'IN_PROGRESS'
    END AS schedule_status
FROM RAW.MANUFACTURING_ORDERS m
LEFT JOIN RAW.PROGRAMS p ON m.program_id = p.program_id;

-- ============================================================================
-- View 5: Quality Dashboard
-- VERIFIED COLUMNS FROM TABLES:
--   QUALITY_INSPECTIONS: inspection_id, order_id, asset_id, inspection_date,
--                        inspection_type, inspection_category, inspector_name,
--                        inspection_result, defects_found, quality_score,
--                        corrective_action_required
--   MANUFACTURING_ORDERS: order_id, order_number, product_name
-- ============================================================================
CREATE OR REPLACE VIEW V_QUALITY_DASHBOARD AS
SELECT
    q.inspection_id,
    q.inspection_date,
    q.inspection_type,
    q.inspection_category,
    q.inspector_name,
    q.inspection_result,
    q.defects_found,
    q.quality_score,
    q.corrective_action_required,
    m.order_id,
    m.order_number,
    m.product_name,
    CASE 
        WHEN q.inspection_result = 'PASS' THEN 1
        ELSE 0
    END AS passed_flag,
    CASE 
        WHEN q.inspection_result = 'FAIL' THEN 1
        ELSE 0
    END AS failed_flag
FROM RAW.QUALITY_INSPECTIONS q
LEFT JOIN RAW.MANUFACTURING_ORDERS m ON q.order_id = m.order_id;

-- ============================================================================
-- View 6: Maintenance Summary
-- VERIFIED COLUMNS FROM TABLES:
--   MAINTENANCE_RECORDS: maintenance_id, asset_id, maintenance_date, maintenance_type,
--                        maintenance_category, work_order_number, labor_hours,
--                        parts_cost, labor_cost, total_cost, maintenance_status,
--                        technician_name
--   ASSETS: asset_id, asset_serial_number, asset_name, asset_type
-- ============================================================================
CREATE OR REPLACE VIEW V_MAINTENANCE_SUMMARY AS
SELECT
    m.maintenance_id,
    m.maintenance_date,
    m.maintenance_type,
    m.maintenance_category,
    m.work_order_number,
    m.labor_hours,
    m.parts_cost,
    m.labor_cost,
    m.total_cost,
    m.maintenance_status,
    m.technician_name,
    a.asset_id,
    a.asset_serial_number,
    a.asset_name,
    a.asset_type
FROM RAW.MAINTENANCE_RECORDS m
JOIN RAW.ASSETS a ON m.asset_id = a.asset_id;

-- ============================================================================
-- View 7: Engineering Projects
-- VERIFIED COLUMNS FROM TABLES:
--   ENGINEERING_PROJECTS: project_id, division_id, project_code, project_name,
--                         project_type, project_category, project_status,
--                         project_phase, technology_readiness_level, start_date,
--                         planned_end_date, budget, actual_cost, team_size,
--                         risk_level
--   DIVISIONS: division_id, division_code, division_name
-- ============================================================================
CREATE OR REPLACE VIEW V_ENGINEERING_PROJECTS AS
SELECT
    e.project_id,
    e.project_code,
    e.project_name,
    e.project_type,
    e.project_category,
    e.project_status,
    e.project_phase,
    e.technology_readiness_level,
    e.start_date,
    e.planned_end_date,
    e.budget,
    e.actual_cost,
    e.team_size,
    e.risk_level,
    d.division_id,
    d.division_code,
    d.division_name,
    (e.actual_cost / NULLIF(e.budget, 0) * 100)::NUMBER(8,2) AS budget_utilization_pct
FROM RAW.ENGINEERING_PROJECTS e
JOIN RAW.DIVISIONS d ON e.division_id = d.division_id;

-- ============================================================================
-- View 8: Test Results
-- VERIFIED COLUMNS FROM TABLES:
--   TEST_EVENTS: test_id, project_id, asset_id, program_id, test_number, test_name,
--                test_type, test_category, test_date, test_location, test_status,
--                test_result, success_criteria_met, anomalies_count, test_conductor
--   PROGRAMS: program_id, program_code, program_name
-- ============================================================================
CREATE OR REPLACE VIEW V_TEST_RESULTS AS
SELECT
    t.test_id,
    t.test_number,
    t.test_name,
    t.test_type,
    t.test_category,
    t.test_date,
    t.test_location,
    t.test_status,
    t.test_result,
    t.success_criteria_met,
    t.anomalies_count,
    t.test_conductor,
    p.program_id,
    p.program_code,
    p.program_name,
    CASE 
        WHEN t.test_result = 'PASS' THEN 1
        ELSE 0
    END AS passed_flag,
    CASE 
        WHEN t.test_result = 'FAIL' THEN 1
        ELSE 0
    END AS failed_flag
FROM RAW.TEST_EVENTS t
LEFT JOIN RAW.PROGRAMS p ON t.program_id = p.program_id;

-- ============================================================================
-- View 9: Incident Tracking
-- VERIFIED COLUMNS FROM TABLES:
--   INCIDENTS: incident_id, division_id, program_id, incident_number, incident_date,
--              incident_type, incident_category, severity, location, incident_status,
--              investigation_status, cost_impact, schedule_impact_days, reported_by,
--              assigned_to
--   DIVISIONS: division_id, division_code, division_name
-- ============================================================================
CREATE OR REPLACE VIEW V_INCIDENT_TRACKING AS
SELECT
    i.incident_id,
    i.incident_number,
    i.incident_date,
    i.incident_type,
    i.incident_category,
    i.severity,
    i.location,
    i.incident_status,
    i.investigation_status,
    i.cost_impact,
    i.schedule_impact_days,
    i.reported_by,
    i.assigned_to,
    d.division_id,
    d.division_code,
    d.division_name,
    DATEDIFF('day', i.incident_date, CURRENT_TIMESTAMP()) AS age_days
FROM RAW.INCIDENTS i
JOIN RAW.DIVISIONS d ON i.division_id = d.division_id;

-- ============================================================================
-- View 10: Supplier Performance
-- VERIFIED COLUMNS FROM TABLES:
--   SUPPLIERS: supplier_id, supplier_code, supplier_name, supplier_type,
--              supplier_category, city, state, quality_rating, delivery_rating,
--              is_approved, is_small_business, supplier_status, total_spend
-- ============================================================================
CREATE OR REPLACE VIEW V_SUPPLIER_PERFORMANCE AS
SELECT
    s.supplier_id,
    s.supplier_code,
    s.supplier_name,
    s.supplier_type,
    s.supplier_category,
    s.city,
    s.state,
    s.quality_rating,
    s.delivery_rating,
    s.is_approved,
    s.is_small_business,
    s.supplier_status,
    s.total_spend,
    ((s.quality_rating + s.delivery_rating) / 2)::NUMBER(3,2) AS overall_rating
FROM RAW.SUPPLIERS s;

-- ============================================================================
-- View 11: Division Summary
-- VERIFIED COLUMNS FROM TABLES:
--   DIVISIONS: division_id, division_code, division_name, division_category,
--              headquarters_location, employee_count, annual_revenue
--   PROGRAMS: division_id, total_contract_value, funded_value, program_status
-- ============================================================================
CREATE OR REPLACE VIEW V_DIVISION_SUMMARY AS
SELECT
    d.division_id,
    d.division_code,
    d.division_name,
    d.division_category,
    d.headquarters_location,
    d.employee_count,
    d.annual_revenue,
    COUNT(DISTINCT p.program_id) AS program_count,
    COUNT(DISTINCT CASE WHEN p.program_status = 'ACTIVE' THEN p.program_id END) AS active_programs,
    SUM(p.total_contract_value) AS total_contract_value,
    SUM(p.funded_value) AS total_funded_value
FROM RAW.DIVISIONS d
LEFT JOIN RAW.PROGRAMS p ON d.division_id = p.division_id
GROUP BY 
    d.division_id, d.division_code, d.division_name, d.division_category,
    d.headquarters_location, d.employee_count, d.annual_revenue;

SELECT 'All analytical views created successfully' AS status;
