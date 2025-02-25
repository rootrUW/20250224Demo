--*************************************************************************--
-- Title: Assignment05
-- Author: RRoot
-- Desc: This file demonstrates how to using Joins and Subqueiers
-- Change Log: When,Who,What
-- 2017-01-01,RRoot,Created File
--**************************************************************************--
Use Master;
go

If Exists(Select Name From SysDatabases Where Name = 'Assignment05DB_RRoot')
 Begin 
  Alter Database [Assignment05DB_RRoot] set Single_user With Rollback Immediate;
  Drop Database Assignment05DB_RRoot;
 End
go

Create Database Assignment05DB_RRoot;
go

Use Assignment05DB_RRoot;
go

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
UNION
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNION
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
-- Question 1 (10 pts): How can you show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!
Select 
 C.CategoryName
,P.ProductName
,P.UnitPrice
From Categories as C
 Inner Join Products as P 
  On C.CategoryID = P.CategoryID 
Order By 1,2,3;

-- Question 2 (10 pts): How can you show a list of Product name 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Date, Product,and Count!
Select 
 Products.ProductName
,Inventories.InventoryDate
,Inventories.[Count]
From Products  
 Inner Join Inventories
  On Products.ProductID = Inventories.ProductID 
Order By InventoryDate,ProductName,[Count];

-- Question 3 (10 pts): How can you show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!
Select Distinct
 Inventories.InventoryDate
,Employees.EmployeeFirstName + ' ' + Employees.EmployeeLastName as EmployeeName
From Inventories 
 Inner Join Employees 
  On Inventories.EmployeeID = Employees.EmployeeID 
Order By 1,2;

-- Question 4 (10 pts): How can you show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!
Select 
 Categories.CategoryName
,Products.ProductName
,Inventories.InventoryDate
,Inventories.Count
From Inventories 
 Inner Join Products 
  On Inventories.ProductID = Products.ProductID 
 Inner Join Categories 
  On Products.CategoryID = Categories.CategoryID
Order By 1,2,3,4;

-- Question 5 (20 pts): How can you show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!
Select 
 Categories.CategoryName
,Products.ProductName
,Inventories.InventoryDate
,Inventories.Count
,Employees.EmployeeFirstName + ' ' + Employees.EmployeeLastName as EmployeeName -- Concantenated these columns
From Inventories 
 Inner Join Employees 
  On Inventories.EmployeeID = Employees.EmployeeID 
 Inner Join Products  
  On Inventories.ProductID = Products.ProductID 
 Inner Join Categories 
  On Products.CategoryID = Categories.CategoryID
Order By 3,1,2,4

-- Question 6 (20 pts): How can you show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 
-- Use a Subquery to get the ProductID based On the Product Names 
-- and order the results by the Inventory Date, Category, and Product!
Select 
 Categories.CategoryName
,Products.ProductName
,Inventories.InventoryDate
,Inventories.Count
,Employees.EmployeeFirstName + ' ' + Employees.EmployeeLastName as EmployeeName
From Inventories 
 Inner Join Employees 
  On Inventories.EmployeeID = Employees.EmployeeID 
 Inner Join Products 
  On Inventories.ProductID = Products.ProductID 
 Inner Join Categories 
  On Products.CategoryID = Categories.CategoryID
Where Inventories.ProductID in (Select ProductID From Products Where ProductName In ('Chai', 'Chang'))
Order By 3,1,2,4


-- Question 7 (20 pts): How can you show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!
Select * From Employees

Select ManagerID, EmployeeID, EmployeeFirstName + ' ' + EmployeeLastName as Employee
From Employees

Select ManagerID, EmployeeID, EmployeeFirstName + ' ' + EmployeeLastName as Employee
From Employees as E

Select M.EmployeeID, E.ManagerID, E.EmployeeID,
 M.EmployeeFirstName + ' ' + M.EmployeeLastName as Manager
,E.EmployeeFirstName + ' ' + E.EmployeeLastName as Employee
From Employees as E Inner Join Employees AS M 
 On E.ManagerID = M.EmployeeID
Order By 1,2

/***************************************************************************************/