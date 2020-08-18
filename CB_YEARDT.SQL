if exists (select * from dbo.sysobjects where id = object_id(N'[odsdba].[sp_CB_DT_TMP_UN_YEARDAY]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [odsdba].[sp_CB_DT_TMP_UN_YEARDAY]
go


CREATE PROCEDURE sp_CB_DT_TMP_UN_YEARDAY
    @BATCH_NO       VARCHAR(10),        --XBATCHFLOW.BATCH_NO
    @JOB_STAGE      CHAR(4),            --XBATCHFLOW.JOB_STAGE
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
-- Excel File     : LBOT DWBasisDB Dimension Mapping v2.34.XLS
-- Format Version : V0
-- Rule Version   : V0
-- Data Source    : SA
-- Last MNT Date  : 
-- This MNT Date  : 2005/2/16

/*
Comment  : 
Filter   : 
InsUpd   : TRUNCATE/INSERT
Join Cond: 
*/

------------------------------
-- 程式開始
------------------------------
-- 控制旗標
SET @F_UPD_XSTATUS = 'T';
SET @F_UPD_ERRLOG = 'T';
SET @F_UPD_SRC_CNT = 'N'
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
    FROM ODSDB.odsdba.TMP_UN_YEARDAY AS src
    ;

    -- 計算 @SRC_SEL_CNT
    SELECT @SRC_SEL_CNT = @SRC_CNT
    ;

    -- 更新 XSTATUS
    EXEC [odsdba].[sp_XStatusStart] @BATCH_NO, @JOB_STAGE, @JOB_FLOW, @JOB_SEQ, @ETL_BEGIN_DATE, @ETL_END_DATE,
    'TMP_UN_YEARDAY', 'CB_DT', @JOB_START_TIME, @SRC_CNT, @SRC_SEL_CNT, @FLT_CNT output, @BATCH_CNT output
END;









-------------------------------------------------------------------------------
-- 整批模式開始
-------------------------------------------------------------------------------
PRINT 'Batch Mode : Start';
IF @RUN_MODE <> 'TEST' BEGIN
    BEGIN TRAN
END;

-- Update 現有紀錄 ------------------------------------
UPDATE A
   SET
     A.DATADT=    dbo.MYtoWY(src.TBSDY)
    ,A.DT_CHAR=   CONVERT(VARCHAR,dbo.MYtoWY(src.TBSDY),112) 
    ,A.WEEK_DY=   src.WEEKDY 
    ,A.WEEK_NO=   DATEPART(WEEK,dbo.MYtoWY(src.TBSDY)) 
    ,A.YR=        LEFT(CONVERT(VARCHAR,dbo.MYtoWY(src.TBSDY),112),4) 
    ,A.MN=        SUBSTRING(CONVERT(VARCHAR,dbo.MYtoWY(src.TBSDY),112),5,2) 
    ,A.DY_IN_MN=  CAST(RIGHT(src.TBSDY,2) AS INT) 
    ,A.DY_IN_YR=  DATEPART(DY,dbo.MYtoWY(src.TBSDY))
    ,A.SEASON=    DATEPART(QQ,dbo.MYtoWY(src.TBSDY))
    ,A.SEMI_YR_NM=CASE WHEN DATEPART(QQ,dbo.MYtoWY(src.TBSDY)) = 1 OR DATEPART(QQ,dbo.MYtoWY(src.TBSDY)) =2 THEN '上半年'  ELSE '下半年' END 
    ,A.HOLIDY_FG= src.HOLIDY 
    ,A.HOLIDY_DY= DATEDIFF(DD,dbo.MYtoWY(src.TBSDY),dbo.MYtoWY(src.NBSDY)) 
    ,A.CYC_BEG=   dbo.MYtoWY(src.TBSDY) 
    ,A.CYC_END=   dbo.MYtoWY(src.TBSDY) 
    ,A.BBOW_FG=   CASE WHEN (DATEPART(WK,dbo.MYtoWY(src.TBSDY)) <> DATEPART(WK,dbo.MYtoWY(src.LBSDY))) AND HOLIDY <> 1 THEN 'Y' ELSE 'N' END 
    ,A.BEOW_FG=   CASE WHEN (DATEPART(WK,dbo.MYtoWY(src.TBSDY)) <> DATEPART(WK,dbo.MYtoWY(src.NBSDY))) AND HOLIDY <> 1 THEN 'Y' ELSE 'N' END 
    ,A.BBOM_FG=   CASE WHEN (DATEPART(MM,dbo.MYtoWY(src.LBSDY))  <> DATEPART(MM,dbo.MYtoWY(src.TBSDY)))AND HOLIDY <> 1 THEN 'Y' ELSE 'N' END 
    ,A.BEOM_FG=   CASE WHEN DATEPART(MM,dbo.MYtoWY(src.NBSDY)) <> DATEPART(MM,dbo.MYtoWY(src.TBSDY)) AND HOLIDY <> 1 THEN 'Y' ELSE 'N' END 
    ,A.BBOQ_FG=   CASE WHEN (DATEPART(QQ,dbo.MYtoWY(src.TBSDY)) <> DATEPART(QQ,dbo.MYtoWY(src.LBSDY)))  AND HOLIDY <> 1 THEN 'Y' ELSE 'N' END 
    ,A.BEOQ_FG=   CASE WHEN (DATEPART(QQ,dbo.MYtoWY(src.TBSDY)) <> DATEPART(QQ,dbo.MYtoWY(src.NBSDY)))  AND HOLIDY <> 1 THEN 'Y' ELSE 'N' END 
    ,A.BBOY_FG=   CASE WHEN (DATEPART(YY,dbo.MYtoWY(src.TBSDY)) <> DATEPART(YY,dbo.MYtoWY(src.LBSDY)))  AND HOLIDY <> 1 THEN 'Y' ELSE 'N' END 
    ,A.BEOY_FG=   CASE WHEN (DATEPART(YY,dbo.MYtoWY(src.TBSDY)) <> DATEPART(YY,dbo.MYtoWY(src.NBSDY)))  AND HOLIDY <> 1 THEN 'Y' ELSE 'N' END 
    ,A.EOM_FG=    CASE WHEN dbo.MYtoWY(src.TBSDY) = dbo.MYtoWY(src.TMNDY) THEN 'Y' ELSE 'N' END 
    ,A.TBSDT=     dbo.MYtoWY(src.TBSDY) 
    ,A.LBSDT=     dbo.MYtoWY(src.LBSDY) 
    ,A.NBSDT=     dbo.MYtoWY(src.NBSDY) 
    ,A.NNBSDT=    dbo.MYtoWY(src.NNBSDY) 
    ,A.LBSDY=     src.LDYCNT 
    ,A.NBSDY=     src.NDYCNT 
    ,A.NNBZDY=    src.NNDYCNT 
    ,A.DYCNTEOM=  DATEDIFF(DD,dbo.MYtoWY(src.TBSDY),dbo.MYtoWY(src.TMNDY)) 
    ,A.NDYCNTTM=  CASE WHEN dbo.MYtoWY(src.TBSDY) = dbo.MYtoWY(src.TMNDY) AND src.HOLIDY =1 THEN (CASE WHEN DATEDIFF(DD,dbo.MYtoWY(src.TBSDY),dbo.MYtoWY(src.TMNDY)) > src.NDYCNT THEN src.NDYCNT ELSE DATEDIFF(DD,dbo.MYtoWY(src.TBSDY),dbo.MYtoWY(src.TMNDY)) END ) ELSE src.NDYCNT END
    ,A.L2MNBDT=   DATEADD(MM, - 2, DATEADD(DD, - (CAST(RIGHT(src.TBSDY,2) AS INT) - 1), dbo.MYtoWY(src.TBSDY)))  
    ,A.L2MNEDT=   DATEADD(DD,-1,DATEADD(MM, - 1, DATEADD(DD, - (CAST(RIGHT(src.TBSDY,2) AS INT) - 1), dbo.MYtoWY(src.TBSDY)))) 
    ,A.L2MNEDYS=  RIGHT(CONVERT(VARCHAR,DATEADD(DD,-1,DATEADD(MM, - 1, DATEADD(DD, - (CAST(RIGHT(src.TBSDY,2) AS INT) - 1), dbo.MYtoWY(src.TBSDY)))),112),2)
    ,A.LMNBDT=    DATEADD(MM, - 1, DATEADD(DD, - (CAST(RIGHT(src.TBSDY,2) AS INT) - 1), dbo.MYtoWY(src.TBSDY))) 
    ,A.LMNEDT=    DATEADD(DD, - (CAST(RIGHT(src.TBSDY,2) AS INT)), dbo.MYtoWY(src.TBSDY)) 
    ,A.LMNEDYS=   RIGHT(CONVERT(VARCHAR(8),DATEADD(DD, - (CAST(RIGHT(src.TBSDY,2) AS INT)), dbo.MYtoWY(src.TBSDY)),112),2) 
    ,A.TMNBDT=    DATEADD(DD,-(CAST(RIGHT(src.TBSDY,2) AS INT)-1),dbo.MYtoWY(src.TBSDY)) 
    ,A.TMNEDT=    dbo.MYtoWY(src.TMNDY) 
    ,A.TMNDYS=    RIGHT(CONVERT(VARCHAR(8),dbo.MYtoWY(src.TMNDY),112),2)   
    ,A.FNBSDT=    dbo.MYtoWY(src.FNBSDY) 
    ,A.TQBDT=     CASE WHEN DATEPART(QQ,dbo.MYtoWY(src.TBSDY)) = 1 THEN CONVERT(DATETIME,CONVERT(VARCHAR,YEAR(dbo.MYtoWY(src.TBSDY))) +'0101')  WHEN DATEPART(QQ,dbo.MYtoWY(src.TBSDY))=2 THEN CONVERT(DATETIME,CONVERT(VARCHAR,YEAR(dbo.MYtoWY(src.TBSDY))) +'0401') WHEN DATEPART(QQ,dbo.MYtoWY(src.TBSDY))=3 THEN CONVERT(DATETIME,CONVERT(VARCHAR,YEAR(dbo.MYtoWY(src.TBSDY))) +'0701') ELSE  CONVERT(DATETIME,CONVERT(VARCHAR,YEAR(dbo.MYtoWY(src.TBSDY))) +'1001')  END 
    ,A.TQEDT=     CASE WHEN DATEPART(QQ,dbo.MYtoWY(src.TBSDY)) = 1 THEN CONVERT(DATETIME,CONVERT(VARCHAR,YEAR(dbo.MYtoWY(src.TBSDY))) +'0301')  WHEN DATEPART(QQ,dbo.MYtoWY(src.TBSDY))=2 THEN CONVERT(DATETIME,CONVERT(VARCHAR,YEAR(dbo.MYtoWY(src.TBSDY))) +'0601') WHEN DATEPART(QQ,dbo.MYtoWY(src.TBSDY))=3 THEN CONVERT(DATETIME,CONVERT(VARCHAR,YEAR(dbo.MYtoWY(src.TBSDY))) +'0901') ELSE CONVERT(DATETIME,CONVERT(VARCHAR,YEAR(dbo.MYtoWY(src.TBSDY))) +'1201')  END 
    ,A.TQDYS=     CASE WHEN DATEPART(QQ,dbo.MYtoWY(src.TBSDY))=1 THEN DATEDIFF(DD,CONVERT(DATETIME,CONVERT(VARCHAR,YEAR(dbo.MYtoWY(src.TBSDY))) +'0101'),CONVERT(DATETIME,CONVERT(VARCHAR,YEAR(dbo.MYtoWY(src.TBSDY))) +'0331')) WHEN DATEPART(QQ,dbo.MYtoWY(src.TBSDY))=2 THEN 90 WHEN DATEPART(QQ,dbo.MYtoWY(src.TBSDY))=3 THEN 91 ELSE 91 END 
    ,A.L1QBDT=    CASE WHEN DATEPART(QUARTER,DATEADD(QQ,-1,dbo.MYtoWY(src.TBSDY))) = 1 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-1,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0101') WHEN DATEPART(QUARTER,DATEADD(QQ,-1,dbo.MYtoWY(src.TBSDY))) = 2 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-1,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0401') WHEN DATEPART(QUARTER,DATEADD(QQ,-1,dbo.MYtoWY(src.TBSDY))) = 3 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-1,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0701') ELSE CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-1,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'1001') END 
    ,A.L1QEDT=    CASE WHEN DATEPART(QUARTER,DATEADD(QQ,-1,dbo.MYtoWY(src.TBSDY))) = 1 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-1,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0301') WHEN DATEPART(QUARTER,DATEADD(QQ,-1,dbo.MYtoWY(src.TBSDY))) = 2 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-1,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0601') WHEN DATEPART(QUARTER,DATEADD(QQ,-1,dbo.MYtoWY(src.TBSDY))) = 3 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-1,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0901') ELSE CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-1,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'1201') END 
    ,A.L1QDYS=    CASE WHEN DATEPART(QUARTER,DATEADD(QQ,-1,dbo.MYtoWY(src.TBSDY)))  =1 THEN  DATEDIFF(DD,CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-1,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0101'),CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-1,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0331'))  WHEN DATEPART(QUARTER,DATEADD(QQ,-1,dbo.MYtoWY(src.TBSDY)))=2 THEN 90 WHEN DATEPART(QUARTER,DATEADD(QQ,-1,dbo.MYtoWY(src.TBSDY)))=3 THEN 91 ELSE 91 END    
    ,A.L2QBDT=    CASE WHEN DATEPART(QUARTER,DATEADD(QQ,-2,dbo.MYtoWY(src.TBSDY))) = 1 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-2,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0101') WHEN DATEPART(QUARTER,DATEADD(QQ,-2,dbo.MYtoWY(src.TBSDY))) = 2 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-2,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0401') WHEN DATEPART(QUARTER,DATEADD(QQ,-2,dbo.MYtoWY(src.TBSDY))) = 3 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-2,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0701') ELSE CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-2,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'1001') END 
    ,A.L2QEDT=    CASE WHEN DATEPART(QUARTER,DATEADD(QQ,-2,dbo.MYtoWY(src.TBSDY))) = 1 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-2,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0301') WHEN DATEPART(QUARTER,DATEADD(QQ,-2,dbo.MYtoWY(src.TBSDY))) = 2 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-2,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0601') WHEN DATEPART(QUARTER,DATEADD(QQ,-2,dbo.MYtoWY(src.TBSDY))) = 3 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-2,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0901') ELSE CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-2,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'1201') END 
    ,A.L2QDYS=    CASE WHEN DATEPART(QUARTER,DATEADD(QQ,-2,dbo.MYtoWY(src.TBSDY)))  =1 THEN  DATEDIFF(DD,CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-2,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0101'),CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-2,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0331'))  WHEN DATEPART(QUARTER,DATEADD(QQ,-2,dbo.MYtoWY(src.TBSDY)))=2 THEN 90 WHEN DATEPART(QUARTER,DATEADD(QQ,-2,dbo.MYtoWY(src.TBSDY)))=3 THEN 91 ELSE 91 END  
    ,A.L3QBDT=    CASE WHEN DATEPART(QUARTER,DATEADD(QQ,-3,dbo.MYtoWY(src.TBSDY))) = 1 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-3,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0101') WHEN DATEPART(QUARTER,DATEADD(QQ,-3,dbo.MYtoWY(src.TBSDY))) = 2 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-3,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0401') WHEN DATEPART(QUARTER,DATEADD(QQ,-3,dbo.MYtoWY(src.TBSDY))) = 3 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-3,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0701') ELSE CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-3,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'1001') END 
    ,A.L3QEDT=    CASE WHEN DATEPART(QUARTER,DATEADD(QQ,-3,dbo.MYtoWY(src.TBSDY))) = 1 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-3,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0301') WHEN DATEPART(QUARTER,DATEADD(QQ,-3,dbo.MYtoWY(src.TBSDY))) = 2 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-3,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0601') WHEN DATEPART(QUARTER,DATEADD(QQ,-3,dbo.MYtoWY(src.TBSDY))) = 3 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-3,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0901') ELSE CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-3,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'1201') END 
    ,A.L3QDYS=    CASE WHEN DATEPART(QUARTER,DATEADD(QQ,-3,dbo.MYtoWY(src.TBSDY)))  =1 THEN  DATEDIFF(DD,CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-3,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0101'),CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-3,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0331'))  WHEN DATEPART(QUARTER,DATEADD(QQ,-3,dbo.MYtoWY(src.TBSDY)))=2 THEN 90 WHEN DATEPART(QUARTER,DATEADD(QQ,-3,dbo.MYtoWY(src.TBSDY)))=3 THEN 91 ELSE 91 END  
    ,A.L4QBDT=    CASE WHEN DATEPART(QUARTER,DATEADD(QQ,-4,dbo.MYtoWY(src.TBSDY))) = 1 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-4,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0101') WHEN DATEPART(QUARTER,DATEADD(QQ,-4,dbo.MYtoWY(src.TBSDY))) = 2 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-4,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0401') WHEN DATEPART(QUARTER,DATEADD(QQ,-4,dbo.MYtoWY(src.TBSDY))) = 3 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-4,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0701') ELSE CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-4,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'1001') END 
    ,A.L4QEDT=    CASE WHEN DATEPART(QUARTER,DATEADD(QQ,-4,dbo.MYtoWY(src.TBSDY))) = 1 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-4,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0301') WHEN DATEPART(QUARTER,DATEADD(QQ,-4,dbo.MYtoWY(src.TBSDY))) = 2 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-4,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0601') WHEN DATEPART(QUARTER,DATEADD(QQ,-4,dbo.MYtoWY(src.TBSDY))) = 3 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-4,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0901') ELSE CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-4,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'1201') END 
    ,A.L4QDYS=    CASE WHEN DATEPART(QUARTER,DATEADD(QQ,-4,dbo.MYtoWY(src.TBSDY)))  =1 THEN  DATEDIFF(DD,CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-4,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0101'),CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-4,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0331'))  WHEN DATEPART(QUARTER,DATEADD(QQ,-4,dbo.MYtoWY(src.TBSDY)))=2 THEN 90 WHEN DATEPART(QUARTER,DATEADD(QQ,-4,dbo.MYtoWY(src.TBSDY)))=3 THEN 91 ELSE 91 END     
    ,A.L5QBDT=    CASE WHEN DATEPART(QUARTER,DATEADD(QQ,-5,dbo.MYtoWY(src.TBSDY))) = 1 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-5,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0101') WHEN DATEPART(QUARTER,DATEADD(QQ,-5,dbo.MYtoWY(src.TBSDY))) = 2 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-5,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0401') WHEN DATEPART(QUARTER,DATEADD(QQ,-5,dbo.MYtoWY(src.TBSDY))) = 3 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-5,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0701') ELSE CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-5,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'1001') END 
    ,A.L5QEDT=    CASE WHEN DATEPART(QUARTER,DATEADD(QQ,-5,dbo.MYtoWY(src.TBSDY))) = 1 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-5,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0301') WHEN DATEPART(QUARTER,DATEADD(QQ,-5,dbo.MYtoWY(src.TBSDY))) = 2 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-5,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0601') WHEN DATEPART(QUARTER,DATEADD(QQ,-5,dbo.MYtoWY(src.TBSDY))) = 3 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-5,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0901') ELSE CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-5,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'1201') END 
    ,A.L5QDYS=    CASE WHEN DATEPART(QUARTER,DATEADD(QQ,-5,dbo.MYtoWY(src.TBSDY)))  =1 THEN  DATEDIFF(DD,CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-5,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0101'),CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-5,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0331'))  WHEN DATEPART(QUARTER,DATEADD(QQ,-5,dbo.MYtoWY(src.TBSDY)))=2 THEN 90 WHEN DATEPART(QUARTER,DATEADD(QQ,-5,dbo.MYtoWY(src.TBSDY)))=3 THEN 91 ELSE 91 END     
    ,A.LstSysDt=  GETDATE() 
        FROM odsdba.CB_DT AS A
    JOIN odsdba.TMP_UN_YEARDAY AS src on(
        A.DATADT=dbo.MYtoWY(src.TBSDY)
    )
;
  
  SELECT @ERR_NO = @@ERROR, @UPD_CNT = @@ROWCOUNT;
IF @ERR_NO<>0 GOTO BATCH_ERR_HANDLE;
 

-- Insert 新的紀錄 ------------------------------------    
INSERT INTO odsdba.CB_DT(DATADT, DT_CHAR, WEEK_DY, WEEK_NO, YR, MN, DY_IN_MN, DY_IN_YR, SEASON, SEMI_YR_NM, HOLIDY_FG, HOLIDY_DY, CYC_BEG, CYC_END, BBOW_FG, BEOW_FG, BBOM_FG, BEOM_FG, BBOQ_FG, BEOQ_FG, BBOY_FG, BEOY_FG, EOM_FG, TBSDT, LBSDT, NBSDT, NNBSDT, LBSDY, NBSDY, NNBZDY, DYCNTEOM, NDYCNTTM, L2MNBDT, L2MNEDT, L2MNEDYS, LMNBDT, LMNEDT, LMNEDYS, TMNBDT, TMNEDT, TMNDYS, FNBSDT, TQBDT, TQEDT, TQDYS, L1QBDT, L1QEDT, L1QDYS, L2QBDT, L2QEDT, L2QDYS, L3QBDT, L3QEDT, L3QDYS, L4QBDT, L4QEDT, L4QDYS, L5QBDT, L5QEDT, L5QDYS, LstSysDt)
SELECT
    /* DATADT= */    dbo.MYtoWY(src.TBSDY)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
   ,/* DT_CHAR= */   CONVERT(VARCHAR,dbo.MYtoWY(src.TBSDY),112)                                                                                                                                                                                                                                                                                                                                                                                                                                                                
   ,/* WEEK_DY= */   src.WEEKDY                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
   ,/* WEEK_NO= */   DATEPART(WEEK,dbo.MYtoWY(src.TBSDY))                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
   ,/* YR= */        LEFT(CONVERT(VARCHAR,dbo.MYtoWY(src.TBSDY),112),4)                                                                                                                                                                                                                                                                                                                                                                                                                                                        
   ,/* MN= */        SUBSTRING(CONVERT(VARCHAR,dbo.MYtoWY(src.TBSDY),112),5,2)                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
   ,/* DY_IN_MN= */  CAST(RIGHT(src.TBSDY,2) AS INT)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
   ,/* DY_IN_YR= */  DATEPART(DY,dbo.MYtoWY(src.TBSDY))                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
   ,/* SEASON= */    DATEPART(QQ,dbo.MYtoWY(src.TBSDY))                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
   ,/* SEMI_YR_NM= */CASE WHEN DATEPART(QQ,dbo.MYtoWY(src.TBSDY)) = 1 OR DATEPART(QQ,dbo.MYtoWY(src.TBSDY)) =2 THEN '上半年'  ELSE '下半年' END                                                                                                                                                                                                                                                                                                                                                                                              
   ,/* HOLIDY_FG= */ src.HOLIDY                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
   ,/* HOLIDY_DY= */ DATEDIFF(DD,dbo.MYtoWY(src.TBSDY),dbo.MYtoWY(src.NBSDY))                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
   ,/* CYC_BEG= */   dbo.MYtoWY(src.TBSDY)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
   ,/* CYC_END= */   dbo.MYtoWY(src.TBSDY)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
   ,/* BBOW_FG= */   CASE WHEN (DATEPART(WK,dbo.MYtoWY(src.TBSDY)) <> DATEPART(WK,dbo.MYtoWY(src.LBSDY))) AND HOLIDY <> 1 THEN 'Y' ELSE 'N' END                                                                                                                                                                                                                                                                                                                                                                                               
   ,/* BEOW_FG= */   CASE WHEN (DATEPART(WK,dbo.MYtoWY(src.TBSDY)) <> DATEPART(WK,dbo.MYtoWY(src.NBSDY))) AND HOLIDY <> 1 THEN 'Y' ELSE 'N' END                                                                                                                                                                                                                                                                                                                                                                                               
   ,/* BBOM_FG= */   CASE WHEN (DATEPART(MM,dbo.MYtoWY(src.LBSDY))  <> DATEPART(MM,dbo.MYtoWY(src.TBSDY)))AND HOLIDY <> 1 THEN 'Y' ELSE 'N' END                                                                                                                                                                                                                                                                                                                                                                                               
   ,/* BEOM_FG= */   CASE WHEN DATEPART(MM,dbo.MYtoWY(src.NBSDY)) <> DATEPART(MM,dbo.MYtoWY(src.TBSDY)) AND HOLIDY <> 1 THEN 'Y' ELSE 'N' END                                                                                                                                                                                                                                                                                                                                                                                                 
   ,/* BBOQ_FG= */   CASE WHEN (DATEPART(QQ,dbo.MYtoWY(src.TBSDY)) <> DATEPART(QQ,dbo.MYtoWY(src.LBSDY)))  AND HOLIDY <> 1 THEN 'Y' ELSE 'N' END                                                                                                                                                                                                                                                                                                                                                                                              
   ,/* BEOQ_FG= */   CASE WHEN (DATEPART(QQ,dbo.MYtoWY(src.TBSDY)) <> DATEPART(QQ,dbo.MYtoWY(src.NBSDY)))  AND HOLIDY <> 1 THEN 'Y' ELSE 'N' END                                                                                                                                                                                                                                                                                                                                                                                              
   ,/* BBOY_FG= */   CASE WHEN (DATEPART(YY,dbo.MYtoWY(src.TBSDY)) <> DATEPART(YY,dbo.MYtoWY(src.LBSDY)))  AND HOLIDY <> 1 THEN 'Y' ELSE 'N' END                                                                                                                                                                                                                                                                                                                                                                                              
   ,/* BEOY_FG= */   CASE WHEN (DATEPART(YY,dbo.MYtoWY(src.TBSDY)) <> DATEPART(YY,dbo.MYtoWY(src.NBSDY)))  AND HOLIDY <> 1 THEN 'Y' ELSE 'N' END                                                                                                                                                                                                                                                                                                                                                                                              
   ,/* EOM_FG= */    CASE WHEN dbo.MYtoWY(src.TBSDY) = dbo.MYtoWY(src.TMNDY) THEN 'Y' ELSE 'N' END                                                                                                                                                                                                                                                                                                                                                                                                                                            
   ,/* TBSDT= */     dbo.MYtoWY(src.TBSDY)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
   ,/* LBSDT= */     dbo.MYtoWY(src.LBSDY)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
   ,/* NBSDT= */     dbo.MYtoWY(src.NBSDY)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
   ,/* NNBSDT= */    dbo.MYtoWY(src.NNBSDY)                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
   ,/* LBSDY= */     src.LDYCNT                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
   ,/* NBSDY= */     src.NDYCNT                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
   ,/* NNBZDY= */    src.NNDYCNT                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
   ,/* DYCNTEOM= */  DATEDIFF(DD,dbo.MYtoWY(src.TBSDY),dbo.MYtoWY(src.TMNDY))                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
   ,/* NDYCNTTM= */  CASE WHEN dbo.MYtoWY(src.TBSDY) = dbo.MYtoWY(src.TMNDY) AND src.HOLIDY =1 THEN (CASE WHEN DATEDIFF(DD,dbo.MYtoWY(src.TBSDY),dbo.MYtoWY(src.TMNDY)) > src.NDYCNT THEN src.NDYCNT ELSE DATEDIFF(DD,dbo.MYtoWY(src.TBSDY),dbo.MYtoWY(src.TMNDY)) END ) ELSE src.NDYCNT END                                                                                                                                                                                                                                                                                                                      
   ,/* L2MNBDT= */   DATEADD(MM, - 2, DATEADD(DD, - (CAST(RIGHT(src.TBSDY,2) AS INT) - 1), dbo.MYtoWY(src.TBSDY)))                                                                                                                                                                                                                                                                                                                                                                                                                                      
   ,/* L2MNEDT= */   DATEADD(DD,-1,DATEADD(MM, - 1, DATEADD(DD, - (CAST(RIGHT(src.TBSDY,2) AS INT) - 1), dbo.MYtoWY(src.TBSDY))))                                                                                                                                                                                                                                                                                                                                                                                                                                           
   ,/* L2MNEDYS= */  RIGHT(CONVERT(VARCHAR,DATEADD(DD,-1,DATEADD(MM, - 1, DATEADD(DD, - (CAST(RIGHT(src.TBSDY,2) AS INT) - 1), dbo.MYtoWY(src.TBSDY)))),112),2)                                                                                                                                                                                                                                                                                                                                                                                                         
   ,/* LMNBDT= */    DATEADD(MM, - 1, DATEADD(DD, - (CAST(RIGHT(src.TBSDY,2) AS INT) - 1), dbo.MYtoWY(src.TBSDY)))                                                                                                                                                                                                                                                                                                                                                                                                                                      
   ,/* LMNEDT= */    DATEADD(DD, - (CAST(RIGHT(src.TBSDY,2) AS INT)), dbo.MYtoWY(src.TBSDY))                                                                                                                                                                                                                                                                                                                                                                                                                                                            
   ,/* LMNEDYS= */   RIGHT(CONVERT(VARCHAR(8),DATEADD(DD, - (CAST(RIGHT(src.TBSDY,2) AS INT)), dbo.MYtoWY(src.TBSDY)),112),2)                                                                                                                                                                                                                                                                                                                                                                                                                           
   ,/* TMNBDT= */    DATEADD(DD,-(CAST(RIGHT(src.TBSDY,2) AS INT)-1),dbo.MYtoWY(src.TBSDY))                                                                                                                                                                                                                                                                                                                                                                                                                                                             
   ,/* TMNEDT= */    dbo.MYtoWY(src.TMNDY)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
   ,/* TMNDYS= */    RIGHT(CONVERT(VARCHAR(8),dbo.MYtoWY(src.TMNDY),112),2)                                                                                                                                                                                                                                                                                                                                                                                                                                                     
   ,/* FNBSDT= */    dbo.MYtoWY(src.FNBSDY)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
   ,/* TQBDT= */     CASE WHEN DATEPART(QQ,dbo.MYtoWY(src.TBSDY)) = 1 THEN CONVERT(DATETIME,CONVERT(VARCHAR,YEAR(dbo.MYtoWY(src.TBSDY))) +'0101')  WHEN DATEPART(QQ,dbo.MYtoWY(src.TBSDY))=2 THEN CONVERT(DATETIME,CONVERT(VARCHAR,YEAR(dbo.MYtoWY(src.TBSDY))) +'0401') WHEN DATEPART(QQ,dbo.MYtoWY(src.TBSDY))=3 THEN CONVERT(DATETIME,CONVERT(VARCHAR,YEAR(dbo.MYtoWY(src.TBSDY))) +'0701') ELSE  CONVERT(DATETIME,CONVERT(VARCHAR,YEAR(dbo.MYtoWY(src.TBSDY))) +'1001')  END                                                                                                                                                                          
   ,/* TQEDT= */     CASE WHEN DATEPART(QQ,dbo.MYtoWY(src.TBSDY)) = 1 THEN CONVERT(DATETIME,CONVERT(VARCHAR,YEAR(dbo.MYtoWY(src.TBSDY))) +'0301')  WHEN DATEPART(QQ,dbo.MYtoWY(src.TBSDY))=2 THEN CONVERT(DATETIME,CONVERT(VARCHAR,YEAR(dbo.MYtoWY(src.TBSDY))) +'0601') WHEN DATEPART(QQ,dbo.MYtoWY(src.TBSDY))=3 THEN CONVERT(DATETIME,CONVERT(VARCHAR,YEAR(dbo.MYtoWY(src.TBSDY))) +'0901') ELSE CONVERT(DATETIME,CONVERT(VARCHAR,YEAR(dbo.MYtoWY(src.TBSDY))) +'1201')  END                                                                                                                                                                           
   ,/* TQDYS= */     CASE WHEN DATEPART(QQ,dbo.MYtoWY(src.TBSDY))=1 THEN DATEDIFF(DD,CONVERT(DATETIME,CONVERT(VARCHAR,YEAR(dbo.MYtoWY(src.TBSDY))) +'0101'),CONVERT(DATETIME,CONVERT(VARCHAR,YEAR(dbo.MYtoWY(src.TBSDY))) +'0331')) WHEN DATEPART(QQ,dbo.MYtoWY(src.TBSDY))=2 THEN 90 WHEN DATEPART(QQ,dbo.MYtoWY(src.TBSDY))=3 THEN 91 ELSE 91 END                                                                                                                                                                                                                                                                           
   ,/* L1QBDT= */    CASE WHEN DATEPART(QUARTER,DATEADD(QQ,-1,dbo.MYtoWY(src.TBSDY))) = 1 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-1,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0101') WHEN DATEPART(QUARTER,DATEADD(QQ,-1,dbo.MYtoWY(src.TBSDY))) = 2 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-1,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0401') WHEN DATEPART(QUARTER,DATEADD(QQ,-1,dbo.MYtoWY(src.TBSDY))) = 3 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-1,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0701') ELSE CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-1,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'1001') END  
   ,/* L1QEDT= */    CASE WHEN DATEPART(QUARTER,DATEADD(QQ,-1,dbo.MYtoWY(src.TBSDY))) = 1 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-1,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0301') WHEN DATEPART(QUARTER,DATEADD(QQ,-1,dbo.MYtoWY(src.TBSDY))) = 2 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-1,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0601') WHEN DATEPART(QUARTER,DATEADD(QQ,-1,dbo.MYtoWY(src.TBSDY))) = 3 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-1,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0901') ELSE CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-1,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'1201') END  
   ,/* L1QDYS= */    CASE WHEN DATEPART(QUARTER,DATEADD(QQ,-1,dbo.MYtoWY(src.TBSDY)))  =1 THEN  DATEDIFF(DD,CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-1,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0101'),CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-1,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0331'))  WHEN DATEPART(QUARTER,DATEADD(QQ,-1,dbo.MYtoWY(src.TBSDY)))=2 THEN 90 WHEN DATEPART(QUARTER,DATEADD(QQ,-1,dbo.MYtoWY(src.TBSDY)))=3 THEN 91 ELSE 91 END                                                                                                                                  
   ,/* L2QBDT= */    CASE WHEN DATEPART(QUARTER,DATEADD(QQ,-2,dbo.MYtoWY(src.TBSDY))) = 1 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-2,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0101') WHEN DATEPART(QUARTER,DATEADD(QQ,-2,dbo.MYtoWY(src.TBSDY))) = 2 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-2,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0401') WHEN DATEPART(QUARTER,DATEADD(QQ,-2,dbo.MYtoWY(src.TBSDY))) = 3 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-2,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0701') ELSE CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-2,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'1001') END  
   ,/* L2QEDT= */    CASE WHEN DATEPART(QUARTER,DATEADD(QQ,-2,dbo.MYtoWY(src.TBSDY))) = 1 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-2,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0301') WHEN DATEPART(QUARTER,DATEADD(QQ,-2,dbo.MYtoWY(src.TBSDY))) = 2 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-2,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0601') WHEN DATEPART(QUARTER,DATEADD(QQ,-2,dbo.MYtoWY(src.TBSDY))) = 3 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-2,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0901') ELSE CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-2,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'1201') END  
   ,/* L2QDYS= */    CASE WHEN DATEPART(QUARTER,DATEADD(QQ,-2,dbo.MYtoWY(src.TBSDY)))  =1 THEN  DATEDIFF(DD,CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-2,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0101'),CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-2,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0331'))  WHEN DATEPART(QUARTER,DATEADD(QQ,-2,dbo.MYtoWY(src.TBSDY)))=2 THEN 90 WHEN DATEPART(QUARTER,DATEADD(QQ,-2,dbo.MYtoWY(src.TBSDY)))=3 THEN 91 ELSE 91 END                                                                                                                                  
   ,/* L3QBDT= */    CASE WHEN DATEPART(QUARTER,DATEADD(QQ,-3,dbo.MYtoWY(src.TBSDY))) = 1 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-3,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0101') WHEN DATEPART(QUARTER,DATEADD(QQ,-3,dbo.MYtoWY(src.TBSDY))) = 2 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-3,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0401') WHEN DATEPART(QUARTER,DATEADD(QQ,-3,dbo.MYtoWY(src.TBSDY))) = 3 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-3,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0701') ELSE CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-3,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'1001') END  
   ,/* L3QEDT= */    CASE WHEN DATEPART(QUARTER,DATEADD(QQ,-3,dbo.MYtoWY(src.TBSDY))) = 1 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-3,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0301') WHEN DATEPART(QUARTER,DATEADD(QQ,-3,dbo.MYtoWY(src.TBSDY))) = 2 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-3,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0601') WHEN DATEPART(QUARTER,DATEADD(QQ,-3,dbo.MYtoWY(src.TBSDY))) = 3 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-3,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0901') ELSE CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-3,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'1201') END  
   ,/* L3QDYS= */    CASE WHEN DATEPART(QUARTER,DATEADD(QQ,-3,dbo.MYtoWY(src.TBSDY)))  =1 THEN  DATEDIFF(DD,CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-3,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0101'),CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-3,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0331'))  WHEN DATEPART(QUARTER,DATEADD(QQ,-3,dbo.MYtoWY(src.TBSDY)))=2 THEN 90 WHEN DATEPART(QUARTER,DATEADD(QQ,-3,dbo.MYtoWY(src.TBSDY)))=3 THEN 91 ELSE 91 END                                                                                                                                  
   ,/* L4QBDT= */    CASE WHEN DATEPART(QUARTER,DATEADD(QQ,-4,dbo.MYtoWY(src.TBSDY))) = 1 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-4,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0101') WHEN DATEPART(QUARTER,DATEADD(QQ,-4,dbo.MYtoWY(src.TBSDY))) = 2 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-4,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0401') WHEN DATEPART(QUARTER,DATEADD(QQ,-4,dbo.MYtoWY(src.TBSDY))) = 3 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-4,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0701') ELSE CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-4,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'1001') END  
   ,/* L4QEDT= */    CASE WHEN DATEPART(QUARTER,DATEADD(QQ,-4,dbo.MYtoWY(src.TBSDY))) = 1 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-4,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0301') WHEN DATEPART(QUARTER,DATEADD(QQ,-4,dbo.MYtoWY(src.TBSDY))) = 2 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-4,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0601') WHEN DATEPART(QUARTER,DATEADD(QQ,-4,dbo.MYtoWY(src.TBSDY))) = 3 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-4,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0901') ELSE CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-4,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'1201') END  
   ,/* L4QDYS= */    CASE WHEN DATEPART(QUARTER,DATEADD(QQ,-4,dbo.MYtoWY(src.TBSDY)))  =1 THEN  DATEDIFF(DD,CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-4,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0101'),CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-4,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0331'))  WHEN DATEPART(QUARTER,DATEADD(QQ,-4,dbo.MYtoWY(src.TBSDY)))=2 THEN 90 WHEN DATEPART(QUARTER,DATEADD(QQ,-4,dbo.MYtoWY(src.TBSDY)))=3 THEN 91 ELSE 91 END                                                                                                                                  
   ,/* L5QBDT= */    CASE WHEN DATEPART(QUARTER,DATEADD(QQ,-5,dbo.MYtoWY(src.TBSDY))) = 1 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-5,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0101') WHEN DATEPART(QUARTER,DATEADD(QQ,-5,dbo.MYtoWY(src.TBSDY))) = 2 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-5,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0401') WHEN DATEPART(QUARTER,DATEADD(QQ,-5,dbo.MYtoWY(src.TBSDY))) = 3 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-5,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0701') ELSE CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-5,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'1001') END  
   ,/* L5QEDT= */    CASE WHEN DATEPART(QUARTER,DATEADD(QQ,-5,dbo.MYtoWY(src.TBSDY))) = 1 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-5,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0301') WHEN DATEPART(QUARTER,DATEADD(QQ,-5,dbo.MYtoWY(src.TBSDY))) = 2 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-5,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0601') WHEN DATEPART(QUARTER,DATEADD(QQ,-5,dbo.MYtoWY(src.TBSDY))) = 3 THEN CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-5,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0901') ELSE CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-5,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'1201') END  
   ,/* L5QDYS= */    CASE WHEN DATEPART(QUARTER,DATEADD(QQ,-5,dbo.MYtoWY(src.TBSDY)))  =1 THEN  DATEDIFF(DD,CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-5,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0101'),CONVERT(DATETIME,CAST( YEAR( DATEADD(QQ,-5,dbo.MYtoWY(src.TBSDY))) AS VARCHAR )+'0331'))  WHEN DATEPART(QUARTER,DATEADD(QQ,-5,dbo.MYtoWY(src.TBSDY)))=2 THEN 90 WHEN DATEPART(QUARTER,DATEADD(QQ,-5,dbo.MYtoWY(src.TBSDY)))=3 THEN 91 ELSE 91 END 
   ,/* LstSysDt= */  GETDATE() as LstSysDt
        FROM odsdba.TMP_UN_YEARDAY AS src
    WHERE NOT EXISTS(
        SELECT * FROM CB_DT AS A
        WHERE A.datadt=dbo.MYtoWY(src.TBSDY)
    )
;


SELECT @ERR_NO = @@ERROR, @INS_CNT = @@ROWCOUNT;
IF @ERR_NO<>0 GOTO BATCH_ERR_HANDLE;



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
    EXEC [odsdba].[sp_XStatusFinish] @BATCH_NO, @JOB_STAGE, @JOB_FLOW, @JOB_SEQ, @JOB_START_TIME,   @INS_CNT, @UPD_CNT, @DIFF_CNT, @LOOKUP_IND, @ERR_NO;

END;

print '@SRC_CNT     =' + STR(@SRC_CNT);
print '@SRC_SEL_CNT =' + STR(@SRC_SEL_CNT);
print '@INS_CNT     =' + STR(@INS_CNT);
print '@UPD_CNT     =' + STR(@UPD_CNT);
print '@INS+@UPD    =' + STR(@INS_CNT + @UPD_CNT);

------------------------------
-- 程式結束 sp_CB_DT_TMP_UN_YEARDAY
------------------------------
IF @ERR_NO<>0 RAISERROR(@ERR_NO, 16, 1);
RETURN(@ERR_NO)
GO


