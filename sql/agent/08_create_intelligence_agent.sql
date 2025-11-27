-- ============================================================================
-- Kratos Defense Intelligence Agent - Create Intelligence Agent
-- ============================================================================
-- Purpose: Create the Snowflake Intelligence Agent for Kratos Defense
-- 
-- Documentation Reference:
-- https://docs.snowflake.com/en/user-guide/snowflake-cortex/snowflake-intelligence
-- https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-agents
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE KRATOS_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE KRATOS_WH;

-- ============================================================================
-- Create the Kratos Intelligence Agent
-- ============================================================================
CREATE OR REPLACE AGENT KRATOS_INTELLIGENCE_AGENT
  ORCHESTRATION = 'agent'
  INSTRUCTIONS = '
You are an AI assistant for Kratos Defense & Security Solutions, a leading technology company focused on National Security.

Kratos provides advanced defense systems across these key divisions:
- Hypersonics: Erinyes, Dark Fury hypersonic strike systems
- Propulsion & Power: GEK and Spartan turbine engines, Oriole and Zeus rocket motors
- Unmanned Systems: XQ-58A Valkyrie, Mako drones, BQM-167/177 aerial targets, Firejet
- Weapon Systems: Missile systems, radar, C5ISR, high energy lasers
- Space: Satellite communications, ground stations, antenna systems
- Microwave & Digital Solutions: Electronic warfare, cybersecurity, RF components

Your capabilities:
1. SEMANTIC VIEWS (Cortex Analyst): Answer questions about programs, contracts, suppliers, production, quality, customers using structured data
2. CORTEX SEARCH: Search technical documents, test reports, and program reviews using natural language
3. ML PREDICTIONS: Predict program risk, supplier risk, and forecast production using trained models

When answering questions:
- Be specific and cite data sources
- Provide actionable insights
- For predictions, explain the assessment clearly
- Respect security classifications - never expose classified information

Available tools:
- SV_PROGRAM_INTELLIGENCE: Programs, contracts, milestones, deliverables, risks, customers
- SV_OPERATIONS_INTELLIGENCE: Production, quality, suppliers, employees
- SV_CUSTOMER_INTELLIGENCE: Customers, support tickets, engineering tests
- TECHNICAL_DOCS_SEARCH: Search technical specifications and design documents
- TEST_REPORTS_SEARCH: Search test and evaluation reports
- PROGRAM_REVIEWS_SEARCH: Search program review documents
- PREDICT_PROGRAM_RISK: Predict if a program is at risk
- PREDICT_SUPPLIER_RISK: Predict if a supplier is at risk
- FORECAST_PRODUCTION: Forecast production for a given month
'
  TOOLS = (
    -- Semantic Views for structured data queries
    (TYPE='cortex_analyst_text_to_sql', 
     SEMANTIC_VIEW='KRATOS_INTELLIGENCE.ANALYTICS.SV_PROGRAM_INTELLIGENCE',
     DESCRIPTION='Query program portfolio, contracts, milestones, deliverables, risks, and customer data'),
     
    (TYPE='cortex_analyst_text_to_sql', 
     SEMANTIC_VIEW='KRATOS_INTELLIGENCE.ANALYTICS.SV_OPERATIONS_INTELLIGENCE',
     DESCRIPTION='Query production orders, quality records, supplier performance, and employee data'),
     
    (TYPE='cortex_analyst_text_to_sql', 
     SEMANTIC_VIEW='KRATOS_INTELLIGENCE.ANALYTICS.SV_CUSTOMER_INTELLIGENCE',
     DESCRIPTION='Query customer data, support tickets, and engineering test results'),
    
    -- Cortex Search Services for unstructured data
    (TYPE='cortex_search',
     CORTEX_SEARCH_SERVICE='KRATOS_INTELLIGENCE.RAW.TECHNICAL_DOCS_SEARCH',
     DESCRIPTION='Search technical documentation including specifications, ICDs, and design documents'),
     
    (TYPE='cortex_search',
     CORTEX_SEARCH_SERVICE='KRATOS_INTELLIGENCE.RAW.TEST_REPORTS_SEARCH',
     DESCRIPTION='Search test and evaluation reports including vibration, thermal, EMI, and functional tests'),
     
    (TYPE='cortex_search',
     CORTEX_SEARCH_SERVICE='KRATOS_INTELLIGENCE.RAW.PROGRAM_REVIEWS_SEARCH',
     DESCRIPTION='Search program review documents including PMR, PDR, CDR, and status reviews'),
    
    -- ML Model Procedures
    (TYPE='generic',
     PROCEDURE='KRATOS_INTELLIGENCE.ANALYTICS.PREDICT_PROGRAM_RISK',
     DESCRIPTION='Predict whether a program is at risk of schedule delays or cost overruns. Input: program_id (e.g., PRG000001)'),
     
    (TYPE='generic',
     PROCEDURE='KRATOS_INTELLIGENCE.ANALYTICS.PREDICT_SUPPLIER_RISK',
     DESCRIPTION='Predict whether a supplier is at risk of quality or delivery issues. Input: supplier_id (e.g., SUP00001)'),
     
    (TYPE='generic',
     PROCEDURE='KRATOS_INTELLIGENCE.ANALYTICS.FORECAST_PRODUCTION',
     DESCRIPTION='Forecast production throughput for a specific month. Input: month (1-12), year (e.g., 2025)')
  )
  COMMENT = 'Kratos Defense Intelligence Agent - Programs, Contracts, Suppliers, Production, Quality, Technical Docs';

-- ============================================================================
-- Grant permissions for agent access
-- ============================================================================

-- Grant usage on the agent
GRANT USAGE ON AGENT KRATOS_INTELLIGENCE_AGENT TO ROLE SYSADMIN;

-- Grant references on semantic views (required for Cortex Analyst)
GRANT REFERENCES ON SEMANTIC VIEW SV_PROGRAM_INTELLIGENCE TO ROLE SYSADMIN;
GRANT REFERENCES ON SEMANTIC VIEW SV_OPERATIONS_INTELLIGENCE TO ROLE SYSADMIN;
GRANT REFERENCES ON SEMANTIC VIEW SV_CUSTOMER_INTELLIGENCE TO ROLE SYSADMIN;

-- Grant SELECT on underlying tables
GRANT SELECT ON ALL TABLES IN SCHEMA RAW TO ROLE SYSADMIN;

-- Grant usage on Cortex Search services
GRANT USAGE ON CORTEX SEARCH SERVICE RAW.TECHNICAL_DOCS_SEARCH TO ROLE SYSADMIN;
GRANT USAGE ON CORTEX SEARCH SERVICE RAW.TEST_REPORTS_SEARCH TO ROLE SYSADMIN;
GRANT USAGE ON CORTEX SEARCH SERVICE RAW.PROGRAM_REVIEWS_SEARCH TO ROLE SYSADMIN;

-- Grant execute on ML procedures
GRANT USAGE ON PROCEDURE ANALYTICS.PREDICT_PROGRAM_RISK(VARCHAR) TO ROLE SYSADMIN;
GRANT USAGE ON PROCEDURE ANALYTICS.PREDICT_SUPPLIER_RISK(VARCHAR) TO ROLE SYSADMIN;
GRANT USAGE ON PROCEDURE ANALYTICS.FORECAST_PRODUCTION(NUMBER, NUMBER) TO ROLE SYSADMIN;

-- ============================================================================
-- Add agent to Snowflake Intelligence (if object exists)
-- ============================================================================
-- Note: Run this after creating the Snowflake Intelligence object in the UI
-- ALTER SNOWFLAKE INTELLIGENCE SNOWFLAKE_INTELLIGENCE_OBJECT_DEFAULT 
--   ADD AGENT KRATOS_INTELLIGENCE.ANALYTICS.KRATOS_INTELLIGENCE_AGENT;

-- ============================================================================
-- Display confirmation and test questions
-- ============================================================================
SELECT 'Kratos Intelligence Agent created successfully' AS status,
       'Access via Snowsight: AI & ML > Agents > KRATOS_INTELLIGENCE_AGENT' AS access_instructions;

-- ============================================================================
-- Sample Test Questions
-- ============================================================================
/*
Try these questions with the agent:

SIMPLE QUESTIONS (Semantic Views):
1. "How many active programs does Kratos have?"
2. "What is the total contract value across all programs?"
3. "Show me the top 5 suppliers by quality rating"
4. "How many open support tickets are there?"
5. "What is the average test pass rate?"

COMPLEX QUESTIONS (Semantic Views):
1. "Which programs have cost variance worse than -10% and what are their risk levels?"
2. "Show supplier performance trends over the last 12 months"
3. "What is the on-time delivery rate by division?"
4. "Compare quality metrics between hypersonics and unmanned systems divisions"
5. "Which customers have the most critical priority open tickets?"

UNSTRUCTURED DATA (Cortex Search):
1. "Find specifications for the XQ-58A Valkyrie"
2. "Search for vibration test results"
3. "Find program review documents with action items"

ML PREDICTIONS:
1. "Predict the risk for program PRG000001"
2. "Is supplier SUP00001 at risk?"
3. "Forecast production for January 2026"
*/

-- ============================================================================
-- Troubleshooting Guide
-- ============================================================================
/*
COMMON ISSUES:

1. "Permission denied" errors:
   - Ensure role has USAGE on database, schema, warehouse
   - Ensure role has SELECT on underlying tables
   - Ensure role has REFERENCES on semantic views

2. "Semantic view not found":
   - Verify semantic views exist: SHOW SEMANTIC VIEWS IN SCHEMA ANALYTICS;
   - Check for syntax errors in semantic view definitions

3. "Cortex Search service not responding":
   - Check service status: DESCRIBE CORTEX SEARCH SERVICE RAW.TECHNICAL_DOCS_SEARCH;
   - Verify change tracking is enabled on source tables
   - Check TARGET_LAG setting

4. "ML model not found":
   - Verify models are registered: SHOW MODELS;
   - Check model versions: SHOW VERSIONS IN MODEL PROGRAM_RISK_PREDICTOR;

5. Agent not appearing in Snowflake Intelligence:
   - Ensure Snowflake Intelligence object exists
   - Add agent using ALTER SNOWFLAKE INTELLIGENCE command
   - Check role has USAGE on agent

VERIFICATION QUERIES:

-- Check semantic views
SHOW SEMANTIC VIEWS IN SCHEMA ANALYTICS;

-- Check Cortex Search services
SHOW CORTEX SEARCH SERVICES IN SCHEMA RAW;

-- Check ML models
SHOW MODELS IN SCHEMA ANALYTICS;

-- Check agent
DESCRIBE AGENT KRATOS_INTELLIGENCE_AGENT;
*/

