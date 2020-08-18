
  declare  @DBNAME     CHAR(20) = 'ASE',

    @TABLENAME  CHAR(30)= 'EDA_LIST'


------------------------------
-- STEP1:若TABLE已存在則跳出程式
------------------------------  
    
DECLARE @CHK_EXISTS_SQL NVARCHAR(4000)
DECLARE @EXIST_FG CHAR(1)
DECLARE @ERROR_MESSAGE  NVARCHAR(4000) --錯誤訊息
  	
  SET @CHK_EXISTS_SQL = 'IF EXISTS (SELECT * FROM '+RTRIM(@DBNAME)+'.DBO.sysobjects WHERE Name ='''+RTRIM(@TABLENAME)+''' ) 
                           BEGIN
                           	SET @EXIST_FG = ''Y''
                           END ELSE BEGIN
                           	SET @EXIST_FG = ''N''
                           END'
 
  --PRINT @CHK_EXISTS_SQL
  
  BEGIN TRY
    EXECUTE sp_executesql @CHK_EXISTS_SQL,N'@EXIST_FG CHAR(1) OUT',@EXIST_FG OUT;
  END TRY
  BEGIN CATCH      
  SET @ERROR_MESSAGE=ERROR_MESSAGE() 
  RAISERROR(@ERROR_MESSAGE,16,1);; 
  END CATCH 
  
 --SELECT @EXIST_FG;
 
 --IF @EXIST_FG = 'Y' GOTO Main_Exit
 
------------------------------
-- STEP2:以TABLE NAME找出TALBE SCHEMA
------------------------------      	
DECLARE @FIND_SCHEMA_SQL NVARCHAR(4000)
DECLARE @SCHEMA CHAR(20) --TABLE SCHEMA

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
  RAISERROR(@ERROR_MESSAGE,16,1);; 
END CATCH   


------------------------------
-- STEP3:產生資料表格SCHEMA相關資訊
------------------------------

DECLARE @CRT_TBLINFO_SQL NVARCHAR(MAX)

     IF EXISTS (SELECT * FROM TEMPDB.DBO.sysobjects WHERE Name ='##TBL_SCHEMA') DROP TABLE ##TBL_SCHEMA;     
    CREATE TABLE ##TBL_SCHEMA ( COLID INT,COL_NM CHAR(40),COL_INFO VARCHAR(1000),TBL_GROUPNAME SYSNAME)
    
    SET @CRT_TBLINFO_SQL 
      ='INSERT INTO ##TBL_SCHEMA (COLID,COL_NM,COL_INFO,TBL_GROUPNAME)
        SELECT C.COLUMN_ID --欄位序號
        ,c.NAME --欄位名稱
        ,CASE WHEN C.COLUMN_ID <> 1 THEN '', '' ELSE ''  '' END --若非第一個欄位則加分隔符號,
       +''[''+RTRIM(c.NAME)+''] ''+ CASE WHEN ISC.DATA_TYPE in (''int'',''smallint'',''bigint'',''bit'',''datetime'',''text'',''sysname'',''tinyint'',''uniqueidentifier'',''float'') THEN UPPER(ISC.DATA_TYPE) WHEN ISC.DATA_TYPE IN (''numeric'',''decimal'') THEN  UPPER(ISC.DATA_TYPE)+''(''+RTRIM(ISC.NUMERIC_PRECISION)+'',''+RTRIM(ISC.NUMERIC_SCALE)+'')'' ELSE UPPER(ISC.DATA_TYPE)+''(''+RTRIM(CASE WHEN ISC.CHARACTER_MAXIMUM_LENGTH = -1 THEN ''MAX'' ELSE ISC.CHARACTER_MAXIMUM_LENGTH  END)+'')'' END --產生欄位型態與長度        
       /*+CASE WHEN c.IS_IDENTITY = 1 THEN '' IDENTITY(1,1) '' ELSE '' '' END --判斷是否為IDENETITY*/
       +CASE WHEN c.IS_NULLABLE = 1 THEN '' NULL'' ELSE '' NOT NULL'' END   --判斷該欄位是否為NULLABLE
       +CASE WHEN c.default_OBJECT_ID <> 0 THEN '' DEFAULT ''+RTRIM(CM.TEXT) ELSE '''' END  --判斷該欄位是否存在DEFAULT VALUE
      ,S.NAME --判斷表格所在之FILE GROUP
       FROM '+RTRIM(@DBNAME)+'.sys.tables T
         INNER JOIN '+RTRIM(@DBNAME)+'.sys.indexes  I ON (T.object_id=I.object_id)
         INNER JOIN '+RTRIM(@DBNAME)+'.sys.data_spaces S ON (S.data_space_id = i.data_space_id)
         INNER JOIN '+RTRIM(@DBNAME)+'.sys.columns c  ON (c.object_id = t.object_id  )
         LEFT OUTER JOIN '+RTRIM(@DBNAME)+'.SYS.SYSCOMMENTS CM ON (CM.ID = c.default_OBJECT_ID)
         INNER JOIN '+RTRIM(@DBNAME)+'.INFORMATION_SCHEMA.COLUMNS ISC ON (ISC.COLUMN_NAME=C.NAME)
       WHERE T.NAME = '''+RTRIM(@TABLENAME)+'''
         AND ISC.TABLE_NAME = '''+RTRIM(@TABLENAME)+'''
         AND I.INDEX_ID < 2 
       ORDER BY C.COLUMN_ID;' 
       
      --PRINT @CRT_TBLINFO_SQL 
      EXEC (@CRT_TBLINFO_SQL) 
            
------------------------------
-- STEP4:建立相對應之暫存表格
------------------------------

 --STEP4.1:產生欄位資訊SQL STATEMENT
 DECLARE @COL_NM CHAR(40)
 DECLARE @COL_INFO VARCHAR(1000)
 DECLARE @TBL_GROUPNAME SYSNAME
 DECLARE @SUB_SQL  VARCHAR(MAX)
 DECLARE @CRT_TBL_SQL NVARCHAR(MAX)
 
 SET @SUB_SQL = '';--初始值 
 
  DECLARE TableCol CURSOR LOCAL  FOR 
  
     SELECT  S1.COL_NM,S1.COL_INFO,'['+S1.TBL_GROUPNAME+']'         
     FROM ##TBL_SCHEMA S1
     ORDER BY S1.COLID;
  
  OPEN TableCol; 
  FETCH NEXT FROM TableCol 
       INTO @COL_NM,@COL_INFO,@TBL_GROUPNAME   
                                                                                                    
  WHILE @@FETCH_STATUS = 0   
  
    BEGIN 

      SET @SUB_SQL = @SUB_SQL + RTRIM(@COL_INFO)        
  
      FETCH NEXT FROM TableCol 
      INTO @COL_NM,@COL_INFO,@TBL_GROUPNAME
        
    END   
       
  CLOSE TableCol;                                                                                                                     
 DEALLOCATE TableCol;
  
 --STEP4.2:建立相對應之暫存表格
 
  DECLARE @ERR_NO  INT      --錯誤代碼


   SET @CRT_TBL_SQL 
       = 'IF EXISTS (SELECT * FROM '+RTRIM(@DBNAME)+'.DBO.sysobjects WHERE Name ='''+RTRIM(@TABLENAME)+''' ) DROP TABLE '+RTRIM(@DBNAME)+'.'+RTRIM(@SCHEMA)+'.'+RTRIM(@TABLENAME)+'; 
          CREATE TABLE '+RTRIM(@DBNAME)+'.'+RTRIM(@SCHEMA)+'.'+RTRIM(@TABLENAME)+'
          ('+RTRIM(@SUB_SQL)+');'
          
   PRINT @CRT_TBL_SQL
 
   BEGIN TRY
     EXEC @ERR_NO = SP_EXECUTESQL @CRT_TBL_SQL,N'@ERR_NO INT OUT',@ERR_NO OUT
   END TRY
   BEGIN CATCH
       SET @ERROR_MESSAGE=ERROR_MESSAGE()
       RAISERROR(@ERROR_MESSAGE,16,1);
   END CATCH    
   
------------------------------
-- STEP5:取得資料表格PK/INDEX之資訊
------------------------------ 

DECLARE @CHK_IDX_SQL NVARCHAR(MAX)

 --判斷是否存在##PK_TBL_INFO
   IF EXISTS (SELECT * FROM TEMPDB.DBO.sysobjects WHERE Name ='##PK_TBL_INFO') DROP TABLE ##PK_TBL_INFO
   CREATE TABLE ##PK_TBL_INFO (DBNAME CHAR(20),INDID INT ,KEYNO INT,TABLE_NAME sysname,COL_NAME sysname,PK_NAME sysname NULL,GROUPNAME sysname,COL_TYPE CHAR(3),IDX_TYPE CHAR(20) )   
   
 --判斷是否存在該表格之相關資訊
   IF NOT EXISTS (SELECT * FROM ##PK_TBL_INFO WHERE DBNAME =@DBNAME AND TABLE_NAME = @TABLENAME)
     BEGIN
       SET @CHK_IDX_SQL
         ='INSERT INTO  ##PK_TBL_INFO (DBNAME,INDID,KEYNO,TABLE_NAME,COL_NAME,PK_NAME,GROUPNAME,COL_TYPE,IDX_TYPE)
           SELECT '''+RTRIM(@DBNAME)+''',IC.INDEX_ID,IC.KEY_ORDINAL,T.[NAME],C.[NAME],I.NAME,S.NAME/*,CASE WHEN k.unique_index_id IS NOT NULL THEN ''PK'' ELSE ''IDX'' END*/
           ,CASE WHEN k.type = ''PK'' THEN ''PK'' ELSE ''IDX'' END
           ,I.TYPE_DESC
           FROM  '+RTRIM(@DBNAME)+'.SYS.TABLES T
            INNER JOIN '+RTRIM(@DBNAME)+'.sys.index_columns as ic ON (ic.object_id = t.object_id)
            INNER JOIN '+RTRIM(@DBNAME)+'.sys.indexes AS I ON (i.object_id = ic.object_id AND i.index_id = ic.index_id )            
            INNER JOIN '+RTRIM(@DBNAME)+'.sys.data_spaces S ON (S.data_space_id = i.data_space_id)
            INNER JOIN '+RTRIM(@DBNAME)+'.sys.columns c on (c.object_id = t.object_id and c.column_id = ic.column_id )
            LEFT OUTER JOIN '+RTRIM(@DBNAME)+'.sys.key_constraints K ON (t.object_id = k.parent_object_id and I.name=K.name) 
          WHERE T.NAME='''+RTRIM(@TABLENAME)+'''
            AND I.NAME IS NOT NULL
          ORDER BY  ic.index_id,ic.key_ordinal;SELECT @ERR_NO =@@ERROR;'
          
           -- PRINT @CHK_IDX_SQL   
             BEGIN TRY
                 EXEC @ERR_NO = SP_EXECUTESQL @CHK_IDX_SQL,N'@ERR_NO INT OUT',@ERR_NO OUT ;
             END TRY
             BEGIN CATCH
                 SET @ERROR_MESSAGE=ERROR_MESSAGE()
                 RAISERROR(@ERROR_MESSAGE,16,1);
             END CATCH  
     END     
           
------------------------------
-- STEP6:建立PK
------------------------------

  DECLARE @IDX_TYPE CHAR(20)
                   
 --STEP6.1:產生PK清單
 IF EXISTS (SELECT * FROM ##PK_TBL_INFO WHERE DBNAME = @DBNAME AND TABLE_NAME = @TABLENAME AND COL_TYPE = 'PK')
   BEGIN
 
      DECLARE @PK_LIST VARCHAR(200)
      DECLARE @PK_COL CHAR(30) 
      DECLARE @PK_KEYNO INT
      DECLARE @PK_NAME VARCHAR(200) --PK(CONSTRAINT) NAME
      DECLARE @CRT_PK_SQL NVARCHAR(MAX)
      
      --PKCbn name
      DECLARE PKCbn CURSOR LOCAL FOR 
        SELECT distinct KEYNO,COL_NAME
        FROM ##PK_TBL_INFO
        WHERE DBNAME = @DBNAME
          AND TABLE_NAME = @TABLENAME
          AND COL_TYPE = 'PK'
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
            SET @PK_LIST = RTRIM(@PK_LIST)+','+RTRIM(@PK_COL)
         END
      
             
         FETCH NEXT FROM PKCbn 
         INTO @PK_KEYNO,@PK_COL
      END   
      
      CLOSE PKCbn;                                                                                                                   
     DEALLOCATE PKCbn;
     
  --STEP6.2:產生PK CONSTRANT NAME & CLUSTERED / NONCLUSTERED
    SELECT TOP 1 @PK_NAME=PK_NAME,@IDX_TYPE=IDX_TYPE FROM ##PK_TBL_INFO WHERE DBNAME = @DBNAME AND TABLE_NAME = @TABLENAME AND COL_TYPE = 'PK'  

  --STEP6.3:建立PK
    SET @CRT_PK_SQL ='ALTER TABLE '+RTRIM(@DBNAME)+'.'+RTRIM(@SCHEMA)+'.'+RTRIM(@TABLENAME)+' ADD CONSTRAINT '+RTRIM(@PK_NAME)+' PRIMARY KEY '+RTRIM(@IDX_TYPE)+' ('+RTRIM(@PK_LIST)+') ;SELECT @ERR_NO =@@ERROR;'
    PRINT @CRT_PK_SQL
    
    BEGIN TRY
      EXEC @ERR_NO = SP_EXECUTESQL @CRT_PK_SQL,N'@ERR_NO INT OUT',@ERR_NO OUT;
    END TRY
    BEGIN CATCH
        SET @ERROR_MESSAGE=ERROR_MESSAGE()
        RAISERROR(@ERROR_MESSAGE,16,1);
    END  CATCH   
     
 END 

------------------------------
-- STEP7:建立INDEX
------------------------------  
  
 --STEP7.1:產生INDEX清單
 IF EXISTS (SELECT * FROM ##PK_TBL_INFO WHERE DBNAME = @DBNAME AND TABLE_NAME = @TABLENAME AND COL_TYPE = 'IDX')
  BEGIN
   
   DECLARE @INDID INT
   DECLARE @IDX_NAME VARCHAR(200) --INDEX(CONSTRAINT) NAME
   DECLARE @CRT_IDX_SQL NVARCHAR(MAX)
    
   DECLARE IDXCnt CURSOR LOCAL FOR
     SELECT DISTINCT INDID
     FROM ##PK_TBL_INFO 
     WHERE DBNAME = @DBNAME
       AND TABLE_NAME = @TABLENAME
       AND COL_TYPE = 'IDX'
     ORDER BY INDID;
      
      OPEN IDXCnt;
      FETCH NEXT FROM IDXCnt 
        INTO @INDID
        
      WHILE @@FETCH_STATUS = 0 
        BEGIN
 
         DECLARE @IDX_LIST VARCHAR(200)
         DECLARE @IDX_col CHAR(30) 
         DECLARE @IDX_KEYNO INT
         
         --IDXCbn name
         DECLARE IDXCbn CURSOR LOCAL FOR 
           SELECT KEYNO,COL_NAME
           FROM ##PK_TBL_INFO
           WHERE DBNAME = @DBNAME
             AND TABLE_NAME = @TABLENAME
             AND INDID = @INDID
             AND COL_TYPE = 'IDX'
           ORDER BY KEYNO; 
           
             OPEN IDXCbn; 
             FETCH NEXT FROM IDXCbn 
                  INTO @IDX_KEYNO,@IDX_col
                                                                                                               
             WHILE @@FETCH_STATUS = 0  
              
         BEGIN 
                          
            IF @IDX_KEYNO = 1
            BEGIN 
               SET @IDX_LIST = RTRIM(@IDX_COL)
            END ELSE BEGIN
               SET @IDX_LIST = RTRIM(@IDX_LIST)+','+RTRIM(@IDX_COL)
            END
         
                
            FETCH NEXT FROM IDXCbn 
            INTO @IDX_KEYNO,@IDX_col
         END   
         
        CLOSE IDXCbn;                                                                                                                   
       DEALLOCATE IDXCbn; 
       
  --STEP7.2:產生INDEX CONSTRAINT NAME
    SELECT TOP 1 @IDX_NAME=PK_NAME,@IDX_TYPE=IDX_TYPE FROM ##PK_TBL_INFO WHERE DBNAME = @DBNAME AND TABLE_NAME = @TABLENAME AND INDID = @INDID AND COL_TYPE = 'IDX'  
         
  --STEP7.3:建立INDEX
    SET @CRT_IDX_SQL = 'CREATE '+RTRIM(@IDX_TYPE)+' INDEX ['+RTRIM(@IDX_NAME)+'] ON '+RTRIM(@DBNAME)+'.'+RTRIM(@SCHEMA)+'.'+RTRIM(@TABLENAME)+' ('+RTRIM(@IDX_LIST)+') ;SELECT @ERR_NO =@@ERROR;'
    PRINT @CRT_IDX_SQL
    
    BEGIN TRY
      EXEC @ERR_NO = SP_EXECUTESQL @CRT_IDX_SQL,N'@ERR_NO INT OUT',@ERR_NO OUT
    END TRY
    BEGIN CATCH
        SET @ERROR_MESSAGE=ERROR_MESSAGE()
        RAISERROR(@ERROR_MESSAGE,16,1);
    END   CATCH        
         
        FETCH NEXT FROM IDXCnt 
          INTO @INDID       
        END 
        
      CLOSE IDXCnt;                                                                                                                   
   DEALLOCATE IDXCnt;  
 
 END 


------------------------------
-- 結束程式
   Main_Exit:
------------------------------