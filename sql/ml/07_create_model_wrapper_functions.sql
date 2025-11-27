-- ============================================================================
-- Kratos Defense Intelligence Agent - ML Model Wrapper Procedures
-- ============================================================================
-- Purpose: SQL procedures that call registered ML models directly
--
-- When models are registered with log_model(), Snowflake creates callable models:
--   PROGRAM_RISK_PREDICTOR
--   SUPPLIER_RISK_PREDICTOR
--   ASSET_MAINTENANCE_PREDICTOR
--
-- These procedures use WITH model AS MODEL syntax to invoke predictions.
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
-- Model: PROGRAM_RISK_PREDICTOR
-- Returns: JSON summary of ML predictions
-- ============================================================================

CREATE OR REPLACE PROCEDURE PREDICT_PROGRAM_RISK(
    PROGRAM_TYPE VARCHAR
)
RETURNS STRING
LANGUAGE SQL
COMMENT = 'Calls PROGRAM_RISK_PREDICTOR ML model to predict program risk levels'
AS
$$
DECLARE
    result_json STRING;
    total_count INTEGER;
    low_risk INTEGER;
    medium_risk INTEGER;
    high_risk INTEGER;
    critical_risk INTEGER;
    high_risk_pct FLOAT;
BEGIN
    -- 1. Get predictions using the ML model
    -- 2. Aggregate results immediately
    WITH predictions AS (
        WITH m AS MODEL KRATOS_INTELLIGENCE.ANALYTICS.PROGRAM_RISK_PREDICTOR
        SELECT 
            m!PREDICT(
                budget, spent, variance, schedule_variance,
                completion_pct, total_milestones, milestone_pct, 
                budget_utilization, prog_type
            ):PREDICTED_RISK::INT AS predicted_risk
        FROM KRATOS_INTELLIGENCE.ANALYTICS.V_PROGRAM_RISK_FEATURES
        WHERE (:PROGRAM_TYPE IS NULL OR :PROGRAM_TYPE = 'NULL' OR :PROGRAM_TYPE = '' OR UPPER(prog_type) = UPPER(:PROGRAM_TYPE))
        LIMIT 100
    )
    SELECT 
        COUNT(*),
        SUM(CASE WHEN predicted_risk = 0 THEN 1 ELSE 0 END),
        SUM(CASE WHEN predicted_risk = 1 THEN 1 ELSE 0 END),
        SUM(CASE WHEN predicted_risk = 2 THEN 1 ELSE 0 END),
        SUM(CASE WHEN predicted_risk = 3 THEN 1 ELSE 0 END)
    INTO total_count, low_risk, medium_risk, high_risk, critical_risk
    FROM predictions;
    
    -- Calculate percentage
    IF (total_count > 0) THEN
        high_risk_pct := ROUND((high_risk + critical_risk) / total_count * 100, 2);
    ELSE
        high_risk_pct := 0;
    END IF;
    
    -- Build JSON response
    result_json := OBJECT_CONSTRUCT(
        'prediction_source', 'PROGRAM_RISK_PREDICTOR ML Model',
        'program_type_filter', COALESCE(:PROGRAM_TYPE, 'ALL'),
        'programs_analyzed', total_count,
        'predicted_low_risk', low_risk,
        'predicted_medium_risk', medium_risk,
        'predicted_high_risk', high_risk,
        'predicted_critical_risk', critical_risk,
        'high_risk_pct', high_risk_pct
    )::STRING;
    
    RETURN result_json;
END;
$$;

-- ============================================================================
-- Procedure 2: Supplier Risk Prediction Wrapper
-- Model: SUPPLIER_RISK_PREDICTOR
-- Returns: JSON summary of ML predictions
-- ============================================================================

CREATE OR REPLACE PROCEDURE PREDICT_SUPPLIER_RISK(
    SUPPLIER_TYPE VARCHAR
)
RETURNS STRING
LANGUAGE SQL
COMMENT = 'Calls SUPPLIER_RISK_PREDICTOR ML model to predict supplier risk levels'
AS
$$
DECLARE
    result_json STRING;
    total_count INTEGER;
    low_risk INTEGER;
    medium_risk INTEGER;
    high_risk INTEGER;
    critical_risk INTEGER;
    avg_quality FLOAT;
    avg_delivery FLOAT;
BEGIN
    WITH predictions AS (
        WITH m AS MODEL KRATOS_INTELLIGENCE.ANALYTICS.SUPPLIER_RISK_PREDICTOR
        SELECT 
            quality_score,
            delivery_score,
            m!PREDICT(
                quality_score, delivery_score, overall_rating,
                order_count, total_spend, avg_order_value,
                payment_terms, sup_type
            ):PREDICTED_RISK::INT AS predicted_risk
        FROM KRATOS_INTELLIGENCE.ANALYTICS.V_SUPPLIER_RISK_FEATURES
        WHERE (:SUPPLIER_TYPE IS NULL OR :SUPPLIER_TYPE = 'NULL' OR :SUPPLIER_TYPE = '' OR UPPER(sup_type) = UPPER(:SUPPLIER_TYPE))
        LIMIT 100
    )
    SELECT 
        COUNT(*),
        SUM(CASE WHEN predicted_risk = 0 THEN 1 ELSE 0 END),
        SUM(CASE WHEN predicted_risk = 1 THEN 1 ELSE 0 END),
        SUM(CASE WHEN predicted_risk = 2 THEN 1 ELSE 0 END),
        SUM(CASE WHEN predicted_risk = 3 THEN 1 ELSE 0 END),
        ROUND(AVG(quality_score), 2),
        ROUND(AVG(delivery_score), 2)
    INTO total_count, low_risk, medium_risk, high_risk, critical_risk, avg_quality, avg_delivery
    FROM predictions;
    
    result_json := OBJECT_CONSTRUCT(
        'prediction_source', 'SUPPLIER_RISK_PREDICTOR ML Model',
        'supplier_type_filter', COALESCE(:SUPPLIER_TYPE, 'ALL'),
        'suppliers_analyzed', total_count,
        'predicted_low_risk', low_risk,
        'predicted_medium_risk', medium_risk,
        'predicted_high_risk', high_risk,
        'predicted_critical_risk', critical_risk,
        'at_risk_suppliers', high_risk + critical_risk,
        'avg_quality_rating', avg_quality,
        'avg_delivery_rating', avg_delivery
    )::STRING;
    
    RETURN result_json;
END;
$$;

-- ============================================================================
-- Procedure 3: Asset Maintenance Prediction Wrapper
-- Model: ASSET_MAINTENANCE_PREDICTOR
-- Returns: JSON summary of ML predictions
-- ============================================================================

CREATE OR REPLACE PROCEDURE PREDICT_ASSET_MAINTENANCE(
    ASSET_TYPE VARCHAR
)
RETURNS STRING
LANGUAGE SQL
COMMENT = 'Calls ASSET_MAINTENANCE_PREDICTOR ML model to predict maintenance urgency'
AS
$$
DECLARE
    result_json STRING;
    total_count INTEGER;
    on_schedule INTEGER;
    due_soon INTEGER;
    overdue INTEGER;
    attention_pct FLOAT;
    avg_days FLOAT;
BEGIN
    WITH predictions AS (
        WITH m AS MODEL KRATOS_INTELLIGENCE.ANALYTICS.ASSET_MAINTENANCE_PREDICTOR
        SELECT 
            days_until_due,
            m!PREDICT(
                flight_hours, maint_interval, utilization_pct,
                days_since_maintenance, days_until_due, 
                condition_score, is_ready, ast_type
            ):PREDICTED_URGENCY::INT AS predicted_urgency
        FROM KRATOS_INTELLIGENCE.ANALYTICS.V_ASSET_MAINTENANCE_FEATURES
        WHERE (:ASSET_TYPE IS NULL OR :ASSET_TYPE = 'NULL' OR :ASSET_TYPE = '' OR UPPER(ast_type) = UPPER(:ASSET_TYPE))
        LIMIT 100
    )
    SELECT 
        COUNT(*),
        SUM(CASE WHEN predicted_urgency = 0 THEN 1 ELSE 0 END),
        SUM(CASE WHEN predicted_urgency = 1 THEN 1 ELSE 0 END),
        SUM(CASE WHEN predicted_urgency = 2 THEN 1 ELSE 0 END),
        ROUND(AVG(CASE WHEN predicted_urgency > 0 THEN days_until_due ELSE NULL END), 1)
    INTO total_count, on_schedule, due_soon, overdue, avg_days
    FROM predictions;
    
    IF (total_count > 0) THEN
        attention_pct := ROUND((due_soon + overdue) / total_count * 100, 2);
    ELSE
        attention_pct := 0;
    END IF;
    
    result_json := OBJECT_CONSTRUCT(
        'prediction_source', 'ASSET_MAINTENANCE_PREDICTOR ML Model',
        'asset_type_filter', COALESCE(:ASSET_TYPE, 'ALL'),
        'assets_analyzed', total_count,
        'predicted_on_schedule', on_schedule,
        'predicted_due_soon', due_soon,
        'predicted_overdue', overdue,
        'assets_needing_attention', due_soon + overdue,
        'attention_rate_pct', attention_pct,
        'avg_days_until_due_critical', COALESCE(avg_days, 0)
    )::STRING;
    
    RETURN result_json;
END;
$$;

-- ============================================================================
-- Display confirmation
-- ============================================================================

SELECT 'ML model wrapper procedures created successfully' AS status;

-- ============================================================================
-- Test Calls (run after models are registered via notebook)
-- These procedures return JSON summaries of real-time ML predictions
-- ============================================================================

-- Test PREDICT_PROGRAM_RISK
CALL PREDICT_PROGRAM_RISK('DEVELOPMENT');
CALL PREDICT_PROGRAM_RISK(NULL);  -- All program types

-- Test PREDICT_SUPPLIER_RISK
CALL PREDICT_SUPPLIER_RISK('TIER_1');
CALL PREDICT_SUPPLIER_RISK(NULL);  -- All supplier types

-- Test PREDICT_ASSET_MAINTENANCE
CALL PREDICT_ASSET_MAINTENANCE('AIRCRAFT');
CALL PREDICT_ASSET_MAINTENANCE(NULL);  -- All asset types

SELECT 'Test calls completed - verify ML prediction summaries in results' AS instruction;
