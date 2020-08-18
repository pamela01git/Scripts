USE [DWMD]
GO
/****** Object:  StoredProcedure [odsdba].[SP_DelData]    Script Date: 12/29/2008 11:14:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [odsdba].[SP_DelData]
    @DBNAME     CHAR(20),
    @TABLENAME  CHAR(30),
    @CYCLE_START DATETIME,
    @CYCLE_END DATETIME,
    @DEL_CNT INT = 0 OUTPUT --DELETE COUNT
AS
------------------------------
-- 程式說明
------------------------------
-- 1.刪除指定區間之資料,若遇Daily Job則指定每日區間分多次刪除

 
------------------------------
-- STEP1:以TABLE NAME找出TALBE SCHEMA
------------------------------      	
DECLARE @FIND_SCHEMA_SQL NVARCHAR(4000)
DECLARE @SCHEMA CHAR(20) --TABLE SCHEMA
DECLARE @ERROR_MESSAGE  NVARCHAR(4000) --錯誤訊息

SET @FIND_SCHEMA_SQL
   ='SELECT  @SCHEMA = S.NAME 
     FROM  '+RTRIM(@DBNAME)+'.SYS.TABLES T
      JOIN '+RTRIM(@DBNAME)+'.SYS.SCHEMAS S ON S.SCHEMA_ID=T.SCHEMA_ID
    WHERE T.name = '''+RTRIM(@TABLENAME)+''''

BEGIN TRY
  EXECUTE sp_executesql @FIND_SCHEMA_SQL,N'@SCHEMA CHAR(20) OUT',@SCHEMA OUT;
END TRY
BEGIN CATCH      
  SET @ERROR_MESSAGE=ERROR_MESSAGE() 
  RAISERROR(@ERROR_MESSAGE,16,1);
END CATCH   

IF @SCHEMA IS NULL GOTO Main_Exit -- 找不到SCHEMA代表該物件不存在

------------------------------
-- STEP2:依TABLE的型態進行DELETE
------------------------------

  ------------------------------
  -- STEP3.1:CURSOR變數
  ------------------------------  
  DECLARE @CYC_BEG DATETIME
  DECLARE @CYC_END DATETIME
  DECLARE @TMP_DEL_CNT INT   
  SET @DEL_CNT = 0
  
  ------------------------------
  -- STEP3.2:產生DELETE CURSOR
  ------------------------------   

  DECLARE CycleList CURSOR LOCAL  FOR 
  
     SELECT TMNBDT AS CYC_BEG,TMNEDT AS CYC_END
     FROM DWBasisDB.ODSDBA.CB_DT
     WHERE DATADT BETWEEN @CYCLE_START AND @CYCLE_END
       AND BBOM_FG ='Y'
       AND (   @TABLENAME LIKE '%[_]MH' OR @TABLENAME LIKE '%[_]MS' OR @TABLENAME LIKE '%[_]MA' OR @TABLENAME LIKE 'ODSMS[_]%'
            OR @TABLENAME IN ('CS_Pcust_CCardRFM','CS_Pcust_FaciAggt','CS_Pcust_MgtInfoRFM','CS_Pcust_SecuAggt')) 
      UNION ALL      
     SELECT TBSDT AS CYC_BEG,TBSDT AS CYC_END
     FROM DWBasisDB.ODSDBA.CB_DT
     WHERE DATADT BETWEEN @CYCLE_START AND @CYCLE_END
       AND ( @TABLENAME LIKE '%[_]DH' OR @TABLENAME LIKE 'TX[_]%' OR @TABLENAME IN ('CS_PAcct1DW_LN','CS_PBrPd_LN'))
              
  OPEN CycleList; 
  FETCH NEXT FROM CycleList 
       INTO @CYC_BEG,@CYC_END   
                                                                                                    
  WHILE @@FETCH_STATUS = 0   
  
    BEGIN   	
       ------------------------------
       -- STEP3.2.1:DELETE DATADT
       ------------------------------  
       
        DECLARE @DEL_DATA_SQL NVARCHAR(MAX)
        SET @DEL_DATA_SQL = 'DELETE FROM ['+RTRIM(@DBNAME)+'].['+RTRIM(@SCHEMA)+'].['+RTRIM(@TABLENAME)+'] WHERE DATADT BETWEEN '''+CONVERT(CHAR(8),@CYCLE_START,112)+''' AND '''+CONVERT(CHAR(8),@CYCLE_END,112)+''';SELECT @TMP_DEL_CNT = @@ROWCOUNT;'
        
        --PRINT @DEL_DATA_SQL
          
           BEGIN TRY
             EXEC SP_EXECUTESQL @DEL_DATA_SQL,N'@TMP_DEL_CNT INT OUT',@TMP_DEL_CNT OUT
             SET @DEL_CNT = @DEL_CNT + @TMP_DEL_CNT
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
-- 結束程式
   Main_Exit:
------------------------------
