select current_database();

select   
   table_name,
   column_name,  
   data_type
from information_schema.columns 
where table_schema = 'raw'
   and table_name in (
    	'store_lookup'
   		'region_lookup'
   )
order by table_name, ordinal_position; 

SELECT *
FROM raw.store_lookup
LIMIT 5;

SELECT *
FROM raw.region_lookup
LIMIT 5;

CREATE TABLE IF NOT EXISTS dw.dim_store (
    store_id INTEGER PRIMARY KEY,
    region_id INTEGER,
    store_name TEXT,
    store_type TEXT,
    store_city TEXT,
    store_state TEXT,
    store_country TEXT,
    sales_district TEXT,
    sales_region TEXT
);

INSERT INTO dw.dim_store (
    store_id,
    region_id,
    store_name,
    store_type,
    store_city,
    store_state,
    store_country,
    sales_district,
    sales_region
)
SELECT
    s.store_id,
    s.region_id,
    NULLIF(TRIM(s.store_name), ''),
    NULLIF(TRIM(s.store_type), ''),
    NULLIF(TRIM(s.store_city), ''),
    NULLIF(TRIM(s.store_state), ''),
    NULLIF(TRIM(s.store_country), ''),
    NULLIF(TRIM(r.sales_district), ''),
    NULLIF(TRIM(r.sales_region), '')
from raw.store_lookup as s
left join raw.region_lookup as r 
   on s.region_id = r.region_id; 

SELECT COUNT(*) AS total_stores
FROM dw.dim_store;


