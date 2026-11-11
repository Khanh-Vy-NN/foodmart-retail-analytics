-- Reconciliation
select 
  extract(year from transaction_date)::INT as sales_year,
  count(*) as total_transactions, 
  sum(quantity) as units_sold
from dw.vw_transactions_clean
group by sales_year
order by sales_year;

-- Check NULLS and abnormal dates
select 
  count(*) filter (
    where transaction_date is null 
  ) as missing_transaction_dates,
  count(*) filter (
    where stock_date is null 
  ) as missing_stock_dates,
  count(*) filter (
    where quantity is null
  ) as missing_quantity,
  count(*) filter (
    where quantity <= 0
  ) as invalid_quantity,
  
  MIN (transaction_date) as earliest_date,
  MAX (transaction_date) as latest_date

from dw.vw_transactions_clean;