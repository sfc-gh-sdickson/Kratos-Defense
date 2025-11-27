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
-- Model: PROGRAM_RISK_PREDICTOR (Random Forest Classifier)
-- Features: budget, spent, variance, schedule_variance, completion_pct,
--           total_milestones, milestone_pct, budget_utilization, prog_type
-- ============================================================================

CREATE OR REPLACE PROCEDURE PREDICT_PROGRAM_RISK(
    PROGRAM_TYPE VARCHAR
)
RETURNS TABLE()
LANGUAGE SQL
COMMENT = 'Calls PROGRAM_RISK_PREDICTOR ML model to predict program risk levels'
AS
$$
DECLARE
    res RESULTSET;
BEGIN
    res := (
        WITH m AS MODEL KRATOS_INTELLIGENCE.ANALYTICS.PROGRAM_RISK_PREDICTOR
        SELECT 
            program_id,
            prog_type,
            budget,
            spent,
            completion_pct,
            m!PREDICT(
                budget, spent, variance, schedule_variance,
                completion_pct, total_milestones, milestone_pct, 
                budget_utilization, prog_type
            ):PREDICTED_RISK::INT AS predicted_risk
        FROM KRATOS_INTELLIGENCE.ANALYTICS.V_PROGRAM_RISK_FEATURES
        WHERE (:PROGRAM_TYPE IS NULL OR prog_type = :PROGRAM_TYPE)
        LIMIT 100
    );
    RETURN TABLE(res);
END;
$$;

-- ============================================================================
-- Procedure 2: Supplier Risk Prediction Wrapper
-- Model: SUPPLIER_RISK_PREDICTOR (Random Forest Classifier)
-- Features: quality_score, delivery_score, overall_rating, order_count,
--           total_spend, avg_order_value, payment_terms, sup_type
-- ============================================================================

CREATE OR REPLACE PROCEDURE PREDICT_SUPPLIER_RISK(
    SUPPLIER_TYPE VARCHAR
)
RETURNS TABLE()
LANGUAGE SQL
COMMENT = 'Calls SUPPLIER_RISK_PREDICTOR ML model to predict supplier risk levels'
AS
$$
DECLARE
    res RESULTSET;
BEGIN
    res := (
        WITH m AS MODEL KRATOS_INTELLIGENCE.ANALYTICS.SUPPLIER_RISK_PREDICTOR
        SELECT 
            supplier_id,
            sup_type,
            quality_score,
            delivery_score,
            total_spend,
            m!PREDICT(
                quality_score, delivery_score, overall_rating,
                order_count, total_spend, avg_order_value,
                payment_terms, sup_type
            ):PREDICTED_RISK::INT AS predicted_risk
        FROM KRATOS_INTELLIGENCE.ANALYTICS.V_SUPPLIER_RISK_FEATURES
        WHERE (:SUPPLIER_TYPE IS NULL OR sup_type = :SUPPLIER_TYPE)
        LIMIT 100
    );
    RETURN TABLE(res);
END;
$$;

-- ============================================================================
-- Procedure 3: Asset Maintenance Prediction Wrapper
-- Model: ASSET_MAINTENANCE_PREDICTOR (Random Forest Classifier)
-- Features: flight_hours, maint_interval, utilization_pct, days_since_maintenance,
--           days_until_due, condition_score, is_ready, ast_type
-- ============================================================================

CREATE OR REPLACE PROCEDURE PREDICT_ASSET_MAINTENANCE(
    ASSET_TYPE VARCHAR
)
RETURNS TABLE()
LANGUAGE SQL
COMMENT = 'Calls ASSET_MAINTENANCE_PREDICTOR ML model to predict maintenance urgency'
AS
$$
DECLARE
    res RESULTSET;
BEGIN
    res := (
        WITH m AS MODEL KRATOS_INTELLIGENCE.ANALYTICS.ASSET_MAINTENANCE_PREDICTOR
        SELECT 
            asset_id,
            ast_type,
            flight_hours,
            condition_score,
            days_until_due,
            m!PREDICT(
                flight_hours, maint_interval, utilization_pct,
                days_since_maintenance, days_until_due, 
                condition_score, is_ready, ast_type
            ):PREDICTED_URGENCY::INT AS predicted_urgency
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

SELECT 'ML model wrapper procedures created successfully' AS status;

-- ============================================================================
-- Test Calls (run after models are registered via notebook)
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

SELECT 'Test calls completed - verify ML predictions in results above' AS instruction;
