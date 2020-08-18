
   DECLARE @SCHEMA       VARCHAR(30) = 'dbo'
   , @TABLENAME    VARCHAR(50) = 'n_bl_acct'
   ,@DBNAME CHAR(10) = 'ODSDATA'
    
DECLARE @ERROR_MESSAGE  NVARCHAR(MAX)
       ,@COLLATION VARCHAR(50)
       ,@Get_Table_Schema_SQL nvarchar(max)
       
SET @COLLATION = (SELECT CONVERT(VARCHAR(50),DATABASEPROPERTYEX(@DBNAME,'COLLATION')))

------------------------------
-- STEP1:Table Schema
------------------------------  

SET @Get_Table_Schema_SQL 
	='USE '+RTRIM(@DBNAME)+'
	  SELECT C.COLUMN_ID AS COL_ID
			,c.NAME AS COL_NM
			, CASE WHEN ISC.DATA_TYPE in (''int'',''smallint'',''bigint'',''bit'',''datetime'',''text'',''sysname'',''tinyint'',''uniqueidentifier'',''float'') THEN UPPER(ISC.DATA_TYPE) WHEN ISC.DATA_TYPE IN (''numeric'',''decimal'') THEN  UPPER(ISC.DATA_TYPE)+''(''+RTRIM(ISC.NUMERIC_PRECISION)+'',''+RTRIM(ISC.NUMERIC_SCALE)+'')'' ELSE UPPER(ISC.DATA_TYPE)+''(''+RTRIM(CASE WHEN ISC.CHARACTER_MAXIMUM_LENGTH = -1 THEN ''MAX'' ELSE ISC.CHARACTER_MAXIMUM_LENGTH  END)+'')'' END  AS DATA_TYPE 
	  FROM sys.tables T
		INNER JOIN sys.indexes  I ON (T.object_id=I.object_id)
		INNER JOIN sys.data_spaces S ON (S.data_space_id = i.data_space_id)
		INNER JOIN sys.columns c  ON (c.object_id = t.object_id  )
		INNER JOIN SYS.TYPES tp ON (tp.USER_TYPE_ID=C.USER_TYPE_ID)
		INNER JOIN INFORMATION_SCHEMA.COLUMNS ISC ON (ISC.COLUMN_NAME=C.NAME)
	  WHERE T.NAME = '''+LTRIM(RTRIM(@TABLENAME))+'''
		AND ISC.TABLE_NAME = '''+LTRIM(RTRIM(@TABLENAME))+'''
        AND ISC.TABLE_SCHEMA = '''+LTRIM(RTRIM(@SCHEMA))+'''
		AND I.INDEX_ID < 2 --Heap or Cluster Index
	  ORDER BY C.COLUMN_ID;' 
	  
   --PRINT @Get_Table_Schema_SQL;
   EXECUTE sp_executesql @Get_Table_Schema_SQL;

==================================================

	declare @TABLENAME varchar(max) ='ODS_UI_UPLOAD_AFP'
	  ,@SCHEMA VARCHAR(MAX)= 'DBO'
	  SELECT C.COLUMN_ID AS COL_ID
			,c.NAME AS COL_NM
			, CASE WHEN ISC.DATA_TYPE in ('int','smallint','bigint','bit','datetime','DATE','DATETIME2','text','sysname','tinyint','uniqueidentifier','float') THEN UPPER(ISC.DATA_TYPE) WHEN ISC.DATA_TYPE IN ('numeric','decimal') 
			THEN  UPPER(ISC.DATA_TYPE)+'('+RTRIM(ISC.NUMERIC_PRECISION)+','+RTRIM(ISC.NUMERIC_SCALE)+')' ELSE UPPER(ISC.DATA_TYPE)+'('+RTRIM(CASE WHEN ISC.CHARACTER_MAXIMUM_LENGTH = -1 THEN 'MAX' ELSE ISC.CHARACTER_MAXIMUM_LENGTH  END)+')' END  AS DATA_TYPE 
	  FROM sys.tables T
		INNER JOIN sys.indexes  I ON (T.object_id=I.object_id)
		INNER JOIN sys.data_spaces S ON (S.data_space_id = i.data_space_id)
		INNER JOIN sys.columns c  ON (c.object_id = t.object_id  )
		INNER JOIN SYS.TYPES tp ON (tp.USER_TYPE_ID=C.USER_TYPE_ID)
		INNER JOIN INFORMATION_SCHEMA.COLUMNS ISC ON (ISC.COLUMN_NAME=C.NAME)
	  WHERE T.NAME = LTRIM(RTRIM(@TABLENAME))
		AND ISC.TABLE_NAME = LTRIM(RTRIM(@TABLENAME))
        AND ISC.TABLE_SCHEMA = LTRIM(RTRIM(@SCHEMA))
		AND I.INDEX_ID < 2 --Heap or Cluster Index
	  ORDER BY C.COLUMN_ID;