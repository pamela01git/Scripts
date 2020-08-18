USE CRMBASISDB
GO

--宣告CURSOR
DECLARE @TableName CHAR(50) --變數
DECLARE @SQL VARCHAR(8000)

if exists (select * from dbo.sysobjects where name = 'MD_TABLEUsage')
Drop Table odsdba.MD_TABLEUsage
CREATE TABLE odsdba.MD_TABLEUsage (name  NVARCHAR(128),ROWS CHAR(11),reserved VARCHAR(18),data VARCHAR(18),index_size VARCHAR(18),UNUSED VARCHAR(18))

--TableList name
DECLARE TableList CURSOR FOR 
     select t.name as TBL_NM                         
     from crmbasisdb.sys.tables t 
     where   t.name not like '%_err%'
      and odsdb.dbo.instr(name,'_',1) in ('CB','CS','FB','FS','MD','TX','CRM','ODS','ODSMS')
      and ISNUMERIC(RIGHT(RTRIM(NAME),6))= 0
     order by tbl_nm
   
        OPEN TableList; -- 開始執行
        FETCH NEXT FROM TableList --第一筆
             INTO @TableName -- cursor裡的變數    
                                                                                                          
        WHILE @@FETCH_STATUS = 0   --當結束時就停止
     
BEGIN --開始進行作業

   SET @SQL ='INSERT INTO odsdba.MD_TABLEUsage EXEC sp_spaceused N''odsdba.'+RTRIM(@TableName)+''';' 
   --print @sql
   EXEC (@SQL)

       
   FETCH NEXT FROM TableList --進行下一筆
   INTO @TableName    
END   

CLOSE TableList;        --結束cursor                                                                                                              
DEALLOCATE TableList;

  select * from odsdba.MD_TABLEUsage
  DROP TABLE odsdba.MD_TABLEUsage