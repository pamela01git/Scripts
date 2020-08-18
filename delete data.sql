--宣告CURSOR
DECLARE @SQL NVARCHAR(4000)
DECLARE @TableNm VARCHAR(30) --變數
DECLARE @TEMPCNT INT

SET @TEMPCNT = 0

--TblList name
DECLARE TblList CURSOR FOR 

           SELECT  'odsdba.'+REPLACE([NAME],' ','')             
           FROM pcusegdb_pd.dbo.sysobjects
           WHERE NAME LIKE 'FS_%'; -- cursor裡的資料
   
        OPEN TblList; -- 開始執行
        FETCH NEXT FROM TblList --第一筆
             INTO @TableNm -- cursor裡的變數    
                                                                                                          
        WHILE @@FETCH_STATUS = 0   --當結束時就停止
     
BEGIN --開始進行作業
   
   IF @TEMPCNT <> 0 BEGIN
   set @SQL=@SQl + N' UNION ALL SELECT DISTINCT CONVERT(CHAR(8),DATADT,112),'''+REPLACE(@TableNm,' ','')+''' FROM '+ @TableNm+' WHERE DATADT NOT IN (''20051201'',''20060101'')'
   END ELSE BEGIN 
   SET @SQL=N'SELECT DISTINCT convert(char(8),DATADT,112) ,'''+@TableNm+''' FROM '+ @TableNm+' WHERE DATADT NOT IN (''20051201'',''20060101'')'
   END 

       
   FETCH NEXT FROM TblList --進行下一筆
   INTO @TableNm    
              SET @TEMPCNT = @TEMPCNT +1;
END   

CLOSE TblList;        --結束cursor                                                                                                              
DEALLOCATE TblList;

--PRINT @SQL
 EXEC SP_EXECUTESQL @SQL


