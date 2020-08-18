select  convert(varchar(max),convert(varbinary(max),packagedata)),* 
from msdb.dbo.sysdtspackages90
where convert(varchar(max),convert(varbinary(max),packagedata)) like '%TRUNCATE TABLE ODSDB.odsdba.TMP_UN_PRSN%'