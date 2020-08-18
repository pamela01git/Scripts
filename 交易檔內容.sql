SELECT top 12 Operation,Context,[Log Record Length],[Transaction Name]
FROM fn_dblog(NULL, NULL)
where allocunitname='dbo.testa'