
------------------------------------------------------
Oracle部分

select * from openquery(mes,'select table_name,column_name,data_type,data_precision,data_scale,char_length from all_tab_cols 
where table_name in( ''BM_DFTCODE'',''BM_EQPLSCODE'',''BM_FS_SPEC'',''BM_FS_SPEC_FAMILY_CO'',''BM_LINE'',
''BM_PRODUCT'',''BM_SCODE'',''BM_TANK'',''HS_CPOP'',''HS_SHTOP'',''PT_BATCH'',''PT_CP'',''PT_CRATE'',''PT_DP'',''PT_FLOWDATA'',
''PT_SHT'',''PT_SLOTMAP'',''PT_UNSCHEDULE_HOURS'',''SP_FINISH_THEO_VALUE'',''SP_MELT_THEO_VALUE'',''USM_USER'') ')



文字比對
char_length

數字比對
(data_precision, data_scale)
12,3

時間不比


MS SQL抓table過濾條件 可從create_date時間上去找


-----------------------------------------------------
MS SQL 部分

--產生所有table的名稱，已抓取oracle的所有table資訊

create table #tmpT(
name varchar(30),
num int 
)

select * from #tmpT

select a.[name] as tb ,COUNT(*) cnt into #tmpT--,e.[name] as column_name,f.name as schema_name
--,g.name as column_typesize,e.length as char_length,E.xprec,E.XSCALE
  from sysobjects a
   join syscolumns e on e.id=a.id 
      join sys.schemas f on a.uid=f.schema_id
      join systypes g on e.XuserTYPE=g.XuserTYPE
      WHERE f.name='mes' --AND  c.indid=1
   group by a.name
   order by a.[name]--,e.colid

select ''''+substring(tb,9,20)+''''+',' from #tmpT

--抓取T-SQL的table資訊
select a.[name] as tb ,e.[name] as column_name,f.name as schema_name
,g.name as column_type,e.length as char_length,E.xprec,E.XSCALE
  from sysobjects a
   join syscolumns e on e.id=a.id 
      join sys.schemas f on a.uid=f.schema_id
      join systypes g on e.XuserTYPE=g.XuserTYPE
      WHERE f.name='mes' --AND  c.indid=1
   order by a.[name]--,e.colid

--組合比對 outerjoin

select *
from 
(select substring(a.[name],9,20) as tb ,e.[name] as column_name,f.name as schema_name
,g.name as column_type,e.length as char_length,E.xprec,E.XSCALE
  from sysobjects a
   join syscolumns e on e.id=a.id 
      join sys.schemas f on a.uid=f.schema_id
      join systypes g on e.XuserTYPE=g.XuserTYPE
      WHERE f.name='mes' --AND  c.indid=1
   ) tb1 
   full join 
   (select * from openquery(mes,'select table_name,column_name,data_type,data_precision,data_scale,char_length from all_tab_cols 
where table_name in( ''BM_DFTCODE'',''BM_EQPLSCODE'',''BM_FS_SPEC'',''BM_FS_SPEC_FAMILY_CO'',''BM_LINE'',
''BM_PRODUCT'',''BM_SCODE'',''BM_TANK'',''HS_CPOP'',''HS_SHTOP'',''PT_BATCH'',''PT_CP'',''PT_CRATE'',''PT_DP'',''PT_FLOWDATA'',--,e.colid
''PT_SHT'',''PT_SLOTMAP'',''PT_UNSCHEDULE_HOURS'',''SP_FINISH_THEO_VALUE'',''SP_MELT_THEO_VALUE'',''USM_USER'') ')) tb2 on tb1.tb = tb2.table_name and tb1.column_name = tb2.column_name 
where (tb1.tb is null or tb2.table_name is null 
OR (tb1.column_type ='nvarchar' and tb2.data_type <> 'VARCHAR2')
OR (tb1.column_type <> 'nvarchar' and tb1.column_type <> 'nchar' and tb2.data_type = 'VARCHAR2')
OR (tb1.column_type ='nchar' and tb2.data_type <> 'CHAR' AND tb2.data_type <> 'VARCHAR2')
OR (tb1.column_type <> 'nchar' and tb2.data_type = 'CHAR')
OR (tb1.column_type ='datetime' and tb2.data_type <> 'DATE')
OR (tb1.column_type <> 'datetime' and tb1.column_type <> 'date' and tb2.data_type = 'DATE')
OR (tb1.column_type ='decimal' and (tb2.data_type <> 'NUMBER' AND tb2.data_type <> 'FLOAT'))

OR (tb1.column_type ='nvarchar' and tb2.data_type = 'VARCHAR2' and tb1.char_length/2 <>tb2.char_length)
OR (tb1.column_type ='nchar' and tb2.data_type = 'CHAR' and tb1.char_length/2 <>tb2.char_length)
OR (tb1.column_type ='decimal' and tb2.data_type = 'NUMBER' and tb1.xprec <> tb2.data_precision )
OR (tb1.column_type ='decimal' and tb2.data_type = 'NUMBER' and tb1.xscale <> tb2.data_scale))
--and tb1.column_name not in ('Last_Maintain_Date','Last_System_Maintain_Date','Last_Maintain_User')

order by 2,1

----test 用
select *
from 
(select substring(a.[name],9,20) as tb ,e.[name] as column_name,f.name as schema_name
,g.name as column_type,e.length as char_length,E.xprec,E.XSCALE
  from sysobjects a
   join syscolumns e on e.id=a.id 
      join sys.schemas f on a.uid=f.schema_id
      join systypes g on e.XuserTYPE=g.XuserTYPE
      WHERE f.name='mes' --AND  c.indid=1
   ) tb1 
   full join 
   (select * from openquery(mes,'select table_name,column_name,data_type,data_precision,data_scale,char_length from all_tab_cols 
where table_name in( ''BM_DFTCODE'',''BM_EQPLSCODE'',''BM_FS_SPEC'',''BM_FS_SPEC_FAMILY_CO'',''BM_LINE'',
''BM_PRODUCT'',''BM_SCODE'',''BM_TANK'',''HS_CPOP'',''HS_SHTOP'',''PT_BATCH'',''PT_CP'',''PT_CRATE'',''PT_DP'',''PT_FLOWDATA'',--,e.colid
''PT_SHT'',''PT_SLOTMAP'',''PT_UNSCHEDULE_HOURS'',''SP_FINISH_THEO_VALUE'',''SP_MELT_THEO_VALUE'',''USM_USER'') ')) tb2 on tb1.tb = tb2.table_name and tb1.column_name = tb2.column_name 
where (tb1.column_type ='nchar' and tb2.data_type = 'VARCHAR2')
--(tb1.column_type ='nvarchar' and tb2.data_type <> 'VARCHAR2')
--OR (tb1.column_type <> 'nvarchar' and tb2.data_type = 'VARCHAR2')
--OR (tb1.column_type ='nchar' and tb2.data_type <> 'CHAR' AND tb2.data_type <> 'VARCHAR2')
--OR (tb1.column_type <> 'nchar' and tb2.data_type = 'CHAR')

--
MS SQL的40為bytes, Oracle的是字元
nvarchar(10)   typesize為20  because 1 nvarchar = 2 Bytes
並且比對data_type時，要轉換欄位型態

ODS_MES_BM_DFTCODE	DF_ID	MES	nchar	40	0	0

--
