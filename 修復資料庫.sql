USE CRMBASISDB
GO


    DBCC CHECKTABLE ('odsdba.FB_DAY_DH')

ALTER DATABASE CRMBASISDB SET SINGLE_USER
GO
DBCC CHECKTABLE ('odsdba.FB_DAY_DH',REPAIR_REBUILD)
GO
ALTER DATABASE CRMBASISDB SET MULTI_USER
 
 
 DBCC CHECKTABLE ('odsdba.FB_DAY_DH',REPAIR_ALLOW_DATA_LOSS )
GO