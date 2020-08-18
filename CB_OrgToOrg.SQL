if exists (select * from dbo.sysobjects where id = object_id(N'[odsdba].[SP_INS_CBOrgToOrg_Org2Org]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [odsdba].[SP_INS_CBOrgToOrg_Org2Org]
go


CREATE PROCEDURE SP_INS_CBOrgToOrg_Org2Org
    @BATCH_NO       VARCHAR(10),        --XBATCHFLOW.BATCH_NO
    @JOB_STAGE      CHAR(4),            --XBATCHFLOW.JOB_STAGE
    @JOB_FLOW       INTEGER,            --XBATCHFLOW.JOB_FLOW
    @JOB_SEQ        INTEGER,            --XBATCHFLOW.JOB_SEQ
    @ETL_BEGIN_DATE DATETIME,           --�@�~�_�l���
    @ETL_END_DATE   DATETIME,           --�@�~�_�l���
    @RUN_MODE       VARCHAR(7)          --�Ұʪ��A(Normal/Restart)
AS

-- �H�U�� XSTATUS �����ܼ�
DECLARE @JOB_START_TIME datetime        --�{���_�l�ɶ�
DECLARE @LOOKUP_IND     varchar(1)      --�O�_�����X�s�N�X�ܥN�X��(T/F)
DECLARE @BATCH_CNT      decimal(10)     --�ӷ���Ƶ���(By XBHDATE2)
DECLARE @SRC_CNT        decimal(10)     --�ӷ���Ƶ���(By Count)
DECLARE @INS_CNT        decimal(10)     --�s�W��Ƶ���
DECLARE @UPD_CNT        decimal(10)     --��s��Ƶ���
DECLARE @FLT_CNT        decimal(10)     --�z�ﵧ��(Filter�ñ�������)
DECLARE @SRC_SEL_CNT    decimal(10)     --�ӷ����Filter�d�U�Ӫ�����
DECLARE @DIFF_CNT       decimal(10)     --�t������

-- �H�U�� ���汱�� �����ܼ�
DECLARE @ERR_NO         int             --���~�N�X
DECLARE @F_UPD_XSTATUS  char(1)         --�O�_��sXSTATUS��ƪ�(T=TRUE,F=FALSE)
DECLARE @F_UPD_ERRLOG   char(1)         --�O�_��sERRLOG��ƪ� (T=TRUE,F=FALSE)
DECLARE @F_UPD_SRC_CNT  char(1)         --�]�wXSTATUS.SRC_CNT�O�_����(Y=Yes,N=No)
DECLARE @F_MNT_CODE_TBL char(1)         --�O�_����s�������N�X��(T=TRUE,F=FALSE)
DECLARE @F_LOOKUP_FLAG  char(1)         --Lookup�ĥ|�ӰѼơG
                                        --  T(�N�s�N�X�g�J�N�X���A�ò��ͬ���)
                                        --  F(���g�J�N�X���A�����ͬ���)
                                        --  N(���B�z)
------------------------------
-- ��������
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
-- �{���}�l
------------------------------
-- ����X��
SET @F_UPD_XSTATUS = 'T';
SET @F_UPD_ERRLOG = 'T';
SET @F_UPD_SRC_CNT = 'N'
SET @F_MNT_CODE_TBL = 'T';

-- �b���ռҦ��U�A���L XSTATUS, ERRLOG ����s
IF UPPER(@RUN_MODE) = 'TEST' BEGIN
    SET @F_UPD_XSTATUS = 'T';
    SET @F_UPD_ERRLOG = 'T';
END;

SET @JOB_START_TIME = GetDate();
SET @INS_CNT = 0;
SET @UPD_CNT = 0;
SET @LOOKUP_IND = 'F';  --default

------------------------------
-- �NXSTATUS��s�� '���椤',��
-- �p��BATCH_CNT, SRC_CNT, FLT_CNT
------------------------------
IF @F_UPD_XSTATUS = 'T' BEGIN

    -- �p�� @SRC_CNT
    SELECT @SRC_CNT = COUNT(*)
    FROM odsdba.CB_OrgToOrg AS src
    ;

    -- �p�� @SRC_SEL_CNT
    SELECT @SRC_SEL_CNT = @SRC_CNT
    ;

    -- ��s XSTATUS
    EXEC [odsdba].[sp_XStatusStart] @BATCH_NO, @JOB_STAGE, @JOB_FLOW, @JOB_SEQ, @ETL_BEGIN_DATE, @ETL_END_DATE,
    'CB_OrgToOrg', 'CB_OrgToOrg', @JOB_START_TIME, @SRC_CNT, @SRC_SEL_CNT, @FLT_CNT output, @BATCH_CNT output
END;


-------------------------------------------------------------------------------
-- ���Ҧ��}�l
-------------------------------------------------------------------------------
PRINT 'Batch Mode : Start';
IF @RUN_MODE <> 'TEST' BEGIN
    BEGIN TRAN
END;

--truncate��㭫
truncate table odsdba.cb_orgtoorg;

--�ŧiCURSOR
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
	
	create table #tmp1 ( seq int identity --�Ǹ�
	                    ,OrgNo CHAR (3)   --����N�X
	                    ,RelationOrgNo CHAR (3) --���Y����
                   );
         insert into   #tmp1 (orgno,relationorgno)
         select orgno,RelationOrgNo from  odsdba.CB_Org2Org where orgno =@orgno;     
 
--�p��Ӥ����ݴX�Ӥ��檺���

DECLARE @CNT INT
DECLARE @TEMPCNT INT
DECLARE @RelationOrg CHAR(3)
DECLARE @NewRelationOrg VARCHAR(500)
SELECT @CNT =(SELECT COUNT(1) FROM odsdba.CB_Org2Org WHERE OrgNo = @OrgNo );

--��l���ܼ�
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



-- Update ���Ψ�Target Table�����---------------------
-- No such fields

------------------------------
-- ���Ҧ��B�z���\
------------------------------
PRINT 'Batch Mode : Finished Successfully';
PRINT '';
IF @RUN_MODE <> 'TEST' BEGIN
    COMMIT TRAN;
END;
GOTO WRITE_LOG;



-------------------------------------------------------------------------------
-- ���Ҧ����~�B�z
   BATCH_ERR_HANDLE:
-------------------------------------------------------------------------------
PRINT 'Batch Mode : Failure';
PRINT '';
IF @RUN_MODE <> 'TEST' BEGIN
    ROLLBACK TRAN;
END;

             
------------------------------
-- ���浲�G����
   WRITE_LOG:
------------------------------
IF @F_UPD_XSTATUS = 'T' BEGIN

    -- �p�� @DIFF_CNT
    /*IF @F_UPD_SRC_CNT='Y' BEGIN
        SELECT @DIFF_CNT = @SRC_CNT -(@INS_CNT + @UPD_CNT + @FLT_CNT);
    END ELSE BEGIN
        SELECT @DIFF_CNT = @BATCH_CNT -(@INS_CNT + @UPD_CNT + @FLT_CNT);
    END;*/
    SELECT @DIFF_CNT = @SRC_CNT -(@INS_CNT + @FLT_CNT);

    -- ��s XSTATUS
    EXEC [odsdba].[sp_XStatusFinish] @BATCH_NO, @JOB_STAGE, @JOB_FLOW, @JOB_SEQ, @JOB_START_TIME,   @INS_CNT, @UPD_CNT, @DIFF_CNT, @LOOKUP_IND, @ERR_NO;

END;

print '@SRC_CNT     =' + STR(@SRC_CNT);
print '@SRC_SEL_CNT =' + STR(@SRC_SEL_CNT);
print '@INS_CNT     =' + STR(@INS_CNT);
print '@UPD_CNT     =' + STR(@UPD_CNT);
print '@INS+@UPD    =' + STR(@INS_CNT + @UPD_CNT);

------------------------------
-- �{������ SP_INS_CBOrgToOrg_Org2Org
------------------------------
IF @ERR_NO<>0 RAISERROR(@ERR_NO, 16, 1);
RETURN(@ERR_NO)
GO

