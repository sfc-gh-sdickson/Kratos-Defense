-- ============================================================================
-- Kratos Defense Intelligence Agent - Cortex Search Services
-- ============================================================================
-- Creates semantic search services over unstructured data tables
-- Syntax verified against Snowflake documentation
-- ============================================================================

USE DATABASE KRATOS_INTELLIGENCE;
USE SCHEMA RAW;
USE WAREHOUSE KRATOS_WH;

-- ============================================================================
-- Enable Change Tracking on Source Tables
-- ============================================================================
ALTER TABLE TECHNICAL_DOCUMENTS SET CHANGE_TRACKING = TRUE;
ALTER TABLE TEST_REPORTS SET CHANGE_TRACKING = TRUE;
ALTER TABLE INCIDENT_LOGS SET CHANGE_TRACKING = TRUE;

-- ============================================================================
-- Cortex Search Service 1: Technical Documents Search
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE TECHNICAL_DOCS_SEARCH
  ON content
  ATTRIBUTES doc_id, doc_number, doc_title, doc_type, doc_category, program_id, division_id, author, security_classification, keywords
  WAREHOUSE = KRATOS_WH
  TARGET_LAG = '1 hour'
  AS (
    SELECT
      doc_id,
      doc_number,
      doc_title,
      doc_type,
      doc_category,
      program_id,
      division_id,
      author,
      security_classification,
      keywords,
      content
    FROM TECHNICAL_DOCUMENTS
    WHERE doc_status = 'CURRENT'
  );

-- ============================================================================
-- Cortex Search Service 2: Test Reports Search
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE TEST_REPORTS_SEARCH
  ON content
  ATTRIBUTES report_id, report_number, report_title, report_type, test_id, program_id, author, result_summary
  WAREHOUSE = KRATOS_WH
  TARGET_LAG = '1 hour'
  AS (
    SELECT
      report_id,
      report_number,
      report_title,
      report_type,
      test_id,
      program_id,
      author,
      result_summary,
      content
    FROM TEST_REPORTS
  );

-- ============================================================================
-- Cortex Search Service 3: Incident Logs Search
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE INCIDENT_LOGS_SEARCH
  ON detailed_description
  ATTRIBUTES log_id, incident_id, program_id, division_id, log_date, log_type, summary, actions_taken, lessons_learned
  WAREHOUSE = KRATOS_WH
  TARGET_LAG = '1 hour'
  AS (
    SELECT
      log_id,
      incident_id,
      program_id,
      division_id,
      log_date,
      log_type,
      summary,
      detailed_description,
      actions_taken,
      lessons_learned
    FROM INCIDENT_LOGS
  );

-- ============================================================================
-- Verification
-- ============================================================================
SELECT 'Cortex Search services created successfully' AS status;
SHOW CORTEX SEARCH SERVICES IN SCHEMA KRATOS_INTELLIGENCE.RAW;

