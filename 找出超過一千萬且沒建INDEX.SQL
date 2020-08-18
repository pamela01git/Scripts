
           DECLARE @TABLENAME   CHAR(40) 
DECLARE @DT_IDX CHAR(1)
DECLARE @DT_FG CHAR(1)
DECLARE @INS_USAGE_SQL VARCHAR(MAX)
DECLARE @ROWS BIGINT



           DECLARE ParamList CURSOR LOCAL  FOR 
              SELECT [NAME] FROM  sys.tables
              WHERE SCHEMA_ID = 5
               ORDER BY [NAME];
   
        OPEN ParamList; 
        FETCH NEXT FROM ParamList 
             INTO @TABLENAME     
                                                                                                          
        WHILE @@FETCH_STATUS = 0   
     
          BEGIN 

IF EXISTS (SELECT * FROM TEMPDB.DBO.sysobjects WHERE Name ='##MD_TABLEUsage') DROP TABLE ##MD_TABLEUsage;    
CREATE TABLE ##MD_TABLEUsage (name  NVARCHAR(128),ROWS CHAR(11),reserved VARCHAR(18),data VARCHAR(18),index_size VARCHAR(18),UNUSED VARCHAR(18))  
      	SET @INS_USAGE_SQL ='INSERT INTO ##MD_TABLEUsage EXEC DBO.sp_spaceused N''odsdba.'+RTRIM(@TableName)+''';' 
      	EXEC (@INS_USAGE_SQL)
   

      	SET @ROWS = (SELECT ROWS FROM ##MD_TABLEUsage)
SET @DT_IDX ='N'
 IF EXISTS ( SELECT  * 
                   FROM  dbo.SYSOBJECTS A
                    JOIN dbo.SYSINDEXES C ON A.ID=C.ID
                    JOIN dbo.SYSINDEXKEYS D ON C.ID=D.ID AND C.INDID=D.INDID
                    JOIN dbo.SYSCOLUMNS E ON E.ID=C.ID AND D.COLID=E.COLID   
                  WHERE A.NAME=RTRIM(@TABLENAME)
                    AND E.name = 'DATADT'
                    AND C.INDID <> 0) SET @DT_IDX ='Y';

    SET @DT_FG ='N'
  IF EXISTS (SELECT * FROM sys.columns c, sys.tables t 
  where c.object_id = t.object_id  and t.NAME=RTRIM(@TABLENAME)
      AND c.name ='DATADT' )SET @DT_FG ='Y';

  IF @DT_IDX <> @DT_FG AND @ROWS > 5000000
    BEGIN 
     SELECT @TABLENAME,@ROWS
    END

       
            FETCH NEXT FROM ParamList 
            INTO @TABLENAME
              
          END   

         CLOSE ParamList;                                                                                                                     
         DEALLOCATE ParamList;
