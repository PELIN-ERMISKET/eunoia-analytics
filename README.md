## EUNOIA Retail Analytics (Power BI)

This project demonstrates an end-to-end **retail analytics solution** using  
**PostgreSQL + Power BI**, built on a fictional cosmetics brand called **EUNOIA**.

> ⚠️ All data is synthetic and created for portfolio & learning purposes only.

---

## 📊 Project Overview

The dashboard focuses on:
- Sales performance analysis
- Brand target vs actual revenue comparison
- Store & geography insights
- Product & category trends
- Year-over-year (2023 vs 2024) performance

---

## 🧱 Tech Stack

- **Database:** PostgreSQL  
- **BI Tool:** Power BI Desktop  
- **Modeling:** Star-schema (orders, order_items, products, brands, stores)
- **KPIs:** Revenue, Orders, Average Basket, Target Achievement %

<h2>📁 Repository Structure</h2>

<pre>
EUNOIA-Analytics/
├─ powerbi/
│  └─ EUNOIA_POWERBI.pbix
├─ sql/
│  └─ eunoia_database.sql
├─ screenshots/
│  ├─ overview.png
│  ├─ sales.png
│  ├─ stores.png
│  └─ products.png
└─ README.md
</pre>



## 📸 Dashboard Pages

### 🔹 Overview
- Total Revenue
- Total Orders
- Average Basket
- Target Achievement (%)

### 🔹 Sales Performance
- Monthly completed / returned orders
- YoY comparison (2023 vs 2024)

### 🔹 Stores & Geography
- Store performance
- Online vs Physical channels

### 🔹 Products & Brands
- Brand revenue contribution
- Category & product mix
- Vegan & Sun Care trends

---

## 🎯 Target vs Actual Logic

- Targets defined per **brand & year**
- Actual revenue calculated from **completed orders**
- Achievement % = Actual / Target
- Variance analysis included

---

## ▶️ How to Use

1. Run `sql/eunoia_database.sql` in PostgreSQL
2. Open `powerbi/EUNOIA_POWERBI.pbix` in Power BI Desktop
3. Refresh data source connection
4. Explore dashboards & visuals

---

## 📌 Notes

- Power BI `.pbix` file is included for download
- Dataset size is optimized for portfolio use
- Model supports slicers by **year, month, brand, store**
