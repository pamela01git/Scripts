-- 指令碼產生於 2005/9/14 上午 11:38
-- 由: SCR00ETD01\Administrator
-- 伺服器: (LOCAL)

BEGIN TRANSACTION            
  DECLARE @JobID BINARY(16)  
  DECLARE @ReturnCode INT    
  SELECT @ReturnCode = 0     
IF (SELECT COUNT(*) FROM msdb.dbo.syscategories WHERE name = N'Report Server') < 1 
  EXECUTE msdb.dbo.sp_add_category @name = N'Report Server'

  -- 刪除相同名稱作業 (如果作業存在)
  SELECT @JobID = job_id     
  FROM   msdb.dbo.sysjobs    
  WHERE (name = N'4BE8F10E-CC09-4594-B0EF-0F97699217AE')       
  IF (@JobID IS NOT NULL)    
  BEGIN  
  -- 檢查作業是否是為多重伺服器的作業  
  IF (EXISTS (SELECT  * 
              FROM    msdb.dbo.sysjobservers 
              WHERE   (job_id = @JobID) AND (server_id <> 0))) 
  BEGIN 
    -- 有，所以中斷指令碼 
    RAISERROR (N'無法匯入作業 '4BE8F10E-CC09-4594-B0EF-0F97699217AE'，因為多重伺服器已經有這個名稱。', 16, 1) 
    GOTO QuitWithRollback  
  END 
  ELSE 
    -- 刪除 [本機] 作業 
    EXECUTE msdb.dbo.sp_delete_job @job_name = N'4BE8F10E-CC09-4594-B0EF-0F97699217AE' 
    SELECT @JobID = NULL
  END 

BEGIN 

  -- 新增作業
  EXECUTE @ReturnCode = msdb.dbo.sp_add_job @job_id = @JobID OUTPUT , @job_name = N'4BE8F10E-CC09-4594-B0EF-0F97699217AE', @owner_login_name = N'odsdba', @description = N'此為 Reporting Services 作業。修改此作業會造成資料庫不相容。請使用報表伺服器 UI 更新此作業。', @category_name = N'Report Server', @enabled = 1, @notify_level_email = 0, @notify_level_page = 0, @notify_level_netsend = 0, @notify_level_eventlog = 2, @delete_level= 0
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- 新增作業步驟
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 1, @step_name = N'4BE8F10E-CC09-4594-B0EF-0F97699217AE_step_1', @command = N'exec ReportServer.dbo.AddEvent @EventType=''ReportExecutionUpdateSchedule'', @EventData=''2cc964e0-3615-45f0-9cc3-ccdf9152aa18''', @database_name = N'master', @server = N'', @database_user_name = N'', @subsystem = N'TSQL', @cmdexec_success_code = 0, @flags = 0, @retry_attempts = 0, @retry_interval = 0, @output_file_name = N'', @on_success_step_id = 0, @on_success_action = 1, @on_fail_step_id = 0, @on_fail_action = 2
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  EXECUTE @ReturnCode = msdb.dbo.sp_update_job @job_id = @JobID, @start_step_id = 1 

  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- 新增作業排程
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id = @JobID, @name = N'Schedule_1', @enabled = 1, @freq_type = 16, @active_start_date = 20050915, @active_start_time = 20000, @freq_interval = 10, @freq_subday_type = 1, @freq_subday_interval = 0, @freq_relative_interval = 0, @freq_recurrence_factor = 1, @active_end_date = 99991231, @active_end_time = 235959
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- 新增目標伺服器
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @JobID, @server_name = N'(local)' 
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

END
COMMIT TRANSACTION          
GOTO   EndSave              
QuitWithRollback:
  IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION 
EndSave: 


