SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'raw'
  AND table_name = 'foodmart_returns'
ORDER BY ordinal_position;

SELECT *
FROM raw.foodmart_returns
LIMIT 10;

SELECT COUNT(*) AS total_returns
FROM raw.foodmart_returns;

TRUNCATE TABLE raw.foodmart_returns;

SELECT
    return_date,
    product_id,
    store_id,
    quantity
FROM raw.foodmart_returns
LIMIT 10;

SELECT
    COUNT(*) AS total_returns,

    COUNT(*) FILTER (
        WHERE return_date IS NULL
           OR TRIM(return_date) = ''
    ) AS missing_dates,

    COUNT(*) FILTER (
        WHERE quantity IS NULL OR quantity <= 0
    ) AS invalid_quantity,

    COUNT(*) FILTER (
        WHERE TRIM(return_date) !~
        '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{2}$'
    ) AS invalid_date_formats

FROM raw.foodmart_returns;

CREATE TABLE dw.fact_returns (
    return_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    return_date DATE NOT NULL,
    product_id INTEGER NOT NULL,
    store_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL,

    unit_price NUMERIC(12,2),
    return_amount NUMERIC(18,2),

    CONSTRAINT fk_returns_date
        FOREIGN KEY (return_date)
        REFERENCES dw.dim_date(calendar_date),

    CONSTRAINT fk_returns_product
        FOREIGN KEY (product_id)
        REFERENCES dw.dim_product(product_id),

    CONSTRAINT fk_returns_store
        FOREIGN KEY (store_id)
        REFERENCES dw.dim_store(store_id),

    CONSTRAINT chk_returns_quantity
        CHECK (quantity > 0)
);
INSERT INTO dw.fact_returns (
    return_date,
    product_id,
    store_id,
    quantity,
    unit_price,
    return_amount
)
SELECT
    MAKE_DATE(
        1900 + SPLIT_PART(TRIM(r.return_date), '/', 3)::INT,
        SPLIT_PART(TRIM(r.return_date), '/', 2)::INT,
        SPLIT_PART(TRIM(r.return_date), '/', 1)::INT
    ) AS return_date,

    r.product_id,
    r.store_id,
    r.quantity,

    p.product_retail_price AS unit_price,

    r.quantity * p.product_retail_price
        AS return_amount

FROM raw.foodmart_returns AS r

LEFT JOIN dw.dim_product AS p
    ON r.product_id = p.product_id;

SELECT
    COUNT(*) AS total_returns,
    SUM(quantity) AS units_returned,
    SUM(return_amount) AS total_return_amount,

    MIN(return_date) AS earliest_return,
    MAX(return_date) AS latest_return,

    COUNT(*) FILTER (
        WHERE return_amount IS NULL
    ) AS missing_return_amount

FROM dw.fact_returns;