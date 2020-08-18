USE [ISMD]
GO
/****** Object:  StoredProcedure [odsdba].[SP_INS_XBATCHFLOW_MVE]    Script Date: 12/29/2008 11:13:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [odsdba].[SP_INS_XBATCHFLOW_MVE]
    @CYCLE_START DATETIME,
    @CYCLE_END  DATETIME
AS
------------------------------
-- 程式說明
------------------------------
-- 1.將資料搬移作業(MVEM)之Job清單載入XBATCHFLOW


------------------------------
-- STEP1:MOVE DATA TO XBATCHFLOWH
------------------------------
DECLARE @DATACAT CHAR(10)
DECLARE @START_MODE CHAR(7)
SET @DATACAT = 'MVEM'
SET @START_MODE = (SELECT START_MODE FROM odsdba.XFLOWSTATUS WHERE DATACAT=@DATACAT)
EXEC [odsdba].[SP_INS_Xbatchflowh_Xbatchflow] @START_MODE,@DATACAT;

  ------------------------------
  -- STEP1.1:若為RESTAR則結束程式
  ------------------------------ 
  IF @START_MODE = 'RESTART' GOTO  Main_Exit;  

------------------------------
-- STEP2:XBATCHFLOW固定變數
------------------------------
DECLARE @DBNAME CHAR(20)
DECLARE @BATCHNO INT
DECLARE @PROCESS_TYPE CHAR(3)
DECLARE @FLOW INT
DECLARE @FLOW_NAME CHAR(50)
DECLARE @RUN_STATUS CHAR(7)
DECLARE @JOB_START_TIME DATETIME
DECLARE @JOB_END_TIME DATETIME
DECLARE @SKIP_FLAG CHAR(1)
DECLARE @JOB_DESC VARCHAR(255)
DECLARE @EXEC_DESC VARCHAR(8000)
DECLARE @ERROR_MESSAGE  NVARCHAR(4000) --錯誤訊息

SET @BATCHNO = CONVERT(CHAR(8),@CYCLE_END,112)
SET @PROCESS_TYPE = 'M'
SET @RUN_STATUS = ''
SET @JOB_START_TIME = NULL
SET @JOB_END_TIME = NULL
SET @SKIP_FLAG = 'N'
SET @JOB_DESC = ''
SET @EXEC_DESC = ''

------------------------------
-- STEP3:依DB產生XBATCHFLOW
------------------------------

  DECLARE DBList CURSOR LOCAL  FOR 
  
     SELECT 'ODSDB' AS DBNAME
     UNION ALL        
     SELECT 'DWBasisDB' AS DBNAME;
  
  OPEN DBList; 
  FETCH NEXT FROM DBList 
       INTO @DBNAME   
                                                                                                    
  WHILE @@FETCH_STATUS = 0   
  
    BEGIN 
      ------------------------------
      -- STEP3.1:INSERT FLOW LEVEL DATA
      ------------------------------      
      SET @FLOW_NAME = CASE WHEN @DBNAME ='ODSDB' THEN 'RunJobFlowMODSM' WHEN @DBNAME ='DWBasisDB' THEN 'RunJobFlowMDWM' END 
      SET @FLOW = CASE WHEN @DBNAME ='ODSDB' THEN '1' WHEN @DBNAME ='DWBasisDB' THEN '2' END             
      INSERT INTO odsdba.XBATCHFLOW
      SELECT RTRIM(@DATACAT),RTRIM(@BATCHNO),CONVERT(CHAR(8),@CYCLE_START,112),CONVERT(CHAR(8),@CYCLE_END,112),RTRIM(@PROCESS_TYPE),@DATACAT,@FLOW,1,RTRIM(@FLOW_NAME),RTRIM(@START_MODE),@JOB_START_TIME,@JOB_END_TIME,RTRIM(@RUN_STATUS),'',RTRIM(@SKIP_FLAG),'Y','D',RTRIM(@JOB_DESC),'\JobControl','odsdba',@EXEC_DESC    	
  
      ------------------------------
      -- STEP3.2:依TABLE產生XBATCHFLOW
      ------------------------------      
      DECLARE @INS_JOB_SQL NVARCHAR(MAX)   
      SET @INS_JOB_SQL = '
             DECLARE @SEQ AS INT
             DECLARE @MAX_SEQ INT
             DECLARE @TABLENAME AS VARCHAR(150) 
             DECLARE @TMNBDT CHAR(8)
             DECLARE @TMNEDT CHAR(8)
             DECLARE @SCHEMA CHAR(10)
             DECLARE @PARTITION_NUMBER INT            
             DECLARE @MEM_CNT INT
             
                   ------------------------------
                   -- STEP3.2.1:決定每個FLOW有幾隻JOB
                   ------------------------------    
                   
                   SET @MEM_CNT = 10 
                                                                  
             DECLARE TABLEList CURSOR LOCAL  FOR 
               
             SELECT ROW_NUMBER() OVER( ORDER BY A.TMNBDT,A.TABLE_NAME) AS ''SEQ''
                   ,A.TABLE_NAME
                   ,A.TMNBDT
                   ,A.TMNEDT
                   ,A.SCHEMA_NAME
                   ,A.PARTITION_NUMBER                   
            FROM  (SELECT t.NAME AS TABLE_NAME,S.NAME AS SCHEMA_NAME,CONVERT(CHAR(8),D.TMNBDT,112) AS TMNBDT,CONVERT(CHAR(8),D.TMNEDT,112) AS TMNEDT ,P.PARTITION_NUMBER 
                   FROM '+RTRIM(@DBNAME)+'.SYS.TABLES t INNER JOIN '+RTRIM(@DBNAME)+'.sys.schemas s ON (s.schema_id=t.schema_id) INNER JOIN odsdba.CB_DT D ON (1=1)
                     INNER JOIN (SELECT OBJECT_ID,MAX(PARTITION_NUMBER) AS PARTITION_NUMBER FROM ( SELECT S2.OBJECT_ID,PARTITION_NUMBER FROM '+RTRIM(@DBNAME)+'.sys.partitions S1 INNER JOIN '+RTRIM(@DBNAME)+'.SYS.TABLES S2 ON (S1.OBJECT_ID=S2.OBJECT_ID)) p GROUP BY OBJECT_ID) p on (p.OBJECT_ID=t.OBJECT_ID)
                   WHERE  ((   t.NAME LIKE ''%[_]MH'' OR t.NAME LIKE ''%[_]MS'' OR t.NAME LIKE ''%[_]MA'' OR t.NAME LIKE ''TX[_]%'' OR t.NAME LIKE ''%[_]DH''
                            OR t.NAME LIKE ''ODSMS[_]%'' OR t.NAME IN (''CS_Pcust_CCardRFM'',''CS_Pcust_FaciAggt'',''CS_Pcust_MgtInfoRFM'',''CS_Pcust_SecuAggt'',''CS_PAcct1DW_LN'',''CS_PBrPd_LN''))
                     AND D.BBOM_FG =''Y''   
                     AND D.DATADT BETWEEN '''+RTRIM(CONVERT(CHAR(8),@CYCLE_START,112))+''' AND '''+RTRIM(CONVERT(CHAR(8),@CYCLE_END,112))+''')) A
             
             OPEN TABLEList; 
             FETCH NEXT FROM TABLEList 
                  INTO @SEQ,@TABLENAME,@TMNBDT,@TMNEDT,@SCHEMA,@PARTITION_NUMBER   
                                                                                                               
             WHILE @@FETCH_STATUS = 0   
             
               BEGIN 
               	               	               	
               	DECLARE @JOB_STAGE CHAR(10)               	
               	SET @JOB_STAGE = SUBSTRING('''+RTRIM(@FLOW_NAME)+''',11,LEN(RTRIM('''+RTRIM(@FLOW_NAME)+'''))-11)+'''+RTRIM(@PROCESS_TYPE)+'''
     
                   ------------------------------
                   -- STEP3.2.1:INSERT SUBFLOW LEVEL DATA
                   ------------------------------     
                   IF @SEQ % @MEM_CNT = 1
                   BEGIN 
                     DECLARE @SUBFLOW_NAME CHAR(50) 
                     SET @SUBFLOW_NAME = SUBSTRING('''+RTRIM(@FLOW_NAME)+''',11,LEN(RTRIM('''+RTRIM(@FLOW_NAME)+'''))-11)+''_Flow''+CONVERT(VARCHAR,(@SEQ/@MEM_CNT)+1)	
                     INSERT INTO odsdba.XBATCHFLOW
                     SELECT '''+RTRIM(@DATACAT)+''','''+RTRIM(@BATCHNO)+''',@TMNBDT,@TMNEDT,'''+RTRIM(@PROCESS_TYPE)+''',RTRIM(@JOB_STAGE),((@SEQ-1)/@MEM_CNT)+1,''1'',RTRIM(@SUBFLOW_NAME),'''+RTRIM(@START_MODE)+''',NULL,NULL,'''+RTRIM(@RUN_STATUS)+''','''','''+RTRIM(@SKIP_FLAG)+''',''Y'',''D'','''+RTRIM(@JOB_DESC)+''',''\JobControl'',''odsdba'',''''
                   END
 
                   ------------------------------
                   -- STEP3.2.2:INSERT JOB LEVEL DATA
                   ------------------------------    
                   DECLARE @JOB_SEQ INT     
                   SET @JOB_SEQ = CASE WHEN @SEQ%@MEM_CNT <> 0 THEN (@SEQ%@MEM_CNT)+1 ELSE @MEM_CNT+1 END     
                   INSERT INTO odsdba.XBATCHFLOW
                   SELECT '''+RTRIM(@DATACAT)+''','''+RTRIM(@BATCHNO)+''',@TMNBDT,@TMNEDT,'''+RTRIM(@PROCESS_TYPE)+''',RTRIM(@JOB_STAGE),((@SEQ-1)/@MEM_CNT)+1,@JOB_SEQ,RTRIM(@TABLENAME),'''+RTRIM(@START_MODE)+''',NULL,NULL,'''+RTRIM(@RUN_STATUS)+''',CASE WHEN @PARTITION_NUMBER > 1 THEN ''Partition'' ELSE '''' END,'''+RTRIM(@SKIP_FLAG)+''',''Y'',''S'','''+RTRIM(@JOB_DESC)+''','''+RTRIM(@DBNAME)+''',RTRIM(@SCHEMA),'''' 
               
                 FETCH NEXT FROM TABLEList 
                 INTO @SEQ,@TABLENAME,@TMNBDT,@TMNEDT,@SCHEMA,@PARTITION_NUMBER        
               
               END   
                  
             CLOSE TABLEList;                                                                                                                     
            DEALLOCATE TABLEList;'    
      
      ------------------------------
      -- STEP3.3:EXECUTE SQL
      ------------------------------          
          
      PRINT @INS_JOB_SQL;     
      BEGIN TRY
        EXEC SP_EXECUTESQL @INS_JOB_SQL;
      END TRY
      BEGIN CATCH
          SET @ERROR_MESSAGE=ERROR_MESSAGE()
          RAISERROR(@ERROR_MESSAGE,16,1);
      END CATCH  
     
     FETCH NEXT FROM DBList 
     INTO @DBNAME   
        
    END   
       
  CLOSE DBList;                                                                                                                     
 DEALLOCATE DBList;

------------------------------
-- 結束程式
   Main_Exit:
------------------------------