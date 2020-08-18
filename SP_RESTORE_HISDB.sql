USE [master]
GO
/****** Object:  StoredProcedure [dbo].[SP_RESTORE_HISDB]    Script Date: 2017/12/25 ¤U¤È 03:18:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER PROC [dbo].[SP_RESTORE_HISDB] @path NVARCHAR(128)
AS 
IF OBJECT_ID(N'tempdb..#tmp') IS NOT NULL
BEGIN
     DROP TABLE #tmp
END


create table #tmp
(
LogicalName nvarchar(128) 
,PhysicalName nvarchar(260) 
,Type char(1) 
,FileGroupName nvarchar(128) 
,Size numeric(20,0) 
,MaxSize numeric(20,0),
Fileid tinyint,
CreateLSN numeric(25,0),
DropLSN numeric(25, 0),
UniqueID uniqueidentifier,
ReadOnlyLSN numeric(25,0),
ReadWriteLSN numeric(25,0),
BackupSizeInBytes bigint,
SourceBlocSize int,
FileGroupId int,
LogGroupGUID uniqueidentifier,
DifferentialBaseLSN numeric(25,0),
DifferentialBaseGUID uniqueidentifier,
IsReadOnly bit,
IsPresent bit, 
TDEThumbPrint varchar(50),
SnapshotUrl Nvarchar(360)
)

insert #tmp
EXEC ('restore filelistonly from disk = ''' + @path + '''')


--select * from #tmp

Declare @RestoreString as Varchar(max)
Declare @NRestoreString as NVarchar(max)
DECLARE @LogicalName  as varchar(75)
Declare @counter as int
Declare @rows as int
set @counter = 1
select @rows = COUNT(*) from #tmp
--select @Rows as [These are the number of rows]

DECLARE MY_CURSOR Cursor 
FOR 
Select LogicalName 
From #tmp

Open My_Cursor 
set @RestoreString = 
'RESTORE DATABASE [HISDB] FROM DISK = N''C:\SqlBack\HISDB_Sprint8.bak'''
 + ' with  ' 

Fetch NEXT FROM MY_Cursor INTO @LogicalName 
While (@@FETCH_STATUS <> -1)
BEGIN
IF (@@FETCH_STATUS <> -2)
select @RestoreString =
case 
when @counter = 1 then 
   @RestoreString + 'move  N''' + @LogicalName + '''' + ' TO N''C:\SQLData\'+
 @LogicalName + '.mdf' + '''' + ', '
when @counter > 1 and @counter < @rows then
   @RestoreString + 'move  N''' + @LogicalName + '''' + ' TO N''C:\SQLData\'+
 @LogicalName + '.ndf' + '''' + ', '
WHen @LogicalName like '%log%' then
   @RestoreString + 'move  N''' + @LogicalName + '''' + ' TO N''C:\SQLLog\'+
 @LogicalName + '.ldf' +''''
end
--select @RestoreString

set @counter = @counter + 1
FETCH NEXT FROM MY_CURSOR INTO @LogicalName
END

--select @RestoreString
set @NRestoreString = 'ALTER DATABASE [HISDB] SET SINGLE_USER WITH ROLLBACK IMMEDIATE'+ char(13)+char(10) +@RestoreString+',  REPLACE'+  char(13)+char(10) +'ALTER DATABASE [HISDB] SET MULTI_USER WITH NO_WAIT'
--print @NRestoreString
EXEC sp_executesql @NRestoreString
CLOSE MY_CURSOR
DEALLOCATE MY_CURSOR