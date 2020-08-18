USE [BMSDB]
GO
/****** Object:  StoredProcedure [dbo].[SP_Create_FKInfo]    Script Date: 2013/5/31 下午 03:04:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC [dbo].[SP_Get_FKInfo] 'BMSDB','DBO','BMS_RAT_TX_BATCH'

ALTER  PROCEDURE [dbo].[SP_Create_FKInfo]
    @DBNAME       CHAR(20),
    @SCHEMA       VARCHAR(30),
    @TABLENAME    VARCHAR(50)     
AS
---------------------------------------------------
-- STEP 0: Foreign Key Info
---------------------------------------------------

DECLARE
 @ERROR_MESSAGE  NVARCHAR(4000)
       ,@outTABLENAME sysname  
       ,@Schema_Name sysname
       ,@Foreign_Key SYSNAME,
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
