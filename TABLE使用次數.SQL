

--宣告CURSOR
DECLARE @TableName CHAR(50) --變數
DECLARE @SQL VARCHAR(8000)

if exists (select * from dbo.sysobjects where name = 'MD_TABLEInfo')
Drop Table odsdba.MD_TABLEInfo
CREATE TABLE odsdba.MD_TABLEInfo (TableName CHAR(50),CNT INT)

--TableList name
DECLARE TableList CURSOR FOR 
     select t.name as TBL_NM                         
     from crmbasisdb.sys.tables t 
     where   t.name not like '%_err%'
      and odsdb.dbo.instr(name,'_',1) in ('CB','CS','FB','FS','MD','TX','CRM','ODS','ODSMS')
      and name not in ('CS_Pcust_GantDtl')
      and ISNUMERIC(RIGHT(RTRIM(NAME),6))= 0
     order by tbl_nm
   
        OPEN TableList; -- 開始執行
        FETCH NEXT FROM TableList --第一筆
             INTO @TableName -- cursor裡的變數    
                                                                                                          
        WHILE @@FETCH_STATUS = 0   --當結束時就停止
     
BEGIN --開始進行作業

   SET @SQL ='INSERT INTO odsdba.MD_TABLEInfo SELECT '''+RTRIM(@TableName) + ''',COUNT(1) FROM (SELECT DISTINCT a.[name] FROM DBO.SYSOBJECTS A JOIN DBO.SYSCOMMENTS B ON A.ID=B.ID WHERE B.[TEXT] LIKE ''%crmbasisdb.odsdba.'+RTRIM(@TableName) + '%'') A' 
   --print @sql
   exec (@SQL)

       
   FETCH NEXT FROM TableList --進行下一筆
   INTO @TableName    
END   

CLOSE TableList;        --結束cursor                                                                                                              
DEALLOCATE TableList;

  select * from odsdba.MD_TABLEInfo
