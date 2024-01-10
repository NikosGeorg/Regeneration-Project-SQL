--exec sp_changedbowner 'sa'
USE master
GO
if exists (select * from sysdatabases where name='ChinookDW')
		alter database ChinookDW set single_user with rollback immediate
		drop database ChinookDW
go

CREATE DATABASE ChinookDW
GO

USE ChinookDW
GO

DROP TABLE IF EXISTS FactSales;
DROP TABLE IF EXISTS DimCustomers;
DROP TABLE IF EXISTS DimTracks;

--1. Create FACT table for FactSales
CREATE TABLE FactSales(
	TrackKey INT NOT NULL,
	CustomerKey INT NOT NULL,
	InvoiceDateKey INT NOT NULL,
	InvoiceId INT NOT NULL,
	TrackPrice FLOAT NOT NULL
);

--2. Create DIMENSION table for DimCustomers
CREATE TABLE DimCustomers(
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

--3. Create DIMENSION table for DimTracks
CREATE TABLE DimTracks(
	TrackKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	TrackId INT NOT NULL,
	TrackName NVARCHAR(200) NOT NULL,
	TrackComposer NVARCHAR(220) NULL,
	TrackLength INT NOT NULL, -- Maybe needs float if we transform from Milliseconds
	AlbumTitle NVARCHAR(160) NOT NULL,
	ArtistName NVARCHAR(120) NULL,
	GenreName NVARCHAR(120)  NULL,
	RowIsCurrent INT DEFAULT 1 NOT NULL,
    RowStartDate DATE DEFAULT '1899-12-31' NOT NULL,
    RowEndDate DATE DEFAULT '9999-12-31' NOT NULL,
    RowChangeReason VARCHAR(200) NULL
);