# CLAUDE.md

SQL portfolio project for Meng (job hunting for data/analyst roles that ask
for SQL). Meng is new to this stack: explain each step in plain English.

- Data: Olist Brazilian e-commerce (Kaggle), CSVs in `data/raw/` (git-ignored).
- dbt-duckdb reads the CSVs directly via `meta.external_location` in
  `models/staging/_sources.yml`; there is no loader script.
- Layers: `models/staging` (views, `staging` schema) → `models/marts`
  (tables, `marts` schema). `macros/generate_schema_name.sql` keeps
  schema names plain.
- Run everything from the project root: `.venv/bin/dbt build`
  (`profiles.yml` lives here, so no `~/.dbt` setup is needed).
- Note: Olist issues a new `customer_id` per order; `customer_unique_id`
  is the real person key.
- Plan: 8–10 business-question analyses (cohort retention, MoM revenue,
  seller rankings, late delivery vs reviews, repeat customers / LTV),
  then an Evidence.dev site on Vercel showing the SQL next to each chart.
