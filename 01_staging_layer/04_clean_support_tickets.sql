/*
 =========================================
 THE PROBLEMS
 =========================================
 • CRM System Glitches (Duplicate Tickets): If the customer service system had a glitch and saved the same `ticket_id` twice, our dashboard would count the refund/resolution cost twice, making our support team look like they are losing more money than they actually are.
 • Blank Costs (Null Poisoning): Many tickets are just simple questions (like "How do I reset my password?") and cost the company nothing, leaving the `resolution_cost` blank (NULL). If we leave it blank, SQL will crash when we try to calculate total costs.
 */
--_________________________________________________________________________________________________________________________________________________________________
CREATE
OR REPLACE VIEW clean.clean_support_tickets AS WITH clean_support_tickets AS (
    SELECT
        ROW_NUMBER() OVER(
            PARTITION BY ticket_id
            ORDER BY
                ticket_date DESC
        ) as row_num,
        ticket_id,
        customer_id,
        order_id,
        ticket_date,
        IFNULL(resolution_cost, 0) AS resolution_cost
    from
        raw.support_tickets
)
SELECT
    ticket_id,
    customer_id,
    order_id,
    ticket_date,
    resolution_cost
FROM
    clean_support_tickets
WHERE
    row_num = 1

--___________________________________________________________________________________________________________________________________________________________________________
/*
 =========================================
 THE SOLUTIONS (CLEANING LAYER)
 =========================================
 • Smart Deduplication: Built a window function (`ROW_NUMBER()`) to group identical `ticket_id`s together, sort them by the newest `ticket_date`, and keep only the latest version, throwing away the system duplicates.
 • Safe Math Formatting: Used `IFNULL(resolution_cost, 0)` to turn all blank costs into $0, ensuring our downstream profit math works perfectly.
 */