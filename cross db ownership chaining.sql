  
If the source object in the source database and the target objects in the target databases are owned by the same login account, SQL Server does not check permissions on the target objects.
Instance : 
   sp_configure 'cross db ownership chaining',1
RECONFIGURE

  Database : 
ALTER DATABASE [BMSDB] SET DB_CHAINING ON 


GRANT EXECUTE ON SCHEMA::[dbo] TO portal_rsuser

use reportdb
go
GRANT EXECUTE ON SCHEMA::[dbo] TO portal_rsuser
GRANT EXECUTE ON SCHEMA::[dbo] TO crm_rsuser
GRANT EXECUTE ON SCHEMA::[dbo] TO bms_rsuser


select name,sid from sys.server_principals
where name in ('bms_rsuser','portal_rsuser','crm_rsuser')

use master
--create login bms_rsuser with password = 'P@ssw0rd', sid = 0xF9A58C76CF0F9242B02B505BAE73DCD4
create login crm_rsuser with password = 'P@ssw0rd', sid = 0x2B90B25BB277944592ED55891F2B014C
create login portal_rsuser with password = 'P@ssw0rd', sid = 0xC4496717BC543E41867DAD9537089C00


use [FETC.eTag.Portal.Custom]

GRANT EXECUTE ON OBJECT::SP_RPT_CRM_15_ETAG_DEVICE_STOCK
    TO [crm_rsuser]
GO 


GRANT EXECUTE ON OBJECT::SP_RPT_DP_09015_ETAG_DEVICE_STOCK
    TO [portal_rsuser]
GO 
