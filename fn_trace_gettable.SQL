Ever wanted to find out what was happening when SQL Server crashed? Your investigation should also include reviewing the SQL Server activities much like what profiler would do. SQL Server 2008 (Including SQL2K5) out of the box comes with a default trace enabled. This trace keeps track of configuration changes, process level information and other information that can be very helpful for troubleshooting SQL Server related issues.

The default trace file can be opened and examined by launching SQL Server Profiler and by loading the log.trc file from (\Program Files\Microsoft SQL Server\<Instance_Name>\MSSQL\Log\) location or by querying it with Transact-SQL using the fn_trace_gettable system function. 

Alternatively, you can query the trace file using the following T-SQL statement: 
SELECT * FROM fn_trace_gettable ('C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\Log\log.trc', default);
-- Make sure you point to the right drive instead of C:\ drive.

Note: By default this trace is on and can¡¦t be stopped by using the SP_Trace_SetStatus system stored procedure. Instead, you will need to stop the default trace by using SP_Configure option. *It is not a good idea to stop this trace. 
Some of the information provided by the default trace includes: 
Configuration change history
Schema Changes History
Memory Consumption
All Blocking Transactions
Top Sessions 
Top Queries by Average CPU time
Top Queries by Average IO, 
Etc. 

This data can also be accessed from the Admin reports (from SQL Server Management Studio right-click the registered server and select "Reports") 

Thank you,
Saleem Hakani
