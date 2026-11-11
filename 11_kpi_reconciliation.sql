with sales_by_year as (
    select 
       extract(year from transaction_date)::INT
         AS sales_year,
        SUM(quantity) AS units_sold,
        SUM(sales_amount) AS total_sales
    FROM dw.fact_sales
    GROUP BY 1
),

returns_by_year AS (
    SELECT
        EXTRACT(YEAR FROM return_date)::INT
            AS return_year,
        SUM(quantity) AS units_returned,
        SUM(return_amount) AS return_value
    FROM dw.fact_returns
    GROUP BY 1
)

SELECT
    s.sales_year,
    s.units_sold,
    COALESCE(r.units_returned, 0)
        AS units_returned,

    ROUND(
        COALESCE(r.units_returned, 0)::NUMERIC
        / NULLIF(s.units_sold, 0) * 100,
        2
    ) AS return_rate_pct,

    s.total_sales,
    COALESCE(r.return_value, 0)
        AS estimated_return_value

FROM sales_by_year AS s
LEFT JOIN returns_by_year AS r
    ON s.sales_year = r.return_year
ORDER BY s.sales_year;
