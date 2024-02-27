--*************************************************************************--
-- Title: Assignment06
-- Author: Bovetz
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-01-01,Bovetz,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_Bovetz')
	 Begin 
	  Alter Database [Assignment06DB_Bovetz] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_Bovetz;
	 End
	Create Database Assignment06DB_Bovetz;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_Bovetz;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- 1
GO
-- View for Categories
CREATE VIEW dbo.vCategories WITH SCHEMABINDING AS
SELECT CategoryID, CategoryName
FROM dbo.Categories;
GO
-- View for Products
CREATE VIEW dbo.vProducts WITH SCHEMABINDING AS
SELECT ProductID, ProductName, CategoryID, UnitPrice
FROM dbo.Products;
GO
-- View for Employees
CREATE VIEW dbo.vEmployees WITH SCHEMABINDING AS
SELECT EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
FROM dbo.Employees;
GO
-- View for Inventories
CREATE VIEW dbo.vInventories WITH SCHEMABINDING AS
SELECT InventoryID, InventoryDate, EmployeeID, ProductID, [Count]
FROM dbo.Inventories;
GO


-- 2

-- Revoke
DENY SELECT ON Categories TO PUBLIC;
DENY SELECT ON Products TO PUBLIC;
DENY SELECT ON Employees TO PUBLIC;
DENY SELECT ON Inventories TO PUBLIC;

-- Grant
GRANT SELECT ON dbo.vCategories TO PUBLIC;
GRANT SELECT ON dbo.vProducts TO PUBLIC;
GRANT SELECT ON dbo.vEmployees TO PUBLIC;
GRANT SELECT ON dbo.vInventories TO PUBLIC;
GO

-- 3
CREATE VIEW vProductsByCategories
AS
SELECT TOP 10000000
C.CategoryName,
P.ProductName,
P.UnitPrice
FROM vCategories as C inner join vProducts as P on C.CategoryID = P.CategoryID Order By 1,2,3;
GO

-- 4
CREATE VIEW vInventoriesByProductsByDates AS
SELECT Top 10000000
p.ProductName,
i.InventoryDate,
i.[Count]
FROM vProducts AS P
INNER JOIN vInventories AS I ON p.ProductID; = i.ProductID
ORDER BY 2,1,3;
GO

-- 5
CREATE VIEW vInventoriesByEmployeesByDates AS
SELECT DISTINCT TOP 10000000 i.InventoryDate, e.EmployeeFirstName + ' ' + e.EmployeeLastName AS EmployeeName
FROM VInventories AS i
INNER JOIN vEmployees AS e ON i.EmployeeID = e.EmployeeID;
ORDER BY 1,2;
GO

-- 6
CREATE VIEW vInventoriesByProductsByCategories AS
SELECT TOP 10000000 c.CategoryName, p.ProductName, i.InventoryDate, i.[Count]
FROM dbo.Inventories AS i
INNER JOIN vEmployees AS E ON i.EmployeeID = e.EmployeeID
INNER JOIN vProducts AS P ON i.ProductID = p.ProductID
INNER JOIN vCategories AS c ON p.CategoryID = c.CategoryID;
ORDER BY 1,2,3,4;
GO

-- 7
CREATE VIEW vInventoriesByProductsByEmployees AS
SELECT TOP 10000000 c.CategoryName, p.ProductName, i.InventoryDate, i.[Count], e.EmployeeFirstName + ' ' + e.EmployeeLastName AS EmployeeName
FROM dbo.Inventories AS i
INNER JOIN vProducts AS p ON i.ProductID = p.ProductID
INNER JOIN vCategories AS c ON p.CategoryID = c.CategoryID
INNER JOIN vEmployees AS e ON i.EmployeeID = e.EmployeeID;
ORDER By 3,1,2,4
GO

-- 8
CREATE VIEW vInventoriesForChaiAndChangByEmployees AS
SELECT TOP 10000000 c.CategoryName, p.ProductName, i.InventoryDate, i.[Count], e.EmployeeFirstName + ' ' + e.EmployeeLastName AS EmployeeName
FROM vInventories AS i
INNER JOIN vProducts AS p ON i.ProductID = p.ProductID
INNER JOIN vCategories AS c ON p.CategoryID = c.CategoryID
INNER JOIN vEmployees AS e ON i.EmployeeID = e.EmployeeID
WHERE i.productID IN ('Chai', 'Chang');
ORDER By 3,1,2,4
GO

-- 9
CREATE VIEW vEmployeesByManager AS
SELECT TOP 10000000 e.EmployeeFirstName + ' ' + e.EmployeeLastName AS EmployeeName, m.EmployeeFirstName + ' ' + m.EmployeeLastName AS ManagerName
FROM vEmployees AS e
INNER JOIN vEmployees AS m ON e.ManagerID = m.EmployeeID;
ORDER BY 1,2
GO

-- 10
CREATE VIEW vInventoriesByProductsByCategoriesByEmployees AS
SELECT TOP 10000000 c.CategoryName, p.ProductName, i.InventoryID, i.InventoryDate, i.[Count], e.EmployeeFirstName + ' ' + e.EmployeeLastName AS EmployeeName, m.EmployeeFirstName + ' ' + m.EmployeeLastName AS ManagerName
FROM vCategories AS C
INNER JOIN vProducts AS p ON i.ProductID = p.ProductID
INNER JOIN vCategories AS c ON p.CategoryID = c.CategoryID
INNER JOIN vEmployees AS e ON i.EmployeeID = e.EmployeeID
INNER JOIN vEmployees AS m ON e.ManagerID = m.EmployeeID;
ORDER BY 1,3,6,9
GO


-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/