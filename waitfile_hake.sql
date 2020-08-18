DECLARE @CC_END_STATUS  CHAR(4)
DECLARE @MF_END_STATUS  CHAR(4)
DECLARE @CIF_END_STATUS  CHAR(4)
DECLARE @DDB_END_STATUS  CHAR(4)
DECLARE @LDB_END_STATUS  CHAR(4)
DECLARE @MGT_END_STATUS  CHAR(4)
DECLARE @RDB_END_STATUS  CHAR(4)
DECLARE @RTB_END_STATUS  CHAR(4)
DECLARE @CHECKDATE_END_STATUS  CHAR(4)
DECLARE @exists                   INT
DECLARE @FILE_NAME  VARCHAR(200)

SET @CC_END_STATUS ='RUN'
SET @MF_END_STATUS ='RUN'
SET @CIF_END_STATUS='RUN'
SET @DDB_END_STATUS='RUN'
SET @LDB_END_STATUS='RUN'
SET @MGT_END_STATUS='RUN'
SET @RDB_END_STATUS='RUN'
SET @RTB_END_STATUS='RUN'
SET @CHECKDATE_END_STATUS='RUN'



--月底才有LDB
IF (SELECT BEOM_FG FROM [ODSDB].odsdba.CB_BHDATE WHERE DATACAT='ODUND')='N' 
    SET @LDB_END_STATUS='OK'

WHILE(@CC_END_STATUS='RUN' OR 
          @MF_END_STATUS='RUN' OR 
          @CIF_END_STATUS='RUN' OR
          @DDB_END_STATUS='RUN' OR 
          @LDB_END_STATUS='RUN' OR 
          @MGT_END_STATUS='RUN' OR
          @RDB_END_STATUS='RUN' OR
          @RTB_END_STATUS='RUN' OR
          @CHECKDATE_END_STATUS='RUN')
BEGIN
   /* 等待一分鐘*/
   WAITFOR DELAY '000:01:00'    
  
   /* 判斷CC FLOW 是否結束*/
   IF(@CC_END_STATUS='RUN')
   BEGIN   
      SET @FILE_NAME='D:\CRM\Data\End_ODS\End_CC_ODS.end'
      EXEC  master..xp_fileexist @FILE_NAME,@exists output
      IF @exists = 1  
        SET  @CC_END_STATUS='OK'
   END   
   /* 判斷MF FLOW 是否結束*/
   IF(@MF_END_STATUS='RUN')
   BEGIN   
      SET @FILE_NAME='D:\CRM\Data\End_ODS\End_MF_ODS.end'
      EXEC  master..xp_fileexist @FILE_NAME,@exists output
      IF @exists = 1 
      SET  @MF_END_STATUS='OK'
   END 
    /* 判斷CIF FLOW 是否結束*/
   IF(@CIF_END_STATUS='RUN')
   BEGIN   
      SET @FILE_NAME='D:\CRM\Data\End_ODS\End_CIF_ODS.end'
      EXEC  master..xp_fileexist @FILE_NAME,@exists output
      IF @exists = 1 
      SET  @CIF_END_STATUS='OK'
   END
   /* 判斷DDB FLOW 是否結束*/
   IF(@DDB_END_STATUS='RUN')
   BEGIN   
      SET @FILE_NAME='D:\CRM\Data\End_ODS\End_DDB_ODS.end'
      EXEC  master..xp_fileexist @FILE_NAME,@exists output
      IF @exists = 1 
      SET  @DDB_END_STATUS='OK'
   END 
   /* 判斷LDB FLOW 是否結束*/   
   IF(@LDB_END_STATUS='RUN')
   BEGIN   
      SET @FILE_NAME='D:\CRM\Data\End_ODS\End_LDB_ODS.end'
      EXEC  master..xp_fileexist @FILE_NAME,@exists output
      IF @exists = 1 
      SET  @LDB_END_STATUS='OK'
   END 
   /* 判斷MGT FLOW 是否結束*/
   IF(@MGT_END_STATUS='RUN')
   BEGIN   
      SET @FILE_NAME='D:\CRM\Data\End_ODS\End_MGT_ODS.end'
      EXEC  master..xp_fileexist @FILE_NAME,@exists output
      IF @exists = 1 
      SET  @MGT_END_STATUS='OK'
   END 
   /* 判斷RDB FLOW 是否結束*/
   IF(@RDB_END_STATUS='RUN')
   BEGIN   
      SET @FILE_NAME='D:\CRM\Data\End_ODS\End_RDB_ODS.end'
      EXEC  master..xp_fileexist @FILE_NAME,@exists output
      IF @exists = 1 
      SET  @RDB_END_STATUS='OK'
   END    
   /* 判斷RTB FLOW 是否結束*/
   IF(@RTB_END_STATUS='RUN')
   BEGIN   
      SET @FILE_NAME='D:\CRM\Data\End_ODS\End_RTB_ODS.end'
      EXEC  master..xp_fileexist @FILE_NAME,@exists output
      IF @exists = 1 
      SET  @RTB_END_STATUS='OK'
   END
    /* 判斷CHECKDATE FLOW 是否結束*/
   IF(@CHECKDATE_END_STATUS='RUN')
   BEGIN   
      SET @FILE_NAME='D:\CRM\Data\End_ODS\End_CHECKDATE_ODS.end'
      EXEC  master..xp_fileexist @FILE_NAME,@exists output
      IF @exists = 1 
      SET  @CHECKDATE_END_STATUS='OK'
   END
    
END	