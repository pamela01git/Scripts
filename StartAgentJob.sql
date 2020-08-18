ALTER procedure SP_START_EXECUTION_ALL_PACKAGE @BegDate VARCHAR(10),@EndDate VARCHAR(10)
AS

--Required Permission
/*Sample:
  use master
   GRANT EXECUTE ON DBO.SP_START_EXECUTION_ALL_PACKAGE TO [FETCM\PTLUSER]
  grant IMPERSONATE ON LOGIN:: [FETCM\ADMINISTRATOR] TO  [FETCM\PTLUSER]

*/

--EXECUTE AS LOGIN = 'FETCP\bmsservice'
EXECUTE AS LOGIN = 'FETCM\administrator'

DECLARE @ID uniqueidentifier
DECLARE @STEP_ID INT
--declare @JOB_NAME sysname = 'ExecutionAllPackage'
declare @JOB_NAME sysname = 'ExecutionAllPackage_DEV1'
declare @step_name sysname = 'ExecutionAllPackage'

SELECT @id=S1.JOB_ID,@STEP_ID=s2.step_id
FROM MSDB.DBO.SYSJOBS AS S1 inner join MSDB.dbo.SYSJOBSTEPS s2 on (s2.job_id=s1.job_id )
WHERE  S1.NAME=@JOB_NAME and  s2.step_name = @step_name

--Modify parameter BegDate & EndDate
DECLARE @CMD nvarchar(1000)
--SET @cMD='/ISSERVER "\"\SSISDB\SETTLEMENT\SETTLEMENT\ExecutionAllPackage.dtsx\"" /SERVER "\"BMS-PRDDB-VIP\"" /ENVREFERENCE 1 /Par "\"$Project::BeginDate\"";"\"'+@BegDate
--+'\"" /Par "\"$Project::EndDate\"";"\"'+@EndDate+'\"" /Par BeginDate;"\"1900-01-01\"" /Par EndDate;"\"1900-01-01\"" /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E'
SET @cMD= '/ISSERVER "\"\SSISDB\SETTLEMENT\SETTLEMENT\ExecutionAllPackage.dtsx\"" /SERVER sqldvip04 /ENVREFERENCE 16 /Par "\"$Project::BeginDate\"";"\"'+@BegDate+'\"" /Par "\"$Project::EndDate\"";"\"'+@EndDate+'\"" /Par BeginDate;"\"1900-01-01\"" /Par EndDate;"\"1900-01-01\"" /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E'



EXEC msdb.dbo.sp_update_jobstep @job_id=@ID, @step_id=@STEP_ID , @command=@CMD

EXEC msdb.dbo.sp_start_job @job_name
WAITFOR DELAY '00:00:05'

--Back to default parameter - 1900-01-01
--set @cmd = '/ISSERVER "\"\SSISDB\SETTLEMENT\SETTLEMENT\ExecutionAllPackage.dtsx\"" /SERVER "\"BMS-PRDDB-VIP\"" /ENVREFERENCE 1 /Par "\"$Project::BeginDate\"";"\"1900-01-01\"" /Par "\"$Project::EndDate\"";"\"1900-01-01\"" /Par BeginDate;"\"1900-01-01\"" /Par EndDate;"\"1900-01-01\"" /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E'
set @cmd = '/ISSERVER "\"\SSISDB\SETTLEMENT\SETTLEMENT\ExecutionAllPackage.dtsx\"" /SERVER sqldvip04 /ENVREFERENCE 16 /Par "\"$Project::BeginDate\"";"\"1900-01-01\"" /Par "\"$Project::EndDate\"";"\"1900-01-01\"" /Par BeginDate;"\"1900-01-01\"" /Par EndDate;"\"1900-01-01\"" /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E'


EXEC msdb.dbo.sp_update_jobstep @job_id=@ID, @step_id=@STEP_ID , @command=@CMD
