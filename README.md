# FoodMart | Retail Performance Intelligence

**End-to-end retail analytics project | PostgreSQL · SQL ETL · Dimensional Modeling · Power BI · DAX**

A business intelligence case study analyzing FoodMart retail performance across **1997–1998**. The project transforms raw transaction and reference data into a dimensional data warehouse and an interactive, three-page Power BI report.

📄 **[View the dashboard (PDF)](FoodMart.pdf)**

## Business questions

- How did revenue, unit sales, gross profit, and gross margin change over time?
- Which products and membership tiers contributed most to revenue?
- How do returns differ by product brand and store?
- Which store types and regions contribute most to sales, and how do revenue and returns relate?

## Dashboard pages

| Page | Analysis |
| --- | --- |
| **General — Sales Performance** | Revenue, gross profit, COGS, units sold, monthly sales trends, average selling price, and year-over-year revenue growth |
| **Product — Product & Customer Insights** | Top products, member-card revenue mix, returns by brand, and gender purchase mix |
| **Store — Store & Regional Performance** | Revenue by store type, revenue per active store by region, store return rates, and revenue-versus-return-rate comparison |

The report uses a green/emerald theme with interactive slicers for time and business dimensions.

## Data pipeline and model

```text
Raw CSV extracts / lookup tables
            │
            ▼
PostgreSQL raw schema
            │
            ▼
Cleaning and validation (SQL)
            │
            ▼
PostgreSQL dw schema (star-style dimensional model)
    ├── dim_date       ──► fact_sales  ◄── dim_customer
    ├── dim_product    ──► fact_sales
    ├── dim_store      ──► fact_sales
    ├── dim_date       ──► fact_returns
    ├── dim_product    ──► fact_returns
    └── dim_store      ──► fact_returns
            │
            ▼
Power BI data model → DAX measures → 3 report pages
```

**Model grain:** `fact_sales` stores transaction-line records; `fact_returns` stores return records. The return source does not identify individual customers or orders, so customer-segmented return rates are not supported.

### Data scope

| Component | Records |
| --- | ---: |
| Sales fact | 269,720 |
| Returns fact | 7,087 |
| Product dimension | 1,560 |
| Customer dimension | 10,281 |
| Store dimension | 24 |
| Date dimension | 730 days |

## Headline results (1997–1998 combined)

| Metric | Value |
| --- | ---: |
| Gross revenue | **$1,764,546.44** |
| Cost of goods sold | **$711,727.66** |
| Gross profit | **$1,052,818.78** |
| Gross margin | **59.67%** |
| Units sold | **833,489** |
| Units returned | **8,289** |
| Unit return rate | **~0.99%** |
| 1998 revenue growth vs. 1997 | **~112.18%** |

**Metric definitions:** Gross revenue = units sold × product retail price; COGS = units sold × product cost; gross profit = gross revenue − COGS; unit return rate = returned units ÷ sold units. Revenue and COGS use the prices/costs available in the product reference table, so they are **modeled values rather than verified historical selling prices**. Return value is likewise an estimate, not verified refunds.

## SQL project files

The repository currently stores scripts at the root (listed below in their intended execution order).

| Phase | Script |
| --- | --- |
| Schemas | [01_Database_Setup.sql](01_Database_Setup.sql) |
| Raw transactions | [02_Raw_tables.sql](02_Raw_tables.sql) |
| Transaction cleaning | [03_Transactions_cleaning.sql](03_Transactions_cleaning.sql) |
| Data validation | [04_Data_validation.sql](04_Data_validation.sql) |
| Product dimension | [05_dim_product.sql](05_dim_product.sql) |
| Customer dimension | [06_dim_customer.sql](06_dim_customer.sql) |
| Store dimension | [07_dim_store.sql](07_dim_store.sql) |
| Calendar dimension | [08_dim_date.sql](08_dim_date.sql) |
| Sales fact | [09_fact_sales.sql](09_fact_sales.sql) |
| Returns fact | [10_fact_returns.sql](10_fact_returns.sql) |
| KPI reconciliation | [11_kpi_reconciliation.sql](11_kpi_reconciliation.sql) |
| Year-over-year analysis | [12_yoy_analysis.sql](12_yoy_analysis.sql) |
| Monthly trend | [13_monthly_sales_trend.sql](13_monthly_sales_trend.sql) |

**Reproducibility note:** Source CSV files and manual reference-table imports are not included in this repository. The SQL files document the development workflow, including exploratory validation and setup-specific statements; **they are not yet a fully automated, rerunnable migration**. In particular, review any data-reset and schema-alteration statements before executing against a populated database.

## Analytical considerations

- **No order identifier:** Sales rows represent transaction lines; row counts should not be described as distinct orders.
- **Returns have no customer key:** Product, store, and date can filter both facts, but customer attributes cannot reliably filter returns.
- **Static catalog pricing:** Historical revenue, cost, and return values are derived from product reference prices/costs rather than transaction-specific price histories.
- **Date parsing:** Two-digit dates are interpreted using a 1900s assumption within the provided historical source context.
- **Year-over-year comparisons:** Observed growth describes this dataset; source coverage and comparability should be considered before inferring business causes.

## Tools

- **PostgreSQL + DBeaver:** Data ingestion, cleaning, validation, warehouse modeling, and analytical SQL
- **Power BI Desktop:** Relationships, DAX metrics, filtering, dashboard design, and PDF export

## Project deliverables

- [Dashboard PDF](FoodMart.pdf) — static preview of the three report pages
- [Power BI template](FoodMart.pbit) — report pages, visuals, Power BI model metadata, and measures; **does not include imported data** and requires Power BI Desktop plus access to compatible source tables to load and interact with the report
- SQL scripts (linked above)
- Power BI file with imported data (`.pbix`) and model diagram: **not included**

---
*Portfolio project for practicing end-to-end retail analytics. This is an analytical case study, not an official FoodMart report.*
