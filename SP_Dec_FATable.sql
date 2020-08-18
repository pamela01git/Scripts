set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


ALTER PROCEDURE [odsdba].[SP_Dec_FATable]
AS
DECLARE @EVE_SQL NVARCHAR(4000)
DECLARE @ODD_SQL NVARCHAR(4000)

DECLARE @TableName VARCHAR(40)
DECLARE @ERR_NO    int             --錯誤代碼


  BEGIN TRAN    




DECLARE TbNm CURSOR FOR 
    SELECT name FROM riskmgtdb.dbo.sysobjects 
    WHERE Name like 'FA_%' and name like '%_MS';  
   
        OPEN TbNm;
        FETCH NEXT FROM TbNm 
             INTO @TableName    
                                                                                                          
        WHILE @@FETCH_STATUS = 0   
     
BEGIN

SET @EVE_SQL = ''
SET @ODD_SQL = ''
   
  ---------子CURSOR
     DECLARE @ColumnName VARCHAR(40)
     DECLARE @TEMPCNT INT
     SET @TEMPCNT = 0
     
     
     DECLARE ClNm CURSOR FOR 
           select   c.name as column_name
           from sys.columns c, sys.tables t, sys.types p
           where c.object_id = t.object_id 
           and c.system_type_id = p.system_type_id --and t.schema_id = 1 
           and t.name = @TableName
           and (c.name  like '%BAL%' or c.name like '%AMT%')
           and p.name = 'numeric'
           order by c.column_id
      
        
             OPEN ClNm;
             FETCH NEXT FROM ClNm 
                  INTO @ColumnName    
                                                                                                               
             WHILE @@FETCH_STATUS = 0   
          
     BEGIN
        IF @TEMPCNT = 0 BEGIN 
          SET @EVE_SQL = @ColumnName+'='+@ColumnName+'/2';	
          SET @ODD_SQL = @ColumnName+'='+@ColumnName+'*2';	
        END ELSE BEGIN
          SET @EVE_SQL = @EVE_SQL + ','+@ColumnName+'='+@ColumnName+'/2';
          SET @ODD_SQL = @ODD_SQL + ','+@ColumnName+'='+@ColumnName+'*2';
        END
        
        
        FETCH NEXT FROM ClNm 
        INTO @ColumnName   
        
        SET @TEMPCNT = @TEMPCNT +1;
     	
     END   
     
     CLOSE ClNm;                                                                                                                      
     DEALLOCATE ClNm;
     
 ----------------------------    


   
   SET  @EVE_SQL = 'UPDATE S1 SET '+@EVE_SQL+' FROM odsdba.'+@TableName+' S1 WHERE right(rtrim(custkey),1) between ''0'' and ''9'' AND convert(int,right(rtrim(custkey),1))%2 = 0;SELECT @ERR_NO =@@ERROR' 
   SET  @ODD_SQL = 'UPDATE S1 SET '+@ODD_SQL+' FROM odsdba.'+@TableName+' S1 WHERE right(rtrim(custkey),1) between ''0'' and ''9'' AND convert(int,right(rtrim(custkey),1))%2 = 1;SELECT @ERR_NO =@@ERROR'   
   EXEC SP_EXECUTESQL @EVE_SQL,N'@ERR_NO INT OUT',@ERR_NO OUT 
      IF @ERR_NO  <> 0 GOTO BATCH_ERR_HANDLE;
   EXEC SP_EXECUTESQL @ODD_SQL,N'@ERR_NO INT OUT',@ERR_NO OUT
      IF @ERR_NO  <> 0 GOTO BATCH_ERR_HANDLE;
   FETCH NEXT FROM TbNm 
   INTO @TableName   
	
END   

CLOSE TbNm;                                                                                                                      
DEALLOCATE TbNm;


------------------------------
-- 整批模式處理成功
------------------------------
PRINT 'Batch Mode : Finished Successfully';
PRINT '';

    COMMIT TRAN;
    GOTO MAIN_EXIT;

-------------------------------------------------------------------------------
-- 整批模式錯誤處理
   BATCH_ERR_HANDLE:
-------------------------------------------------------------------------------
PRINT 'Batch Mode : Failure';
PRINT '';
    ROLLBACK TRAN;
           


------------------------------
-- 程式結束 ODSDBA.SP_INS_XStatus
   MAIN_EXIT:
------------------------------
IF @ERR_NO<>0 BEGIN RAISERROR(@ERR_NO, 16, 1);
RETURN(@ERR_NO) 
END ELSE
RETURN 0

