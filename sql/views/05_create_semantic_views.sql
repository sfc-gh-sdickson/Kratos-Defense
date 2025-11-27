-- ============================================================================
-- Kratos Defense Intelligence Agent - Semantic Views
-- ============================================================================
-- CRITICAL SYNTAX (from GENERATION_FAILURES_AND_LESSONS.md):
--   DIMENSIONS: table_alias.semantic_name AS actual_column_name
--   The expression AFTER "AS" must be the actual column from the table
-- 
-- Clause order: TABLES → RELATIONSHIPS → DIMENSIONS → METRICS → COMMENT
-- All column references VERIFIED against 02_create_tables.sql
-- ============================================================================

USE DATABASE KRATOS_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE KRATOS_WH;

-- ============================================================================
-- Semantic View 1: Program & Contract Operations Intelligence
-- ============================================================================
-- VERIFIED COLUMNS:
--   PROGRAMS: program_id, division_id, program_code, program_name, program_type,
--             program_category, program_status, program_phase, security_classification,
--             start_date, planned_end_date, total_contract_value, funded_value,
--             costs_incurred, revenue_recognized, margin_percentage, program_manager,
--             technical_lead, risk_level, customer_id
--   DIVISIONS: division_id, division_code, division_name, division_category
--   CUSTOMERS: customer_id, customer_code, customer_name, customer_type,
--              customer_category, agency_branch, country
--   CONTRACTS: contract_id, program_id, customer_id, contract_number, contract_name,
--              contract_type, contract_vehicle, award_date, start_date, end_date,
--              base_value, option_value, total_value, funded_amount, contract_status
--   MILESTONES: milestone_id, program_id, milestone_name, milestone_type,
--               milestone_status, planned_date, actual_date, payment_milestone
-- ============================================================================

CREATE OR REPLACE SEMANTIC VIEW SV_PROGRAM_OPERATIONS_INTELLIGENCE
  TABLES (
    programs AS RAW.PROGRAMS
      PRIMARY KEY (program_id)
      WITH SYNONYMS ('defense programs', 'projects', 'program portfolio'),
    divisions AS RAW.DIVISIONS
      PRIMARY KEY (division_id)
      WITH SYNONYMS ('business units', 'segments', 'operating divisions'),
    customers AS RAW.CUSTOMERS
      PRIMARY KEY (customer_id)
      WITH SYNONYMS ('dod customers', 'government clients', 'military customers'),
    contracts AS RAW.CONTRACTS
      PRIMARY KEY (contract_id)
      WITH SYNONYMS ('defense contracts', 'awards', 'contract awards'),
    milestones AS RAW.MILESTONES
      PRIMARY KEY (milestone_id)
      WITH SYNONYMS ('program milestones', 'deliverables', 'schedule milestones')
  )
  RELATIONSHIPS (
    programs(division_id) REFERENCES divisions(division_id),
    programs(customer_id) REFERENCES customers(customer_id),
    contracts(program_id) REFERENCES programs(program_id),
    contracts(customer_id) REFERENCES customers(customer_id),
    milestones(program_id) REFERENCES programs(program_id)
  )
  DIMENSIONS (
    -- Program dimensions (semantic_name AS actual_column)
    programs.prog_id AS program_id
      WITH SYNONYMS ('project id', 'program identifier'),
    programs.prog_code AS program_code
      WITH SYNONYMS ('project code', 'program number'),
    programs.prog_name AS program_name
      WITH SYNONYMS ('project name', 'program title'),
    programs.prog_type AS program_type
      WITH SYNONYMS ('project type', 'contract category'),
    programs.prog_status AS program_status
      WITH SYNONYMS ('project status', 'program state'),
    programs.prog_phase AS program_phase
      WITH SYNONYMS ('project phase', 'development phase'),
    programs.classification AS security_classification
      WITH SYNONYMS ('classification level', 'security level'),
    programs.prog_risk AS risk_level
      WITH SYNONYMS ('project risk', 'risk rating'),
    programs.pm AS program_manager
      WITH SYNONYMS ('project manager', 'program lead'),
    -- Division dimensions
    divisions.div_name AS division_name
      WITH SYNONYMS ('business unit', 'segment name'),
    divisions.div_code AS division_code
      WITH SYNONYMS ('unit code', 'segment code'),
    divisions.div_category AS division_category
      WITH SYNONYMS ('unit type', 'segment category'),
    -- Customer dimensions
    customers.cust_name AS customer_name
      WITH SYNONYMS ('client name', 'dod agency'),
    customers.cust_type AS customer_type
      WITH SYNONYMS ('client type', 'agency type'),
    customers.cust_category AS customer_category
      WITH SYNONYMS ('client category', 'customer class'),
    customers.branch AS agency_branch
      WITH SYNONYMS ('military branch', 'service branch'),
    -- Contract dimensions
    contracts.contract_num AS contract_number
      WITH SYNONYMS ('award number', 'contract id'),
    contracts.contract_title AS contract_name
      WITH SYNONYMS ('award name', 'contract title'),
    contracts.contr_type AS contract_type
      WITH SYNONYMS ('pricing type', 'award type'),
    contracts.contr_status AS contract_status
      WITH SYNONYMS ('award status', 'contract state'),
    contracts.vehicle AS contract_vehicle
      WITH SYNONYMS ('acquisition vehicle', 'buying vehicle'),
    -- Milestone dimensions
    milestones.ms_name AS milestone_name
      WITH SYNONYMS ('deliverable name', 'event name'),
    milestones.ms_type AS milestone_type
      WITH SYNONYMS ('deliverable type', 'event type'),
    milestones.ms_status AS milestone_status
      WITH SYNONYMS ('deliverable status', 'event status')
  )
  METRICS (
    -- Program metrics
    programs.total_programs AS COUNT(DISTINCT program_id)
      WITH SYNONYMS ('program count', 'project count'),
    programs.total_program_value AS SUM(total_contract_value)
      WITH SYNONYMS ('program value', 'portfolio value'),
    programs.total_funded AS SUM(funded_value)
      WITH SYNONYMS ('funded amount', 'obligated funds'),
    programs.total_costs AS SUM(costs_incurred)
      WITH SYNONYMS ('costs spent', 'expenses incurred'),
    programs.total_revenue AS SUM(revenue_recognized)
      WITH SYNONYMS ('revenue earned', 'recognized revenue'),
    programs.avg_margin AS AVG(margin_percentage)
      WITH SYNONYMS ('average margin', 'mean profit margin'),
    -- Contract metrics
    contracts.total_contracts AS COUNT(DISTINCT contract_id)
      WITH SYNONYMS ('contract count', 'award count'),
    contracts.contract_base AS SUM(base_value)
      WITH SYNONYMS ('base contract value', 'initial award value'),
    contracts.contract_options AS SUM(option_value)
      WITH SYNONYMS ('option value', 'potential value'),
    contracts.contract_ceiling AS SUM(total_value)
      WITH SYNONYMS ('total award value', 'full contract value'),
    contracts.contract_funded AS SUM(funded_amount)
      WITH SYNONYMS ('funded contract value', 'obligated amount'),
    -- Milestone metrics
    milestones.total_milestones AS COUNT(DISTINCT milestone_id)
      WITH SYNONYMS ('milestone count', 'deliverable count'),
    milestones.completed_ms AS SUM(CASE WHEN milestone_status = 'COMPLETED' THEN 1 ELSE 0 END)
      WITH SYNONYMS ('finished milestones', 'achieved deliverables'),
    milestones.at_risk_ms AS SUM(CASE WHEN milestone_status IN ('AT_RISK', 'DELAYED') THEN 1 ELSE 0 END)
      WITH SYNONYMS ('problem milestones', 'delayed deliverables')
  )
  COMMENT = 'Program & Contract Operations Intelligence';

-- ============================================================================
-- Semantic View 2: Asset & Manufacturing Intelligence
-- ============================================================================
-- VERIFIED COLUMNS:
--   ASSETS: asset_id, division_id, program_id, asset_serial_number, asset_name,
--           asset_type, asset_category, asset_model, asset_status, operational_status,
--           location, total_flight_hours, total_missions, acquisition_cost, current_value
--   ASSET_OPERATIONS: operation_id, asset_id, operation_date, operation_type,
--                     mission_type, flight_hours, cycles, operation_status, mission_success
--   MAINTENANCE_RECORDS: maintenance_id, asset_id, maintenance_date, maintenance_type,
--                        maintenance_category, labor_hours, parts_cost, labor_cost,
--                        total_cost, maintenance_status
--   MANUFACTURING_ORDERS: order_id, division_id, order_number, product_name, product_type,
--                         order_type, order_status, quantity_ordered, quantity_completed,
--                         quantity_scrapped, unit_cost, total_cost, priority
--   QUALITY_INSPECTIONS: inspection_id, inspection_date, inspection_type, inspection_result,
--                        defects_found, quality_score
-- ============================================================================

CREATE OR REPLACE SEMANTIC VIEW SV_ASSET_MANUFACTURING_INTELLIGENCE
  TABLES (
    assets AS RAW.ASSETS
      PRIMARY KEY (asset_id)
      WITH SYNONYMS ('equipment', 'unmanned systems', 'fleet assets'),
    operations AS RAW.ASSET_OPERATIONS
      PRIMARY KEY (operation_id)
      WITH SYNONYMS ('flights', 'missions', 'asset usage'),
    maintenance AS RAW.MAINTENANCE_RECORDS
      PRIMARY KEY (maintenance_id)
      WITH SYNONYMS ('service records', 'repairs', 'maintenance history'),
    manufacturing AS RAW.MANUFACTURING_ORDERS
      PRIMARY KEY (order_id)
      WITH SYNONYMS ('production orders', 'work orders', 'manufacturing jobs'),
    quality AS RAW.QUALITY_INSPECTIONS
      PRIMARY KEY (inspection_id)
      WITH SYNONYMS ('qc inspections', 'quality checks', 'inspection records')
  )
  RELATIONSHIPS (
    operations(asset_id) REFERENCES assets(asset_id),
    maintenance(asset_id) REFERENCES assets(asset_id),
    quality(order_id) REFERENCES manufacturing(order_id)
  )
  DIMENSIONS (
    -- Asset dimensions
    assets.asset_identifier AS asset_id
      WITH SYNONYMS ('equipment id', 'system id'),
    assets.serial_num AS asset_serial_number
      WITH SYNONYMS ('sn', 'equipment serial'),
    assets.name AS asset_name
      WITH SYNONYMS ('equipment name', 'system name'),
    assets.type AS asset_type
      WITH SYNONYMS ('equipment type', 'system type'),
    assets.category AS asset_category
      WITH SYNONYMS ('equipment category', 'asset class'),
    assets.model AS asset_model
      WITH SYNONYMS ('equipment model', 'variant'),
    assets.status AS asset_status
      WITH SYNONYMS ('equipment status', 'system condition'),
    assets.op_status AS operational_status
      WITH SYNONYMS ('availability', 'readiness status'),
    assets.asset_location AS location
      WITH SYNONYMS ('equipment location', 'base location'),
    -- Operations dimensions
    operations.op_type AS operation_type
      WITH SYNONYMS ('activity type', 'usage type'),
    operations.mission AS mission_type
      WITH SYNONYMS ('flight type', 'mission category'),
    operations.op_status AS operation_status
      WITH SYNONYMS ('activity status', 'mission status'),
    -- Maintenance dimensions
    maintenance.maint_type AS maintenance_type
      WITH SYNONYMS ('service type', 'work type'),
    maintenance.maint_category AS maintenance_category
      WITH SYNONYMS ('service category', 'maintenance area'),
    maintenance.maint_status AS maintenance_status
      WITH SYNONYMS ('service status', 'work status'),
    -- Manufacturing dimensions
    manufacturing.product AS product_name
      WITH SYNONYMS ('manufactured item', 'produced item'),
    manufacturing.prod_type AS product_type
      WITH SYNONYMS ('item type', 'manufactured type'),
    manufacturing.mfg_order_type AS order_type
      WITH SYNONYMS ('production type', 'job type'),
    manufacturing.mfg_status AS order_status
      WITH SYNONYMS ('production status', 'job status'),
    manufacturing.mfg_priority AS priority
      WITH SYNONYMS ('urgency', 'production priority'),
    -- Quality dimensions
    quality.insp_type AS inspection_type
      WITH SYNONYMS ('qc type', 'check type'),
    quality.insp_result AS inspection_result
      WITH SYNONYMS ('qc result', 'pass fail')
  )
  METRICS (
    -- Asset metrics
    assets.total_assets AS COUNT(DISTINCT asset_id)
      WITH SYNONYMS ('equipment count', 'fleet size'),
    assets.operational_count AS SUM(CASE WHEN asset_status = 'OPERATIONAL' THEN 1 ELSE 0 END)
      WITH SYNONYMS ('available equipment', 'ready assets'),
    assets.fleet_cost AS SUM(acquisition_cost)
      WITH SYNONYMS ('fleet investment', 'equipment cost'),
    assets.fleet_value AS SUM(current_value)
      WITH SYNONYMS ('current fleet value', 'equipment value'),
    assets.avg_hours AS AVG(total_flight_hours)
      WITH SYNONYMS ('mean flight time', 'average hours'),
    assets.mission_count AS SUM(total_missions)
      WITH SYNONYMS ('total missions', 'sorties flown'),
    -- Operations metrics
    operations.total_ops AS COUNT(DISTINCT operation_id)
      WITH SYNONYMS ('activity count', 'operation count'),
    operations.flight_time AS SUM(flight_hours)
      WITH SYNONYMS ('cumulative flight time', 'hours flown'),
    operations.cycle_count AS SUM(cycles)
      WITH SYNONYMS ('total cycles', 'takeoff landings'),
    operations.successful_ops AS SUM(CASE WHEN mission_success = TRUE THEN 1 ELSE 0 END)
      WITH SYNONYMS ('successful missions', 'completed operations'),
    -- Maintenance metrics
    maintenance.maint_count AS COUNT(DISTINCT maintenance_id)
      WITH SYNONYMS ('service count', 'maintenance events'),
    maintenance.maint_hours AS SUM(labor_hours)
      WITH SYNONYMS ('maintenance hours', 'work hours'),
    maintenance.parts_expense AS SUM(parts_cost)
      WITH SYNONYMS ('parts cost', 'material cost'),
    maintenance.maint_expense AS SUM(total_cost)
      WITH SYNONYMS ('service cost', 'maintenance expense'),
    -- Manufacturing metrics
    manufacturing.mfg_orders AS COUNT(DISTINCT order_id)
      WITH SYNONYMS ('production orders', 'job count'),
    manufacturing.units_ordered AS SUM(quantity_ordered)
      WITH SYNONYMS ('total ordered', 'production quantity'),
    manufacturing.units_completed AS SUM(quantity_completed)
      WITH SYNONYMS ('total completed', 'finished quantity'),
    manufacturing.units_scrapped AS SUM(quantity_scrapped)
      WITH SYNONYMS ('scrap count', 'rejected units'),
    manufacturing.mfg_cost AS SUM(total_cost)
      WITH SYNONYMS ('production cost', 'manufacturing expense'),
    -- Quality metrics
    quality.inspections AS COUNT(DISTINCT inspection_id)
      WITH SYNONYMS ('qc count', 'inspection count'),
    quality.passed AS SUM(CASE WHEN inspection_result = 'PASS' THEN 1 ELSE 0 END)
      WITH SYNONYMS ('passing inspections', 'successful qc'),
    quality.failed AS SUM(CASE WHEN inspection_result = 'FAIL' THEN 1 ELSE 0 END)
      WITH SYNONYMS ('failing inspections', 'failed qc'),
    quality.defect_count AS SUM(defects_found)
      WITH SYNONYMS ('total defects', 'quality issues'),
    quality.avg_score AS AVG(quality_score)
      WITH SYNONYMS ('mean quality score', 'average qc score')
  )
  COMMENT = 'Asset & Manufacturing Intelligence';

-- ============================================================================
-- Semantic View 3: Engineering & Support Intelligence
-- ============================================================================
-- VERIFIED COLUMNS:
--   ENGINEERING_PROJECTS: project_id, division_id, project_code, project_name,
--                         project_type, project_category, project_status, project_phase,
--                         technology_readiness_level, budget, actual_cost, team_size,
--                         patents_filed, risk_level
--   TEST_EVENTS: test_id, project_id, test_name, test_type, test_category,
--                test_status, test_result, anomalies_count
--   INCIDENTS: incident_id, division_id, incident_type, incident_category, severity,
--              incident_status, investigation_status, cost_impact, schedule_impact_days
--   EMPLOYEES: employee_id, division_id, job_title, department, employee_type,
--              security_clearance, employee_status, labor_category
--   SUPPLIERS: supplier_id, supplier_name, supplier_type, supplier_category,
--              quality_rating, delivery_rating, is_approved, is_small_business
-- ============================================================================

CREATE OR REPLACE SEMANTIC VIEW SV_ENGINEERING_SUPPORT_INTELLIGENCE
  TABLES (
    projects AS RAW.ENGINEERING_PROJECTS
      PRIMARY KEY (project_id)
      WITH SYNONYMS ('engineering projects', 'r&d projects', 'development projects'),
    tests AS RAW.TEST_EVENTS
      PRIMARY KEY (test_id)
      WITH SYNONYMS ('test events', 'evaluations', 'flight tests'),
    incidents AS RAW.INCIDENTS
      PRIMARY KEY (incident_id)
      WITH SYNONYMS ('safety incidents', 'anomalies', 'incident reports'),
    employees AS RAW.EMPLOYEES
      PRIMARY KEY (employee_id)
      WITH SYNONYMS ('workforce', 'personnel', 'staff members'),
    suppliers AS RAW.SUPPLIERS
      PRIMARY KEY (supplier_id)
      WITH SYNONYMS ('vendors', 'supply chain', 'supplier base')
  )
  RELATIONSHIPS (
    tests(project_id) REFERENCES projects(project_id)
  )
  DIMENSIONS (
    -- Engineering project dimensions
    projects.proj_id AS project_id
      WITH SYNONYMS ('eng project id', 'r&d id'),
    projects.proj_code AS project_code
      WITH SYNONYMS ('eng project code', 'r&d code'),
    projects.proj_name AS project_name
      WITH SYNONYMS ('eng project name', 'r&d project name'),
    projects.proj_type AS project_type
      WITH SYNONYMS ('eng type', 'r&d type'),
    projects.proj_category AS project_category
      WITH SYNONYMS ('eng category', 'r&d category'),
    projects.proj_status AS project_status
      WITH SYNONYMS ('eng status', 'r&d status'),
    projects.proj_phase AS project_phase
      WITH SYNONYMS ('eng phase', 'development stage'),
    projects.trl AS technology_readiness_level
      WITH SYNONYMS ('technology readiness', 'maturity level'),
    projects.proj_risk AS risk_level
      WITH SYNONYMS ('eng risk', 'project risk'),
    -- Test dimensions
    tests.tst_name AS test_name
      WITH SYNONYMS ('evaluation name', 'test event name'),
    tests.tst_type AS test_type
      WITH SYNONYMS ('evaluation type', 'test method'),
    tests.tst_category AS test_category
      WITH SYNONYMS ('test classification', 'evaluation category'),
    tests.tst_status AS test_status
      WITH SYNONYMS ('evaluation status', 'test state'),
    tests.tst_result AS test_result
      WITH SYNONYMS ('evaluation result', 'pass fail result'),
    -- Incident dimensions
    incidents.inc_type AS incident_type
      WITH SYNONYMS ('event type', 'occurrence type'),
    incidents.inc_category AS incident_category
      WITH SYNONYMS ('event category', 'occurrence category'),
    incidents.inc_severity AS severity
      WITH SYNONYMS ('criticality', 'severity level'),
    incidents.inc_status AS incident_status
      WITH SYNONYMS ('event status', 'incident state'),
    incidents.inv_status AS investigation_status
      WITH SYNONYMS ('inquiry status', 'review status'),
    -- Employee dimensions
    employees.title AS job_title
      WITH SYNONYMS ('position', 'role'),
    employees.dept AS department
      WITH SYNONYMS ('org unit', 'team'),
    employees.emp_type AS employee_type
      WITH SYNONYMS ('worker type', 'employment type'),
    employees.clearance AS security_clearance
      WITH SYNONYMS ('clearance level', 'access level'),
    employees.labor_cat AS labor_category
      WITH SYNONYMS ('job category', 'labor type'),
    -- Supplier dimensions
    suppliers.supp_name AS supplier_name
      WITH SYNONYMS ('vendor name', 'company name'),
    suppliers.supp_type AS supplier_type
      WITH SYNONYMS ('vendor type', 'supplier tier'),
    suppliers.supp_category AS supplier_category
      WITH SYNONYMS ('vendor category', 'supply category'),
    suppliers.small_bus AS is_small_business
      WITH SYNONYMS ('sb status', 'small business status')
  )
  METRICS (
    -- Engineering project metrics
    projects.total_projects AS COUNT(DISTINCT project_id)
      WITH SYNONYMS ('eng project count', 'r&d count'),
    projects.active_count AS SUM(CASE WHEN project_status = 'ACTIVE' THEN 1 ELSE 0 END)
      WITH SYNONYMS ('ongoing projects', 'current r&d'),
    projects.project_budget AS SUM(budget)
      WITH SYNONYMS ('total budget', 'r&d budget'),
    projects.project_spend AS SUM(actual_cost)
      WITH SYNONYMS ('total spend', 'r&d spend'),
    projects.total_staff AS SUM(team_size)
      WITH SYNONYMS ('headcount', 'staffing'),
    projects.patent_count AS SUM(patents_filed)
      WITH SYNONYMS ('patents', 'ip filed'),
    projects.mean_trl AS AVG(technology_readiness_level)
      WITH SYNONYMS ('average trl', 'mean readiness'),
    -- Test metrics
    tests.test_count AS COUNT(DISTINCT test_id)
      WITH SYNONYMS ('total tests', 'evaluation count'),
    tests.tests_passed AS SUM(CASE WHEN test_result = 'PASS' THEN 1 ELSE 0 END)
      WITH SYNONYMS ('successful tests', 'passing tests'),
    tests.tests_failed AS SUM(CASE WHEN test_result = 'FAIL' THEN 1 ELSE 0 END)
      WITH SYNONYMS ('unsuccessful tests', 'failing tests'),
    tests.anomaly_count AS SUM(anomalies_count)
      WITH SYNONYMS ('total anomalies', 'test issues'),
    -- Incident metrics
    incidents.incident_count AS COUNT(DISTINCT incident_id)
      WITH SYNONYMS ('total incidents', 'event count'),
    incidents.open_count AS SUM(CASE WHEN incident_status = 'OPEN' THEN 1 ELSE 0 END)
      WITH SYNONYMS ('active incidents', 'unresolved events'),
    incidents.resolved_count AS SUM(CASE WHEN incident_status IN ('RESOLVED', 'CLOSED') THEN 1 ELSE 0 END)
      WITH SYNONYMS ('closed incidents', 'resolved events'),
    incidents.cost_total AS SUM(cost_impact)
      WITH SYNONYMS ('incident cost', 'impact cost'),
    incidents.schedule_delay AS SUM(schedule_impact_days)
      WITH SYNONYMS ('total delay', 'days impacted'),
    -- Employee metrics
    employees.employee_count AS COUNT(DISTINCT employee_id)
      WITH SYNONYMS ('total employees', 'headcount total'),
    employees.active_count AS SUM(CASE WHEN employee_status = 'ACTIVE' THEN 1 ELSE 0 END)
      WITH SYNONYMS ('current employees', 'active workforce'),
    -- Supplier metrics
    suppliers.supplier_count AS COUNT(DISTINCT supplier_id)
      WITH SYNONYMS ('total vendors', 'supplier total'),
    suppliers.approved_count AS SUM(CASE WHEN is_approved = TRUE THEN 1 ELSE 0 END)
      WITH SYNONYMS ('qualified vendors', 'approved vendors'),
    suppliers.mean_quality AS AVG(quality_rating)
      WITH SYNONYMS ('supplier quality', 'vendor quality score'),
    suppliers.mean_delivery AS AVG(delivery_rating)
      WITH SYNONYMS ('supplier delivery', 'vendor delivery score'),
    suppliers.sb_count AS SUM(CASE WHEN is_small_business = TRUE THEN 1 ELSE 0 END)
      WITH SYNONYMS ('small business count', 'small business suppliers')
  )
  COMMENT = 'Engineering & Support Intelligence';

SELECT 'All semantic views created successfully' AS status;
SHOW SEMANTIC VIEWS IN SCHEMA KRATOS_INTELLIGENCE.ANALYTICS;

