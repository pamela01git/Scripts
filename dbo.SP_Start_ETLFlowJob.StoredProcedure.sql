USE [ETLMD]
GO
/****** Object:  StoredProcedure [dbo].[SP_Start_ETLFlowJob]    Script Date: 04/24/2008 20:22:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SP_Start_ETLFlowJob]
@JOB_NAME VARCHAR(128),@CYCLE_START DATETIME,@CYCLE_END DATETIME,@STARTMODE VARCHAR(10)
-- 1. 康寧手動發動ETL Flow，依照使用者傳入的啟動日期、結束日期、模式發動ETL Flow，發動完成後，將數值改回預設值
AS

DECLARE @ID uniqueidentifier
DECLARE @STEP_ID INT
DECLARE @CMD nvarchar(1000)
EXECUTE AS LOGIN = 'sa'

SELECT @ID=S1.JOB_ID,@STEP_ID=STEP_ID,@JOB_NAME=LTRIM(RTRIM(@JOB_NAME)) 
FROM MSDB.DBO.SYSJOBS AS S1
JOIN MSDB.dbo.SYSJOBSTEPS  AS S2 ON S1.JOB_ID=S2.JOB_ID
WHERE S1.NAME=S2.STEP_NAME AND S1.NAME=@JOB_NAME
SET @CMD=N'/SQL "\JobControl\'+@JOB_NAME+'" /SERVER "TCTK1SQ34" /DECRYPT etl /MAXCONCURRENT " -1 " /CHECKPOINTING OFF '+
          '/SET "\Package.Variables[User::CycleStart].Properties[Value]";"'+CONVERT(char(19),@CYCLE_START,121)+'" '+
          '/SET "\Package.Variables[User::CycleEnd].Properties[Value]";"'+CONVERT(char(19),@CYCLE_END,121)+'" '+
          '/SET "\Package.Variables[User::StartMode].Properties[Value]";'+@STARTMODE+' /REPORTING E'

EXEC msdb.dbo.sp_update_jobstep @job_id=@ID, @step_id=@STEP_ID , 
		@command=@CMD

EXEC msdb.dbo.sp_start_job @job_name

WAITFOR DELAY '00:00:05'

SET @CMD=N'/SQL "\JobControl\'+@JOB_NAME+'" /SERVER "TCTK1SQ34" /DECRYPT etl /MAXCONCURRENT " -1 " /CHECKPOINTING OFF '+
          '/SET "\Package.Variables[User::CycleStart].Properties[Value]";"1900-01-01 00:00:00" '+
          '/SET "\Package.Variables[User::CycleEnd].Properties[Value]";"1900-01-01 00:00:00" '+
          '/SET "\Package.Variables[User::StartMode].Properties[Value]";NA /REPORTING E'

EXEC msdb.dbo.sp_update_jobstep @job_id=@ID, @step_id=@STEP_ID , 
		@command=@CMD
GO
