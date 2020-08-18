--xp_cmdshell 'del /F /Q /S \atel-web\be1\backups*.*'

--exec xp_cmdshell 'del /F /Q /S \atel-web\be2\backups*.*'

USE master

DECLARE @secondaryservername nvarchar(50) = ''

DECLARE @primaryservername nvarchar(50) = ''

DECLARE @availabilitygroup nvarchar(50)  =''

SET @secondaryservername = (select replica_server_name AS Servername from sys.dm_hadr_availability_replica_states
 , sys.dm_hadr_availability_replica_cluster_states where role_desc = 'SECONDARY' AND sys.dm_hadr_availability_replica_states.replica_id = sys.dm_hadr_availability_replica_cluster_states.replica_id)

SET @primaryservername = (select replica_server_name AS Servername from sys.dm_hadr_availability_replica_states
 , sys.dm_hadr_availability_replica_cluster_states where role_desc = 'PRIMARY' AND sys.dm_hadr_availability_replica_states.replica_id = sys.dm_hadr_availability_replica_cluster_states.replica_id)

SET @availabilitygroup = (SELECT name FROM [sys].[availability_groups])

IF OBJECT_ID('dbo.#dbs', 'U') IS NOT NULL DROP TABLE dbo.#dbs


IF (SELECT CURSOR_STATUS('global','adddbs')) >=0 BEGIN DEALLOCATE adddbs END

create table #dbs(a int primary key identity, dbname varchar(100)) declare @nextdb varchar(100) declare @restorestring varchar(400)

--Populate temp table insert (dbname) 
insert into #dbs(dbname) 
select name

 from sys.databases where group_database_id is null and replica_id is null and name not in('master','model','msdb','tempdb')

--Create a cursor to
 declare adddbs cursor for select dbname from #dbs

open adddbs

FETCH NEXT FROM adddbs INTO @nextdb

WHILE @@FETCH_STATUS = 0 BEGIN EXEC ('ALTER DATABASE' + '[' + @nextdb + ']' + 'set RECOVERY FULL') EXEC ('BACKUP DATABASE ' + '[' + @nextdb + ']' + ' TO DISK = ' + '''\' +@primaryservername+'\backups\' + '[' + @nextdb + ']' + 'initialize.bak''')

print ('ALTER AVAILABILITY GROUP ['+ @availabilitygroup +'] ADD DATABASE ' + '[' + @nextdb + ']')

print ('BACKUP DATABASE ' + '[' + @nextdb + ']' + ' TO DISK = ' + '''\'+@primaryservername+'\backups\' + '[' + @nextdb + ']' + '.bak''')

print ('BACKUP LOG ' + '[' + @nextdb + ']' + ' TO DISK = ' + '''\'+@primaryservername+'\backups\' + '[' + @nextdb + ']' + '_log.bak''')

set @restorestring='sqlcmd -S ' +@secondaryservername+' -E -Q"RESTORE DATABASE ' + '[' + @nextdb + ']' + ' FROM DISK = ' + '''\' +@primaryservername +'\backups\' + '[' + @nextdb + ']' + '.bak''' + ' WITH NORECOVERY, NOUNLOAD, STATS = 5"' 
--exec xp_cmdshell @restorestring
print @restorestring

set @restorestring='sqlcmd -S ' +@secondaryservername+' -E -Q"RESTORE LOG ' + '[' + @nextdb + ']' + ' FROM DISK = ' + '''\' +@primaryservername+'\backups\' + '[' + @nextdb + ']' + '_log.bak''' + ' WITH NORECOVERY, NOUNLOAD, STATS = 5"' 
--exec xp_cmdshell @restorestring
print @restorestring

set @restorestring='sqlcmd -S ' +@secondaryservername+' -E -Q"ALTER DATABASE ' + '[' + @nextdb + ']' + ' SET HADR AVAILABILITY GROUP = [' + @availabilitygroup +']"' 
exec xp_cmdshell @restorestring
print @restorestring

FETCH NEXT FROM adddbs INTO @nextdb END

CLOSE adddbs DEALLOCATE adddbs
