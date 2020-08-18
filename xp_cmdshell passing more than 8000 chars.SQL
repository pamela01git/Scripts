 DECLARE @DOS_CMD VARCHAR(8000)                                                                       
 DECLARE @TEXT VARCHAR(max)                                                                           
 SET @TEXT = CONVERT(VARCHAR(max),'11111111111111111111111111111111111111')                           
                                                       
 SELECT @TEXT  AS TEST INTO ##TEMP                                                                    
 select * from ##temp                                                                                 
 SET @DOS_CMD = 'bcp "select * from ##TEMP " queryout D:\TEMP\1.TXT -S127.0.0.1 -T -c -Usa -Pcrmgroup'
                                                       
 exec xp_cmdshell @DOS_CMD                                                                            
 drop table  ##TEMP                                                                                   