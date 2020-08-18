/*
Name: usp_SG_SelectInto
Desc: 將 Source Table以 Select Into語法載入 DB
example: exec usp_SG_SelectInto 'CSFCDB','dbo','cdb_sploan_dds','STGDB','dbo','SG_UN_LN_SPLOAN'
Release Notes:
V0.1	20060224	Initiation
*/
use STGDB

if exists (select * from dbo.sysobjects where id = object_id(N'usp_SG_SelectInto') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
    drop procedure dbo.usp_SG_SelectInto
go


create procedure dbo.usp_SG_SelectInto
	@SrcDBName		varchar(20), 
	@SrcSchemaName	varchar(20),
	@SrcTableName	varchar(50),
	@TgtDBName		varchar(20),
	@TgtSchemaName	varchar(20),
	@TgtTableName	varchar(50)
--With EXECUTE AS owner	-- 請以 sa權限建立此 stored procedure
AS

declare @SqlCmd		nvarchar(max)

-- 先 drop已存在的 Target Table
Set @SqlCmd = 
'if exists (select * from dbo.sysobjects where id = object_id(N''['+@TgtDBName+'.'+@TgtSchemaName+'.'+@TgtTableName+']'') and OBJECTPROPERTY(id, N''IsUserTable'') = 1)
drop table ['+@TgtDBName+'.'+@TgtSchemaName+'.'+@TgtTableName+'];'

--print	@SqlCmd
-- 執行 SQL command
EXEC	sp_executesql @SqlCmd

-- 組成 SQL command
Set @SqlCmd = 
'SELECT * INTO '+@TgtDBName+'.'+@TgtSchemaName+'.'+@TgtTableName+' 
FROM '+@SrcDBName+'.'+@SrcSchemaName+'.'+@SrcTableName+';'

--print	@SqlCmd
-- 執行 SQL command
EXEC	sp_executesql @SqlCmd

-- Show message
print 'Loading from ' + @SrcDBName+'.'+@SrcSchemaName+'.'+@SrcTableName + ' to ' + @TgtDBName+'.'+@TgtSchemaName+'.'+@TgtTableName + ' : ' + Cast(@@ROWCOUNT as varchar) + ' row(s)'

go

