(1) 資料庫使用權限:
select s1.name as usr,s3.name as permission from sys.sysusers as s1
join sys.database_role_members as s2 on s1.uid=s2.member_principal_id
join sys.database_principals as s3 on s2.role_principal_id=s3.principal_id
 
(2)資料庫物件使用權限:
select c.name as users,b.name as obj,d.name as owner,e.permission_name as permission,e.state_desc as status
,e.state_desc+' '+CONVERT(NVARCHAR(MAX),e.permission_name),' ON '+d.name+'.'+b.name+' TO '+c.name
 from sys.syspermissions a
join dbo.sysobjects b on a.id=b.id
join dbo.sysusers c on a.grantee=c.uid
join SYS.SCHEMAS d on b.uid=d.schema_id
join sys.database_permissions e on a.id=e.major_id and e.grantee_principal_id=c.uid
where c.name<>'public'
order by users,obj 


/* USER */
--ODSDB
SELECT 'USE ODSDB DROP USER '+NAME+' CREATE USER '+NAME+' FOR LOGIN '+NAME AS EXECSQL FROM ODSDB.sys.sysusers WHERE GID=0 AND UID>4
--DWBASISDB
SELECT 'USE DWBASISDB DROP USER '+NAME+' CREATE USER '+NAME+' FOR LOGIN '+NAME AS EXECSQL FROM DWBASISDB.sys.sysusers WHERE GID=0 AND UID>4
/* USER ROLE */
--ODSDB
select ' EXEC ODSDB.dbo.sp_addrolemember N'''+S3.NAME+''', N'''+S1.NAME+'''' AS EXECSQL
from ODSDB.sys.sysusers as s1
join ODSDB.sys.database_role_members as s2 on s1.uid=s2.member_principal_id
join ODSDB.sys.database_principals as s3 on s2.role_principal_id=s3.principal_id
where s1.name not in ('dbo')
--DWBASISDB
select ' EXEC DWBASISDB.dbo.sp_addrolemember N'''+S3.NAME+''', N'''+S1.NAME+'''' AS EXECSQL
from DWBASISDB.sys.sysusers as s1
join DWBASISDB.sys.database_role_members as s2 on s1.uid=s2.member_principal_id
join DWBASISDB.sys.database_principals as s3 on s2.role_principal_id=s3.principal_id
where s1.name not in ('dbo')
/* DB OBJECT */
-- ODSDB
select 'USE ODSDB '+e.state_desc+' '+CONVERT(NVARCHAR(MAX),e.permission_name) AS PERMISSION,  +' ON '+d.name+'.'+b.name+' TO '+c.name AS OWN
from ODSDB.sys.syspermissions a
join ODSDB.dbo.sysobjects b on a.id=b.id
join ODSDB.dbo.sysusers c on a.grantee=c.uid
join ODSDB.SYS.SCHEMAS d on b.uid=d.schema_id
join ODSDB.sys.database_permissions e on a.id=e.major_id and e.grantee_principal_id=c.uid
where c.name<>'public'
-- DWBASISDB
select 'USE DWBASISDB '+e.state_desc+' '+CONVERT(NVARCHAR(MAX),e.permission_name) AS PERMISSION,  +' ON '+d.name+'.'+b.name+' TO '+c.name AS OWN
from DWBASISDB.sys.syspermissions a
join DWBASISDB.dbo.sysobjects b on a.id=b.id
join DWBASISDB.dbo.sysusers c on a.grantee=c.uid
join DWBASISDB.SYS.SCHEMAS d on b.uid=d.schema_id
join DWBASISDB.sys.database_permissions e on a.id=e.major_id and e.grantee_principal_id=c.uid
where c.name<>'public'






1.Create SQL Server Login User
SELECT 'use master CREATE LOGIN '+LOGINNAME+' WITH PASSWORD=N'''+LOGINNAME+''',DEFAULT_DATABASE=['+DBNAME+'], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF' 
FROM master.sys.syslogins WHERE PASSWORD IS NOT NULL AND NAME<>'SA'
2. Create DB User
SELECT 'USE DWBasisDB DROP USER '+NAME+' CREATE USER '+NAME+' FOR LOGIN '+NAME AS EXECSQL FROM DWBasisDB.sys.sysusers WHERE GID=0 AND UID>4
UNION ALL
SELECT 'USE ODSDB DROP USER '+NAME+' CREATE USER '+NAME+' FOR LOGIN '+NAME AS EXECSQL FROM ODSDB.sys.sysusers WHERE GID=0 AND UID>4
UNION ALL
SELECT 'USE REPORTDB DROP USER '+NAME+' CREATE USER '+NAME+' FOR LOGIN '+NAME AS EXECSQL FROM REPORTDB.sys.sysusers WHERE GID=0 AND UID>4
UNION ALL
SELECT 'USE CBMDB DROP USER '+NAME+' CREATE USER '+NAME+' FOR LOGIN '+NAME AS EXECSQL FROM CBMDB.sys.sysusers WHERE GID=0 AND UID>4
UNION ALL
SELECT 'USE DWMD DROP USER '+NAME+' CREATE USER '+NAME+' FOR LOGIN '+NAME AS EXECSQL FROM DWMD.sys.sysusers WHERE GID=0 AND UID>4
UNION ALL
SELECT 'USE ISMD DROP USER '+NAME+' CREATE USER '+NAME+' FOR LOGIN '+NAME AS EXECSQL FROM ISMD.sys.sysusers WHERE GID=0 AND UID>4
UNION ALL
SELECT 'USE REPLMD DROP USER '+NAME+' CREATE USER '+NAME+' FOR LOGIN '+NAME AS EXECSQL FROM REPLMD.sys.sysusers WHERE GID=0 AND UID>4
UNION ALL
SELECT 'USE TtrailDB DROP USER '+NAME+' CREATE USER '+NAME+' FOR LOGIN '+NAME AS EXECSQL FROM TtrailDB.sys.sysusers WHERE GID=0 AND UID>4
UNION ALL
SELECT 'USE Ttrail_LogDB DROP USER '+NAME+' CREATE USER '+NAME+' FOR LOGIN '+NAME AS EXECSQL FROM Ttrail_LogDB.sys.sysusers WHERE GID=0 AND UID>4
UNION ALL
SELECT 'USE TTrail_UserDB DROP USER '+NAME+' CREATE USER '+NAME+' FOR LOGIN '+NAME AS EXECSQL FROM TTrail_UserDB.sys.sysusers WHERE GID=0 AND UID>4
3. Create DB Role
select ' EXEC DWBasisDB.dbo.sp_addrolemember N'''+S3.NAME+''', N'''+S1.NAME+'''' AS EXECSQL
from DWBasisDB.sys.sysusers as s1
join DWBasisDB.sys.database_role_members as s2 on s1.uid=s2.member_principal_id
join DWBasisDB.sys.database_principals as s3 on s2.role_principal_id=s3.principal_id
where s1.name not in ('dbo')
UNION ALL 
select ' EXEC ODSDB.dbo.sp_addrolemember N'''+S3.NAME+''', N'''+S1.NAME+'''' AS EXECSQL
from ODSDB.sys.sysusers as s1
join ODSDB.sys.database_role_members as s2 on s1.uid=s2.member_principal_id
join ODSDB.sys.database_principals as s3 on s2.role_principal_id=s3.principal_id
where s1.name not in ('dbo')
UNION ALL 
select ' EXEC REPORTDB.dbo.sp_addrolemember N'''+S3.NAME+''', N'''+S1.NAME+'''' AS EXECSQL
from REPORTDB.sys.sysusers as s1
join REPORTDB.sys.database_role_members as s2 on s1.uid=s2.member_principal_id
join REPORTDB.sys.database_principals as s3 on s2.role_principal_id=s3.principal_id
where s1.name not in ('dbo')
UNION ALL 
select ' EXEC CBMDB.dbo.sp_addrolemember N'''+S3.NAME+''', N'''+S1.NAME+'''' AS EXECSQL
from CBMDB.sys.sysusers as s1
join CBMDB.sys.database_role_members as s2 on s1.uid=s2.member_principal_id
join CBMDB.sys.database_principals as s3 on s2.role_principal_id=s3.principal_id
where s1.name not in ('dbo')
UNION ALL 
select ' EXEC DWMD.dbo.sp_addrolemember N'''+S3.NAME+''', N'''+S1.NAME+'''' AS EXECSQL
from DWMD.sys.sysusers as s1
join DWMD.sys.database_role_members as s2 on s1.uid=s2.member_principal_id
join DWMD.sys.database_principals as s3 on s2.role_principal_id=s3.principal_id
where s1.name not in ('dbo')
UNION ALL 
select ' EXEC ISMD.dbo.sp_addrolemember N'''+S3.NAME+''', N'''+S1.NAME+'''' AS EXECSQL
from ISMD.sys.sysusers as s1
join ISMD.sys.database_role_members as s2 on s1.uid=s2.member_principal_id
join ISMD.sys.database_principals as s3 on s2.role_principal_id=s3.principal_id
where s1.name not in ('dbo')
UNION ALL 
select ' EXEC REPLMD.dbo.sp_addrolemember N'''+S3.NAME+''', N'''+S1.NAME+'''' AS EXECSQL
from REPLMD.sys.sysusers as s1
join REPLMD.sys.database_role_members as s2 on s1.uid=s2.member_principal_id
join REPLMD.sys.database_principals as s3 on s2.role_principal_id=s3.principal_id
where s1.name not in ('dbo')
UNION ALL 
select ' EXEC TtrailDB.dbo.sp_addrolemember N'''+S3.NAME+''', N'''+S1.NAME+'''' AS EXECSQL
from TtrailDB .sys.sysusers as s1
join TtrailDB .sys.database_role_members as s2 on s1.uid=s2.member_principal_id
join TtrailDB .sys.database_principals as s3 on s2.role_principal_id=s3.principal_id
where s1.name not in ('dbo')
UNION ALL 
select ' EXEC Ttrail_LogDB.dbo.sp_addrolemember N'''+S3.NAME+''', N'''+S1.NAME+'''' AS EXECSQL
from Ttrail_LogDB .sys.sysusers as s1
join Ttrail_LogDB .sys.database_role_members as s2 on s1.uid=s2.member_principal_id
join Ttrail_LogDB .sys.database_principals as s3 on s2.role_principal_id=s3.principal_id
where s1.name not in ('dbo')
UNION ALL 
select ' EXEC Ttrail_UserDB.dbo.sp_addrolemember N'''+S3.NAME+''', N'''+S1.NAME+'''' AS EXECSQL
from Ttrail_UserDB .sys.sysusers as s1
join Ttrail_UserDB .sys.database_role_members as s2 on s1.uid=s2.member_principal_id
join Ttrail_UserDB .sys.database_principals as s3 on s2.role_principal_id=s3.principal_id
where s1.name not in ('dbo')
4. Create Objects Permission
-- DWBASISDB
select 'USE DWBASISDB '+e.state_desc+' '+CONVERT(NVARCHAR(MAX),e.permission_name) AS PERMISSION,  +' ON '+d.name+'.'+b.name+' TO '+c.name AS OWN
from DWBASISDB.sys.syspermissions a
join DWBASISDB.dbo.sysobjects b on a.id=b.id
join DWBASISDB.dbo.sysusers c on a.grantee=c.uid
join DWBASISDB.SYS.SCHEMAS d on b.uid=d.schema_id
join DWBASISDB.sys.database_permissions e on a.id=e.major_id and e.grantee_principal_id=c.uid
where c.name<>'public'
-- ODSDB
select 'USE ODSDB '+e.state_desc+' '+CONVERT(NVARCHAR(MAX),e.permission_name) AS PERMISSION,  +' ON '+d.name+'.'+b.name+' TO '+c.name AS OWN
from ODSDB.sys.syspermissions a
join ODSDB.dbo.sysobjects b on a.id=b.id
join ODSDB.dbo.sysusers c on a.grantee=c.uid
join ODSDB.SYS.SCHEMAS d on b.uid=d.schema_id
join ODSDB.sys.database_permissions e on a.id=e.major_id and e.grantee_principal_id=c.uid
where c.name<>'public'
-- REPORTDB
select 'USE REPORTDB '+e.state_desc+' '+CONVERT(NVARCHAR(MAX),e.permission_name) AS PERMISSION,  +' ON '+d.name+'.'+b.name+' TO '+c.name AS OWN
from REPORTDB.sys.syspermissions a
join REPORTDB.dbo.sysobjects b on a.id=b.id
join REPORTDB.dbo.sysusers c on a.grantee=c.uid
join REPORTDB.SYS.SCHEMAS d on b.uid=d.schema_id
join REPORTDB.sys.database_permissions e on a.id=e.major_id and e.grantee_principal_id=c.uid
where c.name<>'public'
-- CBMDB
select 'USE CBMDB '+e.state_desc+' '+CONVERT(NVARCHAR(MAX),e.permission_name) AS PERMISSION,  +' ON '+d.name+'.'+b.name+' TO '+c.name AS OWN
from CBMDB.sys.syspermissions a
join CBMDB.dbo.sysobjects b on a.id=b.id
join CBMDB.dbo.sysusers c on a.grantee=c.uid
join CBMDB.SYS.SCHEMAS d on b.uid=d.schema_id
join CBMDB.sys.database_permissions e on a.id=e.major_id and e.grantee_principal_id=c.uid
where c.name<>'public'
-- DWMD
select 'USE DWMD '+e.state_desc+' '+CONVERT(NVARCHAR(MAX),e.permission_name) AS PERMISSION,  +' ON '+d.name+'.'+b.name+' TO '+c.name AS OWN
from DWMD.sys.syspermissions a
join DWMD.dbo.sysobjects b on a.id=b.id
join DWMD.dbo.sysusers c on a.grantee=c.uid
join DWMD.SYS.SCHEMAS d on b.uid=d.schema_id
join DWMD.sys.database_permissions e on a.id=e.major_id and e.grantee_principal_id=c.uid
where c.name<>'public'
-- ISMD
select 'USE ISMD '+e.state_desc+' '+CONVERT(NVARCHAR(MAX),e.permission_name) AS PERMISSION,  +' ON '+d.name+'.'+b.name+' TO '+c.name AS OWN
from ISMD.sys.syspermissions a
join ISMD.dbo.sysobjects b on a.id=b.id
join ISMD.dbo.sysusers c on a.grantee=c.uid
join ISMD.SYS.SCHEMAS d on b.uid=d.schema_id
join ISMD.sys.database_permissions e on a.id=e.major_id and e.grantee_principal_id=c.uid
where c.name<>'public'
-- REPLMD
select 'USE REPLMD '+e.state_desc+' '+CONVERT(NVARCHAR(MAX),e.permission_name) AS PERMISSION,  +' ON '+d.name+'.'+b.name+' TO '+c.name AS OWN
from REPLMD.sys.syspermissions a
join REPLMD.dbo.sysobjects b on a.id=b.id
join REPLMD.dbo.sysusers c on a.grantee=c.uid
join REPLMD.SYS.SCHEMAS d on b.uid=d.schema_id
join REPLMD.sys.database_permissions e on a.id=e.major_id and e.grantee_principal_id=c.uid
where c.name<>'public'
-- TtrailDB
select 'USE TtrailDB '+e.state_desc+' '+CONVERT(NVARCHAR(MAX),e.permission_name) AS PERMISSION,  +' ON '+d.name+'.'+b.name+' TO '+c.name AS OWN
from TtrailDB.sys.syspermissions a
join TtrailDB.dbo.sysobjects b on a.id=b.id
join TtrailDB.dbo.sysusers c on a.grantee=c.uid
join TtrailDB.SYS.SCHEMAS d on b.uid=d.schema_id
join TtrailDB.sys.database_permissions e on a.id=e.major_id and e.grantee_principal_id=c.uid
where c.name<>'public'
-- Ttrail_LogDB
select 'USE Ttrail_LogDB '+e.state_desc+' '+CONVERT(NVARCHAR(MAX),e.permission_name) AS PERMISSION,  +' ON '+d.name+'.'+b.name+' TO '+c.name AS OWN
from Ttrail_LogDB.sys.syspermissions a
join Ttrail_LogDB.dbo.sysobjects b on a.id=b.id
join Ttrail_LogDB.dbo.sysusers c on a.grantee=c.uid
join Ttrail_LogDB.SYS.SCHEMAS d on b.uid=d.schema_id
join Ttrail_LogDB.sys.database_permissions e on a.id=e.major_id and e.grantee_principal_id=c.uid
where c.name<>'public'
-- TTrail_UserDB
select 'USE TTrail_UserDB '+e.state_desc+' '+CONVERT(NVARCHAR(MAX),e.permission_name) AS PERMISSION,  +' ON '+d.name+'.'+b.name+' TO '+c.name AS OWN
from TTrail_UserDB.sys.syspermissions a
join TTrail_UserDB.dbo.sysobjects b on a.id=b.id
join TTrail_UserDB.dbo.sysusers c on a.grantee=c.uid
join TTrail_UserDB.SYS.SCHEMAS d on b.uid=d.schema_id
join TTrail_UserDB.sys.database_permissions e on a.id=e.major_id and e.grantee_principal_id=c.uid
where c.name<>'public'



1.	SQL SERVER LOGIN
--NT Loging
SELECT 'IF NOT EXISTS (select * from sys.server_principals where name= '''+LOGINNAME+''')
CREATE LOGIN ['+LOGINNAME+'] FROM WINDOWS WITH DEFAULT_DATABASE=[master]'
FROM master.sys.syslogins 
WHERE isntuser = 1
--DB Loging
Create SQL Server Login(Domain)
SELECT 'use master CREATE LOGIN '+LOGINNAME+' WITH PASSWORD=N''P@ssw0rd'',DEFAULT_DATABASE=['+DBNAME+'], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF' 
FROM master.sys.syslogins WHERE PASSWORD IS NOT NULL AND NAME<>'SA' and name not like '##%'

2.	DB User
DECLARE @DBNAME SYSNAME
select @DBNAME=s2.name from sys.sysprocesses s1 inner join sys.sysdatabases s2 on (s2.dbid=s1.dbid) where spid = @@SPID
SELECT 'USE '+@DBNAME+'
IF NOT EXISTS (SELECT * FROM SYS.SYSUSERS WHERE NAME = '''+NAME+''')
 CREATE USER ['+NAME+'] FOR LOGIN ['+NAME+']' AS EXECSQL FROM sys.sysusers WHERE GID=0 AND UID>4

3.	DB Role
DECLARE @DBNAME SYSNAME
select @DBNAME=s2.name from sys.sysprocesses s1 inner join sys.sysdatabases s2 on (s2.dbid=s1.dbid) where spid = @@SPID
select 'USE '+@DBNAME+' EXEC dbo.sp_addrolemember N'''+S3.NAME+''', N'''+rtrim(S1.NAME)+'''' AS EXECSQL
from sys.sysusers as s1
join sys.database_role_members as s2 on s1.uid=s2.member_principal_id
join sys.database_principals as s3 on s2.role_principal_id=s3.principal_id
where s1.name not in ('dbo')

4.	Object Permission
DECLARE @DBNAME SYSNAME
select @DBNAME=s2.name from sys.sysprocesses s1 inner join sys.sysdatabases s2 on (s2.dbid=s1.dbid) where spid = @@SPID
;WITH    perms_cte as

(
    select USER_NAME(p.grantee_principal_id) AS principal_name,

            dp.principal_id,

            dp.type_desc AS principal_type_desc,

            p.class_desc,

            OBJECT_NAME(p.major_id) AS object_name,

            p.permission_name,

            p.state_desc AS permission_state_desc 
			,p.grantee_principal_id

    from    sys.database_permissions p

    inner   JOIN sys.database_principals dp

    on     p.grantee_principal_id = dp.principal_id
	--where permission_name= 'execute'
)

SELECT p.principal_name,  p.principal_type_desc, p.class_desc, p.[object_name], p.permission_name, p.permission_state_desc, cast(NULL as sysname) as role_name
,permission_state_desc+' '+permission_name+' on ['+isnull(object_name,class_desc+'::[dbo]')+'] to ['+principal_name+']' as SQL
FROM    perms_cte p
WHERE   principal_type_desc <> 'DATABASE_ROLE'
order by 1




