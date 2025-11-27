-- ============================================================================
-- Kratos Defense Intelligence Agent - Analytical Views
-- ============================================================================
-- Purpose: Create analytical views for common business metrics and reporting
-- All column names VERIFIED against 02_create_tables.sql
-- Syntax: Verified against Snowflake SQL Reference
-- ============================================================================

USE DATABASE KRATOS_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE KRATOS_WH;

-- ============================================================================
-- View 1: Program 360 - Complete program overview
-- VERIFIED COLUMNS: program_id, program_code, program_name, program_type, program_status,
--                   budget_amount, spent_amount, percent_complete, risk_level, customer
-- ============================================================================
CREATE OR REPLACE VIEW V_PROGRAM_360 AS
SELECT
    p.program_id,
    p.program_code,
    p.program_name,
    p.program_type,
    p.program_status,
    d.division_name,
    p.customer,
    p.prime_contractor,
    p.start_date,
    p.end_date,
    p.budget_amount,
    p.spent_amount,
    p.budget_variance,
    p.schedule_variance_days,
    p.risk_level,
    p.priority_level,
    p.classification_level,
    p.contract_type,
    p.milestone_count,
    p.milestones_completed,
    p.percent_complete,
    -- Calculated fields
    (p.spent_amount / NULLIF(p.budget_amount, 0) * 100)::NUMBER(5,2) AS budget_utilization_pct,
    (p.milestones_completed::FLOAT / NULLIF(p.milestone_count, 0) * 100)::NUMBER(5,2) AS milestone_completion_pct,
    DATEDIFF('day', p.start_date, COALESCE(p.end_date, CURRENT_DATE())) AS program_duration_days,
    -- Related counts
    (SELECT COUNT(*) FROM RAW.CONTRACTS c WHERE c.program_id = p.program_id) AS contract_count,
    (SELECT COUNT(*) FROM RAW.ASSETS a WHERE a.program_id = p.program_id) AS asset_count
FROM RAW.PROGRAMS p
LEFT JOIN RAW.DIVISIONS d ON p.division_id = d.division_id;

-- ============================================================================
-- View 2: Contract Analytics
-- VERIFIED COLUMNS: contract_id, contract_number, contract_name, contract_type,
--                   contract_status, base_value, ceiling_value, funded_value, billed_amount
-- ============================================================================
CREATE OR REPLACE VIEW V_CONTRACT_ANALYTICS AS
SELECT
    c.contract_id,
    c.contract_number,
    c.contract_name,
    c.contract_type,
    c.contract_status,
    p.program_name,
    c.customer,
    c.award_date,
    c.start_date,
    c.end_date,
    c.base_value,
    c.ceiling_value,
    c.funded_value,
    c.billed_amount,
    c.performance_rating,
    c.is_classified,
    c.security_level,
    -- Calculated metrics
    (c.funded_value / NULLIF(c.ceiling_value, 0) * 100)::NUMBER(5,2) AS funding_utilization_pct,
    (c.billed_amount / NULLIF(c.funded_value, 0) * 100)::NUMBER(5,2) AS billing_pct,
    (c.ceiling_value - c.base_value)::NUMBER(15,2) AS option_value,
    DATEDIFF('day', CURRENT_DATE(), c.end_date) AS days_remaining,
    CASE 
        WHEN c.end_date < CURRENT_DATE() THEN 'EXPIRED'
        WHEN DATEDIFF('day', CURRENT_DATE(), c.end_date) <= 90 THEN 'EXPIRING_SOON'
        ELSE 'ACTIVE'
    END AS expiration_status
FROM RAW.CONTRACTS c
LEFT JOIN RAW.PROGRAMS p ON c.program_id = p.program_id;

-- ============================================================================
-- View 3: Asset Status Summary
-- VERIFIED COLUMNS: asset_id, asset_tag, asset_name, asset_type, asset_status,
--                   acquisition_cost, current_value, mission_ready, condition_rating
-- ============================================================================
CREATE OR REPLACE VIEW V_ASSET_STATUS AS
SELECT
    a.asset_id,
    a.asset_tag,
    a.asset_name,
    a.asset_type,
    a.asset_category,
    a.asset_status,
    a.manufacturer,
    a.model,
    p.program_name,
    a.assigned_location,
    a.acquisition_date,
    a.acquisition_cost,
    a.current_value,
    a.depreciation_rate,
    a.total_flight_hours,
    a.maintenance_interval_hours,
    a.last_maintenance_date,
    a.next_maintenance_due,
    a.mission_ready,
    a.condition_rating,
    -- Calculated metrics
    (a.acquisition_cost - a.current_value)::NUMBER(15,2) AS total_depreciation,
    DATEDIFF('day', CURRENT_DATE(), a.next_maintenance_due) AS days_until_maintenance,
    CASE 
        WHEN a.next_maintenance_due < CURRENT_DATE() THEN 'OVERDUE'
        WHEN DATEDIFF('day', CURRENT_DATE(), a.next_maintenance_due) <= 14 THEN 'DUE_SOON'
        ELSE 'ON_SCHEDULE'
    END AS maintenance_urgency,
    (SELECT COUNT(*) FROM RAW.MAINTENANCE_RECORDS m WHERE m.asset_id = a.asset_id) AS total_maintenance_records
FROM RAW.ASSETS a
LEFT JOIN RAW.PROGRAMS p ON a.program_id = p.program_id;

-- ============================================================================
-- View 4: Supplier Performance
-- VERIFIED COLUMNS: supplier_id, supplier_code, supplier_name, supplier_type,
--                   supplier_status, quality_rating, delivery_rating, total_spend
-- ============================================================================
CREATE OR REPLACE VIEW V_SUPPLIER_PERFORMANCE AS
SELECT
    s.supplier_id,
    s.supplier_code,
    s.supplier_name,
    s.supplier_type,
    s.supplier_status,
    s.cage_code,
    s.city,
    s.state,
    s.country,
    s.payment_terms,
    s.credit_limit,
    s.risk_rating,
    s.quality_rating,
    s.delivery_rating,
    s.is_small_business,
    s.is_woman_owned,
    s.is_veteran_owned,
    s.is_minority_owned,
    s.total_orders,
    s.total_spend,
    -- Calculated metrics
    ((s.quality_rating + s.delivery_rating) / 2)::NUMBER(3,2) AS overall_rating,
    (s.total_spend / NULLIF(s.total_orders, 0))::NUMBER(12,2) AS avg_order_value,
    -- PO counts
    (SELECT COUNT(*) FROM RAW.PURCHASE_ORDERS po WHERE po.supplier_id = s.supplier_id AND po.po_status = 'OPEN') AS open_po_count,
    (SELECT SUM(po.total_amount) FROM RAW.PURCHASE_ORDERS po WHERE po.supplier_id = s.supplier_id AND po.po_status = 'OPEN') AS open_po_value
FROM RAW.SUPPLIERS s;

-- ============================================================================
-- View 5: Monthly Spending Summary
-- VERIFIED COLUMNS: po_date, total_amount, subtotal, po_status
-- ============================================================================
CREATE OR REPLACE VIEW V_MONTHLY_SPENDING AS
SELECT
    DATE_TRUNC('month', po.po_date)::DATE AS spending_month,
    COUNT(DISTINCT po.po_id) AS total_orders,
    COUNT(DISTINCT po.supplier_id) AS unique_suppliers,
    SUM(po.subtotal)::NUMBER(15,2) AS gross_spending,
    SUM(po.tax_amount)::NUMBER(12,2) AS total_tax,
    SUM(po.shipping_amount)::NUMBER(12,2) AS total_shipping,
    SUM(po.total_amount)::NUMBER(15,2) AS net_spending,
    SUM(po.paid_amount)::NUMBER(15,2) AS paid_amount,
    AVG(po.total_amount)::NUMBER(12,2) AS avg_order_value,
    COUNT(DISTINCT CASE WHEN po.po_status = 'OPEN' THEN po.po_id END) AS open_orders,
    COUNT(DISTINCT CASE WHEN po.po_status = 'RECEIVED' THEN po.po_id END) AS received_orders
FROM RAW.PURCHASE_ORDERS po
GROUP BY DATE_TRUNC('month', po.po_date)
ORDER BY spending_month DESC;

-- ============================================================================
-- View 6: Maintenance Analytics
-- VERIFIED COLUMNS: maintenance_id, maintenance_type, maintenance_status,
--                   labor_hours, parts_cost, labor_cost, total_cost
-- ============================================================================
CREATE OR REPLACE VIEW V_MAINTENANCE_ANALYTICS AS
SELECT
    DATE_TRUNC('month', m.scheduled_date)::DATE AS maintenance_month,
    m.maintenance_type,
    m.maintenance_category,
    m.priority,
    COUNT(DISTINCT m.maintenance_id) AS total_records,
    COUNT(DISTINCT CASE WHEN m.maintenance_status = 'COMPLETED' THEN m.maintenance_id END) AS completed,
    COUNT(DISTINCT CASE WHEN m.maintenance_status = 'IN_PROGRESS' THEN m.maintenance_id END) AS in_progress,
    COUNT(DISTINCT CASE WHEN m.maintenance_status = 'SCHEDULED' THEN m.maintenance_id END) AS scheduled,
    SUM(m.labor_hours)::NUMBER(10,2) AS total_labor_hours,
    SUM(m.parts_cost)::NUMBER(15,2) AS total_parts_cost,
    SUM(m.labor_cost)::NUMBER(15,2) AS total_labor_cost,
    SUM(m.total_cost)::NUMBER(15,2) AS total_maintenance_cost,
    AVG(m.downtime_hours)::NUMBER(8,2) AS avg_downtime_hours,
    SUM(CASE WHEN m.is_unscheduled = TRUE THEN 1 ELSE 0 END) AS unscheduled_count
FROM RAW.MAINTENANCE_RECORDS m
GROUP BY DATE_TRUNC('month', m.scheduled_date), m.maintenance_type, m.maintenance_category, m.priority
ORDER BY maintenance_month DESC;

-- ============================================================================
-- View 7: Quality Metrics
-- VERIFIED COLUMNS: inspection_id, inspection_type, inspection_status,
--                   compliance_score, quality_score, safety_score, passed
-- ============================================================================
CREATE OR REPLACE VIEW V_QUALITY_METRICS AS
SELECT
    DATE_TRUNC('month', qi.inspection_date)::DATE AS inspection_month,
    qi.inspection_type,
    COUNT(DISTINCT qi.inspection_id) AS total_inspections,
    SUM(CASE WHEN qi.passed = TRUE THEN 1 ELSE 0 END) AS passed_inspections,
    SUM(CASE WHEN qi.passed = FALSE THEN 1 ELSE 0 END) AS failed_inspections,
    (SUM(CASE WHEN qi.passed = TRUE THEN 1 ELSE 0 END)::FLOAT / NULLIF(COUNT(DISTINCT qi.inspection_id), 0) * 100)::NUMBER(5,2) AS pass_rate,
    AVG(qi.compliance_score)::NUMBER(5,2) AS avg_compliance_score,
    AVG(qi.quality_score)::NUMBER(5,2) AS avg_quality_score,
    AVG(qi.safety_score)::NUMBER(5,2) AS avg_safety_score,
    AVG(qi.overall_rating)::NUMBER(3,2) AS avg_overall_rating,
    SUM(qi.findings_count) AS total_findings,
    SUM(qi.critical_findings) AS total_critical_findings
FROM RAW.QUALITY_INSPECTIONS qi
GROUP BY DATE_TRUNC('month', qi.inspection_date), qi.inspection_type
ORDER BY inspection_month DESC;

-- ============================================================================
-- View 8: Proposal Pipeline
-- VERIFIED COLUMNS: proposal_id, proposal_number, proposal_name, proposal_status,
--                   opportunity_value, proposed_value, win_probability
-- ============================================================================
CREATE OR REPLACE VIEW V_PROPOSAL_PIPELINE AS
SELECT
    pr.proposal_id,
    pr.proposal_number,
    pr.proposal_name,
    pr.solicitation_number,
    pr.proposal_type,
    pr.proposal_status,
    d.division_name,
    pr.customer,
    pr.opportunity_value,
    pr.proposed_value,
    pr.win_probability,
    pr.submission_date,
    pr.due_date,
    pr.decision_date,
    pr.result,
    -- Calculated metrics
    DATEDIFF('day', CURRENT_DATE(), pr.due_date) AS days_until_due,
    (pr.opportunity_value * pr.win_probability / 100)::NUMBER(15,2) AS weighted_value,
    CASE 
        WHEN pr.due_date < CURRENT_DATE() THEN 'PAST_DUE'
        WHEN DATEDIFF('day', CURRENT_DATE(), pr.due_date) <= 30 THEN 'URGENT'
        WHEN DATEDIFF('day', CURRENT_DATE(), pr.due_date) <= 90 THEN 'UPCOMING'
        ELSE 'FUTURE'
    END AS urgency_status
FROM RAW.PROPOSALS pr
LEFT JOIN RAW.DIVISIONS d ON pr.division_id = d.division_id;

-- ============================================================================
-- View 9: Employee Summary
-- VERIFIED COLUMNS: employee_id, first_name, last_name, job_title, department,
--                   employee_status, security_clearance, annual_salary, billable_rate
-- ============================================================================
CREATE OR REPLACE VIEW V_EMPLOYEE_SUMMARY AS
SELECT
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    e.job_title,
    e.department,
    d.division_name,
    e.employee_level,
    e.employee_status,
    e.security_clearance,
    e.clearance_expiry_date,
    e.hire_date,
    e.years_experience,
    e.education_level,
    e.location,
    e.is_remote,
    e.annual_salary,
    e.billable_rate,
    e.utilization_target,
    -- Calculated metrics
    DATEDIFF('month', e.hire_date, CURRENT_DATE()) AS months_employed,
    DATEDIFF('day', CURRENT_DATE(), e.clearance_expiry_date) AS days_until_clearance_expiry,
    CASE 
        WHEN e.clearance_expiry_date < CURRENT_DATE() THEN 'EXPIRED'
        WHEN DATEDIFF('day', CURRENT_DATE(), e.clearance_expiry_date) <= 90 THEN 'EXPIRING_SOON'
        ELSE 'VALID'
    END AS clearance_status
FROM RAW.EMPLOYEES e
LEFT JOIN RAW.DIVISIONS d ON e.division_id = d.division_id;

-- ============================================================================
-- View 10: Division Performance
-- VERIFIED COLUMNS: division_id, division_code, division_name, division_category,
--                   employee_count, annual_revenue, is_active
-- ============================================================================
CREATE OR REPLACE VIEW V_DIVISION_PERFORMANCE AS
SELECT
    d.division_id,
    d.division_code,
    d.division_name,
    d.division_category,
    d.headquarters_location,
    d.employee_count,
    d.annual_revenue,
    d.primary_customer,
    d.security_clearance_level,
    d.is_active,
    d.established_date,
    -- Calculated metrics from related tables
    (SELECT COUNT(*) FROM RAW.PROGRAMS p WHERE p.division_id = d.division_id) AS program_count,
    (SELECT COUNT(*) FROM RAW.PROGRAMS p WHERE p.division_id = d.division_id AND p.program_status = 'ACTIVE') AS active_programs,
    (SELECT SUM(p.budget_amount) FROM RAW.PROGRAMS p WHERE p.division_id = d.division_id)::NUMBER(15,2) AS total_program_budget,
    (SELECT COUNT(*) FROM RAW.EMPLOYEES e WHERE e.division_id = d.division_id) AS actual_employee_count,
    (SELECT COUNT(*) FROM RAW.PROPOSALS pr WHERE pr.division_id = d.division_id AND pr.proposal_status = 'IN_PROGRESS') AS active_proposals,
    (SELECT SUM(pr.opportunity_value) FROM RAW.PROPOSALS pr WHERE pr.division_id = d.division_id AND pr.proposal_status IN ('IN_PROGRESS', 'SUBMITTED'))::NUMBER(15,2) AS pipeline_value
FROM RAW.DIVISIONS d;

-- ============================================================================
-- Display confirmation
-- ============================================================================
SELECT 'All analytical views created successfully' AS status;

