

--宣告CURSOR
DECLARE @tablename CHAR(40) --變數
DECLARE @COLNAME CHAR(20)

--tablename name
DECLARE tablename CURSOR FOR 

--查詢狀態
select 'odsdb.odsdba.'+tablename,colname from dbo.XSurStatus
where left(rtrim(tablename),5) = 'odsms' 
  and run_status = 'runok'
 union all
select 'crmbasisdb.odsdba.cb_pcust_ms','UNINO'
union all
select 'crmbasisdb.odsdba.cb_pcust_ms','CUSTKEY'



   
        OPEN tablename; -- 開始執行
        FETCH NEXT FROM tablename --第一筆
             INTO @tablename,@COLNAME -- cursor裡的變數    
                                                                                                          
        WHILE @@FETCH_STATUS = 0   --當結束時就停止
     
BEGIN --開始進行作業


  --宣告CURSOR
DECLARE @DATADT CHAR(8) --變數
declare @sql nvarchar(4000)

 --Step2:確認該TABLE是否有DTADT為Index
 
             
     

         	
           DECLARE DATADTList CURSOR FOR 
           
             SELECT CONVERT(CHAR(8),TMNBDT,112) AS DATADT             
             FROM ODSDB.ODSDBA.CB_DT S1
             WHERE S1.BEOM_FG = 'Y' --只挑選月初日
               AND TMNBDT BETWEEN '20050301' AND '20070701' ; --介於CRM資料起日與目前截止日
               
               
   
        OPEN DATADTList; 
        FETCH NEXT FROM DATADTList 
             INTO @DATADT 
                                                                                                          
        WHILE @@FETCH_STATUS = 0   
     
BEGIN 

  set @sql ='update s1
             set s1.'+RTRIM(@COLNAME)+' = s2.custkey
             from '+rtrim(@tablename)+' s1
             ,surdb.dbo.cb_surcust s2
             where  CONVERT(CHAR(11),s2.SUR_custkey) = S1.'+RTRIM(@COLNAME)+'
               and s1.datadt='''+rtrim(@datadt)+''''
    print @sql
    exec (@sql)
             
    
       
   FETCH NEXT FROM DATADTList 
   INTO @DATADT    
END   

CLOSE DATADTList;                                                                                                             
DEALLOCATE DATADTList;

       
   FETCH NEXT FROM tablename --進行下一筆
   INTO @tablename,@COLNAME    
END   

CLOSE tablename;        --結束cursor                                                                                                              
DEALLOCATE tablename;
