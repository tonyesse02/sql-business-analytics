# 🧸 ToysGroup — Sales Database Design & SQL Analysis

> Relational database design and SQL querying project for a fictional European toy and sporting goods distributor.

---

## 📌 Project Overview

This project covers the full lifecycle of a relational database, from conceptual design to analytical querying. Starting from a business scenario, a normalized MySQL database was designed, populated with transactional data, and queried to extract business insights on sales performance, product demand, and geographic distribution.

---

## 🗂️ Database Schema

The database `toys_group` consists of **5 tables** connected via foreign key relationships:

| Table | Description |
|---|---|
| `category` | Product categories (Bikes, Clothing, Accessories) |
| `product` | Product catalogue with category reference |
| `salesregion` | European macro-regions (West, South, North Europe) |
| `country` | Countries mapped to sales regions |
| `sales` | Transactional records with product, country, quantity and price |

### Entity-Relationship Overview

```
SALESREGION ──< COUNTRY ──< SALES >── PRODUCT >── CATEGORY
   (1:N)          (1:N)                  (N:1)        (N:1)
```

> Full E-R and EER diagrams are available in the `screenshots/` folder.

---

## 📁 Repository Structure

```
toys-group-sql/
│
├── 📂 queries/
│   └── ToysGroup_task4_queries.sql   # All analytical queries (tasks 4.1–4.9)
│
├── 📂 schema/
│   ├── toys_group_category.sql       # Table: category
│   ├── toys_group_country.sql        # Table: country
│   ├── toys_group_product.sql        # Table: product
│   ├── toys_group_sales.sql          # Table: sales
│   └── toys_group_salesregion.sql    # Table: salesregion
│
├── 📂 screenshots/
│   ├── Diagramma_E_R_drawio_.pdf     # Conceptual E-R diagram
│   └── EER_Diagram_.pdf              # Physical EER diagram (MySQL Workbench)
│
└── 📄 README.md
```

---

## 🔍 Analytical Queries — Summary

All queries are in `queries/ToysGroup_task4_queries.sql`.

| Task | Description | Technique |
|---|---|---|
| 4.1 | Duplicate primary key check across all tables | `GROUP BY` + `HAVING COUNT(*) > 1` |
| 4.2 | Full transaction list with region and 180-day flag | Multi-table `JOIN` + `CASE` + `DATEDIFF` |
| 4.3 | Products exceeding average sales of the latest year | CTE chain (`WITH`) + `AVG` + subquery |
| 4.4 | Revenue by product per year | `SUM(Quantity * UnitPrice)` + `GROUP BY` year |
| 4.5 | Revenue by country per year | `JOIN` + `GROUP BY` country and year |
| 4.6 | Best-selling product category | `JOIN` + `SUM(Quantity)` + `ORDER BY` |
| 4.7 | Unsold products | `LEFT JOIN … WHERE IS NULL` and `NOT IN` subquery |
| 4.8 | View: products with category | `CREATE VIEW vista_prodotti` |
| 4.9 | View: countries with region | `CREATE VIEW vista_geografica` |

---

## 💡 Key Query Highlights

**Task 4.3 — Products above average using CTEs**
```sql
WITH ultimo_anno AS (
  SELECT MAX(YEAR(SalesDate)) AS anno FROM sales
),
vendite_ultimo_anno AS (
  SELECT ProductID, SUM(Quantity) AS quantita_ultimo_anno
  FROM sales
  WHERE YEAR(SalesDate) = (SELECT anno FROM ultimo_anno)
  GROUP BY ProductID
),
media_ultimo_anno AS (
  SELECT AVG(quantita_ultimo_anno) AS media_vendite
  FROM vendite_ultimo_anno
)
SELECT v.ProductID, v.totale_venduto
FROM vendite_totali v
JOIN media_ultimo_anno m
WHERE v.totale_venduto > m.media_vendite
ORDER BY v.totale_venduto DESC;
```

**Task 4.7 — Unsold products (two approaches)**
```sql
-- Approach 1: LEFT JOIN
SELECT p.ProductID, p.ProductName
FROM product p
LEFT JOIN sales s ON s.ProductID = p.ProductID
WHERE s.ProductID IS NULL;

-- Approach 2: NOT IN subquery
SELECT ProductID, ProductName
FROM product
WHERE ProductID NOT IN (SELECT ProductID FROM sales);
```

---

## 🚀 How to Run

### Prerequisites
- MySQL 8.0+
- MySQL Workbench (optional, for visual schema exploration)

### Setup

```sql
-- 1. Run schema files in this order:
SOURCE schema/toys_group_salesregion.sql;
SOURCE schema/toys_group_category.sql;
SOURCE schema/toys_group_country.sql;
SOURCE schema/toys_group_product.sql;
SOURCE schema/toys_group_sales.sql;

-- 2. Run the analytical queries:
SOURCE queries/ToysGroup_task4_queries.sql;
```

> ⚠️ Run `salesregion` and `category` **before** `country` and `product` to respect foreign key constraints.

---

## 🛠️ Tech Stack

![MySQL](https://img.shields.io/badge/MySQL-8.0-blue?logo=mysql)
![MySQL Workbench](https://img.shields.io/badge/MySQL_Workbench-EER_Design-lightblue?logo=mysql)

- **MySQL 8.0** — database engine
- **MySQL Workbench** — schema design and EER diagram generation
- **draw.io** — conceptual E-R diagram

---

## 📄 License

This project is released under the [MIT License](LICENSE) and was developed for academic purposes.
