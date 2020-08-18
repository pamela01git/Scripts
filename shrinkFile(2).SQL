     DECLARE @FILE_NAME CHAR(40)
         DECLARE @FILE_SIZE CHAR(10)

           DECLARE FILELIST CURSOR LOCAL  FOR 
              SELECT  [NAME],(CAST(FILEPROPERTY(name, 'SpaceUsed') AS int)+128)/128             
              FROM sys.database_files
              WHERE [SIZE]-CAST(FILEPROPERTY(name, 'SpaceUsed') AS int) > 128
            ORDER BY [NAME];
   
        OPEN FILELIST; 
        FETCH NEXT FROM FILELIST 
             INTO @FILE_NAME,@FILE_SIZE     
                                                                                                          
        WHILE @@FETCH_STATUS = 0   
     
          BEGIN 

            PRINT 'DBCC SHRINKFILE(N'''+RTRIM(@FILE_NAME)+''','+RTRIM(@FILE_SIZE)+')'
      --  SHRINKFILE (N'CRMBasisDB_Data' , 151850)
            PRINT 'GO'


       
            FETCH NEXT FROM FILELIST 
            INTO @FILE_NAME,@FILE_SIZE     
              
          END   

         CLOSE FILELIST;                                                                                                                     
         DEALLOCATE FILELIST;
