DECLARE @Request_tocnt int
, @Activity_tocnt int
, @err_msg nvarchar(max)
, @SJ_Time datetime = (SELECT SJtime FROM OPENQUERY([SJDCSPESTGDB.intservice.trendnet.org], 'SELECT getdate() as SJtime'))
, @Request_SR_List NVARCHAR(MAX)
, @Activity_SR_List NVARCHAR(MAX)
SET @Request_SR_List=''
set @Activity_SR_List=''

select @Request_tocnt =count(1)   
from  [SJDCSPESTGDB.intservice.trendnet.org].[SPE_DB].[dbo].[CASE_REQUEST_JP] with (nolock)
where status= 'Timeout' and sr_number is not null
  and dt_created between dateadd(MINUTE,-5,@SJ_Time) and @SJ_Time
 
select @Request_SR_List=COALESCE(RTRIM(@Request_SR_List)+',','') + SR_NUMBER   
from  [SJDCSPESTGDB.intservice.trendnet.org].[SPE_DB].[dbo].[CASE_REQUEST_JP] with (nolock)
where status= 'Timeout' and sr_number is not null
 and dt_created between dateadd(MINUTE,-5,@SJ_Time) and @SJ_Time 
 
 
select  @Activity_tocnt=count(*) from [SJDCSPESTGDB.intservice.trendnet.org].[SPE_DB].[dbo].[CASE_ACTIVITY_JP] with (nolock)
where status= 'Timeout' and sr_number is not null
 and dt_created between dateadd(MINUTE,-5,@SJ_Time) and @SJ_Time
select  @Activity_SR_List=COALESCE(RTRIM(@Activity_SR_List)+',','') + SR_NUMBER   
from  [SJDCSPESTGDB.intservice.trendnet.org].[SPE_DB].[dbo].[CASE_activity_JP] with (nolock)
where [status]= 'Timeout' and sr_number is not null
 and dt_created between dateadd(MINUTE,-5,@SJ_Time) and @SJ_Time

 set @err_msg =rtrim(convert(varchar,@Request_tocnt))+' record occurs timeout error in CASE_REQUEST_JP, '+rtrim(convert(varchar,@Activity_tocnt))+' record occurs timeout error in CASE_ACTIVITY_JP during dt_created between '+convert(char(19),dateadd(MINUTE,-5,@SJ_Time),20)+' and '+convert(char(19),@SJ_Time,20)+'
Here is the CASE_REQUEST_JP Time out List: '+
rtrim(@Request_SR_List)+'
Here is the CASE_Activity_JP Time out List: '+
rtrim(@Activity_SR_List)+'
Please execute SQL Statement below to get detail information'+'
               
                select * from SPE_DB.dbo.CASE_REQUEST_JP
                 where (status= ''Timeout'' )
                 and dt_created between '''+convert(char(19),dateadd(MINUTE,-5,@SJ_Time),20)+''' and '''+convert(char(19),@SJ_Time,20)+''';
                select * from SPE_DB.dbo.CASE_ACTIVITY_JP
                 where (status= ''Timeout'' )
                 and dt_created between '''+convert(char(19),dateadd(MINUTE,-5,@SJ_Time),20)+''' and '''+convert(char(19),@SJ_Time,20)+''';'                 

 if @Request_tocnt > 0  or @Activity_tocnt > 0
 begin
 EXEC msdb.dbo.sp_send_dbmail
    @profile_name = 'tw-gccejdb',
    @recipients = 'anita_kuo@trend.com.tw;sasha_sha@trend.com.tw;ann_j_lin@trend.com.tw',
    @body = @err_msg,
    @subject = 'SPE_DB Timnout error',
    @exclude_query_output=1
end