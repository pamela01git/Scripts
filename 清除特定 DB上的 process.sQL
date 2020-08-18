create procedure dbo.usp_ETL_KillProcessOnDB
    @db_name       varchar(50)   -- DB Name
AS
declare @spid  as int
declare @sqlcmd  as nvarchar(50)
-- Get spid on DB
DECLARE spid_cursor CURSOR FOR 
select spid
from master.dbo.sysprocesses
where dbid <> 0 and db_name(dbid) = @db_name
order by spid
-- KILL Process
OPEN spid_cursor
FETCH NEXT FROM spid_cursor 
INTO @spid
WHILE @@FETCH_STATUS = 0
BEGIN
 set  @sqlcmd = 'KILL '+STR(@spid)
 PRINT @sqlcmd
 exec sp_executesql @sqlcmd
FETCH NEXT FROM spid_cursor 
INTO @spid
END
CLOSE spid_cursor
DEALLOCATE spid_cursor
GO