SELECT  CONVERT (varchar(30), GETDATE(), 121) as runtime, DATEADD (ms, a.[Record Time] - sys.ms_ticks, GETDATE()) AS Notification_time,    a.* , sys.ms_ticks AS [Current Time]  
FROM   (SELECT x.value('(//Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') AS [ProcessUtilization],    
x.value('(//Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') AS [SystemIdle %],   
x.value('(//Record/SchedulerMonitorEvent/SystemHealth/UserModeTime) [1]', 'bigint') AS [UserModeTime],   
x.value('(//Record/SchedulerMonitorEvent/SystemHealth/KernelModeTime) [1]', 'bigint') AS [KernelModeTime],    
x.value('(//Record/SchedulerMonitorEvent/SystemHealth/PageFaults) [1]', 'bigint') AS [PageFaults],   
x.value('(//Record/SchedulerMonitorEvent/SystemHealth/WorkingSetDelta) [1]', 'bigint')/1024 AS [WorkingSetDelta],   
x.value('(//Record/SchedulerMonitorEvent/SystemHealth/MemoryUtilization) [1]', 'bigint') AS [MemoryUtilization (%workingset)],   
x.value('(//Record/@time)[1]', 'bigint') AS [Record Time]  FROM (SELECT CAST (record as xml) FROM sys.dm_os_ring_buffers    
WHERE ring_buffer_type = 'RING_BUFFER_SCHEDULER_MONITOR') AS R(x)) a  CROSS JOIN sys.dm_os_sys_info sys 
ORDER BY DATEADD (ms, a.[Record Time] - sys.ms_ticks, GETDATE())