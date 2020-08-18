http://www.cnblogs.com/rock_chen/archive/2006/11/24/570795.html


--DROP TABLE #xp_results
declare	@job_id UNIQUEIDENTIFIER 
		, @is_sysadmin INT
		, @job_owner   sysname

	select @job_id = job_id from msdb..sysjobs_view where name  = 'Truncate_Log'
	select @is_sysadmin = ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0)
	select @job_owner = SUSER_SNAME()

	CREATE TABLE #xp_results (job_id                UNIQUEIDENTIFIER NOT NULL,
	                            last_run_date         INT              NOT NULL,
	                            last_run_time         INT              NOT NULL,
	                            next_run_date         INT              NOT NULL,
	                            next_run_time         INT              NOT NULL,
	                            next_run_schedule_id  INT              NOT NULL,
	                            requested_to_run      INT              NOT NULL, -- BOOL
	                            request_source        INT              NOT NULL,
	                            request_source_id     sysname          COLLATE database_default NULL,
	                            running               INT              NOT NULL, -- BOOL
	                            current_step          INT              NOT NULL,
	                            current_retry_attempt INT              NOT NULL,
	                            job_state             INT              NOT NULL)

  INSERT INTO #xp_results
		    EXECUTE master.dbo.xp_sqlagent_enum_jobs 1, 'SA', @job_id

select job_state from #xp_results WHERE JOB_STATE = 1
IF NOT EXISTS ( select job_state from #xp_results WHERE JOB_STATE = 1)
BEGIN
 EXEC SP_START_JOB 'Truncate_Log';
END

--查看Job是否在運行
Declare @Job_ID as UNIQUEIDENTIFIER
select @Job_ID =Job_ID from msdb.dbo.sysjobs where name = 'Jobname'
Exec master..sp_MSget_jobstate @Job_ID
--返回值? 1 - 正在?行
--            4 - 表示完成(成功或失?)

per the comments in the msdb.dbo.sp_get_composite_job_info sp the state values are defined as follows:
0 = Not idle or suspended, 
1 = Executing, 
2 = Waiting For Thread, 
3 = Between Retries, 
4 = Idle, 
5 = Suspended, 
6 = WaitingForStepToFinish, 
7 = PerformingCompletionActions  


