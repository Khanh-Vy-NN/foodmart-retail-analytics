-- Append transaction_97 & transaction_98
create or replace view dw.vw_transactions_clean as
with combined as (
     select *
     from raw.transactions_1997 t 
     
     union all 
     
     select *
     from raw.transactions_1998
)
select 
  to_date(trim(transaction_date), 'DD/MM/YY')
    as transaction_date,
  to_date(trim(stock_date), 'DD/MM/YY') 
    as stock_date,

  TRIM (product_id):: INTEGER as product_id,
  TRIM (customer_id):: INTEGER as customer_id,
  TRIM(store_id)::INTEGER AS store_id,
  TRIM(quantity)::INTEGER AS quantity
  
from combined;

SELECT *
FROM dw.vw_transactions_clean
LIMIT 10;

SELECT COUNT(*) AS total_rows
FROM dw.vw_transactions_clean;