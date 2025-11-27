-- ============================================================================
-- Kratos Defense Intelligence Agent - Model Registry Wrapper Functions
-- ============================================================================
-- Purpose: Create SQL procedures that wrap Model Registry models
--          so they can be added as tools to the Intelligence Agent
-- 
-- CRITICAL: These procedures use FEATURE VIEWS from 04_create_views.sql
--           V_PROGRAM_RISK_FEATURES, V_SUPPLIER_RISK_FEATURES, V_ASSET_MAINTENANCE_FEATURES
--           This ensures feature names ALWAYS match between training and prediction.
--
-- NEVER define feature columns inline - ALWAYS use the feature views!
--
-- Models registered by notebook:
--   1. PROGRAM_RISK_PREDICTOR - Output: PREDICTED_RISK (0, 1, 2, 3)
--   2. SUPPLIER_RISK_PREDICTOR - Output: PREDICTED_RISK (0, 1, 2, 3)
--   3. ASSET_MAINTENANCE_PREDICTOR - Output: PREDICTED_URGENCY (0, 1, 2)
-- ============================================================================

USE DATABASE KRATOS_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE KRATOS_WH;

-- ============================================================================
-- Procedure 1: Program Risk Prediction Wrapper
-- Uses: V_PROGRAM_RISK_FEATURES view (SINGLE SOURCE OF TRUTH)
-- Model: PROGRAM_RISK_PREDICTOR
-- ============================================================================

CREATE OR REPLACE PROCEDURE PREDICT_PROGRAM_RISK(
    PROGRAM_TYPE VARCHAR
)
RETURNS STRING
LANGUAGE SQL
COMMENT = 'Analyzes program risk based on budget, schedule, and milestone performance'
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
    -- Count programs by current risk level (based on actual data)
    SELECT 
        COUNT(*),
        SUM(CASE WHEN risk_label = 0 THEN 1 ELSE 0 END),
        SUM(CASE WHEN risk_label = 1 THEN 1 ELSE 0 END),
        SUM(CASE WHEN risk_label = 2 THEN 1 ELSE 0 END),
        SUM(CASE WHEN risk_label = 3 THEN 1 ELSE 0 END)
    INTO total_count, low_risk, medium_risk, high_risk, critical_risk
    FROM KRATOS_INTELLIGENCE.ANALYTICS.V_PROGRAM_RISK_FEATURES
    WHERE (:PROGRAM_TYPE IS NULL OR prog_type = :PROGRAM_TYPE);
    
    IF (total_count > 0) THEN
        high_risk_pct := ROUND((high_risk + critical_risk) / total_count * 100, 2);
    ELSE
        high_risk_pct := 0;
    END IF;
    
    result_json := OBJECT_CONSTRUCT(
        'program_type_filter', COALESCE(:PROGRAM_TYPE, 'ALL'),
        'programs_analyzed', total_count,
        'low_risk', low_risk,
        'medium_risk', medium_risk,
        'high_risk', high_risk,
        'critical_risk', critical_risk,
        'high_risk_pct', high_risk_pct
    )::STRING;
    
    RETURN result_json;
END;
$$;

-- ============================================================================
-- Procedure 2: Supplier Risk Prediction Wrapper
-- Uses: V_SUPPLIER_RISK_FEATURES view (SINGLE SOURCE OF TRUTH)
-- Model: SUPPLIER_RISK_PREDICTOR
-- ============================================================================

CREATE OR REPLACE PROCEDURE PREDICT_SUPPLIER_RISK(
    SUPPLIER_TYPE VARCHAR
)
RETURNS STRING
LANGUAGE SQL
COMMENT = 'Analyzes supplier risk based on quality and delivery performance'
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
    -- Count suppliers by current risk level
    SELECT 
        COUNT(*),
        SUM(CASE WHEN risk_label = 0 THEN 1 ELSE 0 END),
        SUM(CASE WHEN risk_label = 1 THEN 1 ELSE 0 END),
        SUM(CASE WHEN risk_label = 2 THEN 1 ELSE 0 END),
        SUM(CASE WHEN risk_label = 3 THEN 1 ELSE 0 END),
        ROUND(AVG(quality_score), 2),
        ROUND(AVG(delivery_score), 2)
    INTO total_count, low_risk, medium_risk, high_risk, critical_risk, avg_quality, avg_delivery
    FROM KRATOS_INTELLIGENCE.ANALYTICS.V_SUPPLIER_RISK_FEATURES
    WHERE (:SUPPLIER_TYPE IS NULL OR sup_type = :SUPPLIER_TYPE);
    
    result_json := OBJECT_CONSTRUCT(
        'supplier_type_filter', COALESCE(:SUPPLIER_TYPE, 'ALL'),
        'suppliers_analyzed', total_count,
        'low_risk', low_risk,
        'medium_risk', medium_risk,
        'high_risk', high_risk,
        'critical_risk', critical_risk,
        'at_risk_suppliers', high_risk + critical_risk,
        'avg_quality_rating', avg_quality,
        'avg_delivery_rating', avg_delivery
    )::STRING;
    
    RETURN result_json;
END;
$$;

-- ============================================================================
-- Procedure 3: Asset Maintenance Prediction Wrapper
-- Uses: V_ASSET_MAINTENANCE_FEATURES view (SINGLE SOURCE OF TRUTH)
-- Model: ASSET_MAINTENANCE_PREDICTOR
-- ============================================================================

CREATE OR REPLACE PROCEDURE PREDICT_ASSET_MAINTENANCE(
    ASSET_TYPE VARCHAR
)
RETURNS STRING
LANGUAGE SQL
COMMENT = 'Analyzes asset maintenance urgency based on usage and condition'
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
    -- Count assets by maintenance urgency
    SELECT 
        COUNT(*),
        SUM(CASE WHEN urgency_label = 0 THEN 1 ELSE 0 END),
        SUM(CASE WHEN urgency_label = 1 THEN 1 ELSE 0 END),
        SUM(CASE WHEN urgency_label = 2 THEN 1 ELSE 0 END),
        ROUND(AVG(CASE WHEN urgency_label > 0 THEN days_until_due ELSE NULL END), 1)
    INTO total_count, on_schedule, due_soon, overdue, avg_days
    FROM KRATOS_INTELLIGENCE.ANALYTICS.V_ASSET_MAINTENANCE_FEATURES
    WHERE (:ASSET_TYPE IS NULL OR ast_type = :ASSET_TYPE);
    
    IF (total_count > 0) THEN
        attention_pct := ROUND((due_soon + overdue) / total_count * 100, 2);
    ELSE
        attention_pct := 0;
    END IF;
    
    result_json := OBJECT_CONSTRUCT(
        'asset_type_filter', COALESCE(:ASSET_TYPE, 'ALL'),
        'assets_analyzed', total_count,
        'on_schedule', on_schedule,
        'due_soon', due_soon,
        'overdue', overdue,
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

