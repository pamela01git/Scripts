--EXEC sp_rename 'CB_BG.BG_key', 'BG_KEY', 'COLUMN'








         DECLARE @TABLE_SCHEMA SYSNAME, @TABLE_NAME SYSNAME,@COLUMN_NAME SYSNAME  ,@SQL NVARCHAR(MAX) 


           DECLARE ParamList CURSOR LOCAL  FOR 
              SELECT TABLE_SCHEMA,TABLE_NAME,COLUMN_NAME
			  FROM INFORMATION_SCHEMA.COLUMNS

   
        OPEN ParamList; 
        FETCH NEXT FROM ParamList 
             INTO @TABLE_SCHEMA,@TABLE_NAME,@COLUMN_NAME    
                                                                                                          
        WHILE @@FETCH_STATUS = 0   
     
          BEGIN 


		    SET @SQL = 'EXEC sp_rename '''+RTRIM(@TABLE_SCHEMA)+'.'+RTRIM(@TABLE_NAME)+'.'+RTRIM(@COLUMN_NAME)+''','''+UPPER(@COLUMN_NAME)+''',''COLUMN'''
		--PRINT @SQL
		   EXEC (@SQL)
       
            FETCH NEXT FROM ParamList 
              INTO @TABLE_SCHEMA,@TABLE_NAME,@COLUMN_NAME    
              
          END   

         CLOSE ParamList;                                                                                                                     
         DEALLOCATE ParamList;
