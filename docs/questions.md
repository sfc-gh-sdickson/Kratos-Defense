# Kratos Defense Intelligence Agent - Test Questions

This document provides 15 test questions (5 simple, 5 complex, 5 ML) that can be answered by the Kratos Intelligence Agent.

All questions are designed to be answerable by the synthetic data generated in this solution.

---

## Simple Questions (Semantic Views)

These questions test basic querying capabilities using the semantic views.

### Question 1: Active Program Count
**Question**: "How many active programs does Kratos Defense have?"

**Expected Tool**: SV_PROGRAM_INTELLIGENCE (Cortex Analyst)

**Expected Analysis**:
- Query the PROGRAMS dimension filtering by program_status = 'ACTIVE'
- Return a count of distinct program_id
- Should return approximately 350 active programs (70% of 500)

---

### Question 2: Total Contract Value
**Question**: "What is the total contract value across all programs?"

**Expected Tool**: SV_PROGRAM_INTELLIGENCE (Cortex Analyst)

**Expected Analysis**:
- Use the total_contract_value metric
- Sum across all programs
- Expected range: $50B - $100B total

---

### Question 3: Top Suppliers by Quality
**Question**: "Show me the top 5 suppliers by quality rating."

**Expected Tool**: SV_OPERATIONS_INTELLIGENCE (Cortex Analyst)

**Expected Analysis**:
- Query supplier dimensions with quality_rating
- Order by quality_rating descending
- Limit to 5 results
- Expected quality ratings: 95-100 for top suppliers

---

### Question 4: Open Support Tickets
**Question**: "How many open support tickets are there?"

**Expected Tool**: SV_CUSTOMER_INTELLIGENCE (Cortex Analyst)

**Expected Analysis**:
- Use open_tickets metric
- Filter by ticket_status = 'OPEN'
- Expected: ~1,500 open tickets (30% of 5,000)

---

### Question 5: Average Test Pass Rate
**Question**: "What is the average test pass rate across all engineering tests?"

**Expected Tool**: SV_CUSTOMER_INTELLIGENCE (Cortex Analyst)

**Expected Analysis**:
- Use test_pass_rate metric
- Calculate passed_tests / completed_tests
- Expected: 75-85% pass rate

---

## Complex Questions (Semantic Views)

These questions test more sophisticated analysis capabilities.

### Question 6: At-Risk Programs by Cost Variance
**Question**: "Which programs have cost variance worse than -10% and what are their risk levels? Show me the top 10 by cost variance."

**Expected Tool**: SV_PROGRAM_INTELLIGENCE (Cortex Analyst)

**Expected Analysis**:
- Filter programs where cost_variance < -10
- Include program_name, cost_variance, risk_level dimensions
- Order by cost_variance ascending (most negative first)
- Limit to 10 results
- Cross-reference with risk_level dimension

---

### Question 7: Supplier Performance Trends
**Question**: "What is the trend in on-time delivery performance by supplier tier over the last 12 months?"

**Expected Tool**: SV_OPERATIONS_INTELLIGENCE (Cortex Analyst)

**Expected Analysis**:
- Group by supplier_tier and evaluation_period
- Calculate avg_on_time_delivery metric
- Filter to last 12 months
- Show trend by tier (1, 2, 3)

---

### Question 8: Division Production Metrics
**Question**: "Compare the on-time completion rate and quality issue count between the Hypersonics and Unmanned Systems divisions."

**Expected Tools**: 
- SV_PROGRAM_INTELLIGENCE (for division context)
- SV_OPERATIONS_INTELLIGENCE (for production/quality metrics)

**Expected Analysis**:
- Filter by division_code IN ('HYPER', 'UAS')
- Calculate on-time completion percentage
- Count open quality issues per division
- Present comparison table

---

### Question 9: Contract Performance Analysis
**Question**: "What is the billing percentage by contract type, and which types have the highest unbilled amounts?"

**Expected Tool**: SV_PROGRAM_INTELLIGENCE (Cortex Analyst)

**Expected Analysis**:
- Group by contract_type (FFP, CPFF, CPIF, T&M, etc.)
- Calculate billing_pct = total_billed / total_funded
- Calculate unbilled = total_funded - total_billed
- Order by unbilled descending

---

### Question 10: Critical Customer Tickets
**Question**: "Which customers have the most critical priority open tickets, and what is the average time to first response?"

**Expected Tool**: SV_CUSTOMER_INTELLIGENCE (Cortex Analyst)

**Expected Analysis**:
- Filter by ticket_priority = 'CRITICAL' and ticket_status != 'CLOSED'
- Group by customer_name
- Count critical_tickets
- Calculate average response time
- Order by ticket count descending

---

## ML Model Questions

These questions test the ML prediction capabilities.

### Question 11: Program Risk Prediction
**Question**: "What is the risk prediction for program PRG000001? Is it likely to have schedule or cost issues?"

**Expected Tool**: PREDICT_PROGRAM_RISK procedure

**Expected Analysis**:
- Call PREDICT_PROGRAM_RISK('PRG000001')
- Return prediction (0 = low risk, 1 = high risk)
- Include risk assessment explanation
- Show key factors: cost_variance, schedule_variance, risk_level

**Expected Output Format**:
```
Program: PRG000001 (Hypersonic Strike Alpha System)
Current Risk Level: MEDIUM
Cost Variance: -5.2%
Schedule Variance: -3.1%
Predicted Risk: LOW RISK - Program on track
Assessment: Based on current metrics, this program is not expected to have significant schedule or cost issues.
```

---

### Question 12: Supplier Risk Prediction
**Question**: "Is supplier SUP00001 at risk of quality or delivery issues?"

**Expected Tool**: PREDICT_SUPPLIER_RISK procedure

**Expected Analysis**:
- Call PREDICT_SUPPLIER_RISK('SUP00001')
- Return prediction (0 = low risk, 1 = high risk)
- Include supplier performance metrics
- Provide risk assessment

**Expected Output Format**:
```
Supplier: SUP00001 (Apex Industries)
Type: MANUFACTURER
Quality Rating: 85.5
Delivery Rating: 88.2
Predicted Risk: LOW RISK - Supplier performing well
Assessment: This supplier shows strong quality and delivery performance with no significant risk indicators.
```

---

### Question 13: Production Forecast
**Question**: "Forecast production for January 2026. How many work orders should we expect?"

**Expected Tool**: FORECAST_PRODUCTION procedure

**Expected Analysis**:
- Call FORECAST_PRODUCTION(1, 2026)
- Return forecasted production count
- Compare to historical averages
- Provide capacity assessment

**Expected Output Format**:
```
Forecast Period: January 2026
Historical Average (January): 850 work orders
Forecasted Production: 920 work orders
Assessment: INCREASED production expected - 8% above historical average
Recommendation: Ensure adequate staffing and materials for higher volume.
```

---

### Question 14: Multi-Program Risk Analysis
**Question**: "Which of the Hypersonics division programs are predicted to be at risk? Run risk predictions for the top 5 programs by contract value."

**Expected Tools**:
- SV_PROGRAM_INTELLIGENCE (to identify programs)
- PREDICT_PROGRAM_RISK (for each program)

**Expected Analysis**:
1. Query top 5 Hypersonics programs by total_contract_value
2. For each program, run PREDICT_PROGRAM_RISK
3. Compile results showing predicted risk for each
4. Summarize overall division risk posture

---

### Question 15: Supplier Risk Summary
**Question**: "How many of our Tier 1 suppliers are predicted to be at risk? What percentage is that?"

**Expected Tools**:
- SV_OPERATIONS_INTELLIGENCE (to identify Tier 1 suppliers)
- PREDICT_SUPPLIER_RISK (for each supplier)

**Expected Analysis**:
1. Query all Tier 1 suppliers
2. Run risk prediction for each
3. Count suppliers with predicted_risk = 1
4. Calculate percentage of at-risk suppliers
5. Provide summary and recommendations

---

## Bonus: Cortex Search Questions

These questions test the unstructured data search capabilities.

### Search Question 1: XQ-58A Documentation
**Question**: "Find technical specifications for the XQ-58A Valkyrie drone."

**Expected Tool**: TECHNICAL_DOCS_SEARCH

**Expected Results**:
- System Specification documents for XQ-58A
- Interface Control Documents
- Performance specifications
- Key parameters: speed, range, payload

---

### Search Question 2: Vibration Test Results
**Question**: "Search for vibration test reports that showed anomalies or deviations."

**Expected Tool**: TEST_REPORTS_SEARCH

**Expected Results**:
- Test reports with test_type = 'Vibration'
- Reports with result_status = 'PASS_WITH_DEVIATION' or 'FAIL'
- Anomaly descriptions and corrective actions

---

### Search Question 3: Program Review Action Items
**Question**: "Find program reviews with open action items related to schedule risks."

**Expected Tool**: PROGRAM_REVIEWS_SEARCH

**Expected Results**:
- PMR and status review documents
- Reviews with action_items mentioning schedule
- Risk summary sections
- Recommendations for schedule recovery

---

## Testing Guidance

### Order of Testing

1. **Start Simple**: Test questions 1-5 first to verify semantic views work
2. **Test Complexity**: Progress to questions 6-10 for multi-dimension queries
3. **Test ML**: Verify ML predictions with questions 11-13
4. **Test Integration**: Questions 14-15 combine semantic views with ML
5. **Test Search**: Verify Cortex Search with bonus questions

### Expected Behavior

- **Response Time**: Simple queries < 5 seconds, complex < 15 seconds
- **Accuracy**: Data should match what's in the underlying tables
- **Formatting**: Results should be properly formatted and readable
- **Context**: Agent should provide relevant context and explanations

### Troubleshooting

If questions don't work:
1. Verify semantic views exist: `SHOW SEMANTIC VIEWS IN SCHEMA ANALYTICS;`
2. Check table data: `SELECT COUNT(*) FROM RAW.PROGRAMS;`
3. Verify agent tools are configured correctly
4. Check for permission issues in query history

---

**Version**: 1.0  
**Last Updated**: November 2025  
**Total Questions**: 15 (+ 3 bonus search questions)

