USE [DWMD]
GO
/****** Object:  StoredProcedure [odsdba].[SP_MergePartition]    Script Date: 12/29/2008 11:13:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [odsdba].[SP_MergePartition]
    @CYCLE_START DATETIME, 
    @CYCLE_END DATETIME    
AS
------------------------------
-- 程式說明
------------------------------
-- 1.Merge指定區間之Partition,並將其DATA FILE刪除


------------------------------
-- STEP1:依DB進行Merge Partition
------------------------------
  DECLARE @DBNAME CHAR(20)
  DECLARE @ERROR_MESSAGE  NVARCHAR(4000) --錯誤訊息
 
  DECLARE DBList CURSOR LOCAL  FOR 
  
     SELECT 'ODSDB' AS DBNAME
     UNION ALL        
     SELECT 'DWBasisDB' AS DBNAME;
  
  OPEN DBList; 
  FETCH NEXT FROM DBList 
       INTO @DBNAME   
                                                                                                    
  WHILE @@FETCH_STATUS = 0   
  
    BEGIN 
 
      ------------------------------
      -- STEP1.1:依Partition Function & Range Date
      ------------------------------      
      DECLARE @DROP_FILE_SQL NVARCHAR(MAX)   
      SET @DROP_FILE_SQL = '
             DECLARE @FILE_NAME AS CHAR(50)
             DECLARE @PF_NAME AS CHAR(30)
             DECLARE @RANGE_DATE AS CHAR(8)
             DECLARE @ERROR_MESSAGE  NVARCHAR(4000)
                       
             DECLARE MergeList CURSOR LOCAL  FOR 
               
             SELECT S5.NAME AS FILE_NAME,S2.NAME AS PF_NAME,CONVERT(CHAR(8),S3.VALUE,112) AS RANGE_DATE
             FROM '+RTRIM(@DBNAME)+'.SYS.PARTITION_SCHEMES AS S1
             JOIN '+RTRIM(@DBNAME)+'.SYS.PARTITION_FUNCTIONS AS S2 ON S1.FUNCTION_ID=S2.FUNCTION_ID
             JOIN '+RTRIM(@DBNAME)+'.SYS.PARTITION_RANGE_VALUES AS S3 ON S1.FUNCTION_ID=S3.FUNCTION_ID
             JOIN '+RTRIM(@DBNAME)+'.SYS.DESTINATION_DATA_SPACES AS S4 ON S1.DATA_SPACE_ID=S4.PARTITION_SCHEME_ID AND S3.BOUNDARY_ID+S2.boundary_value_on_right=S4.DESTINATION_ID
             JOIN '+RTRIM(@DBNAME)+'.SYS.DATA_SPACES AS S5 ON S4.DATA_SPACE_ID=S5.DATA_SPACE_ID
             WHERE S3.VALUE BETWEEN CONVERT(DATETIME,'''+CONVERT(CHAR(8),@CYCLE_START,112)+''') AND CONVERT(DATETIME,'''+CONVERT(CHAR(8),@CYCLE_END,112)+''')
             
             OPEN MergeList; 
             FETCH NEXT FROM MergeList 
                  INTO @FILE_NAME,@PF_NAME,@RANGE_DATE   
                                                                                                               
             WHILE @@FETCH_STATUS = 0   
             
               BEGIN 
               	
                 ------------------------------
                 -- STEP1.1.1:移除界限值
                 ------------------------------ 
                  DECLARE @MER_PAR_SQL NVARCHAR(MAX)              	
                  SET @MER_PAR_SQL =''               	
                  USE '+RTRIM(@DBNAME)+'
                  ALTER PARTITION FUNCTION ''+RTRIM(@PF_NAME)+''()
                  MERGE RANGE(CONVERT(DATETIME,''''''+@RANGE_DATE+''''''))''
                  
                  --PRINT @MER_PAR_SQL    
                  BEGIN TRY
                    EXEC SP_EXECUTESQL @MER_PAR_SQL;
                  END TRY
                  BEGIN CATCH
                      SET @ERROR_MESSAGE=ERROR_MESSAGE()
                      RAISERROR(@ERROR_MESSAGE,16,1);
                  END CATCH  
                  
                 ------------------------------
                 -- STEP1.1.2:DELETE LOGIAL FILE
                 ------------------------------ 

                  DECLARE @REMOVE_FILE_SQL NVARCHAR(MAX)              	
                  SET @REMOVE_FILE_SQL =''
                  ALTER DATABASE ['+RTRIM(@DBNAME)+'] REMOVE FILE [''+RTRIM(@FILE_NAME)+'']'' 
 
                     --PRINT @REMOVE_FILE_SQL;     
                     BEGIN TRY
                       EXEC SP_EXECUTESQL @REMOVE_FILE_SQL;
                     END TRY
                     BEGIN CATCH
                         IF (ERROR_NUMBER() <> 5042) /*cannot be removed because it is not empty*/
                          BEGIN 
                            SET @ERROR_MESSAGE=ERROR_MESSAGE()
                            RAISERROR(@ERROR_MESSAGE,16,1);
                          END 
                     END CATCH     
     	
               
               FETCH NEXT FROM MergeList 
                 INTO @FILE_NAME,@PF_NAME,@RANGE_DATE        
               
               END   
                  
             CLOSE MergeList;                                                                                                                     
            DEALLOCATE MergeList;' 
            
         --PRINT @DROP_FILE_SQL; 
         BEGIN TRY
           EXEC SP_EXECUTESQL @DROP_FILE_SQL;
         END TRY
         BEGIN CATCH
             SET @ERROR_MESSAGE=ERROR_MESSAGE()
             RAISERROR(@ERROR_MESSAGE,16,1);
         END CATCH               
                    
                     	    
     FETCH NEXT FROM DBList 
     INTO @DBNAME   
        
    END   
       
  CLOSE DBList;                                                                                                                     
 DEALLOCATE DBList;
    