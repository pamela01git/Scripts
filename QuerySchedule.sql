SELECT S2.NAME,S1.NEXT_RUN_TIME,S1.next_run_date FROM MSDB.[dbo].[sysjobschedules] S1 INNER JOIN  MSDB.[dbo].[sysjobs] S2 ON (S2.job_id=S1.job_id)
WHERE S2.NAME LIKE 'Initial%' --and next_run_date in ('20120821','20120822','20120901')
order by 1