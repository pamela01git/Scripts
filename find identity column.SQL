This is what i use without using the system function:

--Find IDENTITIES
select 
'TableName' = o.name, 
'ColumnName' = c.name, 
* 
from sysobjects o
inner join syscolumns c
on o.id = c.id
where c.status = 128
and o.type = 'u'
and o.status > 0
order by o.name


http://forums.databasejournal.com/showthread.php?t=38700