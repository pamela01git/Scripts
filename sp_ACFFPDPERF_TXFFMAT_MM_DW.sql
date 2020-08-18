if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_ACFFPDPERF_TXFFMAT_MM_DW]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_ACFFPDPERF_TXFFMAT_MM_DW]
go


CREATE PROCEDURE sp_ACFFPDPERF_TXFFMAT_MM_DW
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
-- This MNT Date  : 2003/9/19

/*
Comment  : 交易 - 海外基金成交資料檔
Filter   : TX_DT >=SQL("@ETL_BEGIN_DATE") AND TX_DT<=SQL("@ETL_END_DATE") AND CANCEL_FLG="N"
InsUpd   : INSERT
Join Cond: 
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
    FROM TXFFMAT AS src
    WHERE src.TX_DT >= @ETL_BEGIN_DATE AND src.TX_DT <= @ETL_END_DATE;

    -- 計算 @SRC_SEL_CNT
    SELECT @SRC_SEL_CNT = COUNT(*)
    FROM TXFFMAT AS src
    WHERE src.TX_DT >= @ETL_BEGIN_DATE 
        AND src.TX_DT <= @ETL_END_DATE 
        AND src.CANCEL_FLG = 'N'
 ;

    -- 更新 XSTATUS
    EXEC [dbo].[sp_XStatusStart] @BATCH_NO, @JOB_STAGE, @JOB_FLOW, @JOB_SEQ, @ETL_BEGIN_DATE, @ETL_END_DATE,
    'TXFFMAT', 'ACFFPDPERF', @JOB_START_TIME, @SRC_CNT, @SRC_SEL_CNT, @FLT_CNT output, @BATCH_CNT output
END;









-------------------------------------------------------------------------------
-- 整批模式開始
-------------------------------------------------------------------------------
PRINT 'Batch Mode : Start';
IF @RUN_MODE <> 'TEST' BEGIN
    BEGIN TRAN
END;

-- Update 現有紀錄 ------------------------------------
-- Skipped by Insert/Update indicator.


DELETE FROM ACFFPDPERF 
WHERE CYC_DT >= @ETL_BEGIN_DATE
      AND CYC_DT <= @ETL_END_DATE

-- Insert 新的紀錄 ------------------------------------
INSERT INTO ACFFPDPERF(CYC_DT, ACCT_DWNO, PROD_DWCD, CYC_CAT,  PROD_CD , MAT_QTY, NTD_MAT_AMT, NTD_MAT_BUY_AMT, NTD_MAT_SELL_AMT, NTD_TX_FEE, NTD_TX_FEE_DISC, NTD_TX_OTHER_EXP, NTD_NON_TX_FEE, NTD_NON_TX_FEE_DISC, NTD_NON_TX_OTHER_EXP, NTD_REAL_PROFIT, LST_MNT_DT, EFF_DT, DW_LST_MNT_DT, DW_LST_MNT_SRC)
SELECT 
    /* CYC_DT= */ (@ETL_BEGIN_DATE) as CYC_DT
    ,/* ACCT_DWNO= */ src.ACCT_DWNO as ACCT_DWNO
    ,/* PROD_DWCD= */ src.PROD_DWCD as PROD_DWCD
    ,/* CYC_CAT= */ 'MM' as CYC_CAT
    ,/* PROD_CD= */ src.PROD_CD 
 --   ,/* MAT_CNT= */ ( SELECT COUNT(DISTINCT CONVERT(CHAR,TX_DT)+TRANS_ID) FROM TXFFMAT SRC WHERE SRC.ACCT_DWNO=A.ACCT_DWNO AND SRC.PROD_DWCD=A.PROD_DWCD AND REPLY_DT BETWEEN @ETL_BEGIN_DATE AND @ETL_END_DATE AND TX_CD IN ('1','2') AND CANCEL_FLG='N') as MAT_CNT
    ,/* MAT_QTY= */ (SUM(MAT_QTY)) as MAT_QTY
    ,/* NTD_MAT_AMT= */ (SUM(NTD_MAT_AMT)) as NTD_MAT_AMT
    ,/* NTD_MAT_BUY_AMT= */ (SUM(CASE WHEN BUY_SELL_FLG='B' THEN NTD_MAT_AMT ELSE 0 END)) as NTD_MAT_BUY_AMT
    ,/* NTD_MAT_SELL_AMT= */ (SUM(CASE WHEN BUY_SELL_FLG='S' THEN NTD_MAT_AMT ELSE 0 END)) as NTD_MAT_SELL_AMT
    ,/* NTD_TX_FEE= */ (SUM(NTD_TX_FEE)) as NTD_TX_FEE
    ,/* NTD_TX_FEE_DISC= */ (SUM(NTD_TX_FEE_DISC)) as NTD_TX_FEE_DISC
    ,/* NTD_TX_OTHER_EXP= */ (SUM(NTD_TX_OTHER_EXP)) as NTD_TX_OTHER_EXP
    ,/* NTD_NON_TX_FEE= */ (SUM(NTD_NON_TX_FEE)) as NTD_NON_TX_FEE
    ,/* NTD_NON_TX_FEE_DISC= */ (SUM(NTD_NON_TX_FEE_DISC)) as NTD_NON_TX_FEE_DISC
    ,/* NTD_NON_TX_OTHER_EXP= */ (SUM(NTD_NON_TX_OTHER_EXP)) as NTD_NON_TX_OTHER_EXP
    ,/* NTD_REAL_PROFIT= */ (SUM(NTD_REAL_PROFIT)) as NTD_REAL_PROFIT
    ,/* LST_MNT_DT= */ @ETL_END_DATE as LST_MNT_DT
    ,/* EFF_DT= */ @ETL_END_DATE AS EFF_DT
    ,/* DW_LST_MNT_DT= */ (@JOB_START_TIME) as DW_LST_MNT_DT
    ,/* DW_LST_MNT_SRC= */ 'TXFFMAT' as DW_LST_MNT_SRC
    FROM TXFFMAT AS SRC
    WHERE src.TX_DT >= @ETL_BEGIN_DATE 
         AND src.TX_DT <= @ETL_END_DATE 
         AND src.CANCEL_FLG = 'N'
   GROUP BY SRC.ACCT_DWNO , SRC.PROD_DWCD  , SRC.PROD_CD
   
;


SELECT @ERR_NO = @@ERROR, @INS_CNT = @@ROWCOUNT;
IF @ERR_NO<>0 GOTO BATCH_ERR_HANDLE;



UPDATE A
         SET A.MAT_CNT= ( SELECT COUNT(DISTINCT CONVERT(CHAR,TX_DT)+TRANS_ID) FROM TXFFMAT SRC WHERE SRC.ACCT_DWNO=A.ACCT_DWNO AND SRC.PROD_DWCD=A.PROD_DWCD AND REPLY_DT BETWEEN @ETL_BEGIN_DATE AND @ETL_END_DATE AND TX_CD IN ('1','2') AND CANCEL_FLG='N') 
    FROM ACFFPDPERF AS A , TXFFMAT AS SRC  
 WHERE A.CYC_DT = @ETL_BEGIN_DATE 
      AND A.ACCT_DWNO  = SRC.ACCT_DWNO 
      AND A.PROD_DWCD  = SRC.PROD_DWCD
      AND SRC.CANCEL_FLG = 'N'
      AND SRC.TX_DT >= @ETL_BEGIN_DATE 
      AND SRC.TX_DT <= @ETL_END_DATE



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
-- 程式結束 sp_ACFFPDPERF_TXFFMAT_MM_DW
------------------------------
IF @ERR_NO<>0 RAISERROR(@ERR_NO, 16, 1);
RETURN(@ERR_NO)
GO


