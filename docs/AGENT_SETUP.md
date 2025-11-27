<img src="../Snowflake_Logo.svg" width="200">

# Kratos Defense Intelligence Agent - Setup Guide

## Prerequisites

1. **Snowflake Account** with:
   - Snowflake Intelligence (Cortex AI features)
   - Cortex Analyst
   - Cortex Search
   - Snowpark ML

2. **Required Roles**: ACCOUNTADMIN or SYSADMIN

3. **Required Privileges**:
   - CREATE DATABASE
   - CREATE WAREHOUSE
   - CREATE SEMANTIC VIEW
   - CREATE CORTEX SEARCH SERVICE
   - CREATE AGENT

## Quick Start (Without ML Models)

### Step 1: Create Database and Schema
```sql
-- Execute: sql/setup/01_database_and_schema.sql
```

### Step 2: Create Tables
```sql
-- Execute: sql/setup/02_create_tables.sql
```

### Step 3: Generate Sample Data
```sql
-- Execute: sql/data/03_generate_synthetic_data.sql
-- Note: May take 5-10 minutes
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
-- Note: May take 5-10 minutes to build indices
```

### Step 7: Create ML Wrapper Procedures
```sql
-- Execute: sql/ml/07_create_model_wrapper_functions.sql
```

### Step 8: Create the Agent
```sql
-- Execute: sql/agent/08_create_intelligence_agent.sql
```

### Step 9: Access the Agent
1. Open Snowsight
2. Navigate to **AI & ML** > **Agents**
3. Select **KRATOS_INTELLIGENCE_AGENT**
4. Start asking questions!

## Complete Setup (With ML Models)

Follow Steps 1-6 above, then:

### Step 7: Train ML Models
1. In Snowsight, go to **Projects** > **Notebooks**
2. Create a new notebook
3. Copy contents from `notebooks/kratos_ml_models.ipynb`
4. Run all cells to train and register models

### Step 8-9: Continue with Quick Start Steps 7-9

## Verification

```sql
-- Verify tables
SELECT table_name, row_count 
FROM information_schema.tables 
WHERE table_schema = 'RAW';

-- Verify semantic views
SHOW SEMANTIC VIEWS IN SCHEMA KRATOS_INTELLIGENCE.ANALYTICS;

-- Verify Cortex Search services
SHOW CORTEX SEARCH SERVICES IN SCHEMA KRATOS_INTELLIGENCE.RAW;

-- Verify agent
DESCRIBE AGENT KRATOS_INTELLIGENCE.ANALYTICS.KRATOS_INTELLIGENCE_AGENT;
```

## Adding to Snowflake Intelligence

```sql
-- Add agent to Snowflake Intelligence
ALTER SNOWFLAKE INTELLIGENCE SNOWFLAKE_INTELLIGENCE_OBJECT_DEFAULT 
  ADD AGENT KRATOS_INTELLIGENCE.ANALYTICS.KRATOS_INTELLIGENCE_AGENT;

-- Grant access
GRANT USAGE ON SNOWFLAKE INTELLIGENCE SNOWFLAKE_INTELLIGENCE_OBJECT_DEFAULT 
  TO ROLE PUBLIC;
```

## Troubleshooting

### Permission Errors
```sql
GRANT USAGE ON DATABASE KRATOS_INTELLIGENCE TO ROLE <your_role>;
GRANT USAGE ON SCHEMA KRATOS_INTELLIGENCE.RAW TO ROLE <your_role>;
GRANT USAGE ON SCHEMA KRATOS_INTELLIGENCE.ANALYTICS TO ROLE <your_role>;
GRANT USAGE ON WAREHOUSE KRATOS_WH TO ROLE <your_role>;
```

### Cortex Search Not Working
```sql
-- Check service status
DESCRIBE CORTEX SEARCH SERVICE KRATOS_INTELLIGENCE.RAW.TECHNICAL_DOCS_SEARCH;

-- Verify data exists
SELECT COUNT(*) FROM KRATOS_INTELLIGENCE.RAW.TECHNICAL_DOCUMENTS;
```

### Agent Not Appearing
```sql
-- Verify agent exists
DESCRIBE AGENT KRATOS_INTELLIGENCE.ANALYTICS.KRATOS_INTELLIGENCE_AGENT;
```

---

**Version**: 1.0  
**Last Updated**: November 2025
