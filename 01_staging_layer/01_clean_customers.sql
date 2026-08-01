/*
 =========================================
 THE PROBLEMS
 =========================================
 • Messy City Names: The `city` column had bad data. People typed things like "Bombay" instead of "Mumbai", used lowercase letters, or left extra spaces at the end. This makes it impossible to group customers by city.
 • Hidden Text Issues: The `acquisition_channel` column also had mixed capital letters and hidden spaces, which would cause the same channel to show up twice.
 • Blank Money Values: The `cac` (Customer Acquisition Cost) column had missing/blank values (NULLs). If you try to do math with a blank value in SQL, the whole calculation breaks and returns blank, ruining our profit tracking.
 */
--_________________________________________________________________________________________________________________________________________________________________

CREATE
OR REPLACE VIEW clean.clean_customers AS with clean_customer as (
    SELECT
        customer_id,
        join_date,
        upper(trim(acquisition_channel)) as acquisition_channel,
        IFNULL(cac, 0) AS cac,
        upper(trim(city)) as city
    FROM
        raw.customers
)
select
    customer_id,
    join_date,
    acquisition_channel,
    cac,
    case
        WHEN city LIKE '%DELHI%' THEN 'DELHI'
        WHEN city LIKE '%BANGALORE%' THEN 'BENGALURU'
        WHEN city LIKE '%BENGALURU%' THEN 'BENGALURU'
        WHEN city LIKE '%BOMBAY%' THEN 'MUMBAI'
        WHEN city LIKE '%MUMBAI%' THEN 'MUMBAI'
        ELSE city
    END as city
FROM
    clean_customer

--___________________________________________________________________________________________________________________________________________________________________________
/*
 =========================================
 THE SOLUTIONS (CLEANING LAYER)
 =========================================
 • Fixing the Text First: I used `UPPER(TRIM())` on the text columns. Because SQL is strictly case-sensitive, it sees "Delhi" and "DELHI" as completely different words. This step removes extra spaces and makes everything uppercase so matches are perfect.
 • Grouping the Cities: I used a `CASE` statement to catch all the messy spelling variations and old names (like Bombay) and force them into three clean, uniform names: DELHI, BENGALURU, and MUMBAI.
 • Plugging the Math Holes: I used `IFNULL(cac, 0)` to turn missing costs into $0. This ensures that when we calculate total profits later, the math doesn't break due to a blank value.
 */