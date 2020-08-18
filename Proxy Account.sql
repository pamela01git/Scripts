http://www.mssqltips.com/sqlservertip/2163/running-a-ssis-package-from-sql-server-agent-using-a-proxy-account/

--Script #1 - Creating a credential to be used by proxy
USE MASTER
GO 
 --Drop the credential if it is already existing 
IF EXISTS (SELECT  1 FROM  sys.credentials  WHERE name = N'SSISProxy_George') 
BEGIN 
 DROP CREDENTIAL [SSISProxy_George] 
END 
 GO 
CREATE CREDENTIAL [SSISProxy_George] 
WITH  IDENTITY  = N'fareast\geoliang', 
SECRET  = N'Georg!54971307' 
GO 

--Script #2 - Creating a proxy account 
USE  msdb
GO 
 --Drop the proxy if it is already existing 
IF EXISTS (SELECT  1 FROM  msdb.dbo.sysproxies  WHERE name = N'SSISProxy') 
BEGIN 
EXEC  dbo.sp_delete_proxy 
@proxy_name  = N'SSISProxy' 
END 
 GO 
--Create a proxy and use the same credential as created above 
 EXEC msdb.dbo.sp_add_proxy 
@proxy_name  = N'SSISProxy', 
@credential_name=N'SSISProxy_George', 
@enabled=1 
GO 
----To enable or disable you can use this command 
--EXEC  msdb.dbo.sp_update_proxy 
--@proxy_name  = N'SSISProxyDemo', 
--@enabled  = 1  --@enabled = 0 
--GO 

--Script #3 - Granting proxy account to SQL Server Agent Sub-systems 
 USE msdb
GO 
--You can view all the sub systems of SQL Server Agent with this command
--You can notice for SSIS Subsystem id is 11 
EXEC  sp_enum_sqlagent_subsystems 
 GO


--Grant created proxy to SQL Agent subsystem 
--You can grant created proxy to as many as available subsystems 
EXEC  msdb.dbo.sp_grant_proxy_to_subsystem 
@proxy_name=N'SSISProxy', 
@subsystem_id=11 --subsystem 11 is for SSIS as you can see in the above image 
GO 
 --View all the proxies granted to all the subsystems 
EXEC  dbo.sp_enum_proxy_for_subsystem 

 --Script #4 - Granting proxy access to security principals 
USE msdb
GO 
 --Grant proxy account access to security principals that could be
--either login name or fixed server role or msdb role
--Please note, Members of sysadmin server role are allowed to use any proxy 
EXEC msdb.dbo.sp_grant_login_to_proxy 
@proxy_name=N'SSISProxy' 
,@login_name=N'tw-geoliang-133\george' 
--,@fixed_server_role=N'' 
--,@msdb_role=N'' 
 GO 
 --View logins provided access to proxies 
EXEC dbo.sp_enum_login_for_proxy 
GO 
\\


select * from master..tbl_user
