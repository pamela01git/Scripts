USE msdb;
declare @job_id UNIQUEIDENTIFIER 
declare @status int


select @job_id = job_id from msdb..sysjobs_view where name  = 'BATCH01';
truncate table  master.dbo.xp_results;
INSERT INTO master.dbo.xp_results
EXECUTE master.dbo.xp_sqlagent_enum_jobs 1, 'SA', @job_id;
select @status = job_state from master.dbo.xp_results 

while @status = 1
 begin
    EXEC dbo.SP_STOP_JOB 'BATCH01';
    truncate table  master.dbo.xp_results;
    INSERT INTO master.dbo.xp_results
    EXECUTE master.dbo.xp_sqlagent_enum_jobs 1, 'SA', @job_id;
    select @status = job_state from master.dbo.xp_results 
 end
 
select @job_id = job_id from msdb..sysjobs_view where name  = 'BATCH02';
truncate table  master.dbo.xp_results;
INSERT INTO master.dbo.xp_results
EXECUTE master.dbo.xp_sqlagent_enum_jobs 1, 'SA', @job_id;
select @status = job_state from master.dbo.xp_results 

while @status = 1
 begin
    EXEC dbo.SP_STOP_JOB 'BATCH02';
    truncate table  master.dbo.xp_results;
    INSERT INTO master.dbo.xp_results
    EXECUTE master.dbo.xp_sqlagent_enum_jobs 1, 'SA', @job_id;
    select @status = job_state from master.dbo.xp_results 
 end
 
select @job_id = job_id from msdb..sysjobs_view where name  = 'BATCH03';
truncate table  master.dbo.xp_results;
INSERT INTO master.dbo.xp_results
EXECUTE master.dbo.xp_sqlagent_enum_jobs 1, 'SA', @job_id;
select @status = job_state from master.dbo.xp_results 

while @status = 1
 begin
    EXEC dbo.SP_STOP_JOB 'BATCH03';
    truncate table  master.dbo.xp_results;
    INSERT INTO master.dbo.xp_results
    EXECUTE master.dbo.xp_sqlagent_enum_jobs 1, 'SA', @job_id;
    select @status = job_state from master.dbo.xp_results 
 end  


select @job_id = job_id from msdb..sysjobs_view where name  = 'BATCH04';
truncate table  master.dbo.xp_results;
INSERT INTO master.dbo.xp_results
EXECUTE master.dbo.xp_sqlagent_enum_jobs 1, 'SA', @job_id;
select @status = job_state from master.dbo.xp_results 

while @status = 1
 begin
    EXEC dbo.SP_STOP_JOB 'BATCH04';
    truncate table  master.dbo.xp_results;
    INSERT INTO master.dbo.xp_results
    EXECUTE master.dbo.xp_sqlagent_enum_jobs 1, 'SA', @job_id;
    select @status = job_state from master.dbo.xp_results 
 end
 
 select @job_id = job_id from msdb..sysjobs_view where name  = 'BATCH05';
truncate table  master.dbo.xp_results;
INSERT INTO master.dbo.xp_results
EXECUTE master.dbo.xp_sqlagent_enum_jobs 1, 'SA', @job_id;
select @status = job_state from master.dbo.xp_results 

while @status = 1
 begin
    EXEC dbo.SP_STOP_JOB 'BATCH05';
    truncate table  master.dbo.xp_results;
    INSERT INTO master.dbo.xp_results
    EXECUTE master.dbo.xp_sqlagent_enum_jobs 1, 'SA', @job_id;
    select @status = job_state from master.dbo.xp_results 
 end
 
 select @job_id = job_id from msdb..sysjobs_view where name  = 'BATCH06';
truncate table  master.dbo.xp_results;
INSERT INTO master.dbo.xp_results
EXECUTE master.dbo.xp_sqlagent_enum_jobs 1, 'SA', @job_id;
select @status = job_state from master.dbo.xp_results 

while @status = 1
 begin
    EXEC dbo.SP_STOP_JOB 'BATCH06';
    truncate table  master.dbo.xp_results;
    INSERT INTO master.dbo.xp_results
    EXECUTE master.dbo.xp_sqlagent_enum_jobs 1, 'SA', @job_id;
    select @status = job_state from master.dbo.xp_results 
 end

select @job_id = job_id from msdb..sysjobs_view where name  = 'BATCH07';
truncate table  master.dbo.xp_results;
INSERT INTO master.dbo.xp_results
EXECUTE master.dbo.xp_sqlagent_enum_jobs 1, 'SA', @job_id;
select @status = job_state from master.dbo.xp_results 

while @status = 1
 begin
    EXEC dbo.SP_STOP_JOB 'BATCH07';
    truncate table  master.dbo.xp_results;
    INSERT INTO master.dbo.xp_results
    EXECUTE master.dbo.xp_sqlagent_enum_jobs 1, 'SA', @job_id;
    select @status = job_state from master.dbo.xp_results 
 end
 
 select @job_id = job_id from msdb..sysjobs_view where name  = 'BATCH08';
truncate table  master.dbo.xp_results;
INSERT INTO master.dbo.xp_results
EXECUTE master.dbo.xp_sqlagent_enum_jobs 1, 'SA', @job_id;
select @status = job_state from master.dbo.xp_results 

while @status = 1
 begin
    EXEC dbo.SP_STOP_JOB 'BATCH08';
    truncate table  master.dbo.xp_results;
    INSERT INTO master.dbo.xp_results
    EXECUTE master.dbo.xp_sqlagent_enum_jobs 1, 'SA', @job_id;
    select @status = job_state from master.dbo.xp_results 
 end
 
 select @job_id = job_id from msdb..sysjobs_view where name  = 'BATCH09';
truncate table  master.dbo.xp_results;
INSERT INTO master.dbo.xp_results
EXECUTE master.dbo.xp_sqlagent_enum_jobs 1, 'SA', @job_id;
select @status = job_state from master.dbo.xp_results 

while @status = 1
 begin
    EXEC dbo.SP_STOP_JOB 'BATCH09';
    truncate table  master.dbo.xp_results;
    INSERT INTO master.dbo.xp_results
    EXECUTE master.dbo.xp_sqlagent_enum_jobs 1, 'SA', @job_id;
    select @status = job_state from master.dbo.xp_results 
 end
 
select @job_id = job_id from msdb..sysjobs_view where name  = 'BATCH10';
truncate table  master.dbo.xp_results;
INSERT INTO master.dbo.xp_results
EXECUTE master.dbo.xp_sqlagent_enum_jobs 1, 'SA', @job_id;
select @status = job_state from master.dbo.xp_results 

while @status = 1
 begin
    EXEC dbo.SP_STOP_JOB 'BATCH10';
    truncate table  master.dbo.xp_results;
    INSERT INTO master.dbo.xp_results
    EXECUTE master.dbo.xp_sqlagent_enum_jobs 1, 'SA', @job_id;
    select @status = job_state from master.dbo.xp_results 
 end



EXEC dbo.sp_start_job 'BATCH01'
EXEC dbo.sp_start_job 'BATCH02'
EXEC dbo.sp_start_job 'BATCH03'
EXEC dbo.sp_start_job 'BATCH04'
EXEC dbo.sp_start_job 'BATCH05'
EXEC dbo.sp_start_job 'BATCH06'
EXEC dbo.sp_start_job 'BATCH07'
EXEC dbo.sp_start_job 'BATCH08'
EXEC dbo.sp_start_job 'BATCH09'
EXEC dbo.sp_start_job 'BATCH10'