<h1 align="center">🅿️ Parking Management System</h1>

<p align="center">
  <b>Comprehensive SQL Database for Managing Parking Lots, Vehicles, and Payments</b><br>
  <sub>Designed for efficiency, analytics, and real-world simulation.</sub>
</p>

---

## 🌐 Overview

The **Parking Management System** is a full-featured SQL project built to manage parking operations —  
including vehicle entry and exit tracking, customer data, payments, and lot availability.  
It demonstrates advanced database logic, query design, and data analysis.

---

## 🧩 Database Structure

| Table | Description |
|--------|-------------|
| 🏢 **ParkingLot** | Contains information about each parking lot (name, location, capacity) |
| 🚗 **ParkingSpot** | Represents individual parking spots and their status |
| 👤 **Customer** | Stores customer details (regular or occasional users) |
| 🚘 **Vehicle** | Links each vehicle to its owner |
| ⏱️ **ParkingSession** | Logs each parking event: entry time, exit time, duration |
| 💳 **Payment** | Records completed payments and amounts due |

---

## ⚙️ Features & Capabilities

- 🔗 **Relational Structure** with primary & foreign keys  
- 🧮 **Analytical Queries** using `GROUP BY`, `CASE`, and window functions  
- 🧠 **Advanced SQL Logic** — `VIEWS`, `JOINS`, subqueries, and set operations (`UNION`, `INTERSECT`, `EXCEPT`)  
- 🔁 **Cursors** for automating calculations (e.g. fees or occupancy updates)  
- 💾 **DML Operations** – seamless `INSERT`, `UPDATE`, `DELETE` flows  
- 📊 **Dynamic Reports** – revenue summaries, occupancy stats, top customers  

---

## 📈 Example Views & Reports

```sql
-- Total income per parking lot
CREATE VIEW v_LotRevenue AS
SELECT pl.LotName,
       SUM(p.Amount) AS TotalRevenue
FROM ParkingLot pl
JOIN ParkingSession s ON s.LotID = pl.LotID
JOIN Payment p ON p.SessionID = s.SessionID
GROUP BY pl.LotName;
