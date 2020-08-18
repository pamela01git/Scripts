IF EXISTS (SELECT 1 FROM sys.dm_xe_sessions WHERE name = 'SQLStmtEvents')
    DROP EVENT SESSION SQLStmtEvents ON SERVER
GO
-- Create our Event Session for current Session_ID
DECLARE @SqlCmd NVARCHAR(MAX) = N'
CREATE EVENT SESSION SQLStmtEvents
ON SERVER
ADD EVENT sqlserver.sql_statement_completed
(    ACTION (sqlserver.sql_text, sqlserver.tsql_stack)
    WHERE (sqlserver.session_id = '+CAST(@@SPID AS NVARCHAR(4))+')    ),
ADD EVENT sqlserver.sql_statement_starting
(    ACTION (sqlserver.sql_text, sqlserver.tsql_stack)
    WHERE (sqlserver.session_id = '+CAST(@@SPID AS NVARCHAR(4))+')    )
ADD target package0.ring_buffer
WITH (MAX_DISPATCH_LATENCY=5SECONDS, TRACK_CAUSALITY=ON)';
EXEC(@SqlCmd);
GO
-- Start the Event Session
ALTER EVENT SESSION SQLStmtEvents
ON SERVER
STATE=START;
GO
-- Run a multi-statement Batch
SELECT * 
FROM sys.objects

SELECT * 
FROM master..spt_values
WHERE type = N'P'

SELECT *
FROM INFORMATION_SCHEMA.TABLES
GO

select GETDATE()