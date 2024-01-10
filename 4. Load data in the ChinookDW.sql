USE ChinookDW

-- Only for the first load
DELETE FROM FactSales;
DELETE FROM DimCustomers;
DELETE FROM DimTracks;

--1.  Insert data into Dimension table DimCustomers
INSERT INTO DimCustomers(
	CustomerId,
	CustomerName,
	CustomerCompany,
	CustomerCountry,
	CustomerState,
	CustomerCity,
	CustomerPostalCode,
	EmployeeName
)
SELECT
	CustomerID,
	[CustomerFirstName] + ' ' + [CustomerLastName],
	CustomerCompany,
	CustomerCountry,
	CustomerState,
	CustomerCity,
	COALESCE(CustomerPostalCode,'n/a'),
	[EmployeeFirstName] + ' ' + [EmployeeLastName]
FROM ChinookStaging.dbo.Customers

--2.  Insert data into Dimension table DimTracks
INSERT INTO DimTracks(
	TrackId,
	TrackName,
	TrackComposer,
	TrackLength, -- currently in milliseconds
	AlbumTitle,
	ArtistName,
	GenreName
)
SELECT
	TrackId,
	TrackName,
	TrackComposer,
	TrackMilliSec,
	AlbumTitle,
	ArtistName,
	GenreName
FROM ChinookStaging.dbo.Tracks

--3.  Insert data into Fact table FactSales
INSERT INTO FactSales(
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
JOIN ChinookDW.dbo.DimTracks t
    ON t.TrackId=s.TrackId
JOIN ChinookDW.dbo.DimCustomers c
    ON c.CustomerId=s.CustomerId

-- Check results
select * from DimCustomers
select * from FactSales