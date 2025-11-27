<img src="../Snowflake_Logo.svg" width="200">

# Kratos Defense Intelligence Agent - Test Questions

15 test questions (5 simple, 5 complex, 5 ML) for the Kratos Intelligence Agent.

---

## Simple Questions (Semantic Views)

### Question 1: Active Programs
**Question**: "How many active programs does Kratos Defense have?"

**Expected Tool**: SV_PROGRAM_OPERATIONS_INTELLIGENCE

---

### Question 2: Total Contract Value
**Question**: "What is the total contract value across all programs?"

**Expected Tool**: SV_PROGRAM_OPERATIONS_INTELLIGENCE

---

### Question 3: Fleet Size
**Question**: "How many assets are in the fleet and how many are operational?"

**Expected Tool**: SV_ASSET_MANUFACTURING_INTELLIGENCE

---

### Question 4: Employee Count
**Question**: "How many employees work at Kratos Defense?"

**Expected Tool**: SV_ENGINEERING_SUPPORT_INTELLIGENCE

---

### Question 5: Supplier Count
**Question**: "How many approved suppliers does Kratos have?"

**Expected Tool**: SV_ENGINEERING_SUPPORT_INTELLIGENCE

---

## Complex Questions (Semantic Views)

### Question 6: Division Performance
**Question**: "Compare the Unmanned Systems and Hypersonic Systems divisions by program count, total contract value, and average margin."

**Expected Tools**: SV_PROGRAM_OPERATIONS_INTELLIGENCE

---

### Question 7: Manufacturing Analysis
**Question**: "What is the on-time completion rate for manufacturing orders by product type? Which types have the most quality issues?"

**Expected Tools**: SV_ASSET_MANUFACTURING_INTELLIGENCE

---

### Question 8: Customer Concentration
**Question**: "Which customers account for the most contract value? Show the top 5 by total contract value and number of programs."

**Expected Tool**: SV_PROGRAM_OPERATIONS_INTELLIGENCE

---

### Question 9: Maintenance Trends
**Question**: "What are the total maintenance costs by asset type? Which types have the highest average cost per maintenance event?"

**Expected Tool**: SV_ASSET_MANUFACTURING_INTELLIGENCE

---

### Question 10: Incident Analysis
**Question**: "Analyze incidents by severity and type. What is the total cost impact and schedule impact for each category?"

**Expected Tool**: SV_ENGINEERING_SUPPORT_INTELLIGENCE

---

## ML Model Questions

### Question 11: Program Risk
**Question**: "What is the risk prediction for program PRG000001?"

**Expected Tool**: PREDICT_PROGRAM_RISK procedure

---

### Question 12: Supplier Risk
**Question**: "Is supplier SUP00001 at risk of quality or delivery issues?"

**Expected Tool**: PREDICT_SUPPLIER_RISK procedure

---

### Question 13: Production Forecast
**Question**: "Forecast production for January 2026."

**Expected Tool**: FORECAST_PRODUCTION procedure

---

### Question 14: Asset Maintenance
**Question**: "When will asset AST000001 need maintenance?"

**Expected Tool**: PREDICT_ASSET_MAINTENANCE procedure

---

### Question 15: Multi-Risk Analysis
**Question**: "Run risk predictions for the top 5 Hypersonics division programs by contract value."

**Expected Tools**: SV_PROGRAM_OPERATIONS_INTELLIGENCE + PREDICT_PROGRAM_RISK

---

## Cortex Search Questions

### Search 1: Technical Documentation
**Question**: "Find technical specifications for the XQ-58A Valkyrie."

**Expected Tool**: TECHNICAL_DOCS_SEARCH

---

### Search 2: Test Anomalies
**Question**: "Search for test reports that mention anomalies or failures."

**Expected Tool**: TEST_REPORTS_SEARCH

---

### Search 3: Lessons Learned
**Question**: "Find incident reports with lessons learned about equipment failures."

**Expected Tool**: INCIDENT_LOGS_SEARCH

---

## Testing Order

1. **Start Simple**: Questions 1-5
2. **Test Complexity**: Questions 6-10
3. **Test ML**: Questions 11-15
4. **Test Search**: Cortex Search questions

---

**Version**: 1.0  
**Total Questions**: 15 + 3 bonus search questions
