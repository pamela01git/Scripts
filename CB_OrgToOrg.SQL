if exists (select * from dbo.sysobjects where id = object_id(N'[odsdba].[SP_INS_CBOrgToOrg_Org2Org]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [odsdba].[SP_INS_CBOrgToOrg_Org2Org]
go


CREATE PROCEDURE SP_INS_CBOrgToOrg_Org2Org
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
-- Excel File     : LBOT Report DB v1.0.xls
-- Format Version : V0
-- Rule Version   : V0
-- Data Source    : SA
-- Last MNT Date  : 
-- This MNT Date  : 2005/11/9

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
    FROM odsdba.CB_OrgToOrg AS src
    ;

    -- 計算 @SRC_SEL_CNT
    SELECT @SRC_SEL_CNT = @SRC_CNT
    ;

    -- 更新 XSTATUS
    EXEC [odsdba].[sp_XStatusStart] @BATCH_NO, @JOB_STAGE, @JOB_FLOW, @JOB_SEQ, @ETL_BEGIN_DATE, @ETL_END_DATE,
    'CB_OrgToOrg', 'CB_OrgToOrg', @JOB_START_TIME, @SRC_CNT, @SRC_SEL_CNT, @FLT_CNT output, @BATCH_CNT output
END;


-------------------------------------------------------------------------------
-- 整批模式開始
-------------------------------------------------------------------------------
PRINT 'Batch Mode : Start';
IF @RUN_MODE <> 'TEST' BEGIN
    BEGIN TRAN
END;

--truncate後整重
truncate table odsdba.cb_orgtoorg;

--宣告CURSOR
DECLARE @OrgNo CHAR(3)

DECLARE Org2Org CURSOR FOR 
           SELECT  distinct orgno             
           FROM odsdba.CB_Org2Org;
 
 
 --OPEN CURSOR   
   
        OPEN Org2Org;
        FETCH NEXT FROM Org2Org 
             INTO @OrgNo 
                                                                                                          
        WHILE @@FETCH_STATUS = 0   
     
BEGIN
	
	create table #tmp1 ( seq int identity --序號
	                    ,OrgNo CHAR (3)   --分行代碼
	                    ,RelationOrgNo CHAR (3) --關係分行
                   );
         insert into   #tmp1 (orgno,relationorgno)
         select orgno,RelationOrgNo from  odsdba.CB_Org2Org where orgno =@orgno;     
 
--計算該分行能看幾個分行的資料

DECLARE @CNT INT
DECLARE @TEMPCNT INT
DECLARE @RelationOrg CHAR(3)
DECLARE @NewRelationOrg VARCHAR(500)
SELECT @CNT =(SELECT COUNT(1) FROM odsdba.CB_Org2Org WHERE OrgNo = @OrgNo );

--初始化變數
SET @TEMPCNT = 0
SET @NewRelationOrg = ''   
      
IF @CNT > 0 BEGIN
   WHILE  @TEMPCNT < @CNT
     BEGIN
       SET @RelationOrg = (select RelationOrgNo from #tmp1 where seq= @TEMPCNT + 1)
       if @TEMPCNT > 0
       begin 
          set @NewRelationOrg = @NewRelationOrg + '|' +@RelationOrg
       end else begin
       	  set @NewRelationOrg = @RelationOrg 
       end	  
        SET @TEMPCNT = @TEMPCNT +1;
    END;                     
END;    

DROP TABLE #tmp1 ;

INSERT INTO odsdba.CB_OrgToOrg   (OrgNo,RelationOrgNo,ModifyDt,ModifyUserNo,ModifyUserNm)   
select @OrgNo,replace(@NewRelationOrg,' ',''),GETDATE(),'LBOT','EXCEL';

        FETCH NEXT FROM Org2Org 
             INTO  @OrgNo    

END   

CLOSE Org2Org;                                                                                                                      
DEALLOCATE Org2Org;

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
    /*IF @F_UPD_SRC_CNT='Y' BEGIN
        SELECT @DIFF_CNT = @SRC_CNT -(@INS_CNT + @UPD_CNT + @FLT_CNT);
    END ELSE BEGIN
        SELECT @DIFF_CNT = @BATCH_CNT -(@INS_CNT + @UPD_CNT + @FLT_CNT);
    END;*/
    SELECT @DIFF_CNT = @SRC_CNT -(@INS_CNT + @FLT_CNT);

    -- 更新 XSTATUS
    EXEC [odsdba].[sp_XStatusFinish] @BATCH_NO, @JOB_STAGE, @JOB_FLOW, @JOB_SEQ, @JOB_START_TIME,   @INS_CNT, @UPD_CNT, @DIFF_CNT, @LOOKUP_IND, @ERR_NO;

END;

print '@SRC_CNT     =' + STR(@SRC_CNT);
print '@SRC_SEL_CNT =' + STR(@SRC_SEL_CNT);
print '@INS_CNT     =' + STR(@INS_CNT);
print '@UPD_CNT     =' + STR(@UPD_CNT);
print '@INS+@UPD    =' + STR(@INS_CNT + @UPD_CNT);

------------------------------
-- 程式結束 SP_INS_CBOrgToOrg_Org2Org
------------------------------
IF @ERR_NO<>0 RAISERROR(@ERR_NO, 16, 1);
RETURN(@ERR_NO)
GO


