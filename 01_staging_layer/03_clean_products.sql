/*
 =========================================
 THE PROBLEMS
 =========================================
 • Messy Categories: The `category` column could have hidden spaces or mixed capital letters, which would cause one product category (like "Electronics") to split into multiple separate groups.
 • Missing Master Costs: The `base_price` and `cogs_pct` (cost to make the product) columns might contain blank values (NULLs). Because this is a master product catalog, a missing cost does NOT mean the product is free to make—it means the data entry team forgot to type it in.
 */
--_________________________________________________________________________________________________________________________________________________________________

CREATE OR REPLACE VIEW clean.clean_products AS
SELECT
    product_id,
    upper(trim(category)) as category,
    base_price,
    cogs_pct
FROM raw.products

--___________________________________________________________________________________________________________________________________________________________________________
/*
 =========================================
 THE SOLUTIONS (CLEANING LAYER)
 =========================================
 • Text Standardization: Used `UPPER(TRIM(category))` to remove hidden spaces and make all text uppercase so product groupings are perfect.
 • The "Fail Loudly" Rule (Data Governance): Intentionally chose NOT to replace missing `base_price` or `cogs_pct` values with 0. If we force a 0, the dashboard will silently calculate a fake 100% profit margin, misleading the business. By leaving them blank (NULL), the dashboard will show an obvious error, forcing the business team to fix their source data. 
 */