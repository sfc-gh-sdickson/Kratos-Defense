-- ============================================================================
-- Kratos Defense Intelligence Agent - ML Prediction Wrapper Functions
-- ============================================================================
-- Purpose: Create SQL procedures that query pre-computed ML predictions
--          These predictions are stored by the notebook after training models
-- 
-- CRITICAL: The notebook trains models AND stores predictions to:
--           - ANALYTICS.PROGRAM_RISK_PREDICTIONS
--           - ANALYTICS.SUPPLIER_RISK_PREDICTIONS  
--           - ANALYTICS.ASSET_MAINTENANCE_PREDICTIONS
--
-- This avoids the Python stored procedure limitations with Model Registry
-- (USE, SHOW statements blocked in stored procs)
--
-- WORKFLOW:
--   1. Run notebook to train models AND store predictions
--   2. Run this file to create procedures
--   3. Procedures query the prediction tables
-- ============================================================================

USE DATABASE KRATOS_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE KRATOS_WH;

-- ============================================================================
-- Procedure 1: Program Risk Prediction Wrapper
-- Queries: ANALYTICS.PROGRAM_RISK_PREDICTIONS (created by notebook)
-- Uses: PREDICTED_RISK from ML model (not just calculated risk_label)
-- ============================================================================

CREATE OR REPLACE PROCEDURE PREDICT_PROGRAM_RISK(
    PROGRAM_TYPE VARCHAR
)
RETURNS STRING
LANGUAGE SQL
COMMENT = 'Returns ML model predictions for program risk based on trained Random Forest model'
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
    -- Count programs by ML PREDICTED risk level
    SELECT 
        COUNT(*),
        SUM(CASE WHEN PREDICTED_RISK = 0 THEN 1 ELSE 0 END),
        SUM(CASE WHEN PREDICTED_RISK = 1 THEN 1 ELSE 0 END),
        SUM(CASE WHEN PREDICTED_RISK = 2 THEN 1 ELSE 0 END),
        SUM(CASE WHEN PREDICTED_RISK = 3 THEN 1 ELSE 0 END)
    INTO total_count, low_risk, medium_risk, high_risk, critical_risk
    FROM KRATOS_INTELLIGENCE.ANALYTICS.PROGRAM_RISK_PREDICTIONS
    WHERE (:PROGRAM_TYPE IS NULL OR PROG_TYPE = :PROGRAM_TYPE);
    
    IF (total_count > 0) THEN
        high_risk_pct := ROUND((high_risk + critical_risk) / total_count * 100, 2);
    ELSE
        high_risk_pct := 0;
    END IF;
    
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
-- Queries: ANALYTICS.SUPPLIER_RISK_PREDICTIONS (created by notebook)
-- Uses: PREDICTED_RISK from ML model
-- ============================================================================

CREATE OR REPLACE PROCEDURE PREDICT_SUPPLIER_RISK(
    SUPPLIER_TYPE VARCHAR
)
RETURNS STRING
LANGUAGE SQL
COMMENT = 'Returns ML model predictions for supplier risk based on trained Random Forest model'
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
    -- Count suppliers by ML PREDICTED risk level
    SELECT 
        COUNT(*),
        SUM(CASE WHEN PREDICTED_RISK = 0 THEN 1 ELSE 0 END),
        SUM(CASE WHEN PREDICTED_RISK = 1 THEN 1 ELSE 0 END),
        SUM(CASE WHEN PREDICTED_RISK = 2 THEN 1 ELSE 0 END),
        SUM(CASE WHEN PREDICTED_RISK = 3 THEN 1 ELSE 0 END),
        ROUND(AVG(QUALITY_SCORE), 2),
        ROUND(AVG(DELIVERY_SCORE), 2)
    INTO total_count, low_risk, medium_risk, high_risk, critical_risk, avg_quality, avg_delivery
    FROM KRATOS_INTELLIGENCE.ANALYTICS.SUPPLIER_RISK_PREDICTIONS
    WHERE (:SUPPLIER_TYPE IS NULL OR SUP_TYPE = :SUPPLIER_TYPE);
    
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
-- Queries: ANALYTICS.ASSET_MAINTENANCE_PREDICTIONS (created by notebook)
-- Uses: PREDICTED_URGENCY from ML model
-- ============================================================================

CREATE OR REPLACE PROCEDURE PREDICT_ASSET_MAINTENANCE(
    ASSET_TYPE VARCHAR
)
RETURNS STRING
LANGUAGE SQL
COMMENT = 'Returns ML model predictions for asset maintenance urgency based on trained Random Forest model'
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
    -- Count assets by ML PREDICTED urgency level
    SELECT 
        COUNT(*),
        SUM(CASE WHEN PREDICTED_URGENCY = 0 THEN 1 ELSE 0 END),
        SUM(CASE WHEN PREDICTED_URGENCY = 1 THEN 1 ELSE 0 END),
        SUM(CASE WHEN PREDICTED_URGENCY = 2 THEN 1 ELSE 0 END),
        ROUND(AVG(CASE WHEN PREDICTED_URGENCY > 0 THEN DAYS_UNTIL_DUE ELSE NULL END), 1)
    INTO total_count, on_schedule, due_soon, overdue, avg_days
    FROM KRATOS_INTELLIGENCE.ANALYTICS.ASSET_MAINTENANCE_PREDICTIONS
    WHERE (:ASSET_TYPE IS NULL OR AST_TYPE = :ASSET_TYPE);
    
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

SELECT 'ML model wrapper functions created successfully' AS status;

-- ============================================================================
-- Test Calls (uncomment after models are registered via notebook)
-- ============================================================================

-- Test PREDICT_PROGRAM_RISK
CALL PREDICT_PROGRAM_RISK('DEVELOPMENT');
CALL PREDICT_PROGRAM_RISK(NULL);

-- Test PREDICT_SUPPLIER_RISK
CALL PREDICT_SUPPLIER_RISK('TIER_1');
CALL PREDICT_SUPPLIER_RISK(NULL);

-- Test PREDICT_ASSET_MAINTENANCE
CALL PREDICT_ASSET_MAINTENANCE('AIRCRAFT');
CALL PREDICT_ASSET_MAINTENANCE(NULL);

SELECT 'Test calls completed - verify results above' AS instruction;

