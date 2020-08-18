--EXEC sp_rename 'CB_BG.BG_key', 'BG_KEY', 'COLUMN'


         DECLARE @TABLE_SCHEMA SYSNAME,@TABLE_NAME SYSNAME ,@SQL NVARCHAR(MAX) 


           DECLARE ParamList CURSOR LOCAL  FOR 
              SELECT distinct TABLE_SCHEMA,TABLE_NAME
			  FROM INFORMATION_SCHEMA.COLUMNS

   
        OPEN ParamList; 
        FETCH NEXT FROM ParamList 
             INTO @TABLE_SCHEMA,@TABLE_NAME  
                                                                                                          
        WHILE @@FETCH_STATUS = 0   
     
          BEGIN 


		  SET @SQL = 'EXEC sp_rename '''+RTRIM(@TABLE_SCHEMA)+'.'+RTRIM(@TABLE_NAME)+''','''+UPPER(@table_NAME)+''''
	 PRINT @SQL
	   EXEC (@SQL)
       
            FETCH NEXT FROM ParamList 
             INTO @TABLE_SCHEMA,@TABLE_NAME  
              
          END   

         CLOSE ParamList;                                                                                                                     
         DEALLOCATE ParamList;
