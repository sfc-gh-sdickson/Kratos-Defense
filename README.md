![Snowflake Logo](Snowflake_Logo.svg)

# Kratos Defense Intelligence Agent Solution

## About Kratos Defense

Kratos Defense & Security Solutions, Inc. is a specialized national security technology company providing mission-critical products, services, and solutions for United States national security priorities. Their core capabilities include sophisticated engineering, manufacturing, and system integration offerings for national security platforms and programs.

### Business Divisions

| Division | Description |
|----------|-------------|
| **Unmanned Systems** | High-performance unmanned aerial systems including target drones and tactical platforms (XQ-58 Valkyrie) |
| **Space & Satellite Communications** | Virtualized ground systems, software-defined space networks, SATCOM, Space C2, TT&C |
| **Hypersonic Systems** | Advanced hypersonic strike and test platforms (Erinyes, Dark Fury) |
| **Propulsion & Power** | Jet engines (GEK series), solid rocket motors (Zeus), next-gen propulsion |
| **Microwave Electronics** | Advanced microwave/digital solutions for missiles, satellites, electronic warfare |
| **Cybersecurity** | Information assurance, critical infrastructure security, cyber warfare |
| **Missile Defense** | Ballistic missile defense systems, high-performance defense platforms |
| **C5ISR** | Command, Control, Communications, Computing, Combat Systems, ISR |
| **Training Systems** | VR/AR simulation and training systems for warfighters |

### Market Position

- Leading provider of unmanned tactical and target drones
- Top 5 supplier of satellite ground systems
- Key contractor for U.S. Department of Defense
- Strategic triad support and nuclear deterrence systems

## Project Overview

This Snowflake Intelligence solution demonstrates how Kratos Defense can leverage AI agents to analyze:

- **Program Intelligence**: Defense programs, contracts, milestones, deliverables
- **Asset Operations**: Unmanned systems fleet status, maintenance, flight hours
- **Manufacturing Analytics**: Production metrics, quality control, supply chain
- **Customer Intelligence**: DoD customers, contract performance, requirements
- **Financial Operations**: Contract revenue, cost tracking, margin analysis
- **Engineering Analytics**: R&D projects, test results, certification status
- **Support Operations**: Field service, maintenance records, parts inventory
- **Unstructured Data Search**: Technical documents, test reports, incident logs using Cortex Search

## Database Schema

The solution includes:

1. **RAW Schema**: Core business tables
   - DIVISIONS: Business unit information
   - PROGRAMS: Defense programs and contracts
   - CONTRACTS: Contract details and terms
   - CUSTOMERS: DoD and allied customers
   - ASSETS: Unmanned systems, satellites, equipment
   - ASSET_OPERATIONS: Flight hours, missions, status
   - MAINTENANCE_RECORDS: Service history and parts
   - MANUFACTURING_ORDERS: Production tracking
   - QUALITY_INSPECTIONS: QC results
   - ENGINEERING_PROJECTS: R&D and development
   - TEST_EVENTS: Test flights and evaluations
   - EMPLOYEES: Cleared personnel
   - INCIDENTS: Safety and anomaly reports
   - PARTS_INVENTORY: Spare parts and materials
   - TECHNICAL_DOCUMENTS: Unstructured technical content
   - TEST_REPORTS: Unstructured test documentation
   - INCIDENT_LOGS: Unstructured incident narratives

2. **ANALYTICS Schema**: Curated views and semantic models
   - Program performance views
   - Asset utilization analytics
   - Manufacturing metrics
   - Semantic views for AI agents

3. **Cortex Search Services**: Semantic search over unstructured data
   - TECHNICAL_DOCS_SEARCH: Search engineering documents
   - TEST_REPORTS_SEARCH: Search test and evaluation reports
   - INCIDENT_LOGS_SEARCH: Search incident and anomaly logs

## Files

### Core Files
- `README.md`: This comprehensive solution documentation
- `docs/AGENT_SETUP.md`: Complete agent configuration instructions
- `docs/questions.md`: 15 test questions (5 simple, 5 complex, 5 ML)

### SQL Files
- `sql/setup/01_database_and_schema.sql`: Database and schema creation
- `sql/setup/02_create_tables.sql`: Table definitions with proper constraints
- `sql/data/03_generate_synthetic_data.sql`: Realistic defense industry sample data
- `sql/views/04_create_views.sql`: Analytical views
- `sql/views/05_create_semantic_views.sql`: Semantic views for AI agents (verified syntax)
- `sql/search/06_create_cortex_search.sql`: Unstructured data tables and Cortex Search services
- `sql/ml/07_create_model_wrapper_functions.sql`: ML model wrapper procedures
- `sql/agent/08_create_intelligence_agent.sql`: Create Snowflake Intelligence Agent

### ML Models
- `notebooks/kratos_ml_models.ipynb`: Snowflake Notebook for training ML models

## Setup Instructions

### Quick Start (Simplified Agent - No ML)
```sql
-- Execute in order:
-- 1. Run sql/setup/01_database_and_schema.sql
-- 2. Run sql/setup/02_create_tables.sql
-- 3. Run sql/data/03_generate_synthetic_data.sql (10-20 min)
-- 4. Run sql/views/04_create_views.sql
-- 5. Run sql/views/05_create_semantic_views.sql
-- 6. Run sql/search/06_create_cortex_search.sql (5-10 min)
-- 7. Run sql/agent/08_create_intelligence_agent.sql
-- 8. Access agent in Snowsight: AI & ML > Agents > KRATOS_INTELLIGENCE_AGENT
```

### Complete Setup (Full Agent with ML)
```sql
-- Execute quick start steps 1-6, then:
-- 7. Upload and run notebooks/kratos_ml_models.ipynb in Snowflake
-- 8. Run sql/ml/07_create_model_wrapper_functions.sql
-- 9. Run sql/agent/08_create_intelligence_agent.sql
-- 10. Access agent in Snowsight: AI & ML > Agents > KRATOS_INTELLIGENCE_AGENT
```

### Detailed Instructions
- See **docs/AGENT_SETUP.md** for step-by-step configuration guide
- Test with questions from **docs/questions.md**

## Data Model Highlights

### Structured Data
- 9 business divisions with detailed profiles
- 200+ defense programs and contracts
- 500+ unmanned assets and systems
- 50K+ flight hours and operations records
- 100K+ maintenance records
- 25K+ manufacturing orders
- 10K+ quality inspections
- 5K+ test events
- 2K+ engineering projects

### Unstructured Data
- 1,000+ technical documents
- 500+ test reports with detailed narratives
- 2,000+ incident logs and anomaly reports
- Semantic search powered by Snowflake Cortex Search
- RAG (Retrieval Augmented Generation) ready for AI agents

## Key Features

✅ **Defense Industry Focus**: Data model reflects actual defense contractor operations  
✅ **Hybrid Data Architecture**: Combines structured tables with unstructured content  
✅ **Semantic Search**: Find similar incidents, technical solutions by meaning  
✅ **RAG-Ready**: Agent can retrieve context from documents and reports  
✅ **Production-Ready Syntax**: All SQL verified against Snowflake documentation  
✅ **Comprehensive Demo**: Programs, assets, manufacturing, operations data  
✅ **ML Models**: Predictive maintenance, program risk, demand forecasting

## Sample Questions

The agent can answer sophisticated questions like:

### Structured Data Analysis (Semantic Views)
1. **Program Status**: Contract performance and milestone tracking
2. **Asset Utilization**: Fleet readiness and flight hour analysis
3. **Manufacturing Metrics**: Production rates and quality trends
4. **Financial Analysis**: Revenue recognition and cost variance
5. **Maintenance Trends**: MTBF, parts consumption, service patterns

### Unstructured Data Search (Cortex Search)
6. **Technical Docs**: Engineering specifications and procedures
7. **Test Reports**: Flight test results and performance data
8. **Incident Analysis**: Similar incidents and root cause patterns

### ML Model Predictions
9. **Predictive Maintenance**: When will assets need service?
10. **Program Risk**: Which programs are at risk of delay?
11. **Demand Forecast**: Parts and manufacturing demand prediction

## Semantic Views

The solution includes three verified semantic views:

1. **SV_PROGRAM_OPERATIONS_INTELLIGENCE**: Programs, contracts, customers, deliverables
2. **SV_ASSET_MANUFACTURING_INTELLIGENCE**: Assets, operations, maintenance, manufacturing
3. **SV_ENGINEERING_SUPPORT_INTELLIGENCE**: Projects, testing, incidents, employees

## Cortex Search Services

Three Cortex Search services enable semantic search over unstructured data:

1. **TECHNICAL_DOCS_SEARCH**: Search technical documents and specifications
2. **TEST_REPORTS_SEARCH**: Search test and evaluation reports
3. **INCIDENT_LOGS_SEARCH**: Search incident reports and anomaly logs

## Syntax Verification

All SQL syntax verified against official Snowflake documentation and the NASM template patterns:

- **CREATE SEMANTIC VIEW**: Verified clause order (TABLES → RELATIONSHIPS → DIMENSIONS → METRICS)
- **CREATE CORTEX SEARCH SERVICE**: Verified ON, ATTRIBUTES, WAREHOUSE, TARGET_LAG syntax
- **CREATE AGENT**: Verified YAML specification format

## Data Volumes

- **Divisions**: 9
- **Programs**: 200+
- **Contracts**: 300+
- **Customers**: 50+
- **Assets**: 500+
- **Operations Records**: 50,000+
- **Maintenance Records**: 100,000+
- **Manufacturing Orders**: 25,000+
- **Quality Inspections**: 10,000+
- **Test Events**: 5,000+
- **Technical Documents**: 1,000+
- **Test Reports**: 500+
- **Incident Logs**: 2,000+

## Support

For questions or issues:
- Review `docs/AGENT_SETUP.md` for detailed setup instructions
- Check `docs/questions.md` for example questions
- Refer to Snowflake documentation for syntax verification

## Version History

- **v1.0** (November 2025): Initial release
  - Defense industry data model
  - 3 semantic views for structured analysis
  - 3 Cortex Search services for unstructured data
  - 3 ML models for predictions
  - 15 test questions

## License

This solution is provided as a template for building Snowflake Intelligence agents. Adapt as needed for your specific use case.

---

**Created**: November 2025  
**Snowflake Documentation**: Syntax verified against official documentation and NASM template  
**Target Use Case**: Kratos Defense operations and business intelligence

**NO GUESSING - ALL SYNTAX VERIFIED** ✅


