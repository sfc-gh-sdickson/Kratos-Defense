-- ============================================================================
-- Kratos Defense Intelligence Agent - Create Snowflake Intelligence Agent
-- ============================================================================
-- Purpose: Create and configure Snowflake Intelligence Agent with:
--          - Cortex Analyst tools (Semantic Views)
--          - Cortex Search tools (Unstructured Data)
--          - ML Model tools (Predictions)
-- Execution: Run this after completing steps 01-07 and running the notebook
-- 
-- ML MODELS (from notebook):
--   1. PROGRAM_RISK_PREDICTOR → PREDICT_PROGRAM_RISK(VARCHAR)
--   2. SUPPLIER_RISK_PREDICTOR → PREDICT_SUPPLIER_RISK(VARCHAR)
--   3. PRODUCTION_FORECASTER → FORECAST_PRODUCTION(NUMBER, NUMBER)
--   4. (Bonus) PREDICT_ASSET_MAINTENANCE(VARCHAR)
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
GRANT REFERENCES, SELECT ON SEMANTIC VIEW KRATOS_INTELLIGENCE.ANALYTICS.SV_PROGRAM_OPERATIONS_INTELLIGENCE TO ROLE SYSADMIN;
GRANT REFERENCES, SELECT ON SEMANTIC VIEW KRATOS_INTELLIGENCE.ANALYTICS.SV_ASSET_MANUFACTURING_INTELLIGENCE TO ROLE SYSADMIN;
GRANT REFERENCES, SELECT ON SEMANTIC VIEW KRATOS_INTELLIGENCE.ANALYTICS.SV_ENGINEERING_SUPPORT_INTELLIGENCE TO ROLE SYSADMIN;

-- Grant usage on warehouse
GRANT USAGE ON WAREHOUSE KRATOS_WH TO ROLE SYSADMIN;

-- Grant usage on Cortex Search services
GRANT USAGE ON CORTEX SEARCH SERVICE KRATOS_INTELLIGENCE.RAW.TECHNICAL_DOCS_SEARCH TO ROLE SYSADMIN;
GRANT USAGE ON CORTEX SEARCH SERVICE KRATOS_INTELLIGENCE.RAW.TEST_REPORTS_SEARCH TO ROLE SYSADMIN;
GRANT USAGE ON CORTEX SEARCH SERVICE KRATOS_INTELLIGENCE.RAW.INCIDENT_LOGS_SEARCH TO ROLE SYSADMIN;

-- Grant execute on ML model wrapper procedures
GRANT USAGE ON PROCEDURE KRATOS_INTELLIGENCE.ANALYTICS.PREDICT_PROGRAM_RISK(VARCHAR) TO ROLE SYSADMIN;
GRANT USAGE ON PROCEDURE KRATOS_INTELLIGENCE.ANALYTICS.PREDICT_SUPPLIER_RISK(VARCHAR) TO ROLE SYSADMIN;
GRANT USAGE ON PROCEDURE KRATOS_INTELLIGENCE.ANALYTICS.FORECAST_PRODUCTION(NUMBER, NUMBER) TO ROLE SYSADMIN;
-- Note: Parameter name is ASSET_ID to match agent tool definition
GRANT USAGE ON PROCEDURE KRATOS_INTELLIGENCE.ANALYTICS.PREDICT_ASSET_MAINTENANCE(VARCHAR) TO ROLE SYSADMIN;

-- ============================================================================
-- Step 2: Create Snowflake Intelligence Agent
-- ============================================================================

CREATE OR REPLACE AGENT KRATOS_INTELLIGENCE_AGENT
  COMMENT = 'Kratos Defense Intelligence Agent for defense contractor business intelligence'
  PROFILE = '{"display_name": "Kratos Intelligence Agent", "avatar": "defense-icon.png", "color": "blue"}'
  FROM SPECIFICATION
  $$
models:
  orchestration: auto

orchestration:
  budget:
    seconds: 60
    tokens: 32000

instructions:
  response: 'You are a specialized analytics assistant for Kratos Defense & Security Solutions, a leading defense contractor providing unmanned systems, satellite communications, and hypersonic technologies. For structured data queries use Cortex Analyst semantic views. For unstructured content use Cortex Search services. For predictions use ML model procedures. Keep responses concise and data-driven.'
  orchestration: 'For metrics and KPIs use Cortex Analyst tools. For technical documents, test reports, and incident logs use Cortex Search tools. For forecasting and predictions use ML function tools.'
  system: 'You help analyze defense contractor data including programs, contracts, assets, manufacturing, suppliers, engineering projects, and operational metrics using structured and unstructured data sources.'
  sample_questions:
    # ========== 5 SIMPLE QUESTIONS (Cortex Analyst) ==========
    - question: 'How many programs are there and what is the total contract value?'
      answer: 'I will count programs and sum total_contract_value using ProgramOperationsAnalyst.'
    - question: 'How many contracts are there by status?'
      answer: 'I will count contracts grouped by contract_status using ProgramOperationsAnalyst.'
    - question: 'What is the total number of manufacturing orders and units completed?'
      answer: 'I will count manufacturing orders and sum quantity_completed using AssetManufacturingAnalyst.'
    - question: 'How many employees are there and how many are active?'
      answer: 'I will count employees and filter by ACTIVE status using EngineeringSupportAnalyst.'
    - question: 'How many suppliers are approved and what is the average quality rating?'
      answer: 'I will count approved suppliers and calculate average quality_rating using EngineeringSupportAnalyst.'
    # ========== 5 COMPLEX QUESTIONS (Cortex Analyst) ==========
    - question: 'Show program metrics by division: total programs, total value, costs incurred, and average margin.'
      answer: 'I will group programs by division_name and calculate value, costs, and margin metrics.'
    - question: 'What is the manufacturing completion rate? Show units ordered, completed, and scrapped by product type.'
      answer: 'I will sum quantity_ordered, quantity_completed, quantity_scrapped grouped by product_type.'
    - question: 'Analyze maintenance costs: total maintenance events, labor hours, parts cost, and total expense.'
      answer: 'I will count maintenance records and sum labor_hours, parts_cost, total_cost.'
    - question: 'Show contract values by status: count, base value, option value, and total ceiling.'
      answer: 'I will group contracts by contract_status and sum base_value, option_value, total_value.'
    - question: 'Compare test results: how many tests passed vs failed, and what is the total anomaly count?'
      answer: 'I will count tests by test_result and sum anomalies_count using EngineeringSupportAnalyst.'
    # ========== 5 ML MODEL QUESTIONS (Predictions) ==========
    - question: 'Predict the risk level for program PRG000001.'
      answer: 'I will call PREDICT_PROGRAM_RISK with program_id=PRG000001.'
    - question: 'Forecast production volume for March 2025.'
      answer: 'I will call FORECAST_PRODUCTION with month_num=3 and year_num=2025.'
    - question: 'Assess the risk for supplier SUP00001.'
      answer: 'I will call PREDICT_SUPPLIER_RISK with supplier_id=SUP00001.'
    - question: 'When is maintenance due for asset AST000001?'
      answer: 'I will call PREDICT_ASSET_MAINTENANCE with asset_id=AST000001.'
    - question: 'Forecast production volume for September 2025.'
      answer: 'I will call FORECAST_PRODUCTION with month_num=9 and year_num=2025.'

tools:
  - tool_spec:
      type: 'cortex_analyst_text_to_sql'
      name: 'ProgramOperationsAnalyst'
      description: 'Analyzes defense programs, contracts, customers, divisions, and milestones'
  - tool_spec:
      type: 'cortex_analyst_text_to_sql'
      name: 'AssetManufacturingAnalyst'
      description: 'Analyzes assets, operations, maintenance, manufacturing orders, and quality inspections'
  - tool_spec:
      type: 'cortex_analyst_text_to_sql'
      name: 'EngineeringSupportAnalyst'
      description: 'Analyzes engineering projects, tests, incidents, employees, and suppliers'
  - tool_spec:
      type: 'cortex_search'
      name: 'TechnicalDocsSearch'
      description: 'Searches technical documents including specifications, procedures, manuals, and drawings'
  - tool_spec:
      type: 'cortex_search'
      name: 'TestReportsSearch'
      description: 'Searches test reports including flight tests, ground tests, and integration tests'
  - tool_spec:
      type: 'cortex_search'
      name: 'IncidentLogsSearch'
      description: 'Searches incident logs for safety events, quality escapes, and lessons learned'
  - tool_spec:
      type: 'generic'
      name: 'PredictProgramRisk'
      description: 'Predicts whether a program is at risk of cost or schedule overruns'
      input_schema:
        type: 'object'
        properties:
          program_id:
            type: 'string'
            description: 'Program ID to analyze (e.g., PRG000001)'
        required: ['program_id']
  - tool_spec:
      type: 'generic'
      name: 'PredictSupplierRisk'
      description: 'Predicts whether a supplier is at risk of quality or delivery issues'
      input_schema:
        type: 'object'
        properties:
          supplier_id:
            type: 'string'
            description: 'Supplier ID to analyze (e.g., SUP00001)'
        required: ['supplier_id']
  - tool_spec:
      type: 'generic'
      name: 'ForecastProduction'
      description: 'Forecasts manufacturing order volume for a given month and year'
      input_schema:
        type: 'object'
        properties:
          month_num:
            type: 'integer'
            description: 'Month number (1-12)'
          year_num:
            type: 'integer'
            description: 'Year (e.g., 2025)'
        required: ['month_num', 'year_num']
  - tool_spec:
      type: 'generic'
      name: 'PredictAssetMaintenance'
      description: 'Predicts when an asset will need maintenance based on flight hours and usage patterns'
      input_schema:
        type: 'object'
        properties:
          asset_id:
            type: 'string'
            description: 'Asset ID to analyze (e.g., AST000001)'
        required: ['asset_id']

tool_resources:
  ProgramOperationsAnalyst:
    semantic_view: 'KRATOS_INTELLIGENCE.ANALYTICS.SV_PROGRAM_OPERATIONS_INTELLIGENCE'
    execution_environment:
      type: 'warehouse'
      warehouse: 'KRATOS_WH'
      query_timeout: 60
  AssetManufacturingAnalyst:
    semantic_view: 'KRATOS_INTELLIGENCE.ANALYTICS.SV_ASSET_MANUFACTURING_INTELLIGENCE'
    execution_environment:
      type: 'warehouse'
      warehouse: 'KRATOS_WH'
      query_timeout: 60
  EngineeringSupportAnalyst:
    semantic_view: 'KRATOS_INTELLIGENCE.ANALYTICS.SV_ENGINEERING_SUPPORT_INTELLIGENCE'
    execution_environment:
      type: 'warehouse'
      warehouse: 'KRATOS_WH'
      query_timeout: 60
  TechnicalDocsSearch:
    search_service: 'KRATOS_INTELLIGENCE.RAW.TECHNICAL_DOCS_SEARCH'
    max_results: 10
    title_column: 'doc_title'
    id_column: 'doc_id'
  TestReportsSearch:
    search_service: 'KRATOS_INTELLIGENCE.RAW.TEST_REPORTS_SEARCH'
    max_results: 10
    title_column: 'report_title'
    id_column: 'report_id'
  IncidentLogsSearch:
    search_service: 'KRATOS_INTELLIGENCE.RAW.INCIDENT_LOGS_SEARCH'
    max_results: 10
    title_column: 'summary'
    id_column: 'log_id'
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
  ForecastProduction:
    type: 'procedure'
    identifier: 'KRATOS_INTELLIGENCE.ANALYTICS.FORECAST_PRODUCTION'
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
   - "How many active programs are there?"
   - "Show me total contract value by division"
   - "What is the asset utilization rate?"
   - "List suppliers with quality ratings below 80%"

2. Unstructured queries (Cortex Search):
   - "Search technical documents for XQ-58A specifications"
   - "Find test reports about flight envelope expansion"
   - "Search incident logs for lessons learned about safety"

3. Predictive queries (ML Models):
   - "Predict the risk for program PRG000001"
   - "Forecast production for September 2025"
   - "Assess supplier risk for SUP00050"
   - "When is maintenance due for asset AST000001?"
*/

-- ============================================================================
-- Success Message
-- ============================================================================

SELECT 'Kratos Intelligence Agent created successfully! Access it in Snowsight under AI & ML > Agents' AS status;

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
   -- Should show:
   -- SV_PROGRAM_OPERATIONS_INTELLIGENCE
   -- SV_ASSET_MANUFACTURING_INTELLIGENCE
   -- SV_ENGINEERING_SUPPORT_INTELLIGENCE

3. All Cortex Search services exist and are ready:
   SHOW CORTEX SEARCH SERVICES IN SCHEMA KRATOS_INTELLIGENCE.RAW;
   -- Should show:
   -- TECHNICAL_DOCS_SEARCH
   -- TEST_REPORTS_SEARCH
   -- INCIDENT_LOGS_SEARCH

4. ML wrapper procedures exist:
   SHOW PROCEDURES IN SCHEMA KRATOS_INTELLIGENCE.ANALYTICS;
   -- Should show:
   -- PREDICT_PROGRAM_RISK(VARCHAR)
   -- PREDICT_SUPPLIER_RISK(VARCHAR)
   -- FORECAST_PRODUCTION(NUMBER, NUMBER)
   -- PREDICT_ASSET_MAINTENANCE(VARCHAR)

5. Warehouse is running:
   SHOW WAREHOUSES LIKE 'KRATOS_WH';

6. Models are registered in Model Registry (run notebook first):
   SHOW MODELS IN SCHEMA KRATOS_INTELLIGENCE.ANALYTICS;
   -- Should show:
   -- PROGRAM_RISK_PREDICTOR
   -- SUPPLIER_RISK_PREDICTOR
   -- PRODUCTION_FORECASTER
*/
