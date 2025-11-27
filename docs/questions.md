<img src="../Snowflake_Logo.svg" width="200">

# Kratos Defense Intelligence Agent - Test Questions

Use these questions to test the Intelligence Agent after setup. All questions have been verified against the actual data and semantic view metrics.

---

## Simple Questions (Cortex Analyst)

These questions test basic data retrieval capabilities.

### 1. How many active programs do we have?
**Expected behavior**: Query PROGRAMS table, filter by program_status='ACTIVE', count results.  
**Expected result**: ~200 active programs (40% of 500 total)

### 2. What is the total value of our contracts?
**Expected behavior**: Sum base_value from CONTRACTS table.  
**Expected result**: Billions in contract value

### 3. How many suppliers are in our system?
**Expected behavior**: Count distinct supplier_id from SUPPLIERS.  
**Expected result**: 200 suppliers

### 4. What is our average supplier quality rating?
**Expected behavior**: Calculate AVG(quality_rating) from SUPPLIERS.  
**Expected result**: ~8.5 (scale of 1-10)

### 5. How many assets are currently operational?
**Expected behavior**: Count ASSETS where asset_status='OPERATIONAL'.  
**Expected result**: ~600 operational assets (60% of 1,000)

---

## Complex Questions (Cortex Analyst)

These questions test multi-table analysis and aggregation.

### 6. Compare program budget utilization across divisions. Show total budget, spent, and variance.
**Expected behavior**: Join PROGRAMS with DIVISIONS, group by division, calculate budget metrics.  
**Expected result**: Budget breakdown by 8 divisions

### 7. Show supplier performance by type. Include quality ratings, delivery ratings, and total spend.
**Expected behavior**: Group SUPPLIERS by supplier_type, aggregate ratings and spend.  
**Expected result**: Performance metrics for TIER_1, TIER_2, TIER_3, DISTRIBUTOR, SERVICE_PROVIDER

### 8. What is our proposal pipeline? Show proposals by status with opportunity values.
**Expected behavior**: Group PROPOSALS by proposal_status, sum opportunity_value.  
**Expected result**: Pipeline breakdown: IN_PROGRESS, SUBMITTED, WON, LOST, PENDING_DECISION

### 9. Analyze maintenance costs by asset type. Show total labor, parts, and total maintenance costs.
**Expected behavior**: Join MAINTENANCE_RECORDS with ASSETS, group by asset_type.  
**Expected result**: Cost breakdown for AIRCRAFT, VEHICLE, EQUIPMENT, ELECTRONICS, etc.

### 10. Show contract performance by customer. Include total value, funded amount, and average performance rating.
**Expected behavior**: Group CONTRACTS by customer, aggregate value and rating metrics.  
**Expected result**: Metrics for U.S. Army, Navy, Air Force, Space Force, MDA, DARPA, DHS

---

## ML Model Questions (Predictions)

These questions test the ML model wrapper functions.

### 11. Predict risk levels for our development programs.
**Expected behavior**: Call PREDICT_PROGRAM_RISK(program_type='DEVELOPMENT').  
**Expected result**: JSON with predicted risk distribution for development programs

### 12. Identify which Tier 1 suppliers might be at risk.
**Expected behavior**: Call PREDICT_SUPPLIER_RISK(supplier_type='TIER_1').  
**Expected result**: JSON with at-risk supplier count and quality/delivery metrics

### 13. Which aircraft assets need maintenance attention soon?
**Expected behavior**: Call PREDICT_ASSET_MAINTENANCE(asset_type='AIRCRAFT').  
**Expected result**: JSON with maintenance urgency breakdown (ON_SCHEDULE, DUE_SOON, OVERDUE)

### 14. What is the overall program risk across all program types?
**Expected behavior**: Call PREDICT_PROGRAM_RISK(program_type=NULL).  
**Expected result**: JSON with risk distribution across all active programs

### 15. Predict maintenance needs for all equipment assets.
**Expected behavior**: Call PREDICT_ASSET_MAINTENANCE(asset_type='EQUIPMENT').  
**Expected result**: JSON with maintenance urgency for equipment category

---

## Cortex Search Questions (Unstructured Data)

These questions test semantic search capabilities.

### 16. Search for UAV operations procedures
**Expected behavior**: Search TECHNICAL_DOCS_SEARCH for UAV-related content.  
**Expected result**: Technical documentation about UAV operations

### 17. Find maintenance procedures for radar calibration
**Expected behavior**: Search MAINTENANCE_PROCEDURES_SEARCH for radar calibration.  
**Expected result**: Radar antenna calibration procedure

### 18. Search incident reports about cybersecurity
**Expected behavior**: Search INCIDENT_REPORTS_SEARCH for cybersecurity incidents.  
**Expected result**: Cybersecurity incident report with root cause and lessons learned

---

## Tips for Testing

1. **Start with simple questions** to verify basic connectivity
2. **Try variations** of the same question to test robustness
3. **Verify numeric results** against the data generation parameters
4. **Check ML predictions** return valid JSON with expected fields
5. **Test Cortex Search** with different query phrasings

## Expected Data Distributions

Based on the data generation script:

| Status Field | Distribution |
|--------------|--------------|
| Program Status | 40% ACTIVE, 25% COMPLETED, 15% ON_HOLD, 10% PLANNING, 10% CANCELLED |
| Contract Status | 35% ACTIVE, 30% COMPLETED, 15% AWARDED, 10% NEGOTIATION, 10% CLOSED |
| Asset Status | 60% OPERATIONAL, 15% MAINTENANCE, 10% STANDBY, 8% REPAIR, 5% RETIRED, 2% DECOMMISSIONED |
| Supplier Status | 70% ACTIVE, 15% PREFERRED, 8% PROBATION, 5% INACTIVE, 2% SUSPENDED |
| Program Risk | 20% LOW, 50% MEDIUM, 25% HIGH, 5% CRITICAL |
| Supplier Risk | 40% LOW, 35% MEDIUM, 20% HIGH, 5% CRITICAL |

