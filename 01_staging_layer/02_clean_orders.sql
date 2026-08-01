/*
 =========================================
 THE PROBLEMS
 =========================================
 • Duplicate Order Records (Double-Counting Risk): System retries caused the exact same `order_id` to be loaded multiple times across different batches. If we add up total sales without fixing this, revenue will be fake and double-counted.
 • Blank Financial Values (Null Poisoning): Columns like `gross_sales`, `cogs`, `discount_amount`, and `refund_amount` had missing/blank values (NULLs). Doing math with a blank value in SQL turns the final result into a blank, breaking our profit math.
 */
--_________________________________________________________________________________________________________________________________________________________________

CREATE OR REPLACE VIEW clean.clean_orders AS
WITH clean_orders AS (
    SELECT
        order_id,
        customer_id,
        product_id,
        order_date,
        IFNULL(gross_sales, 0) AS gross_sales,
        IFNULL(cogs, 0) AS cogs,
        IFNULL(discount_amount, 0) AS discount_amount,
        IFNULL(refund_amount, 0) AS refund_amount,
        ingestion_batch,
        loaded_at,
        ROW_NUMBER() OVER(
            PARTITION BY order_id
            ORDER BY
                loaded_at DESC
        ) as row_num
    FROM
        raw.orders
)
SELECT
    order_id,
    customer_id,
    product_id,
    order_date,
    gross_sales,
    cogs,
    discount_amount,
    refund_amount,
    ingestion_batch,
    loaded_at
FROM
    clean_orders
WHERE
    row_num = 1;

--___________________________________________________________________________________________________________________________________________________________________________
/*
 =========================================
 THE SOLUTIONS (CLEANING LAYER)
 =========================================
 • Smart Deduplication: Used a window function (`ROW_NUMBER()`) grouped by `order_id` and sorted by `loaded_at DESC`. This isolates every group of duplicate orders and keeps only row #1 (the newest, most up-to-date record), throwing away the old retry data.
 • Protecting Financial Math: Wrapped all money columns (`gross_sales`, `cogs`, `discount_amount`, `refund_amount`) in `IFNULL(..., 0)`. This turns blank values into $0 so profit calculations run without breaking.
 */