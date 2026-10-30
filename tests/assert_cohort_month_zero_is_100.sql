-- Every cohort is defined by its first month, so month 0 retention
-- must be exactly 100%. Any other value means the cohort logic is wrong.
select *
from {{ ref('rpt_cohort_retention') }}
where months_since_first = 0 and retention_pct <> 100
