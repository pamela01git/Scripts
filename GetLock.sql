IF OBJECT_ID('TEMPDB..#lock') IS NOT NULL
  BEGIN DROP TABLE #lock END;
IF OBJECT_ID('TEMPDB..#cte') IS NOT NULL
  BEGIN DROP TABLE #cte END;
IF OBJECT_ID('TEMPDB..#result') IS NOT NULL
  BEGIN DROP TABLE #result END;
IF OBJECT_ID('TEMPDB..#tmp1') IS NOT NULL
  BEGIN DROP TABLE #tmp1 END;

--Step1:All Session
SELECT    getdate() systime,  r.scheduler_id as 排程器識別碼,   
            r.status         as 要求的狀態,   
         r.session_id   as SPID,   
          r.blocking_session_id as BlkBy,   
          substring(   
              ltrim(q.text),   
             r.statement_start_offset/2+1,   
               (CASE  
               WHEN r.statement_end_offset = -1   
                THEN LEN(CONVERT(nvarchar(MAX), q.text)) * 2   
               ELSE r.statement_end_offset   
               END - r.statement_start_offset)/2)   
               AS [正在執行的 T-SQL 命令],   
           r.cpu_time      as [CPU Time(ms)],   
          r.start_time    as [開始時間],   
           r.total_elapsed_time as [執行總時間],   
           r.reads              as [讀取數],   
           r.writes             as [寫入數],   
           r.logical_reads      as [邏輯讀取數],   
         
         d.name               as [資料庫名稱]
     ,s2.lastwaittype,s2.cmd,s2.loginame,s2.hostname,s2.program_name
	 --,	 F.*  
into #tmp1
FROM        sys.dm_exec_requests r    with (nolock)
           CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS q   
          LEFT JOIN sys.databases d with (nolock) ON (r.database_id=d.database_id)   
		  left join sys.sysprocesses s2 on (s2.spid=r.session_id  and blocked >0)
		  --	  cross apply sys.dm_exec_query_plan(plan_handle)F
WHERE       r.session_id > 50 AND r.session_id <> @@SPID   



--Step2:Get Block Session
SELECT    SPID,    BlkBy 
into #lock
FROM        #tmp1  
WHERE    BlkBy >0 
 and spid  in ( SELECT distinct   BlkBy  FROM  #tmp1 WHERE   BlkBy >0)

 
--Step3:Get Block Session
;WITH cte (spid,blkby,lvl,sort) as
(
	select spid,  0 as bid ,0 as lvl,convert(varchar(max),spid)as sort
	 from (
	 select distinct blkby as spid
	 from #lock
     where blkby not in (select spid from #lock)) a

	  UNION ALL 

	  select e.spid, convert(int,e.blkby) as bid,cte.lvl+1 as lvl,
	  cte.sort+' => '+convert(varchar(max),e.spid) as sort
	  from #lock e inner join cte on (e.blkby=cte.spid)
)

--Step4:Convert CTE table to temp table
select * into #cte from cte

--Step5:Final Result
SELECT    r.spid,r.systime,r.BlkBy,case when charindex('=>',sort,0) = 0 then 0 else substring(sort,1,charindex('=>',sort,0)-1) end as parent_blocked
        ,cte.sort,r.資料庫名稱 as DB_Name
,r.lastwaittype,r.loginame,r.hostname,r.program_name,r.[正在執行的 T-SQL 命令] as [RunningCmd]
FROM    #tmp1 as r left join   #cte cte on (cte.spid=r.spid)
where lvl is not null
order by r.spid

--Step7:  Blocking count
 select s1.*,s2.cnt from #cte s1
 inner join  (
 select case when charindex('=>',sort,0) = 0 then sort else substring(sort,1,charindex('=>',sort,0)-1) end spid,count(1) cnt
 from #cte s1
 group by case when charindex('=>',sort,0) = 0 then sort else substring(sort,1,charindex('=>',sort,0)-1) end
 ) s2 on (s2.spid=s1.spid /*and s1.lvl=0*/)

 --Step8:  Dead Lock
   select s1.*,s2.cnt from #cte s1
 inner join  (
 select case when charindex('=>',sort,0) = 0 then sort else substring(sort,1,charindex('=>',sort,0)-1) end spid,count(1) cnt
 from #cte s1
 group by case when charindex('=>',sort,0) = 0 then sort else substring(sort,1,charindex('=>',sort,0)-1) end
 ) s2 on (s2.spid=s1.spid /*and s1.lvl=0*/)
 WHERE S1.LVL >0


---- Notice the MAXRECURSION option is removed
--SELECT * 
--FROM cte
--order by 1

----select * from cte where bid=0

--select * from #cte






 select s1.* 
 from #lock s1






--select * from #cte

--select datediff(second,s1.開始時間,GETDATE()),s1.*,s2.lastwaittype,s2.cmd,s2.loginame,s2.hostname,s2.program_name
--from #result s1
--left join sys.sysprocesses s2 on (s2.spid=s1.SPID)

--where lvl is not null
--order by s1.spid

select * from #tmp1
order by spid

