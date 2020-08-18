USE [DMDB]
GO
/****** Object:  StoredProcedure [dmo].[SP_GEN_ReportDispatchJob_01]    Script Date: 11/30/2010 18:20:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dmo].[SP_GEN_ReportDispatchJob_01]
AS
------------------------------
-- COMMENT
------------------------------
-- Generate Schedule for Report Dispatch

---------------------------------------------------
-- PART 1: DECLARE VARIBLE
---------------------------------------------------

DECLARE @SCHEDULE_NAME VARCHAR(100)
DECLARE @SCHEDULE_TYPE VARCHAR(10)
DECLARE @START_TIME VARCHAR(10)
DECLARE @OCCUR VARCHAR(20)
DECLARE @AGENTJOBSQL VARCHAR(MAX)
DECLARE @freq_int INT
DECLARE @QT_ST INT
DECLARE @AGENTJOB NVARCHAR(150)

---------------------------------------------------
-- PART 2: Generate SQL Agent Job
---------------------------------------------------
EXECUTE AS LOGIN = 'sa'

---------------------------------------------------
-- PART 2-1: Job List
---------------------------------------------------
    DECLARE AgentJobCur CURSOR FOR     
       SELECT rtrim(Schedule_Name),rtrim(Schedule_Type),rtrim([Start_Time]),rtrim([Occur]) FROM dmo.MD_ReportSchedule
       WHERE ('ReportDispatch-'+ltrim(rtrim(Schedule_Name)) not in (SELECT NAME FROM msdb.dbo.sysjobs)
              OR CONVERT(CHAR(8),ModifyDt,112)=CONVERT(CHAR(8),GETDATE(),112)) --OR datediff(mi,ModifyDt,getdate())<=10)
       AND Schedule_Type IN ('Hour','Day','Month')
             
        OPEN AgentJobCur;    
        FETCH NEXT FROM AgentJobCur     
             INTO @Schedule_Name,@Schedule_Type,@Start_Time,@Occur


---------------------------------------------------
-- PART 2-1: Job's SQL Script
---------------------------------------------------                                   
        WHILE @@FETCH_STATUS = 0       
          BEGIN    
---------------------------------------------------
-- PART 2-1-1: SQL Agent Job 
---------------------------------------------------              
            SET @AGENTJOBSQL='
                              BEGIN TRANSACTION
                              DECLARE @ReturnCode INT
                              SELECT @ReturnCode = 0

                              IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N''[Uncategorized (Local)]'' AND category_class=1)
                                BEGIN
                                  EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N''JOB'', @type=N''LOCAL'', @name=N''[Uncategorized (Local)]''
                                  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
                                END

                                DECLARE @jobId BINARY(16)
                                EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N''ReportDispatch-'+@SCHEDULE_NAME+''', 
		                             @enabled=1, 
		                             @notify_level_eventlog=0, 
		                             @notify_level_email=0, 
		                             @notify_level_netsend=0, 
		                             @notify_level_page=0, 
		                             @delete_level=0, 
		                             @description=N''No description available.'', 
		                             @category_name=N''[Uncategorized (Local)]'', 
		                             @owner_login_name=N''MIDev'', @job_id = @jobId OUTPUT
                              IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
                              
                              EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N''ReportDispatch-'+@SCHEDULE_NAME+''', 
		                             @step_id=1, 
		                             @cmdexec_success_code=0, 
		                             @on_success_action=1, 
		                             @on_success_step_id=0, 
		                             @on_fail_action=2, 
		                             @on_fail_step_id=0, 
		                             @retry_attempts=0, 
		                             @retry_interval=0, 
		                             @os_run_priority=0, @subsystem=N''SSIS'', 
		                             @command=N''/SQL "\UTL\UTLReportDispatch" /SERVER "." /CHECKPOINTING OFF /SET "\Package.Variables[User::Schedule_Name].Properties[Value]";'+@SCHEDULE_NAME+' /REPORTING E'', 
		                             @database_name=N''master'', 
		                             @flags=0
                              IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
                              EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
                              IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback'
                              
---------------------------------------------------
-- PART 2-2-1: Daily Schedule
---------------------------------------------------
            IF @Schedule_Type ='Hour'
              BEGIN
                IF ISNUMERIC(@OCCUR)=1 BEGIN
                  SET @AGENTJOBSQL=@AGENTJOBSQL+'
                              EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N''ReportDispatch-Daily-'+@SCHEDULE_NAME+''', 
		                             @enabled=1, 
		                             @freq_type=4, 
		                             @freq_interval=1, 
		                             @freq_subday_type=8, 
		                             @freq_subday_interval='+@Occur+', 
		                             @freq_relative_interval=0, 
		                             @freq_recurrence_factor=0, 
		                             @active_start_date='+CONVERT(CHAR(8),GETDATE(),112)+', 
		                             @active_end_date=99991231, 
		                             @active_start_time='+REPLACE(RTRIM(@Start_Time),':','')+'00, 
		                             @active_end_time=235959, 
		                             @schedule_uid=N'''+CAST(NEWID() AS VARCHAR(100))+'''		                
                              IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback'              
                   END;           
              END      

---------------------------------------------------
-- PART 2-2-2: Weekly Schedule
---------------------------------------------------              
            IF @Schedule_Type ='Day'
              BEGIN
                SET @freq_int=CASE WHEN CHARINDEX('Mon',@Occur)>0 THEN 2 ELSE 0 END+
                              CASE WHEN CHARINDEX('Tus',@Occur)>0 THEN 4 ELSE 0 END+
                              CASE WHEN CHARINDEX('Wed',@Occur)>0 THEN 8 ELSE 0 END+
                              CASE WHEN CHARINDEX('Thu',@Occur)>0 THEN 16 ELSE 0 END+
                              CASE WHEN CHARINDEX('Fri',@Occur)>0 THEN 32 ELSE 0 END+
                              CASE WHEN CHARINDEX('Sat',@Occur)>0 THEN 64 ELSE 0 END+
                              CASE WHEN CHARINDEX('Sun',@Occur)>0 THEN 1 ELSE 0 END
                
                SET @AGENTJOBSQL=@AGENTJOBSQL+'
                              EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N''ReportDispatch-Weekly-'+@SCHEDULE_NAME+''', 
		                             @enabled=1, 
		                             @freq_type=8, 
		                             @freq_interval='+CAST(@FREQ_INT AS VARCHAR(3))+', 
		                             @freq_subday_type=1, 
		                             @freq_subday_interval=0, 
		                             @freq_relative_interval=0, 
		                             @freq_recurrence_factor=1, 
		                             @active_start_date='+CONVERT(CHAR(8),GETDATE(),112)+', 
		                             @active_end_date=99991231, 
		                             @active_start_time='+REPLACE(RTRIM(@Start_Time),':','')+'00, 
		                             @active_end_time=235959, 
		                             @schedule_uid=N'''+CAST(NEWID() AS VARCHAR(100))+'''		                
                              IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback'              
              END     
---------------------------------------------------
-- PART 2-2-3: Monthly Schedule
---------------------------------------------------                                        
            IF @Schedule_Type ='Month'
              BEGIN
                SET @QT_ST=1
                WHILE ISNULL(dbo.FN_Instr(@Occur,',',@QT_ST),'')<>''
                  BEGIN
                    SET @freq_int=CASE WHEN ISNUMERIC(dbo.FN_Instr(@Occur,',',@QT_ST))=1 THEN dbo.FN_Instr(@Occur,',',@QT_ST) ELSE 0 END
                    IF @freq_int BETWEEN 1 AND 31 BEGIN
                    SET @AGENTJOBSQL=@AGENTJOBSQL+'
                              EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N''ReportDispatch-Monthly-'+@SCHEDULE_NAME+'_'+CAST(@freq_int as varchar(2))+''', 
		                             @enabled=1, 
		                             @freq_type=16, 
		                             @freq_interval='+CAST(@freq_int as varchar(2))+', 
		                             @freq_subday_type=1, 
		                             @freq_subday_interval=0, 
		                             @freq_relative_interval=0, 
		                             @freq_recurrence_factor=1, 
		                             @active_start_date='+CONVERT(CHAR(8),GETDATE(),112)+', 
		                             @active_end_date=99991231, 
		                             @active_start_time='+REPLACE(RTRIM(@Start_Time),':','')+'00, 
		                             @active_end_time=235959, 
		                             @schedule_uid=N'''+CAST(NEWID() AS VARCHAR(100))+'''		                
                              IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback' END;   
                    SET @QT_ST=@QT_ST+1          
                  END                       
              END                               
           

                     
              SET @AGENTJOBSQL=@AGENTJOBSQL+'
                              EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N''(local)''
                              IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
                                COMMIT TRANSACTION
                              GOTO EndSave
                              QuitWithRollback:
                                IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
                              EndSave:'
              BEGIN TRY          
                IF EXISTS(SELECT * FROM msdb.dbo.SYSJOBS WHERE name='ReportDispatch-'+@SCHEDULE_NAME)
                  BEGIN
                    SET @AGENTJOB=N'ReportDispatch-'+cast(@SCHEDULE_NAME as nvarchar(100))
                    EXEC MSDB.dbo.sp_delete_job @job_name = @AGENTJOB
                  END  
                  EXEC (@AGENTJOBSQL)       
              END TRY
              BEGIN CATCH
                SELECT ERROR_MESSAGE()
              END CATCH  
            
            FETCH NEXT FROM AgentJobCur --NEXT
            INTO @Schedule_Name,@Schedule_Type,@Start_Time,@Occur
          END 

        CLOSE AgentJobCur;                                                                                                                          
        DEALLOCATE AgentJobCur;    



---------------------------------------------------
-- PART 3-1: Drop expire Agent Job
---------------------------------------------------
    DECLARE AgentJobDelCur CURSOR FOR     
       SELECT NAME FROM msdb.dbo.sysjobs AS S1
       WHERE NOT EXISTS(SELECT * FROM dmo.MD_ReportSchedule AS S2 WHERE S1.NAME='ReportDispatch-'+ltrim(rtrim(S2.Schedule_Name)))
       AND S1.NAME LIKE 'ReportDispatch%'
             
        OPEN AgentJobDelCur;    
        FETCH NEXT FROM AgentJobDelCur     
             INTO @Schedule_Name
        WHILE @@FETCH_STATUS = 0       
          BEGIN  
            EXEC MSDB.dbo.sp_delete_job @job_name = @Schedule_Name
            FETCH NEXT FROM AgentJobDelCur --NEXT
            INTO @Schedule_Name
          END 

        CLOSE AgentJobDelCur;                                                                                                                          
        DEALLOCATE AgentJobDelCur;    