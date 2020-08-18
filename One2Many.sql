DECLARE @CNT INT                 --CSV檔案個數
DECLARE @TEMPCNT INT             --TEMP COUNT
DECLARE @NewCSVNM VARCHAR(100)   --CSV NAME
DECLARE @FolderNm VARCHAR(100)   --存放CSV的路徑
DECLARE @Path VARCHAR(100)       --CSV之絕對路徑
DECLARE @SQL  varchar(8000)      --SQL Command
DECLARE @ERR_NO   int            --錯誤代碼


@CNT =(select crmbasisdb.dbo.dcount(csvnm,'.csv') from reportdb.odsdba.cb_csvlist );
SET @FolderNm ='C:\ReportDB\CSV\'

--初始化變數
SET @TEMPCNT = 0;
SET @NewCSVNM = '';
      
IF @CNT > 0 BEGIN
   WHILE  @TEMPCNT < @CNT
     BEGIN

       if @TEMPCNT > 0
       begin 
       	  set @NewCSVNM =(select substring(replace(crmbasisdb.dbo.instr(csvnm,'.csv',@TEMPCNT+1),'csv',''),2,7) from reportdb.odsdba.cb_csvlist)
       	  SET @NewCSVNM = REPLACE(@NewCSVNM,' ','')+'.csv'
          set @Path = @FolderNm + @NewCSVNM;
          set @SQL = 'BULK INSERT TMP_MD_RptPermission from '''+replace(@Path,' ','') +''' WITH (FIRSTROW=2,FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'')';          
       exec (@SQL);
       end else begin
       	  set @NewCSVNM =(select crmbasisdb.dbo.instr(csvnm,'.csv',@TEMPCNT+1) from reportdb.odsdba.cb_csvlist)
       	  SET @NewCSVNM = REPLACE(@NewCSVNM,' ','')+'.csv'
       	  set @Path = @FolderNm + @NewCSVNM;
          set @SQL = 'BULK INSERT TMP_MD_RptPermission from '''+@Path +''' WITH (FIRSTROW=2,FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'')';
       exec (@SQL) ;
       end	  
        SET @TEMPCNT = @TEMPCNT +1;
    END;                     
END;    
