   DECLARE @DBNAME CHAR(20)
   DECLARE @TABLENAME  CHAR(30)
   DECLARE @INS_USAGE_SQL NVARCHAR(MAX)
   SET @DBNAME = 'ODSDB'


IF EXISTS (SELECT * FROM TEMPDB.DBO.sysobjects WHERE Name ='##MD_TABLEUsage') DROP TABLE ##MD_TABLEUsage;    
CREATE TABLE ##MD_TABLEUsage (name  NVARCHAR(128),ROWS CHAR(11),reserved VARCHAR(18),data VARCHAR(18),index_size VARCHAR(18),UNUSED VARCHAR(18)) 

   
   DECLARE TABLEList CURSOR LOCAL FOR   
 
    --依序處理XSURDETAIL之所有資料             
     SELECT @DBNAME,t.name AS TABLENAME 
     FROM  sys.tables t
          ,sys.schemas s 
     WHERE s.schema_id = t.schema_id 
        and s.name = 'odsdba'
     ORDER BY t.name; 
         
  
   OPEN TABLEList; 
   FETCH NEXT FROM TABLEList 
        INTO @DBNAME,@TABLENAME
                                                                                                     
   WHILE @@FETCH_STATUS = 0   
      
 BEGIN 
 	
 
      	SET @INS_USAGE_SQL ='INSERT INTO ##MD_TABLEUsage EXEC '+RTRIM(@DBNAME)+'.DBO.sp_spaceused N''odsdba.'+RTRIM(@TableName)+''';' 
      	EXEC (@INS_USAGE_SQL) 
   
           FETCH NEXT FROM TABLEList
     INTO @DBNAME,@TABLENAME
 END    
 
 CLOSE TABLEList;                                                                                                             
 DEALLOCATE TABLEList;