DECLARE @non_exists INT
DECLARE @date_exists INT
SET @non_exists = 0
SET @date_exists = 0

WHILE @non_exists <> 1 OR @date_exists <> 1
BEGIN
  EXEC  master..xp_fileexist 'D:\DWBasisDB\EndFlag\End_ODS_NonWork.end',@non_exists output
  EXEC  master..xp_fileexist 'D:\DWBasisDB\EndFlag\End_CHECKDATE_ODS.end',@date_exists output
    IF @non_exists = 1 OR @date_exists = 1
    BEGIN
    	GOTO EXITLOOP
    END ELSE BEGIN
        WAITFOR DELAY '000:03:00'
    END
END

------------------------------
   EXITLOOP:
------------------------------
IF @non_exists = 1 GOTO  MAIN_EXIT --獶ら,瞒秨祘Α

IF @date_exists = 1
BEGIN
   DECLARE @CYCLEDATE CHAR(8)
   SET @CYCLEDATE = (SELECT CONVERT(CHAR(8),DATADT,112) FROM ODSDB.ODSDBA.CB_BHDATE WHERE DATACAT = 'ODUND')
   DECLARE @RAR_exists INT
   DECLARE @FLAG_EXISTS INT
   SET @RAR_exists = 0
   SET @FLAG_exists = 1
   
   WHILE @RAR_exists <> 1
     BEGIN
     	DECLARE @RAR_PATH CHAR(100)	
     	DECLARE @RAR_FILE CHAR(100)
     	DECLARE @RAR_FULL_NAME CHAR(100)
     	SET @RAR_PATH =  'F:\CRM_SOURCE\BACKUP\FTPData\CC'  --蠢传把计  
     	SET @RAR_FILE = 'CC_'+@CYCLEDATE+'.rar'	--蠢传把计
     	SET @RAR_FULL_NAME = RTRIM(@RAR_PATH)+'\'+RTRIM(@RAR_FILE)
        EXEC  master..xp_fileexist @RAR_FULL_NAME,@RAR_exists output                  	
          IF @RAR_exists = 1 
          BEGIN      	
              WHILE  @FLAG_EXISTS <> 0
                BEGIN               	
          	  DECLARE @FLAG_PATH CHAR(100)
          	  DECLARE @FLAG_FILE CHAR(100)
          	  DECLARE @FLAG_FULL_NAME CHAR(100)
          	  SET @FLAG_PATH = 'I:\FTP_Root\LocalUser\CRMFTPCC' --蠢传把计 
          	  SET @FLAG_FILE = 'EFTP_CC01'  --蠢传把计
          	  SET @FLAG_FULL_NAME = RTRIM(@FLAG_PATH)+'\'+RTRIM(@FLAG_FILE)          	  
          	  EXEC  master..xp_fileexist @FLAG_FULL_NAME,@FLAG_exists output          	  
          	       IF @FLAG_exists = 0
          	       BEGIN
          	       	 --STEP1:CREATE WORKING DIRECTORY
          	       	 DECLARE @MKDIR_CMD VARCHAR(8000)
          	       	 SET @MKDIR_CMD = 'IF NOT EXIST '+RTRIM(@RAR_PATH)+'\WORK mkdir '+RTRIM(@RAR_PATH)+'\WORK'
          	         exec master..xp_cmdshell @MKDIR_CMD
          	         --STE2:UNZIP FILE
          	         DECLARE @UNZIP_CMD VARCHAR(8000)
          	         SET @UNZIP_CMD = 'D:\CRM\Data\Convert\winrar E -o+ '+RTRIM(@RAR_FULL_NAME)+' '+RTRIM(@RAR_PATH)+'\WORK'
          	         EXEC master..xp_cmdshell @UNZIP_CMD 
          	         --STEP3:DELETE END FLAG FILE
          	         DECLARE @DELFG_CMD VARCHAR(8000)
          	         SET @DELFG_CMD = 'DEL /Q '+RTRIM(@RAR_PATH)+'\WORK\'+RTRIM(@FLAG_FILE)
          	         EXEC master..xp_cmdshell @DELFG_CMD 
          	         --STEP4:CREATE FTP LIST
          	         DECLARE @Create_FTP_List VARCHAR(8000)
          	         SET @Create_FTP_List = 'D:\DWBasisDB\SysControl\FTP_DW.bat 10.153.103.21 CRMFTPCC scmscustp \CRMFTPCC '+ RTRIM(@RAR_PATH)+'\WORK '+ RTRIM(@FLAG_FILE)+' '+RTRIM(@CYCLEDATE) --蠢传把计(ftp)
                         exec master..xp_cmdshell @Create_FTP_List
                         --STEP5:EXECUTE FTP LIST
                         DECLARE @EXEC_FTP VARCHAR(8000)
                         SET @EXEC_FTP ='FTP -s:D:\DWBasisDB\SysControl\ftplist.txt > D:\DWBasisDB\FTP\CC_'+@CYCLEDATE+'_FTPLOG.txt' --蠢传把计
                         exec master..xp_cmdshell @EXEC_FTP                           
                         --STEP6:DELETE WORKING DIRECTORY
                         DECLARE @RMDIR_CMD VARCHAR(8000)
                         SET @RMDIR_CMD  = 'rm -rf '+RTRIM(@RAR_PATH)+'\WORK'
                         exec master..xp_cmdshell @RMDIR_CMD 
          	       END ELSE BEGIN
          	         WAITFOR DELAY '000:03:00'	
          	       END  	  
          	END         		
          END ELSE BEGIN  
            WAITFOR DELAY '000:03:00'	       	 
          END
     END   
END




------------------------------
-- 祘Α挡 ODSDBA.SP_INS_XStatus
   MAIN_EXIT:
------------------------------