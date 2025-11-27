# Kratos Defense Intelligence Agent - Setup Guide

This guide provides step-by-step instructions to set up and configure the Kratos Defense Intelligence Agent.

## Prerequisites

Before starting, ensure you have:

1. **Snowflake Account** with the following capabilities:
   - Snowflake Intelligence (Cortex AI features enabled)
   - Cortex Analyst
   - Cortex Search
   - Snowpark ML

2. **Required Roles**:
   - ACCOUNTADMIN (for initial setup)
   - SYSADMIN (for ongoing operations)

3. **Required Privileges**:
   - CREATE DATABASE
   - CREATE WAREHOUSE
   - CREATE SEMANTIC VIEW
   - CREATE CORTEX SEARCH SERVICE
   - CREATE AGENT

## Quick Start (Without ML Models)

If you want to get started quickly without the ML prediction capabilities:

### Step 1: Create Database and Schema
```sql
-- Run as ACCOUNTADMIN
-- Execute: sql/setup/01_database_and_schema.sql
```

### Step 2: Create Tables
```sql
-- Execute: sql/setup/02_create_tables.sql
```

### Step 3: Generate Synthetic Data
```sql
-- Execute: sql/data/03_generate_synthetic_data.sql
-- Note: This may take 10-20 minutes for large datasets
```

### Step 4: Create Analytical Views
```sql
-- Execute: sql/views/04_create_views.sql
```

### Step 5: Create Semantic Views
```sql
-- Execute: sql/views/05_create_semantic_views.sql
```

### Step 6: Create Cortex Search Services
```sql
-- Execute: sql/search/06_create_cortex_search.sql
-- Note: This may take 5-10 minutes to build search indices
```

### Step 7: Create Intelligence Agent (Simplified)
```sql
-- Execute the agent creation section of: sql/agent/08_create_intelligence_agent.sql
-- Skip the ML tool configurations if models are not trained
```

### Step 8: Access the Agent
1. Navigate to Snowsight
2. Go to **AI & ML** > **Agents**
3. Select **KRATOS_INTELLIGENCE_AGENT**
4. Start asking questions!

## Complete Setup (With ML Models)

For the full experience including ML predictions:

### Steps 1-6: Same as Quick Start
Follow Steps 1-6 from the Quick Start guide above.

### Step 7: Train ML Models
1. In Snowsight, go to **Projects** > **Notebooks**
2. Create a new notebook
3. Copy the contents from `notebooks/kratos_ml_models.ipynb`
4. Run all cells to train and register the 3 models:
   - PROGRAM_RISK_PREDICTOR
   - SUPPLIER_RISK_PREDICTOR
   - PRODUCTION_FORECASTER

### Step 8: Create Model Wrapper Functions
```sql
-- Execute: sql/ml/07_create_model_wrapper_functions.sql
```

### Step 9: Create Complete Intelligence Agent
```sql
-- Execute: sql/agent/08_create_intelligence_agent.sql
```

### Step 10: Verify Setup
```sql
-- Verify semantic views
SHOW SEMANTIC VIEWS IN SCHEMA KRATOS_INTELLIGENCE.ANALYTICS;

-- Verify Cortex Search services
SHOW CORTEX SEARCH SERVICES IN SCHEMA KRATOS_INTELLIGENCE.RAW;

-- Verify ML models
SHOW MODELS IN SCHEMA KRATOS_INTELLIGENCE.ANALYTICS;

-- Verify agent
DESCRIBE AGENT KRATOS_INTELLIGENCE.ANALYTICS.KRATOS_INTELLIGENCE_AGENT;
```

### Step 11: Access the Agent
1. Navigate to Snowsight
2. Go to **AI & ML** > **Agents**
3. Select **KRATOS_INTELLIGENCE_AGENT**
4. Test with sample questions from `docs/questions.md`

## Adding Agent to Snowflake Intelligence

To make the agent visible to all users in Snowflake Intelligence:

### Step 1: Create Snowflake Intelligence Object (if not exists)
1. In Snowsight, go to **AI & ML** > **Agents**
2. Click the **Snowflake Intelligence** tab
3. Click **Open settings**
4. This creates the Snowflake Intelligence object automatically

### Step 2: Add the Agent
```sql
ALTER SNOWFLAKE INTELLIGENCE SNOWFLAKE_INTELLIGENCE_OBJECT_DEFAULT 
  ADD AGENT KRATOS_INTELLIGENCE.ANALYTICS.KRATOS_INTELLIGENCE_AGENT;
```

### Step 3: Grant User Access
```sql
-- Grant access to specific role
GRANT USAGE ON SNOWFLAKE INTELLIGENCE SNOWFLAKE_INTELLIGENCE_OBJECT_DEFAULT 
  TO ROLE SYSADMIN;

-- Or grant access to all users
GRANT USAGE ON SNOWFLAKE INTELLIGENCE SNOWFLAKE_INTELLIGENCE_OBJECT_DEFAULT 
  TO ROLE PUBLIC;
```

## Troubleshooting

### Permission Errors

**Issue**: "Permission denied" or "Object does not exist"

**Solution**:
```sql
-- Ensure role has all required privileges
GRANT USAGE ON DATABASE KRATOS_INTELLIGENCE TO ROLE <your_role>;
GRANT USAGE ON SCHEMA KRATOS_INTELLIGENCE.RAW TO ROLE <your_role>;
GRANT USAGE ON SCHEMA KRATOS_INTELLIGENCE.ANALYTICS TO ROLE <your_role>;
GRANT USAGE ON WAREHOUSE KRATOS_WH TO ROLE <your_role>;
GRANT SELECT ON ALL TABLES IN SCHEMA KRATOS_INTELLIGENCE.RAW TO ROLE <your_role>;
GRANT REFERENCES ON ALL SEMANTIC VIEWS IN SCHEMA KRATOS_INTELLIGENCE.ANALYTICS TO ROLE <your_role>;
```

### Semantic View Errors

**Issue**: "Cannot create semantic view" or syntax errors

**Solution**:
- Verify clause order: TABLES → RELATIONSHIPS → DIMENSIONS → METRICS → COMMENT
- Check that all column names exist in source tables
- Ensure no duplicate synonyms across views
- Verify PRIMARY KEY columns exist

### Cortex Search Not Working

**Issue**: "Service not responding" or no results

**Solution**:
```sql
-- Check service status
DESCRIBE CORTEX SEARCH SERVICE KRATOS_INTELLIGENCE.RAW.TECHNICAL_DOCS_SEARCH;

-- Verify change tracking is enabled
ALTER TABLE KRATOS_INTELLIGENCE.RAW.TECHNICAL_DOCUMENTS SET CHANGE_TRACKING = TRUE;

-- Check if data exists
SELECT COUNT(*) FROM KRATOS_INTELLIGENCE.RAW.TECHNICAL_DOCUMENTS;
```

### ML Model Errors

**Issue**: "Model not found" or prediction errors

**Solution**:
```sql
-- Check if models are registered
SHOW MODELS IN SCHEMA KRATOS_INTELLIGENCE.ANALYTICS;

-- Check model versions
SHOW VERSIONS IN MODEL KRATOS_INTELLIGENCE.ANALYTICS.PROGRAM_RISK_PREDICTOR;

-- Verify wrapper procedures exist
SHOW PROCEDURES LIKE 'PREDICT%' IN SCHEMA KRATOS_INTELLIGENCE.ANALYTICS;
```

### Agent Not Appearing

**Issue**: Agent not visible in Snowflake Intelligence

**Solution**:
1. Verify agent was created: `DESCRIBE AGENT KRATOS_INTELLIGENCE_AGENT;`
2. Check if Snowflake Intelligence object exists: `SHOW SNOWFLAKE INTELLIGENCES;`
3. Add agent to the object:
```sql
ALTER SNOWFLAKE INTELLIGENCE SNOWFLAKE_INTELLIGENCE_OBJECT_DEFAULT 
  ADD AGENT KRATOS_INTELLIGENCE.ANALYTICS.KRATOS_INTELLIGENCE_AGENT;
```

## Data Refresh

To refresh the synthetic data:

```sql
-- Truncate all tables
TRUNCATE TABLE KRATOS_INTELLIGENCE.RAW.TECHNICAL_DOCUMENTS;
TRUNCATE TABLE KRATOS_INTELLIGENCE.RAW.TEST_REPORTS;
TRUNCATE TABLE KRATOS_INTELLIGENCE.RAW.PROGRAM_REVIEWS;
-- ... truncate other tables ...

-- Re-run data generation
-- Execute: sql/data/03_generate_synthetic_data.sql
-- Execute: sql/search/06_create_cortex_search.sql (data insert portion)
```

## Customization

### Adding New Data Sources

1. Create new tables in the RAW schema
2. Add to semantic views as additional TABLES entries
3. Define RELATIONSHIPS to connect to existing tables
4. Add DIMENSIONS and METRICS for the new columns

### Adding New ML Models

1. Train model in Snowflake Notebook
2. Register to Model Registry
3. Create wrapper procedure in `sql/ml/`
4. Add as tool in agent definition

### Customizing Agent Instructions

Edit the INSTRUCTIONS in `sql/agent/08_create_intelligence_agent.sql` to:
- Add company-specific context
- Define response formatting preferences
- Set security/compliance guidelines

## Support

For additional assistance:
- Review the README.md for solution overview
- Check the test questions in `docs/questions.md`
- Consult Snowflake documentation for specific features
- Contact your Snowflake account team

---

**Version**: 1.0  
**Last Updated**: November 2025  
**Syntax Verification**: All SQL verified against official Snowflake documentation

