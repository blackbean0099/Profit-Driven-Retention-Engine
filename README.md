# 🚀 The Profit-Driven Retention Engine: Finding Hidden Revenue with Data 📊

> 📝 **Note:** This is a portfolio project built with sample e-commerce data. It demonstrates how I use advanced Data Engineering (Google BigQuery) and Business Intelligence (Power BI) to identify and fix real-world revenue leaks.

## 📌 The Big Business Problem
A growing e-commerce company had a dangerous blind spot. Their leadership team was only looking at **Total Sales (Gross Sales)** to measure success. Because of this, they assumed customers who bought a lot of items were their "VIPs".

But the Finance and Customer Service teams suspected a major issue: What if these "VIP" customers were returning half their items and constantly calling customer support? What if the company was actually **losing money** on them? 

Additionally, the Marketing team was blindly guessing when a customer was going to churn (leave forever) using a generic "30-day rule," causing them to miss highly targeted win-back opportunities.

## 💡 My Solution
I built an enterprise-grade **Google BigQuery Data Pipeline** from scratch. I extracted messy, siloed data from 4 different company departments (Sales, Products, Marketing, Support), cleaned it, and engineered a powerful **"Customer 360" Data Mart**. 

Instead of tracking fake "Total Sales," I built a system that tracks the **True Profit** of every single customer. I then connected this engine to a Power BI dashboard to give executives instant, actionable answers.

---

## 🎯 Executive Summary: My 3 Massive Discoveries

### 🚨 Discovery 1 & 2: Exposing "Fake VIPs" & The ₹18.39M Leak
By calculating the *True Profit* (Sales minus product costs, refunds, discounts, marketing, and support tickets), I proved that some of the company's highest-spending customers are actually their biggest liabilities. 

Leadership was overly worried about Customer Support costs (**₹444K**). However, my data proved that **Refunds (₹18.39M)** were the actual fire burning down the company's profits, heavily driven by the `SOCIAL_ADS` acquisition channel. 

👇 **Visual Proof: The Profitability Radar**

![Profitability Radar Dashboard](Assets/Profitability.png)

<br>

### 🎯 Discovery 3: Predicting "Silent Churn"
Instead of guessing when someone churns, I used advanced SQL to calculate every single customer's unique buying rhythm (e.g., Customer A normally buys every 12 days, Customer B every 60 days). 

I identified a massive cohort of users who had quietly missed their personal re-order dates. This provided the Marketing team with an exact, targeted hit-list of people to email *today*.

👇 **Visual Proof: The Silent Churn Radar**

![Customer Churn Dashboard](Assets/Retention.png)

<br>

---

## 🧠 The Tech Stack (How I Built It)
To achieve these business results, I utilized advanced data engineering and analytics techniques:

* ☁️ **Google BigQuery (Advanced SQL):** Handled the heavy lifting in the cloud, utilizing optimized queries to process unstandardized data quickly.
* 🏗️ **One-Big-Table (OBT) Architecture:** Power BI runs incredibly slowly if forced to join 5 messy tables live. I used SQL to perfectly flatten all departmental data into one single, highly optimized table (One Row = One Customer). 
* 🛡️ **Defensive Data Engineering:** I used strict `CTE`s (Common Table Expressions) to aggregate order math and support ticket math *separately* before joining them. This completely prevents the "Fan-Out Trap" (a common database error where SQL accidentally multiplies sales numbers).
* ⏱️ **Window Functions:** I deployed advanced `LAG()` functions to analyze historical purchase dates and calculate the exact number of days between every single order a customer ever placed.
* 🧮 **Safe Math & Null Handling:** I used `COALESCE()` and `IFNULL()` to safely convert missing support costs into ₹0 so the profit math wouldn't crash, and `SAFE_DIVIDE()` to prevent fatal division-by-zero database errors.

---

## 🛠️ The Data Pipeline (Step-by-Step)

### 🧽 Phase 1: The Cleaning Layer (`01_staging_layer`)
Raw data is notoriously messy. People spell cities wrong, CRM systems duplicate tickets, and costs are left blank. 
* **My Execution:** I built 4 automated SQL views to clean the data. I used `UPPER(TRIM())` to fix bad spelling, `ROW_NUMBER()` to delete duplicate system glitches, and implemented strict Data Governance rules to flag missing product costs so the business team could fix them at the source.

### ⚙️ Phase 2: The Analytics Engine (`02_MART`)
You cannot simply `JOIN` a customer's 5 orders to their 3 support tickets—SQL will multiply them into 15 rows and create fake revenue.
* **My Execution:** I built a master SQL script (`mart_customer_360.sql`). I did the heavy profit math safely in isolated blocks, used Window Functions to find buying patterns, and joined everything into one beautiful, unbreakable Data Mart view.

### 📈 Phase 3: Business Intelligence (`Power BI`)
* **My Execution:** I connected my BigQuery Data Mart to Power BI. Using the psychological "F-Pattern" design method, I built a fast, clean, corporate dashboard that delivers the exact answers executives need in 5 seconds or less.

👇 **The Executive Overview**

![Executive Overview Dashboard](Assets/Overview.png)


---

## 📂 Repository Files
* **/Assets**: Dashboard screenshots and diagrams.
* **/01_staging_layer**: The SQL scripts used to clean, format, and fix the raw data.
* **/02_MART**: The heavy Data Engineering SQL script that calculates True Profit and Custom Churn.
* **/dashboard**: The final Power BI `.pbix` file.