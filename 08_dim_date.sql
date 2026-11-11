create table if not exists dw.dim_date (
    calendar_date DATE primary key, 
    year INTEGER,
    quarter INTEGER, 
    month INTEGER, 
    month_name TEXT, 
    year_month TEXT,
    day_of_month INTEGER, 
    day_of_week INTEGER, 
    is_weekend BOOLEAN 
    );
 
INSERT INTO dw.dim_date (
    calendar_date,
    year,
    quarter,
    month,
    month_name,
    year_month,
    day_of_month,
    day_of_week,
    is_weekend
)
select
    d::DATE, 
    extract (year from d)::INT, 
    EXTRACT(QUARTER FROM d)::INT,
    EXTRACT(MONTH FROM d)::INT,
    TO_CHAR(d, 'FMMonth'),
    TO_CHAR(d, 'YYYY-MM'),
    EXTRACT(DAY FROM d)::INT,
    EXTRACT(ISODOW FROM d)::INT,
    EXTRACT(ISODOW FROM d) IN (6, 7)
from generate_series( 
	DATE '1997-01-01',
	DATE '1998-12-31',
	interval '1 day'
) as dates(d)
on conflict (calendar_date) do nothing; 

SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'dw'
  AND table_name = 'dim_date'
ORDER BY ordinal_position;

ALTER TABLE dw.dim_date
RENAME COLUMN calender_date TO calendar_date;

SELECT
    COUNT(*) AS total_dates,
    MIN(calendar_date) AS first_date,
    MAX(calendar_date) AS last_date
FROM dw.dim_date;
