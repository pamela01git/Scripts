  SET NOCOUNT ON
  USE REPLMD
  GO
  
  DECLARE @CYCLEDATE CHAR(8) 
  DECLARE @SERVERNAME CHAR(15) 
  DECLARE @JOB_LOCATION VARCHAR(100)
  DECLARE @JOB_NAME VARCHAR(150)
  DECLARE @JOB_TYPE CHAR(1)
  DECLARE @INS_TYPE CHAR(1)
  DECLARE @CLEAN_DATA_SQL NVARCHAR(MAX) 
  DECLARE @FIND_DATADT_SQL NVARCHAR(MAX) 
  DECLARE @DATADT_COL CHAR(20)
  DECLARE @ERR_NO  INT      --錯誤代碼
  DECLARE @INS_SQL1 NVARCHAR(MAX)
  DECLARE @INS_SQL2 NVARCHAR(MAX)
  
  SET @CYCLEDATE = '20070929'
  SET @SERVERNAME = 'SDW00ETD23'


 DECLARE ParamList CURSOR LOCAL  FOR 
 
  SELECT JOB_LOCATION,JOB_NAME,JOB_TYPE,INS_TYPE 
  FROM ODSDBA.XREPLDETAIL
  WHERE PROCESS_TYPE <> 'M' --不處理月檔案
    AND JOB_TYPE <> 'D' --不處理control job
    AND JOB_NAME <> 'ODS_CC_SCMCACCP'
  ORDER BY JOB_LOCATION,JOB_NAME;

OPEN ParamList; 
FETCH NEXT FROM ParamList 
     INTO @JOB_LOCATION,@JOB_NAME,@JOB_TYPE,@INS_TYPE     
                                                                                                  
WHILE @@FETCH_STATUS = 0   

  BEGIN 
  	
   --找出INSERT之COLUMN清單 	
     DECLARE @CRT_TBLINFO_SQL NVARCHAR(MAX)

    IF EXISTS (SELECT * FROM TEMPDB.DBO.sysobjects WHERE Name ='##TBL_SCHEMA') DROP TABLE ##TBL_SCHEMA;    
    CREATE TABLE ##TBL_SCHEMA ( COLID INT,COL_NM CHAR(40),COL_INFO VARCHAR(1000),TBL_GROUPNAME SYSNAME)
    
    SET @CRT_TBLINFO_SQL 
      ='INSERT INTO ##TBL_SCHEMA (COLID,COL_NM,COL_INFO,TBL_GROUPNAME)
        SELECT C.COLUMN_ID --欄位序號
        ,c.NAME --欄位名稱
        ,CASE WHEN C.COLUMN_ID <> 1 THEN '', '' ELSE ''  '' END --若非第一個欄位則加分隔符號,
       +''[''+RTRIM(c.NAME)+''] ''+ CASE WHEN ISC.DATA_TYPE in (''int'',''smallint'',''bigint'',''bit'',''datetime'',''text'',''sysname'',''tinyint'',''uniqueidentifier'',''float'') THEN UPPER(ISC.DATA_TYPE) WHEN ISC.DATA_TYPE IN (''numeric'',''decimal'') THEN  UPPER(ISC.DATA_TYPE)+''(''+RTRIM(ISC.NUMERIC_PRECISION)+'',''+RTRIM(ISC.NUMERIC_SCALE)+'')'' ELSE UPPER(ISC.DATA_TYPE)+''(''+RTRIM(CASE WHEN ISC.CHARACTER_MAXIMUM_LENGTH = -1 THEN ''MAX'' ELSE ISC.CHARACTER_MAXIMUM_LENGTH  END)+'')'' END --產生欄位型態與長度        
       +CASE WHEN c.IS_IDENTITY = 1 THEN '' IDENTITY(1,1) '' ELSE '' '' END --判斷是否為IDENETITY
       +CASE WHEN c.IS_NULLABLE = 1 THEN ''NULL'' ELSE ''NOT NULL'' END   --判斷該欄位是否為NULLABLE
       +CASE WHEN c.default_OBJECT_ID <> 0 THEN '' DEFAULT ''+RTRIM(CM.TEXT) ELSE '''' END  --判斷該欄位是否存在DEFAULT VALUE
      ,S.NAME --判斷表格所在之FILE GROUP
       FROM '+RTRIM(@JOB_LOCATION)+'.sys.tables T
         INNER JOIN '+RTRIM(@JOB_LOCATION)+'.sys.indexes  I ON (T.object_id=I.object_id)
         INNER JOIN '+RTRIM(@JOB_LOCATION)+'.sys.data_spaces S ON (S.data_space_id = i.data_space_id)
         INNER JOIN '+RTRIM(@JOB_LOCATION)+'.sys.columns c  ON (c.object_id = t.object_id  )
         LEFT OUTER JOIN '+RTRIM(@JOB_LOCATION)+'.SYS.SYSCOMMENTS CM ON (CM.ID = c.default_OBJECT_ID)
         INNER JOIN '+RTRIM(@JOB_LOCATION)+'.INFORMATION_SCHEMA.COLUMNS ISC ON (ISC.COLUMN_NAME=C.NAME)
       WHERE T.NAME = '''+RTRIM(@JOB_NAME)+'''
         AND ISC.TABLE_NAME = '''+RTRIM(@JOB_NAME)+'''
         AND ISC.TABLE_SCHEMA = ''ODSDBA''
         AND I.INDEX_ID < 2 
       ORDER BY C.COLUMN_ID;' 
       
     -- PRINT @CRT_TBLINFO_SQL 
     EXEC (@CRT_TBLINFO_SQL)


     --產生欄位資訊SQL STATEMENT
     DECLARE @COL_NM CHAR(40)
     DECLARE @COL_INFO VARCHAR(1000)
     DECLARE @TBL_GROUPNAME SYSNAME
     DECLARE @SURCOL_FG CHAR(1) 
     DECLARE @SUB_SQL  VARCHAR(MAX)
     DECLARE @INS_LIST VARCHAR(MAX)
     DECLARE @TAR_LIST VARCHAR(MAX)
     DECLARE @TMP_CNT INT
     
     
     SET @TAR_LIST = '';--初始值
     SET @TMP_CNT = 2   --初始值由2開始 
     
      DECLARE TableCol CURSOR LOCAL  FOR 
      
         SELECT  '['+RTRIM(S1.COL_NM)+']',S1.COL_INFO
         FROM ##TBL_SCHEMA S1
         ORDER BY S1.COLID;
      
      OPEN TableCol; 
      FETCH NEXT FROM TableCol 
           INTO @COL_NM,@COL_INFO   
                                                                                                        
      WHILE @@FETCH_STATUS = 0   
      
        BEGIN 
            
            IF @COL_INFO NOT LIKE '%IDENTITY(1,1)%' --INSERT TABLE時不處理IDENTITY欄位
              BEGIN
                 SET @TAR_LIST = @TAR_LIST +','+RTRIM(@COL_NM)
              END
      
          FETCH NEXT FROM TableCol 
          INTO @COL_NM,@COL_INFO  
            
        END   
           
      CLOSE TableCol;                                                                                                                     
     DEALLOCATE TableCol;
     
      --將最左邊第一個,清除
       SET @TAR_LIST = SUBSTRING(@TAR_LIST,2,LEN(RTRIM(@TAR_LIST))-1) 	
      		
  --DELETE DATA BEFORE INSERT	
    IF @INS_TYPE IN ('T','IT')
      BEGIN
      	 SET @CLEAN_DATA_SQL = 'TRUNCATE TABLE '+RTRIM(@JOB_LOCATION)+'.ODSDBA.'+RTRIM(@JOB_NAME)+';'
      END ELSE BEGIN
      	
      	  SET @FIND_DATADT_SQL = 'IF EXISTS (SELECT * FROM '+RTRIM(@JOB_LOCATION)+'.sys.columns c, '+RTRIM(@JOB_LOCATION)+'.sys.tables t where c.object_id = t.object_id and t.name ='''+RTRIM(@JOB_NAME)+''' AND c.name =''datadt'')
                                  BEGIN
                                  	SET @DATADT_COL = ''DATADT''
                                  END ELSE BEGIN
                                  	SET @DATADT_COL = ( SELECT C.NAME FROM '+RTRIM(@JOB_LOCATION)+'.sys.columns c, '+RTRIM(@JOB_LOCATION)+'.sys.tables t, '+RTRIM(@JOB_LOCATION)+'.sys.types p where c.object_id = t.object_id and c.system_type_id = p.system_type_id and t.name = '''+RTRIM(@JOB_NAME)+''' and p.name =''datetime'' AND C.COLUMN_ID = 1 )
                                  END;SELECT @ERR_NO =@@ERROR;'
                   
      BEGIN TRY                    
        EXECUTE sp_executesql @FIND_DATADT_SQL,N'@ERR_NO INT OUT,@DATADT_COL CHAR(20) OUT',@ERR_NO OUT,@DATADT_COL OUT;
      END TRY
      BEGIN CATCH      
        RAISERROR(@ERR_NO, 16, 1);
      END CATCH       
           
      	  SET @CLEAN_DATA_SQL = 'DELETE FROM '+RTRIM(@JOB_LOCATION)+'.ODSDBA.'+RTRIM(@JOB_NAME)+' WHERE '+RTRIM(@DATADT_COL) +'='''+RTRIM(@CYCLEDATE)+''';'                  
             
      END

       PRINT 'PRINT ''START JOB: '+RTRIM(@JOB_LOCATION)+''+'.ODSDBA.'+RTRIM(@JOB_NAME)+''''
       PRINT @CLEAN_DATA_SQL 
       
  --INSERT DATA
    IF @JOB_TYPE IN ('S','T')
     BEGIN
     	IF @INS_TYPE IN ('T','IT')
     	 BEGIN
     	   SET @INS_SQL1 = 'INSERT INTO '+RTRIM(@JOB_LOCATION)+'.ODSDBA.'+RTRIM(@JOB_NAME)+'( '+RTRIM(@TAR_LIST)+') '
     	   SET @INS_SQL2 = 'SELECT '+RTRIM(@TAR_LIST)+' FROM '+RTRIM(@SERVERNAME)+'.'+RTRIM(@JOB_LOCATION)+'.ODSDBA.'+RTRIM(@JOB_NAME)+';'
     	 END ELSE BEGIN
     	   SET @INS_SQL1 = 'INSERT INTO '+RTRIM(@JOB_LOCATION)+'.ODSDBA.'+RTRIM(@JOB_NAME)+'( '+RTRIM(@TAR_LIST)+') '
     	   SET @INS_SQL2 = 'SELECT '+RTRIM(@TAR_LIST)+' FROM '+RTRIM(@SERVERNAME)+'.'+RTRIM(@JOB_LOCATION)+'.ODSDBA.'+RTRIM(@JOB_NAME)+' WHERE '+RTRIM(@DATADT_COL) +'='''+RTRIM(@CYCLEDATE)+''';'     	 	
     	END  	   
     END    
     
     
      PRINT @INS_SQL1
      PRINT @INS_SQL2


    FETCH NEXT FROM ParamList 
    INTO @JOB_LOCATION,@JOB_NAME,@JOB_TYPE,@INS_TYPE   
      
  END   

 CLOSE ParamList;                                                                                                                     
 DEALLOCATE ParamList;
