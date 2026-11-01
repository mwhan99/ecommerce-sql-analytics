# E-commerce SQL Analytics

SQL analysis of **~100k real orders** from Olist, a Brazilian online
marketplace (2016–2018), plus Olist's **marketing funnel** data (8,000 seller
leads). Raw CSVs are modelled into tested tables with **dbt** on **DuckDB**,
then used to answer 10 business questions about growth, retention, customer
value, promotions, delivery and acquisition.

**📊 Interactive dashboard:** [Olist E-commerce Analytics on Tableau Public](https://public.tableau.com/app/profile/meng.wen.han/viz/OlistE-commerceAnalytics_17934985929420/Dashboard)


## Key findings

| # | Question | Finding |
|---|---|---|
| 1 | How is the business trending? | Revenue for Jan–Aug 2018 was **2.4× Jan–Aug 2017** (R$7.3M vs R$3.1M). Black Friday made Nov 2017 the peak month (**+52%** vs October). Growth then levelled off at about R$0.85–1.0M a month in 2018. |
| 2 | Do customers come back? | Only **3.0%** of customers ever place a second order, and under **1%** of a monthly cohort buys again the next month. Growth depends almost entirely on new customers. |
| 3 | Who are the VIPs? | The top **1%** of customers (spending R$1,000+) bring **11%** of revenue, and the top 10% bring **41%**. Even VIPs rarely return (6.7%): their status comes from one big purchase, not loyalty. |
| 4 | Do vouchers pay off? | Customers who used a voucher on their first order came back slightly more (**3.7% vs 3.0%**) but spent **20% less** over their lifetime (R$114 vs R$143), with an average voucher of R$94. The extra repeat business doesn't come close to covering that. |
| 5 | Does late delivery hurt satisfaction? | Yes, sharply. On-time orders average **4.29★**. Orders 4–7 days late average **2.10★**, and their 1-star rate jumps from **6.6% to 59%**. 6.8% of orders arrive late. |
| 6 | Where is delivery worst? | São Paulo is **38%** of revenue with 4.4% late. Rio de Janeiro is the #2 market (13%) but **11.8%** late with a 3.90★ average. Some north-eastern states are 17–21% late. |
| 7 | Which categories drive revenue? | The top 10 of 74 categories bring **62%** of revenue, led by health & beauty (9.3%) and watches & gifts (8.9%). |
| 8 | How concentrated are sellers? | The top **10%** of sellers (306 of 3,053) bring **68%** of revenue. |
| 9 | When do repeat customers return? | **50%** of repeat orders come within 30 days, but 29% are on the same day, which is likely one basket split into two orders. |
| 10 | Which marketing channels work? | **10.5%** of leads became sellers. Paid search converts **12.3%** at **R$96 revenue per lead**, while social converts 5.6% (R$32) and email 3.0% (R$17). |

### Recommendations

1. **Fix delivery in Rio de Janeiro first.** It's the second-biggest market,
   with nearly 3× São Paulo's late rate, and lateness is the clearest driver of
   1-star reviews.
2. **Treat retention as the main growth lever.** With 3% repeat, even a small
   gain is significant. Half of repeat purchases happen within 30 days, so a
   win-back offer should go out inside that window.
3. **Test vouchers with a holdout group before scaling them.** The current data
   suggests they cost far more than they return, but only an experiment can
   show cause and effect.
4. **Shift seller-acquisition budget toward paid and organic search** and away
   from social and email. Also fix lead-source tracking: 14% of leads are
   "unknown", and that group converts best of all.

### Limitations

- **Comparisons, not experiments.** Voucher users may differ from other
  customers to begin with (finding 4), so the results show association,
  not cause.
- **"Voucher" in Olist's data** may include gift cards and store credit, not
  only promotions.
- **Incomplete months.** The export is thin before Jan 2017 and after Aug 2018.
  Those months are flagged and left out of growth rates.
- **Short sales window.** Marketing leads run Jun 2017–May 2018 but orders stop
  in Oct 2018, so late sign-ups have had little time to sell.
- **Data issues found and handled:** 8 "delivered" orders have no delivery
  date; some orders have 2 reviews (the latest is kept); and Olist issues a new
  `customer_id` per order, so `customer_unique_id` is used as the person.

## How it's built

```
raw CSVs (data/raw/)
  └─ staging/     one cleaned view per source table (types, names, duplicates)
       └─ marts/      fct_orders · fct_order_items · dim_customers
            └─ reporting/  rpt_* — one table per business question
```

| Tool | Role |
|---|---|
| DuckDB | Analytical SQL database in a single local file |
| dbt | Organises SQL into layers, with 32 automated data tests |
| SQL | CTEs, joins, window functions, aggregations |

### Where to find each analysis

| # | File | SQL techniques |
|---|---|---|
| 1 | [rpt_monthly_kpis.sql](models/reporting/rpt_monthly_kpis.sql) | `GROUP BY`, `COUNT(DISTINCT)`, `LAG()`, `NULLIF` |
| 2 | [rpt_cohort_retention.sql](models/reporting/rpt_cohort_retention.sql) | CTEs, `MIN()` first date, `DATE_DIFF`, cohort joins |
| 3 | [rpt_customer_segments.sql](models/reporting/rpt_customer_segments.sql) | `NTILE()`, `CASE WHEN`, `SUM(SUM()) OVER ()` |
| 4 | [rpt_promo_vouchers.sql](models/reporting/rpt_promo_vouchers.sql) | `LEFT JOIN` flags, `COALESCE`, group comparison |
| 5 | [rpt_delivery_reviews.sql](models/reporting/rpt_delivery_reviews.sql) | `DATE_DIFF`, bucketing, conditional averages |
| 6 | [rpt_state_performance.sql](models/reporting/rpt_state_performance.sql) | `RANK()`, share of total |
| 7 | [rpt_category_performance.sql](models/reporting/rpt_category_performance.sql) | Joins, `RANK()`, running total |
| 8 | [rpt_top_sellers_by_state.sql](models/reporting/rpt_top_sellers_by_state.sql) | `ROW_NUMBER() OVER (PARTITION BY …)`: top N per group |
| 9 | [rpt_repeat_purchase_timing.sql](models/reporting/rpt_repeat_purchase_timing.sql) | `LAG() OVER (PARTITION BY …)` |
| 10 | [rpt_marketing_funnel.sql](models/reporting/rpt_marketing_funnel.sql) | Funnel via `LEFT JOIN`s, conditional counts, `MEDIAN` |

## Run it yourself

1. Download both datasets from Kaggle and unzip all CSVs into `data/raw/`:
   - https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce
   - https://www.kaggle.com/datasets/olistbr/marketing-funnel-olist
2. Set up and build:

   ```bash
   python3 -m venv .venv
   .venv/bin/pip install -r requirements.txt
   .venv/bin/dbt build
   ```

   This creates `warehouse.duckdb` with `staging`, `marts` and `reporting`
   schemas and runs every test.

### Explore with SQL

```bash
.venv/bin/python scripts/sql_notebook.py
```

opens the DuckDB notebook at `localhost:4213`, connected to
`warehouse.duckdb`. Stop it (Ctrl+C) before running `dbt build`.

## Data source

Olist, *Brazilian E-Commerce Public Dataset* and *Marketing Funnel by Olist*,
Kaggle (CC BY-NC-SA 4.0).
