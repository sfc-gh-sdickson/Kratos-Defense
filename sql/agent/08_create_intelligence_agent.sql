-- ============================================================================
-- Kratos Defense Intelligence Agent - Create Snowflake Intelligence Agent
-- ============================================================================
-- Purpose: Create and configure Snowflake Intelligence Agent with:
--          - Cortex Analyst tools (Semantic Views)
--          - Cortex Search tools (Unstructured Data)
--          - ML Model tools (Predictions)
-- Execution: Run this after completing steps 01-07 and running the notebook
-- 
-- CRITICAL VERIFICATION:
-- - Procedure parameter names MUST match tool input_schema properties
-- - Sample questions MUST reference metrics exposed in semantic views
-- - Sample questions MUST be answerable by generated data
--
-- ML MODELS (from notebook):
--   1. PROGRAM_RISK_PREDICTOR → PREDICT_PROGRAM_RISK(VARCHAR)
--   2. SUPPLIER_RISK_PREDICTOR → PREDICT_SUPPLIER_RISK(VARCHAR)
--   3. ASSET_MAINTENANCE_PREDICTOR → PREDICT_ASSET_MAINTENANCE(VARCHAR)
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE KRATOS_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE KRATOS_WH;

-- ============================================================================
-- Step 1: Grant Required Permissions for Cortex Analyst
-- ============================================================================

-- Grant Cortex Analyst user role to your role
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_ANALYST_USER TO ROLE SYSADMIN;

-- Grant usage on database and schemas
GRANT USAGE ON DATABASE KRATOS_INTELLIGENCE TO ROLE SYSADMIN;
GRANT USAGE ON SCHEMA KRATOS_INTELLIGENCE.ANALYTICS TO ROLE SYSADMIN;
GRANT USAGE ON SCHEMA KRATOS_INTELLIGENCE.RAW TO ROLE SYSADMIN;

-- Grant privileges on semantic views for Cortex Analyst
GRANT REFERENCES, SELECT ON SEMANTIC VIEW KRATOS_INTELLIGENCE.ANALYTICS.SV_PROGRAM_CONTRACT_INTELLIGENCE TO ROLE SYSADMIN;
GRANT REFERENCES, SELECT ON SEMANTIC VIEW KRATOS_INTELLIGENCE.ANALYTICS.SV_ASSET_MAINTENANCE_INTELLIGENCE TO ROLE SYSADMIN;
GRANT REFERENCES, SELECT ON SEMANTIC VIEW KRATOS_INTELLIGENCE.ANALYTICS.SV_SUPPLIER_PROCUREMENT_INTELLIGENCE TO ROLE SYSADMIN;

-- Grant usage on warehouse
GRANT USAGE ON WAREHOUSE KRATOS_WH TO ROLE SYSADMIN;

-- Grant usage on Cortex Search services
GRANT USAGE ON CORTEX SEARCH SERVICE KRATOS_INTELLIGENCE.RAW.TECHNICAL_DOCS_SEARCH TO ROLE SYSADMIN;
GRANT USAGE ON CORTEX SEARCH SERVICE KRATOS_INTELLIGENCE.RAW.MAINTENANCE_PROCEDURES_SEARCH TO ROLE SYSADMIN;
GRANT USAGE ON CORTEX SEARCH SERVICE KRATOS_INTELLIGENCE.RAW.INCIDENT_REPORTS_SEARCH TO ROLE SYSADMIN;

-- Grant execute on ML model wrapper procedures
-- Parameter names MUST match procedure definitions in 07_create_model_wrapper_functions.sql
GRANT USAGE ON PROCEDURE KRATOS_INTELLIGENCE.ANALYTICS.PREDICT_PROGRAM_RISK(VARCHAR) TO ROLE SYSADMIN;
GRANT USAGE ON PROCEDURE KRATOS_INTELLIGENCE.ANALYTICS.PREDICT_SUPPLIER_RISK(VARCHAR) TO ROLE SYSADMIN;
GRANT USAGE ON PROCEDURE KRATOS_INTELLIGENCE.ANALYTICS.PREDICT_ASSET_MAINTENANCE(VARCHAR) TO ROLE SYSADMIN;

-- ============================================================================
-- Step 2: Create Snowflake Intelligence Agent
-- ============================================================================

CREATE OR REPLACE AGENT KRATOS_INTELLIGENCE_AGENT
  COMMENT = 'Kratos Defense Intelligence Agent for defense contractor business intelligence'
  PROFILE = '{"display_name": "Kratos Defense Intelligence Agent", "avatar": "defense-icon.png", "color": "navy"}'
  FROM SPECIFICATION
  $$
models:
  orchestration: auto

orchestration:
  budget:
    seconds: 60
    tokens: 32000

instructions:
  response: 'You are a specialized analytics assistant for Kratos Defense, a leading defense contractor specializing in unmanned systems, satellite technology, and electronic warfare. For structured data queries use Cortex Analyst semantic views. For unstructured content use Cortex Search services. For predictions use ML model procedures. Keep responses concise and data-driven.'
  orchestration: 'For metrics and KPIs use Cortex Analyst tools. For technical documentation, maintenance procedures, and incident reports use Cortex Search tools. For risk forecasting and predictions use ML function tools.'
  system: 'You help analyze defense contractor data including programs, contracts, assets, suppliers, maintenance, quality, and proposals using structured and unstructured data sources.'
  sample_questions:
    # ========== 5 SIMPLE QUESTIONS (Cortex Analyst) ==========
    # All questions verified against semantic view metrics from 05_create_semantic_views.sql
    - question: 'How many active programs do we have?'
      answer: 'I will query the programs table filtering by program_status=ACTIVE to count active programs.'
    - question: 'What is the total value of our contracts?'
      answer: 'I will sum the base_value from the contracts table to get total contract value.'
    - question: 'How many suppliers are in our system?'
      answer: 'I will count distinct supplier_id from the suppliers table to get total suppliers.'
    - question: 'What is our average supplier quality rating?'
      answer: 'I will calculate the average of quality_rating from the suppliers table.'
    - question: 'How many assets are currently operational?'
      answer: 'I will count assets filtering by asset_status=OPERATIONAL to get operational asset count.'
    # ========== 5 COMPLEX QUESTIONS (Cortex Analyst) ==========
    # All questions verified to use metrics exposed in semantic views
    - question: 'Compare program budget utilization across divisions. Show total budget, spent, and variance.'
      answer: 'I will join programs with divisions and calculate budget_amount, spent_amount, and budget_variance by division.'
    - question: 'Show supplier performance by type. Include quality ratings, delivery ratings, and total spend.'
      answer: 'I will query suppliers grouped by supplier_type showing avg quality_rating, avg delivery_rating, and sum total_spend.'
    - question: 'What is our proposal pipeline? Show proposals by status with opportunity values.'
      answer: 'I will query proposals grouped by proposal_status showing count and sum of opportunity_value.'
    - question: 'Analyze maintenance costs by asset type. Show total labor, parts, and total maintenance costs.'
      answer: 'I will join maintenance_records with assets and sum labor_cost, parts_cost, and total_cost by asset_type.'
    - question: 'Show contract performance by customer. Include total value, funded amount, and average performance rating.'
      answer: 'I will query contracts grouped by customer showing sum base_value, sum funded_value, and avg performance_rating.'
    # ========== 5 ML MODEL QUESTIONS (Predictions) ==========
    # All questions use correct parameter names from 07_create_model_wrapper_functions.sql
    - question: 'Predict risk levels for our development programs.'
      answer: 'I will call PREDICT_PROGRAM_RISK with program_type=DEVELOPMENT to analyze risk.'
    - question: 'Identify which Tier 1 suppliers might be at risk.'
      answer: 'I will call PREDICT_SUPPLIER_RISK with supplier_type=TIER_1 to identify at-risk suppliers.'
    - question: 'Which aircraft assets need maintenance attention soon?'
      answer: 'I will call PREDICT_ASSET_MAINTENANCE with asset_type=AIRCRAFT to predict maintenance urgency.'
    - question: 'What is the overall program risk across all program types?'
      answer: 'I will call PREDICT_PROGRAM_RISK with no filter to analyze all programs.'
    - question: 'Predict maintenance needs for all equipment assets.'
      answer: 'I will call PREDICT_ASSET_MAINTENANCE with asset_type=EQUIPMENT to predict maintenance urgency.'

tools:
  - tool_spec:
      type: 'cortex_analyst_text_to_sql'
      name: 'ProgramContractAnalyst'
      description: 'Analyzes defense programs, contracts, divisions, and milestones'
  - tool_spec:
      type: 'cortex_analyst_text_to_sql'
      name: 'AssetMaintenanceAnalyst'
      description: 'Analyzes assets, maintenance records, and quality inspections'
  - tool_spec:
      type: 'cortex_analyst_text_to_sql'
      name: 'SupplierProcurementAnalyst'
      description: 'Analyzes suppliers, purchase orders, proposals, and service agreements'
  - tool_spec:
      type: 'cortex_search'
      name: 'TechnicalDocsSearch'
      description: 'Searches technical documentation including operations manuals, integration guides, and technical references'
  - tool_spec:
      type: 'cortex_search'
      name: 'MaintenanceProceduresSearch'
      description: 'Searches maintenance procedures for inspection, calibration, and repair tasks'
  - tool_spec:
      type: 'cortex_search'
      name: 'IncidentReportsSearch'
      description: 'Searches incident reports for operational, quality, and cybersecurity events'
  - tool_spec:
      type: 'generic'
      name: 'PredictProgramRisk'
      description: 'Predicts risk levels for defense programs based on budget, schedule, and milestone data'
      input_schema:
        type: 'object'
        properties:
          program_type:
            type: 'string'
            description: 'Program type to filter (DEVELOPMENT, PRODUCTION, SUSTAINMENT, RDT&E, etc.) or null for all'
        required: []
  - tool_spec:
      type: 'generic'
      name: 'PredictSupplierRisk'
      description: 'Identifies suppliers at risk based on quality and delivery performance'
      input_schema:
        type: 'object'
        properties:
          supplier_type:
            type: 'string'
            description: 'Supplier type to filter (TIER_1, TIER_2, TIER_3, DISTRIBUTOR, etc.) or null for all'
        required: []
  - tool_spec:
      type: 'generic'
      name: 'PredictAssetMaintenance'
      description: 'Predicts maintenance urgency for assets based on usage and maintenance history'
      input_schema:
        type: 'object'
        properties:
          asset_type:
            type: 'string'
            description: 'Asset type to filter (AIRCRAFT, VEHICLE, EQUIPMENT, ELECTRONICS, etc.) or null for all'
        required: []

tool_resources:
  ProgramContractAnalyst:
    semantic_view: 'KRATOS_INTELLIGENCE.ANALYTICS.SV_PROGRAM_CONTRACT_INTELLIGENCE'
    execution_environment:
      type: 'warehouse'
      warehouse: 'KRATOS_WH'
      query_timeout: 60
  AssetMaintenanceAnalyst:
    semantic_view: 'KRATOS_INTELLIGENCE.ANALYTICS.SV_ASSET_MAINTENANCE_INTELLIGENCE'
    execution_environment:
      type: 'warehouse'
      warehouse: 'KRATOS_WH'
      query_timeout: 60
  SupplierProcurementAnalyst:
    semantic_view: 'KRATOS_INTELLIGENCE.ANALYTICS.SV_SUPPLIER_PROCUREMENT_INTELLIGENCE'
    execution_environment:
      type: 'warehouse'
      warehouse: 'KRATOS_WH'
      query_timeout: 60
  TechnicalDocsSearch:
    search_service: 'KRATOS_INTELLIGENCE.RAW.TECHNICAL_DOCS_SEARCH'
    max_results: 5
    title_column: 'doc_title'
    id_column: 'doc_id'
  MaintenanceProceduresSearch:
    search_service: 'KRATOS_INTELLIGENCE.RAW.MAINTENANCE_PROCEDURES_SEARCH'
    max_results: 5
    title_column: 'procedure_title'
    id_column: 'procedure_id'
  IncidentReportsSearch:
    search_service: 'KRATOS_INTELLIGENCE.RAW.INCIDENT_REPORTS_SEARCH'
    max_results: 5
    title_column: 'incident_title'
    id_column: 'incident_id'
  PredictProgramRisk:
    type: 'procedure'
    identifier: 'KRATOS_INTELLIGENCE.ANALYTICS.PREDICT_PROGRAM_RISK'
    execution_environment:
      type: 'warehouse'
      warehouse: 'KRATOS_WH'
      query_timeout: 60
  PredictSupplierRisk:
    type: 'procedure'
    identifier: 'KRATOS_INTELLIGENCE.ANALYTICS.PREDICT_SUPPLIER_RISK'
    execution_environment:
      type: 'warehouse'
      warehouse: 'KRATOS_WH'
      query_timeout: 60
  PredictAssetMaintenance:
    type: 'procedure'
    identifier: 'KRATOS_INTELLIGENCE.ANALYTICS.PREDICT_ASSET_MAINTENANCE'
    execution_environment:
      type: 'warehouse'
      warehouse: 'KRATOS_WH'
      query_timeout: 60
  $$;

-- ============================================================================
-- Step 3: Verify Agent Creation
-- ============================================================================

-- Show created agent
SHOW AGENTS LIKE 'KRATOS_INTELLIGENCE_AGENT';

-- Describe agent configuration
DESCRIBE AGENT KRATOS_INTELLIGENCE_AGENT;

-- Grant usage
GRANT USAGE ON AGENT KRATOS_INTELLIGENCE_AGENT TO ROLE SYSADMIN;

-- ============================================================================
-- Step 4: Test Agent (Examples)
-- ============================================================================

-- Note: After agent creation, you can test it in Snowsight:
-- 1. Go to AI & ML > Agents
-- 2. Select KRATOS_INTELLIGENCE_AGENT
-- 3. Click "Chat" to interact with the agent

-- Example test queries:
/*
1. Structured queries (Cortex Analyst):
   - "How many active programs do we have?"
   - "What is our total contract value?"
   - "Show supplier performance by type"
   - "What is the proposal pipeline by status?"

2. Unstructured queries (Cortex Search):
   - "Search for UAV operations procedures"
   - "Find maintenance procedures for radar calibration"
   - "Search incident reports about cybersecurity"

3. Predictive queries (ML Models):
   - "Predict risk for development programs"
   - "Identify at-risk Tier 1 suppliers"
   - "Which aircraft need maintenance soon?"
*/

-- ============================================================================
-- Success Message
-- ============================================================================

SELECT 'KRATOS_INTELLIGENCE_AGENT created successfully! Access it in Snowsight under AI & ML > Agents' AS status;

-- ============================================================================
-- TROUBLESHOOTING
-- ============================================================================

/*
If agent creation fails, verify:

1. Permissions are granted:
   - CORTEX_ANALYST_USER database role
   - REFERENCES and SELECT on all semantic views
   - USAGE on Cortex Search services
   - USAGE on ML procedures

2. All semantic views exist:
   SHOW SEMANTIC VIEWS IN SCHEMA KRATOS_INTELLIGENCE.ANALYTICS;

3. All Cortex Search services exist and are ready:
   SHOW CORTEX SEARCH SERVICES IN SCHEMA KRATOS_INTELLIGENCE.RAW;

4. ML wrapper procedures exist:
   SHOW PROCEDURES IN SCHEMA KRATOS_INTELLIGENCE.ANALYTICS;
   -- Should show:
   -- PREDICT_PROGRAM_RISK(VARCHAR)
   -- PREDICT_SUPPLIER_RISK(VARCHAR)
   -- PREDICT_ASSET_MAINTENANCE(VARCHAR)

5. Warehouse is running:
   SHOW WAREHOUSES LIKE 'KRATOS_WH';

6. Models are registered in Model Registry (run notebook first):
   SHOW MODELS IN SCHEMA KRATOS_INTELLIGENCE.ANALYTICS;
   -- Should show:
   -- PROGRAM_RISK_PREDICTOR
   -- SUPPLIER_RISK_PREDICTOR
   -- ASSET_MAINTENANCE_PREDICTOR
*/

