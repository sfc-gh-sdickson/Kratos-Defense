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
LANGUAGE PYTHON
RUNTIME_VERSION = '3.10'
PACKAGES = ('snowflake-ml-python', 'scikit-learn')
HANDLER = 'predict_program_risk'
COMMENT = 'Calls PROGRAM_RISK_PREDICTOR model to predict risk level for programs'
AS
$$
def predict_program_risk(session, program_type):
    from snowflake.ml.registry import Registry
    import json
    
    # Get model from registry
    reg = Registry(session)
    model = reg.get_model("PROGRAM_RISK_PREDICTOR").default
    
    # Build query using FEATURE VIEW - NEVER define features inline!
    # The view already has filters built in, just add optional type filter
    type_filter = f"WHERE prog_type = '{program_type}'" if program_type else ""
    
    query = f"""
    SELECT * FROM ANALYTICS.V_PROGRAM_RISK_FEATURES
    {type_filter}
    LIMIT 50
    """
    
    input_df = session.sql(query)
    
    if input_df.count() == 0:
        return json.dumps({
            "error": "No active programs found for prediction",
            "program_type_filter": program_type
        })
    
    # Get predictions
    predictions = model.run(input_df, function_name="predict")
    
    # Analyze predictions
    result = predictions.select("PREDICTED_RISK", "PROG_TYPE").to_pandas()
    
    # Count by predicted risk
    low_risk = int((result['PREDICTED_RISK'] == 0).sum())
    medium_risk = int((result['PREDICTED_RISK'] == 1).sum())
    high_risk = int((result['PREDICTED_RISK'] == 2).sum())
    critical_risk = int((result['PREDICTED_RISK'] == 3).sum())
    total_count = len(result)
    
    return json.dumps({
        "program_type_filter": program_type or "ALL",
        "programs_analyzed": total_count,
        "predicted_low_risk": low_risk,
        "predicted_medium_risk": medium_risk,
        "predicted_high_risk": high_risk,
        "predicted_critical_risk": critical_risk,
        "high_risk_pct": round((high_risk + critical_risk) / total_count * 100, 2) if total_count > 0 else 0
    })
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
LANGUAGE PYTHON
RUNTIME_VERSION = '3.10'
PACKAGES = ('snowflake-ml-python', 'scikit-learn')
HANDLER = 'predict_supplier_risk'
COMMENT = 'Calls SUPPLIER_RISK_PREDICTOR model to identify suppliers at risk'
AS
$$
def predict_supplier_risk(session, supplier_type):
    from snowflake.ml.registry import Registry
    import json
    
    # Get model from registry
    reg = Registry(session)
    model = reg.get_model("SUPPLIER_RISK_PREDICTOR").default
    
    # Build query using FEATURE VIEW - NEVER define features inline!
    # The view already has filters built in, just add optional type filter
    type_filter = f"WHERE sup_type = '{supplier_type}'" if supplier_type else ""
    
    query = f"""
    SELECT * FROM ANALYTICS.V_SUPPLIER_RISK_FEATURES
    {type_filter}
    LIMIT 50
    """
    
    input_df = session.sql(query)
    
    if input_df.count() == 0:
        return json.dumps({
            "error": "No active suppliers found for prediction",
            "supplier_type_filter": supplier_type
        })
    
    # Get predictions
    predictions = model.run(input_df, function_name="predict")
    
    # Analyze predictions
    result = predictions.select("PREDICTED_RISK", "SUP_TYPE", "QUALITY_SCORE", "DELIVERY_SCORE").to_pandas()
    
    # Count by predicted risk
    low_risk = int((result['PREDICTED_RISK'] == 0).sum())
    medium_risk = int((result['PREDICTED_RISK'] == 1).sum())
    high_risk = int((result['PREDICTED_RISK'] == 2).sum())
    critical_risk = int((result['PREDICTED_RISK'] == 3).sum())
    total_count = len(result)
    avg_quality = round(result['QUALITY_SCORE'].mean(), 2)
    avg_delivery = round(result['DELIVERY_SCORE'].mean(), 2)
    
    return json.dumps({
        "supplier_type_filter": supplier_type or "ALL",
        "suppliers_analyzed": total_count,
        "predicted_low_risk": low_risk,
        "predicted_medium_risk": medium_risk,
        "predicted_high_risk": high_risk,
        "predicted_critical_risk": critical_risk,
        "at_risk_suppliers": high_risk + critical_risk,
        "avg_quality_rating": avg_quality,
        "avg_delivery_rating": avg_delivery
    })
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
LANGUAGE PYTHON
RUNTIME_VERSION = '3.10'
PACKAGES = ('snowflake-ml-python', 'scikit-learn')
HANDLER = 'predict_maintenance'
COMMENT = 'Calls ASSET_MAINTENANCE_PREDICTOR model to predict maintenance urgency'
AS
$$
def predict_maintenance(session, asset_type):
    from snowflake.ml.registry import Registry
    import json
    
    # Get model from registry
    reg = Registry(session)
    model = reg.get_model("ASSET_MAINTENANCE_PREDICTOR").default
    
    # Build query using FEATURE VIEW - NEVER define features inline!
    # The view already has filters built in, just add optional type filter
    type_filter = f"WHERE ast_type = '{asset_type}'" if asset_type else ""
    
    query = f"""
    SELECT * FROM ANALYTICS.V_ASSET_MAINTENANCE_FEATURES
    {type_filter}
    LIMIT 100
    """
    
    input_df = session.sql(query)
    
    if input_df.count() == 0:
        return json.dumps({
            "error": "No assets found for maintenance prediction",
            "asset_type_filter": asset_type
        })
    
    # Get predictions
    predictions = model.run(input_df, function_name="predict")
    
    # Analyze predictions
    result = predictions.select("PREDICTED_URGENCY", "AST_TYPE", "DAYS_UNTIL_DUE").to_pandas()
    
    # Count by predicted urgency
    on_schedule = int((result['PREDICTED_URGENCY'] == 0).sum())
    due_soon = int((result['PREDICTED_URGENCY'] == 1).sum())
    overdue = int((result['PREDICTED_URGENCY'] == 2).sum())
    total_count = len(result)
    
    # Calculate average days until due for assets needing attention
    needs_attention = result[result['PREDICTED_URGENCY'] > 0]
    avg_days_critical = round(needs_attention['DAYS_UNTIL_DUE'].mean(), 1) if len(needs_attention) > 0 else 0
    
    return json.dumps({
        "asset_type_filter": asset_type or "ALL",
        "assets_analyzed": total_count,
        "on_schedule": on_schedule,
        "due_soon": due_soon,
        "overdue": overdue,
        "assets_needing_attention": due_soon + overdue,
        "attention_rate_pct": round((due_soon + overdue) / total_count * 100, 2) if total_count > 0 else 0,
        "avg_days_until_due_for_critical": avg_days_critical
    })
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

