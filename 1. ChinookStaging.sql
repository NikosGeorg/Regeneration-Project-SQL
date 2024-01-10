--exec sp_changedbowner 'sa'
USE master
GO
if exists (select * from sysdatabases where name='ChinookStaging')
		alter database ChinookStaging set single_user with rollback immediate
		drop database ChinookStaging
go

CREATE DATABASE ChinookStaging
GO

USE ChinookStaging
GO

DROP TABLE IF EXISTS ChinookStaging.dbo.Sales;
DROP TABLE IF EXISTS ChinookStaging.dbo.Customers;
DROP TABLE IF EXISTS ChinookStaging.dbo.Tracks;

--1. Creates Staging Sales
--  Get data FROM Invoice, InvoiceLine
--  Invoice: CustomerId, InvoiceDate, InvoiceId
--  InvoiceLine: TrackId, UnitPrice
--  NOT used: Invoice-->[BillingAddress],[BillingCity],[BillingState],[BillingCountry],[BillingPostalCode],[Total]
--            InvoiceLine-->[InvoiceLineId],[Quantity]

SELECT TrackId, CustomerId, InvoiceDate, i.InvoiceId, UnitPrice
INTO ChinookStaging.dbo.Sales
FROM Chinook.[dbo].Invoice i
JOIN Chinook.[dbo].InvoiceLine il
ON i.InvoiceId = il.InvoiceId


--2. Create Staging Customers 
--  Get FROM Customer, Employee
--  Customers: CustomerID, FirstName, LastName, Company, Country, State, City, PostalCode 
--  Employee: FirstName, LastName
--  NOT used: CUSTOMER -->[Address],[Phone],[Fax],[Email],[SupportRepId] 
--            EMPLOYEE -->[EmployeeId],[Title],[ReportsTo],[BirthDate],[HireDate],[Address],[City],[State],[Country],[PostalCode],[Phone],[Fax],[Email]

SELECT  c.CustomerID, c.FirstName as CustomerFirstName, c.LastName as CustomerLastName, c.Company as CustomerCompany, c.Country as CustomerCountry, c.State as CustomerState, c.City as CustomerCity, c.PostalCode as CustomerPostalCode, e.FirstName as EmployeeFirstName, e.LastName as EmployeeLastName
INTO ChinookStaging.dbo.Customers
FROM Chinook.[dbo].Customer c
JOIN Chinook.[dbo].Employee e
ON c.SupportRepId = e.EmployeeId


--3. Create Staging Tracks
--  Get data FROM Track, Album, Artist, Genre
--  Track: TrackId, Name, Composer, Milliseconds
--  Album: Title
--  Artist: Name
--  Genre: Name
--  NOT used: Track -->[Bytes],[UnitPrice]
--			  Album -->[AlbumId]
--			  Genre -->[GenreId]
--			  Artist -->[ArtistId]

SELECT  t.TrackId, t.Name as TrackName, t.Composer as TrackComposer, t.Milliseconds as TrackMilliSec, al.Title as AlbumTitle, ar.Name as ArtistName, g.Name as GenreName
INTO ChinookStaging.dbo.Tracks
FROM Chinook.[dbo].Track t
JOIN Chinook.[dbo].Album al
    ON t.AlbumId = al.AlbumId
JOIN Chinook.[dbo].Artist ar
    ON al.ArtistId = ar.ArtistId
JOIN Chinook.[dbo].Genre g
	ON t.GenreId = g.GenreId

--4 Get date dimension

SELECT MIN(InvoiceDate) minDate, MAX(InvoiceDate) maxDate FROM Sales