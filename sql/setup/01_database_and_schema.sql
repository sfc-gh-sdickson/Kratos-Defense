-- ============================================================================
-- Kratos Defense Intelligence Agent - Database and Schema Setup
-- ============================================================================
-- Purpose: Create database, schemas, and warehouse for the Intelligence Agent
-- Execution: Run this script first before any other setup scripts
-- Required Role: ACCOUNTADMIN or role with CREATE DATABASE privileges
-- ============================================================================

-- Use ACCOUNTADMIN role for initial setup
USE ROLE ACCOUNTADMIN;

-- ============================================================================
-- Step 1: Create Virtual Warehouse
-- ============================================================================
CREATE WAREHOUSE IF NOT EXISTS KRATOS_WH
    WITH WAREHOUSE_SIZE = 'MEDIUM'
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = FALSE
    COMMENT = 'Warehouse for Kratos Defense Intelligence Agent workloads';

-- ============================================================================
-- Step 2: Create Database
-- ============================================================================
CREATE DATABASE IF NOT EXISTS KRATOS_INTELLIGENCE
    COMMENT = 'Kratos Defense Intelligence Agent - Program, Asset, and Operations Analytics';

-- ============================================================================
-- Step 3: Create Schemas
-- ============================================================================

-- RAW schema for source data tables
CREATE SCHEMA IF NOT EXISTS KRATOS_INTELLIGENCE.RAW
    COMMENT = 'Raw data tables for programs, assets, operations, and manufacturing';

-- ANALYTICS schema for views and semantic models
CREATE SCHEMA IF NOT EXISTS KRATOS_INTELLIGENCE.ANALYTICS
    COMMENT = 'Analytical views and semantic models for Intelligence Agent';

-- ============================================================================
-- Step 4: Set Default Context
-- ============================================================================
USE DATABASE KRATOS_INTELLIGENCE;
USE SCHEMA RAW;
USE WAREHOUSE KRATOS_WH;

-- ============================================================================
-- Step 5: Grant Permissions (adjust role names as needed)
-- ============================================================================

-- Grant usage on warehouse
GRANT USAGE ON WAREHOUSE KRATOS_WH TO ROLE SYSADMIN;
GRANT OPERATE ON WAREHOUSE KRATOS_WH TO ROLE SYSADMIN;

-- Grant full access on database
GRANT ALL PRIVILEGES ON DATABASE KRATOS_INTELLIGENCE TO ROLE SYSADMIN;

-- Grant full access on schemas
GRANT ALL PRIVILEGES ON SCHEMA KRATOS_INTELLIGENCE.RAW TO ROLE SYSADMIN;
GRANT ALL PRIVILEGES ON SCHEMA KRATOS_INTELLIGENCE.ANALYTICS TO ROLE SYSADMIN;

-- Grant future privileges on tables and views
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA KRATOS_INTELLIGENCE.RAW TO ROLE SYSADMIN;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA KRATOS_INTELLIGENCE.ANALYTICS TO ROLE SYSADMIN;
GRANT ALL PRIVILEGES ON ALL VIEWS IN SCHEMA KRATOS_INTELLIGENCE.ANALYTICS TO ROLE SYSADMIN;
GRANT ALL PRIVILEGES ON FUTURE TABLES IN SCHEMA KRATOS_INTELLIGENCE.RAW TO ROLE SYSADMIN;
GRANT ALL PRIVILEGES ON FUTURE TABLES IN SCHEMA KRATOS_INTELLIGENCE.ANALYTICS TO ROLE SYSADMIN;
GRANT ALL PRIVILEGES ON FUTURE VIEWS IN SCHEMA KRATOS_INTELLIGENCE.ANALYTICS TO ROLE SYSADMIN;

-- ============================================================================
-- Step 6: Verify Setup
-- ============================================================================
SELECT 'Database and schemas created successfully' AS status;

SHOW DATABASES LIKE 'KRATOS_INTELLIGENCE';
SHOW SCHEMAS IN DATABASE KRATOS_INTELLIGENCE;
SHOW WAREHOUSES LIKE 'KRATOS_WH';

-- ============================================================================
-- Next Steps:
-- 1. Run 02_create_tables.sql to create table definitions
-- 2. Run 03_generate_synthetic_data.sql to populate with sample data
-- ============================================================================


