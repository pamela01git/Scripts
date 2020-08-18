--以關聯式方式處理
select s1.glorgno,s1.acctkey,s1.baltwd
from odsdba.FB_AcctLN2_DW s1
where datadt ='20050617' and baltwd 
 in (select top 50  baltwd from odsdba.FB_AcctLN2_DW s2
where datadt ='20050617' and s2.glorgno=s1.glorgno order by  s2.baltwd desc ) 
order by glorgno

--以cursor處理
--宣告CURSOR
DECLARE @SQL NVARCHAR(4000)
DECLARE @TableNm CHAR(3) --變數
DECLARE @TEMPCNT INT

SET @TEMPCNT = 0

create table #temp1 (acctkey [char](24),[GLORGNO] [char](3),[BALTWD] [numeric](14, 2) )

--TblList name
DECLARE TblList CURSOR FOR 

           SELECT  orgno
           from crmbasisdb.odsdba.cb_org
           where hdrdep =0;
           
   
        OPEN TblList; -- 開始執行
        FETCH NEXT FROM TblList --第一筆
             INTO @TableNm -- cursor裡的變數    
                                                                                                          
        WHILE @@FETCH_STATUS = 0   --當結束時就停止
     
BEGIN --開始進行作業
	
	insert into #temp1 (acctkey,GLORGNO,BALTWD)
	select top 50  acctkey,GLORGNO,BALTWD from odsdba.FB_AcctLN2_DW s2
where datadt ='20050617' and s2.glorgno=@TableNm
 order by  s2.baltwd desc 
   

       
   FETCH NEXT FROM TblList --進行下一筆
   INTO @TableNm    
              SET @TEMPCNT = @TEMPCNT +1;
END   

CLOSE TblList;        --結束cursor                                                                                                              
DEALLOCATE TblList;

select * from #temp1

--drop table #temp1



