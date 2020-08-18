USE [master]
GO

/****** Object:  View [dbo].[View_All_Job_Status]    Script Date: 02/01/2012 20:40:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[View_All_Job_Status] as SELECT 'SQL01' AS Server,case when stepname = '(作業結果)' then 'Batch' else 'Step' end JobType ,JOBNAME,StepName,convert(datetime,rundate+' '+runTime)  as JobStartTime ,DATeadd(SECOND,StepDuration,rundate+' '+runTime) as JobEndTime,StepDuration/60 as StepDuration ,ExecutionStatus from ( SELECT j.name JobName,h.step_name StepName, 

CONVERT(CHAR(10), CAST(STR(h.run_date,8, 0) AS dateTIME), 111) RunDate, 

STUFF(STUFF(RIGHT('000000' + CAST ( h.run_time AS VARCHAR(6 ) ) ,6),5,0,':'),3,0,':') RunTime, 

((h.run_duration/1000000)*86400) 
+ (((h.run_duration-((h.run_duration/1000000)*1000000))/10000)*3600)
+ (((h.run_duration-((h.run_duration/10000)*10000))/100)*60)
+ (h.run_duration-(h.run_duration/100)*100) StepDuration,
h.run_duration StepDuration1,
case h.run_status when 0 then 'failed'

when 1 then 'Succeded' 

when 2 then 'Retry' 

when 3 then 'Cancelled' 

when 4 then 'In Progress' 

end as ExecutionStatus, 

h.message MessageGenerated

FROM MSDB.DBO.sysjobhistory h inner join MSDB.DBO.sysjobs j

ON j.job_id = h.job_id where j.name like 'BATCH%' ) a UNION ALL SELECT 'SQL02' AS Server,case when stepname = '(作業結果)' then 'Batch' else 'Step' end JobType ,JOBNAME,StepName,convert(datetime,rundate+' '+runTime)  as JobStartTime ,DATeadd(SECOND,StepDuration,rundate+' '+runTime) as JobEndTime,StepDuration/60 as StepDuration ,ExecutionStatus from ( SELECT j.name JobName,h.step_name StepName, 

CONVERT(CHAR(10), CAST(STR(h.run_date,8, 0) AS dateTIME), 111) RunDate, 

STUFF(STUFF(RIGHT('000000' + CAST ( h.run_time AS VARCHAR(6 ) ) ,6),5,0,':'),3,0,':') RunTime, 

((h.run_duration/1000000)*86400) 
+ (((h.run_duration-((h.run_duration/1000000)*1000000))/10000)*3600)
+ (((h.run_duration-((h.run_duration/10000)*10000))/100)*60)
+ (h.run_duration-(h.run_duration/100)*100) StepDuration,
h.run_duration StepDuration1,
case h.run_status when 0 then 'failed'

when 1 then 'Succeded' 

when 2 then 'Retry' 

when 3 then 'Cancelled' 

when 4 then 'In Progress' 

end as ExecutionStatus, 

h.message MessageGenerated

FROM [10.150.100.2].MSDB.DBO.sysjobhistory h inner join [10.150.100.2].MSDB.DBO.sysjobs j

ON j.job_id = h.job_id where j.name like 'BATCH%' ) a UNION ALL SELECT 'SQL03' AS Server,case when stepname = '(作業結果)' then 'Batch' else 'Step' end JobType ,JOBNAME,StepName,convert(datetime,rundate+' '+runTime)  as JobStartTime ,DATeadd(SECOND,StepDuration,rundate+' '+runTime) as JobEndTime,StepDuration/60 as StepDuration ,ExecutionStatus from ( SELECT j.name JobName,h.step_name StepName, 

CONVERT(CHAR(10), CAST(STR(h.run_date,8, 0) AS dateTIME), 111) RunDate, 

STUFF(STUFF(RIGHT('000000' + CAST ( h.run_time AS VARCHAR(6 ) ) ,6),5,0,':'),3,0,':') RunTime, 

((h.run_duration/1000000)*86400) 
+ (((h.run_duration-((h.run_duration/1000000)*1000000))/10000)*3600)
+ (((h.run_duration-((h.run_duration/10000)*10000))/100)*60)
+ (h.run_duration-(h.run_duration/100)*100) StepDuration,
h.run_duration StepDuration1,
case h.run_status when 0 then 'failed'

when 1 then 'Succeded' 

when 2 then 'Retry' 

when 3 then 'Cancelled' 

when 4 then 'In Progress' 

end as ExecutionStatus, 

h.message MessageGenerated

FROM [10.150.100.3].MSDB.DBO.sysjobhistory h inner join [10.150.100.3].MSDB.DBO.sysjobs j

ON j.job_id = h.job_id where j.name like 'BATCH%' ) a UNION ALL SELECT 'SQL05' AS Server,case when stepname = '(作業結果)' then 'Batch' else 'Step' end JobType ,JOBNAME,StepName,convert(datetime,rundate+' '+runTime)  as JobStartTime ,DATeadd(SECOND,StepDuration,rundate+' '+runTime) as JobEndTime,StepDuration/60 as StepDuration ,ExecutionStatus from ( SELECT j.name JobName,h.step_name StepName, 

CONVERT(CHAR(10), CAST(STR(h.run_date,8, 0) AS dateTIME), 111) RunDate, 

STUFF(STUFF(RIGHT('000000' + CAST ( h.run_time AS VARCHAR(6 ) ) ,6),5,0,':'),3,0,':') RunTime, 

((h.run_duration/1000000)*86400) 
+ (((h.run_duration-((h.run_duration/1000000)*1000000))/10000)*3600)
+ (((h.run_duration-((h.run_duration/10000)*10000))/100)*60)
+ (h.run_duration-(h.run_duration/100)*100) StepDuration,
h.run_duration StepDuration1,
case h.run_status when 0 then 'failed'

when 1 then 'Succeded' 

when 2 then 'Retry' 

when 3 then 'Cancelled' 

when 4 then 'In Progress' 

end as ExecutionStatus, 

h.message MessageGenerated

FROM [10.150.100.5].MSDB.DBO.sysjobhistory h inner join [10.150.100.5].MSDB.DBO.sysjobs j

ON j.job_id = h.job_id where j.name like 'BATCH%' ) a UNION ALL SELECT 'SQL06' AS Server,case when stepname = '(作業結果)' then 'Batch' else 'Step' end JobType ,JOBNAME,StepName,convert(datetime,rundate+' '+runTime)  as JobStartTime ,DATeadd(SECOND,StepDuration,rundate+' '+runTime) as JobEndTime,StepDuration/60 as StepDuration ,ExecutionStatus from ( SELECT j.name JobName,h.step_name StepName, 

CONVERT(CHAR(10), CAST(STR(h.run_date,8, 0) AS dateTIME), 111) RunDate, 

STUFF(STUFF(RIGHT('000000' + CAST ( h.run_time AS VARCHAR(6 ) ) ,6),5,0,':'),3,0,':') RunTime, 

((h.run_duration/1000000)*86400) 
+ (((h.run_duration-((h.run_duration/1000000)*1000000))/10000)*3600)
+ (((h.run_duration-((h.run_duration/10000)*10000))/100)*60)
+ (h.run_duration-(h.run_duration/100)*100) StepDuration,
h.run_duration StepDuration1,
case h.run_status when 0 then 'failed'

when 1 then 'Succeded' 

when 2 then 'Retry' 

when 3 then 'Cancelled' 

when 4 then 'In Progress' 

end as ExecutionStatus, 

h.message MessageGenerated

FROM [10.150.100.6].MSDB.DBO.sysjobhistory h inner join [10.150.100.6].MSDB.DBO.sysjobs j

ON j.job_id = h.job_id where j.name like 'BATCH%' ) a UNION ALL SELECT 'SQL07' AS Server,case when stepname = '(作業結果)' then 'Batch' else 'Step' end JobType ,JOBNAME,StepName,convert(datetime,rundate+' '+runTime)  as JobStartTime ,DATeadd(SECOND,StepDuration,rundate+' '+runTime) as JobEndTime,StepDuration/60 as StepDuration ,ExecutionStatus from ( SELECT j.name JobName,h.step_name StepName, 

CONVERT(CHAR(10), CAST(STR(h.run_date,8, 0) AS dateTIME), 111) RunDate, 

STUFF(STUFF(RIGHT('000000' + CAST ( h.run_time AS VARCHAR(6 ) ) ,6),5,0,':'),3,0,':') RunTime, 

((h.run_duration/1000000)*86400) 
+ (((h.run_duration-((h.run_duration/1000000)*1000000))/10000)*3600)
+ (((h.run_duration-((h.run_duration/10000)*10000))/100)*60)
+ (h.run_duration-(h.run_duration/100)*100) StepDuration,
h.run_duration StepDuration1,
case h.run_status when 0 then 'failed'

when 1 then 'Succeded' 

when 2 then 'Retry' 

when 3 then 'Cancelled' 

when 4 then 'In Progress' 

end as ExecutionStatus, 

h.message MessageGenerated

FROM [10.150.100.7].MSDB.DBO.sysjobhistory h inner join [10.150.100.7].MSDB.DBO.sysjobs j

ON j.job_id = h.job_id where j.name like 'BATCH%' ) a

GO



per the comments in the msdb.dbo.sp_get_composite_job_info sp the state values are defined as follows:
0 = Not idle or suspended, 
1 = Executing, 
2 = Waiting For Thread, 
3 = Between Retries, 
4 = Idle, 
5 = Suspended, 
6 = WaitingForStepToFinish, 
7 = PerformingCompletionActions
