USE ODSDB
GO

DECLARE @DBNAME CHAR(50)
DECLARE @TABLENAME CHAR(100)
DECLARE @TMP_CNT INT
DECLARE @ACTION CHAR(6)
DECLARE @CRT_VIEW_SQL NVARCHAR(4000)
DECLARE @ERROR_MESSAGE  NVARCHAR(4000) --錯誤訊息

------------------------------
-- STEP1:找出所有歷史性資料表
------------------------------     
   DECLARE TABLEList CURSOR LOCAL FOR   
 
    --依序處理各歷史資料表
    SELECT t.NAME 
    FROM SYS.TABLES t 
    WHERE (t.NAME LIKE 'TX[_]%' OR t.NAME LIKE '%[_]DH' OR t.NAME LIKE '%[_]MH' OR t.NAME LIKE '%[_]MS' OR t.NAME LIKE '%[_]MA'
           OR t.NAME LIKE 'ODSMS[_]%'
           OR t.NAME IN ('CS_Pcust_CCardRFM','CS_Pcust_FaciAggt','CS_Pcust_MgtInfoRFM','CS_Pcust_SecuAggt'))
     ORDER BY NAME      
  
   OPEN TABLEList; 
   FETCH NEXT FROM TABLEList 
        INTO @TABLENAME
                                                                                                     
   WHILE @@FETCH_STATUS = 0   
      
 BEGIN  	
 	
        ------------------------------
        -- STEP2:以TABLE NAME找出TALBE SCHEMA
        ------------------------------      	
        DECLARE @FIND_SCHEMA_SQL NVARCHAR(4000)
        DECLARE @SCHEMA CHAR(20) --TABLE SCHEMA
        
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
 	
 	 SET @TMP_CNT = 0 --計數器初始化
 	 
 	------------------------------
        -- STEP3:找出所有的歷史性資料庫
        ----------------------------- 
        DECLARE DBList CURSOR LOCAL FOR   
      
         --依序處理各歷史資料庫
         SELECT NAME
         FROM SYS.DATABASES
         WHERE NAME LIKE 'ODSDB%'
         ORDER BY NAME 
         
        OPEN DBList; 
        FETCH NEXT FROM DBList 
             INTO @DBNAME
                                                                                                          
        WHILE @@FETCH_STATUS = 0   
           
          BEGIN  	          	
           ------------------------------
           -- STEP3.1:若歷史資料庫不存在該TABLE則自動建立
           ----------------------------- 
             BEGIN TRY
                DECLARE @NEW_DBNAME CHAR(20)
                DECLARE @YEAR CHAR(4)
                SET @NEW_DBNAME = DBO.INSTR(@DBNAME,'_',1)
                SET @YEAR = DBO.INSTR(@DBNAME,'_',2)
                EXEC [DWMD].[odsdba].[SP_CRT_TABLE] @NEW_DBNAME,@YEAR ,@TABLENAME
             END TRY
             BEGIN CATCH      
                SET @ERROR_MESSAGE=ERROR_MESSAGE() 
                RAISERROR(@ERROR_MESSAGE,16,1); 
             END CATCH 	                	
          
             ------------------------------
             -- STEP3.2:判斷該VIEW是否已存在
             ----------------------------- 	
            IF EXISTS (SELECT * FROM SYS.VIEWS V INNER JOIN SYS.SCHEMAS S ON (V.SCHEMA_ID=S.SCHEMA_ID) WHERE S.NAME= 'dbo' AND V.NAME = 'VW_'+RTRIM(@TABLENAME))
            BEGIN
             SET @ACTION = 'ALTER'   --存在則ALTER VIEW
            END ELSE BEGIN
             SET @ACTION = 'CREATE'  --不存在則CREATE VIEW  
            END          
  
             ------------------------------
             -- STEP3.3:產生VIEW的內容
             -----------------------------             
            IF @TMP_CNT = 0
             BEGIN
               SET  @CRT_VIEW_SQL = RTRIM(@ACTION)+' VIEW [dbo].[VW_'+RTRIM(@TABLENAME)+'] AS SELECT * FROM ['+RTRIM(@DBNAME)+'].['+RTRIM(@SCHEMA)+'].['+RTRIM(@TABLENAME)+']'
             END ELSE BEGIN
               SET  @CRT_VIEW_SQL = RTRIM(@CRT_VIEW_SQL)+' UNION ALL SELECT * FROM ['+RTRIM(@DBNAME)+'].['+RTRIM(@SCHEMA)+'].['+RTRIM(@TABLENAME)+']'
             END      	
                
          	 
            SET @TMP_CNT = @TMP_CNT + 1
          
            FETCH NEXT FROM DBList 
            INTO  @DBNAME
            
          END    
          
          CLOSE DBList;                                                                                                             
          DEALLOCATE DBList; 	    

------------------------------
-- STEP4:CREATE VIEW
------------------------------  
   PRINT @CRT_VIEW_SQL
        
   BEGIN TRY
     EXECUTE sp_executesql @CRT_VIEW_SQL;
   END TRY
   BEGIN CATCH      
     SET @ERROR_MESSAGE=ERROR_MESSAGE() 
     RAISERROR(@ERROR_MESSAGE,16,1);
   END CATCH      
   
   FETCH NEXT FROM TABLEList 
   INTO  @TABLENAME
   
 END    
 
 CLOSE TABLEList;                                                                                                             
 DEALLOCATE TABLEList;
    

