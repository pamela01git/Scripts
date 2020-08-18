USE ODSDB
GO

CREATE TABLE #TEMP (TABLENM CHAR(20),ODS_CNT INT ,ODSMS_CNT INT)

--宣告CURSOR
DECLARE @TABLE_NAME CHAR(20) --變數
DECLARE @ODS_SQL NVARCHAR(MAX)
DECLARE @ODSMS_SQL NVARCHAR(MAX)
DECLARE @OUT_ODS_CNT INT
DECLARE @OUT_ODSMS_CNT INT

--TableList name
DECLARE TableList CURSOR FOR 

    SELECT DBO.INSTR(NAME,'ODSMS_',2)
    FROM sys.tables 
    WHERE NAME LIKE 'ODSMS%'
       AND NAME NOT LIKE 'ODSMS_OB%'
    ORDER BY NAME
   
        OPEN TableList; -- 開始執行
        FETCH NEXT FROM TableList --第一筆
             INTO @TABLE_NAME -- cursor裡的變數    
                                                                                                          
        WHILE @@FETCH_STATUS = 0   --當結束時就停止
     
BEGIN --開始進行作業

    SET @ODS_SQL = 'SELECT @OUT_ODS_CNT = COUNT(1) FROM ODSDB.ODSDBA.ODS_'+@TABLE_NAME
   EXECUTE sp_executesql @ODS_SQL,N'@OUT_ODS_CNT INT OUT',@OUT_ODS_CNT OUT;
       PRINT @OUT_ODS_CNT

    SET @ODSMS_SQL = 'SELECT @OUT_ODSMS_CNT = COUNT(1) FROM ODSDB.ODSDBA.ODSMS_'+@TABLE_NAME+' WHERE DATADT =''20070401'''
   EXECUTE sp_executesql @ODSMS_SQL,N'@OUT_ODSMS_CNT INT OUT',@OUT_ODSMS_CNT OUT;
       PRINT @OUT_ODSMS_CNT

      IF @OUT_ODS_CNT <> @OUT_ODSMS_CNT INSERT INTO #TEMP SELECT @TABLE_NAME,@OUT_ODS_CNT,@OUT_ODSMS_CNT
   FETCH NEXT FROM TableList --進行下一筆
   INTO @TABLE_NAME    
END   

CLOSE TableList;        --結束cursor                                                                                                              
DEALLOCATE TableList;

SELECT * FROM #TEMP WHERE ODSMS_CNT <> 0 
DROP TABLE #TEMP