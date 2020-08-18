 SELECT TOP 50   getdate() as runtime, 





                      





                        qs.total_worker_time as TotalCPU, 





                        qs.total_physical_reads as PhysicalReads, 





                        qs.total_logical_reads as LogicalReads, 





                        qs.total_logical_writes as LogicalWrites, 





                        qs.total_elapsed_time as Duration, 





                        qs.total_worker_time/qs.execution_count as [Avg CPU Time], 





                                    substring (qt.text,qs.statement_start_offset/2,(case when qs.statement_end_offset = -1 then len (convert (nvarchar(max), qt.text)) * 2 




                                    else qs.statement_end_offset end - qs.statement_start_offset)/2) as query_text, 





                        qt.dbid as DBID, 





                        qt.objectid as OBJECT_ID, 





                                    cast ( query_plan as xml) as XMLPlan 

									, qs.total_worker_time
									,QS.last_execution_time
									 , qs.Execution_count as Executions

      FROM sys.dm_exec_query_stats qs 




      cross apply sys.dm_exec_sql_text(qs.sql_handle) as qt 




      CROSS APPLY sys.dm_exec_query_plan(plan_handle) 





    --  ORDER BY TotalCPU DESC 

	ORDER BY [Avg CPU Time] DESC













