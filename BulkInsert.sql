BULK INSERT odsdb_tbl  FROM 'D:\土銀三層式\DataProvider使用空間\odsdb.csv'
WITH (FIRSTROW=2,FIELDTERMINATOR = ',', ROWTERMINATOR = '\n');