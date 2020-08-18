EXEC msdb.dbo.sp_send_dbmail

@profile_name = 'Gmail',

@recipients = 'geoliang@microsoft.com',

@body = 'test',

@subject = 'hihi' ;
