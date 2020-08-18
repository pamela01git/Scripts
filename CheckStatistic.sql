select @@ServerName, getdate()

/* **************************************************************** */

use master

go

DECLARE @db sysname,

            @cmd varchar(4000)

SET NOCOUNT ON




IF (object_id( 'tempdb..#DBA_STATISTICS_STATUS' ) IS NOT NULL) DROP TABLE #DBA_STATISTICS_STATUS ; 




CREATE TABLE #DBA_STATISTICS_STATUS(

id int identity primary key,

database_name sysname,

table_schema sysname,

table_name sysname,

index_name sysname,

table_id int,

index_id int,

modifiedRows int,

rowcnt int,

ModifiedPercent DECIMAL(18,8),

lastStatsUpdate datetime

)




DECLARE Cursor_Statistics CURSOR FOR

SELECT name FROM sys.databases (NOLOCK)

WHERE NAME not in ('tempdb') and Is_Read_only = 0

order by name




OPEN Cursor_Statistics




FETCH NEXT FROM Cursor_Statistics

INTO @db




WHILE @@FETCH_STATUS = 0

BEGIN

      SELECT @cmd = 'USE ['+@db+'];

Insert into #DBA_STATISTICS_STATUS

select

db_name() as database_name,

schemas.name as table_schema,

tbls.name as table_name,

i.name as index_name,

i.id as table_id,

i.indid as index_id,

i.rowmodctr as modifiedRows,

(select max(rowcnt) from sysindexes i2 where i.id = i2.id and i2.indid < 2) as rowcnt,

convert(DECIMAL(18,8), convert(DECIMAL(18,8),i.rowmodctr) / convert(DECIMAL(18,8),(select max(rowcnt) from sysindexes i2 where i.id = i2.id and i2.indid < 2))) as ModifiedPercent,

stats_date( i.id, i.indid ) as lastStatsUpdate

from sysindexes i

inner join sysobjects tbls on i.id = tbls.id

inner join sysusers schemas on tbls.uid = schemas.uid

inner join information_schema.tables tl

on tbls.name = tl.table_name

and schemas.name = tl.table_schema

--and tl.table_type=''BASE TABLE''

where 0 < i.indid and i.indid < 255

and table_schema <> ''sys''

and i.rowmodctr <> 0

and i.status not in (8388704,8388672)

and (select max(rowcnt) from sysindexes i2 where i.id = i2.id and i2.indid < 2) > 0

'

     

     

      --PRINT @cmd

      EXEC (@cmd)




      FETCH NEXT FROM Cursor_Statistics

INTO @db

END




CLOSE Cursor_Statistics

DEALLOCATE Cursor_Statistics




SELECT * from #DBA_STATISTICS_STATUS WHERE ModifiedPercent >= 20 or datediff(DD,lastStatsUpdate,getdate()) >= 30

ORDER BY database_name,rowcnt desc




DECLARE @table sysname,

            @schema sysname,

            @index sysname         




DECLARE Cursor_Statistics CURSOR FOR

SELECT database_name,table_schema,table_name,index_name from #DBA_STATISTICS_STATUS WHERE ModifiedPercent >= 20 or datediff(DD,lastStatsUpdate,getdate()) >= 30

ORDER BY database_name,rowcnt desc




OPEN Cursor_Statistics




FETCH NEXT FROM Cursor_Statistics

INTO @db,@schema,@table,@index







WHILE @@FETCH_STATUS = 0

BEGIN

      SELECT @cmd = 'USE ['+@db+'];

      UPDATE STATISTICS '+@schema+'.'+@table+' '+@index+' WITH FULLSCAN;

      '

     

      PRINT @cmd

      EXEC (@cmd)

      PRINT '--'+cast(getdate() as varchar(20))







      FETCH NEXT FROM Cursor_Statistics

      INTO @db,@schema,@table,@index

END




CLOSE Cursor_Statistics

DEALLOCATE Cursor_Statistics

GO




select @@ServerName, getdate()

/* **************************************************************** */

IF (object_id( 'tempdb..#DBA_STATISTICS_STATUS' ) IS NOT NULL) DROP TABLE #DBA_STATISTICS_STATUS ;









----------------------------------
SELECT name AS Stats, 

STATS_DATE(object_id, stats_id) AS LastStatsUpdate

FROM sys.stats 

WHERE object_id= OBJECT_ID('dbo.bms_rat_tx_batch')

--object_id= OBJECT_ID('dbo.bms_pro_gantry_tx')

/*and left(name,4)!='_WA_';*/

order by 2 desc
