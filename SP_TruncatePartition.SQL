USE [DWMD]
GO
/****** Object:  StoredProcedure [odsdba].[SP_TruncatePartition]    Script Date: 12/29/2008 11:14:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [odsdba].[SP_TruncatePartition]
    @DBNAME     CHAR(20),
    @TABLENAME  CHAR(30),
    @CYCLE_START DATETIME, --月初日
    @CYCLE_END DATETIME   --月底日    
    
AS
------------------------------
-- 程式說明
------------------------------
-- 1.Truncate特定月份(限單一月份)之Partition

 
------------------------------
-- STEP1:以TABLE NAME找出TALBE SCHEMA
------------------------------      	
DECLARE @FIND_SCHEMA_SQL NVARCHAR(4000)
DECLARE @SCHEMA CHAR(20) --TABLE SCHEMA
DECLARE @ERROR_MESSAGE  NVARCHAR(4000) --錯誤訊息

SET @FIND_SCHEMA_SQL
   ='SELECT  @SCHEMA = S.NAME 
     FROM  '+RTRIM(@DBNAME)+'.SYS.TABLES T
      JOIN '+RTRIM(@DBNAME)+'.SYS.SCHEMAS S ON S.SCHEMA_ID=T.SCHEMA_ID
    WHERE T.name = '''+RTRIM(@TABLENAME)+''''

BEGIN TRY
  EXECUTE sp_executesql @FIND_SCHEMA_SQL,N'@SCHEMA CHAR(20) OUT',@SCHEMA OUT;
END TRY
BEGIN CATCH      
  SET @ERROR_MESSAGE=ERROR_MESSAGE() 
  RAISERROR(@ERROR_MESSAGE,16,1);
END CATCH   

IF @SCHEMA IS NULL GOTO Main_Exit -- 找不到SCHEMA代表該物件不存在

------------------------------
-- STEP2:驗證資料表是否為Partition
------------------------------
DECLARE @CHK_PARTITION_SQL NVARCHAR(4000)
DECLARE @PARTITION_NUMBER INT

SET @CHK_PARTITION_SQL = 'SELECT @PARTITION_NUMBER=MAX(PARTITION_NUMBER)
                          FROM ( SELECT S2.OBJECT_ID,PARTITION_NUMBER FROM '+RTRIM(@DBNAME)+'.sys.partitions S1
                                 INNER JOIN '+RTRIM(@DBNAME)+'.SYS.TABLES S2 ON (S1.OBJECT_ID=S2.OBJECT_ID)) p'

BEGIN TRY
  EXEC SP_EXECUTESQL @CHK_PARTITION_SQL,N'@PARTITION_NUMBER INT OUT',@PARTITION_NUMBER OUT;
END TRY BEGIN CATCH
  SET @ERROR_MESSAGE=ERROR_MESSAGE()
  RAISERROR(@ERROR_MESSAGE,16,1);
END  CATCH    

  ------------------------------
  --STEP2.2:非Partition改用Delete方式處理
  ------------------------------
  IF @PARTITION_NUMBER <= 1 
     BEGIN
       EXEC [odsdba].[SP_DelData]  @DBNAME,@TABLENAME,@CYCLE_START,@CYCLE_END;
       GOTO Main_Exit
     END
            
------------------------------
-- STEP3:建立相對應之暫存表格
------------------------------

  ------------------------------
  --STEP3.1:產生欄位資訊SQL STATEMENT
  ------------------------------
 
   DECLARE @TBL_SCHEMA_SQL NVARCHAR(MAX)  
   DECLARE @SUB_SQL  VARCHAR(MAX)
   DECLARE @TBL_GROUPNAME SYSNAME
   DECLARE @IS_ANSI_PADDED CHAR(3)
    
   SET @TBL_SCHEMA_SQL = ' 
         DECLARE @COL_NM CHAR(40)
         DECLARE @COL_INFO VARCHAR(1000)
         DECLARE @DATA_TYPE CHAR(20)
         DECLARE @ANSI_PADDED INT

         SET @SUB_SQL = '''';--初始值 
         SET @IS_ANSI_PADDED = ''ON''
 
         DECLARE TableCol CURSOR LOCAL  FOR 
  
          SELECT c.NAME /*欄位名稱*/
          ,CASE WHEN C.COLUMN_ID <> 1 THEN '', '' ELSE ''  '' END /*若非第一個欄位則加分隔符號*/
         +''[''+RTRIM(c.NAME)+''] ''+ CASE WHEN ISC.DATA_TYPE in (''int'',''smallint'',''bigint'',''bit'',''datetime'',''text'',''sysname'',''tinyint'',''uniqueidentifier'',''float'') THEN UPPER(ISC.DATA_TYPE) WHEN ISC.DATA_TYPE IN (''numeric'',''decimal'') THEN  UPPER(ISC.DATA_TYPE)+''(''+RTRIM(ISC.NUMERIC_PRECISION)+'',''+RTRIM(ISC.NUMERIC_SCALE)+'')'' ELSE UPPER(ISC.DATA_TYPE)+''(''+RTRIM(CASE WHEN ISC.CHARACTER_MAXIMUM_LENGTH = -1 THEN ''MAX'' ELSE ISC.CHARACTER_MAXIMUM_LENGTH  END)+'')'' END /*產生欄位型態與長度*/        
         /*+CASE WHEN c.IS_IDENTITY = 1 THEN '' IDENTITY(1,1) '' ELSE '' '' END 判斷是否為IDENETITY*/
         +CASE WHEN c.IS_NULLABLE = 1 THEN '' NULL'' ELSE '' NOT NULL'' END   /*判斷該欄位是否為NULLABLE*/
         +CASE WHEN c.default_OBJECT_ID <> 0 THEN '' DEFAULT ''+RTRIM(CM.TEXT) ELSE '''' END  /*判斷該欄位是否存在DEFAULT VALUE*/
         ,S.NAME /*判斷表格所在之FILE GROUP*/
         ,ISC.DATA_TYPE /*DATA TYPE*/
         ,C.IS_ANSI_PADDED/*ANSI_PADDED*/
         FROM '+RTRIM(@DBNAME)+'.sys.tables T
           INNER JOIN '+RTRIM(@DBNAME)+'.sys.indexes  I ON (T.object_id=I.object_id)
           INNER JOIN '+RTRIM(@DBNAME)+'.sys.data_spaces S ON (S.data_space_id = i.data_space_id)
           INNER JOIN '+RTRIM(@DBNAME)+'.sys.columns c  ON (c.object_id = t.object_id  )
           LEFT OUTER JOIN '+RTRIM(@DBNAME)+'.SYS.SYSCOMMENTS CM ON (CM.ID = c.default_OBJECT_ID)
           INNER JOIN '+RTRIM(@DBNAME)+'.INFORMATION_SCHEMA.COLUMNS ISC ON (ISC.COLUMN_NAME=C.NAME)
         WHERE T.NAME = '''+RTRIM(@TABLENAME)+'''
           AND ISC.TABLE_NAME = '''+RTRIM(@TABLENAME)+'''
           AND ISC.TABLE_SCHEMA = '''+RTRIM(@SCHEMA)+'''
           AND I.INDEX_ID < 2 
         ORDER BY C.COLUMN_ID;
  
       OPEN TableCol; 
       FETCH NEXT FROM TableCol 
            INTO @COL_NM,@COL_INFO,@TBL_GROUPNAME,@DATA_TYPE,@ANSI_PADDED   
                                                                                                         
       WHILE @@FETCH_STATUS = 0   
       
         BEGIN 
     
           SET @SUB_SQL = @SUB_SQL + RTRIM(@COL_INFO) 
           IF  RTRIM(@DATA_TYPE) = ''CHAR''
             BEGIN
             	IF @ANSI_PADDED = ''0'' SET @IS_ANSI_PADDED = ''OFF''
              END	   
       
           FETCH NEXT FROM TableCol 
           INTO @COL_NM,@COL_INFO,@TBL_GROUPNAME,@DATA_TYPE,@ANSI_PADDED 
             
         END   

       CLOSE TableCol;                                                                                                                     
      DEALLOCATE TableCol;'
      
    BEGIN TRY
      EXECUTE sp_executesql @TBL_SCHEMA_SQL,N'@SUB_SQL VARCHAR(MAX) OUT,@TBL_GROUPNAME SYSNAME OUT,@IS_ANSI_PADDED CHAR(3) OUT',@SUB_SQL OUT,@TBL_GROUPNAME OUT,@IS_ANSI_PADDED OUT;
    END TRY
    BEGIN CATCH
        SET @ERROR_MESSAGE=ERROR_MESSAGE()
        RAISERROR(@ERROR_MESSAGE,16,1);
    END CATCH  
  
  ------------------------------
  --STEP3.2:Get FileGroup Name
  ------------------------------
  
  DECLARE @CRT_TBLINFO_SQL NVARCHAR(MAX)
  DECLARE @TBL_PF CHAR(50)
  DECLARE @TBL_FILENAME SYSNAME
 
  SET @CRT_TBLINFO_SQL =
     'SELECT @TBL_FILENAME = S5.NAME
            ,@TBL_PF = S2.NAME
     FROM '+RTRIM(@DBNAME)+'.SYS.PARTITION_SCHEMES AS S1
     JOIN '+RTRIM(@DBNAME)+'.SYS.PARTITION_FUNCTIONS AS S2 ON S1.FUNCTION_ID=S2.FUNCTION_ID
     JOIN '+RTRIM(@DBNAME)+'.SYS.PARTITION_RANGE_VALUES AS S3 ON S1.FUNCTION_ID=S3.FUNCTION_ID
     JOIN '+RTRIM(@DBNAME)+'.SYS.DESTINATION_DATA_SPACES AS S4 ON S1.DATA_SPACE_ID=S4.PARTITION_SCHEME_ID AND S3.BOUNDARY_ID+S2.boundary_value_on_right=S4.DESTINATION_ID
     JOIN '+RTRIM(@DBNAME)+'.SYS.DATA_SPACES AS S5 ON S4.DATA_SPACE_ID=S5.DATA_SPACE_ID
     WHERE S1.NAME = '''+@TBL_GROUPNAME+'''
       AND S3.VALUE = CONVERT(DATETIME,'''+CONVERT(CHAR(8),@CYCLE_START,112)+''')'
     
 BEGIN TRY
    EXECUTE sp_executesql @CRT_TBLINFO_SQL,N'@TBL_FILENAME SYSNAME OUT,@TBL_PF CHAR(50) OUT',@TBL_FILENAME OUT,@TBL_PF OUT;
  END TRY
  BEGIN CATCH      
    SET @ERROR_MESSAGE=ERROR_MESSAGE() 
    RAISERROR(@ERROR_MESSAGE,16,1);
  END CATCH;     
       
  IF @TBL_FILENAME IS NULL GOTO Main_Exit; --該Partition File已被刪除

  ------------------------------
  --STEP3.3:產生對應之Temp Table
  ------------------------------
   DECLARE @CRT_TBL_SQL NVARCHAR(MAX)
   SET @CRT_TBL_SQL 
       = 'IF EXISTS (SELECT * FROM '+RTRIM(@DBNAME)+'.DBO.sysobjects WHERE Name ='''+RTRIM(@TABLENAME)+'_SWI'' ) DROP TABLE '+RTRIM(@DBNAME)+'.'+RTRIM(@SCHEMA)+'.'+RTRIM(@TABLENAME)+'_SWI;  
          SET ANSI_PADDING '+RTRIM(@IS_ANSI_PADDED)+'
          CREATE TABLE '+RTRIM(@DBNAME)+'.'+RTRIM(@SCHEMA)+'.'+RTRIM(@TABLENAME)+'_SWI
          ('+RTRIM(@SUB_SQL)+') ON ['+RTRIM(@TBL_FILENAME)+'];'
          
   --PRINT @CRT_TBL_SQL
 
   BEGIN TRY
     EXEC SP_EXECUTESQL @CRT_TBL_SQL
   END TRY
   BEGIN CATCH
       SET @ERROR_MESSAGE=ERROR_MESSAGE()
       RAISERROR(@ERROR_MESSAGE,16,1);
   END CATCH    
   
------------------------------
-- STEP4:取得資料表格PK/INDEX之資訊
------------------------------ 

DECLARE @CRT_CONSTRAINTS_SQL1 NVARCHAR(MAX)

SET @CRT_CONSTRAINTS_SQL1=
   'CREATE TABLE #CONSTRAINTS_INFO (DBNAME CHAR(20),INDID INT ,KEYNO INT,TABLE_NAME sysname,COL_NAME sysname,PK_NAME sysname NULL,GROUPNAME sysname,COL_TYPE CHAR(3),IDX_TYPE CHAR(20) )   
    
    INSERT INTO  #CONSTRAINTS_INFO (DBNAME,INDID,KEYNO,TABLE_NAME,COL_NAME,PK_NAME,GROUPNAME,COL_TYPE,IDX_TYPE)
    SELECT '''+RTRIM(@DBNAME)+''',IC.INDEX_ID,IC.KEY_ORDINAL,T.[NAME],C.[NAME],I.NAME,S.NAME,CASE WHEN k.type = ''PK'' THEN ''PK'' ELSE ''IDX'' END,I.TYPE_DESC
    FROM  '+RTRIM(@DBNAME)+'.SYS.TABLES T
     INNER JOIN '+RTRIM(@DBNAME)+'.sys.index_columns as ic ON (ic.object_id = t.object_id)
     INNER JOIN '+RTRIM(@DBNAME)+'.sys.indexes AS I ON (i.object_id = ic.object_id AND i.index_id = ic.index_id )            
     INNER JOIN '+RTRIM(@DBNAME)+'.sys.data_spaces S ON (S.data_space_id = i.data_space_id)
     INNER JOIN '+RTRIM(@DBNAME)+'.sys.columns c on (c.object_id = t.object_id and c.column_id = ic.column_id )
     LEFT OUTER JOIN '+RTRIM(@DBNAME)+'.sys.key_constraints K ON (t.object_id = k.parent_object_id and I.name=K.name) 
   WHERE T.NAME='''+RTRIM(@TABLENAME)+'''
     AND I.NAME IS NOT NULL
   ORDER BY  ic.index_id,ic.key_ordinal
           
   ------------------------------
   -- STEP4.1:產生PK清單
   ------------------------------
   DECLARE @IDX_TYPE CHAR(20)
   DECLARE @PK_LIST VARCHAR(200)
   DECLARE @PK_COL CHAR(30) 
   DECLARE @PK_KEYNO INT
   DECLARE @PK_NAME VARCHAR(200)
   DECLARE @ERROR_MESSAGE  NVARCHAR(4000)
      
   DECLARE PKCbn CURSOR LOCAL FOR   
     SELECT distinct KEYNO,COL_NAME
     FROM #CONSTRAINTS_INFO
     WHERE DBNAME = '''+RTRIM(@DBNAME)+'''
       AND TABLE_NAME = '''+RTRIM(@TABLENAME)+'''
       AND COL_TYPE = ''PK''
     ORDER BY KEYNO; 
     
       OPEN PKCbn; 
       FETCH NEXT FROM PKCbn 
            INTO @PK_KEYNO,@PK_COL
                                                                                                         
       WHILE @@FETCH_STATUS = 0  
        
         BEGIN                           
            IF @PK_KEYNO = 1
            BEGIN 
               SET @PK_LIST = RTRIM(@PK_COL)
            END ELSE BEGIN
               SET @PK_LIST = RTRIM(@PK_LIST)+'',''+RTRIM(@PK_COL)
            END        
                
          FETCH NEXT FROM PKCbn 
          INTO @PK_KEYNO,@PK_COL
         END   
   
   CLOSE PKCbn;                                                                                                                   
  DEALLOCATE PKCbn;

   ------------------------------
   -- STEP4.2:產生PK NAME & CLUSTERED / NONCLUSTERED
   ------------------------------     
    SELECT TOP 1 @PK_NAME=PK_NAME,@IDX_TYPE=IDX_TYPE FROM #CONSTRAINTS_INFO WHERE DBNAME = '''+RTRIM(@DBNAME)+''' AND TABLE_NAME = '''+RTRIM(@TABLENAME)+''' AND COL_TYPE = ''PK'';  

   ------------------------------
   -- STEP4.3:建立PK
   ------------------------------ 
    DECLARE @CRT_PK_SQL NVARCHAR(MAX)

    SET @CRT_PK_SQL =''     
    ALTER TABLE ['+RTRIM(@DBNAME)+'].['+RTRIM(@SCHEMA)+'].['+RTRIM(@TABLENAME)+'_SWI] ADD CONSTRAINT ''+RTRIM(@PK_NAME)+''_SWI PRIMARY KEY ''+RTRIM(@IDX_TYPE)+'' (''+RTRIM(@PK_LIST)+'') ON ['+RTRIM(@TBL_FILENAME)+']''
  
    BEGIN TRY
      EXEC SP_EXECUTESQL @CRT_PK_SQL;
    END TRY
    BEGIN CATCH
      SET @ERROR_MESSAGE=ERROR_MESSAGE()
      RAISERROR(@ERROR_MESSAGE,16,1);
    END CATCH'

DECLARE @CRT_CONSTRAINTS_SQL2 NVARCHAR(MAX)  
SET @CRT_CONSTRAINTS_SQL2 ='      
   ------------------------------
   -- STEP4.4:產生Index清單
   ------------------------------ 
   
   DECLARE @INDID INT
   DECLARE @IDX_NAME VARCHAR(200)
    
   DECLARE IDXCnt CURSOR LOCAL FOR
   
     SELECT DISTINCT INDID
     FROM #CONSTRAINTS_INFO 
     WHERE DBNAME = '''+RTRIM(@DBNAME)+'''
       AND TABLE_NAME ='''+RTRIM(@TABLENAME)+'''
       AND COL_TYPE = ''IDX''
     ORDER BY INDID;
      
     OPEN IDXCnt;
     FETCH NEXT FROM IDXCnt 
     INTO @INDID
        
      WHILE @@FETCH_STATUS = 0 
        BEGIN 
         DECLARE @IDX_LIST VARCHAR(200)
         DECLARE @IDX_COL CHAR(30) 
         DECLARE @IDX_KEYNO INT
         
         DECLARE IDXCbn CURSOR LOCAL FOR 
         
           SELECT KEYNO,COL_NAME
           FROM #CONSTRAINTS_INFO
           WHERE DBNAME = '''+RTRIM(@DBNAME)+'''
             AND TABLE_NAME = '''+RTRIM(@TABLENAME)+'''
             AND INDID = @INDID
             AND COL_TYPE = ''IDX''
           ORDER BY KEYNO; 
           
             OPEN IDXCbn; 
             FETCH NEXT FROM IDXCbn 
                  INTO @IDX_KEYNO,@IDX_COL
                                                                                                               
             WHILE @@FETCH_STATUS = 0                
               BEGIN                                 
                  IF @IDX_KEYNO = 1
                  BEGIN 
                     SET @IDX_LIST = RTRIM(@IDX_COL)
                  END ELSE BEGIN
                     SET @IDX_LIST = RTRIM(@IDX_LIST)+'',''+RTRIM(@IDX_COL)
                  END                                    
                FETCH NEXT FROM IDXCbn 
                INTO @IDX_KEYNO,@IDX_COL
               END  
                         
        CLOSE IDXCbn;                                                                                                                   
       DEALLOCATE IDXCbn; 
       
   ------------------------------
   -- STEP4.5:產生INDEX NAME & CLUSTERED / NONCLUSTERED
   ------------------------------ 
    SELECT TOP 1 @IDX_NAME=PK_NAME,@IDX_TYPE=IDX_TYPE FROM #CONSTRAINTS_INFO WHERE DBNAME = '''+RTRIM(@DBNAME)+''' AND TABLE_NAME = '''+RTRIM(@TABLENAME)+''' AND INDID = @INDID AND COL_TYPE = ''IDX''  
         
   ------------------------------
   -- STEP4.6:建立INDEX
   ------------------------------ 
    DECLARE @CRT_IDX_SQL NVARCHAR(MAX)
    SET @CRT_IDX_SQL ='' 
    CREATE ''+RTRIM(@IDX_TYPE)+'' INDEX [''+RTRIM(@IDX_NAME)+''] ON '+RTRIM(@DBNAME)+'.'+RTRIM(@SCHEMA)+'.'+RTRIM(@TABLENAME)+'_SWI  (''+RTRIM(@IDX_LIST)+'') ON ['+RTRIM(@TBL_FILENAME)+']''      

    BEGIN TRY
      EXEC SP_EXECUTESQL @CRT_IDX_SQL;
    END TRY
    BEGIN CATCH
      SET @ERROR_MESSAGE=ERROR_MESSAGE()
      RAISERROR(@ERROR_MESSAGE,16,1);
    END CATCH

        FETCH NEXT FROM IDXCnt 
          INTO @INDID       
        END 
        
      CLOSE IDXCnt;                                                                                                                   
   DEALLOCATE IDXCnt;'  

   ------------------------------
   -- STEP4.7:EXECUTE SQL
   ------------------------------ 
    
    --PRINT @CRT_CONSTRAINTS_SQL1;
    --PRINT @CRT_CONSTRAINTS_SQL2;

    DECLARE @ALL_CRT_CONSTRAINTS_SQL NVARCHAR(MAX)
    SET @ALL_CRT_CONSTRAINTS_SQL  = RTRIM(@CRT_CONSTRAINTS_SQL1)+RTRIM(@CRT_CONSTRAINTS_SQL2)
    BEGIN TRY
      EXECUTE sp_executesql @ALL_CRT_CONSTRAINTS_SQL
    END TRY
    BEGIN CATCH
        SET @ERROR_MESSAGE=ERROR_MESSAGE()
        RAISERROR(@ERROR_MESSAGE,16,1);
    END CATCH  
    
------------------------------
-- STEP5:若該Table有Replication,則先卸除
------------------------------   

DECLARE @DEL_ARTICLE_SQL NVARCHAR(MAX)
DECLARE @DEL_ARTICLE_FG CHAR(1)
SET @DEL_ARTICLE_SQL = 'USE ['+RTRIM(@DBNAME)+']
                        IF EXISTS (SELECT * FROM SYS.TABLES WHERE NAME =''sysarticles'')
                          BEGIN	
                           IF EXISTS (SELECT NAME FROM sysarticles WHERE NAME = '''+RTRIM(@TABLENAME)+'''
                                      UNION ALL
                                      SELECT JOB_NAME FROM REPLMD.ODSDBA.XREPLDETAIL
                                      WHERE JOB_NAME = '''+RTRIM(@TABLENAME)+''')
                             BEGIN        
                               SET  @DEL_ARTICLE_FG = ''Y'' 
                             END
                          END;'   
                                 

BEGIN TRY
  EXEC SP_EXECUTESQL @DEL_ARTICLE_SQL,N'@DEL_ARTICLE_FG CHAR(1) OUT',@DEL_ARTICLE_FG OUT;
END TRY BEGIN CATCH
  SET @ERROR_MESSAGE=ERROR_MESSAGE()
  RAISERROR(@ERROR_MESSAGE,16,1);
END  CATCH                           
                        
   ------------------------------
   -- STEP5.1:判斷Replicaiton是否正在執行,若是等待3分鐘
   ------------------------------ 
   IF @DEL_ARTICLE_FG = 'Y'
    BEGIN
        DECLARE @STATUS CHAR(10)
        SET @STATUS = (SELECT TOP 1 ISNULL(RUN_STATUS,'') FROM REPLMD.ODSDBA.XREPLSTATUS WHERE JOB_LOCATION = @DBNAME AND JOB_NAME=@TABLENAME )
        	
          IF RTRIM(@STATUS) IN ('RUNNING','RUNSNAP','RUNDIS')
           BEGIN 
             WHILE RTRIM(@STATUS) IN ('RUNNING','RUNSNAP','RUNDIS')
               BEGIN    	     	
          	     WAITFOR DELAY '000:03:00' 
                 SET @STATUS = (SELECT ISNULL(RUN_STATUS,'') FROM REPLMD.ODSDBA.XREPLSTATUS WHERE JOB_LOCATION = @DBNAME AND JOB_NAME=@TABLENAME )
               END         	     
           END
   ------------------------------
   -- STEP5.2:卸除Replicaiton
   ------------------------------
    BEGIN TRY
      EXEC [REPLMD].[odsdba].[SP_DEL_ReplArticle] @DBNAME,@TABLENAME;  
    END TRY
    BEGIN CATCH
        SET @ERROR_MESSAGE=ERROR_MESSAGE()
        RAISERROR(@ERROR_MESSAGE,16,1);
    END CATCH                      
    END        

------------------------------
-- STEP6:Switch Partition
------------------------------  
 DECLARE @SWI_PAR_SQL NVARCHAR(MAX)
 SET @SWI_PAR_SQL = 'ALTER TABLE ['+RTRIM(@DBNAME)+'].['+RTRIM(@SCHEMA)+'].['+RTRIM(@TABLENAME)+'] SWITCH PARTITION $PARTITION.'+RTRIM(@TBL_PF)+'('''+CONVERT(CHAR(8),@CYCLE_START,112)+''') TO ['+RTRIM(@DBNAME)+'].['+RTRIM(@SCHEMA)+'].['+RTRIM(@TABLENAME)+'_SWI]'
 
 --PRINT @SWI_PAR_SQL
    
    BEGIN TRY
      EXEC SP_EXECUTESQL @SWI_PAR_SQL
    END TRY
    BEGIN CATCH
        SET @ERROR_MESSAGE=ERROR_MESSAGE()
        RAISERROR(@ERROR_MESSAGE,16,1);
    END CATCH        
    
------------------------------
-- STEP7:若該Table有Replication,則復原
------------------------------   
 IF @DEL_ARTICLE_FG = 'Y'
  BEGIN
    BEGIN TRY
        EXEC [REPLMD].[odsdba].[SP_INS_ReplArticle] @DBNAME,@TABLENAME,@TABLENAME; 
    END TRY
    BEGIN CATCH
        SET @ERROR_MESSAGE=ERROR_MESSAGE()
        RAISERROR(@ERROR_MESSAGE,16,1);
    END CATCH                           
  END  
      
------------------------------
-- STEP8:DROP TEMP TABLE
------------------------------  
 DECLARE @DRP_TBL_SQL NVARCHAR(MAX)
 SET @DRP_TBL_SQL = 'DROP TABLE ['+RTRIM(@DBNAME)+'].['+RTRIM(@SCHEMA)+'].['+RTRIM(@TABLENAME)+'_SWI]'
 
 --PRINT @DRP_TBL_SQL
   
    BEGIN TRY
      EXEC SP_EXECUTESQL @DRP_TBL_SQL
    END TRY
    BEGIN CATCH
        SET @ERROR_MESSAGE=ERROR_MESSAGE()
        RAISERROR(@ERROR_MESSAGE,16,1);
    END CATCH        
   
------------------------------
-- 結束程式
   Main_Exit:
------------------------------