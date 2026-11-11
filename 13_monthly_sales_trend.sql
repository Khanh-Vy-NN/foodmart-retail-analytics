SELECT
    TO_CHAR(transaction_date, 'YYYY-MM') AS sales_month,
    COUNT(*) AS transactions,
    SUM(quantity) AS units_sold,
    SUM(sales_amount) AS monthly_sales
FROM dw.fact_sales
GROUP BY 1
ORDER BY 1;

