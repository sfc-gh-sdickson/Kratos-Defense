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
    - question: 'How many active programs are there?'
      answer: 'I will query the PROGRAMS table to count programs with ACTIVE status.'
    - question: 'What is the total contract value across all programs?'
      answer: 'I will calculate the sum of total_contract_value from the PROGRAMS table.'
    - question: 'List all divisions and their employee counts.'
      answer: 'I will query the DIVISIONS table to show names and headcounts.'
    - question: 'How many assets are in operational status?'
      answer: 'I will filter assets by status OPERATIONAL to get the count.'
    - question: 'What are the top 5 suppliers by total spend?'
      answer: 'I will query SUPPLIERS ordered by total_spend descending.'
    # ========== 5 COMPLEX QUESTIONS (Cortex Analyst) ==========
    - question: 'Analyze program performance by division. Show total value, costs incurred, and average margin.'
      answer: 'I will join PROGRAMS with DIVISIONS to calculate metrics by division.'
    - question: 'Compare manufacturing order completion rates by product type and priority.'
      answer: 'I will analyze MANUFACTURING_ORDERS to calculate completion percentages by category.'
    - question: 'Show asset utilization trends - flight hours, missions, and maintenance costs.'
      answer: 'I will analyze ASSETS, ASSET_OPERATIONS, and MAINTENANCE_RECORDS for utilization metrics.'
    - question: 'What is the contract pipeline? Show contracts by status with total and funded values.'
      answer: 'I will query CONTRACTS grouped by status with value aggregations.'
    - question: 'Analyze supplier performance by category showing quality ratings and delivery scores.'
      answer: 'I will query SUPPLIERS to calculate average ratings by supplier_category.'
    # ========== 5 ML MODEL QUESTIONS (Predictions) ==========
    - question: 'Predict the risk level for program PRG000001.'
      answer: 'I will call PREDICT_PROGRAM_RISK with program_id=PRG000001.'
    - question: 'Forecast production volume for September 2025.'
      answer: 'I will call FORECAST_PRODUCTION with month=9 and year=2025.'
    - question: 'Assess the risk for supplier SUP00050.'
      answer: 'I will call PREDICT_SUPPLIER_RISK with supplier_id=SUP00050.'
    - question: 'When is maintenance due for asset AST000001?'
      answer: 'I will call PREDICT_ASSET_MAINTENANCE with asset_id=AST000001.'
    - question: 'Predict which programs are at risk of cost overruns.'
      answer: 'I will call PREDICT_PROGRAM_RISK for high-value programs to assess risk.'

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
