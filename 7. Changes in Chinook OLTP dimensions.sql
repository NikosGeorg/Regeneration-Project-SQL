--changes in OLTP
USE [Chinook]
GO

--  select * from [dbo].[Customer]

--  Update a Customer in the table Customer
update [dbo].[Customer] set 
	Address = 'Konitsas 15',
	City = 'Athens',
	State = 'Attiki',
	Country = 'Greece', 
	PostalCode = '11526'
where [CustomerId] = '1';

--  Insert a Customer in the table Customer
INSERT INTO [dbo].[Customer](
[CustomerId],
[FirstName],
[LastName],
[Company],
[Address],
[City],
[State],
[Country],
[PostalCode],
[Phone],
[Email],
[SupportRepId]
)
VALUES(
'60',
'Dimitris',
'Georgakis',
'Gati Company',
'Iracliou',
'Athens',
'Attiki',
'Greece',
11527,
'+306954897536',
'xxxx',
'3'
);

--  Find a  customer with no Invoices to delete
--select c.CustomerID 
--from Customer c left join [Invoice] i
--on i.CustomerID = c.CustomerID
--where i.InvoiceId is null;
		   
--  Delete a Customer from the table Customer
--delete from [dbo].[Customer] where [CustomerID] = '60';

--  select * from [dbo].[Invoice]

--  Insert new sale into Fact table Invoice
INSERT INTO [dbo].[Invoice](
[InvoiceId],
[CustomerID],
[InvoiceDate],
[Total]
)
VALUES(
'413',
'60',
'2013-12-23',
'1.98'
),
(
'414',
'1',
'2013-12-23',
'0.99'
);

--select * from [dbo].[InvoiceLine]

--  Insert new Invoice Line into table InvoiceLine
INSERT INTO [dbo].[InvoiceLine](
[InvoiceLineId],
[InvoiceId],
[TrackId],
[UnitPrice],
[Quantity]
)
VALUES
(2241, 413, 1, 0.99, 1),
(2242, 413, 2, 0.99, 1),
(2243, 414, 1, 0.99, 1);

-- Check results
select * from [dbo].[Customer]
select * from [dbo].[Invoice]
select * from [dbo].[InvoiceLine]