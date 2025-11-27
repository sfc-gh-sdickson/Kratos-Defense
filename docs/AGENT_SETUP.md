<img src="../Snowflake_Logo.svg" width="200">

# Kratos Defense Intelligence Agent - Setup Guide

## Prerequisites

Before setting up the Intelligence Agent, ensure you have:

1. **Snowflake Account** with appropriate permissions
2. **ACCOUNTADMIN role** for agent creation
3. **Warehouse access** for query processing
4. **Cortex Analyst** enabled on your account

## Step-by-Step Setup

### Step 1: Create Database and Schema

Run the database setup script:

```sql
-- Execute sql/setup/01_database_and_schema.sql
```

This creates:
- Database: `KRATOS_INTELLIGENCE`
- Schemas: `RAW`, `ANALYTICS`
- Warehouse: `KRATOS_WH`

### Step 2: Create Tables

Run the table creation script:

```sql
-- Execute sql/setup/02_create_tables.sql
```

This creates 16+ tables including:
- DIVISIONS, EMPLOYEES, PROGRAMS, CONTRACTS
- ASSETS, SUPPLIERS, PURCHASE_ORDERS
- MAINTENANCE_RECORDS, QUALITY_INSPECTIONS
- PROPOSALS, SERVICE_AGREEMENTS, MILESTONES

### Step 3: Generate Sample Data

Run the data generation script:

```sql
-- Execute sql/data/03_generate_synthetic_data.sql
-- Estimated time: 5-10 minutes
```

This populates:
- 5,000 employees
- 500 programs
- 300 contracts
- 1,000 assets
- 200 suppliers
- And more...

### Step 4: Create Analytical Views

Run the views script:

```sql
-- Execute sql/views/04_create_views.sql
```

This creates 10 analytical views for common metrics.

### Step 5: Create Semantic Views

Run the semantic views script:

```sql
-- Execute sql/views/05_create_semantic_views.sql
```

This creates 3 semantic views:
- SV_PROGRAM_CONTRACT_INTELLIGENCE
- SV_ASSET_MAINTENANCE_INTELLIGENCE
- SV_SUPPLIER_PROCUREMENT_INTELLIGENCE

### Step 6: Create Cortex Search Services

Run the Cortex Search setup:

```sql
-- Execute sql/search/06_create_cortex_search.sql
```

This creates:
- Unstructured data tables
- 3 Cortex Search services

### Step 7: Train ML Models (Optional)

Upload and run the notebook in Snowflake:

1. Go to Snowsight > Notebooks
2. Upload `notebooks/kratos_ml_models.ipynb`
3. Run all cells to train and register models

### Step 8: Create ML Wrapper Functions

Run the wrapper functions script:

```sql
-- Execute sql/ml/07_create_model_wrapper_functions.sql
```

### Step 9: Create Intelligence Agent

Run the agent creation script:

```sql
-- Execute sql/agent/08_create_intelligence_agent.sql
```

### Step 10: Test the Agent

1. Go to Snowsight
2. Navigate to AI & ML > Agents
3. Select `KRATOS_INTELLIGENCE_AGENT`
4. Click "Chat" to interact
5. Try the sample questions from `docs/questions.md`

## Troubleshooting

### Agent Creation Fails

Verify permissions:
```sql
-- Check semantic views exist
SHOW SEMANTIC VIEWS IN SCHEMA KRATOS_INTELLIGENCE.ANALYTICS;

-- Check Cortex Search services
SHOW CORTEX SEARCH SERVICES IN SCHEMA KRATOS_INTELLIGENCE.RAW;

-- Check ML procedures
SHOW PROCEDURES IN SCHEMA KRATOS_INTELLIGENCE.ANALYTICS;
```

### Model Not Found Errors

Ensure notebook was run successfully:
```sql
-- Check model registry
SHOW MODELS IN SCHEMA KRATOS_INTELLIGENCE.ANALYTICS;
```

### Permission Errors

Verify grants:
```sql
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_ANALYST_USER TO ROLE SYSADMIN;
GRANT USAGE ON DATABASE KRATOS_INTELLIGENCE TO ROLE SYSADMIN;
```

## Configuration Reference

### Semantic Views

| View | Description |
|------|-------------|
| SV_PROGRAM_CONTRACT_INTELLIGENCE | Programs, contracts, milestones |
| SV_ASSET_MAINTENANCE_INTELLIGENCE | Assets, maintenance, quality |
| SV_SUPPLIER_PROCUREMENT_INTELLIGENCE | Suppliers, POs, proposals |

### Cortex Search Services

| Service | Content |
|---------|---------|
| TECHNICAL_DOCS_SEARCH | Technical manuals |
| MAINTENANCE_PROCEDURES_SEARCH | Maintenance procedures |
| INCIDENT_REPORTS_SEARCH | Incident reports |

### ML Models

| Model | Purpose |
|-------|---------|
| PROGRAM_RISK_PREDICTOR | Predict program risk |
| SUPPLIER_RISK_PREDICTOR | Identify supplier risk |
| ASSET_MAINTENANCE_PREDICTOR | Predict maintenance urgency |

## Next Steps

After successful setup:
1. Test with sample questions
2. Customize for your specific needs
3. Add additional data sources
4. Create custom semantic views
5. Train domain-specific ML models

