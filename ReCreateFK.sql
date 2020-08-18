USE [BMSDB]
GO
/****** Object:  StoredProcedure [dbo].[SP_Get_FKInfo]    Script Date: 2013/5/31 下午 03:04:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC [dbo].[SP_Get_FKInfo] 'BMSDB','DBO','BMS_RAT_TX_BATCH'

ALTER  PROCEDURE [dbo].[SP_Get_FKInfo]
    @DBNAME       CHAR(20),
    @SCHEMA       VARCHAR(30),
    @TABLENAME    VARCHAR(50)     
AS
---------------------------------------------------
-- STEP 0: Varialbe
---------------------------------------------------
    
DECLARE @ERROR_MESSAGE  NVARCHAR(MAX)
       ,@GET_FK_SQL  NVARCHAR(MAX) 
       ,@COLLATION VARCHAR(50)

SET @COLLATION = (SELECT CONVERT(VARCHAR(50),DATABASEPROPERTYEX(@DBNAME,'COLLATION')))      

------------------------------
-- STEP1:Table Schema
------------------------------  

SET @GET_FK_SQL
    =' USE tempdb
	 IF OBJECT_ID(''tempdb..##FK_TBL_INFO'') IS NOT NULL DROP TABLE  ##FK_TBL_INFO
	 USE '+RTRIM(@DBNAME)+'
      SELECT OBJECT_NAME(f.parent_object_id) AS TableName
            ,SCHEMA_NAME(f.SCHEMA_ID) AS SchemaName
            ,f.name AS ForeignKey
            ,COL_NAME(fc.parent_object_id,fc.parent_column_id) AS ColumnName
            ,OBJECT_NAME (f.referenced_object_id) AS ReferenceTableName
            ,(SELECT SCHEMA_NAME(SCHEMA_ID) FROM SYS.TABLES WHERE OBJECT_ID=f.referenced_object_id) as ReferenceSchema
            ,COL_NAME(fc.referenced_object_id,fc.referenced_column_id) AS ReferenceColumnName
            ,CASE WHEN DELETE_REFERENTIAL_ACTION=1 THEN ''ON DELETE ''+RTRIM(DELETE_REFERENTIAL_ACTION_DESC) ELSE '''' END AS DELETE_REFERENTIAL_ACTION
            ,CASE WHEN UPDATE_REFERENTIAL_ACTION=1 THEN ''ON UPDATE ''+RTRIM(UPDATE_REFERENTIAL_ACTION_DESC) ELSE '''' END AS UPDATE_REFERENTIAL_ACTION
		INTO ##FK_TBL_INFO
      FROM sys.foreign_keys AS f
        INNER JOIN sys.foreign_key_columns AS fc ON (f.OBJECT_ID = fc.constraint_object_id)
     WHERE f.parent_object_id=(OBJECT_ID('''+RTRIM(@SCHEMA)+'.'+RTRIM(@TABLENAME)+'''))
        or  f.referenced_object_id=(OBJECT_ID('''+RTRIM(@SCHEMA)+'.'+RTRIM(@TABLENAME)+'''))'
		          
BEGIN TRY
 --PRINT @GET_FK_SQL
  EXECUTE sp_executesql @GET_FK_SQL
END TRY
BEGIN CATCH      
   SET @ERROR_MESSAGE=ERROR_MESSAGE() 
   RAISERROR(@ERROR_MESSAGE,16,1); 
   GOTO Main_Exit;
END CATCH 


-----------------------------------------------
--Drop FK
-----------------------------------------------
       declare @outTABLENAME sysname
       ,@Schema_Name sysname
       ,@Foreign_Key SYSNAME
	   ,@DRP_FK_SQL NVARCHAR(2000)
---------------------------------------------------
-- STEP 1: Creating Foreign Key
---------------------------------------------------

DECLARE DRPFKInfo CURSOR LOCAL FOR
SELECT TableName,[SCHEMANAME] ,ForeignKey
FROM ##FK_TBL_INFO
		      
 OPEN DRPFKInfo;
   FETCH NEXT FROM DRPFKInfo 
     INTO @outTABLENAME,@Schema_Name,@Foreign_Key
	 WHILE @@FETCH_STATUS = 0 
	   BEGIN
		 		
         SET @DRP_FK_SQL = 'USE '+RTRIM(@DBNAME)+'
                            IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID=(OBJECT_ID('''+RTRIM(@Schema_Name)+'.'+RTRIM(@Foreign_Key)+''')))
                            ALTER TABLE '+RTRIM(@Schema_Name)+'.['+LTRIM(RTRIM(@outTABLENAME))+'] 
                             DROP CONSTRAINT ['+LTRIM(RTRIM(@Foreign_Key))+'];'
         BEGIN TRY
          PRINT @DRP_FK_SQL
          -- EXECUTE sp_executesql @DRP_FK_SQL
         END TRY
         BEGIN CATCH      
           SET @ERROR_MESSAGE=ERROR_MESSAGE() 
           RAISERROR(@ERROR_MESSAGE,16,1); 
           GOTO Main_Exit;
         END CATCH  
        
         FETCH NEXT FROM DRPFKInfo 
           INTO @outTABLENAME,@Schema_Name,@Foreign_Key
	   END 
  CLOSE DRPFKInfo;                                                                                                                     
 DEALLOCATE DRPFKInfo;
 
 -----------------------------------------------
--Create FK
-----------------------------------------------
---------------------------------------------------
-- STEP 0: Foreign Key Info
---------------------------------------------------

DECLARE
 --@ERROR_MESSAGE  NVARCHAR(4000)
 --      ,@outTABLENAME sysname  
 --      ,@Schema_Name sysname
 --      ,@Foreign_Key SYSNAME,
        @COL_Name SYSNAME
       ,@Reference_Table_Name SYSNAME
       ,@Reference_Schema SYSNAME
       ,@Reference_COL_Name SYSNAME
       ,@DELETE_REFERENTIAL_ACTION CHAR(30)
       ,@UPDATE_REFERENTIAL_ACTION CHAR(30)
       ,@CRT_FK_SQL NVARCHAR(2000)         
       
---------------------------------------------------
-- STEP 1: Creating Foreign Key
---------------------------------------------------

DECLARE FKInfo CURSOR LOCAL FOR
SELECT TABLENAME,[SCHEMANAME] ,ForeignKey,ColumnName,ReferenceTableName,ReferenceSchema,ReferenceColumnName,DELETE_REFERENTIAL_ACTION,UPDATE_REFERENTIAL_ACTION
FROM ##FK_TBL_INFO
		      
 OPEN FKInfo;
   FETCH NEXT FROM FKInfo 
     INTO @outTABLENAME,@Schema_Name,@Foreign_Key,@COL_Name,@Reference_Table_Name,@Reference_Schema,@Reference_COL_Name,@DELETE_REFERENTIAL_ACTION,@UPDATE_REFERENTIAL_ACTION
	 WHILE @@FETCH_STATUS = 0 
	   BEGIN
		 		
         SET @CRT_FK_SQL = 'USE '+RTRIM(@DBNAME)+'
                            IF NOT EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID=(OBJECT_ID('''+RTRIM(@Schema_Name)+'.'+RTRIM(@Foreign_Key)+''')))
                            ALTER TABLE '+RTRIM(@Schema_Name)+'.['+LTRIM(RTRIM(@outTABLENAME))+'] WITH CHECK
                             ADD CONSTRAINT ['+LTRIM(RTRIM(@Foreign_Key))+'] FOREIGN KEY ('+RTRIM(@Col_Name)+')
                               REFERENCES '+RTRIM(@Reference_Schema)+'.['+LTRIM(RTRIM(@Reference_Table_Name))+'] ('+RTRIM(@Reference_COL_Name)+')'+'
                               '+RTRIM(@DELETE_REFERENTIAL_ACTION)+'
                               '+RTRIM(@UPDATE_REFERENTIAL_ACTION)+';'
         BEGIN TRY
          PRINT @CRT_FK_SQL
          -- EXECUTE sp_executesql @CRT_FK_SQL
         END TRY
         BEGIN CATCH      
           SET @ERROR_MESSAGE=ERROR_MESSAGE() 
           RAISERROR(@ERROR_MESSAGE,16,1); 
           GOTO Main_Exit;
         END CATCH  
        
         FETCH NEXT FROM FKInfo 
           INTO @outTABLENAME,@Schema_Name,@Foreign_Key,@COL_Name,@Reference_Table_Name,@Reference_Schema,@Reference_COL_Name,@DELETE_REFERENTIAL_ACTION,@UPDATE_REFERENTIAL_ACTION
	   END 
  CLOSE FKInfo;                                                                                                                     
 DEALLOCATE FKInfo;
 

------------------------------
-- 結束程式
   Main_Exit:
------------------------------
