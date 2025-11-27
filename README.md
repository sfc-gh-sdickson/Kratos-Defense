<img src="Snowflake_Logo.svg" width="200">

# Kratos Defense Intelligence Agent Solution

## About Kratos Defense

Kratos Defense & Security Solutions, Inc. is a specialized national security technology company providing mission-critical products, services, and solutions for United States national security priorities.

### Business Divisions

| Division | Description |
|----------|-------------|
| **Unmanned Systems** | High-performance UAVs including XQ-58A Valkyrie, BQM-167, tactical drones |
| **Space & Satellite Communications** | Virtualized ground systems, SATCOM, TT&C |
| **Hypersonic Systems** | Advanced hypersonic strike and test platforms |
| **Propulsion & Power** | Jet engines (TJ150, TJ50), solid rocket motors |
| **Microwave Electronics** | Advanced microwave/digital solutions for missiles, satellites, EW |
| **Cybersecurity** | Information assurance, critical infrastructure security |
| **Missile Defense** | Ballistic missile defense systems and components |
| **C5ISR** | Command, Control, Communications, Computing, Combat Systems, ISR |
| **Training Systems** | VR/AR simulation and training systems |

## Solution Overview

This Snowflake Intelligence solution demonstrates AI-powered analytics for:

- **Program Intelligence**: Defense programs, contracts, milestones
- **Asset Operations**: Fleet status, flight hours, maintenance
- **Manufacturing Analytics**: Production metrics, quality control
- **Engineering Analytics**: R&D projects, test results
- **Unstructured Search**: Technical documents, test reports, incident logs

## Database Schema

### RAW Schema (18 Tables)
- DIVISIONS, CUSTOMERS, PROGRAMS, CONTRACTS, MILESTONES
- ASSETS, ASSET_OPERATIONS, MAINTENANCE_RECORDS
- MANUFACTURING_ORDERS, QUALITY_INSPECTIONS
- ENGINEERING_PROJECTS, TEST_EVENTS
- EMPLOYEES, INCIDENTS, SUPPLIERS, PARTS_INVENTORY, PURCHASE_ORDERS
- TECHNICAL_DOCUMENTS, TEST_REPORTS, INCIDENT_LOGS

### ANALYTICS Schema
- 11 Analytical Views (V_PROGRAM_DASHBOARD, V_ASSET_FLEET_STATUS, etc.)
- 3 Semantic Views for AI agents
- 4 ML wrapper procedures

### Cortex Search Services
- TECHNICAL_DOCS_SEARCH
- TEST_REPORTS_SEARCH
- INCIDENT_LOGS_SEARCH

## Files

### SQL Files
| File | Purpose |
|------|---------|
| `sql/setup/01_database_and_schema.sql` | Database and schema creation |
| `sql/setup/02_create_tables.sql` | 18 table definitions |
| `sql/data/03_generate_synthetic_data.sql` | Sample data generation |
| `sql/views/04_create_views.sql` | 11 analytical views |
| `sql/views/05_create_semantic_views.sql` | 3 semantic views |
| `sql/search/06_create_cortex_search.sql` | Cortex Search services |
| `sql/ml/07_create_model_wrapper_functions.sql` | ML prediction procedures |
| `sql/agent/08_create_intelligence_agent.sql` | Agent definition |

### Other Files
| File | Purpose |
|------|---------|
| `notebooks/kratos_ml_models.ipynb` | ML model training notebook |
| `docs/AGENT_SETUP.md` | Setup instructions |
| `docs/questions.md` | 15 test questions |

## Quick Start

```sql
-- Execute in order:
-- 1. sql/setup/01_database_and_schema.sql
-- 2. sql/setup/02_create_tables.sql
-- 3. sql/data/03_generate_synthetic_data.sql (5-10 min)
-- 4. sql/views/04_create_views.sql
-- 5. sql/views/05_create_semantic_views.sql
-- 6. sql/search/06_create_cortex_search.sql (5-10 min)
-- 7. sql/ml/07_create_model_wrapper_functions.sql
-- 8. sql/agent/08_create_intelligence_agent.sql
-- 9. Access agent in Snowsight: AI & ML > Agents
```

## Key Features

✅ **Defense Industry Focus**: Realistic defense contractor data model  
✅ **Hybrid Data**: Structured tables + unstructured documents  
✅ **Semantic Search**: Find content by meaning with Cortex Search  
✅ **ML Predictions**: Risk assessment and forecasting  
✅ **Verified Syntax**: All SQL tested against Snowflake documentation  

## Sample Data Volumes

| Table | Records |
|-------|---------|
| Programs | 200 |
| Contracts | 300 |
| Assets | 500 |
| Asset Operations | 10,000 |
| Maintenance Records | 5,000 |
| Manufacturing Orders | 2,000 |
| Quality Inspections | 3,000 |
| Engineering Projects | 300 |
| Test Events | 2,000 |
| Employees | 1,000 |
| Incidents | 500 |
| Suppliers | 200 |
| Technical Documents | 500 |
| Test Reports | 300 |
| Incident Logs | 400 |

## Support

- See `docs/AGENT_SETUP.md` for detailed instructions
- Test with questions from `docs/questions.md`

---

**Created**: November 2025  
**Version**: 1.0
