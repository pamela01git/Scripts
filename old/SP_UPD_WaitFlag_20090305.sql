USE [ISMD]
GO
/****** Object:  StoredProcedure [odsdba].[SP_UPD_WaitFlag]    Script Date: 03/05/2009 16:03:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [odsdba].[SP_UPD_WaitFlag]
    @DATACAT CHAR(10),
    @JOB_STAGE  CHAR(10),
    @JOB_FLOW CHAR(10),
    @InsertOnly char(1)='N'
AS
------------------------------
-- 祘Α弧
------------------------------
-- 1.ㄌETLヘ玡磅︽FLOW计∕﹚キ︽磅︽Job计(穝WAIT_FLAG)
-- 2.2009/2/11,George璝@InsertOnly='N'笿Partition Table玥@WAIT_FLAGY
-- 3.2009/2/17,George眏キ︽Ω计2
-- 4.20092/19,George,flow1眏NO WAITING,璝FLOW1ごRUNNING玥ぃ穝WAIT_FLAG

------------------------------
-- STEP1:XBATCHFLOW㏕﹚跑计
------------------------------
DECLARE @BATCH_NO INT
DECLARE @CYCLE_START CHAR(8)
DECLARE @CYCLE_END CHAR(8)
DECLARE @PROCESS_TYPE CHAR(3)
DECLARE @JOB_SEQ INT
DECLARE @JOB_NAME VARCHAR(150)
DECLARE @START_MODE CHAR(7)
DECLARE @PARAM CHAR(20)
DECLARE @SKIP_FLAG CHAR(1)
DECLARE @JOB_TYPE CHAR(1)
DECLARE @JOB_DESC VARCHAR(255)
DECLARE @JOB_LOCATION CHAR(30)
DECLARE @JOB_OWNER CHAR(10)

IF @JOB_FLOW = 1 OR EXISTS (SELECT * FROM ODSDBA.XBATCHFLOW WHERE DATACAT=@DATACAT AND JOB_STAGE=@JOB_STAGE AND JOB_FLOW=1 AND RUN_STATUS = 'RUNNING'  )
 BEGIN
     GOTO Main_Exit;
  END

  ------------------------------
  -- STEP1.1:∕﹚そノ跑计
  ------------------------------    
  SELECT TOP 1 @BATCH_NO=BATCH_NO,@CYCLE_START=CONVERT(CHAR(8),CYCLE_START,112),@CYCLE_END=CONVERT(CHAR(8),CYCLE_END,112)
        ,@PROCESS_TYPE=PROCESS_TYPE,@START_MODE=START_MODE
  FROM ODSDBA.XBATCHFLOW
  WHERE DATACAT=@DATACAT AND JOB_STAGE=@JOB_STAGE AND JOB_FLOW=@JOB_FLOW;

------------------------------
-- STEP2:キ︽磅︽Ω计耞
------------------------------
DECLARE @RUNNING_CNT INT
DECLARE @PARA_CNT INT
DECLARE @MEM_CNT INT --FLOWΤ碭唉JOB
DECLARE @WEIGHT_CNT INT --舦计

SELECT @RUNNING_CNT =COUNT(1) FROM (SELECT DATACAT FROM ODSDBA.XBATCHFLOW
                      WHERE RUN_STATUS = 'RUNNING'
                        AND DATACAT NOT IN ('ODUND','ODDAYD','MVEM')
                        AND JOB_LOCATION <> '\JobControl'
                      GROUP BY DATACAT ) S1
                      
                
SET @PARA_CNT = CASE WHEN @RUNNING_CNT > 3 THEN 1    --璝Τ3FLOW磅︽,玥キ︽Ω计1
                     WHEN @RUNNING_CNT = 3 THEN 2    --璝Τ3FLOW磅︽,玥キ︽Ω计2
                     WHEN @RUNNING_CNT = 2 THEN 3    --璝Τ2FLOW磅︽,玥キ︽Ω计3
                     WHEN @RUNNING_CNT = 1 THEN 4    --璝Τ1FLOW磅︽,玥キ︽Ω计4
                     WHEN @RUNNING_CNT = 0 THEN 5 END--璝⊿ΤFLOW磅︽,玥キ︽Ω计5
                     
SET @PARA_CNT = 2 --[2009/2/17]代刚2唉禲                     
                     
------------------------------
-- STEP3:穝Wait Flag
------------------------------
                     
  ------------------------------
  -- STEP3.1:璝キ︽Ω计1玥挡祘Α
  ------------------------------                       
  IF @PARA_CNT = 1 GOTO Main_Exit;
  
  ------------------------------
  -- STEP3.2:璝キ︽Ω计2玥穝案计ぇJOB_SEQNo Waiting
  ------------------------------        
  IF @PARA_CNT = 2
   BEGIN
     UPDATE ODSDBA.XBATCHFLOW
     SET WAIT_FLAG = 'N'
     WHERE DATACAT=@DATACAT AND JOB_STAGE=@JOB_STAGE AND JOB_FLOW=@JOB_FLOW
       AND JOB_SEQ%2 = 0;
     GOTO Main_Exit;    	
   END

  ------------------------------
  -- STEP3.3:璝キ︽Ω计单3ぇ矪瞶
  ------------------------------    
  DECLARE @NEW_SEQ INT
  SET @NEW_SEQ = 1
  
   DECLARE @XBATCHFLOW TABLE (JOB_SEQ INT,JOB_NAME VARCHAR(150),PARAM CHAR(20),SKIP_FLAG CHAR(1),JOB_TYPE CHAR(1),JOB_LOCATION CHAR(30),JOB_OWNER CHAR(10));
   INSERT INTO  @XBATCHFLOW
   SELECT JOB_SEQ,JOB_NAME,PARAM,SKIP_FLAG,JOB_TYPE,JOB_LOCATION,JOB_OWNER
   FROM ODSDBA.XBATCHFLOW
   WHERE DATACAT=@DATACAT AND JOB_STAGE=@JOB_STAGE AND JOB_FLOW=@JOB_FLOW
     AND JOB_SEQ <> 1
   ORDER BY JOB_SEQ; 
    
  
    DECLARE JobList CURSOR LOCAL  FOR 
    
       SELECT JOB_SEQ,JOB_NAME,PARAM,SKIP_FLAG,JOB_TYPE,JOB_LOCATION,JOB_OWNER
       FROM @XBATCHFLOW;  
    
    OPEN JobList; 
    FETCH NEXT FROM JobList 
         INTO @JOB_SEQ,@JOB_NAME,@PARAM,@SKIP_FLAG,@JOB_TYPE,@JOB_LOCATION,@JOB_OWNER 
                                                                                                      
    WHILE @@FETCH_STATUS = 0   
    
      BEGIN 
         SET @NEW_SEQ = @NEW_SEQ + 1
         
          ------------------------------
          -- STEP3.3.1:穝玡睲埃侣Τ癘魁
          ------------------------------           
         IF @NEW_SEQ = 2 DELETE FROM ODSDBA.XBATCHFLOW WHERE DATACAT=@DATACAT AND JOB_STAGE=@JOB_STAGE AND JOB_FLOW=@JOB_FLOW AND JOB_SEQ <> 1;
 
          ------------------------------
          -- STEP3.3.2:结ぉ穝JOB_SEQ 籔WAIT_FLAG
          ------------------------------             
         INSERT INTO ODSDBA.XBATCHFLOW
         SELECT @DATACAT,@BATCH_NO,@CYCLE_START,@CYCLE_END,@PROCESS_TYPE,@JOB_STAGE,@JOB_FLOW,@NEW_SEQ,@JOB_NAME,@START_MODE,NULL,NULL,'' AS RUN_STATUS
                     ,@PARAM,@SKIP_FLAG,CASE WHEN ((@InsertOnly = 'N' AND @PARAM = 'PARTITION') OR @JOB_SEQ%@PARA_CNT = 1) THEN 'Y' ELSE 'N' END AS WAIT_FLAG,@JOB_TYPE,@JOB_DESC,@JOB_LOCATION,@JOB_OWNER,'' AS EXEC_DESC; 

          ------------------------------
          -- STEP3.3.3:WaitingRunning砞﹚
          ------------------------------    
         IF @JOB_SEQ%@PARA_CNT =1 
           BEGIN
               SET @NEW_SEQ = @NEW_SEQ + 1	
               INSERT INTO ODSDBA.XBATCHFLOW
               SELECT @DATACAT,@BATCH_NO,@CYCLE_START,@CYCLE_END,@PROCESS_TYPE,@JOB_STAGE,@JOB_FLOW,@NEW_SEQ,'WaitingContinueRunning' AS JOB_NAME,@START_MODE,NULL,NULL,'' AS RUN_STATUS
                     ,'BegSeq='+RTRIM(CONVERT(CHAR,@NEW_SEQ-@PARA_CNT))+'|EndSeq='+RTRIM(CONVERT(CHAR,@NEW_SEQ-1)) AS PARAM,'N' AS SKIP_FLAG,'Y' AS WAIT_FLAG,'D' AS JOB_TYPE,'' AS JOB_DESC,'\JobControl' AS JOB_LOCATION,'dbo' AS JOB_OWNER,'' AS EXEC_DESC; 
           END
         
         
  
       FETCH NEXT FROM JobList 
       INTO @JOB_SEQ,@JOB_NAME,@PARAM,@SKIP_FLAG,@JOB_TYPE,@JOB_LOCATION,@JOB_OWNER   
          
      END   
         
    CLOSE JobList;                                                                                                                     
   DEALLOCATE JobList;

------------------------------
-- 挡祘Α
   Main_Exit:
------------------------------