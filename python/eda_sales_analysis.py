#!/usr/bin/env python3
"""Retail sales EDA, KPI calculations, and CSV summary export."""
from pathlib import Path
import pandas as pd
import matplotlib.pyplot as plt

ROOT = Path(__file__).resolve().parents[1]
DATA_PATH = ROOT / "data" / "retail_sales_data.csv"
OUTPUT = ROOT / "outputs"
OUTPUT.mkdir(exist_ok=True)

def main():
    df = pd.read_csv(DATA_PATH, parse_dates=["Order_Date"])
    print(f"Loaded {len(df):,} rows")
    missing_before = int(df.isna().sum().sum())
    duplicate_rows_before = int(df.duplicated().sum())
    # Numeric fields: fill missing with median; categorical fields with explicit unknown label.
    numeric = ["Sales", "Quantity", "Discount", "Profit"]
    for col in numeric:
        df[col] = pd.to_numeric(df[col], errors="coerce")
        df[col] = df[col].fillna(df[col].median())
    for col in ["Customer_ID", "Region", "Category", "Sub_Category"]:
        df[col] = df[col].fillna("Unknown")
    df = df.drop_duplicates().copy()
    # Derived KPI fields
    total_sales = float(df["Sales"].sum())
    total_profit = float(df["Profit"].sum())
    kpis = {
        "rows_loaded": int(len(pd.read_csv(DATA_PATH))),
        "rows_after_cleaning": int(len(df)),
        "missing_cells_before_cleaning": missing_before,
        "duplicate_rows_before_cleaning": duplicate_rows_before,
        "total_revenue": round(total_sales, 2),
        "total_profit": round(total_profit, 2),
        "profit_margin_pct": round(100 * total_profit / total_sales, 2) if total_sales else None,
        "average_order_value": round(float(df["Sales"].mean()), 2),
        "total_orders": int(df["Order_ID"].nunique()),
        "unique_customers": int(df["Customer_ID"].nunique()),
        "total_units": int(df["Quantity"].sum()),
        "average_discount_pct": round(100 * float(df["Discount"].mean()), 2),
        "discount_profit_pearson_correlation": round(float(df["Discount"].corr(df["Profit"])), 4),
    }
    monthly = df.assign(Month=df["Order_Date"].dt.to_period("M").astype(str)).groupby("Month", as_index=False)["Sales"].sum()
    monthly["MoM_Growth_Pct"] = monthly["Sales"].pct_change() * 100
    monthly.to_csv(OUTPUT / "monthly_sales_summary.csv", index=False)
    region_category = df.groupby(["Region", "Category"], as_index=False).agg(Revenue=("Sales","sum"), Profit=("Profit","sum"))
    region_category["Profit_Margin_Pct"] = 100 * region_category["Profit"] / region_category["Revenue"]
    region_category.to_csv(OUTPUT / "region_category_summary.csv", index=False)
    pd.Series(kpis, name="value").to_csv(OUTPUT / "kpi_summary.csv", header=True)
    # Charts saved for easy inclusion in a BI dashboard or portfolio README.
    monthly.plot(x="Month", y="Sales", kind="line", marker="o", title="Monthly Revenue Trend", legend=False)
    plt.ylabel("Revenue"); plt.xticks(rotation=45); plt.tight_layout(); plt.savefig(OUTPUT / "monthly_sales_trend.png", dpi=160); plt.close()
    category = df.groupby("Category")["Profit"].sum().sort_values()
    category.plot(kind="bar", title="Profit by Category"); plt.ylabel("Profit"); plt.tight_layout(); plt.savefig(OUTPUT / "profit_by_category.png", dpi=160); plt.close()
    print("\nKEY KPIs")
    for k, v in kpis.items(): print(f"{k}: {v}")
    print(f"\nOutputs saved to: {OUTPUT}")

if __name__ == "__main__":
    main()
