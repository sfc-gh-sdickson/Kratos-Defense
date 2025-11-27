-- ============================================================================
-- Kratos Defense Intelligence Agent - Semantic Views
-- ============================================================================
-- Purpose: Create semantic views for Snowflake Intelligence agents
-- All syntax VERIFIED against official documentation and NASM template:
-- https://docs.snowflake.com/en/sql-reference/sql/create-semantic-view
-- 
-- CRITICAL SYNTAX RULE (from GENERATION_FAILURES_AND_LESSONS.md):
-- Dimensions/Metrics: <table_alias>.<semantic_name> AS <sql_expression>
--   - semantic_name = the NAME you want for the dimension/metric
--   - sql_expression = the SQL to compute it (column name or expression)
-- 
-- Clause order is MANDATORY: TABLES → RELATIONSHIPS → DIMENSIONS → METRICS → COMMENT
-- All synonyms are GLOBALLY UNIQUE across all semantic views
-- All column references VERIFIED against 02_create_tables.sql
-- ============================================================================

USE DATABASE KRATOS_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE KRATOS_WH;

-- ============================================================================
-- Semantic View 1: Program & Contract Operations Intelligence
-- ============================================================================
-- COLUMN VERIFICATION against 02_create_tables.sql:
--   PROGRAMS: program_id, division_id, program_code, program_name, program_type,
--             program_category, program_status, program_phase, security_classification,
--             start_date, planned_end_date, total_contract_value, funded_value,
--             costs_incurred, revenue_recognized, margin_percentage, program_manager,
--             technical_lead, risk_level
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
      WITH SYNONYMS ('defense programs', 'projects', 'program portfolio')
      COMMENT = 'Defense program and contract information',
    divisions AS RAW.DIVISIONS
      PRIMARY KEY (division_id)
      WITH SYNONYMS ('business units', 'segments', 'operating divisions')
      COMMENT = 'Kratos business divisions',
    customers AS RAW.CUSTOMERS
      PRIMARY KEY (customer_id)
      WITH SYNONYMS ('dod customers', 'government clients', 'military customers')
      COMMENT = 'DoD and allied customer information',
    contracts AS RAW.CONTRACTS
      PRIMARY KEY (contract_id)
      WITH SYNONYMS ('defense contracts', 'awards', 'contract awards')
      COMMENT = 'Contract details and terms',
    milestones AS RAW.MILESTONES
      PRIMARY KEY (milestone_id)
      WITH SYNONYMS ('program milestones', 'deliverables', 'schedule milestones')
      COMMENT = 'Program milestone tracking'
  )
  RELATIONSHIPS (
    programs(division_id) REFERENCES divisions(division_id),
    programs(customer_id) REFERENCES customers(customer_id),
    contracts(program_id) REFERENCES programs(program_id),
    contracts(customer_id) REFERENCES customers(customer_id),
    milestones(program_id) REFERENCES programs(program_id),
    milestones(contract_id) REFERENCES contracts(contract_id)
  )
  DIMENSIONS (
    -- Program dimensions (semantic_name AS sql_expression)
    programs.program_id AS program_id
      WITH SYNONYMS ('project id', 'program identifier')
      COMMENT = 'Unique program identifier',
    programs.program_code AS program_code
      WITH SYNONYMS ('project code', 'program number')
      COMMENT = 'Program code designation',
    programs.program_name AS program_name
      WITH SYNONYMS ('project name', 'program title')
      COMMENT = 'Full program name',
    programs.program_type AS program_type
      WITH SYNONYMS ('project type', 'contract category')
      COMMENT = 'Type: DEVELOPMENT, PRODUCTION, SUSTAINMENT, RDT&E, SERVICES',
    programs.program_status AS program_status
      WITH SYNONYMS ('project status', 'program state')
      COMMENT = 'Status: ACTIVE, COMPLETED, ON_HOLD',
    programs.program_phase AS program_phase
      WITH SYNONYMS ('project phase', 'development phase')
      COMMENT = 'Phase: PHASE_1, PHASE_2, EMD, LRIP, FRP',
    programs.security_classification AS program_classification
      WITH SYNONYMS ('classification level', 'security level')
      COMMENT = 'Security: UNCLASSIFIED, SECRET, TOP SECRET',
    programs.risk_level AS program_risk
      WITH SYNONYMS ('project risk', 'risk rating')
      COMMENT = 'Risk level: LOW, MEDIUM, HIGH',
    programs.program_manager AS program_manager
      WITH SYNONYMS ('pm', 'project manager')
      COMMENT = 'Program manager name',
    -- Division dimensions
    divisions.division_name AS division_name
      WITH SYNONYMS ('business unit', 'segment name')
      COMMENT = 'Division name',
    divisions.division_code AS division_code
      WITH SYNONYMS ('unit code', 'segment code')
      COMMENT = 'Division code',
    divisions.division_category AS division_category
      WITH SYNONYMS ('unit type', 'segment category')
      COMMENT = 'Division category',
    -- Customer dimensions
    customers.customer_name AS customer_name
      WITH SYNONYMS ('client name', 'dod agency')
      COMMENT = 'Customer organization name',
    customers.customer_type AS customer_type
      WITH SYNONYMS ('client type', 'agency type')
      COMMENT = 'Type: MILITARY_SERVICE, DEFENSE_AGENCY, INTELLIGENCE_COMMUNITY',
    customers.customer_category AS customer_category
      WITH SYNONYMS ('client category', 'contract type')
      COMMENT = 'Category: PRIME_CONTRACTOR, DIRECT_GOVERNMENT, SUBCONTRACT, FMS',
    customers.agency_branch AS agency_branch
      WITH SYNONYMS ('military branch', 'service branch')
      COMMENT = 'Branch: Air Force, Navy, Army, Space Force',
    -- Contract dimensions
    contracts.contract_number AS contract_number
      WITH SYNONYMS ('award number', 'contract id')
      COMMENT = 'Contract number',
    contracts.contract_name AS contract_name
      WITH SYNONYMS ('award name', 'contract title')
      COMMENT = 'Contract name',
    contracts.contract_type AS contract_type
      WITH SYNONYMS ('pricing type', 'award type')
      COMMENT = 'Type: CPFF, FFP, CPIF, T&M, IDIQ',
    contracts.contract_status AS contract_status
      WITH SYNONYMS ('award status', 'contract state')
      COMMENT = 'Status: ACTIVE, COMPLETED, PENDING',
    contracts.contract_vehicle AS contract_vehicle
      WITH SYNONYMS ('acquisition vehicle', 'buying vehicle')
      COMMENT = 'Vehicle: GSA Schedule, SEWP, CIO-SP3, OASIS',
    -- Milestone dimensions
    milestones.milestone_name AS milestone_name
      WITH SYNONYMS ('deliverable name', 'event name')
      COMMENT = 'Milestone name',
    milestones.milestone_type AS milestone_type
      WITH SYNONYMS ('deliverable type', 'event type')
      COMMENT = 'Type: REVIEW, DELIVERY, TEST, PRODUCTION, CONTRACTUAL',
    milestones.milestone_status AS milestone_status
      WITH SYNONYMS ('deliverable status', 'event status')
      COMMENT = 'Status: COMPLETED, ON_TRACK, AT_RISK, DELAYED, PENDING'
  )
  METRICS (
    -- Program metrics
    programs.total_programs AS COUNT(DISTINCT program_id)
      WITH SYNONYMS ('program count', 'project count')
      COMMENT = 'Total number of programs',
    programs.total_contract_value AS SUM(total_contract_value)
      WITH SYNONYMS ('program value', 'portfolio value')
      COMMENT = 'Sum of all program contract values',
    programs.total_funded_value AS SUM(funded_value)
      WITH SYNONYMS ('funded amount', 'obligated funds')
      COMMENT = 'Sum of funded amounts',
    programs.total_costs_incurred AS SUM(costs_incurred)
      WITH SYNONYMS ('costs spent', 'expenses incurred')
      COMMENT = 'Sum of costs incurred',
    programs.total_revenue_recognized AS SUM(revenue_recognized)
      WITH SYNONYMS ('revenue earned', 'recognized revenue')
      COMMENT = 'Sum of revenue recognized',
    programs.avg_margin_pct AS AVG(margin_percentage)
      WITH SYNONYMS ('average margin', 'mean profit margin')
      COMMENT = 'Average margin percentage',
    -- Contract metrics
    contracts.total_contracts AS COUNT(DISTINCT contract_id)
      WITH SYNONYMS ('contract count', 'award count')
      COMMENT = 'Total number of contracts',
    contracts.contract_base_value AS SUM(base_value)
      WITH SYNONYMS ('base contract value', 'initial award value')
      COMMENT = 'Sum of base contract values',
    contracts.contract_option_value AS SUM(option_value)
      WITH SYNONYMS ('option value', 'potential value')
      COMMENT = 'Sum of option values',
    contracts.contract_total_value AS SUM(total_value)
      WITH SYNONYMS ('total award value', 'full contract value')
      COMMENT = 'Sum of total contract values',
    contracts.contract_funded_amount AS SUM(funded_amount)
      WITH SYNONYMS ('funded contract value', 'obligated amount')
      COMMENT = 'Sum of funded contract amounts',
    -- Milestone metrics
    milestones.total_milestones AS COUNT(DISTINCT milestone_id)
      WITH SYNONYMS ('milestone count', 'deliverable count')
      COMMENT = 'Total number of milestones',
    milestones.completed_milestones AS SUM(CASE WHEN milestone_status = 'COMPLETED' THEN 1 ELSE 0 END)
      WITH SYNONYMS ('finished milestones', 'achieved deliverables')
      COMMENT = 'Number of completed milestones',
    milestones.at_risk_milestones AS SUM(CASE WHEN milestone_status IN ('AT_RISK', 'DELAYED') THEN 1 ELSE 0 END)
      WITH SYNONYMS ('problem milestones', 'delayed deliverables')
      COMMENT = 'Number of at-risk or delayed milestones'
  )
  COMMENT = 'Program & Contract Operations Intelligence - comprehensive view of programs, contracts, customers, and milestones';

-- ============================================================================
-- Semantic View 2: Asset & Manufacturing Intelligence
-- ============================================================================
-- COLUMN VERIFICATION against 02_create_tables.sql:
--   ASSETS: asset_id, division_id, program_id, asset_serial_number, asset_name,
--           asset_type, asset_category, asset_model, asset_status, operational_status,
--           location, total_flight_hours, total_missions, last_maintenance_date,
--           next_maintenance_due, acquisition_cost, current_value
--   ASSET_OPERATIONS: operation_id, asset_id, operation_date, operation_type,
--                     mission_type, flight_hours, cycles, operation_status, mission_success
--   MAINTENANCE_RECORDS: maintenance_id, asset_id, maintenance_date, maintenance_type,
--                        maintenance_category, labor_hours, parts_cost, labor_cost,
--                        total_cost, maintenance_status, quality_inspection_passed
--   MANUFACTURING_ORDERS: order_id, division_id, order_number, product_name, product_type,
--                         order_type, order_status, quantity_ordered, quantity_completed,
--                         quantity_scrapped, unit_cost, total_cost, priority
--   QUALITY_INSPECTIONS: inspection_id, inspection_date, inspection_type, inspection_result,
--                        defects_found, quality_score, corrective_action_required
-- ============================================================================

CREATE OR REPLACE SEMANTIC VIEW SV_ASSET_MANUFACTURING_INTELLIGENCE
  TABLES (
    assets AS RAW.ASSETS
      PRIMARY KEY (asset_id)
      WITH SYNONYMS ('equipment', 'unmanned systems', 'fleet assets')
      COMMENT = 'Unmanned systems, satellites, and equipment',
    operations AS RAW.ASSET_OPERATIONS
      PRIMARY KEY (operation_id)
      WITH SYNONYMS ('flights', 'missions', 'asset usage')
      COMMENT = 'Asset operation and flight records',
    maintenance AS RAW.MAINTENANCE_RECORDS
      PRIMARY KEY (maintenance_id)
      WITH SYNONYMS ('service records', 'repairs', 'maintenance history')
      COMMENT = 'Maintenance and service records',
    manufacturing AS RAW.MANUFACTURING_ORDERS
      PRIMARY KEY (order_id)
      WITH SYNONYMS ('production orders', 'work orders', 'manufacturing jobs')
      COMMENT = 'Manufacturing and production orders',
    quality AS RAW.QUALITY_INSPECTIONS
      PRIMARY KEY (inspection_id)
      WITH SYNONYMS ('qc inspections', 'quality checks', 'inspection records')
      COMMENT = 'Quality control inspections'
  )
  RELATIONSHIPS (
    operations(asset_id) REFERENCES assets(asset_id),
    maintenance(asset_id) REFERENCES assets(asset_id),
    quality(order_id) REFERENCES manufacturing(order_id),
    quality(asset_id) REFERENCES assets(asset_id)
  )
  DIMENSIONS (
    -- Asset dimensions
    assets.asset_id AS asset_id
      WITH SYNONYMS ('equipment id', 'system id')
      COMMENT = 'Unique asset identifier',
    assets.asset_serial_number AS serial_number
      WITH SYNONYMS ('sn', 'equipment serial')
      COMMENT = 'Asset serial number',
    assets.asset_name AS asset_name
      WITH SYNONYMS ('equipment name', 'system name')
      COMMENT = 'Asset name',
    assets.asset_type AS asset_type
      WITH SYNONYMS ('equipment type', 'system type')
      COMMENT = 'Type: UAV, GROUND_SYSTEM, ENGINE, ELECTRONICS, SIMULATOR',
    assets.asset_category AS asset_category
      WITH SYNONYMS ('equipment category', 'asset class')
      COMMENT = 'Category: TACTICAL, STRATEGIC, TRAINING, TEST, PRODUCTION',
    assets.asset_model AS asset_model
      WITH SYNONYMS ('equipment model', 'variant')
      COMMENT = 'Asset model designation',
    assets.asset_status AS asset_status
      WITH SYNONYMS ('equipment status', 'system condition')
      COMMENT = 'Status: OPERATIONAL, MAINTENANCE, STORAGE',
    assets.operational_status AS operational_status
      WITH SYNONYMS ('availability', 'readiness status')
      COMMENT = 'Status: AVAILABLE, DEPLOYED, TESTING, MAINTENANCE',
    assets.location AS asset_location
      WITH SYNONYMS ('equipment location', 'base location')
      COMMENT = 'Physical location of asset',
    -- Operations dimensions
    operations.operation_type AS operation_type
      WITH SYNONYMS ('activity type', 'usage type')
      COMMENT = 'Type: FLIGHT, TEST, TRAINING, MAINTENANCE_RUN, DEMONSTRATION',
    operations.mission_type AS mission_type
      WITH SYNONYMS ('flight type', 'mission category')
      COMMENT = 'Mission: RECONNAISSANCE, TARGET, LOYAL_WINGMAN, GROUND_TEST',
    operations.operation_status AS operation_status
      WITH SYNONYMS ('activity status', 'mission status')
      COMMENT = 'Status: COMPLETED, ABORTED',
    operations.mission_success AS mission_success
      WITH SYNONYMS ('successful mission', 'operation success')
      COMMENT = 'Whether mission was successful',
    -- Maintenance dimensions
    maintenance.maintenance_type AS maintenance_type
      WITH SYNONYMS ('service type', 'work type')
      COMMENT = 'Type: SCHEDULED, UNSCHEDULED, INSPECTION, OVERHAUL, MODIFICATION',
    maintenance.maintenance_category AS maintenance_category
      WITH SYNONYMS ('service category', 'maintenance area')
      COMMENT = 'Category: AIRFRAME, ENGINE, AVIONICS, PAYLOAD, GROUND_SUPPORT',
    maintenance.maintenance_status AS maintenance_status
      WITH SYNONYMS ('service status', 'work status')
      COMMENT = 'Status: COMPLETED, IN_PROGRESS',
    -- Manufacturing dimensions
    manufacturing.product_name AS product_name
      WITH SYNONYMS ('manufactured item', 'produced item')
      COMMENT = 'Product being manufactured',
    manufacturing.product_type AS product_type
      WITH SYNONYMS ('item type', 'manufactured type')
      COMMENT = 'Type: AIRFRAME, ENGINE, AVIONICS, STRUCTURES, SYSTEMS',
    manufacturing.order_type AS manufacturing_order_type
      WITH SYNONYMS ('production type', 'job type')
      COMMENT = 'Type: PRODUCTION, PROTOTYPE, SPARE_PARTS, REPAIR, MODIFICATION',
    manufacturing.order_status AS manufacturing_status
      WITH SYNONYMS ('production status', 'job status')
      COMMENT = 'Status: COMPLETED, IN_PROGRESS, PENDING, ON_HOLD',
    manufacturing.priority AS manufacturing_priority
      WITH SYNONYMS ('urgency', 'production priority')
      COMMENT = 'Priority: NORMAL, HIGH, CRITICAL, LOW',
    -- Quality dimensions
    quality.inspection_type AS inspection_type
      WITH SYNONYMS ('qc type', 'check type')
      COMMENT = 'Type: INCOMING, IN_PROCESS, FINAL, RECEIVING, FIRST_ARTICLE',
    quality.inspection_result AS inspection_result
      WITH SYNONYMS ('qc result', 'pass fail')
      COMMENT = 'Result: PASS, FAIL, CONDITIONAL'
  )
  METRICS (
    -- Asset metrics
    assets.total_assets AS COUNT(DISTINCT asset_id)
      WITH SYNONYMS ('equipment count', 'fleet size')
      COMMENT = 'Total number of assets',
    assets.operational_assets AS SUM(CASE WHEN asset_status = 'OPERATIONAL' THEN 1 ELSE 0 END)
      WITH SYNONYMS ('available equipment', 'ready assets')
      COMMENT = 'Number of operational assets',
    assets.total_acquisition_cost AS SUM(acquisition_cost)
      WITH SYNONYMS ('fleet investment', 'equipment cost')
      COMMENT = 'Sum of acquisition costs',
    assets.total_current_value AS SUM(current_value)
      WITH SYNONYMS ('fleet value', 'equipment value')
      COMMENT = 'Sum of current asset values',
    assets.avg_flight_hours AS AVG(total_flight_hours)
      WITH SYNONYMS ('mean flight time', 'average hours')
      COMMENT = 'Average flight hours per asset',
    assets.total_missions_flown AS SUM(total_missions)
      WITH SYNONYMS ('mission count', 'sorties flown')
      COMMENT = 'Total missions across fleet',
    -- Operations metrics
    operations.total_operations AS COUNT(DISTINCT operation_id)
      WITH SYNONYMS ('activity count', 'operation count')
      COMMENT = 'Total operation records',
    operations.total_flight_hours AS SUM(flight_hours)
      WITH SYNONYMS ('cumulative flight time', 'hours flown')
      COMMENT = 'Sum of flight hours',
    operations.total_cycles AS SUM(cycles)
      WITH SYNONYMS ('cycle count', 'takeoff landings')
      COMMENT = 'Sum of cycles',
    operations.successful_operations AS SUM(CASE WHEN mission_success = TRUE THEN 1 ELSE 0 END)
      WITH SYNONYMS ('successful missions', 'completed operations')
      COMMENT = 'Number of successful operations',
    -- Maintenance metrics
    maintenance.total_maintenance_records AS COUNT(DISTINCT maintenance_id)
      WITH SYNONYMS ('service count', 'maintenance events')
      COMMENT = 'Total maintenance records',
    maintenance.total_labor_hours AS SUM(labor_hours)
      WITH SYNONYMS ('maintenance hours', 'work hours')
      COMMENT = 'Sum of maintenance labor hours',
    maintenance.total_parts_cost AS SUM(parts_cost)
      WITH SYNONYMS ('parts expense', 'material cost')
      COMMENT = 'Sum of parts costs',
    maintenance.total_maintenance_cost AS SUM(total_cost)
      WITH SYNONYMS ('service cost', 'maintenance expense')
      COMMENT = 'Sum of total maintenance costs',
    -- Manufacturing metrics
    manufacturing.total_manufacturing_orders AS COUNT(DISTINCT order_id)
      WITH SYNONYMS ('production orders', 'job count')
      COMMENT = 'Total manufacturing orders',
    manufacturing.total_quantity_ordered AS SUM(quantity_ordered)
      WITH SYNONYMS ('units ordered', 'production quantity')
      COMMENT = 'Sum of quantities ordered',
    manufacturing.total_quantity_completed AS SUM(quantity_completed)
      WITH SYNONYMS ('units completed', 'finished quantity')
      COMMENT = 'Sum of quantities completed',
    manufacturing.total_quantity_scrapped AS SUM(quantity_scrapped)
      WITH SYNONYMS ('scrap count', 'rejected units')
      COMMENT = 'Sum of quantities scrapped',
    manufacturing.total_manufacturing_cost AS SUM(total_cost)
      WITH SYNONYMS ('production cost', 'manufacturing expense')
      COMMENT = 'Sum of manufacturing costs',
    -- Quality metrics
    quality.total_inspections AS COUNT(DISTINCT inspection_id)
      WITH SYNONYMS ('qc count', 'inspection count')
      COMMENT = 'Total quality inspections',
    quality.passed_inspections AS SUM(CASE WHEN inspection_result = 'PASS' THEN 1 ELSE 0 END)
      WITH SYNONYMS ('passing inspections', 'successful qc')
      COMMENT = 'Number of passed inspections',
    quality.failed_inspections AS SUM(CASE WHEN inspection_result = 'FAIL' THEN 1 ELSE 0 END)
      WITH SYNONYMS ('failing inspections', 'failed qc')
      COMMENT = 'Number of failed inspections',
    quality.total_defects AS SUM(defects_found)
      WITH SYNONYMS ('defect count', 'quality issues')
      COMMENT = 'Sum of defects found',
    quality.avg_quality_score AS AVG(quality_score)
      WITH SYNONYMS ('mean quality score', 'average qc score')
      COMMENT = 'Average quality inspection score'
  )
  COMMENT = 'Asset & Manufacturing Intelligence - comprehensive view of assets, operations, maintenance, manufacturing, and quality';

-- ============================================================================
-- Semantic View 3: Engineering & Support Intelligence
-- ============================================================================
-- COLUMN VERIFICATION against 02_create_tables.sql:
--   ENGINEERING_PROJECTS: project_id, division_id, project_code, project_name,
--                         project_type, project_category, project_status, project_phase,
--                         technology_readiness_level, budget, actual_cost, team_size,
--                         ip_generated, patents_filed, risk_level
--   TEST_EVENTS: test_id, project_id, asset_id, test_name, test_type, test_category,
--                test_date, test_status, test_result, success_criteria_met, anomalies_count
--   INCIDENTS: incident_id, division_id, incident_number, incident_date, incident_type,
--              incident_category, severity, incident_status, investigation_status,
--              cost_impact, schedule_impact_days, customer_notified
--   EMPLOYEES: employee_id, division_id, first_name, last_name, job_title, department,
--              employee_type, security_clearance, employee_status, labor_category
--   SUPPLIERS: supplier_id, supplier_name, supplier_type, supplier_category,
--              quality_rating, delivery_rating, is_approved, is_small_business
-- ============================================================================

CREATE OR REPLACE SEMANTIC VIEW SV_ENGINEERING_SUPPORT_INTELLIGENCE
  TABLES (
    projects AS RAW.ENGINEERING_PROJECTS
      PRIMARY KEY (project_id)
      WITH SYNONYMS ('engineering projects', 'r&d projects', 'development projects')
      COMMENT = 'Engineering and R&D project information',
    tests AS RAW.TEST_EVENTS
      PRIMARY KEY (test_id)
      WITH SYNONYMS ('test events', 'evaluations', 'flight tests')
      COMMENT = 'Test and evaluation records',
    incidents AS RAW.INCIDENTS
      PRIMARY KEY (incident_id)
      WITH SYNONYMS ('safety incidents', 'anomalies', 'incident reports')
      COMMENT = 'Safety and operational incidents',
    employees AS RAW.EMPLOYEES
      PRIMARY KEY (employee_id)
      WITH SYNONYMS ('workforce', 'personnel', 'staff members')
      COMMENT = 'Employee and personnel records',
    suppliers AS RAW.SUPPLIERS
      PRIMARY KEY (supplier_id)
      WITH SYNONYMS ('vendors', 'supply chain', 'supplier base')
      COMMENT = 'Supplier and vendor information'
  )
  RELATIONSHIPS (
    tests(project_id) REFERENCES projects(project_id)
  )
  DIMENSIONS (
    -- Engineering project dimensions
    projects.project_id AS project_id
      WITH SYNONYMS ('eng project id', 'r&d id')
      COMMENT = 'Unique project identifier',
    projects.project_code AS project_code
      WITH SYNONYMS ('eng project code', 'r&d code')
      COMMENT = 'Project code',
    projects.project_name AS project_name
      WITH SYNONYMS ('eng project name', 'r&d project name')
      COMMENT = 'Project name',
    projects.project_type AS project_type
      WITH SYNONYMS ('eng type', 'r&d type')
      COMMENT = 'Type: R&D, IRAD, CRAD, PRODUCTION_IMPROVEMENT, SUSTAINMENT',
    projects.project_category AS project_category
      WITH SYNONYMS ('eng category', 'r&d category')
      COMMENT = 'Category: ADVANCED_TECH, MANUFACTURING, SOFTWARE, SYSTEMS, TESTING',
    projects.project_status AS project_status
      WITH SYNONYMS ('eng status', 'r&d status')
      COMMENT = 'Status: ACTIVE, COMPLETED, ON_HOLD',
    projects.project_phase AS project_phase
      WITH SYNONYMS ('eng phase', 'development stage')
      COMMENT = 'Phase: CONCEPT, DESIGN, DEVELOPMENT, TEST, PRODUCTION',
    projects.technology_readiness_level AS trl
      WITH SYNONYMS ('technology readiness', 'maturity level')
      COMMENT = 'Technology Readiness Level (1-9)',
    projects.risk_level AS project_risk_level
      WITH SYNONYMS ('eng risk', 'project risk')
      COMMENT = 'Risk level: LOW, MEDIUM, HIGH',
    -- Test dimensions
    tests.test_name AS test_name
      WITH SYNONYMS ('evaluation name', 'test event name')
      COMMENT = 'Test event name',
    tests.test_type AS test_type
      WITH SYNONYMS ('evaluation type', 'test category')
      COMMENT = 'Type: FLIGHT, GROUND, LAB, ENVIRONMENTAL, INTEGRATION',
    tests.test_category AS test_category
      WITH SYNONYMS ('test classification', 'evaluation category')
      COMMENT = 'Category: DEVELOPMENT, QUALIFICATION, ACCEPTANCE, REGRESSION',
    tests.test_status AS test_status
      WITH SYNONYMS ('evaluation status', 'test state')
      COMMENT = 'Status: COMPLETED, ABORTED',
    tests.test_result AS test_result
      WITH SYNONYMS ('evaluation result', 'pass fail result')
      COMMENT = 'Result: PASS, FAIL, CONDITIONAL',
    -- Incident dimensions
    incidents.incident_type AS incident_type
      WITH SYNONYMS ('event type', 'occurrence type')
      COMMENT = 'Type: SAFETY, QUALITY, OPERATIONAL, SECURITY, ENVIRONMENTAL',
    incidents.incident_category AS incident_category
      WITH SYNONYMS ('event category', 'occurrence category')
      COMMENT = 'Category: EQUIPMENT_FAILURE, HUMAN_ERROR, PROCESS_DEVIATION, NEAR_MISS',
    incidents.severity AS incident_severity
      WITH SYNONYMS ('criticality', 'severity level')
      COMMENT = 'Severity: LOW, MEDIUM, HIGH, CRITICAL',
    incidents.incident_status AS incident_status
      WITH SYNONYMS ('event status', 'incident state')
      COMMENT = 'Status: OPEN, INVESTIGATING, RESOLVED, CLOSED',
    incidents.investigation_status AS investigation_status
      WITH SYNONYMS ('inquiry status', 'review status')
      COMMENT = 'Status: PENDING, IN_PROGRESS, COMPLETED',
    -- Employee dimensions
    employees.job_title AS job_title
      WITH SYNONYMS ('position', 'role')
      COMMENT = 'Employee job title',
    employees.department AS department
      WITH SYNONYMS ('org unit', 'team')
      COMMENT = 'Department: Engineering, Manufacturing, Quality, Programs, Operations',
    employees.employee_type AS employee_type
      WITH SYNONYMS ('worker type', 'employment type')
      COMMENT = 'Type: FULL_TIME, CONTRACTOR',
    employees.security_clearance AS clearance_level
      WITH SYNONYMS ('clearance', 'access level')
      COMMENT = 'Clearance: SECRET, TOP SECRET, TOP SECRET/SCI, CONFIDENTIAL',
    employees.labor_category AS labor_category
      WITH SYNONYMS ('job category', 'labor type')
      COMMENT = 'Category: ENGINEER, TECHNICIAN, MANAGER, SPECIALIST, ANALYST',
    -- Supplier dimensions
    suppliers.supplier_name AS supplier_name
      WITH SYNONYMS ('vendor name', 'company name')
      COMMENT = 'Supplier company name',
    suppliers.supplier_type AS supplier_type
      WITH SYNONYMS ('vendor type', 'supplier tier')
      COMMENT = 'Type: TIER_1, TIER_2, TIER_3, DISTRIBUTOR, OEM',
    suppliers.supplier_category AS supplier_category
      WITH SYNONYMS ('vendor category', 'supply category')
      COMMENT = 'Category: AEROSPACE, ELECTRONICS, MATERIALS, SERVICES, MANUFACTURING',
    suppliers.is_small_business AS small_business
      WITH SYNONYMS ('sb status', 'small business status')
      COMMENT = 'Whether supplier is small business'
  )
  METRICS (
    -- Engineering project metrics
    projects.total_projects AS COUNT(DISTINCT project_id)
      WITH SYNONYMS ('eng project count', 'r&d count')
      COMMENT = 'Total engineering projects',
    projects.active_projects AS SUM(CASE WHEN project_status = 'ACTIVE' THEN 1 ELSE 0 END)
      WITH SYNONYMS ('ongoing projects', 'current r&d')
      COMMENT = 'Number of active projects',
    projects.total_budget AS SUM(budget)
      WITH SYNONYMS ('project budget', 'r&d budget')
      COMMENT = 'Sum of project budgets',
    projects.total_actual_cost AS SUM(actual_cost)
      WITH SYNONYMS ('project spend', 'r&d spend')
      COMMENT = 'Sum of actual costs',
    projects.total_team_size AS SUM(team_size)
      WITH SYNONYMS ('headcount', 'staffing')
      COMMENT = 'Sum of team sizes',
    projects.total_patents AS SUM(patents_filed)
      WITH SYNONYMS ('patent count', 'ip filed')
      COMMENT = 'Sum of patents filed',
    projects.avg_trl AS AVG(technology_readiness_level)
      WITH SYNONYMS ('average trl', 'mean readiness')
      COMMENT = 'Average technology readiness level',
    -- Test metrics
    tests.total_tests AS COUNT(DISTINCT test_id)
      WITH SYNONYMS ('test count', 'evaluation count')
      COMMENT = 'Total test events',
    tests.passed_tests AS SUM(CASE WHEN test_result = 'PASS' THEN 1 ELSE 0 END)
      WITH SYNONYMS ('successful tests', 'passing tests')
      COMMENT = 'Number of passed tests',
    tests.failed_tests AS SUM(CASE WHEN test_result = 'FAIL' THEN 1 ELSE 0 END)
      WITH SYNONYMS ('unsuccessful tests', 'failing tests')
      COMMENT = 'Number of failed tests',
    tests.total_anomalies AS SUM(anomalies_count)
      WITH SYNONYMS ('anomaly count', 'test issues')
      COMMENT = 'Sum of anomalies detected',
    -- Incident metrics
    incidents.total_incidents AS COUNT(DISTINCT incident_id)
      WITH SYNONYMS ('incident count', 'event count')
      COMMENT = 'Total incidents',
    incidents.open_incidents AS SUM(CASE WHEN incident_status = 'OPEN' THEN 1 ELSE 0 END)
      WITH SYNONYMS ('active incidents', 'unresolved events')
      COMMENT = 'Number of open incidents',
    incidents.resolved_incidents AS SUM(CASE WHEN incident_status IN ('RESOLVED', 'CLOSED') THEN 1 ELSE 0 END)
      WITH SYNONYMS ('closed incidents', 'resolved events')
      COMMENT = 'Number of resolved incidents',
    incidents.total_cost_impact AS SUM(cost_impact)
      WITH SYNONYMS ('incident cost', 'impact cost')
      COMMENT = 'Sum of cost impacts',
    incidents.total_schedule_impact AS SUM(schedule_impact_days)
      WITH SYNONYMS ('schedule delay', 'days impacted')
      COMMENT = 'Sum of schedule impact days',
    -- Employee metrics
    employees.total_employees AS COUNT(DISTINCT employee_id)
      WITH SYNONYMS ('employee count', 'headcount total')
      COMMENT = 'Total employees',
    employees.active_employees AS SUM(CASE WHEN employee_status = 'ACTIVE' THEN 1 ELSE 0 END)
      WITH SYNONYMS ('current employees', 'active workforce')
      COMMENT = 'Number of active employees',
    -- Supplier metrics
    suppliers.total_suppliers AS COUNT(DISTINCT supplier_id)
      WITH SYNONYMS ('vendor count', 'supplier count')
      COMMENT = 'Total suppliers',
    suppliers.approved_suppliers AS SUM(CASE WHEN is_approved = TRUE THEN 1 ELSE 0 END)
      WITH SYNONYMS ('qualified vendors', 'approved vendors')
      COMMENT = 'Number of approved suppliers',
    suppliers.avg_quality_rating AS AVG(quality_rating)
      WITH SYNONYMS ('supplier quality', 'vendor quality score')
      COMMENT = 'Average supplier quality rating',
    suppliers.avg_delivery_rating AS AVG(delivery_rating)
      WITH SYNONYMS ('supplier delivery', 'vendor delivery score')
      COMMENT = 'Average supplier delivery rating',
    suppliers.small_business_count AS SUM(CASE WHEN is_small_business = TRUE THEN 1 ELSE 0 END)
      WITH SYNONYMS ('sb count', 'small business suppliers')
      COMMENT = 'Number of small business suppliers'
  )
  COMMENT = 'Engineering & Support Intelligence - comprehensive view of engineering projects, testing, incidents, employees, and suppliers';

-- ============================================================================
-- Display confirmation
-- ============================================================================
SELECT 'All semantic views created successfully' AS status;

SHOW SEMANTIC VIEWS IN SCHEMA KRATOS_INTELLIGENCE.ANALYTICS;


