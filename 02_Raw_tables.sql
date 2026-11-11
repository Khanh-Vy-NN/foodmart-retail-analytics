CREATE TABLE IF NOT EXISTS raw.transactions_1997 (
    transaction_date TEXT,
    stock_date TEXT,
    product_id TEXT,
    customer_id TEXT,
    store_id TEXT,
    quantity TEXT
);

CREATE TABLE IF NOT EXISTS raw.transactions_1998 (
    transaction_date TEXT,
    stock_date TEXT,
    product_id TEXT,
    customer_id TEXT,
    store_id TEXT,
    quantity TEXT
);

select count (*) as total_rows
from raw.transactions_1997;

select count (*) as total_rows
from raw.transactions_1998;

select table_schema, table_name
from information_schema.tables 
WHERE table_schema = 'raw'
ORDER BY table_name;

SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'raw'
  AND table_name = 'transactions_1997'
ORDER BY ordinal_position;

select transaction_date,  
       to_date (
         trim (transaction_date),
         'DD/MM/YY'
) as clean_transaction_date,
       stock_date,
       to_date (
         trim (stock_date),
         'DD/MM/YY'
) as clean_stock_date
FROM raw.transactions_1997
LIMIT 10;
         