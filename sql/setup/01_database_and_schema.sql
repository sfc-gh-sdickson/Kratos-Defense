-- ============================================================================
-- Kratos Defense Intelligence Agent - Database and Schema Setup
-- ============================================================================
-- Purpose: Initialize the database, schema, and warehouse for the Kratos
--          Defense Intelligence Agent solution
-- Syntax: Verified against Snowflake SQL Reference
-- ============================================================================

-- Create the database
CREATE DATABASE IF NOT EXISTS KRATOS_INTELLIGENCE;

-- Use the database
USE DATABASE KRATOS_INTELLIGENCE;

-- Create schemas
CREATE SCHEMA IF NOT EXISTS RAW;
CREATE SCHEMA IF NOT EXISTS ANALYTICS;

-- Create a virtual warehouse for query processing
CREATE OR REPLACE WAREHOUSE KRATOS_WH WITH
    WAREHOUSE_SIZE = 'X-SMALL'
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Warehouse for Kratos Defense Intelligence Agent queries';

-- Set the warehouse as active
USE WAREHOUSE KRATOS_WH;

-- Display confirmation
SELECT 'Database, schema, and warehouse setup completed successfully' AS STATUS;

