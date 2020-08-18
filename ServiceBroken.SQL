USE TEMPDB
ALTER DATABASE TEMPDB SET ENABLE_BROKER
GO
/* 產生log記錄table */
CREATE TABLE dbo.AuditLog(
command nvarchar(1000),
posttime nvarchar(24),
houstname nvarchar(100),
loginname nvarchar(100),
spid nvarchar(6)
)
GO
/* 產生QUEUE */
CREATE QUEUE NOTIFYQUEUE
GO
/* 產生SERVICE */
CREATE SERVICE NOFIFYSERVICE
ON QUEUE NOTIFYQUEUE
(
[http://schemas.microsoft.com/SQL/Notifications/PostEventNotification]
)
GO
/* 產生ROUTE */
CREATE ROUTE NOTIFYROUTE
WITH SERVICE_NAME='NOFIFYSERVICE',
ADDRESS='LOCAL'
GO
/* 產生接收記錄 */
CREATE EVENT NOTIFICATION NOTIFYTSQL
ON SERVER
FOR TRC_STORED_PROCEDURES  /* 記錄USER所下的T-SQL命令 */
/* 以上屬性可參考 ms-help://MS.SQLCC.v9/MS.SQLSVR.v9.en/udb9/html/5c484e7b-8ad5-4cdc-9f6a-55845edac4a5.htm */
TO SERVICE 'NOFIFYSERVICE',
'current database'
GO
/* 將記錄寫至實體TABLE中 (從QUEUE中接收資訊)*/
/* 例: ?<EVENT_INSTANCE><EventType>SP_CACHEMISS</EventType><PostTime>2007-07-12T14:00:59.813</PostTime><SPID>61</SPID><TextData>&#x0D; EXEC ODSDB.odsdba.SP_INS_OdsmsUnBbal_OdsUnBbal '','','','','','',''</TextData><DatabaseID>2</DatabaseID><TransactionID>635612</TransactionID><NTUserName>Administrator</NTUserName><NTDomainName>BIBBY-HSU</NTDomainName><HostName>BIBBY-HSU</HostName><ClientProcessID>4644</ClientProcessID><ApplicationName>Microsoft SQL Server Management Studio - Query</ApplicationName><LoginName>BIBBY-HSU\Administrator</LoginName><StartTime>2007-07-12T14:00:59.793</StartTime><ObjectID>715771103</ObjectID><ServerName>BIBBY-HSU</ServerName><ObjectType>20801</ObjectType><ObjectName/><LoginSid>AQUAAAAAAAUVAAAAOyNsoL6mMRJomgSV9AEAAA==</LoginSid><RequestID>0</RequestID><XactSequence>0</XactSequence><EventSequence>38655</EventSequence><IsSystem/><SessionLoginName>BIBBY-HSU\Administrator</SessionLoginName></EVENT_INSTANCE> */
DECLARE @MESSAGETYPENAME NVARCHAR(256),@MESSAGEBODY XML,@CNT INT
SET @CNT=1
WHILE @CNT>0
BEGIN
 ;RECEIVE top(1)
 @MESSAGETYPENAME=MESSAGE_TYPE_NAME,
 @MESSAGEBODY=MESSAGE_BODY
 FROM DBO.NOTIFYQUEUE;
 SELECT @CNT=@@ROWCOUNT
 IF @CNT=0
 RETURN
 DECLARE @CMD NVARCHAR(1000)
 DECLARE @POSTTIME NVARCHAR(24)
 DECLARE @SPID NVARCHAR(6)
 DECLARE @HOSTNAME NVARCHAR(100)
 DECLARE @LOGINNAME NVARCHAR(100)
 SET @CMD=@MESSAGEBODY.value('(/EVENT_INSTANCE/TextData)[1]','NVARCHAR(1000)')
 SET @POSTTIME=@MESSAGEBODY.value('(/EVENT_INSTANCE/PostTime)[1]','NVARCHAR(24)')
 SET @SPID=@MESSAGEBODY.value('(/EVENT_INSTANCE/SPID)[1]','NVARCHAR(6)')
 SET @LOGINNAME=@MESSAGEBODY.value('(/EVENT_INSTANCE/LoginName)[1]','NVARCHAR(100)')
 SET @HOSTNAME=HOST_NAME()
 INSERT INTO dbo.AUDITLOG
 VALUES(@CMD,@POSTTIME,@HOSTNAME,@LOGINNAME,@SPID)
END

/* 查看QUEUE接收到的資訊 */
select CONVERT(NVARCHAR(MAX),MESSAGE_BODY), * from dbo.NOTIFYQUEUE