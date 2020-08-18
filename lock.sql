SP_LOCK;

trace flag 1200

select * from sys.dm_tran_locks;

select * from sys.dm_tran_session_transactions where session_id = 78
select * from sys.dm_tran_locks where request_request_id = 78
exec sp_lock
select * from sys.dm_tran_active_transactions 
where transaction_id in (select transaction_id from sys.dm_tran_session_transactions where session_id = 78)


SELECT
t1.resource_type,
t1.resource_database_id,
t1.resource_associated_entity_id,
t1.request_mode,
t1.request_session_id,
t2.blocking_session_id,
o1.name 'object name',
o1.type_desc 'object descr',
p1.partition_id 'partition id',
p1.rows 'partition/page rows',
a1.type_desc 'index descr',
a1.container_id 'index/page container_id'
FROM sys.dm_tran_locks as t1
INNER JOIN sys.dm_os_waiting_tasks as t2
	ON t1.lock_owner_address = t2.resource_address
LEFT OUTER JOIN sys.objects o1 on o1.object_id = t1.resource_associated_entity_id
LEFT OUTER JOIN sys.partitions p1 on p1.hobt_id = t1.resource_associated_entity_id
LEFT OUTER JOIN sys.allocation_units a1 on a1.allocation_unit_id = t1.resource_associated_entity_id

SELECT

CASE DTL.REQUEST_SESSION_ID

WHEN -2 THEN 'ORPHANED DISTRIBUTED TRANSACTION'

WHEN -3 THEN 'DEFERRED RECOVERY TRANSACTION'

ELSE DTL.REQUEST_SESSION_ID END AS SPID,

DB_NAME(DTL.RESOURCE_DATABASE_ID) AS DATABASENAME,

SO.NAME AS LOCKEDOBJECTNAME,

DTL.RESOURCE_TYPE AS LOCKEDRESOURCE,

DTL.REQUEST_MODE AS LOCKTYPE,

ST.TEXT AS SQLSTATEMENTTEXT,

ES.LOGIN_NAME AS LOGINNAME,

ES.HOST_NAME AS HOSTNAME,

CASE TST.IS_USER_TRANSACTION

WHEN 0 THEN 'SYSTEM TRANSACTION'

WHEN 1 THEN 'USER TRANSACTION' END AS USER_OR_SYSTEM_TRANSACTION,

AT.NAME AS TRANSACTIONNAME,

DTL.REQUEST_STATUS

FROM

SYS.DM_TRAN_LOCKS DTL

JOIN SYS.PARTITIONS SP ON SP.HOBT_ID = DTL.RESOURCE_ASSOCIATED_ENTITY_ID

JOIN SYS.OBJECTS SO ON SO.OBJECT_ID = SP.OBJECT_ID

JOIN SYS.DM_EXEC_SESSIONS ES ON ES.SESSION_ID = DTL.REQUEST_SESSION_ID

JOIN SYS.DM_TRAN_SESSION_TRANSACTIONS TST ON ES.SESSION_ID = TST.SESSION_ID

JOIN SYS.DM_TRAN_ACTIVE_TRANSACTIONS AT ON TST.TRANSACTION_ID = AT.TRANSACTION_ID

JOIN SYS.DM_EXEC_CONNECTIONS EC ON EC.SESSION_ID = ES.SESSION_ID

CROSS APPLY SYS.DM_EXEC_SQL_TEXT(EC.MOST_RECENT_SQL_HANDLE) AS ST

WHERE

RESOURCE_DATABASE_ID = DB_ID()

ORDER BY DTL.REQUEST_SESSION_id

