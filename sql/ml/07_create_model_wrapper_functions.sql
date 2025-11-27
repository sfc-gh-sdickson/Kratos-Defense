-- ============================================================================
-- Kratos Defense Intelligence Agent - ML Model Wrapper Procedures
-- ============================================================================
-- Purpose: SQL procedures that call registered ML models directly
--
-- When models are registered with log_model(), Snowflake creates SQL functions:
--   PROGRAM_RISK_PREDICTOR!PREDICT(...)
--   SUPPLIER_RISK_PREDICTOR!PREDICT(...)
--   ASSET_MAINTENANCE_PREDICTOR!PREDICT(...)
--
-- These procedures wrap those functions for use by the Intelligence Agent.
--
-- WORKFLOW:
--   1. Run notebook to train and register models
--   2. Run this file to create wrapper procedures
--   3. Agent calls procedures which invoke ML models in real-time
-- ============================================================================

USE DATABASE KRATOS_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE KRATOS_WH;

-- ============================================================================
-- Procedure 1: Program Risk Prediction Wrapper
-- Calls: PROGRAM_RISK_PREDICTOR!PREDICT(...) directly
-- Features must match training: budget, spent, variance, schedule_variance,
--   completion_pct, total_milestones, milestone_pct, budget_utilization, prog_type
-- ============================================================================

CREATE OR REPLACE PROCEDURE PREDICT_PROGRAM_RISK(
    PROGRAM_TYPE VARCHAR
)
RETURNS TABLE()
LANGUAGE SQL
COMMENT = 'Calls PROGRAM_RISK_PREDICTOR ML model in real-time to predict program risk'
AS
$$
DECLARE
    res RESULTSET;
BEGIN
    res := (
        SELECT 
            program_id,
            prog_type,
            budget,
            spent,
            completion_pct,
            PROGRAM_RISK_PREDICTOR!PREDICT(
                budget, spent, variance, schedule_variance,
                completion_pct, total_milestones, milestone_pct, 
                budget_utilization, prog_type
            ) AS predicted_risk
        FROM KRATOS_INTELLIGENCE.ANALYTICS.V_PROGRAM_RISK_FEATURES
        WHERE (:PROGRAM_TYPE IS NULL OR prog_type = :PROGRAM_TYPE)
        LIMIT 100
    );
    RETURN TABLE(res);
END;
$$;

-- ============================================================================
-- Procedure 2: Supplier Risk Prediction Wrapper
-- Calls: SUPPLIER_RISK_PREDICTOR!PREDICT(...) directly
-- Features must match training: quality_score, delivery_score, overall_rating,
--   order_count, total_spend, avg_order_value, payment_terms, sup_type
-- ============================================================================

CREATE OR REPLACE PROCEDURE PREDICT_SUPPLIER_RISK(
    SUPPLIER_TYPE VARCHAR
)
RETURNS TABLE()
LANGUAGE SQL
COMMENT = 'Calls SUPPLIER_RISK_PREDICTOR ML model in real-time to predict supplier risk'
AS
$$
DECLARE
    res RESULTSET;
BEGIN
    res := (
        SELECT 
            supplier_id,
            sup_type,
            quality_score,
            delivery_score,
            total_spend,
            SUPPLIER_RISK_PREDICTOR!PREDICT(
                quality_score, delivery_score, overall_rating,
                order_count, total_spend, avg_order_value,
                payment_terms, sup_type
            ) AS predicted_risk
        FROM KRATOS_INTELLIGENCE.ANALYTICS.V_SUPPLIER_RISK_FEATURES
        WHERE (:SUPPLIER_TYPE IS NULL OR sup_type = :SUPPLIER_TYPE)
        LIMIT 100
    );
    RETURN TABLE(res);
END;
$$;

-- ============================================================================
-- Procedure 3: Asset Maintenance Prediction Wrapper
-- Calls: ASSET_MAINTENANCE_PREDICTOR!PREDICT(...) directly
-- Features must match training: flight_hours, maint_interval, utilization_pct,
--   days_since_maintenance, days_until_due, condition_score, is_ready, ast_type
-- ============================================================================

CREATE OR REPLACE PROCEDURE PREDICT_ASSET_MAINTENANCE(
    ASSET_TYPE VARCHAR
)
RETURNS TABLE()
LANGUAGE SQL
COMMENT = 'Calls ASSET_MAINTENANCE_PREDICTOR ML model in real-time to predict maintenance urgency'
AS
$$
DECLARE
    res RESULTSET;
BEGIN
    res := (
        SELECT 
            asset_id,
            ast_type,
            flight_hours,
            condition_score,
            days_until_due,
            ASSET_MAINTENANCE_PREDICTOR!PREDICT(
                flight_hours, maint_interval, utilization_pct,
                days_since_maintenance, days_until_due, 
                condition_score, is_ready, ast_type
            ) AS predicted_urgency
        FROM KRATOS_INTELLIGENCE.ANALYTICS.V_ASSET_MAINTENANCE_FEATURES
        WHERE (:ASSET_TYPE IS NULL OR ast_type = :ASSET_TYPE)
        LIMIT 100
    );
    RETURN TABLE(res);
END;
$$;

-- ============================================================================
-- Display confirmation
-- ============================================================================

SELECT 'ML model wrapper functions created successfully' AS status;

-- ============================================================================
-- Test Calls (run after models are registered via notebook)
-- These procedures return TABLE results with real-time ML predictions
-- ============================================================================

-- Test PREDICT_PROGRAM_RISK - returns table of programs with predicted risk
CALL PREDICT_PROGRAM_RISK('DEVELOPMENT');
CALL PREDICT_PROGRAM_RISK(NULL);  -- All program types

-- Test PREDICT_SUPPLIER_RISK - returns table of suppliers with predicted risk
CALL PREDICT_SUPPLIER_RISK('TIER_1');
CALL PREDICT_SUPPLIER_RISK(NULL);  -- All supplier types

-- Test PREDICT_ASSET_MAINTENANCE - returns table of assets with predicted urgency
CALL PREDICT_ASSET_MAINTENANCE('AIRCRAFT');
CALL PREDICT_ASSET_MAINTENANCE(NULL);  -- All asset types

SELECT 'Test calls completed - each procedure returns a table with ML predictions' AS instruction;

