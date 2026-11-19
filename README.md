# Retail Sales & Customer Churn Analysis (SQL + Python)

> Portfolio case study using a synthetic retail dataset. The dataset is generated for practice and is not company/customer data. Churn is approached as an **at-risk customer proxy** (recency, low repeat activity, and profitability); no true churn label is present.

## Business Problem & Objective
Retail teams need to understand what drives revenue and profit across regions, categories, products, discounts, and customer groups. This analysis answers: which regions/categories contribute most, how sales change month to month, where discounts may erode profitability, and which customers merit retention outreach.

## Dataset & Tools
- **Dataset:** 100 order-line records, 2025 dates, 35 synthetic customer IDs; columns: Order_ID, Order_Date, Customer_ID, Region, Category, Sub_Category, Sales, Quantity, Discount, Profit.
- **SQL:** aggregation, CTEs, joins-ready relational analysis, `RANK`, `LAG`, segmentation, revenue share. Queries use PostgreSQL-style syntax.
- **Python:** pandas for data quality and KPI analysis; matplotlib for visualizations.
- **Excel / BI:** CSV is Excel-friendly; summary exports can be imported into Excel, Power BI, or Tableau.

## Snapshot Insights (calculated from included CSV)
- **Revenue:** $34,170.95; **profit:** $-2,360.55; overall profit margin: **-6.91%**.
- **Average order value:** $341.71; 100 order records and 32 distinct customers.
- **Leading sales region:** West; **leading category by sales:** Technology.
- **Most profitable sub-category:** Tables; weakest profit sub-category: Computers ($-1,722.34).
- **Average discount:** 17.2%; Pearson correlation between order discount and profit: **-0.456** (correlation does not establish causation).
- Discount-heavy loss-makers meeting average discount ≥15% and total profit <0: Accessories, Art Supplies, Binders, Computers, Labels, Paper, Phones, Printers.

## Recommendations
1. **Discount governance:** investigate sub-categories with high average discounts and negative aggregate profit; test discount caps or approval thresholds, then compare margin and conversion.
2. **Regional planning:** use regional/category margin and revenue share to allocate inventory and promotions, not revenue alone.
3. **Customer retention:** prioritize customers flagged at-risk by recency/profit proxy; run a small win-back test and track repeat purchase and incremental profit.
4. **Monthly performance:** monitor MoM revenue and category trends; annotate seasonality and one-off order effects.
5. **BI-ready reporting:** import `outputs/region_category_summary.csv` and `outputs/monthly_sales_summary.csv` into Excel/Power BI/Tableau for slicers and dashboards.

## Repository contents
- `data/retail_sales_data.csv` — source dataset
- `sql/business_queries.sql` — eight commented business analysis queries
- `python/eda_sales_analysis.py` — cleaning, KPIs, correlation, exports, and charts
- `outputs/` — created when the Python script runs

## Run locally
### Python
```bash
python -m pip install pandas matplotlib
python python/eda_sales_analysis.py
```
Generated outputs: KPI summary, monthly sales, region/category summary CSVs, and two PNG charts under `outputs/`.

### SQL
1. Create a table named `retail_sales` with the ten dataset columns (use `DATE` for `Order_Date`, numeric types for metrics).
2. Import the CSV using your SQL tool (pgAdmin/psql or compatible importer).
3. Run `sql/business_queries.sql` in PostgreSQL. For other SQL engines, adjust date-truncation and interval syntax.

## Limitations & Next Steps
- Synthetic data, small sample, no real business context; insights are illustrative and not generalizable.
- Customer “at-risk” is a rule-based proxy, not validated churn prediction.
- Extend with cohort retention, a labelled churn dataset, a Power BI dashboard, statistical tests, and sensitivity analysis for discount changes.

**Portfolio note:** This is a learning project demonstrating workflow and business reasoning, not professional experience.
