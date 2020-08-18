select CASE WHEN C.COLID <> 1 THEN ', ' ELSE ' ' END  
+'['+rtrim(c.name)+'] '+ case when t.name in ('int','smallint','bigint','bit','datetime','text') then UPPER(t.name) when t.name = 'numeric' then  UPPER(t.name)+'('+rtrim(c.xprec)+','+rtrim(c.xscale)+')' else UPPER(t.name)+'('+rtrim(c.length)+')' end
+case when  c.status = 128 then ' identity(1,1) ' else ' ' end +case when c.isnullable = 1 then 'NULL' ELSE 'NOT NULL' END
+CASE WHEN c.cdefault <> 0 THEN ' DEFAULT '+RTRIM(CM.TEXT) ELSE '' END 
,G.GROUPNAME
,c.id,c.colid,c.name,c.cdefault,c.isnullable,c.status
,t.name,c.*
from dbo.SYSOBJECTS o
INNER JOIN dbo.SYSINDEXES I ON (O.ID=I.ID)
INNER JOIN DBO.SYSFILEGROUPS G ON (I.GROUPID = G.GROUPID)
,dbo.SYSCOLUMNS c
LEFT OUTER JOIN DBO.syscomments CM ON (CM.ID = c.cdefault)
,dbo.SYSTYPES T
where o.id= c.id
  AND t.xtype=c.xusertype 
  and o.name= 'FB_ACCT1PF_MS'
  and o.xtype = 'u'
order by c.colid