select 
  column_name, 
  data_type, 
  is_nullable
from information_schema."columns" c 
where c.table_schema = 'raw'
  and table_name = 'customer_lookup'
order by ordinal_position; 

SELECT
    COUNT(*) AS total_customers,
    COUNT(DISTINCT customer_id) AS unique_customer_ids,
    COUNT(*) FILTER (
        WHERE customer_id IS NULL
    ) AS missing_customer_ids
FROM raw.customer_lookup;

SELECT
    customer_id,
    birthdate,
    acct_open_date,
    yearly_income,
    customer_postal_code,
    marital_status,
    member_card,
    homeowner
FROM raw.customer_lookup
ORDER BY customer_id
LIMIT 10;

select 
   customer_id,
   birthdate as orginal_birthdate,  
make_date(
   1900 + split_part(trim(birthdate), '/', 3):: INT, 
   split_part(trim(birthdate), '/', 2):: INT,
   split_part(trim(birthdate), '/', 1):: INT
) as clean_birthdate
from raw.customer_lookup cl 
order by customer_id 
limit 10;

create table if not exists dw.dim_customer (
   customer_id INTEGER primary key,
   customer_city TEXT,
   customer_state_province TEXT,
   customer_country TEXT,
   birth_date DATE,
   marital_status TEXT,
   yearly_income TEXT,
   gender TEXT,
   total_children INTEGER,
   num_children_at_home INTEGER,
   education TEXT,
   account_open_date DATE,
   member_card TEXT,
   occupation TEXT,
   homeowner TEXT
);
INSERT INTO dw.dim_customer (
    customer_id,
    customer_city,
    customer_state_province,
    customer_country,
    birth_date,
    marital_status,
    yearly_income,
    gender,
    total_children,
    num_children_at_home,
    education,
    account_open_date,
    member_card,
    occupation,
    homeowner
)
select

   customer_id, 
   nullif(trim(customer_city), ''),
   nullif(trim(customer_state_province), ''),
   nullif(trim(customer_country), ''),
   
   case
	   when nullif(trim(birthdate), '') is null
	   then null
	   else make_date(
	       1900 + split_part(trim(birthdate), '/', 3)::INT,  
	       split_part(trim(birthdate), '/', 2)::INT,
	       split_part(trim(birthdate), '/', 1)::INT
	       )
	   end, 
	   
	NULLIF(TRIM(marital_status), ''),
    NULLIF(TRIM(yearly_income), ''),
    NULLIF(TRIM(gender), ''),

    total_children,
    num_children_at_home,

    NULLIF(TRIM(education), ''),

    CASE
        WHEN NULLIF(TRIM(acct_open_date), '') IS NULL
        THEN NULL
        ELSE MAKE_DATE(
            1900 + SPLIT_PART(TRIM(acct_open_date), '/', 3)::INT,
            SPLIT_PART(TRIM(acct_open_date), '/', 2)::INT,
            SPLIT_PART(TRIM(acct_open_date), '/', 1)::INT
        )
    END,

    NULLIF(TRIM(member_card), ''),
    NULLIF(TRIM(occupation), ''),
    NULLIF(TRIM(homeowner), '')

from raw.customer_lookup;

SELECT
    COUNT(*) AS total_customers,
    COUNT(DISTINCT customer_id) AS unique_customers,
    MIN(birth_date) AS earliest_birth,
    MAX(birth_date) AS latest_birth,
    MIN(account_open_date) AS earliest_account_open,
    MAX(account_open_date) AS latest_account_open
FROM dw.dim_customer;
	   
	   
