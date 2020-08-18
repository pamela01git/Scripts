USE PCUSEGDB
GO
--1.將正式TABLE rename為working table
EXEC sp_rename 'FS_PCuBrPdPf_MS', 'FS_PCuBrPdPf_MS_WK';
GO
--2.建立新table schema

IF EXISTS (SELECT * FROM sysobjects WHERE Name ='FS_PCuBrPdPf_MS') DROP TABLE ODSDBA.FS_PCuBrPdPf_MS;
CREATE TABLE ODSDBA.FS_PCuBrPdPf_MS
(
 DATADT                                  DATETIME             NOT NULL ,
 CUSTKEY                                 CHAR      (11)       NOT NULL ,
 GLORGNO                                 CHAR      (3)        NOT NULL ,
 PDBCCD                                  CHAR      (10)       NOT NULL ,
 DEPTNO                                  CHAR      (3)        DEFAULT -1 NOT NULL ,
 PDBCCAMPCD                              CHAR      (10)      ,
 CITYNO                                  NUMERIC   (4)       ,
 REGNM                                   CHAR      (10)      ,
 REGSEQ                                  NUMERIC   (4)       ,
 ASSETRANKCD                             CHAR      (2)       ,
 BIRTHDAY                                DATETIME            ,
 TAGEGUP                                 CHAR      (20)      ,
 TAGEGUPSEQ                              NUMERIC   (2)       ,
 AGERANKCD                               NUMERIC   (3)       ,
 SEX                                     CHAR      (2)       ,
 EDU                                     NUMERIC   (1)       ,
 MARRIAGE                                CHAR      (2)       ,
 JOBCD                                   NUMERIC   (2)       ,
 CZIPCD                                  NUMERIC   (5)       ,
 ZIPCAT2NO                               NUMERIC   (4)       ,
 ZIPCAT3                                 CHAR      (10)      ,
 ZIPCAT3SEQ                              NUMERIC   (4)       ,
 CULIFECNT                               NUMERIC   (7)       ,
 ACCTLIFELMNCNT                          NUMERIC   (9)       ,
 ACCTNEWCNT                              NUMERIC   (9)       ,
 ACCTCLOSEDCNT                           NUMERIC   (9)       ,
 ACCTLIFECNT                             NUMERIC   (9)       ,
 ACCTCNT                                 NUMERIC   (9)       ,
 ACCTBLOCKEDCNT                          NUMERIC   (9)       ,
 ACCTQUIETCNT                            NUMERIC   (9)       ,
 ACCTACTIVECNT                           NUMERIC   (9)       ,
 ACCTNEWAMT                              NUMERIC   (16,2)    ,
 ACCTCLOSEAMT                            NUMERIC   (16,2)    ,
 ACCTQUIETAMT                            NUMERIC   (16,2)    ,
 ACCTCONTRIBUTIONAMT                     NUMERIC   (12)      ,
 EOMBAL                                  NUMERIC   (16,2)    ,
 LMNEOMBAL                               NUMERIC   (16,2)    ,
 AVGBAL                                  NUMERIC   (16,2)    ,
 AVGBALSUM                               NUMERIC   (16,2)    ,
 LMNAVGBALSUM                            NUMERIC   (16,2)    ,
 MLYDAYS                                 NUMERIC   (4)       ,
 LMNMLYDAYS                              NUMERIC   (4)       ,
 BALINCRCNT                              NUMERIC   (9)       ,
 BALDECRCNT                              NUMERIC   (9)       ,
 BALINCRAMT                              NUMERIC   (16,2)    ,
 BALDECRAMT                              NUMERIC   (16,2)    ,
 CCCSCNT                                 NUMERIC   (9)       ,
 CCCACNT                                 NUMERIC   (16,2)    ,
 CCCSAMT                                 NUMERIC   (9)       ,
 CCCAAMT                                 NUMERIC   (16,2)    ,
 DEQCNT                                  NUMERIC   (9)       ,
 RPTDEQCNT                               NUMERIC   (9)       ,
 DEQAMT                                  NUMERIC   (16,2)    ,
 DATACNT                                 NUMERIC   (7)       ,
 LSTRECNO                                NUMERIC   (8)    IDENTITY (1,1)  ,
 ORGDATASRC                              CHAR      (16)      ,
 ORGDEDT                                 DATETIME            ,
 LSTCYCDT                                DATETIME            ,
 LSTSYSDT                                DATETIME            ,
)
ON PCuSegDB_PS_FS(DATADT)

CREATE UNIQUE INDEX FS_PCuBrPdPf_MS_IDX_1 ON ODSDBA.FS_PCuBrPdPf_MS
(
    DataDt, CustKey, GLOrgNo, PdBCCd, DeptNo
)
ON PCuSegDB_PS_FS(DATADT)
ALTER TABLE ODSDBA.FS_PCuBrPdPf_MS WITH NOCHECK ADD CONSTRAINT PK_FS_PCuBrPdPf_MS_1 PRIMARY KEY CLUSTERED
(
    DataDt, CustKey, GLOrgNo, PdBCCd, DeptNo
) ON PCuSegDB_PS_FS(DATADT)
GO

--3.以CURSOR方式依月份分別INSERT至新TABLE(測試套可量力而為,決定要INSERT幾個月)
DECLARE @datadt CHAR(20) --變數

DECLARE InsertDt CURSOR FOR 
  SELECT datadt from odsdba.cb_dt
  where dy_in_mn = 1
   and datadt between '20050301' and '20060901' --選定INSERT區間
  ORDER BY DATADT DESC
   
        OPEN InsertDt; -- 開始執行
        FETCH NEXT FROM InsertDt --第一筆
             INTO @datadt -- cursor裡的變數    
                                                                                                          
        WHILE @@FETCH_STATUS = 0   --當結束時就停止
     
BEGIN --開始進行作業
  
    BEGIN TRAN
    INSERT INTO ODSDBA.FS_PCuBrPdPf_MS (DATADT, CUSTKEY, GLORGNO, PDBCCD, PDBCCAMPCD, CITYNO, RegNm, REGSEQ, ASSETRANKCD, BIRTHDAY, AGERANKCD, TAgeGup, TAgeGupSeq, SEX, EDU, MARRIAGE, JOBCD, CZIPCD, ZIPCat2No, ZIPCat3, ZIPCat3Seq, CULIFECNT, ACCTLIFELMNCNT, ACCTNEWCNT, ACCTCLOSEDCNT, ACCTLIFECNT, ACCTCNT, ACCTBLOCKEDCNT, ACCTQUIETCNT, ACCTACTIVECNT, ACCTNEWAMT, ACCTCLOSEAMT, ACCTQUIETAMT, ACCTCONTRIBUTIONAMT, EOMBAL, LMNEOMBAL, AVGBAL, AVGBALSUM, LMNAVGBALSUM, MLYDAYS, LMNMLYDAYS, BALINCRCNT, BALDECRCNT, BALINCRAMT, BALDECRAMT, CCCSCNT, CCCACNT, CCCSAMT, CCCAAMT, DEQCNT, RPTDEQCNT, DEQAMT, DATACNT, LstRecNo, ORGDATASRC, ORGDEDT, LSTCYCDT, LSTSYSDT)
    SELECT DATADT, CUSTKEY, GLORGNO, PDBCCD, PDBCCAMPCD, CITYNO, RegNm, REGSEQ, ASSETRANKCD, BIRTHDAY, AGERANKCD, TAgeGup, TAgeGupSeq, SEX, EDU, MARRIAGE, JOBCD, CZIPCD, ZIPCat2No, ZIPCat3, ZIPCat3Seq, CULIFECNT, ACCTLIFELMNCNT, ACCTNEWCNT, ACCTCLOSEDCNT, ACCTLIFECNT, ACCTCNT, ACCTBLOCKEDCNT, ACCTQUIETCNT, ACCTACTIVECNT, ACCTNEWAMT, ACCTCLOSEAMT, ACCTQUIETAMT, ACCTCONTRIBUTIONAMT, EOMBAL, LMNEOMBAL, AVGBAL, AVGBALSUM, LMNAVGBALSUM, MLYDAYS, LMNMLYDAYS, BALINCRCNT, BALDECRCNT, BALINCRAMT, BALDECRAMT, CCCSCNT, CCCACNT, CCCSAMT, CCCAAMT, DEQCNT, RPTDEQCNT, DEQAMT, DATACNT, LstRecNo, ORGDATASRC, ORGDEDT, LSTCYCDT, LSTSYSDT
    FROM ODSDBA.FS_PCuBrPdPf_MS_WK
    WHERE DATADT = @datadt
    COMMIT TRAN

   FETCH NEXT FROM InsertDt --進行下一筆
   INTO @datadt    
END   

CLOSE InsertDt;        --結束cursor                                                                                                              
DEALLOCATE InsertDt

--4.將WORKING表格刪除
DROP TABLE ODSDBA.FS_PCuBrPdPf_MS_WK



