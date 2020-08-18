您提供及測試的方法2可以讓執行的 T-SQL 語法固定、長度不變，且可以明確的傳入參數的型態及長度，如同 SP_EXECUTESQL的效果一般，且網路傳輸的數量也降低非常多，這是非常好的作法！因此可以進一步確認一下，是否可以讓 AD_HOC語法不需重新編譯。

建議可以在UAT環境上模擬Production的Execution 次數進行壓測，可以觀察看看是否總執行時間及平均執行時間是否有減少。只要一個語法少 1ms，在同時大量執行語法的整體CPU時間就會改善。

另外，如果要看執行計畫是否不需要編譯就可以重用，可以使用以下的語法察看。如果特定語法的執行計畫的 Execution Count 都是 1，代表沒有重用，每次都需要重新編譯。



select 
 bucketid,
a.plan_handle,
refcounts, 
 usecounts,
execution_count,
size_in_bytes,
cacheobjtype,
objtype,
text,
query_plan,
creation_time,
last_execution_time,
execution_count,
total_elapsed_time,
last_elapsed_time
from sys.dm_exec_cached_plans a 
       inner join sys.dm_exec_query_stats b on a.plan_handle=b.plan_handle
     cross apply sys.dm_exec_sql_text(b.sql_handle) as sql_text
     cross apply sys.dm_exec_query_plan(a.plan_handle) as query_plan
where 1=1
and text like '%mybadproc%'   --此處放置您要查詢的語法
-- and a.plan_handle = 0x06000B00C96DEC2AB8A16D06000000000000000000000000
and b.last_execution_time between '2014-01-20 09:00' and '2014-01-20 12:00'
order by last_execution_time desc
