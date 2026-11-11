select
   column_name,
   data_type,  
   is_nullable
from information_schema.columns  
where table_schema  = 'raw'
   and table_name = 'product_lookup'
order by ordinal_position;  

select *
from raw.product_lookup
limit 5;

-- Check primary key
select 
  Count (*) as total_products,
  Count (distinct product_id) as unique_product_ids,  
  Count (*) filter (
     where product_id is null
  ) as missing_product_ids
from raw.product_lookup;

-- DDL & Primary key
create table dw.dim_product ( 
   product_id INTEGER primary key,
   product_brand TEXT,
   product_name TEXT,
   product_sku TEXT, 
   product_retail_price numeric (12,2), 
   product_cost numeric (12,2),
   product_weight real, 
   recyclable INTEGER,
   low_fat INTEGER
);

insert into dw.dim_product (
    product_id,
    product_brand,
    product_name,
    product_sku,
    product_retail_price,
    product_cost,
    product_weight,
    recyclable,
    low_fat
)
select
   product_id,
   trim(product_brand),
   trim(product_name),
   product_sku::TEXT,
    product_retail_price::NUMERIC(12,2),
    product_cost::NUMERIC(12,2),
    product_weight,
    recyclable,
    low_fat
FROM raw.product_lookup;

SELECT
    COUNT(*) AS total_products,
    COUNT(DISTINCT product_id) AS unique_products,
    MIN(product_retail_price) AS min_price,
    MAX(product_retail_price) AS max_price
FROM dw.dim_product;

SELECT *
FROM dw.dim_product
ORDER BY product_id
LIMIT 5;

--Quality check
select 
  count (*) as total_products,  
  count (*) filter (
      where product_name is null
        or trim (product_name) = ''
  ) as missing_names, 
  count (*) filter (
      where product_retail_price is null 
        or product_retail_price <= 0
  ) as invalid_prices, 
  COUNT(*) FILTER (
        WHERE product_cost IS NULL
           OR product_cost < 0
    ) AS invalid_costs,

    COUNT(*) FILTER (
        WHERE product_cost > product_retail_price
    ) AS products_below_cost,

    COUNT(*) FILTER (
        WHERE recyclable IS NULL
    ) AS missing_recyclable,

    COUNT(*) FILTER (
        WHERE low_fat IS NULL
    ) AS missing_low_fat

FROM dw.dim_product;

SELECT
    recyclable,
    low_fat,
    COUNT(*) AS total_products
FROM dw.dim_product
GROUP BY recyclable, low_fat
ORDER BY recyclable NULLS LAST,
         low_fat NULLS LAST;


 