# GTM & Sales Operations Analytics | SQL Portfolio

**A synthetic B2B SaaS sales dataset and SQL analysis project** demonstrating practical Revenue Operations, Go-to-Market (GTM), pipeline, pricing, and sales performance analysis.

> All company names, people, and records in this project are fictional and generated for learning and portfolio use. No real customer or employer data is included.

## Business context

A fictional B2B SaaS company sells a multi-product platform across North America, LATAM, EMEA, and APAC. The GTM team wants a repeatable view of pipeline health, bookings, sales-motion effectiveness, discounting, rep performance, and follow-up coverage.

## Questions this project answers

1. How much open pipeline ACV is available, and how much ACV has been won?
2. What is the win rate among closed opportunities?
3. Which regions and sales motions show the strongest performance?
4. How does discounting relate to win rate and average won deal size?
5. Which open opportunities may be stale due to lack of recent completed activity?
6. How do bookings trend by month and product line?
7. What are the most common lost-deal reasons?
8. How does opportunity performance vary by region and company-size segment?

## Dataset

| File | Grain | Description |
|---|---|---|
| `data/accounts.csv` | One row per account | Region, industry, segment, country, lead source |
| `data/sales_reps.csv` | One row per sales rep | Rep, region, primary segment, hire date |
| `data/opportunities.csv` | One row per opportunity | Stage, sales motion, product, ACV, discount, outcome |
| `data/activities.csv` | One row per activity | Activity type, date, completion, duration, channel |

Approximate volume:
- 150 accounts
- 12 sales reps
- 360 opportunities
- 1,000 activities

### Key definitions

- **ACV**: Annual Contract Value, represented in USD.
- **Open pipeline ACV**: Sum of ACV for opportunities that are not closed. This is unweighted pipeline, not forecasted revenue.
- **Bookings / won ACV**: Sum of ACV for opportunities marked Closed Won.
- **Win rate**: Closed Won opportunities divided by all closed opportunities (Closed Won + Closed Lost).
- **Discount**: Synthetic percentage discount field.
- **Stale opportunity**: Open opportunity with no completed activity in the last 30 days, based on the query's run date.

These are simplified portfolio definitions. Real organizations may define pipeline, bookings, ACV, stage entry, and activity coverage differently.

## SQL skills demonstrated

- Filtering, sorting, and aggregation (`WHERE`, `ORDER BY`, `GROUP BY`)
- Conditional aggregation and safe division (`FILTER`, `NULLIF`)
- Joining related datasets (`JOIN`, `LEFT JOIN`)
- CTEs (`WITH`)
- Window functions (`OVER`)
- Date analysis (`DATE_TRUNC`, date arithmetic)
- Business logic using `CASE WHEN`
- KPI definition and interpretation

**SQL dialect:** PostgreSQL 14+. The scripts use PostgreSQL-specific features such as aggregate `FILTER`, `DATE_TRUNC`, and date arithmetic. Adapt syntax before using another database engine.

## Project structure

```text
gtm_sales_operations_sql_portfolio/
├── README.md
├── DATA_DICTIONARY.md
├── ANALYSIS_NOTES.md
├── data/
│   ├── accounts.csv
│   ├── sales_reps.csv
│   ├── opportunities.csv
│   └── activities.csv
└── sql/
    ├── 01_schema.sql
    └── 02_gtm_sales_analysis.sql
```

## How to run it

### Option A: PostgreSQL

1. Install PostgreSQL locally or use an approved learning database.
2. Create a database, for example `gtm_portfolio`.
3. Run `sql/01_schema.sql` to create the tables.
4. Import each CSV into its matching table. In pgAdmin, use **Import/Export Data** and set the header option on.
5. Run queries from `sql/02_gtm_sales_analysis.sql`.

The CSV headers match the schema column names. Ensure CSV date fields are imported as `DATE`, numeric fields as numeric, and boolean fields as boolean.

### Option B: use another SQL environment

You can adapt the schema and queries for SQLite, DuckDB, SQL Server, BigQuery, or Snowflake. Some syntax changes will be needed. Do not upload real employer data into personal or public environments.

## Suggested dashboard

Use Power BI, Tableau, or a spreadsheet with these visuals:
- KPI cards: Open Pipeline ACV, Won ACV, Win Rate, Average Won ACV
- Bar chart: pipeline and won ACV by region
- Funnel or stage distribution: opportunities by stage
- Bar chart: win rate by sales motion
- Scatter or table: discount versus win rate, with sample sizes
- Table: stale opportunities with ACV and last completed activity
- Line chart: monthly bookings

## Portfolio caveats

- The dataset is synthetic and intentionally simplified.
- The current stage distribution is not a cohort-based funnel conversion calculation.
- The discount analysis is observational, not causal. A relationship between discount and win rate does not prove that discounting caused a deal to win.
- Rep-level comparisons should be interpreted with caution because territory, tenure, deal mix, and sample sizes differ.
- Activity count is not a proxy for activity quality or sales effectiveness.
- The data is not intended for forecasting or business decisions.

## Next improvements

1. Add stage history to calculate true stage-to-stage conversion and time in stage.
2. Add quota and target tables to calculate attainment.
3. Add monthly pipeline snapshots to analyze pipeline coverage and slippage.
4. Add source-level acquisition cost and spend to assess GTM efficiency.
5. Build a dashboard and write an executive summary with recommendations.

## GitHub publishing checklist

- Keep the README and data dictionary in the repository root.
- Commit the SQL scripts and synthetic CSV files.
- Add screenshots of a dashboard only after creating it.
- Do not include credentials, access tokens, internal screenshots, employer data, or proprietary business definitions.
- In your portfolio description, clearly label this as a **synthetic case study**, not work performed for an employer.
