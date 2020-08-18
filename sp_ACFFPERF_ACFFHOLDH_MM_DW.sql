if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_ACFFPERF_ACFFHOLDH_MM_DW]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_ACFFPERF_ACFFHOLDH_MM_DW]
go


CREATE PROCEDURE sp_ACFFPERF_ACFFHOLDH_MM_DW
    @BATCH_NO       VARCHAR(10),        --XBATCHFLOW.BATCH_NO
    @JOB_STAGE      CHAR(3),            --XBATCHFLOW.JOB_STAGE
    @JOB_FLOW       INTEGER,            --XBATCHFLOW.JOB_FLOW
    @JOB_SEQ        INTEGER,            --XBATCHFLOW.JOB_SEQ
    @ETL_BEGIN_DATE DATETIME,           --作業起始日期
    @ETL_END_DATE   DATETIME,           --作業起始日期
    @RUN_MODE       VARCHAR(7)          --啟動狀態(Normal/Restart)
AS

-- 以下為 XSTATUS 相關變數
DECLARE @JOB_START_TIME datetime        --程式起始時間
DECLARE @LOOKUP_IND     varchar(1)      --是否有產出新代碼至代碼表(T/F)
DECLARE @BATCH_CNT      decimal(10)     --來源資料筆數(By XBHDATE2)
DECLARE @SRC_CNT        decimal(10)     --來源資料筆數(By Count)
DECLARE @INS_CNT        decimal(10)     --新增資料筆數
DECLARE @UPD_CNT        decimal(10)     --更新資料筆數
DECLARE @FLT_CNT        decimal(10)     --篩選筆數(Filter踼掉的筆數)
DECLARE @SRC_SEL_CNT    decimal(10)     --來源資料Filter留下來的筆數
DECLARE @DIFF_CNT       decimal(10)     --差異筆數

-- 以下為 執行控制 相關變數
DECLARE @ERR_NO         int             --錯誤代碼
DECLARE @F_UPD_XSTATUS  char(1)         --是否更新XSTATUS資料表(T=TRUE,F=FALSE)
DECLARE @F_UPD_ERRLOG   char(1)         --是否更新ERRLOG資料表 (T=TRUE,F=FALSE)
DECLARE @F_UPD_SRC_CNT  char(1)         --設定XSTATUS.SRC_CNT是否有效(Y=Yes,N=No)
DECLARE @F_MNT_CODE_TBL char(1)         --是否先更新相關的代碼表(T=TRUE,F=FALSE)
DECLARE @F_LOOKUP_FLAG  char(1)         --Lookup第四個參數：
                                        --  T(將新代碼寫入代碼表，並產生紀錄)
                                        --  F(不寫入代碼表，但產生紀錄)
                                        --  N(不處理)
------------------------------
-- 版本控制
------------------------------
-- Excel File     : Polaris DW Mapping V1.2.xls
-- Format Version : V1.2
-- Rule Version   : V1.2
-- Data Source    : DW
-- Last MNT Date  : 
-- This MNT Date  : 2003/9/22

/*
Comment  : 帳戶 - 海外基金庫存歷史檔
Filter   : SRC.CYC_DT>= sql("@ETL_BEGIN_DATE")  AND SRC.CYC_DT<= sql("@ETL_END_DATE")
InsUpd   : Update
Join Cond: A.ACCT_DWNO = SRC.ACCT_DWNO AND A.CYC_DT=sql("@ETL_BEGIN_DATE")
*/

------------------------------
-- 程式開始
------------------------------
-- 控制旗標
SET @F_UPD_XSTATUS = 'T';
SET @F_UPD_ERRLOG = 'T';
SET @F_UPD_SRC_CNT = 'Y'
SET @F_MNT_CODE_TBL = 'T';

-- 在測試模式下，略過 XSTATUS, ERRLOG 的更新
IF UPPER(@RUN_MODE) = 'TEST' BEGIN
    SET @F_UPD_XSTATUS = 'T';
    SET @F_UPD_ERRLOG = 'T';
END;

SET @JOB_START_TIME = GetDate();
SET @INS_CNT = 0;
SET @UPD_CNT = 0;
SET @LOOKUP_IND = 'F';  --default

------------------------------
-- 將XSTATUS更新為 '執行中',並
-- 計算BATCH_CNT, SRC_CNT, FLT_CNT
------------------------------
IF @F_UPD_XSTATUS = 'T' BEGIN

    -- 計算 @SRC_CNT
    SELECT @SRC_CNT = COUNT(*)
    FROM ACFFHOLDH AS src
    WHERE src.CYC_DT >= @ETL_BEGIN_DATE AND src.CYC_DT <= @ETL_END_DATE;

    -- 計算 @SRC_SEL_CNT
    SELECT @SRC_SEL_CNT = COUNT(*)
    FROM ACFFHOLDH AS src
    WHERE SRC.CYC_DT >= @ETL_BEGIN_DATE AND SRC.CYC_DT <= @ETL_END_DATE
;

    -- 更新 XSTATUS
    EXEC [dbo].[sp_XStatusStart] @BATCH_NO, @JOB_STAGE, @JOB_FLOW, @JOB_SEQ, @ETL_BEGIN_DATE, @ETL_END_DATE,
    'ACFFHOLDH', 'ACFFPERF', @JOB_START_TIME, @SRC_CNT, @SRC_SEL_CNT, @FLT_CNT output, @BATCH_CNT output
END;

-------------------------------------------------------------------------------
-- 整批模式開始
-------------------------------------------------------------------------------
PRINT 'Batch Mode : Start';
IF @RUN_MODE <> 'TEST' BEGIN
    BEGIN TRAN
END;

---- 最大庫存成本  ，最小庫存成本 ，平均庫存成本 ，最大庫存市值，最小庫存市值 ， 平均庫存市值
  SELECT  ACCT_DWNO,   CYC_DT,
                 SUM(ISNULL(NTD_COST_AMT,0)) AS MKT_VALUE1 
    --             SUM(ISNULL(CB_QTY*TRADE_NTD_RATE*NAV_PRICE,0)) AS MKT_VALUE2 
     INTO #SRC1
     FROM ACFFHOLDH   AS SRC  
  WHERE  SRC.CYC_DT>=@ETL_BEGIN_DATE 
        AND SRC.CYC_DT<=@ETL_END_DATE 
   GROUP BY ACCT_DWNO, CYC_DT

SELECT ACCT_DWNO,
               MAX(B.MKT_VALUE1) MAX_COST_AMT, 
               MIN(B.MKT_VALUE1)  MIN_COST_AMT,
               SUM(B.MKT_VALUE1)   SUM_COST_AMT,
--               MAX(B.MKT_VALUE2) MAX_HOLD_AMT,
--               MIN(B.MKT_VALUE2)  MIN_HOLD_AMT, 
--               SUM(B.MKT_VALUE2) SUM_HOLD_AMT,
               COUNT( DISTINCT CYC_DT)  AS HOLD_DAYS
    INTO  #SRC2
    FROM #SRC1 AS B
 GROUP BY ACCT_DWNO 


-- Update 現有紀錄 ------------------------------------
 UPDATE A
    SET A.NTD_MAX_COST_AMT = SRC1.MAX_COST_AMT
    ,A.NTD_MIN_COST_AMT = ( CASE WHEN HOLD_DAYS = DAY(@ETL_END_DATE) THEN SRC1.MIN_COST_AMT ELSE 0 END) 
    ,A.NTD_AVG_COST_AMT = ( SRC1.SUM_COST_AMT ) / DAY(@ETL_END_DATE)
--   , A.NTD_MAX_HOLD_AMT = SRC1.MAX_HOLD_AMT
--   , A.NTD_MIN_HOLD_AMT = ( CASE WHEN HOLD_DAYS = DAY(@ETL_END_DATE) THEN SRC1.MIN_HOLD_AMT ELSE 0 END) 
--   , A.NTD_AVG_HOLD_AMT = ( SRC1.SUM_HOLD_AMT ) / DAY(@ETL_END_DATE)
   , A.LST_MNT_DT = (@ETL_END_DATE) 
    ,A.DW_LST_MNT_DT = (@JOB_START_TIME)
    ,A.DW_LST_MNT_SRC = 'ACFFHOLDH'
    FROM ACFFPERF AS A, #SRC2  AS SRC1
    WHERE  A.CYC_DT >= @ETL_BEGIN_DATE
          AND A.CYC_DT <= @ETL_END_DATE
          AND A.ACCT_DWNO = SRC1.ACCT_DWNO 
;


SELECT @ERR_NO = @@ERROR, @UPD_CNT = @@ROWCOUNT;
IF @ERR_NO<>0 GOTO BATCH_ERR_HANDLE;


DROP TABLE #SRC1
DROP TABLE #SRC2



-- Insert 新的紀錄 ------------------------------------
-- Skipped by Insert/Update indicator.



-- Update 有用到Target Table的欄位---------------------
-- No such fields




------------------------------
-- 整批模式處理成功
------------------------------
PRINT 'Batch Mode : Finished Successfully';
PRINT '';
IF @RUN_MODE <> 'TEST' BEGIN
    COMMIT TRAN;
END;
GOTO WRITE_LOG;



-------------------------------------------------------------------------------
-- 整批模式錯誤處理
   BATCH_ERR_HANDLE:
-------------------------------------------------------------------------------
PRINT 'Batch Mode : Failure';
PRINT '';
IF @RUN_MODE <> 'TEST' BEGIN
    ROLLBACK TRAN;
END;










               
------------------------------
-- 執行結果紀錄
   WRITE_LOG:
------------------------------
IF @F_UPD_XSTATUS = 'T' BEGIN

    -- 計算 @DIFF_CNT
    IF @F_UPD_SRC_CNT='Y' BEGIN
        SELECT @DIFF_CNT = @SRC_CNT -(@INS_CNT + @UPD_CNT + @FLT_CNT);
    END ELSE BEGIN
        SELECT @DIFF_CNT = @BATCH_CNT -(@INS_CNT + @UPD_CNT + @FLT_CNT);
    END;

    -- 更新 XSTATUS
    EXEC [dbo].[sp_XStatusFinish] @BATCH_NO, @JOB_STAGE, @JOB_FLOW, @JOB_SEQ, @JOB_START_TIME,   @INS_CNT, @UPD_CNT, @DIFF_CNT, @LOOKUP_IND, @ERR_NO;

END;

print '@SRC_CNT     =' + STR(@SRC_CNT);
print '@SRC_SEL_CNT =' + STR(@SRC_SEL_CNT);
print '@INS_CNT     =' + STR(@INS_CNT);
print '@UPD_CNT     =' + STR(@UPD_CNT);
print '@INS+@UPD    =' + STR(@INS_CNT + @UPD_CNT);

------------------------------
-- 程式結束 sp_ACFFPERF_ACFFHOLDH_MM_DW
------------------------------
IF @ERR_NO<>0 RAISERROR(@ERR_NO, 16, 1);
RETURN(@ERR_NO)
GO


