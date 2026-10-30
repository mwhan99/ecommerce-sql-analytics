# CLAUDE.md

SQL portfolio project for Meng (job hunting for data/analyst roles that ask
for SQL). Meng is new to this stack: explain each step in plain English.

- Data: Olist Brazilian e-commerce (Kaggle), CSVs in `data/raw/` (git-ignored).
- dbt-duckdb reads the CSVs directly via `meta.external_location` in
  `models/staging/_sources.yml`; there is no loader script.
- Layers: `models/staging` (views, `staging` schema) → `models/marts`
  (tables, `marts` schema) → `models/reporting` (one `rpt_*` table per
  business question, `reporting` schema). `macros/generate_schema_name.sql`
  keeps schema names plain.
- Run everything from the project root: `.venv/bin/dbt build`
  (`profiles.yml` lives here, so no `~/.dbt` setup is needed). The SQL
  notebook (`scripts/sql_notebook.py`) locks `warehouse.duckdb`; to build
  while it runs, set `DBT_DUCKDB_PATH` to a copy of the file.
- Note: Olist issues a new `customer_id` per order; `customer_unique_id`
  is the real person key. "Late" = delivered after the promised date.
- The README's Key findings quote numbers from the `reporting` tables.
  Re-check them if any model changes.
- Status (2026-10-30): all 10 analyses built and written up. Meng chose to
  have Claude build first, then learn it lesson by lesson (Lessons 2–12),
  using these files as the answer key. Still to do: GitHub repo, Tableau
  Public dashboard (Meng builds it), and a 5–6 slide deck.
