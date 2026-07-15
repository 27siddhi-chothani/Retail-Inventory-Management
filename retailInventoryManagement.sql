create database inventory;

use inventory;

---- create products table ----
CREATE TABLE Products(
ProductID INT PRIMARY KEY,
ProductName VARCHAR(100),
CategoryID INT,
SupplierID INT,
Price DECIMAL(10,2),
ReorderLevel INT
);

INSERT INTO Products VALUES
(101,'Laptop',1,1,65000,20),
(102,'Wireless Mouse',2,2,800,50),
(103,'Keyboard',2,2,1200,40),
(104,'LED Monitor',1,3,15000,15),
(105,'Office Chair',3,4,5500,25),
(106,'Printer',1,5,12000,10),
(107,'Desk',3,4,7000,15),
(108,'Headphones',2,2,2500,30),
(109,'USB Drive',2,3,900,60),
(110,'Router',1,5,3500,20);

---- create categories table ----
CREATE TABLE Categories(
CategoryID INT PRIMARY KEY,
CategoryName VARCHAR(50)
);

INSERT INTO Categories VALUES
(1,'Electronics'),
(2,'Accessories'),
(3,'Furniture');

---- create suppliers table ----
CREATE TABLE Suppliers(
SupplierID INT PRIMARY KEY,
SupplierName VARCHAR(100),
City VARCHAR(50)
);

INSERT INTO Suppliers VALUES
(1,'Dell India','Bangalore'),
(2,'Logitech','Mumbai'),
(3,'Samsung','Delhi'),
(4,'Godrej','Pune'),
(5,'HP India','Chennai');

---- create warehouse table ----
CREATE TABLE Warehouses(
WarehouseID INT PRIMARY KEY,
WarehouseName VARCHAR(50),
Location VARCHAR(50)
);

INSERT INTO Warehouses VALUES
(1,'North Warehouse','Delhi'),
(2,'South Warehouse','Chennai'),
(3,'West Warehouse','Mumbai'),
(4,'Central Warehouse','Nagpur');

---- create inventory table ----
CREATE TABLE Inventory(
InventoryID INT PRIMARY KEY,
ProductID INT,
WarehouseID INT,
StockAvailable INT,
LastRestocked DATE
);

INSERT INTO Inventory VALUES
(1,101,1,18,'2025-06-01'),
(2,102,3,120,'2025-06-05'),
(3,103,2,35,'2025-06-10'),
(4,104,1,8,'2025-06-02'),
(5,105,4,40,'2025-06-08'),
(6,106,2,12,'2025-06-12'),
(7,107,4,10,'2025-06-11'),
(8,108,3,70,'2025-06-09'),
(9,109,1,150,'2025-06-13'),
(10,110,2,5,'2025-06-14');

---- create sales table ----
CREATE TABLE Sales(
SaleID INT PRIMARY KEY,
ProductID INT,
QuantitySold INT,
SaleDate DATE
);

INSERT INTO Sales VALUES
(1,101,15,'2025-06-15'),
(2,102,80,'2025-06-15'),
(3,103,30,'2025-06-16'),
(4,104,7,'2025-06-16'),
(5,105,12,'2025-06-17'),
(6,106,6,'2025-06-17'),
(7,107,5,'2025-06-18'),
(8,108,40,'2025-06-18'),
(9,109,100,'2025-06-19'),
(10,110,4,'2025-06-20');

---- QUERIES ----

-- display all products
SELECT * FROM Products;

-- current stock availability
SELECT
P.ProductName,
StockAvailable
FROM Inventory I
JOIN Products P
ON I.ProductID=P.ProductID;

-- products below reorder level
SELECT
P.ProductName,
StockAvailable
FROM Inventory I
JOIN Products P
ON I.ProductID=P.ProductID;

-- total inventory value
SELECT
SUM(StockAvailable*Price) AS InventoryValue
FROM Products P
JOIN Inventory I
ON P.ProductID=I.ProductID;

-- inventory turnover
SELECT
P.ProductName,
QuantitySold,
StockAvailable,
ROUND(
QuantitySold*100.0/StockAvailable,2)
AS TurnoverPercentage
FROM Products P
JOIN Sales S
ON P.ProductID=S.ProductID
JOIN Inventory I
ON P.ProductID=I.ProductID;

-- top selling products
SELECT
ProductName,
QuantitySold
FROM Products P
JOIN Sales S
ON P.ProductID=S.ProductID
ORDER BY QuantitySold DESC;

-- slow moving products
SELECT
ProductName,
QuantitySold
FROM Products P
JOIN Sales S
ON P.ProductID=S.ProductID
WHERE QuantitySold<10;

-- category wise inventory
SELECT
CategoryName,
SUM(StockAvailable)
FROM Products P
JOIN Categories C
ON P.CategoryID=C.CategoryID
JOIN Inventory I
ON P.ProductID=I.ProductID
GROUP BY CategoryName;

-- supplier performance
SELECT
SupplierName,
COUNT(ProductID) TotalProducts
FROM Products P
JOIN Suppliers S
ON P.SupplierID=S.SupplierID
GROUP BY SupplierName
ORDER BY TotalProducts DESC;

-- stock out analysis 
SELECT
ProductName,
StockAvailable
FROM Products P
JOIN Inventory I
ON P.ProductID=I.ProductID
WHERE StockAvailable<10;

-- warehouse wise stock
SELECT
WarehouseName,
SUM(StockAvailable)
FROM Inventory I
JOIN Warehouses W
ON I.WarehouseID=W.WarehouseID
GROUP BY WarehouseName;

-- products never solds
SELECT ProductName
FROM Products
WHERE ProductID NOT IN
(
SELECT ProductID
FROM Sales
);

-- avg products price
SELECT
AVG(Price)
FROM Products;

-- highest inventory product
SELECT top 1
ProductName,
StockAvailable
FROM Products P
JOIN Inventory I
ON P.ProductID=I.ProductID
ORDER BY StockAvailable DESC;

-- most expensive product
SELECT top 1
ProductName,
Price
FROM Products
ORDER BY Price DESC;

-- supplier wise inventory value
SELECT
SupplierName,
SUM(Price*StockAvailable) InventoryValue
FROM Products P
JOIN Suppliers S
ON P.SupplierID=S.SupplierID
JOIN Inventory I
ON P.ProductID=I.ProductID
GROUP BY SupplierName;

-- running inventory value
SELECT
ProductName,
Price,
SUM(Price)
OVER(ORDER BY Price DESC)
AS RunningValue
FROM Products;

-- rank products by sales
SELECT
ProductName,
QuantitySold,
RANK()
OVER(ORDER BY QuantitySold DESC)
AS SalesRank
FROM Products P
JOIN Sales S
ON P.ProductID=S.ProductID;

-- dense rank by stock
SELECT
ProductName,
StockAvailable,
DENSE_RANK()
OVER(ORDER BY StockAvailable DESC)
AS StockRank
FROM Products P
JOIN Inventory I
ON P.ProductID=I.ProductID;

-- products above avg sales
SELECT
ProductName,
QuantitySold
FROM Products P
JOIN Sales S
ON P.ProductID=S.ProductID
WHERE QuantitySold>
(
SELECT AVG(QuantitySold)
FROM Sales
);