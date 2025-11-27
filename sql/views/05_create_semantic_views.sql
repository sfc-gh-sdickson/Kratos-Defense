-- ============================================================================
-- Kratos Defense Intelligence Agent - Semantic Views
-- ============================================================================
-- Purpose: Create semantic views for Snowflake Intelligence agents
-- All syntax VERIFIED against official documentation:
-- https://docs.snowflake.com/en/sql-reference/sql/create-semantic-view
-- 
-- CRITICAL SYNTAX RULE:
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
-- Semantic View 1: Program & Contract Intelligence
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_PROGRAM_CONTRACT_INTELLIGENCE
  TABLES (
    programs AS RAW.PROGRAMS
      PRIMARY KEY (program_id)
      WITH SYNONYMS ('defense programs', 'projects', 'program initiatives')
      COMMENT = 'Defense program portfolio and project information',
    contracts AS RAW.CONTRACTS
      PRIMARY KEY (contract_id)
      WITH SYNONYMS ('defense contracts', 'awards', 'contract awards')
      COMMENT = 'Contract details and financial data',
    divisions AS RAW.DIVISIONS
      PRIMARY KEY (division_id)
      WITH SYNONYMS ('business divisions', 'business units', 'organizational units')
      COMMENT = 'Company division structure',
    milestones AS RAW.MILESTONES
      PRIMARY KEY (milestone_id)
      WITH SYNONYMS ('program milestones', 'deliverables', 'program deliverables')
      COMMENT = 'Program milestone tracking',
    employees AS RAW.EMPLOYEES
      PRIMARY KEY (employee_id)
      WITH SYNONYMS ('program managers', 'staff', 'personnel')
      COMMENT = 'Employee records for program assignments'
  )
  RELATIONSHIPS (
    programs(division_id) REFERENCES divisions(division_id),
    programs(program_manager_id) REFERENCES employees(employee_id),
    contracts(program_id) REFERENCES programs(program_id),
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
      COMMENT = 'Program code',
    programs.program_name AS program_name
      WITH SYNONYMS ('project name', 'initiative name')
      COMMENT = 'Program name',
    programs.program_type AS program_type
      WITH SYNONYMS ('project type', 'initiative type')
      COMMENT = 'Type: DEVELOPMENT, PRODUCTION, SUSTAINMENT, RDT&E',
    programs.program_status AS program_status
      WITH SYNONYMS ('project status', 'initiative status')
      COMMENT = 'Status: ACTIVE, COMPLETED, ON_HOLD, PLANNING, CANCELLED',
    programs.program_customer AS customer
      WITH SYNONYMS ('client', 'government customer')
      COMMENT = 'Customer name (DoD branch, agency)',
    programs.program_risk AS risk_level
      WITH SYNONYMS ('risk rating', 'program risk')
      COMMENT = 'Risk level: LOW, MEDIUM, HIGH, CRITICAL',
    programs.program_priority AS priority_level
      WITH SYNONYMS ('priority', 'urgency')
      COMMENT = 'Priority: STANDARD, HIGH, CRITICAL, URGENT',
    programs.classification AS classification_level
      WITH SYNONYMS ('security classification', 'clearance level')
      COMMENT = 'Classification: UNCLASSIFIED, CONFIDENTIAL, SECRET, TOP SECRET',
    -- Contract dimensions
    contracts.contract_number AS contract_number
      WITH SYNONYMS ('award number', 'contract id number')
      COMMENT = 'Official contract number',
    contracts.contract_name AS contract_name
      WITH SYNONYMS ('award name', 'contract title')
      COMMENT = 'Contract name/title',
    contracts.contract_type AS contract_type
      WITH SYNONYMS ('award type', 'pricing type')
      COMMENT = 'Type: FIRM_FIXED_PRICE, COST_PLUS_FIXED_FEE, T&M, IDIQ',
    contracts.contract_status AS contract_status
      WITH SYNONYMS ('award status', 'contract state')
      COMMENT = 'Status: ACTIVE, COMPLETED, AWARDED, NEGOTIATION, CLOSED',
    contracts.is_classified AS is_classified
      WITH SYNONYMS ('classified contract', 'security contract')
      COMMENT = 'Whether contract is classified',
    -- Division dimensions
    divisions.division_name AS division_name
      WITH SYNONYMS ('business unit name', 'organization name')
      COMMENT = 'Division name',
    divisions.division_category AS division_category
      WITH SYNONYMS ('unit category', 'division type')
      COMMENT = 'Category: CORE, SPECIALTY, SUPPORT',
    -- Milestone dimensions
    milestones.milestone_name AS milestone_name
      WITH SYNONYMS ('deliverable name', 'milestone title')
      COMMENT = 'Milestone name',
    milestones.milestone_status AS milestone_status
      WITH SYNONYMS ('deliverable status', 'milestone state')
      COMMENT = 'Status: COMPLETED, PENDING, IN_PROGRESS, AT_RISK',
    milestones.is_critical AS is_critical_milestone
      WITH SYNONYMS ('critical path', 'key milestone')
      COMMENT = 'Whether milestone is on critical path'
  )
  METRICS (
    -- Program metrics (semantic_name AS aggregation_expression)
    programs.total_programs AS COUNT(DISTINCT program_id)
      WITH SYNONYMS ('program count', 'project count')
      COMMENT = 'Total number of programs',
    programs.total_budget AS SUM(budget_amount)
      WITH SYNONYMS ('total program budget', 'aggregate budget')
      COMMENT = 'Sum of all program budgets',
    programs.total_spent AS SUM(spent_amount)
      WITH SYNONYMS ('total spending', 'aggregate expenditure')
      COMMENT = 'Sum of all program spending',
    programs.avg_percent_complete AS AVG(percent_complete)
      WITH SYNONYMS ('average completion', 'mean progress')
      COMMENT = 'Average program completion percentage',
    programs.avg_budget_variance AS AVG(budget_variance)
      WITH SYNONYMS ('average cost variance', 'mean budget deviation')
      COMMENT = 'Average budget variance across programs',
    programs.avg_schedule_variance AS AVG(schedule_variance_days)
      WITH SYNONYMS ('average schedule slip', 'mean schedule deviation')
      COMMENT = 'Average schedule variance in days',
    programs.active_programs AS SUM(CASE WHEN program_status = 'ACTIVE' THEN 1 ELSE 0 END)
      WITH SYNONYMS ('active project count', 'ongoing programs')
      COMMENT = 'Count of active programs',
    programs.high_risk_programs AS SUM(CASE WHEN risk_level IN ('HIGH', 'CRITICAL') THEN 1 ELSE 0 END)
      WITH SYNONYMS ('at-risk programs', 'troubled projects')
      COMMENT = 'Count of high/critical risk programs',
    -- Contract metrics
    contracts.total_contracts AS COUNT(DISTINCT contract_id)
      WITH SYNONYMS ('contract count', 'award count')
      COMMENT = 'Total number of contracts',
    contracts.total_contract_value AS SUM(base_value)
      WITH SYNONYMS ('total base value', 'aggregate contract value')
      COMMENT = 'Sum of contract base values',
    contracts.total_ceiling_value AS SUM(ceiling_value)
      WITH SYNONYMS ('total ceiling', 'maximum contract value')
      COMMENT = 'Sum of contract ceiling values',
    contracts.total_funded AS SUM(funded_value)
      WITH SYNONYMS ('total funding', 'aggregate funded value')
      COMMENT = 'Sum of funded amounts',
    contracts.total_billed AS SUM(billed_amount)
      WITH SYNONYMS ('total billings', 'aggregate billed')
      COMMENT = 'Sum of billed amounts',
    contracts.avg_performance_rating AS AVG(performance_rating)
      WITH SYNONYMS ('average cpars', 'mean contract rating')
      COMMENT = 'Average contract performance rating',
    -- Milestone metrics
    milestones.total_milestones AS COUNT(DISTINCT milestone_id)
      WITH SYNONYMS ('milestone count', 'deliverable count')
      COMMENT = 'Total number of milestones',
    milestones.completed_milestones AS SUM(CASE WHEN milestone_status = 'COMPLETED' THEN 1 ELSE 0 END)
      WITH SYNONYMS ('milestones done', 'completed deliverables')
      COMMENT = 'Number of completed milestones',
    milestones.at_risk_milestones AS SUM(CASE WHEN milestone_status = 'AT_RISK' THEN 1 ELSE 0 END)
      WITH SYNONYMS ('endangered milestones', 'at-risk deliverables')
      COMMENT = 'Number of at-risk milestones',
    milestones.total_milestone_value AS SUM(payment_amount)
      WITH SYNONYMS ('milestone payment total', 'deliverable value')
      COMMENT = 'Sum of milestone payment amounts'
  )
  COMMENT = 'Program & Contract Intelligence - comprehensive view of programs, contracts, divisions, and milestones';

-- ============================================================================
-- Semantic View 2: Asset & Maintenance Intelligence
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_ASSET_MAINTENANCE_INTELLIGENCE
  TABLES (
    assets AS RAW.ASSETS
      PRIMARY KEY (asset_id)
      WITH SYNONYMS ('defense assets', 'equipment', 'hardware')
      COMMENT = 'Asset inventory and status',
    maintenance AS RAW.MAINTENANCE_RECORDS
      PRIMARY KEY (maintenance_id)
      WITH SYNONYMS ('maintenance records', 'service records', 'repair history')
      COMMENT = 'Asset maintenance history',
    quality AS RAW.QUALITY_INSPECTIONS
      PRIMARY KEY (inspection_id)
      WITH SYNONYMS ('quality checks', 'inspections', 'qa records')
      COMMENT = 'Quality inspection records',
    programs AS RAW.PROGRAMS
      PRIMARY KEY (program_id)
      WITH SYNONYMS ('asset programs', 'assigned programs', 'program assignments')
      COMMENT = 'Programs assets are assigned to'
  )
  RELATIONSHIPS (
    assets(program_id) REFERENCES programs(program_id),
    maintenance(asset_id) REFERENCES assets(asset_id),
    quality(asset_id) REFERENCES assets(asset_id),
    quality(program_id) REFERENCES programs(program_id)
  )
  DIMENSIONS (
    -- Asset dimensions
    assets.asset_id AS asset_id
      WITH SYNONYMS ('equipment id', 'hardware id')
      COMMENT = 'Unique asset identifier',
    assets.asset_tag AS asset_tag
      WITH SYNONYMS ('equipment tag', 'asset number')
      COMMENT = 'Asset tag number',
    assets.asset_name AS asset_name
      WITH SYNONYMS ('equipment name', 'hardware name')
      COMMENT = 'Asset name/description',
    assets.asset_type AS asset_type
      WITH SYNONYMS ('equipment type', 'hardware category')
      COMMENT = 'Type: AIRCRAFT, VEHICLE, EQUIPMENT, ELECTRONICS, WEAPON_SYSTEM',
    assets.asset_status AS asset_status
      WITH SYNONYMS ('equipment status', 'operational status')
      COMMENT = 'Status: OPERATIONAL, MAINTENANCE, STANDBY, REPAIR, RETIRED',
    assets.asset_manufacturer AS manufacturer
      WITH SYNONYMS ('equipment maker', 'vendor')
      COMMENT = 'Asset manufacturer',
    assets.asset_location AS assigned_location
      WITH SYNONYMS ('equipment location', 'site location')
      COMMENT = 'Current asset location',
    assets.asset_condition AS condition_rating
      WITH SYNONYMS ('equipment condition', 'asset health')
      COMMENT = 'Condition: EXCELLENT, GOOD, FAIR, POOR',
    assets.mission_ready AS mission_ready
      WITH SYNONYMS ('combat ready', 'deployment ready')
      COMMENT = 'Whether asset is mission ready',
    -- Maintenance dimensions
    maintenance.maintenance_type AS maintenance_type
      WITH SYNONYMS ('service type', 'repair type')
      COMMENT = 'Type: SCHEDULED, UNSCHEDULED, PREVENTIVE, CORRECTIVE, OVERHAUL',
    maintenance.maintenance_category AS maintenance_category
      WITH SYNONYMS ('service category', 'work category')
      COMMENT = 'Category: INSPECTION, REPAIR, REPLACEMENT, CALIBRATION',
    maintenance.maintenance_status AS maintenance_status
      WITH SYNONYMS ('service status', 'work status')
      COMMENT = 'Status: COMPLETED, IN_PROGRESS, SCHEDULED, CANCELLED',
    maintenance.maintenance_priority AS priority
      WITH SYNONYMS ('service priority', 'work priority')
      COMMENT = 'Priority: LOW, MEDIUM, HIGH, CRITICAL',
    -- Quality dimensions
    quality.inspection_type AS inspection_type
      WITH SYNONYMS ('qa type', 'check type')
      COMMENT = 'Type: RECEIVING, IN_PROCESS, FINAL, SOURCE, FIRST_ARTICLE',
    quality.inspection_status AS inspection_status
      WITH SYNONYMS ('qa status', 'check status')
      COMMENT = 'Status: COMPLETED, IN_PROGRESS, PENDING',
    quality.inspection_passed AS passed
      WITH SYNONYMS ('qa passed', 'inspection passed')
      COMMENT = 'Whether inspection passed'
  )
  METRICS (
    -- Asset metrics
    assets.total_assets AS COUNT(DISTINCT asset_id)
      WITH SYNONYMS ('asset count', 'equipment count')
      COMMENT = 'Total number of assets',
    assets.operational_assets AS SUM(CASE WHEN asset_status = 'OPERATIONAL' THEN 1 ELSE 0 END)
      WITH SYNONYMS ('operational count', 'ready assets')
      COMMENT = 'Count of operational assets',
    assets.mission_ready_assets AS SUM(CASE WHEN mission_ready = TRUE THEN 1 ELSE 0 END)
      WITH SYNONYMS ('deployable assets', 'combat ready count')
      COMMENT = 'Count of mission-ready assets',
    assets.total_acquisition_cost AS SUM(acquisition_cost)
      WITH SYNONYMS ('total asset cost', 'equipment investment')
      COMMENT = 'Sum of asset acquisition costs',
    assets.total_current_value AS SUM(current_value)
      WITH SYNONYMS ('current asset value', 'book value')
      COMMENT = 'Sum of current asset values',
    assets.avg_flight_hours AS AVG(total_flight_hours)
      WITH SYNONYMS ('average usage hours', 'mean operating hours')
      COMMENT = 'Average flight/operating hours per asset',
    -- Maintenance metrics
    maintenance.total_maintenance_records AS COUNT(DISTINCT maintenance_id)
      WITH SYNONYMS ('maintenance count', 'service record count')
      COMMENT = 'Total maintenance records',
    maintenance.completed_maintenance AS SUM(CASE WHEN maintenance_status = 'COMPLETED' THEN 1 ELSE 0 END)
      WITH SYNONYMS ('completed services', 'finished maintenance')
      COMMENT = 'Number of completed maintenance actions',
    maintenance.total_labor_hours AS SUM(labor_hours)
      WITH SYNONYMS ('maintenance labor', 'service hours')
      COMMENT = 'Sum of maintenance labor hours',
    maintenance.total_parts_cost AS SUM(parts_cost)
      WITH SYNONYMS ('parts spending', 'component cost')
      COMMENT = 'Sum of parts costs',
    maintenance.total_labor_cost AS SUM(labor_cost)
      WITH SYNONYMS ('labor spending', 'workforce cost')
      COMMENT = 'Sum of labor costs',
    maintenance.total_maintenance_cost AS SUM(total_cost)
      WITH SYNONYMS ('maintenance spending', 'service cost total')
      COMMENT = 'Total maintenance costs',
    maintenance.avg_downtime AS AVG(downtime_hours)
      WITH SYNONYMS ('average downtime', 'mean outage hours')
      COMMENT = 'Average downtime hours per maintenance event',
    maintenance.unscheduled_maintenance AS SUM(CASE WHEN is_unscheduled = TRUE THEN 1 ELSE 0 END)
      WITH SYNONYMS ('emergency repairs', 'unplanned maintenance')
      COMMENT = 'Count of unscheduled maintenance events',
    -- Quality metrics
    quality.total_inspections AS COUNT(DISTINCT inspection_id)
      WITH SYNONYMS ('inspection count', 'qa count')
      COMMENT = 'Total inspections performed',
    quality.passed_inspections AS SUM(CASE WHEN passed = TRUE THEN 1 ELSE 0 END)
      WITH SYNONYMS ('passing inspections', 'qa passes')
      COMMENT = 'Number of passed inspections',
    quality.avg_compliance_score AS AVG(compliance_score)
      WITH SYNONYMS ('average compliance', 'mean compliance')
      COMMENT = 'Average compliance score',
    quality.avg_quality_score AS AVG(quality_score)
      WITH SYNONYMS ('average quality', 'mean quality')
      COMMENT = 'Average quality score',
    quality.total_findings AS SUM(findings_count)
      WITH SYNONYMS ('finding count', 'defect count')
      COMMENT = 'Total inspection findings',
    quality.critical_findings AS SUM(critical_findings)
      WITH SYNONYMS ('critical defects', 'major findings')
      COMMENT = 'Total critical findings'
  )
  COMMENT = 'Asset & Maintenance Intelligence - comprehensive view of assets, maintenance, and quality';

-- ============================================================================
-- Semantic View 3: Supplier & Procurement Intelligence
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_SUPPLIER_PROCUREMENT_INTELLIGENCE
  TABLES (
    suppliers AS RAW.SUPPLIERS
      PRIMARY KEY (supplier_id)
      WITH SYNONYMS ('vendors', 'subcontractors', 'supply chain partners')
      COMMENT = 'Supplier master data',
    purchase_orders AS RAW.PURCHASE_ORDERS
      PRIMARY KEY (po_id)
      WITH SYNONYMS ('purchase orders', 'pos', 'procurement orders')
      COMMENT = 'Purchase order transactions',
    proposals AS RAW.PROPOSALS
      PRIMARY KEY (proposal_id)
      WITH SYNONYMS ('bids', 'solicitation responses', 'business proposals')
      COMMENT = 'Proposal pipeline data',
    service_agreements AS RAW.SERVICE_AGREEMENTS
      PRIMARY KEY (agreement_id)
      WITH SYNONYMS ('service contracts', 'support agreements', 'maintenance agreements')
      COMMENT = 'Service agreement data'
  )
  RELATIONSHIPS (
    purchase_orders(supplier_id) REFERENCES suppliers(supplier_id)
  )
  DIMENSIONS (
    -- Supplier dimensions
    suppliers.supplier_id AS supplier_id
      WITH SYNONYMS ('vendor id', 'subcontractor id')
      COMMENT = 'Unique supplier identifier',
    suppliers.supplier_name AS supplier_name
      WITH SYNONYMS ('vendor name', 'subcontractor name')
      COMMENT = 'Supplier company name',
    suppliers.supplier_type AS supplier_type
      WITH SYNONYMS ('vendor type', 'tier level')
      COMMENT = 'Type: TIER_1, TIER_2, TIER_3, DISTRIBUTOR, SERVICE_PROVIDER',
    suppliers.supplier_status AS supplier_status
      WITH SYNONYMS ('vendor status', 'supplier state')
      COMMENT = 'Status: ACTIVE, PREFERRED, PROBATION, INACTIVE, SUSPENDED',
    suppliers.supplier_risk AS risk_rating
      WITH SYNONYMS ('vendor risk', 'supplier risk level')
      COMMENT = 'Risk rating: LOW, MEDIUM, HIGH, CRITICAL',
    suppliers.supplier_city AS city
      WITH SYNONYMS ('vendor city', 'supplier location city')
      COMMENT = 'Supplier city',
    suppliers.supplier_state AS state
      WITH SYNONYMS ('vendor state', 'supplier location state')
      COMMENT = 'Supplier state',
    suppliers.small_business AS is_small_business
      WITH SYNONYMS ('small business supplier', 'sb vendor')
      COMMENT = 'Whether supplier is small business',
    suppliers.woman_owned AS is_woman_owned
      WITH SYNONYMS ('wosb', 'woman owned business')
      COMMENT = 'Whether supplier is woman-owned',
    suppliers.veteran_owned AS is_veteran_owned
      WITH SYNONYMS ('sdvosb', 'veteran owned business')
      COMMENT = 'Whether supplier is veteran-owned',
    -- Purchase order dimensions
    purchase_orders.po_number AS po_number
      WITH SYNONYMS ('purchase order number', 'order number')
      COMMENT = 'Purchase order number',
    purchase_orders.po_status AS po_status
      WITH SYNONYMS ('order status', 'po state')
      COMMENT = 'Status: OPEN, RECEIVED, CLOSED, CANCELLED',
    purchase_orders.payment_status AS payment_status
      WITH SYNONYMS ('invoice status', 'billing status')
      COMMENT = 'Payment status: PAID, PARTIAL, UNPAID',
    -- Proposal dimensions
    proposals.proposal_name AS proposal_name
      WITH SYNONYMS ('bid name', 'opportunity name')
      COMMENT = 'Proposal name',
    proposals.proposal_status AS proposal_status
      WITH SYNONYMS ('bid status', 'opportunity status')
      COMMENT = 'Status: IN_PROGRESS, SUBMITTED, WON, LOST, PENDING_DECISION',
    proposals.proposal_type AS proposal_type
      WITH SYNONYMS ('bid type', 'opportunity type')
      COMMENT = 'Type: COMPETITIVE, SOLE_SOURCE, UNSOLICITED, RECOMPETE',
    proposals.proposal_result AS result
      WITH SYNONYMS ('bid outcome', 'award result')
      COMMENT = 'Result: WIN, LOSS, NO_BID',
    -- Service agreement dimensions
    service_agreements.agreement_name AS agreement_name
      WITH SYNONYMS ('service contract name', 'support contract name')
      COMMENT = 'Service agreement name',
    service_agreements.agreement_status AS agreement_status
      WITH SYNONYMS ('service status', 'support status')
      COMMENT = 'Status: ACTIVE, EXPIRED, PENDING_RENEWAL',
    service_agreements.agreement_type AS agreement_type
      WITH SYNONYMS ('service type', 'support type')
      COMMENT = 'Type: MAINTENANCE, SUPPORT, TRAINING, LOGISTICS, ENGINEERING'
  )
  METRICS (
    -- Supplier metrics
    suppliers.total_suppliers AS COUNT(DISTINCT supplier_id)
      WITH SYNONYMS ('vendor count', 'subcontractor count')
      COMMENT = 'Total number of suppliers',
    suppliers.active_suppliers AS SUM(CASE WHEN supplier_status = 'ACTIVE' THEN 1 ELSE 0 END)
      WITH SYNONYMS ('active vendors', 'current suppliers')
      COMMENT = 'Count of active suppliers',
    suppliers.preferred_suppliers AS SUM(CASE WHEN supplier_status = 'PREFERRED' THEN 1 ELSE 0 END)
      WITH SYNONYMS ('preferred vendors', 'top suppliers')
      COMMENT = 'Count of preferred suppliers',
    suppliers.avg_quality_rating AS AVG(quality_rating)
      WITH SYNONYMS ('average vendor quality', 'mean supplier quality')
      COMMENT = 'Average supplier quality rating',
    suppliers.avg_delivery_rating AS AVG(delivery_rating)
      WITH SYNONYMS ('average vendor delivery', 'mean on-time delivery')
      COMMENT = 'Average supplier delivery rating',
    suppliers.total_supplier_spend AS SUM(total_spend)
      WITH SYNONYMS ('total vendor spend', 'aggregate supplier payments')
      COMMENT = 'Sum of all supplier spending',
    suppliers.small_business_count AS SUM(CASE WHEN is_small_business = TRUE THEN 1 ELSE 0 END)
      WITH SYNONYMS ('sb supplier count', 'small business vendors')
      COMMENT = 'Count of small business suppliers',
    -- Purchase order metrics
    purchase_orders.total_pos AS COUNT(DISTINCT po_id)
      WITH SYNONYMS ('po count', 'order count')
      COMMENT = 'Total purchase orders',
    purchase_orders.open_pos AS SUM(CASE WHEN po_status = 'OPEN' THEN 1 ELSE 0 END)
      WITH SYNONYMS ('open orders', 'pending pos')
      COMMENT = 'Count of open purchase orders',
    purchase_orders.total_po_value AS SUM(total_amount)
      WITH SYNONYMS ('total order value', 'po spending')
      COMMENT = 'Sum of purchase order values',
    purchase_orders.total_paid AS SUM(paid_amount)
      WITH SYNONYMS ('payments made', 'amount paid')
      COMMENT = 'Sum of paid amounts',
    purchase_orders.avg_po_value AS AVG(total_amount)
      WITH SYNONYMS ('average order value', 'mean po value')
      COMMENT = 'Average purchase order value',
    -- Proposal metrics
    proposals.total_proposals AS COUNT(DISTINCT proposal_id)
      WITH SYNONYMS ('bid count', 'opportunity count')
      COMMENT = 'Total proposals',
    proposals.proposals_in_progress AS SUM(CASE WHEN proposal_status = 'IN_PROGRESS' THEN 1 ELSE 0 END)
      WITH SYNONYMS ('active bids', 'current opportunities')
      COMMENT = 'Count of proposals in progress',
    proposals.proposals_won AS SUM(CASE WHEN proposal_status = 'WON' THEN 1 ELSE 0 END)
      WITH SYNONYMS ('wins', 'awarded proposals')
      COMMENT = 'Count of won proposals',
    proposals.total_pipeline_value AS SUM(opportunity_value)
      WITH SYNONYMS ('pipeline value', 'opportunity total')
      COMMENT = 'Sum of proposal opportunity values',
    proposals.weighted_pipeline AS SUM(opportunity_value * win_probability / 100)
      WITH SYNONYMS ('weighted opportunity value', 'expected value')
      COMMENT = 'Sum of probability-weighted pipeline value',
    proposals.avg_win_probability AS AVG(win_probability)
      WITH SYNONYMS ('average pwin', 'mean win rate')
      COMMENT = 'Average win probability percentage',
    -- Service agreement metrics
    service_agreements.total_agreements AS COUNT(DISTINCT agreement_id)
      WITH SYNONYMS ('service contract count', 'agreement count')
      COMMENT = 'Total service agreements',
    service_agreements.active_agreements AS SUM(CASE WHEN agreement_status = 'ACTIVE' THEN 1 ELSE 0 END)
      WITH SYNONYMS ('active services', 'current agreements')
      COMMENT = 'Count of active service agreements',
    service_agreements.total_agreement_value AS SUM(total_value)
      WITH SYNONYMS ('service revenue', 'agreement revenue')
      COMMENT = 'Sum of service agreement values',
    service_agreements.avg_sla_performance AS AVG(actual_sla)
      WITH SYNONYMS ('average sla', 'mean service level')
      COMMENT = 'Average actual SLA performance'
  )
  COMMENT = 'Supplier & Procurement Intelligence - comprehensive view of suppliers, purchase orders, proposals, and service agreements';

-- ============================================================================
-- Display confirmation
-- ============================================================================
SELECT 'All semantic views created successfully' AS status;

