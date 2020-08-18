           DECLARE @dbname VARCHAR(MAX)
           declare @tablename  VARCHAR(MAX)


           DECLARE ParamList CURSOR LOCAL  FOR 
              SELECT  dbname,tablename             
              FROM dbo.REPL_CRM;
   
        OPEN ParamList; 
        FETCH NEXT FROM ParamList 
             INTO @dbname,@tablename     
                                                                                                          
        WHILE @@FETCH_STATUS = 0   
     
          BEGIN 
             print 'USE ['+RTRIM(@DBNAME)+']'
             PRINT 'GO'
             PRINT 'GRANT SELECT ON [odsdba].['+RTRIM(@TABLENAME)+'] TO [crmuser]'
             PRINT 'GO'



       
            FETCH NEXT FROM ParamList 
            INTO  @dbname,@tablename     
              
          END   

         CLOSE ParamList;                                                                                                                     
         DEALLOCATE ParamList;
