SET NOCOUNT ON
 DECLARE @TABLENAME VARCHAR(4000)


           DECLARE ParamList CURSOR LOCAL  FOR 
           
         SELECT RTRIM(NAME)
         FROM SYS.TABLES
           WHERE  NAME IN
         (
'BY_APNO'
,'BY_BCODE'
,'CB_CCust'
,'ODS_XBATCHFLOW'
,'ODS_XSTARTTIME'
,'TMP_BD_BDCUST04A'
,'TMP_BD_BDCUST075'
,'TMP_BD_BDCUST07A'
,'TMP_BD_BDMST04A'
,'TMP_BD_BDMST075'
,'TMP_BD_BDMST07A'
,'TMP_BD_BDPYMT04A'
,'TMP_BD_BDPYMT075'
,'TMP_BD_BDPYMT07A'
,'TMP_BD_BDSTOCK04A'
,'TMP_BD_BDSTOCK075'
,'TMP_BD_BDSTOCK07A'
,'TMP_BD_BDTXN04A'
,'TMP_BD_BDTXN075'
,'TMP_BD_BDTXN07A'
,'TMP_BD_BDTXNH04A'
,'TMP_BD_BDTXNH075'
,'TMP_BD_BDTXNH07A'
,'TMP_BD_BILLRPS'
,'TMP_BD_BIMST04A'
,'TMP_BD_BIMST075'
,'TMP_BD_BIMST07A'
,'TMP_BD_BIRATE04A'
,'TMP_BD_BIRATE075'
,'TMP_BD_BIRATE07A'
,'TMP_BD_BITXN04A'
,'TMP_BD_BITXN075'
,'TMP_BD_BITXN07A'
,'TMP_BD_BITXNH04A'
,'TMP_BD_BITXNH075'
,'TMP_BD_BITXNH07A'
,'TMP_BD_BONDRPS'
,'TMP_BD_LONREM04A'
,'TMP_BD_LONREM075'
,'TMP_BD_LONREM07A'
,'TMP_BD_LONTR04A'
,'TMP_BD_LONTR075'
,'TMP_BD_LONTR07A'
,'TMP_CC_CHECK'
,'TMP_CC_LBKCDOPUP'
,'TMP_CC_LBKCTRYP'
,'TMP_CC_SCMACCTP'
,'TMP_CC_SCMCACCP'
,'TMP_CC_SCMCARDP'
,'TMP_CC_SCMCTDTP'
,'TMP_CC_SCMCUSTXP'
,'TMP_CC_SCMINTNP'
,'TMP_CC_SCMMCCDP'
,'TMP_CC_SCMMCCTP'
,'TMP_CC_SCMMECHP'
,'TMP_CC_SCMMEEXP'
,'TMP_CC_SCMOLSHP'
,'TMP_CC_SCMOLSTP'
,'TMP_CC_SCMPRODP'
,'TMP_CC_SCMRTBALP'
,'TMP_CC_SCMTDSCP'
,'TMP_CC_SCMXPACP'
,'TMP_CT_CALLTYPE'
,'TMP_CT_CRMMOB'
,'TMP_CT_CRMPOB'
,'TMP_CT_CRMPROMOFLAG'
,'TMP_CT_CUSTOMHISTORY'
,'TMP_ICB_TBACCBALD'
,'TMP_ICB_TBACCBALM'
,'TMP_ICB_TBACCCODM'
,'TMP_ICB_TBACCVOUD'
,'TMP_ICB_TBACCVOUM'
,'TMP_ICB_TBACCVOUS'
,'TMP_ICB_TBBILBILM'
,'TMP_ICB_TBCSTACCM'
,'TMP_ICB_TBCSTCUSM'
,'TMP_ICB_TBCSTEVND'
,'TMP_ICB_TBCSTFEEL'
,'TMP_ICB_TBCSTFEEM'
,'TMP_ICB_TBCSTINVD'
,'TMP_ICB_TBCSTINVL'
,'TMP_ICB_TBCSTINVM'
,'TMP_ICB_TBTRNBILD'
,'TMP_ICB_TBTRNBILM'
,'TMP_ICB_TBTRNBILS'
,'TMP_INS_CONTRACT'
,'TMP_INS_CONTRACTTEST'
,'TMP_INS_INTROFEE'
,'TMP_INS_QKRPT'
,'TMP_MF_AC1FIL'
,'TMP_MF_AC2FIL'
,'TMP_MF_CTMFIL'
,'TMP_MF_FUAFIL'
,'TMP_MF_FUNFIL'
,'TMP_MF_FUSFIL'
,'TMP_MF_NETFIL'
,'TMP_MF_PROFIL'
,'TMP_MF_PRPFIL'
,'TMP_MF_RATFIL'
,'TMP_MF_TR1FIL'
,'TMP_MF_UUNFIL'
,'TMP_MF_VUNFIL'
,'TMP_OB_CHECKLAX'
,'TMP_OB_CHECKSIN'
,'TMP_OB_CMBNAMLAX'
,'TMP_OB_CMBNAMSIN'
,'TMP_OB_CMBNKMLAX'
,'TMP_OB_CMBNKMSIN'
,'TMP_OB_CMCALMLAX'
,'TMP_OB_CMCALMSIN'
,'TMP_OB_CMCIFMLAX'
,'TMP_OB_CMCIFMSIN'
,'TMP_OB_CMCILMLAX'
,'TMP_OB_CMCILMSIN'
,'TMP_OB_CPBUYTLAX'
,'TMP_OB_CPBUYTSIN'
,'TMP_OB_CPSECMLAX'
,'TMP_OB_CPSECMSIN'
,'TMP_OB_CSABHMLAX'
,'TMP_OB_CSABHMSIN'
,'TMP_OB_CSDBLMLAX'
,'TMP_OB_CSDBLMSIN'
,'TMP_OB_CSHISTLAX'
,'TMP_OB_CSHISTSIN'
,'TMP_OB_CSMSTMLAX'
,'TMP_OB_CSMSTMSIN'
,'TMP_OB_DLFXTTLAX'
,'TMP_OB_DLFXTTSIN'
,'TMP_OB_EXBPAMLAX'
,'TMP_OB_EXBPAMSIN'
,'TMP_OB_EXECAMLAX'
,'TMP_OB_EXECAMSIN'
,'TMP_OB_EXLAFMLAX'
,'TMP_OB_EXLAFMSIN'
,'TMP_OB_EXLALMLAX'
,'TMP_OB_EXLALMSIN'
,'TMP_OB_EXLAMMLAX'
,'TMP_OB_EXLAMMSIN'
,'TMP_OB_FDARKMLAX'
,'TMP_OB_FDARKMSIN'
,'TMP_OB_FRBCCMLAX'
,'TMP_OB_FRBCCMSIN'
,'TMP_OB_FRBPPMLAX'
,'TMP_OB_FRBPPMSIN'
,'TMP_OB_FRFBNMLAX'
,'TMP_OB_FRFBNMSIN'
,'TMP_OB_FRIRAMLAX'
,'TMP_OB_FRIRAMSIN'
,'TMP_OB_FRORTMLAX'
,'TMP_OB_FRORTMSIN'
,'TMP_OB_FRTCSMLAX'
,'TMP_OB_FRTCSMSIN'
,'TMP_OB_IMICMMLAX'
,'TMP_OB_IMICMMSIN'
,'TMP_OB_IMLABMLAX'
,'TMP_OB_IMLABMSIN'
,'TMP_OB_IMLADMLAX'
,'TMP_OB_IMLADMSIN'
,'TMP_OB_IMLCMMLAX'
,'TMP_OB_IMLCMMSIN'
,'TMP_OB_IMLGRMLAX'
,'TMP_OB_IMLGRMSIN'
,'TMP_OB_LNGTTMLAX'
,'TMP_OB_LNGTTMSIN'
,'TMP_OB_LNINTHLAX'
,'TMP_OB_LNINTHSIN'
,'TMP_OB_LNMSAMLAX'
,'TMP_OB_LNMSAMSIN'
,'TMP_OB_LNMSTMLAX'
,'TMP_OB_LNMSTMSIN'
,'TMP_OB_LNTRAHLAX'
,'TMP_OB_LNTRAHSIN'
,'TMP_OB_TDBALHLAX'
,'TMP_OB_TDBALHSIN'
,'TMP_OB_TDMSAMLAX'
,'TMP_OB_TDMSAMSIN'
,'TMP_OB_TDMSTMLAX'
,'TMP_OB_TDMSTMSIN'
,'TMP_OB_TDTRAHLAX'
,'TMP_OB_TDTRAHSIN'
,'TMP_SK_ACCT'
,'TMP_SK_TXMATCH'
,'TMP_UN_ACC'
,'TMP_UN_ACCTL'
,'TMP_UN_ACDATA'
,'TMP_UN_ACMR'
,'TMP_UN_ACNAPP'
,'TMP_UN_ACTNUM'
,'TMP_UN_ACTSLP'
,'TMP_UN_ACTX'
,'TMP_UN_ADMR'
,'TMP_UN_ADTR'
,'TMP_UN_AVEBAL'
,'TMP_UN_BAF'
,'TMP_UN_BBAL'
,'TMP_UN_BCODE'
,'TMP_UN_BCTL'
,'TMP_UN_BHDATE'
,'TMP_UN_BIOBACK'
,'TMP_UN_BKEEP'
,'TMP_UN_BKINF'
,'TMP_UN_BLICRD'
,'TMP_UN_BPCL'
,'TMP_UN_BPLA'
,'TMP_UN_BPMR'
,'TMP_UN_BPTR'
,'TMP_UN_BRA'
,'TMP_UN_BRDTL'
,'TMP_UN_BREG'
,'TMP_UN_BRLOG'
,'TMP_UN_BRMR'
,'TMP_UN_BRNM'
,'TMP_UN_BRNO'
,'TMP_UN_BRTOT'
,'TMP_UN_BUDG'
,'TMP_UN_CBMR'
,'TMP_UN_CBOND'
,'TMP_UN_CBTR'
,'TMP_UN_CCARD'
,'TMP_UN_CFACT'
,'TMP_UN_CHST'
,'TMP_UN_CHSTK'
,'TMP_UN_CKMR'
,'TMP_UN_CLIENT'
,'TMP_UN_CMCALMLAX'
,'TMP_UN_CMCALMSIN'
,'TMP_UN_COMBO'
,'TMP_UN_CRCY'
,'TMP_UN_CRINF'
,'TMP_UN_CTHTR'
,'TMP_UN_CTL'
,'TMP_UN_CTMR'
,'TMP_UN_CUST'
,'TMP_UN_DAY'
,'TMP_UN_DEBTN'
,'TMP_UN_DLTACT_DP'
,'TMP_UN_DLTACT_LN'
,'TMP_UN_EDIMR'
,'TMP_UN_EMPLY'
,'TMP_UN_FACI'
,'TMP_UN_FBAS'
,'TMP_UN_FBTR'
,'TMP_UN_FCLMR'
,'TMP_UN_FDMR'
,'TMP_UN_FEXMR'
,'TMP_UN_FPHTR'
,'TMP_UN_FPMR'
,'TMP_UN_FPPB'
,'TMP_UN_FRBAF'
,'TMP_UN_FXEXP'
,'TMP_UN_FXLN'
,'TMP_UN_HACTX'
,'TMP_UN_HTXAC'
,'TMP_UN_IMABS'
,'TMP_UN_IMLN'
,'TMP_UN_IMMR'
,'TMP_UN_IMTR'
,'TMP_UN_INTDCT'
,'TMP_UN_INTDFD'
,'TMP_UN_INTR'
,'TMP_UN_IRMR'
,'TMP_UN_KSMR'
,'TMP_UN_LAMR'
,'TMP_UN_LATR'
,'TMP_UN_LBANK'
,'TMP_UN_LCMR'
,'TMP_UN_LDDEC'
,'TMP_UN_LDDTL'
,'TMP_UN_LDINC'
,'TMP_UN_LGDTL'
,'TMP_UN_LN417'
,'TMP_UN_LXDTL'
,'TMP_UN_MGDTL'
,'TMP_UN_MGMR'
,'TMP_UN_MGTINFO'
,'TMP_UN_MNACN'
,'TMP_UN_MONEY'
,'TMP_UN_NAINF'
,'TMP_UN_NBCA'
,'TMP_UN_NBUSER'
,'TMP_UN_NLACC'
,'TMP_UN_NLBAF'
,'TMP_UN_NLMR'
,'TMP_UN_NUMWK1'
,'TMP_UN_NUMWK2'
,'TMP_UN_NUMWK3'
,'TMP_UN_NUMWK4'
,'TMP_UN_NUMWK6'
,'TMP_UN_OBUDTL'
,'TMP_UN_ORMR'
,'TMP_UN_PBMR'
,'TMP_UN_PROCTL'
,'TMP_UN_PROD'
,'TMP_UN_PROFIT'
,'TMP_UN_PSMR'
,'TMP_UN_REMARK'
,'TMP_UN_REMPRO'
,'TMP_UN_RTACT'
,'TMP_UN_RTBAL'
,'TMP_UN_RTBAL1'
,'TMP_UN_RTBAL2'
,'TMP_UN_RTBAL3'
,'TMP_UN_RTBAL4'
,'TMP_UN_RTBAL5'
,'TMP_UN_RTMR'
,'TMP_UN_SECU'
,'TMP_UN_SECUR'
,'TMP_UN_STOCK'
,'TMP_UN_TCMR'
,'TMP_UN_TCST'
,'TMP_UN_VID'
,'TMP_UN_VIPIDNO'
,'TMP_UN_VOUCH'
,'TMP_UN_VPIN'
,'TMP_UN_VTN'
,'TMP_UN_XCRT'
,'TMP_UN_YEARDAY'
,'XBATCHFLOW'
,'XBHDATE1'
,'XCLOSE'
,'XFILEDATE'
,'XFLOWLOG'
,'XFLOWLOGH'
,'XFLOWMSG'
,'XJOBDETAIL'
,'XLOOKUP_LOG'
,'XMAIL'
,'XPARAM'
,'XSYSTEM'





         )


DECLARE @PK_NAME VARCHAR(200) --PK(CONSTRAINT) NAME
DECLARE @IDX_NAME VARCHAR(200) --INDEX(CONSTRAINT) NAME
DECLARE @GROUPNAME VARCHAR(30) --FILE GROUP NAME
   DECLARE @INS_SQL NVARCHAR(MAX)
   DECLARE @DBNAME CHAR(40)
  SET @DBNAME = 'ODSDB'
   
   
        OPEN ParamList; 
        FETCH NEXT FROM ParamList 
             INTO @TABLENAME  
                                                                                                          
        WHILE @@FETCH_STATUS = 0   
     
          BEGIN 

------------------------------
-- STEP9:產生資料表格SCHEMA相關資訊
------------------------------
  
    IF EXISTS (SELECT * FROM TEMPDB.DBO.sysobjects WHERE Name ='##TBL_SCHEMA') DROP TABLE ##TBL_SCHEMA;    
    CREATE TABLE ##TBL_SCHEMA ( COLID INT,COL_NM CHAR(40),COL_INFO VARCHAR(1000),TBL_GROUPNAME SYSNAME)
    
DECLARE @CRT_TBLINFO_SQL  NVARCHAR(MAX)
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
       FROM '+RTRIM(@DBNAME)+'.sys.tables T
         INNER JOIN '+RTRIM(@DBNAME)+'.sys.indexes  I ON (T.object_id=I.object_id)
         INNER JOIN '+RTRIM(@DBNAME)+'.sys.data_spaces S ON (S.data_space_id = i.data_space_id)
         INNER JOIN '+RTRIM(@DBNAME)+'.sys.columns c  ON (c.object_id = t.object_id  )
         LEFT OUTER JOIN '+RTRIM(@DBNAME)+'.SYS.SYSCOMMENTS CM ON (CM.ID = c.default_OBJECT_ID)
         INNER JOIN '+RTRIM(@DBNAME)+'.INFORMATION_SCHEMA.COLUMNS ISC ON (ISC.COLUMN_NAME=C.NAME)
       WHERE T.NAME = '''+RTRIM(@TABLENAME)+'''
         AND ISC.TABLE_NAME = '''+RTRIM(@TABLENAME)+'''
         AND ISC.TABLE_SCHEMA = ''ODSDBA''
         AND I.INDEX_ID < 2 
       ORDER BY C.COLUMN_ID;' 
       
      --PRINT @CRT_TBLINFO_SQL 
      EXEC (@CRT_TBLINFO_SQL) 

------------------------------
-- STEP10:建立相對應之暫存表格,並產生INSERT SQL
------------------------------

 --產生欄位資訊SQL STATEMENT
 DECLARE @COL_NM CHAR(40)
 DECLARE @COL_INFO VARCHAR(1000)
 DECLARE @TBL_GROUPNAME SYSNAME
 DECLARE @SUB_SQL  VARCHAR(MAX)
 DECLARE @INS_LIST VARCHAR(MAX)
 DECLARE @TAR_LIST VARCHAR(MAX)

 
 SET @SUB_SQL = '';--初始值
 SET @INS_LIST = '';--初始值
 SET @TAR_LIST = '';--初始值

 
  DECLARE TableCol CURSOR LOCAL  FOR 
  
     SELECT  COL_NM,COL_INFO,TBL_GROUPNAME          
     FROM ##TBL_SCHEMA
     ORDER BY COLID;
  
  OPEN TableCol; 
  FETCH NEXT FROM TableCol 
       INTO @COL_NM,@COL_INFO,@TBL_GROUPNAME     
                                                                                                    
  WHILE @@FETCH_STATUS = 0   
  
    BEGIN 

        SET @SUB_SQL = @SUB_SQL + RTRIM(@COL_INFO)
        
        
            IF @TAR_LIST =''
             BEGIN
             	SET @TAR_LIST = RTRIM(@COL_NM)
             END ELSE BEGIN
             	SET @TAR_LIST = @TAR_LIST +','+RTRIM(@COL_NM)
             END
             
   
             IF @INS_LIST = '' 
               BEGIN
                 SET @INS_LIST = 'S1.'+RTRIM(@COL_NM)
               END ELSE BEGIN
                 SET @INS_LIST = @INS_LIST +',S1.'+RTRIM(@COL_NM)                      	
               END 
                              	
  
      FETCH NEXT FROM TableCol 
      INTO @COL_NM,@COL_INFO,@TBL_GROUPNAME  
        
    END          

  CLOSE TableCol;                                                                                                                     
 DEALLOCATE TableCol;   
 
 
 ------------------------------
-- STEP11:建立相對應之暫存表格
------------------------------

DECLARE @CRT_TBL_SQL NVARCHAR(MAX)
   SET @CRT_TBL_SQL 
       = 'CREATE TABLE '+RTRIM(@DBNAME)+'.ODSDBA.'+RTRIM(@TABLENAME)+' 
          ('+RTRIM(@SUB_SQL)+') ON ['+RTRIM(@TBL_GROUPNAME)+']
          GO'
   PRINT @CRT_TBL_SQL
  
 
------------------------------
-- STEP4:取得資料表格PK/INDEX之資訊
------------------------------ 
 --判斷是否存在##PK_TBL_INFO
   IF NOT EXISTS (SELECT * FROM TEMPDB.DBO.sysobjects WHERE Name ='##PK_TBL_INFO')
     BEGIN
     	 CREATE TABLE ##PK_TBL_INFO (DBNAME CHAR(20),INDID INT ,KEYNO INT,TABLE_NAME sysname,COL_NAME sysname,PK_NAME sysname NULL,GROUPNAME sysname,COL_TYPE CHAR(3) )
     END
   
DECLARE  @CHK_IND_SQL NVARCHAR(MAX)

 --判斷是否存在該表格之相關資訊
   IF NOT EXISTS (SELECT * FROM ##PK_TBL_INFO WHERE DBNAME =@DBNAME AND TABLE_NAME = @TABLENAME)
     BEGIN
       SET @CHK_IND_SQL
         ='INSERT INTO  ##PK_TBL_INFO (DBNAME,INDID,KEYNO,TABLE_NAME,COL_NAME,PK_NAME,GROUPNAME,COL_TYPE)
           SELECT '''+RTRIM(@DBNAME)+''',IC.INDEX_ID,IC.KEY_ORDINAL,T.[NAME],C.[NAME],I.NAME,S.NAME,CASE WHEN k.unique_index_id=ic.index_id THEN ''PK'' ELSE ''IDX'' END
           FROM  '+RTRIM(@DBNAME)+'.SYS.TABLES T
            INNER JOIN '+RTRIM(@DBNAME)+'.sys.index_columns as ic ON (ic.object_id = t.object_id)
            INNER JOIN '+RTRIM(@DBNAME)+'.sys.indexes AS I ON (i.object_id = ic.object_id AND i.index_id = ic.index_id )            
            INNER JOIN '+RTRIM(@DBNAME)+'.sys.data_spaces S ON (S.data_space_id = i.data_space_id)
            INNER JOIN '+RTRIM(@DBNAME)+'.sys.columns c on (c.object_id = t.object_id and c.column_id = ic.column_id )
            LEFT OUTER JOIN '+RTRIM(@DBNAME)+'.sys.key_constraints K ON (t.object_id = k.parent_object_id) 
          WHERE T.NAME='''+RTRIM(@TABLENAME)+'''
            AND I.NAME IS NOT NULL
          ORDER BY  ic.index_id,ic.key_ordinal'
          
          EXEC (@CHK_IND_SQL)
           -- PRINT @CHK_IND_SQL   

     END     
 
   
------------------------------
-- STEP11:建立相對應暫存表格之PK
------------------------------
                   
 --若資料表格存在PK則建立PK欄位
 IF EXISTS (SELECT * FROM ##PK_TBL_INFO WHERE DBNAME = @DBNAME AND TABLE_NAME = @TABLENAME AND COL_TYPE = 'PK')
   BEGIN
 
      DECLARE @PK_LIST VARCHAR(200)
      DECLARE @pk_col CHAR(30) 
      DECLARE @PK_KEYNO INT
      
      --PKCbn name
      DECLARE PKCbn CURSOR LOCAL FOR 
        SELECT KEYNO,COL_NAME
        FROM ##PK_TBL_INFO
        WHERE DBNAME = @DBNAME
          AND TABLE_NAME = @TABLENAME
          AND COL_TYPE = 'PK'
        ORDER BY KEYNO; 
        
          OPEN PKCbn; 
          FETCH NEXT FROM PKCbn 
               INTO @PK_KEYNO,@pk_col
                                                                                                            
          WHILE @@FETCH_STATUS = 0  
           
      BEGIN 
                       
         IF @PK_KEYNO = 1
         BEGIN 
            SET @PK_LIST = RTRIM(@PK_COL)
         END ELSE BEGIN
            SET @PK_LIST = RTRIM(@PK_LIST)+','+RTRIM(@PK_COL)
         END
      
             
         FETCH NEXT FROM PKCbn 
         INTO @PK_KEYNO,@pk_col
      END   
      
      CLOSE PKCbn;                                                                                                                   
     DEALLOCATE PKCbn;
     
      --取得 CONSTRAINT NAME
       SET @PK_NAME = (SELECT TOP 1 PK_NAME FROM ##PK_TBL_INFO WHERE DBNAME = @DBNAME AND TABLE_NAME = @TABLENAME AND COL_TYPE = 'PK')  
       SET @GROUPNAME = (SELECT TOP 1 GROUPNAME FROM ##PK_TBL_INFO WHERE DBNAME = @DBNAME AND TABLE_NAME = @TABLENAME AND COL_TYPE = 'PK')      
 
DECLARE @CRT_PK_SQL NVARCHAR(MAX)
     --建立暫存表格之PK
       SET @CRT_PK_SQL ='ALTER TABLE '+RTRIM(@DBNAME)+'.ODSDBA.'+RTRIM(@TABLENAME)+' ADD CONSTRAINT '+RTRIM(@PK_NAME)+' PRIMARY KEY CLUSTERED ('+RTRIM(@PK_LIST)+') ON ['+RTRIM(@GROUPNAME)+'];
                        GO'
       PRINT @CRT_PK_SQL
  
     
 END 



------------------------------
-- STEP12:建立相對應暫存表格之INDEX
------------------------------  
  
 --若資料表格存在IDX則建立IDX欄位
 IF EXISTS (SELECT * FROM ##PK_TBL_INFO WHERE DBNAME = @DBNAME AND TABLE_NAME = @TABLENAME AND COL_TYPE = 'IDX')
  BEGIN
  	
   DECLARE @INDID INT
   	
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
       
          --取得 CONSTRAINT NAME
           SET @IDX_NAME  = (SELECT TOP 1 PK_NAME FROM ##PK_TBL_INFO WHERE DBNAME = @DBNAME AND TABLE_NAME = @TABLENAME AND INDID = @INDID AND COL_TYPE = 'IDX')  
           SET @GROUPNAME = (SELECT TOP 1 GROUPNAME FROM ##PK_TBL_INFO WHERE DBNAME = @DBNAME AND  TABLE_NAME = @TABLENAME AND INDID = @INDID AND COL_TYPE = 'IDX')      
         DECLARE @CRT_IDX_SQL NVARCHAR(MAX)
         --建立暫存表格之index
           SET @CRT_IDX_SQL = 'CREATE NONCLUSTERED INDEX ['+RTRIM(@IDX_NAME)+'] ON '+RTRIM(@DBNAME)+'.ODSDBA.'+RTRIM(@TABLENAME)+' ('+RTRIM(@IDX_LIST)+') ON ['+RTRIM(@GROUPNAME)+'];
                              GO'
           PRINT @CRT_IDX_SQL

        FETCH NEXT FROM IDXCnt 
          INTO @INDID      	
        END 
        
      CLOSE IDXCnt;                                                                                                                   
   DEALLOCATE IDXCnt;  
 
 END 

  
              
            FETCH NEXT FROM ParamList 
            INTO @TABLENAME
              
          END   

         CLOSE ParamList;                                                                                                                     
         DEALLOCATE ParamList;
