EXEC sp_addlinkedserver 
    '10.253.22.40',
    N'SQL Server'
    
EXEC sp_addlinkedsrvlogin '10.253.22.40', 'false', NULL, 'odsdba', 'odsdba'
