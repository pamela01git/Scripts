(1)	I provide some T-SQL utilities for troubleshooting performance issue:

1)	以下針對資料庫 Auto Create Statistics (_WA_SYS)的建議(無用的 Statistics 可能影響產生正確的執行計畫)：

1.	您可以先將資料庫現有的 Auto Create Statistics 進行清理動作，SQL Server 會依據語法的條件，自動建立

/*
一次清除所有資料表上，SQL Server 自動建立的統計資訊 (以_WA_Sys 命名的統計資訊)
*/

DECLARE @ObjectName sysname
DECLARE @StatsName sysname
DECLARE @SchemaName sysname

DECLARE StatsCursor CURSOR FAST_FORWARD
FOR
	SELECT (tblSchema.TABLE_SCHEMA + '.' + tbl.name) AS ObjectName, st.name AS StatsName
	FROM sys.tables AS tbl 
	INNER JOIN sys.stats st ON st.object_id=tbl.object_id
	INNER JOIN information_schema.tables tblSchema
	ON tbl.name = tblSchema.TABLE_NAME
	WHERE st.auto_created  = 1

OPEN StatsCursor
FETCH NEXT FROM StatsCursor
	INTO @ObjectName, @StatsName
	WHILE @@FETCH_STATUS = 0
		BEGIN
			PRINT 'DROP STATISTICS ' + @ObjectName + '.' + @StatsName
			EXEC ('DROP STATISTICS ' + @ObjectName + '.' + @StatsName)
			FETCH NEXT FROM StatsCursor
			INTO @ObjectName, @StatsName
		END
CLOSE StatsCursor
DEALLOCATE StatsCursor


2.	如果還有 Auto Create Statistics (_WA_SYS) 產生，請檢視該 Statistics 從那一個欄位產生，接下來搜尋所有的 T-SQL 語法，檢視是否有使用到該欄位作為查詢條件，如果有的話請評估其使用頻率，是否需要將該欄位增加一個 Index。如果您決定要增加該欄位的 Index，請在增加完成後，將對應的Auto Create Statistics (_WA_SYS)清除。

請參考：
SQL Server Statistics: Problems and Solutions
http://www.simple-talk.com/sql/performance/sql-server-statistics-problems-and-solutions/  

Why does Update Stats with SAMPLE take longer then FULLSCAN?
http://www.sql-server-performance.com/forum/threads/why-does-update-stats-with-sample-take-longer-then-fullscan.29194/ 

Execution Plan Basics
http://www.simple-talk.com/sql/performance/execution-plan-basics/ 

Update SQL Server table statistics for performance kick
http://searchsqlserver.techtarget.com/tip/Update-SQL-Server-table-statistics-for-performance-kick 

--Use DBCC UpdateStstistics with FULLSCAN on every Table on Specific Database

Set nocount on

-- <<<< Please change the following Database name >>>>
USE {Database_Name}
---------------

declare @db_name as sysname
set @db_name = DB_NAME()

--For SQL Server 2000
declare tables cursor for
select quotename(User_Name(uid))+'.'+ quotename(Object_Name(id)) as [Schema Table] 
from sysObjects 
where xtype = 'U'
And (quotename(User_Name(uid))+'.'+ quotename(Object_Name(id)))is not null
order by name

Open tables 

declare @table_name as sysname
declare @reserved_size as VarChar(10)
declare @int_reserved_size as int
DECLARE @ExecuteString NVARCHAR(500)

--Initial Variables
Set @ExecuteString = ''

--Start Cursor 
Fetch next from tables into @table_name
while (@@fetch_status=0) 
  Begin
  
            print '========== Information ==================='
            print 'Table [' + @table_name + '] Is Processed!'   
            print '=========================================='
  
                Set @ExecuteString = 'UPDATE STATISTICS ' + @table_name + ' WITH FULLSCAN'
                Print 'Executing UPDATE STATISTICS  : ' + @ExecuteString              
                EXEC SP_ExecuteSql @ExecuteString         
      
      Set @ExecuteString = ''
      Fetch next from tables into @table_name

  End 
 
Close tables
Deallocate tables

2)	手動執行每一個 Table Re-index 的語法(減少索引 Fragment 及一併更新統計資訊 )：

set nocount on

--請修改資料庫名稱
use Adventureworks

declare @db_name as char(50)
select @db_name = name from sys.sysdatabases where dbid=DB_ID()

declare tables cursor for
select name from sysobjects where xtype = 'U' order by name

open tables 
 
declare @name as sysname
declare @reserved_size as VarChar(10)
declare @int_reserved_size as int

--Start Cursor 
fetch next from tables into @name

    while (@@fetch_status=0)
     
      begin
      
       Begin
     
          print '========== Information ================'
          PRINT 'Table <' + @name + '> Is Processed!' 
          print '=================================='
     
          DBCC DBREINDEX(@name,'',70)
     
          End 
     
  fetch next from tables into @name

  end 
 
close tables
deallocate tables
