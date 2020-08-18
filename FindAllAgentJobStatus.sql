if object_id('tempdb..#xp_results') > 0 drop table #xp_results

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

declare @job_id as uniqueidentifier
     ,@name as varchar(max)
     ,@sid sysname

Declare AgentList cursor local for
select job_id,name,SUSER_SNAME(owner_sid) from msdb..sysjobs_view 

open AgentList
fetch next from AgentList
into @job_id,@name,@sid

while @@FETCH_STATUS = 0
 begin
 
  INSERT INTO #xp_results
  EXECUTE master.dbo.xp_sqlagent_enum_jobs 1, @sid, @job_id
 
  fetch next from AgentList
  into  @job_id,@name,@sid
 end
 close AgentList
 deallocate AgentList

select s2.name,case when s1.job_state= 1 then 'Running' when s1.job_state=4 then 'Completed' end,* from #xp_results s1
   inner join msdb..sysjobs_view  s2 on (s2.job_id=s1.job_id)
where s2.name='Maintenance plan_mirrorbackup_GCC_EBC_DB.Subplan 1'