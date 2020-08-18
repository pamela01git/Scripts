USE CRMBASISDB
GO

  DECLARE @CYCLEDATE CHAR(8)    
  DECLARE @RUNSTATUS CHAR(10)	
  
  SELECT @CYCLEDATE=CYCLEDATE,@RUNSTATUS=RUNSTATUS FROM [CRMBASISDB].ODSDBA.DW_XSTARTTIME WHERE DATACAT = 'DWD'
    
    WHILE @CYCLEDATE IS NULL OR @RUNSTATUS <> 'RUNOK'
    BEGIN
      WAITFOR DELAY '000:03:00' 	
      SELECT @CYCLEDATE=CYCLEDATE,@RUNSTATUS=RUNSTATUS FROM [CRMBASISDB].ODSDBA.DW_XSTARTTIME WHERE DATACAT = 'DWD'	    
    END
    	
   

DECLARE @DBNAME CHAR(20)
SET @DBNAME= 'CRMBASISDB'  --輸入資料庫名稱

DECLARE @DATADT CHAR(8)
DECLARE @table_name CHAR(50)
DECLARE @COLUMN_NAME CHAR(50)
DECLARE @DATADT_FG CHAR(1) 
DECLARE @ERR_NO      int             --錯誤代碼 
DECLARE @SQL VARCHAR(8000)

if exists (select * from dbo.sysobjects where name = 'MD_VERIFY')
Drop Table odsdba.MD_VERIFY
CREATE TABLE odsdba.MD_VERIFY (DATADT CHAR(8),DB_NAME CHAR(20),TABLE_NAME CHAR(50),TOT_CNT CHAR(20),COLUMN_NAME CHAR(50),TOT_NUM CHAR(30),DATADT_FG CHAR(1))


DECLARE ListCur CURSOR FOR 

        SELECT DISTINCT t.name
              ,CASE WHEN S1.TBL_NM IS NULL THEN 'N' ELSE 'Y' END AS DATADT_FG -- WHETHER EXIST DATADT COLUMN
              ,CASE WHEN RIGHT(RTRIM(t.name),2) IN ('MS','MH','MW','MA','WK') OR odsdb.dbo.instr(t.name,'_',1) IN ('ODSMS') 
                         OR ( RIGHT(RTRIM(NAME),6) = LEFT(@CYCLEDATE,6) AND odsdb.dbo.instr(name,'_',1) <> 'TX' AND NAME NOT LIKE '%_DH_%'  ) THEN CONVERT(CHAR(8),S9.TMNBDT,112)
                  --  WHEN  NAME LIKE 'FB_TBCSTFEEL_DH_%' THEN CONVERT(CHAR(8),S9.LMNEDT,112) 
                    ELSE CONVERT(CHAR(8),S9.DATADT,112) END AS DATADT                 
        FROM dbo.sysobjects t
        LEFT OUTER JOIN (select t.name as TBL_NM                         
                         from syscolumns c, sysobjects t, systypes p     
                         where c.id = t.id                   
                         and c.xtype = p.xtype
                         and t.xtype= 'U' --user talbe           
                         and c.name  ='datadt') S1 ON ( S1.TBL_NM = name)
        INNER JOIN ODSDB.ODSDBA.CB_DT S9 ON (S9.DATADT= @CYCLEDATE)                 
        WHERE xtype = 'U' --USER TABLE
        --  AND uid in (select uid from dbo.sysusers where name = 'odsdba') --Table owner = ODSDBA
          AND  uid in (5,6)
          AND  odsdb.dbo.instr(name,'_',1) in ('CB','CS','FB','FS','MD','TX','CRM','ODS','ODSMS') --TABLE PREFIX
          AND  rtrim(name) not like '%_err' -- ERROR TALE NAME
          AND  (ISNUMERIC(RIGHT(RTRIM(NAME),6))= 0 OR RIGHT(RTRIM(NAME),6) = LEFT(@CYCLEDATE,6) )  -- ONLY THIS NOMNTH PARTIOTION TABLE
        ORDER BY 1
 
        OPEN ListCur;
        FETCH NEXT FROM ListCur 
             INTO @table_name,@DATADT_FG,@DATADT
                                                                                                                   
        WHILE @@FETCH_STATUS = 0   
          BEGIN
                SET @SQL =''
                DECLARE ColCur CURSOR FOR
                
                   select DISTINCT c.name as column_name
                   from syscolumns c, sysobjects t, systypes p
                   where c.id = t.id 
                   and c.xtype = p.xtype
                   and t.xtype= 'U' --user talbe
                   and t.name = @table_name
                   and p.name IN  ('numeric','int','decimal') --數值欄位
                   order by 1                

                OPEN ColCur;
                FETCH NEXT FROM ColCur 
                     INTO @COLUMN_NAME     
                
                WHILE @@FETCH_STATUS = 0   
                  BEGIN   
                     SET @SQL = RTRIM(@SQL)+'+''|'+RTRIM(@COLUMN_NAME)+'=''+CONVERT(VARCHAR,SUM(ISNULL('+RTRIM(@COLUMN_NAME)+',0)))'	
                  	
                    FETCH NEXT FROM ColCur --進行下一筆
                    INTO @COLUMN_NAME                                                                      	
                  END                      	                         
            
                CLOSE ColCur;                                                                                                                      
                DEALLOCATE ColCur            
------------------------------
-- 處理下一筆
   NEXT_TYPE:
------------------------------ 
               IF @DATADT_FG = 'Y'
               BEGIN 
                 SET @SQL = 'DECLARE @VAR VARCHAR(8000) DECLARE @DLMCNT INT DECLARE @TMPCNT INT SET @TMPCNT = 0 SELECT @VAR=CONVERT(VARCHAR,COUNT(1))'+RTRIM(@SQL)+' FROM ODSDBA.'+RTRIM(@table_name)+' WHERE DATADT ='''+@DATADT+''' SET @DLMCNT= (SELECT ODSDB.DBO.DCOUNT(@VAR,''|'')) IF @DLMCNT = 0  INSERT INTO ODSDBA.MD_VERIFY SELECT '''+ @CYCLEDATE+''','''+ RTRIM(@DBNAME)+''','''+RTRIM(@table_name)+''',COUNT(1),''NA'',''0'',''Y'' FROM ODSDBA.'+RTRIM(@table_name)+' WHERE DATADT ='''+@DATADT+''' WHILE @TMPCNT < @DLMCNT BEGIN INSERT INTO ODSDBA.MD_VERIFY SELECT '''+ @CYCLEDATE+''','''+ RTRIM(@DBNAME)+''','''+RTRIM(@table_name)+''',ODSDB.DBO.INSTR(RTRIM(@VAR),''|'',1),ODSDB.DBO.INSTR(ODSDB.DBO.INSTR(RTRIM(@VAR),''|'',@TMPCNT+2),''='',1),ODSDB.DBO.INSTR(ODSDB.DBO.INSTR(RTRIM(@VAR),''|'',@TMPCNT+2),''='',2),''Y'' SET @TMPCNT= @TMPCNT + 1 END'
               END
               ELSE BEGIN
               	 SET @SQL = 'DECLARE @VAR VARCHAR(8000) DECLARE @DLMCNT INT DECLARE @TMPCNT INT SET @TMPCNT = 0 SELECT @VAR=CONVERT(VARCHAR,COUNT(1))'+RTRIM(@SQL)+' FROM ODSDBA.'+RTRIM(@table_name)+' SET @DLMCNT= (SELECT ODSDB.DBO.DCOUNT(@VAR,''|'')) IF @DLMCNT = 0  INSERT INTO ODSDBA.MD_VERIFY SELECT '''+ @CYCLEDATE+''','''+ RTRIM(@DBNAME)+''','''+RTRIM(@table_name)+''',COUNT(1),''NA'',''0'',''N'' FROM ODSDBA.'+RTRIM(@table_name)+' WHILE @TMPCNT < @DLMCNT BEGIN INSERT INTO ODSDBA.MD_VERIFY SELECT '''+ @CYCLEDATE+''','''+ RTRIM(@DBNAME)+''','''+RTRIM(@table_name)+''',ODSDB.DBO.INSTR(RTRIM(@VAR),''|'',1),ODSDB.DBO.INSTR(ODSDB.DBO.INSTR(RTRIM(@VAR),''|'',@TMPCNT+2),''='',1),ODSDB.DBO.INSTR(ODSDB.DBO.INSTR(RTRIM(@VAR),''|'',@TMPCNT+2),''='',2),''N'' SET @TMPCNT =@TMPCNT +1 END'                 
               END  
               --PRINT @SQL
               -- EXEC SP_EXECUTESQL @SQL,N'@ERR_NO INT OUT',@ERR_NO OUT
                  EXEC (@SQL) 
            FETCH NEXT FROM ListCur --進行下一筆
            INTO @table_name,@DATADT_FG,@DATADT                                                                        	
          END         

        CLOSE ListCur;                                                                                                                      
        DEALLOCATE ListCur;      
        
--產生text file        
  DECLARE @BAT VARCHAR(8000);       
  SET @BAT='bcp '+RTRIM(@DBNAME)+'.odsdba.MD_VERIFY out d:\'+@CYCLEDATE+'_'+RTRIM(@DBNAME)+'_4cpu.txt -fd:\MD_Verify.fmt -S127.0.0.1 -Ursuser -Prsuser'
  exec master..xp_cmdshell @BAT; 
      
if exists (select * from dbo.sysobjects where name = 'MD_VERIFY')
Drop Table odsdba.MD_VERIFY   

           
           --利用SMTP傳送MAIL
           DECLARE @SUBJECT  VARCHAR(100)
           DECLARE @MSGDIR   VARCHAR(1000)
           DECLARE @EXEC_MAIL VARCHAR(8000)
           DECLARE @MAILLIST VARCHAR(1000)
           DECLARE @MAILADD VARCHAR(30)

           SET @SUBJECT = '[4CPU]'+@CYCLEDATE+'_'+RTRIM(@DBNAME)
           SET @MSGDIR  = 'd:\'+@CYCLEDATE+'_'+RTRIM(@DBNAME)+'_4cpu.txt'
           
           SET @EXEC_MAIL ='D:\DWBasisDB\SysControl\sendmail.bat '+@SUBJECT+' '+@MSGDIR+' '+'crmgroup@landbank.com.tw'
          -- PRINT @EXEC_MAIL
           exec master..xp_cmdshell @EXEC_MAIL 
           
---------------------------PCUCAMPDB--------------------------------------------------------------------           
              
USE PCUCAMPDB
GO

  DECLARE @CYCLEDATE CHAR(8)    
  DECLARE @RUNSTATUS CHAR(10)	
  
  SELECT @CYCLEDATE=CYCLEDATE,@RUNSTATUS=RUNSTATUS FROM [CRMBASISDB].ODSDBA.DW_XSTARTTIME WHERE DATACAT = 'DWD'
    

   

DECLARE @DBNAME CHAR(20)
SET @DBNAME= 'PCUCAMPDB'  --輸入資料庫名稱

DECLARE @DATADT CHAR(8)
DECLARE @table_name CHAR(50)
DECLARE @COLUMN_NAME CHAR(50)
DECLARE @DATADT_FG CHAR(1) 
DECLARE @ERR_NO      int             --錯誤代碼 
DECLARE @SQL VARCHAR(8000)

if exists (select * from dbo.sysobjects where name = 'MD_VERIFY')
Drop Table odsdba.MD_VERIFY
CREATE TABLE odsdba.MD_VERIFY (DATADT CHAR(8),DB_NAME CHAR(20),TABLE_NAME CHAR(50),TOT_CNT CHAR(20),COLUMN_NAME CHAR(50),TOT_NUM CHAR(30),DATADT_FG CHAR(1))


DECLARE ListCur CURSOR FOR 

        SELECT DISTINCT t.name
              ,CASE WHEN S1.TBL_NM IS NULL THEN 'N' ELSE 'Y' END AS DATADT_FG -- WHETHER EXIST DATADT COLUMN
              ,CASE WHEN RIGHT(RTRIM(t.name),2) IN ('MS','MH','MW','MA','WK') OR odsdb.dbo.instr(t.name,'_',1) IN ('ODSMS') 
                         OR ( RIGHT(RTRIM(NAME),6) = LEFT(@CYCLEDATE,6) AND odsdb.dbo.instr(name,'_',1) <> 'TX' AND NAME NOT LIKE '%_DH_%'  ) THEN CONVERT(CHAR(8),S9.TMNBDT,112)
                  --  WHEN  NAME LIKE 'FB_TBCSTFEEL_DH_%' THEN CONVERT(CHAR(8),S9.LMNEDT,112) 
                    ELSE CONVERT(CHAR(8),S9.DATADT,112) END AS DATADT                 
        FROM dbo.sysobjects t
        LEFT OUTER JOIN (select t.name as TBL_NM                         
                         from syscolumns c, sysobjects t, systypes p     
                         where c.id = t.id                   
                         and c.xtype = p.xtype
                         and t.xtype= 'U' --user talbe           
                         and c.name  ='datadt') S1 ON ( S1.TBL_NM = name)
        INNER JOIN ODSDB.ODSDBA.CB_DT S9 ON (S9.DATADT= @CYCLEDATE)                 
        WHERE xtype = 'U' --USER TABLE
        --  AND uid in (select uid from dbo.sysusers where name = 'odsdba') --Table owner = ODSDBA
          AND  uid in (5,6)
          AND  odsdb.dbo.instr(name,'_',1) in ('CB','CS','FB','FS','MD','TX','CRM','ODS','ODSMS') --TABLE PREFIX
          AND  rtrim(name) not like '%_err' -- ERROR TALE NAME
          AND  (ISNUMERIC(RIGHT(RTRIM(NAME),6))= 0 OR RIGHT(RTRIM(NAME),6) = LEFT(@CYCLEDATE,6) )  -- ONLY THIS NOMNTH PARTIOTION TABLE
        ORDER BY 1
 
        OPEN ListCur;
        FETCH NEXT FROM ListCur 
             INTO @table_name,@DATADT_FG,@DATADT
                                                                                                                   
        WHILE @@FETCH_STATUS = 0   
          BEGIN
                SET @SQL =''
                DECLARE ColCur CURSOR FOR
                
                   select DISTINCT c.name as column_name
                   from syscolumns c, sysobjects t, systypes p
                   where c.id = t.id 
                   and c.xtype = p.xtype
                   and t.xtype= 'U' --user talbe
                   and t.name = @table_name
                   and p.name IN  ('numeric','int','decimal') --數值欄位
                   order by 1                

                OPEN ColCur;
                FETCH NEXT FROM ColCur 
                     INTO @COLUMN_NAME     
                
                WHILE @@FETCH_STATUS = 0   
                  BEGIN   
                     SET @SQL = RTRIM(@SQL)+'+''|'+RTRIM(@COLUMN_NAME)+'=''+CONVERT(VARCHAR,SUM(ISNULL('+RTRIM(@COLUMN_NAME)+',0)))'	
                  	
                    FETCH NEXT FROM ColCur --進行下一筆
                    INTO @COLUMN_NAME                                                                      	
                  END                      	                         
            
                CLOSE ColCur;                                                                                                                      
                DEALLOCATE ColCur            
------------------------------
-- 處理下一筆
   NEXT_TYPE:
------------------------------ 
               IF @DATADT_FG = 'Y'
               BEGIN 
                 SET @SQL = 'DECLARE @VAR VARCHAR(8000) DECLARE @DLMCNT INT DECLARE @TMPCNT INT SET @TMPCNT = 0 SELECT @VAR=CONVERT(VARCHAR,COUNT(1))'+RTRIM(@SQL)+' FROM ODSDBA.'+RTRIM(@table_name)+' WHERE DATADT ='''+@DATADT+''' SET @DLMCNT= (SELECT ODSDB.DBO.DCOUNT(@VAR,''|'')) IF @DLMCNT = 0  INSERT INTO ODSDBA.MD_VERIFY SELECT '''+ @CYCLEDATE+''','''+ RTRIM(@DBNAME)+''','''+RTRIM(@table_name)+''',COUNT(1),''NA'',''0'',''Y'' FROM ODSDBA.'+RTRIM(@table_name)+' WHERE DATADT ='''+@DATADT+''' WHILE @TMPCNT < @DLMCNT BEGIN INSERT INTO ODSDBA.MD_VERIFY SELECT '''+ @CYCLEDATE+''','''+ RTRIM(@DBNAME)+''','''+RTRIM(@table_name)+''',ODSDB.DBO.INSTR(RTRIM(@VAR),''|'',1),ODSDB.DBO.INSTR(ODSDB.DBO.INSTR(RTRIM(@VAR),''|'',@TMPCNT+2),''='',1),ODSDB.DBO.INSTR(ODSDB.DBO.INSTR(RTRIM(@VAR),''|'',@TMPCNT+2),''='',2),''Y'' SET @TMPCNT= @TMPCNT + 1 END'
               END
               ELSE BEGIN
               	 SET @SQL = 'DECLARE @VAR VARCHAR(8000) DECLARE @DLMCNT INT DECLARE @TMPCNT INT SET @TMPCNT = 0 SELECT @VAR=CONVERT(VARCHAR,COUNT(1))'+RTRIM(@SQL)+' FROM ODSDBA.'+RTRIM(@table_name)+' SET @DLMCNT= (SELECT ODSDB.DBO.DCOUNT(@VAR,''|'')) IF @DLMCNT = 0  INSERT INTO ODSDBA.MD_VERIFY SELECT '''+ @CYCLEDATE+''','''+ RTRIM(@DBNAME)+''','''+RTRIM(@table_name)+''',COUNT(1),''NA'',''0'',''N'' FROM ODSDBA.'+RTRIM(@table_name)+' WHILE @TMPCNT < @DLMCNT BEGIN INSERT INTO ODSDBA.MD_VERIFY SELECT '''+ @CYCLEDATE+''','''+ RTRIM(@DBNAME)+''','''+RTRIM(@table_name)+''',ODSDB.DBO.INSTR(RTRIM(@VAR),''|'',1),ODSDB.DBO.INSTR(ODSDB.DBO.INSTR(RTRIM(@VAR),''|'',@TMPCNT+2),''='',1),ODSDB.DBO.INSTR(ODSDB.DBO.INSTR(RTRIM(@VAR),''|'',@TMPCNT+2),''='',2),''N'' SET @TMPCNT =@TMPCNT +1 END'                 
               END  
               --PRINT @SQL
               -- EXEC SP_EXECUTESQL @SQL,N'@ERR_NO INT OUT',@ERR_NO OUT
                  EXEC (@SQL) 
            FETCH NEXT FROM ListCur --進行下一筆
            INTO @table_name,@DATADT_FG,@DATADT                                                                        	
          END         

        CLOSE ListCur;                                                                                                                      
        DEALLOCATE ListCur;      
        
--產生text file        
  DECLARE @BAT VARCHAR(8000);       
  SET @BAT='bcp '+RTRIM(@DBNAME)+'.odsdba.MD_VERIFY out d:\'+@CYCLEDATE+'_'+RTRIM(@DBNAME)+'_4cpu.txt -fd:\MD_Verify.fmt -S127.0.0.1 -Ursuser -Prsuser'
  exec master..xp_cmdshell @BAT; 
      
if exists (select * from dbo.sysobjects where name = 'MD_VERIFY')
Drop Table odsdba.MD_VERIFY   

           
           --利用SMTP傳送MAIL
           DECLARE @SUBJECT  VARCHAR(100)
           DECLARE @MSGDIR   VARCHAR(1000)
           DECLARE @EXEC_MAIL VARCHAR(8000)
           DECLARE @MAILLIST VARCHAR(1000)
           DECLARE @MAILADD VARCHAR(30)

           SET @SUBJECT = '[4CPU]'+@CYCLEDATE+'_'+RTRIM(@DBNAME)
           SET @MSGDIR  = 'd:\'+@CYCLEDATE+'_'+RTRIM(@DBNAME)+'_4cpu.txt'
           
           SET @EXEC_MAIL ='D:\DWBasisDB\SysControl\sendmail.bat '+@SUBJECT+' '+@MSGDIR+' '+'crmgroup@landbank.com.tw'
          -- PRINT @EXEC_MAIL
           exec master..xp_cmdshell @EXEC_MAIL 
              
---------------------------PCUINFODB--------------------------------------------------------------------           
              
USE PCUINFODB
GO

  DECLARE @CYCLEDATE CHAR(8)    
  DECLARE @RUNSTATUS CHAR(10)	
  
  SELECT @CYCLEDATE=CYCLEDATE,@RUNSTATUS=RUNSTATUS FROM [CRMBASISDB].ODSDBA.DW_XSTARTTIME WHERE DATACAT = 'DWD'
    

   

DECLARE @DBNAME CHAR(20)
SET @DBNAME= 'PCUINFODB'  --輸入資料庫名稱

DECLARE @DATADT CHAR(8)
DECLARE @table_name CHAR(50)
DECLARE @COLUMN_NAME CHAR(50)
DECLARE @DATADT_FG CHAR(1) 
DECLARE @ERR_NO      int             --錯誤代碼 
DECLARE @SQL VARCHAR(8000)

if exists (select * from dbo.sysobjects where name = 'MD_VERIFY')
Drop Table odsdba.MD_VERIFY
CREATE TABLE odsdba.MD_VERIFY (DATADT CHAR(8),DB_NAME CHAR(20),TABLE_NAME CHAR(50),TOT_CNT CHAR(20),COLUMN_NAME CHAR(50),TOT_NUM CHAR(30),DATADT_FG CHAR(1))


DECLARE ListCur CURSOR FOR 

        SELECT DISTINCT t.name
              ,CASE WHEN S1.TBL_NM IS NULL THEN 'N' ELSE 'Y' END AS DATADT_FG -- WHETHER EXIST DATADT COLUMN
              ,CASE WHEN RIGHT(RTRIM(t.name),2) IN ('MS','MH','MW','MA','WK') OR odsdb.dbo.instr(t.name,'_',1) IN ('ODSMS') 
                         OR ( RIGHT(RTRIM(NAME),6) = LEFT(@CYCLEDATE,6) AND odsdb.dbo.instr(name,'_',1) <> 'TX' AND NAME NOT LIKE '%_DH_%'  ) THEN CONVERT(CHAR(8),S9.TMNBDT,112)
                  --  WHEN  NAME LIKE 'FB_TBCSTFEEL_DH_%' THEN CONVERT(CHAR(8),S9.LMNEDT,112) 
                    ELSE CONVERT(CHAR(8),S9.DATADT,112) END AS DATADT                 
        FROM dbo.sysobjects t
        LEFT OUTER JOIN (select t.name as TBL_NM                         
                         from syscolumns c, sysobjects t, systypes p     
                         where c.id = t.id                   
                         and c.xtype = p.xtype
                         and t.xtype= 'U' --user talbe           
                         and c.name  ='datadt') S1 ON ( S1.TBL_NM = name)
        INNER JOIN ODSDB.ODSDBA.CB_DT S9 ON (S9.DATADT= @CYCLEDATE)                 
        WHERE xtype = 'U' --USER TABLE
        --  AND uid in (select uid from dbo.sysusers where name = 'odsdba') --Table owner = ODSDBA
          AND  uid in (5,6)
          AND  odsdb.dbo.instr(name,'_',1) in ('CB','CS','FB','FS','MD','TX','CRM','ODS','ODSMS') --TABLE PREFIX
          AND  rtrim(name) not like '%_err' -- ERROR TALE NAME
          AND  (ISNUMERIC(RIGHT(RTRIM(NAME),6))= 0 OR RIGHT(RTRIM(NAME),6) = LEFT(@CYCLEDATE,6) )  -- ONLY THIS NOMNTH PARTIOTION TABLE
        ORDER BY 1
 
        OPEN ListCur;
        FETCH NEXT FROM ListCur 
             INTO @table_name,@DATADT_FG,@DATADT
                                                                                                                   
        WHILE @@FETCH_STATUS = 0   
          BEGIN
                SET @SQL =''
                DECLARE ColCur CURSOR FOR
                
                   select DISTINCT c.name as column_name
                   from syscolumns c, sysobjects t, systypes p
                   where c.id = t.id 
                   and c.xtype = p.xtype
                   and t.xtype= 'U' --user talbe
                   and t.name = @table_name
                   and p.name IN  ('numeric','int','decimal') --數值欄位
                   order by 1                

                OPEN ColCur;
                FETCH NEXT FROM ColCur 
                     INTO @COLUMN_NAME     
                
                WHILE @@FETCH_STATUS = 0   
                  BEGIN   
                     SET @SQL = RTRIM(@SQL)+'+''|'+RTRIM(@COLUMN_NAME)+'=''+CONVERT(VARCHAR,SUM(ISNULL('+RTRIM(@COLUMN_NAME)+',0)))'	
                  	
                    FETCH NEXT FROM ColCur --進行下一筆
                    INTO @COLUMN_NAME                                                                      	
                  END                      	                         
            
                CLOSE ColCur;                                                                                                                      
                DEALLOCATE ColCur            
------------------------------
-- 處理下一筆
   NEXT_TYPE:
------------------------------ 
               IF @DATADT_FG = 'Y'
               BEGIN 
                 SET @SQL = 'DECLARE @VAR VARCHAR(8000) DECLARE @DLMCNT INT DECLARE @TMPCNT INT SET @TMPCNT = 0 SELECT @VAR=CONVERT(VARCHAR,COUNT(1))'+RTRIM(@SQL)+' FROM ODSDBA.'+RTRIM(@table_name)+' WHERE DATADT ='''+@DATADT+''' SET @DLMCNT= (SELECT ODSDB.DBO.DCOUNT(@VAR,''|'')) IF @DLMCNT = 0  INSERT INTO ODSDBA.MD_VERIFY SELECT '''+ @CYCLEDATE+''','''+ RTRIM(@DBNAME)+''','''+RTRIM(@table_name)+''',COUNT(1),''NA'',''0'',''Y'' FROM ODSDBA.'+RTRIM(@table_name)+' WHERE DATADT ='''+@DATADT+''' WHILE @TMPCNT < @DLMCNT BEGIN INSERT INTO ODSDBA.MD_VERIFY SELECT '''+ @CYCLEDATE+''','''+ RTRIM(@DBNAME)+''','''+RTRIM(@table_name)+''',ODSDB.DBO.INSTR(RTRIM(@VAR),''|'',1),ODSDB.DBO.INSTR(ODSDB.DBO.INSTR(RTRIM(@VAR),''|'',@TMPCNT+2),''='',1),ODSDB.DBO.INSTR(ODSDB.DBO.INSTR(RTRIM(@VAR),''|'',@TMPCNT+2),''='',2),''Y'' SET @TMPCNT= @TMPCNT + 1 END'
               END
               ELSE BEGIN
               	 SET @SQL = 'DECLARE @VAR VARCHAR(8000) DECLARE @DLMCNT INT DECLARE @TMPCNT INT SET @TMPCNT = 0 SELECT @VAR=CONVERT(VARCHAR,COUNT(1))'+RTRIM(@SQL)+' FROM ODSDBA.'+RTRIM(@table_name)+' SET @DLMCNT= (SELECT ODSDB.DBO.DCOUNT(@VAR,''|'')) IF @DLMCNT = 0  INSERT INTO ODSDBA.MD_VERIFY SELECT '''+ @CYCLEDATE+''','''+ RTRIM(@DBNAME)+''','''+RTRIM(@table_name)+''',COUNT(1),''NA'',''0'',''N'' FROM ODSDBA.'+RTRIM(@table_name)+' WHILE @TMPCNT < @DLMCNT BEGIN INSERT INTO ODSDBA.MD_VERIFY SELECT '''+ @CYCLEDATE+''','''+ RTRIM(@DBNAME)+''','''+RTRIM(@table_name)+''',ODSDB.DBO.INSTR(RTRIM(@VAR),''|'',1),ODSDB.DBO.INSTR(ODSDB.DBO.INSTR(RTRIM(@VAR),''|'',@TMPCNT+2),''='',1),ODSDB.DBO.INSTR(ODSDB.DBO.INSTR(RTRIM(@VAR),''|'',@TMPCNT+2),''='',2),''N'' SET @TMPCNT =@TMPCNT +1 END'                 
               END  
               --PRINT @SQL
               -- EXEC SP_EXECUTESQL @SQL,N'@ERR_NO INT OUT',@ERR_NO OUT
                  EXEC (@SQL) 
            FETCH NEXT FROM ListCur --進行下一筆
            INTO @table_name,@DATADT_FG,@DATADT                                                                        	
          END         

        CLOSE ListCur;                                                                                                                      
        DEALLOCATE ListCur;      
        
--產生text file        
  DECLARE @BAT VARCHAR(8000);       
  SET @BAT='bcp '+RTRIM(@DBNAME)+'.odsdba.MD_VERIFY out d:\'+@CYCLEDATE+'_'+RTRIM(@DBNAME)+'_4cpu.txt -fd:\MD_Verify.fmt -S127.0.0.1 -Ursuser -Prsuser'
  exec master..xp_cmdshell @BAT; 
      
if exists (select * from dbo.sysobjects where name = 'MD_VERIFY')
Drop Table odsdba.MD_VERIFY   

           
           --利用SMTP傳送MAIL
           DECLARE @SUBJECT  VARCHAR(100)
           DECLARE @MSGDIR   VARCHAR(1000)
           DECLARE @EXEC_MAIL VARCHAR(8000)
           DECLARE @MAILLIST VARCHAR(1000)
           DECLARE @MAILADD VARCHAR(30)

           SET @SUBJECT = '[4CPU]'+@CYCLEDATE+'_'+RTRIM(@DBNAME)
           SET @MSGDIR  = 'd:\'+@CYCLEDATE+'_'+RTRIM(@DBNAME)+'_4cpu.txt'
           
           SET @EXEC_MAIL ='D:\DWBasisDB\SysControl\sendmail.bat '+@SUBJECT+' '+@MSGDIR+' '+'crmgroup@landbank.com.tw'
          -- PRINT @EXEC_MAIL
           exec master..xp_cmdshell @EXEC_MAIL 