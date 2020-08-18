
declare @systime datetime = getdate()

;with CTE_LOCK_SRC as
(select  @systime as systime,t2.wait_duration_ms,t1.resource_type
	,db_name(resource_database_id) as [database]
	,t1.resource_associated_entity_id as [blk object]
	,t1.request_mode
    ,waiter.hostname as waiter_hostname
    ,waiter.program_name as waiter_program_name
    ,waiter.loginame as waiter_loginame	
	,t1.request_session_id   -- spid of waiter
	,(select text from sys.dm_exec_requests as r  --- get sql for waiter
		cross apply sys.dm_exec_sql_text(r.sql_handle) where r.session_id = t1.request_session_id) as waiter_text
    ,blocker.hostname as blocker_hostname
    ,blocker.program_name as blocker_program_name
    ,blocker.loginame as blocker_loginame		
	,t2.blocking_session_id  -- spid of blocker
     ,(select text from sys.sysprocesses as p		--- get sql for blocker
		cross apply sys.dm_exec_sql_text(p.sql_handle) where p.spid = t2.blocking_session_id) as blocker_text
	from 
	sys.dm_tran_locks as t1, 
	sys.dm_os_waiting_tasks as t2,
	sys.sysprocesses as waiter,
	sys.sysprocesses as blocker	
where 
	t1.lock_owner_address = t2.resource_address
  and t1.request_session_id = waiter.spid
  and t2.blocking_session_id = blocker.spid
  and t1.resource_type not in  ('DATABASE','FILE')
) ,
CTE_LOCK_AGG as
(
SELECT S1.*,S2.blocking_session_id AS parent_session_id FROM CTE_LOCK_SRC S1 LEFT JOIN CTE_LOCK_SRC S2 ON (S1.blocking_session_id=S2.request_session_id)
)

insert into dbo.Tbl_LockInfo 
select systime, wait_duration_ms, resource_type, [database], waiter_hostname, waiter_program_name, waiter_loginame, [blk object], request_mode, request_session_id, waiter_text, blocker_hostname, blocker_program_name, blocker_loginame, blocking_session_id, blocker_text,parent_session_id
FROM CTE_LOCK_AGG
WHERE  [database]= 'SiebelDB'

---------------------------------------------------
-- STEP 2: Del Expired Log
---------------------------------------------------

DECLARE @KILL_SPID CHAR(5)
       ,@KILL_CMD NVARCHAR(MAX)
       ,@KILL_FLAG CHAR(1) = 'N'
       
DECLARE ExceptionInfo CURSOR LOCAL FOR
select blocking_session_id
from dbo.Tbl_LockInfo
where [database] = 'SiebelDB' and wait_duration_ms >  600000 and systime= @systime and parent_session_id is null
		      
 OPEN ExceptionInfo;
   FETCH NEXT FROM  ExceptionInfo
     INTO @KILL_SPID
	 WHILE @@FETCH_STATUS = 0 
	   BEGIN
	   
	     SET @KILL_CMD = 'KILL '+RTRIM(@KILL_SPID)
         EXEC (@KILL_CMD)
         SET @KILL_FLAG= 'Y'

         FETCH NEXT FROM ExceptionInfo
           INTO @KILL_SPID
	   END 
  CLOSE ExceptionInfo;                                                                                                                     
 DEALLOCATE ExceptionInfo;

 IF @KILL_FLAG= 'Y' RAISERROR('Kill one bloacked session which exection time more than 10 mins',16,1); 

