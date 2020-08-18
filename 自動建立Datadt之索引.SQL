
DECLARE @SCRIPT_PATH VARCHAR(256)
SET @SCRIPT_PATH ='D:\' --檔案存放路徑



IF EXISTS (SELECT * FROM TEMPDB.DBO.sysobjects WHERE Name ='##HISTABLE_SCRIPT') DROP TABLE ##HISTABLE_SCRIPT;     
CREATE TABLE ##HISTABLE_SCRIPT(ROWNUM INT IDENTITY(1,1),CMD VARCHAR(MAX))

DECLARE @DBNAME CHAR(30)
DECLARE @TABLENAME CHAR(200)
DECLARE @GROUPNAME CHAR(30)
DECLARE @CRT_IDX_SQL NVARCHAR(4000)

------------------------------
-- STEP1:找出所有歷史性資料表
------------------------------  
   DECLARE TABLEList CURSOR LOCAL FOR   
 
    --依序處理XSURDETAIL之所有資料 
    SELECT 'ODSDB' DBNAME,t.NAME 
    FROM ODSDB.SYS.TABLES t 
    WHERE (t.NAME LIKE 'TX[_]%' OR t.NAME LIKE '%[_]DH' OR t.NAME LIKE '%[_]MH' OR t.NAME LIKE '%[_]MS' OR t.NAME LIKE '%[_]MA'
           OR t.NAME LIKE 'ODSMS[_]%'
           OR t.NAME IN ('CS_Pcust_CCardRFM','CS_Pcust_FaciAggt','CS_Pcust_MgtInfoRFM','CS_Pcust_SecuAggt'))
      AND t.NAME NOT IN 
         (SELECT A.NAME
          FROM ODSDB.dbo.SYSOBJECTS A
          JOIN ODSDB.dbo.SYSINDEXES C ON A.ID=C.ID
          JOIN ODSDB.dbo.SYSINDEXKEYS D ON C.ID=D.ID AND C.INDID=D.INDID
          JOIN ODSDB.dbo.SYSCOLUMNS E ON E.ID=C.ID AND D.COLID=E.COLID   
          WHERE E.name IN ('DATADT'))
    UNION ALL      
    SELECT 'DWBasisDB' DBNAME,t.NAME 
    FROM DWBASISDB.SYS.TABLES t 
    WHERE (t.NAME LIKE 'TX[_]%' OR t.NAME LIKE '%[_]DH' OR t.NAME LIKE '%[_]MH' OR t.NAME LIKE '%[_]MS' OR t.NAME LIKE '%[_]MA'
           OR t.NAME LIKE 'ODSMS[_]%'
           OR t.NAME IN ('CS_Pcust_CCardRFM','CS_Pcust_FaciAggt','CS_Pcust_MgtInfoRFM','CS_Pcust_SecuAggt'))
      AND t.NAME NOT IN 
         (SELECT A.NAME
          FROM DWBASISDB.dbo.SYSOBJECTS A
          JOIN DWBASISDB.dbo.SYSINDEXES C ON A.ID=C.ID
          JOIN DWBASISDB.dbo.SYSINDEXKEYS D ON C.ID=D.ID AND C.INDID=D.INDID
          JOIN DWBASISDB.dbo.SYSCOLUMNS E ON E.ID=C.ID AND D.COLID=E.COLID   
          WHERE E.name IN ('DATADT'))  
  
   OPEN TABLEList; 
   FETCH NEXT FROM TABLEList 
        INTO @DBNAME,@TABLENAME
                                                                                                     
   WHILE @@FETCH_STATUS = 0   
      
 BEGIN  	
 
    ------------------------------
    -- STEP2:判斷需建立CLUSTER OR NONCLUSTER INDEX
    ------------------------------
    DECLARE @IDX_TYPE CHAR(20)
    IF EXISTS (SELECT T.[NAME],I.NAME ,I.TYPE_DESC
               FROM  SYS.TABLES T
                 INNER JOIN sys.index_columns as ic ON (ic.object_id = t.object_id)
                 INNER JOIN sys.indexes AS I ON (i.object_id = ic.object_id AND i.index_id = ic.index_id )            
               WHERE T.NAME=@TABLENAME
                 AND I.NAME IS NOT NULL
                 AND I.TYPE_DESC = 'CLUSTERED')
     BEGIN
     	SET @IDX_TYPE = 'NONCLUSTERED'
     END ELSE BEGIN
      	SET @IDX_TYPE = 'CLUSTERED'    	
     END;     	            
    	
    SET @GROUPNAME = CASE WHEN @TABLENAME LIKE 'ODSMS_%' THEN 'PRIMARY' WHEN @TABLENAME LIKE 'FB_%' THEN 'CRMBasisDB_FG2' WHEN @TABLENAME LIKE 'TX_%' THEN 'CRMBasisDB_FG3' ELSE 'CRMBasisDB_FG1' END	
    SET @CRT_IDX_SQL = 'CREATE '+RTRIM(@IDX_TYPE)+' INDEX [AK_'+RTRIM(@TABLENAME)+'_DATADT] ON '+RTRIM(@DBNAME)+'.odsdba.'+RTRIM(@TABLENAME)+' (datadt) ON ['+RTRIM(@GROUPNAME)+'];'  
    
    ------------------------------
    -- STEP3:CREATE INDEX
    ------------------------------
     PRINT @CRT_IDX_SQL  
     INSERT INTO ##HISTABLE_SCRIPT(CMD) VALUES(@CRT_IDX_SQL)

   FETCH NEXT FROM TABLEList 
   INTO  @DBNAME,@TABLENAME
   
 END    
 
 CLOSE TABLEList;                                                                                                             
 DEALLOCATE TABLEList;
    
        
------------------------------
-- STEP9: 執行SQL命令或產生SCRIPT
------------------------------  

DECLARE @QT_ST INT
DECLARE @CMD NVARCHAR(MAX)
DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;


    DECLARE @BCP_CMD VARCHAR(1000)
    SET @SCRIPT_PATH=CASE WHEN RIGHT(@SCRIPT_PATH,1)='\' THEN SUBSTRING(@SCRIPT_PATH,1,LEN(@SCRIPT_PATH)-1) ELSE @SCRIPT_PATH END
    SET @BCP_CMD='BCP "SELECT CMD FROM ##HISTABLE_SCRIPT ORDER BY ROWNUM" QUERYOUT "'+@SCRIPT_PATH+'\CreateIndex.sql" -T -c'
    EXEC XP_CMDSHELL @BCP_CMD
    PRINT @BCP_CMD
