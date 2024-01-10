use ChinookDW

ALTER TABLE FactSales ADD  constraint [FactSalesDimDate] FOREIGN KEY (InvoiceDateKey)
    REFERENCES DimDate(DateKey);

ALTER TABLE FactSales ADD  constraint [FactSalesDimCustomers]  FOREIGN KEY (CustomerKey)
    REFERENCES DimCustomers (CustomerKey);

ALTER TABLE FactSales ADD  constraint [FactSalesDimTracks] FOREIGN KEY (TrackKey)
    REFERENCES DimTracks (TrackKey);
