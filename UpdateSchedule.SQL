 
  DECLARE @JobID BINARY(16)
  
  SELECT @JobID = job_id     
  FROM   msdb.dbo.sysjobs    
  WHERE (name = N'4BE8F10E-CC09-4594-B0EF-0F97699217AE')  --

EXEC msdb.dbo.sp_add_jobschedule
  @job_id = @JobID
, @name = N'Schedule_1'
, @enabled = 1
, @freq_type = 16
, @active_start_date = 20050915
, @active_start_time = 20000
, @freq_interval = 10
, @freq_subday_type = 1
, @freq_subday_interval = 0
, @freq_relative_interval = 0
, @freq_recurrence_factor = 1
, @active_end_date = 99991231
, @active_end_time = 235959

EXEC msdb.dbo.sp_update_jobschedule
  @job_id = @JobID
, @name = N'Schedule_1'
, @enabled = 0
, @freq_type = 16
, @active_start_date = 20051112
, @active_start_time = 5200
, @freq_interval = 13
, @freq_subday_type = 1
, @freq_subday_interval = 0
, @freq_relative_interval = 0
, @freq_recurrence_factor = 1
, @active_end_date = 99991231
, @active_end_time = 235959


  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id = @JobID, @name = N'Schedule_1', @enabled = 0, @freq_type = 16,
   @active_start_date = 20051112, @active_start_time = 5200, @freq_interval = 1, @freq_subday_type = 1,
    @freq_subday_interval = 0, @freq_relative_interval = 0, @freq_recurrence_factor = 1, @active_end_date = 20051126, @active_end_time = 235959
    
    
    
       DECLARE @JobID BINARY(16)
   SELECT @JobID = job_id 
--select *    
  FROM   msdb.dbo.sysjobs    
  WHERE (name = N'964259B6-41C6-415D-B95E-DEF3823B9B12')


EXEC  msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Schedule_1', 
		@enabled=1, 
		@freq_type=16, 
		@freq_interval=21, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20051121, 
		@active_end_date=99991231, 
		@active_start_time=215800, 
		@active_end_time=235959
		
--直接發動job		
USE msdb ;
GO

EXEC dbo.sp_start_job N'Weekly Sales Data Backup' ;
GO

