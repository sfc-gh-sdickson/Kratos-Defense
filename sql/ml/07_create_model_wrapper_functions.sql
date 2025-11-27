-- ============================================================================
-- Kratos Defense Intelligence Agent - Model Registry Wrapper Functions
-- ============================================================================
-- Purpose: Create SQL procedures that wrap Model Registry models
--          so they can be added as tools to the Intelligence Agent
-- 
-- IMPORTANT: These wrapper functions MUST match the models created in:
--            notebooks/kratos_ml_models.ipynb
--
-- CRITICAL: Parameter names MUST match the agent tool input_schema in file 08
--
-- COLUMN VERIFICATION: All column names verified against 02_create_tables.sql
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
-- Matches: PROGRAM_RISK_PREDICTOR model from notebook
-- 
-- VERIFIED COLUMNS from 02_create_tables.sql PROGRAMS table:
--   budget_amount, spent_amount, budget_variance, schedule_variance_days,
--   percent_complete, milestone_count, milestones_completed, risk_level
-- 
-- PARAMETER NAME: program_type (matches agent tool input_schema)
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
    
    # Build query with optional filter
    type_filter = f"AND program_type = '{program_type}'" if program_type else ""
    
    # Query uses VERIFIED column names from 02_create_tables.sql PROGRAMS table
    query = f"""
    SELECT
        p.program_id,
        p.budget_amount::FLOAT AS budget,
        p.spent_amount::FLOAT AS spent,
        p.budget_variance::FLOAT AS variance,
        p.schedule_variance_days::FLOAT AS schedule_variance,
        p.percent_complete::FLOAT AS completion_pct,
        p.milestone_count::FLOAT AS total_milestones,
        COALESCE((p.milestones_completed::FLOAT / NULLIF(p.milestone_count, 0) * 100), 0)::FLOAT AS milestone_pct,
        (p.spent_amount::FLOAT / NULLIF(p.budget_amount, 0) * 100)::FLOAT AS budget_utilization,
        p.program_type AS prog_type,
        -- Label for reference (will not be used in prediction)
        CASE p.risk_level
            WHEN 'LOW' THEN 0
            WHEN 'MEDIUM' THEN 1
            WHEN 'HIGH' THEN 2
            ELSE 3
        END AS risk_label
    FROM RAW.PROGRAMS p
    WHERE p.program_status = 'ACTIVE'
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
    
    # Map numeric predictions back to risk levels
    risk_map = {0: 'LOW', 1: 'MEDIUM', 2: 'HIGH', 3: 'CRITICAL'}
    
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
-- Matches: SUPPLIER_RISK_PREDICTOR model from notebook
-- 
-- VERIFIED COLUMNS from 02_create_tables.sql SUPPLIERS table:
--   quality_rating, delivery_rating, total_orders, total_spend, risk_rating
-- 
-- PARAMETER NAME: supplier_type (matches agent tool input_schema)
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
    
    # Build query with optional filter
    type_filter = f"AND supplier_type = '{supplier_type}'" if supplier_type else ""
    
    # Query uses VERIFIED column names from 02_create_tables.sql SUPPLIERS table
    query = f"""
    SELECT
        s.supplier_id,
        s.quality_rating::FLOAT AS quality_score,
        s.delivery_rating::FLOAT AS delivery_score,
        ((s.quality_rating + s.delivery_rating) / 2)::FLOAT AS overall_rating,
        s.total_orders::FLOAT AS order_count,
        s.total_spend::FLOAT AS total_spend,
        (s.total_spend::FLOAT / NULLIF(s.total_orders, 0))::FLOAT AS avg_order_value,
        s.supplier_type AS sup_type,
        -- Label for reference
        CASE s.risk_rating
            WHEN 'LOW' THEN 0
            WHEN 'MEDIUM' THEN 1
            WHEN 'HIGH' THEN 2
            ELSE 3
        END AS risk_label
    FROM RAW.SUPPLIERS s
    WHERE s.supplier_status IN ('ACTIVE', 'PREFERRED', 'PROBATION')
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
-- Matches: ASSET_MAINTENANCE_PREDICTOR model from notebook
-- 
-- VERIFIED COLUMNS from 02_create_tables.sql ASSETS table:
--   total_flight_hours, maintenance_interval_hours, last_maintenance_date,
--   next_maintenance_due, condition_rating, mission_ready
-- 
-- PARAMETER NAME: asset_type (matches agent tool input_schema)
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
    
    # Build query with optional filter
    type_filter = f"AND asset_type = '{asset_type}'" if asset_type else ""
    
    # Query uses VERIFIED column names from 02_create_tables.sql ASSETS table
    query = f"""
    SELECT
        a.asset_id,
        a.total_flight_hours::FLOAT AS flight_hours,
        a.maintenance_interval_hours::FLOAT AS maint_interval,
        (a.total_flight_hours::FLOAT / NULLIF(a.maintenance_interval_hours, 0) * 100)::FLOAT AS utilization_pct,
        DATEDIFF('day', a.last_maintenance_date, CURRENT_DATE())::FLOAT AS days_since_maintenance,
        DATEDIFF('day', CURRENT_DATE(), a.next_maintenance_due)::FLOAT AS days_until_due,
        CASE a.condition_rating
            WHEN 'EXCELLENT' THEN 4
            WHEN 'GOOD' THEN 3
            WHEN 'FAIR' THEN 2
            ELSE 1
        END::FLOAT AS condition_score,
        CASE WHEN a.mission_ready = TRUE THEN 1 ELSE 0 END::FLOAT AS is_ready,
        a.asset_type AS ast_type,
        -- Synthetic urgency label for training
        CASE 
            WHEN DATEDIFF('day', CURRENT_DATE(), a.next_maintenance_due) < 0 THEN 2  -- OVERDUE
            WHEN DATEDIFF('day', CURRENT_DATE(), a.next_maintenance_due) <= 14 THEN 1  -- DUE_SOON
            ELSE 0  -- ON_SCHEDULE
        END AS urgency_label
    FROM RAW.ASSETS a
    WHERE a.asset_status IN ('OPERATIONAL', 'MAINTENANCE', 'STANDBY')
      AND a.next_maintenance_due IS NOT NULL
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
    
    # Map predictions
    urgency_map = {0: 'ON_SCHEDULE', 1: 'DUE_SOON', 2: 'OVERDUE'}
    
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

