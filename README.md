# E-commerce SQL Analytics

A SQL analytics project on ~100k real orders from Olist, a Brazilian
online marketplace (2016–2018). Raw CSVs are modelled into clean tables
with **dbt** on **DuckDB**, then used to answer business questions with SQL.

> Status: work in progress. Models are built; analyses and a live
> dashboard are next.

## Stack

| Tool | Role |
|---|---|
| DuckDB | Analytical SQL database in a single local file |
| dbt | Organises SQL into tested, layered models |
| SQL | CTEs, joins, window functions, aggregations |

## Data model

```
raw CSVs (data/raw/)
  └─ staging/   one cleaned view per source table (stg_*)
       └─ marts/   report-ready tables
            ├─ fct_orders        one row per order: totals, delivery timing, review
            ├─ fct_order_items   one row per item: category, seller state
            └─ dim_customers     one row per person: cohort month, lifetime spend
```

21 data tests check keys are unique and present, statuses and review scores
are valid, and payments roughly match item totals.

## Run it yourself

1. Download the dataset from Kaggle:
   https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce
   and unzip the CSVs into `data/raw/`.
2. Set up and build:

   ```bash
   python3 -m venv .venv
   .venv/bin/pip install -r requirements.txt
   .venv/bin/dbt build
   ```

   This creates `warehouse.duckdb` with the `staging` and `marts` schemas.

## Data source

Olist, *Brazilian E-Commerce Public Dataset*, Kaggle (CC BY-NC-SA 4.0).
