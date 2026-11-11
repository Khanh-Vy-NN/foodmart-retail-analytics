select 
   count(*) as total_transactions,  
   
   count(*) filter ( 
       where p.product_id is null
	) as missing_products,

   count(*) filter ( 
       where c.customer_id is null
   ) as missing_customers,
   
   count(*) FILTER (
        WHERE s.store_id IS NULL
    ) AS missing_stores,

   count(*) FILTER (
        WHERE d.calendar_date IS NULL
    ) AS missing_dates

FROM dw.vw_transactions_clean AS t

left join dw.dim_product as p 
    on t.product_id = p.product_id 
    
left join dw.dim_customer as c 
    on t.customer_id = c.customer_id 
left join dw.dim_store as s 
    on t.store_id = s.store_id 
left join dw.dim_date AS d
    on t.transaction_date = d.calendar_date;


create table if not exists dw.fact_sales (
     sales_id bigint generated always as identity primary key,
     
     transaction_date DATE not null,
     stock_date DATE,
     
     product_id INTEGER not null,
     customer_id INTEGER NOT NULL,
    store_id INTEGER NOT NULL,

    quantity INTEGER NOT NULL,

    unit_price NUMERIC(12,2),
    unit_cost NUMERIC(12,2),

    sales_amount NUMERIC(18,2),
    cogs_amount NUMERIC(18,2),
    gross_profit_amount NUMERIC(18,2),

    CONSTRAINT fk_sales_date
        FOREIGN KEY (transaction_date)
        REFERENCES dw.dim_date(calendar_date),

    CONSTRAINT fk_sales_product
        FOREIGN KEY (product_id)
        REFERENCES dw.dim_product(product_id),

    CONSTRAINT fk_sales_customer
        FOREIGN KEY (customer_id)
        REFERENCES dw.dim_customer(customer_id),

    CONSTRAINT fk_sales_store
        FOREIGN KEY (store_id)
        REFERENCES dw.dim_store(store_id),

    CONSTRAINT chk_sales_quantity
        CHECK (quantity > 0)
);
INSERT INTO dw.fact_sales (
    transaction_date,
    stock_date,
    product_id,
    customer_id,
    store_id,
    quantity,
    unit_price,
    unit_cost,
    sales_amount,
    cogs_amount,
    gross_profit_amount
)
SELECT
    t.transaction_date,
    t.stock_date,
    t.product_id,
    t.customer_id,
    t.store_id,
    t.quantity,

    p.product_retail_price AS unit_price,
    p.product_cost AS unit_cost,

    t.quantity * p.product_retail_price
        AS sales_amount,

    t.quantity * p.product_cost
        AS cogs_amount,

    t.quantity *
        (p.product_retail_price - p.product_cost)
        AS gross_profit_amount

FROM dw.vw_transactions_clean AS t

INNER JOIN dw.dim_product AS p
    ON t.product_id = p.product_id;

SELECT
    COUNT(*) AS total_transactions,
    SUM(quantity) AS total_units,
    SUM(sales_amount) AS total_sales,
    SUM(cogs_amount) AS total_cogs,
    SUM(gross_profit_amount) AS total_profit
FROM dw.fact_sales;

select   
   extract(year from transaction_date)::INT  
      as sales_year, 
      
   count(*) as total_transactions,
   sum(quantity) as units_sold,
   
   sum(sales_amount) as total_sales,
   sum(cogs_amount) as total_cogs, 
   sum(gross_profit_amount) AS gross_profit,

    ROUND(
        SUM(gross_profit_amount)
        / NULLIF(SUM(sales_amount), 0) * 100,
        2
    ) AS gross_margin_pct,

    SUM(
        sales_amount
        - cogs_amount
        - gross_profit_amount
    ) AS reconciliation_diff

FROM dw.fact_sales
GROUP BY sales_year
ORDER BY sales_year;