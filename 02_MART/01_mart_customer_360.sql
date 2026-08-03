/*
 =========================================
 THE PROBLEMS (Why we built this view)
 =========================================
 • Scattered Data: Customer details, order history, product costs, and support tickets are stored in completely different tables. If we force Power BI to connect all of these raw tables live, the dashboard will run incredibly slowly.
 • The Multiplier Trap (Fan-Out): If a customer has 5 orders and 3 support tickets, joining all the tables together the wrong way will make the database spit out 15 rows (5 x 3) for that one person. This accidentally multiplies their sales, creating fake revenue numbers.
 • Fake Profit Metrics: Just looking at "Total Sales" is a lie. If we don't subtract how much it cost to make the product, the marketing money spent to get the customer, and the cost of answering their support tickets, we don't know if we actually made money.
 • Flawed Churn Guesses: Most companies just guess that if a person hasn't bought anything in 30 days, they are gone. But if a specific customer only buys a product every 60 days, they aren't gone at all. We need to know everyone's personal buying rhythm.
 */
--_________________________________________________________________________________________________________________________________________________________________
CREATE
OR REPLACE VIEW mart.mart_customer_360 AS WITH order_sequence AS (
    SELECT
        o.customer_id,
        o.order_id,
        o.product_id,
        o.order_date,
        o.gross_sales,
        o.cogs,
        o.discount_amount,
        o.refund_amount,
        p.base_price,
        p.cogs_pct,
        DATE_DIFF(
            o.order_date,
            LAG(o.order_date) OVER (
                PARTITION BY o.customer_id
                ORDER BY
                    o.order_date,
                    o.order_id
            ),
            DAY
        ) AS days_since_prev_order
    FROM
        clean.clean_orders AS o
        LEFT JOIN clean.clean_products AS p ON o.product_id = p.product_id
),
customer_order AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS total_orders,
        COUNT(DISTINCT product_id) AS distinct_products,
        SUM(gross_sales) AS gross_sales,
        SUM(cogs) AS cogs,
        SUM(discount_amount) AS discount_amount,
        SUM(refund_amount) AS refund_amount,
        SUM(gross_sales) - SUM(discount_amount) - SUM(refund_amount) AS net_sales,
        SUM(gross_sales) - SUM(discount_amount) - SUM(refund_amount) - SUM(cogs) AS gross_profit,
        AVG(gross_sales) AS avg_order_value,
        AVG(cogs) AS avg_cogs_per_order,
        AVG(discount_amount) AS avg_discount_per_order,
        AVG(refund_amount) AS avg_refund_per_order,
        SAFE_DIVIDE(SUM(discount_amount), SUM(gross_sales)) * 100 AS discount_rate_pct,
        SAFE_DIVIDE(SUM(refund_amount), SUM(gross_sales)) * 100 AS refund_rate_pct,
        SAFE_DIVIDE(
            SUM(gross_sales) - SUM(discount_amount) - SUM(refund_amount) - SUM(cogs),
            SUM(gross_sales)
        ) * 100 AS gross_margin_pct,
        AVG(base_price) AS avg_base_price,
        AVG(cogs_pct) AS avg_cogs_pct,
        MIN(order_date) AS first_order_date,
        MAX(order_date) AS last_order_date,
        AVG(days_since_prev_order) AS avg_days_between_orders,
        STDDEV_SAMP(days_since_prev_order) AS stddev_days_between_orders,
        DATE_DIFF(MAX(order_date), MIN(order_date), DAY) AS active_days,
        
        -- UPDATED: Hardcoded to April 30, 2024 to perfectly match the dataset's actual timeline
        DATE_DIFF(DATE('2024-04-30'), DATE(MAX(order_date)), DAY) AS days_since_last_order
        
    FROM
        order_sequence
    GROUP BY
        customer_id
),
support_agg AS (
    SELECT
        st.customer_id,
        COUNT(DISTINCT st.ticket_id) AS support_ticket_count,
        SUM(st.resolution_cost) AS total_resolution_cost,
        AVG(st.resolution_cost) AS avg_resolution_cost
    FROM
        clean.clean_support_tickets AS st
    GROUP BY
        st.customer_id
)
SELECT
    c.customer_id,
    c.join_date,
    c.acquisition_channel,
    c.cac,
    c.city,
    co.total_orders,
    co.distinct_products,
    round(co.gross_sales, 2) AS gross_sales,
    round(co.cogs, 2) AS cogs,
    round(co.discount_amount, 2) AS discount_amount,
    round(co.refund_amount, 2) AS refund_amount,
    round(co.net_sales, 2) AS net_sales,
    round(co.gross_profit, 2) AS gross_profit,
    round(co.avg_order_value, 2) AS avg_order_value,
    round(co.avg_cogs_per_order, 2) AS avg_cogs_per_order,
    round(co.avg_discount_per_order, 2) AS avg_discount_per_order,
    round(co.avg_refund_per_order, 2) AS avg_refund_per_order,
    round(co.discount_rate_pct, 2) AS discount_rate_pct,
    round(co.refund_rate_pct, 2) AS refund_rate_pct,
    round(co.gross_margin_pct, 2) AS gross_margin_pct,
    round(co.avg_base_price, 2) AS avg_base_price,
    round(co.avg_cogs_pct, 2) AS avg_cogs_pct,
    co.first_order_date,
    co.last_order_date,
    round(co.avg_days_between_orders, 2) AS avg_days_between_orders,
    round(co.stddev_days_between_orders, 2) AS stddev_days_between_orders,
    co.active_days,
    co.days_since_last_order,
    sa.support_ticket_count,
    sa.total_resolution_cost,
    sa.avg_resolution_cost,
    round(
        co.gross_profit - COALESCE(c.cac, 0) - COALESCE(sa.total_resolution_cost, 0),
        2
    ) AS rounded_true_net_margin
FROM
    clean.clean_customers AS c
    LEFT JOIN customer_order AS co ON c.customer_id = co.customer_id
    LEFT JOIN support_agg AS sa ON c.customer_id = sa.customer_id;
--___________________________________________________________________________________________________________________________________________________________________________
/*
 =========================================
 THE SOLUTIONS (The Analytics Engine)
 =========================================
 • The "One Big Table" Approach: We fixed the scattered data problem by doing all the heavy math right here in SQL. This script flattens everything into exactly one row per customer, so the dashboard just has to read one simple, wide table.
 • Safe Math (No Multipliers): We used separate temporary blocks (CTEs) to calculate the order totals and the support ticket totals completely separate from each other. We only joined them together at the very end, which guarantees our sales numbers never accidentally multiply.
 • True Net Margin: We calculated the exact dollars put in the bank by taking the total sales and subtracting the product costs (COGS), discounts, refunds, marketing costs (CAC), and customer service costs. 
 • Smart Churn Tracking: We used a window function (LAG) to calculate the exact number of days between every single order a customer placed. This let us calculate their true average buying rhythm and see exactly how many days it has been since their last purchase.
 • The Blank Space Fix: We used `COALESCE` on the support costs. If a customer never submitted a support ticket, the database leaves that cost blank. We forced it to say $0 so our profit math wouldn't crash.
 */