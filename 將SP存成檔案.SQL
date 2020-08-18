
 DECLARE @SP_NAME VARCHAR(4000)


           DECLARE ParamList CURSOR LOCAL  FOR 
         SELECT RTRIM(NAME)
         FROM SYS.OBJECTS
           WHERE TYPE = 'P'
         AND  NAME IN
         (
'FINJOB'
,'INTJOB'
,'INTJOB2'
,'INTSJOB'
,'SP_FB_PCuCamppf_MS'
,'SP_INS_CBBhdate_CRMDBCBBhdate'
,'SP_INS_CBBhdate_CRMDBCBBhdate1'
,'SP_INS_CbRCu2AO_CRMBasisCbRCu2AO'
,'SP_INS_CSPcustGantDtl_CRMBasisCSPcustGantDtl'
,'SP_INS_CsPcustLoyalty_CRMBasisCbRCu2AO'
,'SP_INS_DWXbatchflow'
,'SP_INS_FbAcctBrPd_FbAcct1PfMh'
,'SP_INS_FbCuBrPd_FbAcctBrPd'
,'SP_INS_FBCuIBCall_CRMBasisFBCuIBCall'
,'sp_INSBHDATE'
,'sp_log'
,'SP_MergeList'
,'sp_RunFlag'
,'SP_UPS_CBOrg_CBOrg'
,'SP_UPS_CBPCust_CSPcustAssetRank'
,'SP_UPS_CBPCust_CSPCustBDBLRPRS'
,'SP_UPS_CBPCust_CSPCustContribute'
,'SP_UPS_CBPCust_CSPCustCustMainOrg'
,'SP_UPS_CBPCust_CSPCustLiabilityRank'
,'SP_UPS_CBPCust_CSPCustSalary'
,'sp_XBHDATE1_CBBHDATE'
,'XWStatus'
,'SP_INS_MDPermissionModel_TMPMDPermissionModel'
,'SP_INS_MDPermissionModelDtl_TMPMDPermissionModelDtl'




         )


   DECLARE @OUT_FILE VARCHAR(1000)
   DECLARE @BCP_CMD VARCHAR(4000)
   DECLARE @INS_SQL NVARCHAR(MAX)
   DECLARE @DBNAME CHAR(40)
  SET @DBNAME = 'PCUINFODB'
   
   
        OPEN ParamList; 
        FETCH NEXT FROM ParamList 
             INTO @SP_NAME  
                                                                                                          
        WHILE @@FETCH_STATUS = 0   
     
          BEGIN 

           IF NOT EXISTS (SELECT * FROM TEMPDB.DBO.sysobjects WHERE Name ='##SP_TEXT')
             BEGIN
             	CREATE TABLE ##SP_TEXT( SP_CONTEXT TEXT) 
             END ELSE BEGIN
             	TRUNCATE TABLE ##SP_TEXT
             END
             
             SET @INS_SQL ='insert into ##SP_TEXT exec '+RTRIM(@DBNAME)+'.DBO.sp_helptext ''ODSDBA.'+RTRIM(@SP_NAME) +''''
              PRINT @INS_SQL
               EXEC (@INS_SQL)
             SET @OUT_FILE = 'D:\SQL_BK\'+RTRIM(@DBNAME)+'\'+RTRIM(@SP_NAME)+'.SQL'
             SET @BCP_CMD = 'BCP ##SP_TEXT OUT "'+RTRIM(@OUT_FILE)+'" -T -c'
             PRINT @BCP_CMD


              exec xp_cmdshell @BCP_CMD

            FETCH NEXT FROM ParamList 
            INTO @SP_NAME
              
          END   

         CLOSE ParamList;                                                                                                                     
         DEALLOCATE ParamList;


DROP TABLE ##SP_TEXT;