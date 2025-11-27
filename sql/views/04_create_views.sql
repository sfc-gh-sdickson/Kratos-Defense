-- ============================================================================
-- Kratos Defense Intelligence Agent - Analytical Views
-- ============================================================================
-- Purpose: Create analytical views for business intelligence
-- Syntax: Verified against Snowflake SQL Reference
-- ============================================================================

USE DATABASE KRATOS_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE KRATOS_WH;

-- ============================================================================
-- View 1: Program Dashboard View
-- ============================================================================
CREATE OR REPLACE VIEW V_PROGRAM_DASHBOARD AS
SELECT
    p.program_id,
    p.program_code,
    p.program_name,
    d.division_name,
    d.division_code,
    p.program_type,
    p.program_status,
    p.classification_level,
    c.customer_name,
    c.customer_type,
    p.program_manager,
    p.start_date,
    p.planned_end_date,
    p.total_contract_value,
    p.funded_value,
    p.budget_at_completion,
    p.estimate_at_completion,
    p.cost_variance_pct,
    p.schedule_variance_pct,
    p.risk_level,
    p.technology_readiness_level,
    DATEDIFF('day', p.start_date, COALESCE(p.planned_end_date, CURRENT_DATE())) AS program_duration_days,
    CASE 
        WHEN p.estimate_at_completion > p.budget_at_completion * 1.1 THEN 'OVER_BUDGET'
        WHEN p.estimate_at_completion < p.budget_at_completion * 0.9 THEN 'UNDER_BUDGET'
        ELSE 'ON_BUDGET'
    END AS budget_status
FROM RAW.PROGRAMS p
JOIN RAW.DIVISIONS d ON p.division_id = d.division_id
LEFT JOIN RAW.CUSTOMERS c ON p.customer_id = c.customer_id;

-- ============================================================================
-- View 2: Contract Performance View
-- ============================================================================
CREATE OR REPLACE VIEW V_CONTRACT_PERFORMANCE AS
SELECT
    c.contract_id,
    c.contract_number,
    p.program_code,
    p.program_name,
    c.contract_type,
    c.contract_status,
    c.award_date,
    c.period_of_performance_start,
    c.period_of_performance_end,
    c.base_value,
    c.option_value,
    c.total_ceiling_value,
    c.funded_amount,
    c.obligated_amount,
    c.billed_amount,
    c.fee_type,
    c.fee_percentage,
    c.modification_count,
    c.is_prime_contract,
    (c.billed_amount / NULLIF(c.funded_amount, 0) * 100)::NUMBER(8,2) AS billing_pct,
    (c.obligated_amount / NULLIF(c.total_ceiling_value, 0) * 100)::NUMBER(8,2) AS obligation_pct,
    DATEDIFF('day', c.period_of_performance_start, c.period_of_performance_end) AS pop_days,
    DATEDIFF('day', CURRENT_DATE(), c.period_of_performance_end) AS days_to_pop_end
FROM RAW.CONTRACTS c
JOIN RAW.PROGRAMS p ON c.program_id = p.program_id;

-- ============================================================================
-- View 3: Supplier Scorecard View
-- ============================================================================
CREATE OR REPLACE VIEW V_SUPPLIER_SCORECARD AS
SELECT
    s.supplier_id,
    s.supplier_code,
    s.supplier_name,
    s.supplier_type,
    s.supplier_tier,
    s.city,
    s.state,
    s.is_small_business,
    s.small_business_type,
    s.quality_rating AS current_quality_rating,
    s.delivery_rating AS current_delivery_rating,
    s.overall_rating AS current_overall_rating,
    COUNT(DISTINCT sp.performance_id) AS evaluation_count,
    AVG(sp.quality_score) AS avg_quality_score,
    AVG(sp.on_time_delivery_pct) AS avg_on_time_delivery_pct,
    AVG(sp.defect_rate_pct) AS avg_defect_rate_pct,
    AVG(sp.responsiveness_score) AS avg_responsiveness_score,
    AVG(sp.overall_score) AS avg_overall_score,
    SUM(sp.total_orders) AS total_orders,
    SUM(sp.total_value) AS total_value,
    SUM(sp.on_time_orders) AS total_on_time_orders,
    SUM(sp.late_orders) AS total_late_orders,
    SUM(sp.rejected_items) AS total_rejected_items,
    SUM(sp.accepted_items) AS total_accepted_items,
    SUM(sp.corrective_actions_issued) AS total_cars_issued,
    SUM(sp.corrective_actions_closed) AS total_cars_closed
FROM RAW.SUPPLIERS s
LEFT JOIN RAW.SUPPLIER_PERFORMANCE sp ON s.supplier_id = sp.supplier_id
GROUP BY 
    s.supplier_id, s.supplier_code, s.supplier_name, s.supplier_type,
    s.supplier_tier, s.city, s.state, s.is_small_business, s.small_business_type,
    s.quality_rating, s.delivery_rating, s.overall_rating;

-- ============================================================================
-- View 4: Production Metrics View
-- ============================================================================
CREATE OR REPLACE VIEW V_PRODUCTION_METRICS AS
SELECT
    wo.work_order_id,
    wo.work_order_number,
    p.program_code,
    p.program_name,
    wo.work_order_type,
    wo.work_order_status,
    wo.priority,
    wo.quantity_ordered,
    wo.quantity_completed,
    wo.quantity_scrapped,
    wo.planned_start_date,
    wo.planned_end_date,
    wo.actual_start_date,
    wo.actual_end_date,
    wo.estimated_hours,
    wo.actual_hours,
    wo.estimated_cost,
    wo.actual_cost,
    wo.work_center,
    wo.assigned_team,
    (wo.quantity_completed::FLOAT / NULLIF(wo.quantity_ordered, 0) * 100)::NUMBER(8,2) AS completion_pct,
    (wo.actual_hours / NULLIF(wo.estimated_hours, 0) * 100)::NUMBER(8,2) AS hours_efficiency_pct,
    (wo.actual_cost / NULLIF(wo.estimated_cost, 0) * 100)::NUMBER(8,2) AS cost_efficiency_pct,
    CASE 
        WHEN wo.actual_end_date IS NOT NULL AND wo.actual_end_date <= wo.planned_end_date THEN 'ON_TIME'
        WHEN wo.actual_end_date IS NOT NULL AND wo.actual_end_date > wo.planned_end_date THEN 'LATE'
        WHEN wo.planned_end_date < CURRENT_DATE() AND wo.actual_end_date IS NULL THEN 'OVERDUE'
        ELSE 'IN_PROGRESS'
    END AS schedule_status
FROM RAW.PRODUCTION_ORDERS wo
JOIN RAW.PROGRAMS p ON wo.program_id = p.program_id;

-- ============================================================================
-- View 5: Quality Dashboard View
-- ============================================================================
CREATE OR REPLACE VIEW V_QUALITY_DASHBOARD AS
SELECT
    qr.quality_id,
    p.program_code,
    p.program_name,
    s.supplier_name,
    qr.record_type,
    qr.record_status,
    qr.severity,
    qr.title,
    qr.root_cause,
    qr.disposition,
    qr.affected_quantity,
    qr.cost_impact,
    qr.schedule_impact_days,
    qr.reported_date,
    qr.due_date,
    qr.closure_date,
    qr.assigned_to,
    DATEDIFF('day', qr.reported_date, COALESCE(qr.closure_date, CURRENT_DATE())) AS age_days,
    CASE 
        WHEN qr.record_status = 'CLOSED' THEN 'RESOLVED'
        WHEN qr.due_date < CURRENT_DATE() THEN 'OVERDUE'
        WHEN qr.due_date <= DATEADD('day', 7, CURRENT_DATE()) THEN 'DUE_SOON'
        ELSE 'ON_TRACK'
    END AS action_status
FROM RAW.QUALITY_RECORDS qr
JOIN RAW.PROGRAMS p ON qr.program_id = p.program_id
LEFT JOIN RAW.SUPPLIERS s ON qr.supplier_id = s.supplier_id;

-- ============================================================================
-- View 6: Engineering Test Summary View
-- ============================================================================
CREATE OR REPLACE VIEW V_ENGINEERING_TEST_SUMMARY AS
SELECT
    et.test_id,
    p.program_code,
    p.program_name,
    et.test_name,
    et.test_type,
    et.test_category,
    et.test_status,
    et.test_result,
    et.planned_date,
    et.actual_date,
    et.test_location,
    et.test_engineer,
    et.anomalies_detected,
    et.test_duration_hours,
    et.test_cost,
    CASE 
        WHEN et.test_result = 'PASS' THEN 1
        WHEN et.test_result = 'PASS_WITH_DEVIATION' THEN 1
        ELSE 0
    END AS passed_flag,
    CASE 
        WHEN et.test_result = 'FAIL' THEN 1
        ELSE 0
    END AS failed_flag
FROM RAW.ENGINEERING_TESTS et
JOIN RAW.PROGRAMS p ON et.program_id = p.program_id;

-- ============================================================================
-- View 7: Customer Support Dashboard View
-- ============================================================================
CREATE OR REPLACE VIEW V_CUSTOMER_SUPPORT_DASHBOARD AS
SELECT
    st.ticket_id,
    st.ticket_number,
    c.customer_name,
    c.customer_type,
    p.program_code,
    p.program_name,
    st.ticket_type,
    st.ticket_category,
    st.priority,
    st.ticket_status,
    st.subject,
    st.reported_date,
    st.response_date,
    st.resolution_date,
    st.assigned_to,
    st.satisfaction_rating,
    st.sla_met,
    DATEDIFF('hour', st.reported_date, COALESCE(st.response_date, CURRENT_TIMESTAMP())) AS response_time_hours,
    DATEDIFF('day', st.reported_date, COALESCE(st.resolution_date, CURRENT_TIMESTAMP())) AS resolution_time_days,
    CASE 
        WHEN st.ticket_status = 'CLOSED' THEN 'RESOLVED'
        WHEN st.priority = 'CRITICAL' AND st.ticket_status != 'CLOSED' THEN 'CRITICAL_OPEN'
        WHEN st.priority = 'HIGH' AND st.ticket_status != 'CLOSED' THEN 'HIGH_PRIORITY_OPEN'
        ELSE 'NORMAL'
    END AS urgency_status
FROM RAW.SUPPORT_TICKETS st
JOIN RAW.CUSTOMERS c ON st.customer_id = c.customer_id
LEFT JOIN RAW.PROGRAMS p ON st.program_id = p.program_id;

-- ============================================================================
-- View 8: Risk Management View
-- ============================================================================
CREATE OR REPLACE VIEW V_RISK_MANAGEMENT AS
SELECT
    rr.risk_id,
    p.program_code,
    p.program_name,
    rr.risk_title,
    rr.risk_category,
    rr.risk_type,
    rr.probability,
    rr.impact,
    rr.risk_score,
    rr.risk_status,
    rr.identification_date,
    rr.risk_owner,
    rr.mitigation_status,
    rr.cost_impact_low,
    rr.cost_impact_high,
    rr.schedule_impact_days,
    rr.review_date,
    DATEDIFF('day', rr.identification_date, CURRENT_DATE()) AS risk_age_days,
    CASE 
        WHEN rr.risk_score >= 20 THEN 'CRITICAL'
        WHEN rr.risk_score >= 15 THEN 'HIGH'
        WHEN rr.risk_score >= 10 THEN 'MEDIUM'
        ELSE 'LOW'
    END AS risk_rating
FROM RAW.RISK_REGISTER rr
JOIN RAW.PROGRAMS p ON rr.program_id = p.program_id;

-- ============================================================================
-- View 9: Division Summary View
-- ============================================================================
CREATE OR REPLACE VIEW V_DIVISION_SUMMARY AS
SELECT
    d.division_id,
    d.division_code,
    d.division_name,
    d.division_head,
    d.headquarters_location,
    d.employee_count,
    d.annual_revenue,
    COUNT(DISTINCT p.program_id) AS program_count,
    COUNT(DISTINCT CASE WHEN p.program_status = 'ACTIVE' THEN p.program_id END) AS active_programs,
    SUM(p.total_contract_value) AS total_contract_value,
    SUM(p.funded_value) AS total_funded_value,
    AVG(p.cost_variance_pct) AS avg_cost_variance_pct,
    AVG(p.schedule_variance_pct) AS avg_schedule_variance_pct
FROM RAW.DIVISIONS d
LEFT JOIN RAW.PROGRAMS p ON d.division_id = p.division_id
GROUP BY 
    d.division_id, d.division_code, d.division_name, d.division_head,
    d.headquarters_location, d.employee_count, d.annual_revenue;

-- ============================================================================
-- Display confirmation
-- ============================================================================
SELECT 'All analytical views created successfully' AS status;
