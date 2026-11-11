WITH annual_sales AS (
    SELECT
        EXTRACT(YEAR FROM transaction_date)::INT
            AS sales_year,
        SUM(sales_amount) AS total_sales
    FROM dw.fact_sales
    GROUP BY 1
),

sales_with_ly AS (
    SELECT
        sales_year,
        total_sales,

        LAG(total_sales) OVER (
            ORDER BY sales_year
        ) AS sales_ly

    FROM annual_sales
)

SELECT
    sales_year,
    total_sales,
    sales_ly,

    ROUND(
        (total_sales - sales_ly)
        / NULLIF(sales_ly, 0) * 100,
        2
    ) AS yoy_growth_pct

FROM sales_with_ly
ORDER BY sales_year;

