--  OLTP -> staging

USE [ChinookStaging]
GO

truncate table [ChinookStaging].[dbo].[Customers];

insert into Customers(CustomerID, CustomerFirstName, CustomerLastName, CustomerCompany, CustomerCountry, CustomerState, CustomerCity, CustomerPostalCode, EmployeeFirstName, EmployeeLastName)
select c.CustomerID, c.FirstName, c.LastName, Company, c.Country, c.State, c.City, c.PostalCode, e.FirstName, e.LastName
FROM Chinook.[dbo].Customer c
JOIN Chinook.[dbo].Employee e
ON c.SupportRepId = e.EmployeeId

-----------------------------------------------------------
truncate table [ChinookStaging].[dbo].Sales;

insert into Sales(TrackId, CustomerId, InvoiceDate, InvoiceId, UnitPrice)
select TrackId, CustomerId, InvoiceDate, i.InvoiceId, UnitPrice
from Chinook.[dbo].Invoice i
join Chinook.[dbo].[InvoiceLine] il
on i.InvoiceID = il.InvoiceID
where InvoiceDate >= '2013-12-23';
--------------------------------------------------------
 
--  Staging ->DW

drop table if exists [ChinookStaging].[dbo].Staging_DimCustomers;

create table [ChinookStaging].[dbo].Staging_DimCustomers(
	CustomerKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    CustomerId INT NOT NULL,
	CustomerName NVARCHAR(60) NOT NULL,
	CustomerCompany NVARCHAR(80) NULL,
	CustomerCountry NVARCHAR(40) NULL,
	CustomerState NVARCHAR(40) NULL,
	CustomerCity NVARCHAR(40) NULL,
	CustomerPostalCode NVARCHAR(10) NULL,
	EmployeeName NVARCHAR(40) NOT NULL,
	RowIsCurrent INT DEFAULT 1 NOT NULL,
    RowStartDate DATE DEFAULT '1899-12-31' NOT NULL,
    RowEndDate DATE DEFAULT '9999-12-31' NOT NULL,
    RowChangeReason VARCHAR(200) NULL
);

------------------------------
Insert into [ChinookStaging].[dbo].Staging_DimCustomers(
	CustomerId,
	CustomerName,
	CustomerCompany,
	CustomerCountry,
	CustomerState,
	CustomerCity,
	CustomerPostalCode,
	EmployeeName
)
(
SELECT
	CustomerID,
	[CustomerFirstName] + ' ' + [CustomerLastName],
	ISNULL([CustomerCompany],'N/A'),
	CustomerCountry,
	ISNULL(CustomerState,'n/a'),
	CustomerCity,
	COALESCE(CustomerPostalCode,'n/a'),
	[EmployeeFirstName] + ' ' + [EmployeeLastName]
from [ChinookStaging].[dbo].[Customers]
);

 -------------------------------------------------


--  Drop the constraints to continue to next step
--  Insert, Delete, Update dimensions in DimCustomers

declare @etldate date = '2013-12-23';

INSERT INTO ChinookDW.[dbo].DimCustomers(
	CustomerId,
	CustomerName,
	CustomerCompany,
	CustomerCountry,
	CustomerState,
	CustomerCity,
	CustomerPostalCode,
	EmployeeName,
	RowStartDate,
	RowChangeReason
)
SELECT 
	CustomerId,
	CustomerName,
	CustomerCompany,
	CustomerCountry,
	CustomerState,
	CustomerCity,
	CustomerPostalCode,
	EmployeeName,
	@etldate,
	ActionName
FROM
(
	MERGE ChinookDW.[dbo].DimCustomers AS target
		USING [ChinookStaging].[dbo].Staging_DimCustomers as source
		ON target.[CustomerID] = source.[CustomerID]
	 WHEN MATCHED 	 AND 
	 source.CustomerCity <> target.CustomerCity  
	 AND target.[RowIsCurrent] = 1 
	 THEN UPDATE SET
		 target.RowIsCurrent = 0,
		 target.RowEndDate = dateadd(day, -1, @etldate ) ,
		 target.RowChangeReason = 'UPDATED NOT CURRENT'
	 WHEN NOT MATCHED THEN
	   INSERT  (	CustomerId,
					CustomerName,
					CustomerCompany,
					CustomerCountry,
					CustomerState,
					CustomerCity,
					CustomerPostalCode,
					EmployeeName,
					RowStartDate,
					RowChangeReason
	   )
	   VALUES( 
			source.CustomerID,
			source.CustomerName,
			source.CustomerCompany,
			source.CustomerCountry,
			source.CustomerState,
			source.CustomerCity,
			source.CustomerPostalCode,
			source.EmployeeName,
			CAST(@etldate AS Date),
		   'NEW RECORD'
	   )
	WHEN NOT MATCHED BY Source THEN
		UPDATE SET 
			Target.RowEndDate= dateadd(day, -1, @etldate )
			,target.RowIsCurrent = 0
			,Target.RowChangeReason  = 'SOFT DELETE'
	OUTPUT 
			source.CustomerID,
			source.CustomerName,
			source.CustomerCompany,
			source.CustomerCountry,
			source.CustomerState,
			source.CustomerCity,
			source.CustomerPostalCode,
			source.EmployeeName,
			$Action as ActionName   
) AS Mrg
WHERE Mrg.ActionName='UPDATE'
AND [CustomerID] IS NOT NULL;


------------------------------------------------
--  Insert new facts into FactSales

INSERT INTO [ChinookDW].[dbo].FactSales(
	TrackKey,
	CustomerKey,
	InvoiceDateKey,
	InvoiceId,
	TrackPrice
)
SELECT 
	t.TrackKey,
	c.CustomerKey,
	CAST(FORMAT(InvoiceDate,'yyyyMMdd') AS INT),
	InvoiceId,
	UnitPrice
FROM 
	ChinookStaging.dbo.Sales s
JOIN ChinookDW.dbo.DimCustomers c
    ON c.CustomerId=s.CustomerId and c.RowIsCurrent=1
JOIN ChinookDW.dbo.DimTracks t 
    ON t.TrackId=s.TrackId and c.RowIsCurrent=1

--  Check the results
USE [ChinookStaging]
GO
select * from Customers
select * from Sales

USE [ChinookDW]
GO
select * from [dbo].DimCustomers
select * from [dbo].FactSales