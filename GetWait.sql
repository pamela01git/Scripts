SELECT OSW.session_id,
       OSW.wait_duration_ms,
       OSW.wait_type,
       DB_NAME(EXR.database_id) AS DatabaseName
FROM sys.dm_os_waiting_tasks OSW
INNER JOIN sys.dm_exec_sessions EXS ON OSW.session_id = EXS.session_id
INNER JOIN  sys.dm_exec_requests EXR ON EXR.session_id = OSW.session_id
OPTION(Recompile);
   