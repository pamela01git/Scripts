SELECT   
 O.name,  
 PS.last_execution_time  
FROM   
 sys.dm_exec_procedure_stats PS   
INNER JOIN sys.objects O   
 ON O.[object_id] = PS.[object_id]   
WHERE OBJECT_ID('usp_ESB_Query8') = ps.object_id

https://www.simple-talk.com/sql/performance/which-of-your-stored-procedures-are-using-the-most-resources/