-- ============================================================================
-- Kratos Defense Intelligence Agent - ML Model Wrapper Functions
-- ============================================================================
-- Purpose: Create stored procedures that wrap ML models for use with the
--          Intelligence Agent. These procedures can be added as tools.
--
-- CRITICAL: Column names MUST match EXACTLY what the models expect!
-- Reference: notebooks/kratos_ml_models.ipynb for model input columns
-- ============================================================================

USE DATABASE KRATOS_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE KRATOS_WH;

-- ============================================================================
-- Wrapper 1: Program Risk Predictor
-- ============================================================================
CREATE OR REPLACE PROCEDURE PREDICT_PROGRAM_RISK(PROGRAM_ID_INPUT VARCHAR)
RETURNS TABLE (
    program_id VARCHAR,
    program_name VARCHAR,
    program_type VARCHAR,
    risk_level VARCHAR,
    cost_variance FLOAT,
    schedule_variance FLOAT,
    predicted_risk NUMBER,
    risk_assessment VARCHAR
)
LANGUAGE PYTHON
RUNTIME_VERSION = '3.10'
PACKAGES = ('snowflake-snowpark-python', 'snowflake-ml-python')
HANDLER = 'predict_program_risk'
AS
$$
from snowflake.snowpark import Session
from snowflake.ml.registry import Registry
import pandas as pd

def predict_program_risk(session: Session, program_id_input: str):
    """Predict risk for a specific program using the trained model."""
    
    # Query program data - COLUMN NAMES VERIFIED against 02_create_tables.sql
    query = f"""
    SELECT
        p.program_id,
        p.program_name,
        DATEDIFF('day', p.start_date, COALESCE(p.planned_end_date, CURRENT_DATE()))::FLOAT AS program_duration_days,
        p.total_contract_value::FLOAT AS contract_value,
        p.funded_value::FLOAT AS funded_value,
        COALESCE(p.cost_variance_pct, 0)::FLOAT AS cost_variance,
        COALESCE(p.schedule_variance_pct, 0)::FLOAT AS schedule_variance,
        COALESCE(p.technology_readiness_level, 5)::FLOAT AS trl,
        p.program_type,
        p.classification_level AS classification,
        p.risk_level
    FROM RAW.PROGRAMS p
    WHERE p.program_id = '{program_id_input}'
    """
    
    program_df = session.sql(query)
    
    if program_df.count() == 0:
        return session.create_dataframe([{
            'PROGRAM_ID': program_id_input,
            'PROGRAM_NAME': 'NOT FOUND',
            'PROGRAM_TYPE': None,
            'RISK_LEVEL': None,
            'COST_VARIANCE': None,
            'SCHEDULE_VARIANCE': None,
            'PREDICTED_RISK': -1,
            'RISK_ASSESSMENT': 'Program not found'
        }])
    
    # Get model from registry
    reg = Registry(session)
    model = reg.get_model("PROGRAM_RISK_PREDICTOR").version("V1")
    
    # Prepare features for prediction - drop ID columns
    features_df = program_df.drop("PROGRAM_ID", "PROGRAM_NAME", "RISK_LEVEL")
    
    # Run prediction
    predictions = model.run(features_df, function_name="predict")
    
    # Get prediction result
    pred_pd = predictions.to_pandas()
    predicted_risk = int(pred_pd['PREDICTED_RISK'].iloc[0]) if 'PREDICTED_RISK' in pred_pd.columns else 0
    
    # Get original program info
    prog_pd = program_df.to_pandas()
    
    # Create result
    result = [{
        'PROGRAM_ID': prog_pd['PROGRAM_ID'].iloc[0],
        'PROGRAM_NAME': prog_pd['PROGRAM_NAME'].iloc[0],
        'PROGRAM_TYPE': prog_pd['PROGRAM_TYPE'].iloc[0],
        'RISK_LEVEL': prog_pd['RISK_LEVEL'].iloc[0],
        'COST_VARIANCE': float(prog_pd['COST_VARIANCE'].iloc[0]),
        'SCHEDULE_VARIANCE': float(prog_pd['SCHEDULE_VARIANCE'].iloc[0]),
        'PREDICTED_RISK': predicted_risk,
        'RISK_ASSESSMENT': 'HIGH RISK - Schedule or cost issues likely' if predicted_risk == 1 else 'LOW RISK - Program on track'
    }]
    
    return session.create_dataframe(result)
$$;

-- ============================================================================
-- Wrapper 2: Supplier Risk Predictor
-- ============================================================================
CREATE OR REPLACE PROCEDURE PREDICT_SUPPLIER_RISK(SUPPLIER_ID_INPUT VARCHAR)
RETURNS TABLE (
    supplier_id VARCHAR,
    supplier_name VARCHAR,
    supplier_type VARCHAR,
    quality_rating FLOAT,
    delivery_rating FLOAT,
    predicted_risk NUMBER,
    risk_assessment VARCHAR
)
LANGUAGE PYTHON
RUNTIME_VERSION = '3.10'
PACKAGES = ('snowflake-snowpark-python', 'snowflake-ml-python')
HANDLER = 'predict_supplier_risk'
AS
$$
from snowflake.snowpark import Session
from snowflake.ml.registry import Registry
import pandas as pd

def predict_supplier_risk(session: Session, supplier_id_input: str):
    """Predict risk for a specific supplier using the trained model."""
    
    # Query supplier data - COLUMN NAMES VERIFIED against 02_create_tables.sql
    query = f"""
    WITH supplier_metrics AS (
        SELECT
            s.supplier_id,
            s.supplier_name,
            s.supplier_tier::FLOAT AS supplier_tier,
            COALESCE(s.quality_rating, 75)::FLOAT AS quality_rating,
            COALESCE(s.delivery_rating, 75)::FLOAT AS delivery_rating,
            COALESCE(s.overall_rating, 75)::FLOAT AS overall_rating,
            s.supplier_type,
            CASE WHEN s.is_small_business = TRUE THEN 1 ELSE 0 END AS is_small_business,
            COALESCE(AVG(sp.quality_score), 75)::FLOAT AS avg_quality_score,
            COALESCE(AVG(sp.on_time_delivery_pct), 85)::FLOAT AS avg_otd_pct,
            COALESCE(AVG(sp.defect_rate_pct), 2)::FLOAT AS avg_defect_rate,
            COALESCE(SUM(sp.total_orders), 0)::FLOAT AS total_orders,
            COALESCE(SUM(sp.late_orders), 0)::FLOAT AS late_orders,
            COALESCE(SUM(sp.corrective_actions_issued), 0)::FLOAT AS cars_issued
        FROM RAW.SUPPLIERS s
        LEFT JOIN RAW.SUPPLIER_PERFORMANCE sp ON s.supplier_id = sp.supplier_id
        WHERE s.supplier_id = '{supplier_id_input}'
        GROUP BY s.supplier_id, s.supplier_name, s.supplier_tier, s.quality_rating, 
                 s.delivery_rating, s.overall_rating, s.supplier_type, s.is_small_business
    )
    SELECT * FROM supplier_metrics
    """
    
    supplier_df = session.sql(query)
    
    if supplier_df.count() == 0:
        return session.create_dataframe([{
            'SUPPLIER_ID': supplier_id_input,
            'SUPPLIER_NAME': 'NOT FOUND',
            'SUPPLIER_TYPE': None,
            'QUALITY_RATING': None,
            'DELIVERY_RATING': None,
            'PREDICTED_RISK': -1,
            'RISK_ASSESSMENT': 'Supplier not found'
        }])
    
    # Get model from registry
    reg = Registry(session)
    model = reg.get_model("SUPPLIER_RISK_PREDICTOR").version("V1")
    
    # Prepare features for prediction - drop ID and name columns
    features_df = supplier_df.drop("SUPPLIER_ID", "SUPPLIER_NAME")
    
    # Run prediction
    predictions = model.run(features_df, function_name="predict")
    
    # Get prediction result
    pred_pd = predictions.to_pandas()
    predicted_risk = int(pred_pd['PREDICTED_RISK'].iloc[0]) if 'PREDICTED_RISK' in pred_pd.columns else 0
    
    # Get original supplier info
    sup_pd = supplier_df.to_pandas()
    
    # Create result
    result = [{
        'SUPPLIER_ID': sup_pd['SUPPLIER_ID'].iloc[0],
        'SUPPLIER_NAME': sup_pd['SUPPLIER_NAME'].iloc[0],
        'SUPPLIER_TYPE': sup_pd['SUPPLIER_TYPE'].iloc[0],
        'QUALITY_RATING': float(sup_pd['QUALITY_RATING'].iloc[0]),
        'DELIVERY_RATING': float(sup_pd['DELIVERY_RATING'].iloc[0]),
        'PREDICTED_RISK': predicted_risk,
        'RISK_ASSESSMENT': 'HIGH RISK - Quality or delivery issues likely' if predicted_risk == 1 else 'LOW RISK - Supplier performing well'
    }]
    
    return session.create_dataframe(result)
$$;

-- ============================================================================
-- Wrapper 3: Production Forecaster
-- ============================================================================
CREATE OR REPLACE PROCEDURE FORECAST_PRODUCTION(FORECAST_MONTH NUMBER, FORECAST_YEAR NUMBER)
RETURNS TABLE (
    month_num NUMBER,
    year_num NUMBER,
    historical_avg_orders FLOAT,
    forecasted_production FLOAT,
    forecast_assessment VARCHAR
)
LANGUAGE PYTHON
RUNTIME_VERSION = '3.10'
PACKAGES = ('snowflake-snowpark-python', 'snowflake-ml-python')
HANDLER = 'forecast_production'
AS
$$
from snowflake.snowpark import Session
from snowflake.ml.registry import Registry
import pandas as pd

def forecast_production(session: Session, forecast_month: int, forecast_year: int):
    """Forecast production for a specific month using the trained model."""
    
    # Get historical data for the same month to use as features
    query = f"""
    SELECT
        {forecast_month}::FLOAT AS month_num,
        {forecast_year}::FLOAT AS year_num,
        COALESCE(AVG(wo_count), 100)::FLOAT AS work_order_count,
        COALESCE(AVG(qty_ord), 1000)::FLOAT AS total_quantity_ordered,
        COALESCE(AVG(qty_comp), 800)::FLOAT AS total_quantity_completed,
        COALESCE(AVG(est_hrs), 100)::FLOAT AS avg_estimated_hours,
        COALESCE(AVG(act_hrs), 100)::FLOAT AS avg_actual_hours,
        COALESCE(AVG(est_cost), 1000000)::FLOAT AS total_estimated_cost
    FROM (
        SELECT
            COUNT(DISTINCT work_order_id) AS wo_count,
            SUM(quantity_ordered) AS qty_ord,
            SUM(quantity_completed) AS qty_comp,
            AVG(estimated_hours) AS est_hrs,
            AVG(actual_hours) AS act_hrs,
            SUM(estimated_cost) AS est_cost
        FROM RAW.PRODUCTION_ORDERS
        WHERE MONTH(planned_start_date) = {forecast_month}
          AND planned_start_date >= DATEADD('year', -3, CURRENT_DATE())
          AND work_order_status IN ('COMPLETED', 'IN_PROGRESS')
        GROUP BY YEAR(planned_start_date)
    ) historical
    """
    
    features_df = session.sql(query)
    
    # Get model from registry
    reg = Registry(session)
    model = reg.get_model("PRODUCTION_FORECASTER").version("V1")
    
    # Run prediction
    predictions = model.run(features_df, function_name="predict")
    
    # Get prediction result
    pred_pd = predictions.to_pandas()
    forecasted = float(pred_pd['PREDICTED_PRODUCTION'].iloc[0]) if 'PREDICTED_PRODUCTION' in pred_pd.columns else 0
    
    # Get historical average
    hist_pd = features_df.to_pandas()
    historical_avg = float(hist_pd['WORK_ORDER_COUNT'].iloc[0])
    
    # Determine assessment
    if forecasted > historical_avg * 1.1:
        assessment = f"INCREASED production expected - {forecasted:.0f} work orders (above historical avg of {historical_avg:.0f})"
    elif forecasted < historical_avg * 0.9:
        assessment = f"DECREASED production expected - {forecasted:.0f} work orders (below historical avg of {historical_avg:.0f})"
    else:
        assessment = f"STABLE production expected - {forecasted:.0f} work orders (near historical avg of {historical_avg:.0f})"
    
    # Create result
    result = [{
        'MONTH_NUM': forecast_month,
        'YEAR_NUM': forecast_year,
        'HISTORICAL_AVG_ORDERS': historical_avg,
        'FORECASTED_PRODUCTION': forecasted,
        'FORECAST_ASSESSMENT': assessment
    }]
    
    return session.create_dataframe(result)
$$;

-- ============================================================================
-- Grant execute permissions
-- ============================================================================
GRANT USAGE ON PROCEDURE PREDICT_PROGRAM_RISK(VARCHAR) TO ROLE SYSADMIN;
GRANT USAGE ON PROCEDURE PREDICT_SUPPLIER_RISK(VARCHAR) TO ROLE SYSADMIN;
GRANT USAGE ON PROCEDURE FORECAST_PRODUCTION(NUMBER, NUMBER) TO ROLE SYSADMIN;

-- ============================================================================
-- Display confirmation
-- ============================================================================
SELECT 'All ML model wrapper procedures created successfully' AS status;

