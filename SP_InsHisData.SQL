USE [DWMD]
GO
/****** Object:  StoredProcedure [odsdba].[SP_InsHisData]    Script Date: 12/29/2008 11:15:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [odsdba].[SP_InsHisData]
    @DBNAME     CHAR(20),
    @TABLENAME  CHAR(30),
    @CYCLE_START DATETIME,
    @CYCLE_END DATETIME,    
    @INS_CNT INT = 0 OUTPUT --INSRT COUNT
AS
------------------------------
-- �{������
------------------------------
-- 1.�N���w�϶������,���J���v��Ʈw,�îھ�@CYCLE_END�M�w���v��Ʈw����m,�Y�JDaily Job�h���w�C��϶����h�����J

 
------------------------------
-- STEP1:�HTABLE NAME��XTALBE SCHEMA
------------------------------      	
DECLARE @FIND_SCHEMA_SQL NVARCHAR(4000)
DECLARE @SCHEMA CHAR(20) --TABLE SCHEMA
DECLARE @ERROR_MESSAGE  NVARCHAR(4000) --���~�T��

SET @FIND_SCHEMA_SQL
   ='SELECT  @SCHEMA = S.NAME
     FROM  '+RTRIM(@DBNAME)+'.SYS.TABLES T
      JOIN '+RTRIM(@DBNAME)+'.SYS.SCHEMAS S ON S.SCHEMA_ID=T.SCHEMA_ID
    WHERE T.name = '''+RTRIM(@TABLENAME)+''''
    
BEGIN TRY
  EXECUTE sp_executesql @FIND_SCHEMA_SQL,N'@SCHEMA CHAR(20) OUT',@SCHEMA OUT;
  SET @SCHEMA = ISNULL(@SCHEMA,'')
END TRY
BEGIN CATCH      
  SET @ERROR_MESSAGE=ERROR_MESSAGE() 
  RAISERROR(@ERROR_MESSAGE,16,1);
END CATCH       

IF @SCHEMA = '' 
 BEGIN
    RAISERROR('Can not find this object!',16,1); 
    GOTO Main_Exit
 END
    
------------------------------
-- STEP2:��X�ت���Ʈw
------------------------------      	
DECLARE @TAR_DBNAME CHAR(25)
SET @TAR_DBNAME = RTRIM(@DBNAME)+'_'+CONVERT(CHAR(4),YEAR(@CYCLE_END))

------------------------------
-- STEP3:��TABLE�����A�i��INSERT
------------------------------

  ------------------------------
  -- STEP3.1:CURSOR�ܼ�
  ------------------------------  
  DECLARE @CYC_BEG DATETIME
  DECLARE @CYC_END DATETIME
  DECLARE @TMP_INS_CNT INT   
  SET @INS_CNT = 0
  
  ------------------------------
  -- STEP3.2:����INSERT CURSOR
  ------------------------------   

  DECLARE CycleList CURSOR LOCAL  FOR 
  
     SELECT TMNBDT AS CYC_BEG,TMNEDT AS CYC_END
     FROM ISMD.ODSDBA.CB_DT
     WHERE DATADT BETWEEN @CYCLE_START AND @CYCLE_END
       AND BBOM_FG ='Y'
       AND (   @TABLENAME LIKE '%[_]MH' OR @TABLENAME LIKE '%[_]MS' OR @TABLENAME LIKE '%[_]MA' OR @TABLENAME LIKE 'ODSMS[_]%'
            OR @TABLENAME IN ('CS_Pcust_CCardRFM','CS_Pcust_FaciAggt','CS_Pcust_MgtInfoRFM','CS_Pcust_SecuAggt')) 
      UNION ALL      
     SELECT TBSDT AS CYC_BEG,TBSDT AS CYC_END
     FROM ISMD.ODSDBA.CB_DT
     WHERE DATADT BETWEEN @CYCLE_START AND @CYCLE_END
       AND ( @TABLENAME LIKE '%[_]DH' OR @TABLENAME LIKE 'TX[_]%' OR @TABLENAME IN ('CS_PAcct1DW_LN','CS_PBrPd_LN')) 
              
  OPEN CycleList; 
  FETCH NEXT FROM CycleList 
       INTO @CYC_BEG,@CYC_END   
                                                                                                    
  WHILE @@FETCH_STATUS = 0   
  
    BEGIN   	
      ------------------------------
      -- STEP3.2.1:IF EXISTS DELETE DATADT
      ------------------------------  
      
       DECLARE @DEL_EXIST_SQL NVARCHAR(MAX)
       SET @DEL_EXIST_SQL = 'IF EXISTS (SELECT TOP 1 * FROM ['+RTRIM(@TAR_DBNAME)+'].['+RTRIM(@SCHEMA)+'].['+RTRIM(@TABLENAME)+'] WHERE DATADT BETWEEN '''+CONVERT(CHAR(8),@CYC_BEG,112)+''' AND '''+CONVERT(CHAR(8),@CYC_END,112)+''') EXEC [DWMD].[odsdba].[SP_DelData] '''+RTRIM(@TAR_DBNAME)+''','''+RTRIM(@TABLENAME)+''','''+RTRIM(@TAR_DBNAME)+''','''+CONVERT(CHAR(8),@CYC_BEG,112)+''' ,'''+CONVERT(CHAR(8),@CYC_END,112)+''';' 
       
       --PRINT @DEL_EXIST_SQL
      
          BEGIN TRY
            EXEC SP_EXECUTESQL @DEL_EXIST_SQL
          END TRY
          BEGIN CATCH
              SET @ERROR_MESSAGE=ERROR_MESSAGE()
              RAISERROR(@ERROR_MESSAGE,16,1);
          END CATCH        
         
      ------------------------------
      -- STEP3.2.2:INSERT DATADT
      ------------------------------  
      
       DECLARE @INS_DATA_SQL NVARCHAR(MAX)
       SET @INS_DATA_SQL = 'INSERT INTO ['+RTRIM(@TAR_DBNAME)+'].['+RTRIM(@SCHEMA)+'].['+RTRIM(@TABLENAME)+'] SELECT * FROM ['+RTRIM(@DBNAME)+'].['+RTRIM(@SCHEMA)+'].['+RTRIM(@TABLENAME)+'] WHERE DATADT BETWEEN '''+CONVERT(CHAR(8),@CYC_BEG,112)+''' AND '''+CONVERT(CHAR(8),@CYC_END,112)+''';SELECT @TMP_INS_CNT = @@ROWCOUNT;'
       
       --PRINT @INS_DATA_SQL
        
          BEGIN TRY
            EXEC SP_EXECUTESQL @INS_DATA_SQL,N'@TMP_INS_CNT INT OUT',@TMP_INS_CNT OUT
            SET @INS_CNT = @INS_CNT + @TMP_INS_CNT  
          END TRY
          BEGIN CATCH
              SET @ERROR_MESSAGE=ERROR_MESSAGE()
              RAISERROR(@ERROR_MESSAGE,16,1);
          END CATCH    
           	
    	
     FETCH NEXT FROM CycleList 
     INTO @CYC_BEG,@CYC_END   
        
    END   
       
  CLOSE CycleList;                                                                                                                     
 DEALLOCATE CycleList;    	

------------------------------
-- �����{��
   Main_Exit:
------------------------------


   